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
-- 请求格式: flag(4) + targetUserId(4) + encryptedData(32) + padding(8) + targetUserId(4) + x(4) + y(4)
-- 响应: 空响应表示成功，然后服务器主动发送 ENTER_MAP
local function handleRoomLogin(ctx)
    -- 解析请求
    local flag = 0
    local targetUserId = ctx.userId
    local x = 300
    local y = 300
    
    if #ctx.body >= 4 then
        flag = readUInt32BE(ctx.body, 1)
    end
    if #ctx.body >= 8 then
        targetUserId = readUInt32BE(ctx.body, 5)
    end
    -- 跳过加密数据和padding，读取坐标
    if #ctx.body >= 52 then
        x = readUInt32BE(ctx.body, 49)
    end
    if #ctx.body >= 56 then
        y = readUInt32BE(ctx.body, 53)
    end
    
    print(string.format("\27[36m[Handler] ROOM_LOGIN: flag=%d, target=%d, pos=(%d,%d)\27[0m", flag, targetUserId, x, y))
    
    -- 发送 ROOM_LOGIN 成功响应
    ctx.sendResponse(buildResponse(10001, ctx.userId, 0, ""))
    print("\27[32m[Handler] → ROOM_LOGIN response\27[0m")
    
    -- 更新用户位置到家园
    local user = ctx.getOrCreateUser(ctx.userId)
    user.mapId = 60  -- 家园地图ID
    user.mapType = 1  -- 家园地图类型
    user.x = x
    user.y = y
    ctx.saveUserDB()
    
    -- 构建并发送 ENTER_MAP 响应 (让客户端进入家园地图)
    local nickname = user.nick or user.nickname or user.username or ("赛尔" .. ctx.userId)
    local petId = user.currentPetId or 0
    local catchTime = user.catchId or 0
    
    local enterMapBody = ""
    enterMapBody = enterMapBody .. writeUInt32BE(ctx.userId)           -- userID (4)
    enterMapBody = enterMapBody .. writeFixedString(nickname, 16)      -- nick (16)
    enterMapBody = enterMapBody .. writeUInt32BE(0xFFFFFF)             -- color (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- texture (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- vip flags (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- vipStage (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- actionType (4)
    enterMapBody = enterMapBody .. writeUInt32BE(x)                    -- pos.x (4)
    enterMapBody = enterMapBody .. writeUInt32BE(y)                    -- pos.y (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- action (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- direction (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- changeShape (4)
    enterMapBody = enterMapBody .. writeUInt32BE(catchTime)            -- spiritTime (4)
    enterMapBody = enterMapBody .. writeUInt32BE(petId)                -- spiritID (4)
    enterMapBody = enterMapBody .. writeUInt32BE(31)                   -- petDV (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- petShiny (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- petSkin (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- achievementsId (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- petRide (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- padding (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- fightFlag (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- teacherID (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- studentID (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- nonoState (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- nonoColor (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- superNono (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- playerForm (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- transTime (4)
    -- TeamInfo
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- teamInfo.id (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- teamInfo.coreCount (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- teamInfo.isShow (4)
    enterMapBody = enterMapBody .. writeUInt16BE(0)                    -- teamInfo.logoBg (2)
    enterMapBody = enterMapBody .. writeUInt16BE(0)                    -- teamInfo.logoIcon (2)
    enterMapBody = enterMapBody .. writeUInt16BE(0)                    -- teamInfo.logoColor (2)
    enterMapBody = enterMapBody .. writeUInt16BE(0)                    -- teamInfo.txtColor (2)
    enterMapBody = enterMapBody .. writeFixedString("", 4)             -- teamInfo.logoWord (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                    -- clothCount (4)
    
    ctx.sendResponse(buildResponse(2001, ctx.userId, 0, enterMapBody))
    print(string.format("\27[32m[Handler] → ENTER_MAP (家园地图 60) at (%d,%d)\27[0m", x, y))
    
    return true
end

-- CMD 10002: GET_ROOM_ADDRES (获取房间地址)
-- 请求: targetUserId(4)
-- 响应: targetUserId(4) + 加密数据(32 bytes) + 端口相关(6 bytes)
-- 官服响应格式: userID(4) + encryptedData(32) + portData(6)
local function handleGetRoomAddress(ctx)
    local targetUserId = ctx.userId
    if #ctx.body >= 4 then
        targetUserId = readUInt32BE(ctx.body, 1)
    end
    
    -- 构建响应 (模拟官服格式)
    local body = writeUInt32BE(targetUserId)           -- targetUserId (4)
    -- 加密数据 (32 bytes) - 官服返回的是加密的房间服务器信息
    -- 本地服务器不需要真正的加密，填充占位数据
    body = body .. string.rep("\0", 32)
    -- 端口数据 (6 bytes)
    body = body .. string.rep("\0", 6)
    
    ctx.sendResponse(buildResponse(10002, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → GET_ROOM_ADDRES response (target=%d)\27[0m", targetUserId))
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
-- 响应格式: userID(4) + roomID(4) + count(4) + [FitmentInfo]...
-- FitmentInfo: id(4) + x(4) + y(4) + dir(4) + status(4)
local function handleFitmentUsering(ctx)
    -- 从请求中读取目标用户ID (可能是访问别人的家)
    local targetUserId = ctx.userId
    if #ctx.body >= 4 then
        targetUserId = readUInt32BE(ctx.body, 1)
    end
    
    -- 房间ID = 用户ID (每个用户有自己的房间)
    local roomId = targetUserId
    
    -- 获取用户的家具数据
    local user = ctx.getOrCreateUser(targetUserId)
    local fitments = user.fitments or {}
    
    -- 构建响应
    local body = writeUInt32BE(targetUserId) ..  -- userID
                 writeUInt32BE(roomId)           -- roomID
    
    -- 如果没有家具，添加默认房间样式 (500001)
    if #fitments == 0 then
        -- 添加默认房间样式
        body = body .. writeUInt32BE(1)          -- count = 1
        body = body .. writeUInt32BE(500001)     -- id (默认房间样式)
        body = body .. writeUInt32BE(0)          -- x
        body = body .. writeUInt32BE(0)          -- y
        body = body .. writeUInt32BE(0)          -- dir
        body = body .. writeUInt32BE(0)          -- status
    else
        body = body .. writeUInt32BE(#fitments)  -- count
        for _, fitment in ipairs(fitments) do
            body = body .. writeUInt32BE(fitment.id or 0)
            body = body .. writeUInt32BE(fitment.x or 0)
            body = body .. writeUInt32BE(fitment.y or 0)
            body = body .. writeUInt32BE(fitment.dir or 0)
            body = body .. writeUInt32BE(fitment.status or 0)
        end
    end
    
    ctx.sendResponse(buildResponse(10006, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → FITMENT_USERING response (user=%d, room=%d)\27[0m", targetUserId, roomId))
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
