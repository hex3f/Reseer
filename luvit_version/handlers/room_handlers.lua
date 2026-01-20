-- 房间系统命令处理器
-- 包括: 房间登录、家具购买、装饰等

local BinaryWriter = require('utils/binary_writer')
local BinaryReader = require('utils/binary_reader')
local ResponseBuilder = require('utils/response_builder')

local RoomHandlers = {}

-- CMD 10001: ROOM_LOGIN (房间登录)
-- 请求格式（根据客户端代码）:
--   session(24 bytes) + catchTime(4) + flag(4) + targetUserId(4) + x(4) + y(4) = 44 bytes
-- 响应: UserInfo (与 ENTER_MAP 相同的格式)
-- 注意：由于房间服务器已合并，ROOM_LOGIN 直接完成房间进入，不需要额外的 ENTER_MAP
-- CMD 10001: ROOM_LOGIN (房间登录)
local function handleRoomLogin(ctx)
    -- 解析请求
    local reader = BinaryReader.new(ctx.body)
    local session = reader:readBytes(24)
    local catchTime = reader:readUInt32BE()
    local flag = reader:readUInt32BE()
    local targetUserId = ctx.userId
    
    if reader:getRemaining() ~= "" then
        targetUserId = reader:readUInt32BE()
    end
    
    local x = 300
    local y = 300
    if reader:getRemaining() ~= "" then
        x = reader:readUInt32BE()
        y = reader:readUInt32BE()
    end
    
    if x == 0 and y == 0 then
        x = 300
        y = 300
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
    local nonoState = 0
    if (nono.hasNono and nono.hasNono > 0) or (nono.flag and nono.flag > 0) then
        -- state=3 (0b11): Bit0=HasNoNo, Bit1=Show/Follow
        nonoState = 3
    end
    local nonoColor = nono.color or 0xFFFFFF
    local superNono = (nono.superNono and nono.superNono > 0) and 1 or 0
    
    print(string.format("\27[33m[NONO] hasNono=%d, flag=%d, state=%d, color=0x%X, superNono=%d\27[0m", 
        nono.hasNono or 0, nono.flag or 0, nonoState, nonoColor, superNono))
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(os.time())                     -- sysTime (4)
    writer:writeUInt32BE(ctx.userId)                    -- userID (4)
    writer:writeStringFixed(nickname, 16)               -- nick (16)
    writer:writeUInt32BE(user.color or 0xFFFFFF)        -- color (4)
    writer:writeUInt32BE(user.texture or 0)             -- texture (4)
    local vipFlags = 0
    if user.vip then vipFlags = vipFlags + 1 end
    if user.viped then vipFlags = vipFlags + 2 end
    writer:writeUInt32BE(vipFlags)                      -- vipFlags (4)
    writer:writeUInt32BE(user.vipStage or 0)            -- vipStage (4)
    
    local actionType = (user.flyMode and user.flyMode > 0) and 1 or 0
    writer:writeUInt32BE(actionType)                             -- actionType (4)
    writer:writeUInt32BE(x)                             -- pos.x (4)
    writer:writeUInt32BE(y)                             -- pos.y (4)
    writer:writeUInt32BE(0)                             -- action (4)
    writer:writeUInt32BE(0)                             -- direction (4)
    writer:writeUInt32BE(0)                             -- changeShape (4)
    writer:writeUInt32BE(catchTime)                     -- spiritTime (4)
    writer:writeUInt32BE(petId)                         -- spiritID (4)
    writer:writeUInt32BE(petDV)                            -- petDV (4)
    writer:writeUInt32BE(0)                             -- petSkin (4)
    writer:writeUInt32BE(0)                             -- fightFlag (4)
    writer:writeUInt32BE(user.teacherID or 0)           -- teacherID (4)
    writer:writeUInt32BE(user.studentID or 0)           -- studentID (4)
    writer:writeUInt32BE(nonoState)                     -- nonoState (4)
    writer:writeUInt32BE(nonoColor)                     -- nonoColor (4)
    writer:writeUInt32BE(superNono)                     -- superNono (4)
    writer:writeUInt32BE(0)                             -- playerForm (4)
    writer:writeUInt32BE(0)                             -- transTime (4)
    
    local teamInfo = user.teamInfo or {}
    writer:writeUInt32BE(teamInfo.id or 0)              -- teamInfo.id (4)
    writer:writeUInt32BE(teamInfo.coreCount or 0)       -- teamInfo.coreCount (4)
    writer:writeUInt32BE(teamInfo.isShow or 0)          -- teamInfo.isShow (4)
    writer:writeUInt16BE(teamInfo.logoBg or 0)          -- teamInfo.logoBg (2)
    writer:writeUInt16BE(teamInfo.logoIcon or 0)        -- teamInfo.logoIcon (2)
    writer:writeUInt16BE(teamInfo.logoColor or 0)       -- teamInfo.logoColor (2)
    writer:writeUInt16BE(teamInfo.txtColor or 0)        -- teamInfo.txtColor (2)
    writer:writeStringFixed(teamInfo.logoWord or "", 4) -- teamInfo.logoWord (4)
    writer:writeUInt32BE(clothCount)                    -- clothCount (4)
    
    for _, cloth in ipairs(clothes) do
        local clothId = cloth
        local clothLevel = 0
        if type(cloth) == "table" then
            clothId = cloth.id or 0
            clothLevel = cloth.level or 0
        end
        writer:writeUInt32BE(clothId)
        writer:writeUInt32BE(clothLevel)
    end
    writer:writeUInt32BE(user.curTitle or 0)            -- curTitle (4)
    
    -- 发送 ROOM_LOGIN 响应（使用 CMD 2001 ENTER_MAP）
    ctx.sendResponse(ResponseBuilder.build(2001, ctx.userId, 0, writer:toString()))
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
-- CMD 10002: GET_ROOM_ADDRES (获取房间地址)
local function handleGetRoomAddress(ctx)
    local reader = BinaryReader.new(ctx.body)
    local targetUserId = ctx.userId
    if reader:getRemaining() ~= "" then
        targetUserId = reader:readUInt32BE()
    end
    
    -- 生成 session（24字节，可以为空）
    local session = string.rep("\0", 24)
    
    -- 动态获取服务器 IP 和 Port
    local serverIP = ctx.serverIP or (conf and conf.server_ip) or "127.0.0.1"
    local serverPort = ctx.serverPort or (conf and conf.gameserver_port) or 5000
    
    if ctx.connectedIP then serverIP = ctx.connectedIP end
    if ctx.connectedPort then serverPort = ctx.connectedPort end
    
    local ipParts = {}
    for part in string.gmatch(serverIP, "(%d+)") do
        table.insert(ipParts, tonumber(part))
    end
    
    local writer = BinaryWriter.new()
    writer:writeBytes(session)
    if #ipParts == 4 then
        writer:writeUInt8(ipParts[1])
        writer:writeUInt8(ipParts[2])
        writer:writeUInt8(ipParts[3])
        writer:writeUInt8(ipParts[4])
    else
        writer:writeUInt32BE(0x7F000001) -- 127.0.0.1
    end
    writer:writeUInt16BE(serverPort)
    
    ctx.sendResponse(ResponseBuilder.build(10002, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → GET_ROOM_ADDRES response (target=%d, ip=%s:%d, isIlk=true)\27[0m", 
        targetUserId, serverIP, serverPort))
    return true
end

-- CMD 10003: LEAVE_ROOM (离开房间)
local function handleLeaveRoom(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    if not user.lastMapId or user.lastMapId == 0 then
        user.lastMapId = 1
    end
    ctx.sendResponse(ResponseBuilder.build(10003, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → LEAVE_ROOM response\27[0m"))
    return true
end

-- CMD 10004: BUY_FITMENT (购买家具)
local function handleBuyFitment(ctx)
    local reader = BinaryReader.new(ctx.body)
    local itemId = reader:readUInt32BE()
    local count = reader:readUInt32BE()
    
    if count <= 0 then count = 1 end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    
    -- TODO: 从物品配置中获取价格，暂时使用固定价格
    local price = 100 * count
    local currentCoins = user.coins or 10000
    
    -- 扣除赛尔豆
    if currentCoins >= price then
        user.coins = currentCoins - price
    else
        -- 余额不足也允许购买（测试用）
        user.coins = currentCoins
    end
    
    -- 添加家具到背包 (items 表)
    if not user.items then user.items = {} end
    local itemKey = tostring(itemId)
    if not user.items[itemKey] then
        user.items[itemKey] = { count = 0 }
    end
    user.items[itemKey].count = (user.items[itemKey].count or 0) + count
    
    ctx.saveUserDB()
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(user.coins)
    writer:writeUInt32BE(itemId)
    writer:writeUInt32BE(count)
    
    ctx.sendResponse(ResponseBuilder.build(10004, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → BUY_FITMENT itemId=%d count=%d coins=%d\27[0m", 
        itemId, count, user.coins))
    return true
end

-- CMD 10005: BETRAY_FITMENT (出售家具)
local function handleBetrayFitment(ctx)
    local reader = BinaryReader.new(ctx.body)
    local itemId = reader:readUInt32BE()
    local count = reader:readUInt32BE()
    
    if count <= 0 then count = 1 end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    
    -- 从背包中移除家具
    if user.items then
        local itemKey = tostring(itemId)
        if user.items[itemKey] then
            local current = user.items[itemKey].count or 0
            local toRemove = math.min(count, current)
            user.items[itemKey].count = current - toRemove
            if user.items[itemKey].count <= 0 then
                user.items[itemKey] = nil
            end
        end
    end
    
    local sellPrice = 50 * count
    user.coins = (user.coins or 0) + sellPrice
    
    ctx.saveUserDB()
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(user.coins)
    writer:writeUInt32BE(itemId)
    writer:writeUInt32BE(count)
    
    ctx.sendResponse(ResponseBuilder.build(10005, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → BETRAY_FITMENT itemId=%d count=%d coins=%d\27[0m", 
        itemId, count, user.coins))
    return true
end

-- CMD 10006: FITMENT_USERING (正在使用的家具)
local function handleFitmentUsering(ctx)
    local reader = BinaryReader.new(ctx.body)
    local targetUserId = ctx.userId
    if reader:getRemaining() ~= "" then
        targetUserId = reader:readUInt32BE()
    end
    
    local user = ctx.getOrCreateUser(targetUserId)
    local fitments = user.fitments or {}
    local roomId = user.roomId or targetUserId
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(targetUserId)
    writer:writeUInt32BE(roomId)
    writer:writeUInt32BE(#fitments)
    
    for _, fitment in ipairs(fitments) do
        writer:writeUInt32BE(fitment.id or 0)
        writer:writeUInt32BE(fitment.x or 0)
        writer:writeUInt32BE(fitment.y or 0)
        writer:writeUInt32BE(fitment.dir or 0)
        writer:writeUInt32BE(fitment.status or 0)
    end
    
    ctx.sendResponse(ResponseBuilder.build(10006, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → FITMENT_USERING response (owner=%d, visitor=%d, count=%d)\27[0m", 
        targetUserId, ctx.userId, #fitments))
    return true
end

-- CMD 10007: FITMENT_ALL (所有家具)
local function handleFitmentAll(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local fitments = user.fitments or {}
    local items = user.items or {}
    local stats = {}
    
    -- 1. 统计已摆放的家具
    for _, f in ipairs(fitments) do
        local id = f.id or 0
        if id > 0 then
            if not stats[id] then stats[id] = {used=0, bag=0} end
            stats[id].used = stats[id].used + 1
        end
    end
    
    -- 2. 统计背包里的家具物品
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
        local allCount = data.used + data.bag
        table.insert(uniqueFitments, {id = id, usedCount = data.used, allCount = allCount})
    end
    
    table.sort(uniqueFitments, function(a, b) return a.id < b.id end)
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(#uniqueFitments)
    for _, f in ipairs(uniqueFitments) do
        writer:writeUInt32BE(f.id)
        writer:writeUInt32BE(f.usedCount)
        writer:writeUInt32BE(f.allCount)
    end
    
    ctx.sendResponse(ResponseBuilder.build(10007, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → FITMENT_ALL response (%d types)\27[0m", #uniqueFitments))
    return true
end

-- CMD 10008: SET_FITMENT (设置家具/保存家具布局)
local function handleSetFitment(ctx)
    local reader = BinaryReader.new(ctx.body)
    local roomId = reader:readUInt32BE()
    local count = reader:readUInt32BE()
    
    local newFitments = {}
    for i = 1, count do
        if reader:getRemaining() ~= "" then
            local fitment = {
                id = reader:readUInt32BE(),
                x = reader:readUInt32BE(),
                y = reader:readUInt32BE(),
                dir = reader:readUInt32BE(),
                status = reader:readUInt32BE()
            }
            table.insert(newFitments, fitment)
        else
            break
        end
    end
    
    -- 获取用户数据
    local user = ctx.getOrCreateUser(ctx.userId)
    local oldFitments = user.fitments or {}
    if not user.items then user.items = {} end
    
    -- 统计旧的已放置家具数量
    local oldPlacedCount = {}
    for _, f in ipairs(oldFitments) do
        local id = f.id
        oldPlacedCount[id] = (oldPlacedCount[id] or 0) + 1
    end
    
    -- 统计新的已放置家具数量
    local newPlacedCount = {}
    for _, f in ipairs(newFitments) do
        local id = f.id
        newPlacedCount[id] = (newPlacedCount[id] or 0) + 1
    end
    
    -- 计算变化并更新背包数量
    local allIds = {}
    for id, _ in pairs(oldPlacedCount) do allIds[id] = true end
    for id, _ in pairs(newPlacedCount) do allIds[id] = true end
    
    for id, _ in pairs(allIds) do
        local oldCount = oldPlacedCount[id] or 0
        local newCount = newPlacedCount[id] or 0
        local delta = newCount - oldCount
        
        if delta ~= 0 then
            local itemKey = tostring(id)
            if not user.items[itemKey] then
                user.items[itemKey] = { count = 0 }
            end
            user.items[itemKey].count = (user.items[itemKey].count or 0) - delta
            if user.items[itemKey].count < 0 then
                user.items[itemKey].count = 0
            end
            print(string.format("  [Sync] id=%d: placed %+d, bag now=%d", 
                id, delta, user.items[itemKey].count))
        end
    end
    
    user.fitments = newFitments
    user.roomId = roomId
    ctx.saveUserDB()
    
    ctx.sendResponse(ResponseBuilder.build(10008, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → SET_FITMENT response (saved %d fitments)\27[0m", #newFitments))
    return true
end

-- CMD 10009: ADD_ENERGY (增加能量)
local function handleAddEnergy(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- ret
    writer:writeUInt32BE(100) -- current energy
    ctx.sendResponse(ResponseBuilder.build(10009, ctx.userId, 0, writer:toString()))
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
