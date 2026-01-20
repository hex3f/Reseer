-- 特殊/扩展命令处理器
-- 包括: 登录响应增强、ENTER_MAP完整响应等

local BinaryWriter = require('utils/binary_writer')
local BinaryReader = require('utils/binary_reader')
local ResponseBuilder = require('utils/response_builder')

local SpecialHandlers = {}

-- ==================== 登录响应增强 ====================

-- CMD 1001: LOGIN_IN (登录游戏服务器) - 完整响应
-- 基于官服响应分析，LOGIN_IN 响应包含完整的用户信息
-- CMD 1001: LOGIN_IN (登录游戏服务器) - 完整响应
local function handleLoginIn(ctx)
    local reader = BinaryReader.new(ctx.body)
    local session = reader:readBytes(8)
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local nickname = user.nick or user.nickname or user.username or ("赛尔" .. ctx.userId)
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeStringFixed(session, 8)
    writer:writeStringFixed(nickname, 20)
    writer:writeBytes(string.rep("\0", 20)) -- 额外昵称空间
    writer:writeUInt32BE(user.level or 15)
    writer:writeUInt32BE(user.exp or 0)
    writer:writeUInt32BE(user.money or 10000)
    writer:writeUInt32BE(user.gold or 0)
    writer:writeUInt32BE(user.vipLevel or 0)
    writer:writeUInt32BE(0) -- vipExp
    writer:writeUInt32BE(0) -- clothCount
    writer:writeUInt32BE(user.currentPetId or 0)
    writer:writeUInt32BE(user.catchId or 0)
    writer:writeUInt32BE(user.mapId or 301)
    writer:writeUInt32BE(user.x or 500)
    writer:writeUInt32BE(user.y or 300)
    
    -- 填充到 200 字节 (虽然 BinaryWriter 自动扩展，但为了保持逻辑一致，这里不额外填充 unless needed by padding logic)
    -- 原逻辑有 while #body < 200 do ... end. 
    -- 让我们检查一下写入了多少字节:
    -- 4+8+20+20+4*9 + 4*3 = 52+36+12 = 100 bytes so far.
    -- padding 100 bytes
    writer:writeBytes(string.rep("\0", 100))

    ctx.sendResponse(ResponseBuilder.build(1001, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → LOGIN_IN response (user=%s)\27[0m", nickname))
    return true
end

-- CMD 2001: ENTER_MAP (进入地图) - 完整响应
local function handleEnterMapFull(ctx)
    local reader = BinaryReader.new(ctx.body)
    local mapId = 0
    local x = 500
    local y = 300
    
    if reader:getRemaining() ~= "" then
        mapId = reader:readUInt32BE()
    end
    if reader:getRemaining() ~= "" then
        x = reader:readUInt32BE()
        y = reader:readUInt32BE()
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.mapId = mapId
    user.x = x
    user.y = y
    ctx.saveUserDB()
    
    local nickname = user.nick or user.nickname or user.username or ("赛尔" .. ctx.userId)
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeStringFixed(nickname, 20)
    writer:writeBytes(string.rep("\0", 20))
    writer:writeUInt32BE(0xFFFFFF) -- color
    writer:writeUInt32BE(0) -- unknown
    writer:writeUInt32BE(user.level or 15)
    writer:writeUInt32BE(0) -- unknown
    writer:writeUInt32BE(user.currentPetId or 7)
    writer:writeUInt32BE(0) -- clothCount
    writer:writeUInt32BE(x)
    writer:writeUInt32BE(y)
    writer:writeUInt32BE(0) -- direction
    
    -- padding to 100
    -- Written: 4+20+20+4*8 = 76 bytes. Need 24 bytes (or just pad to 100 total)
    -- The original logic padded until < 100 ? No `while #body < 100`
    -- 100 - 76 = 24
    writer:writeBytes(string.rep("\0", 24))
    
    ctx.sendResponse(ResponseBuilder.build(2001, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → ENTER_MAP %d at (%d,%d)\27[0m", mapId, x, y))
    return true
end

-- CMD 2101: PEOPLE_WALK (人物移动) - 完整响应
local function handlePeopleWalkFull(ctx)
    local reader = BinaryReader.new(ctx.body)
    local walkType = reader:readUInt32BE()
    local x = 0
    local y = 0
    if reader:getRemaining() ~= "" then
        x = reader:readUInt32BE()
        y = reader:readUInt32BE()
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.x = x
    user.y = y
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeUInt32BE(x)
    writer:writeUInt32BE(y)
    writer:writeUInt32BE(0) -- direction
    
    ctx.sendResponse(ResponseBuilder.build(2101, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 2102: CHAT (聊天) - 完整响应
local function handleChatFull(ctx)
    local reader = BinaryReader.new(ctx.body)
    local chatType = reader:readUInt32BE()
    local msgLen = reader:readUInt32BE()
    local message = reader:readBytes(msgLen)
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local nickname = user.nick or user.nickname or user.username or ("赛尔" .. ctx.userId)
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeStringFixed(nickname, 16)
    writer:writeUInt32BE(0) -- toID
    writer:writeUInt32BE(#message)
    writer:writeBytes(message)
    
    ctx.sendResponse(ResponseBuilder.build(2102, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → CHAT: %s\27[0m", message))
    return true
end

-- CMD 2405: USE_SKILL (使用技能) - 完整战斗流程
local function handleUseSkillFull(ctx)
    local reader = BinaryReader.new(ctx.body)
    local skillId = reader:readUInt32BE()
    
    local user = ctx.getOrCreateUser(ctx.userId)
    
    -- 1. 发送技能确认
    ctx.sendResponse(ResponseBuilder.build(2405, ctx.userId, 0, ""))
    
    -- 2. 发送 NOTE_USE_SKILL (2505)
    local writer = BinaryWriter.new()
    -- 玩家攻击信息
    writer:writeUInt32BE(ctx.userId)
    writer:writeUInt32BE(skillId)
    writer:writeUInt32BE(1)
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(100)
    writer:writeUInt32BE(100)
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(0)
    writer:writeBytes(string.rep("\0", 20))
    writer:writeBytes(string.rep("\0", 6))
    
    -- 敌人受击信息
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(50)
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(50)
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(0)
    writer:writeBytes(string.rep("\0", 20))
    writer:writeBytes(string.rep("\0", 6))
    
    ctx.sendResponse(ResponseBuilder.build(2505, ctx.userId, 0, writer:toString()))
    
    -- 3. 发送 FIGHT_OVER (2506)
    local writer2 = BinaryWriter.new()
    writer2:writeUInt32BE(0)
    writer2:writeUInt32BE(ctx.userId)
    writer2:writeUInt32BE(0)
    writer2:writeUInt32BE(0)
    writer2:writeUInt32BE(0)
    writer2:writeUInt32BE(0)
    writer2:writeUInt32BE(0)
    
    ctx.sendResponse(ResponseBuilder.build(2506, ctx.userId, 0, writer2:toString()))
    
    print(string.format("\27[32m[Handler] → USE_SKILL %d (full battle flow)\27[0m", skillId))
    return true
end

-- CMD 2393: LEIYI_TRAIN_GET_STATUS (雷伊训练获取状态)
local function handleLeiyiTrainGetStatus(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2393, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → LEIYI_TRAIN_GET_STATUS response\27[0m")
    return true
end

-- 注册所有处理器
function SpecialHandlers.register(Handlers)
    -- 这些处理器可以覆盖基础处理器，提供更完整的响应
    -- 如果需要使用增强版，取消下面的注释
    
    -- Handlers.register(1001, handleLoginIn)
    -- Handlers.register(2001, handleEnterMapFull)
    -- Handlers.register(2101, handlePeopleWalkFull)
    -- Handlers.register(2102, handleChatFull)
    -- Handlers.register(2405, handleUseSkillFull)
    
    -- 雷伊训练状态 (从 xin_handlers 移过来)
    Handlers.register(2393, handleLeiyiTrainGetStatus)
    
    print("\27[36m[Handlers] 特殊命令处理器已加载\27[0m")
end

-- 导出单独的处理函数供其他模块使用
SpecialHandlers.handleLoginIn = handleLoginIn
SpecialHandlers.handleEnterMapFull = handleEnterMapFull
SpecialHandlers.handlePeopleWalkFull = handlePeopleWalkFull
SpecialHandlers.handleChatFull = handleChatFull
SpecialHandlers.handleUseSkillFull = handleUseSkillFull

return SpecialHandlers
