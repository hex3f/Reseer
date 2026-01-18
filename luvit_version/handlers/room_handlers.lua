-- 房间系统命令处理器
-- 包括: 房间登录、家具购买、装饰等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local RoomHandlers = {}

-- CMD 10001: ROOM_LOGIN (房间登录)
-- 请求格式（根据客户端代码）:
--   session(24 bytes) + catchTime(4) + flag(4) + targetUserId(4) + x(4) + y(4) = 44 bytes
-- 响应: 空响应表示成功
-- 注意：由于房间服务器已合并，客户端会通过 isIlk=true 检测到是同一连接
--       因此 ROOM_LOGIN 后，客户端会发送 ENTER_MAP 命令来真正进入地图
local function handleRoomLogin(ctx)
    -- 解析请求
    local session = ""
    local catchTime = 0
    local flag = 0
    local targetUserId = ctx.userId
    local x = 300
    local y = 300
    
    if #ctx.body >= 24 then
        session = ctx.body:sub(1, 24)
    end
    if #ctx.body >= 28 then
        catchTime = readUInt32BE(ctx.body, 25)
    end
    if #ctx.body >= 32 then
        flag = readUInt32BE(ctx.body, 29)
    end
    if #ctx.body >= 36 then
        targetUserId = readUInt32BE(ctx.body, 33)
    end
    if #ctx.body >= 40 then
        x = readUInt32BE(ctx.body, 37)
    end
    if #ctx.body >= 44 then
        y = readUInt32BE(ctx.body, 41)
    end
    
    print(string.format("\27[36m[Handler] ROOM_LOGIN: flag=%d, target=%d, catchTime=0x%08X, pos=(%d,%d)\27[0m", 
        flag, targetUserId, catchTime, x, y))
    
    -- 更新用户位置到家园（预设置，等待 ENTER_MAP 确认）
    local user = ctx.getOrCreateUser(ctx.userId)
    user.pendingMapId = targetUserId  -- 待进入的家园地图ID
    user.pendingMapType = 1           -- 家园地图类型
    user.pendingX = x
    user.pendingY = y
    
    -- 发送 ROOM_LOGIN 成功响应（空响应）
    -- 客户端收到后会发送 ENTER_MAP 命令
    ctx.sendResponse(buildResponse(10001, ctx.userId, 0, ""))
    print("\27[32m[Handler] → ROOM_LOGIN response (waiting for ENTER_MAP)\27[0m")
    
    return true
end

