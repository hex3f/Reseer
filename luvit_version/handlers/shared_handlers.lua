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

-- 获取或创建NONO数据
local function getNonoData(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    if not user.nono then
        user.nono = {
            flag = 0x00000001,
            state = 0x00000001,
            nick = "NONO",
            superNono = 1,
            color = 0x00FFFFFF,
            power = 80000,
            mate = 80000,
            iq = 100,
            ai = 100,
            birth = os.time(),
            chargeTime = 0,
            superEnergy = 10000,
            superLevel = 10,
            superStage = 3,
            hp = 10000,
            isFollowing = false
        }
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
local function handleNonoInfo(ctx)
    local nonoData = getNonoData(ctx)
    
    local body = ""
    body = body .. writeUInt32BE(ctx.userId)
    body = body .. writeUInt32BE(nonoData.flag or 1)
    body = body .. writeUInt32BE(nonoData.state or 1)
    body = body .. writeFixedString(nonoData.nick or "NONO", 16)
    body = body .. writeUInt32BE(nonoData.superNono or 1)
    body = body .. writeUInt32BE(nonoData.color or 0x00FFFFFF)
    body = body .. writeUInt32BE(nonoData.power or 80000)
    body = body .. writeUInt32BE(nonoData.mate or 80000)
    body = body .. writeUInt32BE(nonoData.iq or 100)
    body = body .. writeUInt16BE(nonoData.ai or 100)
    body = body .. writeUInt32BE(nonoData.birth or os.time())
    body = body .. writeUInt32BE(nonoData.chargeTime or 0)
    body = body .. string.rep("\xFF", 20)  -- func (所有功能开启)
    body = body .. writeUInt32BE(nonoData.superEnergy or 10000)
    body = body .. writeUInt32BE(nonoData.superLevel or 10)
    body = body .. writeUInt32BE(nonoData.superStage or 3)
    
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
