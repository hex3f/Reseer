-- 共享命令处理器
-- 游戏服务器和房间服务器都可以使用的处理器
-- 避免重复代码

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local SharedHandlers = {}

-- 已注册的处理器
local registeredHandlers = {}

-- 注册处理器
function SharedHandlers.register(cmdId, handler)
    registeredHandlers[cmdId] = handler
end

-- 获取处理器
function SharedHandlers.get(cmdId)
    return registeredHandlers[cmdId]
end

-- 获取所有已注册的命令ID
function SharedHandlers.getRegisteredCmds()
    local cmds = {}
    for cmdId, _ in pairs(registeredHandlers) do
        table.insert(cmds, cmdId)
    end
    return cmds
end

-- 检查是否有处理器
function SharedHandlers.has(cmdId)
    return registeredHandlers[cmdId] ~= nil
end

-- 执行处理器
-- ctx 包含: userId, body, sendResponse, getOrCreateUser, saveUser, userdb, broadcastToMap
function SharedHandlers.execute(cmdId, ctx)
    local handler = registeredHandlers[cmdId]
    if handler then
        return handler(ctx)
    end
    return false
end

-- ==================== 工具函数 ====================

-- NONO 默认数据 (基于官服)
local NONO_DEFAULTS = {
    flag = 1,               -- 标志位 (1=已开启)
    state = 1,              -- 状态位 (1=已激活)
    nick = "NONO",          -- 名字
    superNono = 0,          -- 超级诺诺 (0=普通, 1=超级)
    color = 0x00FFFFFF,     -- 颜色 (官服默认白色)
    power = 10000,          -- 体力 (客户端会除以1000, 显示10)
    mate = 10000,           -- 心情 (客户端会除以1000, 显示10)
    iq = 0,                 -- 智力
    ai = 0,                 -- AI
    birth = 0,              -- 出生时间 (会设为当前时间)
    chargeTime = 500,       -- 充电时间 (官服默认500)
    superEnergy = 0,        -- 超能能量
    superLevel = 0,         -- 超能等级
    superStage = 1,         -- 超能阶段 (1-5, 官服默认1)
    hp = 10000,             -- HP
    maxHp = 10000,          -- 最大HP
    isFollowing = false     -- 是否跟随
}

-- 获取或创建用户的NONO数据 (确保所有字段都存在)
local function getNonoData(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local needSave = false
    
    if not user.nono then
        user.nono = {}
        needSave = true
    end
    
    -- 确保所有字段都有值
    for key, defaultValue in pairs(NONO_DEFAULTS) do
        if user.nono[key] == nil then
            if key == "birth" then
                user.nono[key] = os.time()
            else
                user.nono[key] = defaultValue
            end
            needSave = true
        end
    end
    
    if needSave then
        ctx.saveUser(ctx.userId, user)
    end
    
    return user.nono
end

-- 保存NONO数据
local function saveNonoData(ctx, nonoData)
    local user = ctx.getOrCreateUser(ctx.userId)
    user.nono = nonoData
    ctx.saveUser(ctx.userId, user)
end

-- ==================== NONO 命令处理器 ====================

-- CMD 9003: NONO_INFO (获取NONO信息)
-- NonoInfo 结构 (86 bytes body):
-- userID(4) + flag(4) + state(4) + nick(16) + superNono(4) + color(4) + 
-- power(4) + mate(4) + iq(4) + ai(2) + birth(4) + chargeTime(4) + 
-- func(20) + superEnergy(4) + superLevel(4) + superStage(4)
local function handleNonoInfo(ctx)
    local nonoData = getNonoData(ctx)
    
    local body = ""
    body = body .. writeUInt32BE(ctx.userId)                        -- userID
    body = body .. writeUInt32BE(nonoData.flag or 1)                -- flag
    body = body .. writeUInt32BE(nonoData.state or 1)               -- state
    body = body .. writeFixedString(nonoData.nick or "NONO", 16)    -- nick
    body = body .. writeUInt32BE(nonoData.superNono or 0)           -- superNono
    body = body .. writeUInt32BE(nonoData.color or 0x00FFFFFF)      -- color
    body = body .. writeUInt32BE(nonoData.power or 10000)           -- power (客户端/1000)
    body = body .. writeUInt32BE(nonoData.mate or 10000)            -- mate (客户端/1000)
    body = body .. writeUInt32BE(nonoData.iq or 0)                  -- iq
    body = body .. writeUInt16BE(nonoData.ai or 0)                  -- ai
    body = body .. writeUInt32BE(nonoData.birth or os.time())       -- birth
    body = body .. writeUInt32BE(nonoData.chargeTime or 500)        -- chargeTime
    body = body .. string.rep("\xFF", 20)                           -- func (所有功能开启)
    body = body .. writeUInt32BE(nonoData.superEnergy or 0)         -- superEnergy
    body = body .. writeUInt32BE(nonoData.superLevel or 0)          -- superLevel
    body = body .. writeUInt32BE(nonoData.superStage or 1)          -- superStage
    
    ctx.sendResponse(buildResponse(9003, ctx.userId, 0, body))
    return true
end

-- CMD 9016: NONO_CHARGE (NONO充电)
local function handleNonoCharge(ctx)
    local nonoData = getNonoData(ctx)
    nonoData.superEnergy = math.min(99999, (nonoData.superEnergy or 0) + 1000)
    nonoData.chargeTime = os.time()
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9016, ctx.userId, 0, ""))
    return true