-- CMD 10002: GET_ROOM_ADDRES (获取房间地址)
-- 请求: targetUserId(4)
-- 响应格式（根据客户端代码）:
--   session(24 bytes) + ip(4 bytes) + port(2 bytes) = 30 bytes total
-- 注意：由于房间服务器已合并到游戏服务器，返回相同的地址
-- 客户端会检测到是同一服务器（isIlk=true），不会创建新连接
local function handleGetRoomAddress(ctx)
    local targetUserId = ctx.userId
    if #ctx.body >= 4 then
        targetUserId = readUInt32BE(ctx.body, 1)
    end
    
    -- 生成 session（24字节，可以为空）
    local session = string.rep("\0", 24)
    
    -- 游戏服务器 IP: 127.0.0.1 (0x7F000001)
    local ip = string.char(0x7F, 0x00, 0x00, 0x01)
    
    -- 游戏服务器端口: 5000 (大端序)
    local port = writeUInt16BE(5000)
    
    -- 构建响应: session(24) + ip(4) + port(2) = 30 bytes
    local body = session .. ip .. port
    
    ctx.sendResponse(buildResponse(10002, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → GET_ROOM_ADDRES response (target=%d, ip=127.0.0.1:5000, isIlk=true)\27[0m", 
        targetUserId))
    return true
end

-- CMD 10003: LEAVE_ROOM (离开房间)
local function handleLeaveRoom(ctx)
    ctx.sendResponse(buildResponse(10003, ctx.userId, 0, ""))
    print("\27[32m[Handler] → LEAVE_ROOM response\27[0m")
    return true
end

-- CMD 10004: BUY_FITMENT (购买家具)
local function handleBuyFitment(ctx)
    local itemId = 0
    if #ctx.body >= 4 then
        itemId = readUInt32BE(ctx.body, 1)
    end
    local body = writeUInt32BE(0) ..      -- ret (0=成功)
                writeUInt32BE(itemId)     -- itemId
    ctx.sendResponse(buildResponse(10004, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → BUY_FITMENT %d response\27[0m", itemId))
    return true
end

-- CMD 10005: BETRAY_FITMENT (出售家具)
local function handleBetrayFitment(ctx)
    local itemId = 0
    if #ctx.body >= 4 then
        itemId = readUInt32BE(ctx.body, 1)
    end
    local body = writeUInt32BE(0) ..      -- ret (0=成功)
                writeUInt32BE(itemId)     -- itemId
    ctx.sendResponse(buildResponse(10005, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → BETRAY_FITMENT %d response\27[0m", itemId))
    return true
end

-- CMD 10006: FITMENT_USERING (正在使用的家具)
-- 返回正在使用的家具列表
-- 官服响应格式: userID(4) + visitorId(4) + count(4) + [FitmentInfo]...
-- FitmentInfo: id(4) + x(4) + y(4) + dir(4) + status(4)
local function handleFitmentUsering(ctx)
    -- 从请求中读取目标用户ID (可能是访问别人的家)
    local targetUserId = ctx.userId
    if #ctx.body >= 4 then
        targetUserId = readUInt32BE(ctx.body, 1)
    end
    
    -- 获取用户的家具数据
    local user = ctx.getOrCreateUser(targetUserId)
    local fitments = user.fitments or {}
    
    -- 构建响应 (与官服格式一致)
    local body = writeUInt32BE(targetUserId) ..  -- userID (房主)
                 writeUInt32BE(ctx.userId) ..    -- visitorId (访问者，通常是自己)
                 writeUInt32BE(#fitments)        -- count
    
    -- 添加家具列表
    for _, fitment in ipairs(fitments) do
        body = body .. writeUInt32BE(fitment.id or 0)
        body = body .. writeUInt32BE(fitment.x or 0)
        body = body .. writeUInt32BE(fitment.y or 0)
        body = body .. writeUInt32BE(fitment.dir or 0)
        body = body .. writeUInt32BE(fitment.status or 0)
    end
    
    ctx.sendResponse(buildResponse(10006, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → FITMENT_USERING response (owner=%d, visitor=%d, count=%d)\27[0m", 
        targetUserId, ctx.userId, #fitments))
    return true
end

-- CMD 10007: FITMENT_ALL (所有家具)
-- FitmentInfo for 10007: id(4) + usedCount(4) + allCount(4)
local function handleFitmentAll(ctx)
    local body = writeUInt32BE(0)  -- count = 0 (没有家具)
    ctx.sendResponse(buildResponse(10007, ctx.userId, 0, body))
    print("\27[32m[Handler] → FITMENT_ALL response\27[0m")
    return true
end

-- CMD 10008: SET_FITMENT (设置家具)
-- FitmentInfo for 10008: id(4) + x(4) + y(4) + dir(4) + status(4)
local function handleSetFitment(ctx)
    ctx.sendResponse(buildResponse(10008, ctx.userId, 0, ""))
    print("\27[32m[Handler] → SET_FITMENT response\27[0m")
    return true
end

-- CMD 10009: ADD_ENERGY (增加能量)
local function handleAddEnergy(ctx)
    local body = writeUInt32BE(0) ..      -- ret
                writeUInt32BE(100)        -- 当前能量
    ctx.sendResponse(buildResponse(10009, ctx.userId, 0, body))
    print("\27[32m[Handler] → ADD_ENERGY response\27[0m")
    return true
end

-- 注册所有处理器
function RoomHandlers.register(Handlers)
    Handlers.register(10001, handleRoomLogin)
    Handlers.register(10002, handleGetRoomAddress)
    Handlers.register(10003, handleLeaveRoom)
    Handlers.register(10004, handleBuyFitment)
    Handlers.register(10005, handleBetrayFitment)
    Handlers.register(10006, handleFitmentUsering)
    Handlers.register(10007, handleFitmentAll)
    Handlers.register(10008, handleSetFitment)
    Handlers.register(10009, handleAddEnergy)
    print("\27[36m[Handlers] 房间命令处理器已注册\27[0m")
end

return RoomHandlers
