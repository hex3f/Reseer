-- 特殊/扩展命令处理器
-- 包括: 登录响应增强、ENTER_MAP完整响应等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local SpecialHandlers = {}

-- ==================== 登录响应增强 ====================

-- CMD 1001: LOGIN_IN (登录游戏服务器) - 完整响应
-- 基于官服响应分析，LOGIN_IN 响应包含完整的用户信息
local function handleLoginIn(ctx)
    local session = ""
    if #ctx.body >= 8 then
        session = ctx.body:sub(1, 8)
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local nickname = user.nick or user.nickname or user.username or ("赛尔" .. ctx.userId)
    
    -- 构建完整的登录响应
    -- 基于官服响应: 963 bytes
    local body = ""
    
    -- 基础信息
    body = body .. writeUInt32BE(ctx.userId)                    -- userId
    body = body .. writeFixedString(session, 8)                 -- session
    body = body .. writeFixedString(nickname, 20)               -- nickname
    body = body .. string.rep("\0", 20)                         -- 额外昵称空间
    body = body .. writeUInt32BE(user.level or 15)              -- level
    body = body .. writeUInt32BE(user.exp or 0)                 -- exp
    body = body .. writeUInt32BE(user.money or 10000)           -- money
    body = body .. writeUInt32BE(user.gold or 0)                -- gold
    body = body .. writeUInt32BE(user.vipLevel or 0)            -- vipLevel
    body = body .. writeUInt32BE(0)                             -- vipExp
    
    -- 服装信息 (clothCount + clothIds)
    body = body .. writeUInt32BE(0)                             -- clothCount
    
    -- 精灵信息
    body = body .. writeUInt32BE(user.currentPetId or 0)        -- currentPetId
    body = body .. writeUInt32BE(user.catchId or 0)             -- catchId
    
    -- 地图信息
    body = body .. writeUInt32BE(user.mapId or 301)             -- mapId
    body = body .. writeUInt32BE(user.x or 500)                 -- x
    body = body .. writeUInt32BE(user.y or 300)                 -- y
    
    -- 填充到合适长度
    while #body < 200 do
        body = body .. "\0"
    end
    
    ctx.sendResponse(buildResponse(1001, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → LOGIN_IN response (user=%s)\27[0m", nickname))
    return true
end

-- ==================== 地图响应增强 ====================

-- CMD 2001: ENTER_MAP (进入地图) - 完整响应
-- 包含地图信息和玩家初始位置
local function handleEnterMapFull(ctx)
    local mapId = 0
    local x = 500
    local y = 300
    
    if #ctx.body >= 4 then
        mapId = readUInt32BE(ctx.body, 1)
    end
    if #ctx.body >= 12 then
        x = readUInt32BE(ctx.body, 5)
        y = readUInt32BE(ctx.body, 9)
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.mapId = mapId
    user.x = x
    user.y = y
    ctx.saveUserDB()
    
    local nickname = user.nick or user.nickname or user.username or ("赛尔" .. ctx.userId)
    
    -- 构建完整的进入地图响应
    -- 包含当前玩家信息
    local body = ""
    
    -- 基础地图信息
    body = body .. writeUInt32BE(ctx.userId)                    -- userId
    body = body .. writeFixedString(nickname, 20)               -- nickname
    body = body .. string.rep("\0", 20)                         -- 额外空间
    body = body .. writeUInt32BE(0xFFFFFF)                      -- color
    body = body .. writeUInt32BE(0)                             -- unknown
    body = body .. writeUInt32BE(user.level or 15)              -- level
    body = body .. writeUInt32BE(0)                             -- unknown
    body = body .. writeUInt32BE(user.currentPetId or 7)        -- petId
    
    -- 服装信息
    body = body .. writeUInt32BE(0)                             -- clothCount
    
    -- 位置信息
    body = body .. writeUInt32BE(x)                             -- x
    body = body .. writeUInt32BE(y)                             -- y
    body = body .. writeUInt32BE(0)                             -- direction
    
    -- 填充
    while #body < 100 do
        body = body .. "\0"
    end
    
    ctx.sendResponse(buildResponse(2001, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → ENTER_MAP %d at (%d,%d)\27[0m", mapId, x, y))
    return true
end

-- CMD 2101: PEOPLE_WALK (人物移动) - 完整响应
-- 需要广播给其他玩家，并返回确认
local function handlePeopleWalkFull(ctx)
    local walkType = 0
    local x = 0
    local y = 0
    
    if #ctx.body >= 4 then
        walkType = readUInt32BE(ctx.body, 1)
    end
    if #ctx.body >= 12 then
        x = readUInt32BE(ctx.body, 5)
        y = readUInt32BE(ctx.body, 9)
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.x = x
    user.y = y
    
    -- 构建移动响应
    -- WalkInfo: userId(4) + x(4) + y(4) + direction(4)
    local body = ""
    body = body .. writeUInt32BE(ctx.userId)
    body = body .. writeUInt32BE(x)
    body = body .. writeUInt32BE(y)
    body = body .. writeUInt32BE(0)  -- direction
    
    ctx.sendResponse(buildResponse(2101, ctx.userId, 0, body))
    return true
end

-- CMD 2102: CHAT (聊天) - 完整响应
-- ChatInfo: senderID(4) + senderNickName(16) + toID(4) + msgLen(4) + msg
local function handleChatFull(ctx)
    local chatType = 0
    local msgLen = 0
    local message = ""
    
    if #ctx.body >= 4 then
        chatType = readUInt32BE(ctx.body, 1)
    end
    if #ctx.body >= 8 then
        msgLen = readUInt32BE(ctx.body, 5)
        if #ctx.body >= 8 + msgLen then
            message = ctx.body:sub(9, 8 + msgLen)
        end
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local nickname = user.nick or user.nickname or user.username or ("赛尔" .. ctx.userId)
    
    -- 构建聊天响应
    local body = ""
    body = body .. writeUInt32BE(ctx.userId)                    -- senderID
    body = body .. writeFixedString(nickname, 16)               -- senderNickName
    body = body .. writeUInt32BE(0)                             -- toID (0=公共)
    body = body .. writeUInt32BE(#message)                      -- msgLen
    body = body .. message                                      -- msg
    
    ctx.sendResponse(buildResponse(2102, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → CHAT: %s\27[0m", message:sub(1, 20)))
    return true
end

-- ==================== 战斗响应增强 ====================

-- CMD 2405: USE_SKILL (使用技能) - 完整战斗流程
-- 需要发送: USE_SKILL确认 + NOTE_USE_SKILL(2505) + FIGHT_OVER(2506)
local function handleUseSkillFull(ctx)
    local skillId = 0
    if #ctx.body >= 4 then
        skillId = readUInt32BE(ctx.body, 1)
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local petId = user.currentPetId or 7
    local bossId = user.currentBossId or 58
    
    -- 1. 发送技能确认
    ctx.sendResponse(buildResponse(2405, ctx.userId, 0, ""))
    
    -- 2. 发送 NOTE_USE_SKILL (2505)
    -- UseSkillInfo: firstAttackInfo + secondAttackInfo
    -- AttackValue: userID(4) + skillID(4) + atkTimes(4) + lostHP(4) + gainHP(4) + 
    --              remainHp(4) + maxHp(4) + state(4) + skillListCount(4) + [skills] + 
    --              isCrit(4) + status(20) + battleLv(6)
    
    local body2505 = ""
    
    -- 玩家攻击信息
    body2505 = body2505 .. writeUInt32BE(ctx.userId)            -- userID
    body2505 = body2505 .. writeUInt32BE(skillId)               -- skillID
    body2505 = body2505 .. writeUInt32BE(1)                     -- atkTimes
    body2505 = body2505 .. writeUInt32BE(0)                     -- lostHP
    body2505 = body2505 .. writeUInt32BE(0)                     -- gainHP
    body2505 = body2505 .. writeUInt32BE(100)                   -- remainHp
    body2505 = body2505 .. writeUInt32BE(100)                   -- maxHp
    body2505 = body2505 .. writeUInt32BE(0)                     -- state
    body2505 = body2505 .. writeUInt32BE(0)                     -- skillListCount
    body2505 = body2505 .. writeUInt32BE(0)                     -- isCrit
    body2505 = body2505 .. string.rep("\0", 20)                 -- status
    body2505 = body2505 .. string.rep("\0", 6)                  -- battleLv
    
    -- 敌人受击信息 (被击败)
    body2505 = body2505 .. writeUInt32BE(0)                     -- userID (敌人)
    body2505 = body2505 .. writeUInt32BE(0)                     -- skillID
    body2505 = body2505 .. writeUInt32BE(0)                     -- atkTimes
    body2505 = body2505 .. writeUInt32BE(50)                    -- lostHP (受到50伤害)
    body2505 = body2505 .. writeUInt32BE(0)                     -- gainHP
    body2505 = body2505 .. writeUInt32BE(0)                     -- remainHp (剩余0)
    body2505 = body2505 .. writeUInt32BE(50)                    -- maxHp
    body2505 = body2505 .. writeUInt32BE(0)                     -- state
    body2505 = body2505 .. writeUInt32BE(0)                     -- skillListCount
    body2505 = body2505 .. writeUInt32BE(0)                     -- isCrit
    body2505 = body2505 .. string.rep("\0", 20)                 -- status
    body2505 = body2505 .. string.rep("\0", 6)                  -- battleLv
    
    ctx.sendResponse(buildResponse(2505, ctx.userId, 0, body2505))
    
    -- 3. 发送 FIGHT_OVER (2506)
    -- FightOverInfo: reason(4) + winnerID(4) + twoTimes(4) + threeTimes(4) + 
    --               autoFightTimes(4) + energyTimes(4) + learnTimes(4)
    local body2506 = ""
    body2506 = body2506 .. writeUInt32BE(0)                     -- reason (0=正常结束)
    body2506 = body2506 .. writeUInt32BE(ctx.userId)            -- winnerID
    body2506 = body2506 .. writeUInt32BE(0)                     -- twoTimes
    body2506 = body2506 .. writeUInt32BE(0)                     -- threeTimes
    body2506 = body2506 .. writeUInt32BE(0)                     -- autoFightTimes
    body2506 = body2506 .. writeUInt32BE(0)                     -- energyTimes
    body2506 = body2506 .. writeUInt32BE(0)                     -- learnTimes
    
    ctx.sendResponse(buildResponse(2506, ctx.userId, 0, body2506))
    
    print(string.format("\27[32m[Handler] → USE_SKILL %d (full battle flow)\27[0m", skillId))
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
    
    print("\27[36m[Handlers] 特殊命令处理器已加载 (未激活)\27[0m")
end

-- 导出单独的处理函数供其他模块使用
SpecialHandlers.handleLoginIn = handleLoginIn
SpecialHandlers.handleEnterMapFull = handleEnterMapFull
SpecialHandlers.handlePeopleWalkFull = handlePeopleWalkFull
SpecialHandlers.handleChatFull = handleChatFull
SpecialHandlers.handleUseSkillFull = handleUseSkillFull

return SpecialHandlers