end

-- CMD 9019: NONO_FOLLOW_OR_HOOM (NONO跟随/回家)
local function handleNonoFollowOrHoom(ctx)
    local action = 0
    if #ctx.body >= 4 then
        action = readUInt32BE(ctx.body, 1)
    end
    
    local nonoData = getNonoData(ctx)
    nonoData.isFollowing = (action == 1)
    saveNonoData(ctx, nonoData)
    
    local body = ""
    body = body .. writeUInt32BE(ctx.userId)
    body = body .. writeUInt32BE(0)  -- flag
    
    if action == 1 then
        -- 跟随
        body = body .. writeUInt32BE(1)  -- state
        body = body .. writeFixedString(nonoData.nick or "NONO", 16)
        body = body .. writeUInt32BE(0)
        body = body .. writeUInt32BE(0)
        body = body .. writeUInt32BE(0)
        body = body .. writeUInt32BE(nonoData.color or 0x00FFFFFF)
        body = body .. writeUInt32BE(nonoData.hp or 10000)
    else
        -- 回家
        body = body .. writeUInt32BE(0)  -- state
    end
    
    ctx.sendResponse(buildResponse(9019, ctx.userId, 0, body))
    
    -- 广播给同地图其他玩家
    if ctx.broadcastToMap then
        ctx.broadcastToMap(buildResponse(9019, ctx.userId, 0, body), ctx.userId)
    end
    
    return true
end

-- CMD 2306: PET_CURE (NONO给宠物治疗)
local function handlePetCure(ctx)
    local catchTime = 0
    if #ctx.body >= 4 then
        catchTime = readUInt32BE(ctx.body, 1)
    end
    
    -- 治疗精灵
    if ctx.userdb and catchTime > 0 then
        local db = ctx.userdb:new()
        local pet = db:getPetByCatchTime(ctx.userId, catchTime)
        if pet then
            pet.hp = pet.maxHp or 100
            db:updatePet(ctx.userId, catchTime, {hp = pet.hp})
        end
    end
    
    ctx.sendResponse(buildResponse(2306, ctx.userId, 0, ""))
    return true
end

-- ==================== 注册所有共享处理器 ====================

function SharedHandlers.init()
    -- NONO 相关
    SharedHandlers.register(9003, handleNonoInfo)
    SharedHandlers.register(9016, handleNonoCharge)
    SharedHandlers.register(9019, handleNonoFollowOrHoom)
    
    -- 精灵相关
    SharedHandlers.register(2306, handlePetCure)
    
    print("\27[36m[SharedHandlers] 共享处理器已初始化\27[0m")
end

-- 自动初始化
SharedHandlers.init()

return SharedHandlers
