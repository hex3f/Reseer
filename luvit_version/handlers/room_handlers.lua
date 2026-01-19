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
-- 响应: UserInfo (与 ENTER_MAP 相同的格式)
-- 注意：由于房间服务器已合并，ROOM_LOGIN 直接完成房间进入，不需要额外的 ENTER_MAP
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
    
    -- 直接进入房间地图
    local user = ctx.getOrCreateUser(ctx.userId)
    -- 房间地图ID: 使用固定的房间地图 (500001-500010 等)
    -- 简化处理：所有玩家使用 500001 作为默认房间
    local mapId = 500001
    user.mapId = mapId
    user.mapType = 1  -- 房间地图类型
    user.x = x
    user.y = y
    ctx.saveUserDB()
    
    -- ROOM_LOGIN 响应：返回 UserInfo（与 ENTER_MAP 相同）
    -- 这样客户端就能正确进入房间
    local nickname = user.nick or user.nickname or user.username or ("赛尔" .. ctx.userId)
    local petId = user.currentPetId or 0
    local catchTime = user.catchId or 0
    -- 获取当前宠物的 DV 值
    local petDV = 31  -- 默认满值
    if user.pets and user.currentPetId then
        for _, pet in ipairs(user.pets) do
            if pet.id == user.currentPetId or pet.catchTime == user.catchId then
                petDV = pet.dv or pet.DV or 31
                break
            end
        end
    end
    local clothes = user.clothes or {}
    local clothCount = #clothes
    
    -- 读取 NONO 数据
    local nono = user.nono or {}
    -- NONO state: 0=不跟随, 1=跟随, 3=在房间但不跟随
    -- 在房间中，如果 NONO 存在，应该设置为 state=1 (跟随) 才会显示
    local nonoState = 0
    if (nono.hasNono and nono.hasNono > 0) or (nono.flag and nono.flag > 0) then
        -- state=3 (0b11): Bit0=HasNoNo, Bit1=Show/Follow
        -- 必须设置 Bit1 (Value 2) 才能让客户端正确显示 NoNo
        nonoState = 3
    end
    local nonoColor = nono.color or 0xFFFFFF
    -- superNono 应该是 0 或 1，不是 vipLevel
    local superNono = (nono.superNono and nono.superNono > 0) and 1 or 0
    
    print(string.format("\27[33m[NONO] hasNono=%d, flag=%d, state=%d, color=0x%X, superNono=%d\27[0m", 
        nono.hasNono or 0, nono.flag or 0, nonoState, nonoColor, superNono))
    
    local body = ""
    body = body .. writeUInt32BE(os.time())                     -- sysTime (4)
    body = body .. writeUInt32BE(ctx.userId)                    -- userID (4)
    body = body .. writeFixedString(nickname, 16)               -- nick (16)
    body = body .. writeUInt32BE(user.color or 0xFFFFFF)        -- color (4)
    body = body .. writeUInt32BE(user.texture or 0)             -- texture (4)
    local vipFlags = 0
    if user.vip then vipFlags = vipFlags + 1 end
    if user.viped then vipFlags = vipFlags + 2 end
    body = body .. writeUInt32BE(vipFlags)                      -- vipFlags (4)
    body = body .. writeUInt32BE(user.vipStage or 0)            -- vipStage (4)
    -- actionType: 飞行模式(flyMode>0)时为1，否则为0
    local actionType = (user.flyMode and user.flyMode > 0) and 1 or 0
    body = body .. writeUInt32BE(actionType)                             -- actionType (4)
    body = body .. writeUInt32BE(x)                             -- pos.x (4)
    body = body .. writeUInt32BE(y)                             -- pos.y (4)
    body = body .. writeUInt32BE(0)                             -- action (4)
    body = body .. writeUInt32BE(0)                             -- direction (4)
    body = body .. writeUInt32BE(0)                             -- changeShape (4)
    body = body .. writeUInt32BE(catchTime)                     -- spiritTime (4)
    body = body .. writeUInt32BE(petId)                         -- spiritID (4)
    body = body .. writeUInt32BE(petDV)                            -- petDV (4)
    body = body .. writeUInt32BE(0)                             -- petSkin (4)
    body = body .. writeUInt32BE(0)                             -- fightFlag (4)
    body = body .. writeUInt32BE(user.teacherID or 0)           -- teacherID (4)
    body = body .. writeUInt32BE(user.studentID or 0)           -- studentID (4)
    body = body .. writeUInt32BE(nonoState)                     -- nonoState (4)
    body = body .. writeUInt32BE(nonoColor)                     -- nonoColor (4)
    body = body .. writeUInt32BE(superNono)                     -- superNono (4)
    body = body .. writeUInt32BE(0)                             -- playerForm (4)
    body = body .. writeUInt32BE(0)                             -- transTime (4)
    local teamInfo = user.teamInfo or {}
    body = body .. writeUInt32BE(teamInfo.id or 0)              -- teamInfo.id (4)
    body = body .. writeUInt32BE(teamInfo.coreCount or 0)       -- teamInfo.coreCount (4)
    body = body .. writeUInt32BE(teamInfo.isShow or 0)          -- teamInfo.isShow (4)
    body = body .. writeUInt16BE(teamInfo.logoBg or 0)          -- teamInfo.logoBg (2)
    body = body .. writeUInt16BE(teamInfo.logoIcon or 0)        -- teamInfo.logoIcon (2)
    body = body .. writeUInt16BE(teamInfo.logoColor or 0)       -- teamInfo.logoColor (2)
    body = body .. writeUInt16BE(teamInfo.txtColor or 0)        -- teamInfo.txtColor (2)
    body = body .. writeFixedString(teamInfo.logoWord or "", 4) -- teamInfo.logoWord (4)
    body = body .. writeUInt32BE(clothCount)                    -- clothCount (4)
    
    for _, cloth in ipairs(clothes) do
        local clothId = cloth
        local clothLevel = 0
        if type(cloth) == "table" then
            clothId = cloth.id or 0
            clothLevel = cloth.level or 0
        end
        body = body .. writeUInt32BE(clothId)
        body = body .. writeUInt32BE(clothLevel)
    end
    body = body .. writeUInt32BE(user.curTitle or 0)            -- curTitle (4)
    
    -- 发送 ROOM_LOGIN 响应（使用 CMD 2001 ENTER_MAP）
    ctx.sendResponse(buildResponse(2001, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → ROOM_LOGIN response as ENTER_MAP (room %d at %d,%d)\27[0m", 
        mapId, x, y))
    
    return true
end

-- CMD 10002: GET_ROOM_ADDRES (获取房间地址)
-- 请求: targetUserId(4)
-- 响应格式（根据客户端代码）:
--   session(24 bytes) + ip(4 bytes) + port(2 bytes) = 30 bytes total
-- 注意：由于房间服务器已合并到游戏服务器，返回相同的地址
-- 客户端会检测到是同一服务器（isIlk=true），不会创建新连接
-- 
-- 重要修改：动态返回客户端当前连接的IP/Port，确保 isIlk=true，避免服务器跳转
local function handleGetRoomAddress(ctx)
    local targetUserId = ctx.userId
    if #ctx.body >= 4 then
        targetUserId = readUInt32BE(ctx.body, 1)
    end
    
    -- 生成 session（24字节，可以为空）
    local session = string.rep("\0", 24)
    
    -- 动态获取服务器 IP 和 Port
    -- 优先使用 ctx 中的连接信息，否则使用全局配置
    local serverIP = ctx.serverIP or (conf and conf.server_ip) or "127.0.0.1"
    local serverPort = ctx.serverPort or (conf and conf.gameserver_port) or 5000
    
    -- 如果 ctx 中有 roomSocket 的 IP/Port 信息（客户端当前连接的地址），使用它
    -- 这样可以确保返回的地址与客户端当前连接一致，isIlk=true
    if ctx.connectedIP then
        serverIP = ctx.connectedIP
    end
    if ctx.connectedPort then
        serverPort = ctx.connectedPort
    end
    
    -- 将 IP 转换为 4 字节格式 (大端序)
    local ip
    local ipParts = {}
    for part in string.gmatch(serverIP, "(%d+)") do
        table.insert(ipParts, tonumber(part))
    end
    if #ipParts == 4 then
        ip = string.char(ipParts[1], ipParts[2], ipParts[3], ipParts[4])
    else
        -- 默认 127.0.0.1
        ip = string.char(0x7F, 0x00, 0x00, 0x01)
    end
    
    -- 端口 (大端序)
    local port = writeUInt16BE(serverPort)
    
    -- 构建响应: session(24) + ip(4) + port(2) = 30 bytes
    local body = session .. ip .. port
    
    ctx.sendResponse(buildResponse(10002, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → GET_ROOM_ADDRES response (target=%d, ip=%s:%d, isIlk=true)\27[0m", 
        targetUserId, serverIP, serverPort))
    return true
end

-- CMD 10003: LEAVE_ROOM (离开房间)
-- 响应：返回空响应，客户端会自动处理离开逻辑
local function handleLeaveRoom(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    
    -- 更新用户位置到默认地图（如果需要）
    if not user.lastMapId or user.lastMapId == 0 then
        user.lastMapId = 1
    end
    
    ctx.sendResponse(buildResponse(10003, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → LEAVE_ROOM response\27[0m"))
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
    local user = ctx.getOrCreateUser(ctx.userId)
    local fitments = user.fitments or {}
    local items = user.items or {}
    
    -- 统计数表: id -> {used=0, bag=0}
    local stats = {}
    
    -- 1. 统计已摆放的家具 (usedCount)
    for _, f in ipairs(fitments) do
        local id = f.id or 0
        if id > 0 then
            if not stats[id] then stats[id] = {used=0, bag=0} end
            stats[id].used = stats[id].used + 1
        end
    end
    
    -- 2. 统计背包里的家具物品 (bagCount)
    -- 家具物品ID通常 >= 500000 (根据 task_handlers 和 game_config)
    for itemIdStr, itemData in pairs(items) do
        local id = tonumber(itemIdStr)
        if id and id >= 500000 then
            local count = itemData.count or 0
            if count > 0 then
                if not stats[id] then stats[id] = {used=0, bag=0} end
                stats[id].bag = count
            end
        end
    end
    
    -- 3. 转换为数组并构建响应
    local uniqueFitments = {}
    for id, data in pairs(stats) do
        -- allCount = usedCount + bagCount
        -- 官服逻辑: allCount 是总拥有数量，usedCount 是已摆放数量
        -- 背包里的数量 = allCount - usedCount
        local allCount = data.used + data.bag
        table.insert(uniqueFitments, {id = id, usedCount = data.used, allCount = allCount})
    end
    
    -- 排序 (可选，方便调试)
    table.sort(uniqueFitments, function(a, b) return a.id < b.id end)
    
    local body = writeUInt32BE(#uniqueFitments)
    for _, f in ipairs(uniqueFitments) do
        body = body .. writeUInt32BE(f.id)
        body = body .. writeUInt32BE(f.usedCount)   -- 已使用数量
        body = body .. writeUInt32BE(f.allCount)    -- 总数量
    end
    
    ctx.sendResponse(buildResponse(10007, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → FITMENT_ALL response (%d types)\27[0m", #uniqueFitments))
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
