-- 系统相关命令处理器
-- 包括: 登录、时间、服务器列表等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse
local OnlineTracker = require('./online_tracker')

local SystemHandlers = {}

-- CMD 105: COMMEND_ONLINE (获取服务器列表)
-- 响应结构: maxOnlineID(4) + isVIP(4) + onlineCnt(4) + [ServerInfo]...
-- ServerInfo: onlineID(4) + userCnt(4) + ip(16) + port(2) + friends(4) = 30 bytes
local function handleCommendOnline(ctx)
    -- 获取服务器列表配置
    local serverList = {}
    for i = 1, 29 do
        table.insert(serverList, {
            id = i,
            userCnt = math.random(10, 60),
            ip = "127.0.0.1",
            port = 5000,  -- 统一游戏服务器端口
            friends = 0
        })
    end
    
    local maxOnlineID = #serverList
    local isVIP = 0
    local onlineCnt = #serverList
    
    local body = writeUInt32BE(maxOnlineID) ..
                 writeUInt32BE(isVIP) ..
                 writeUInt32BE(onlineCnt)
    
    for _, server in ipairs(serverList) do
        body = body ..
            writeUInt32BE(server.id) ..
            writeUInt32BE(server.userCnt) ..
            writeFixedString(server.ip, 16) ..
            writeUInt16BE(server.port) ..
            writeUInt32BE(server.friends)
    end
    
    ctx.sendResponse(buildResponse(105, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → COMMEND_ONLINE response (%d servers)\27[0m", onlineCnt))
    return true
end

-- CMD 106: RANGE_ONLINE (获取指定范围服务器)
-- 请求: startId(4) + endId(4)
-- 响应: count(4) + [ServerInfo]...
local function handleRangeOnline(ctx)
    local startId = 1
    local endId = 29
    
    if #ctx.body >= 8 then
        startId = readUInt32BE(ctx.body, 1)
        endId = readUInt32BE(ctx.body, 5)
    end
    
    local servers = {}
    for i = startId, math.min(endId, 29) do
        table.insert(servers, {
            id = i,
            userCnt = math.random(10, 60),
            ip = "127.0.0.1",
            port = 5000,
            friends = 0
        })
    end
    
    local body = writeUInt32BE(#servers)
    
    for _, server in ipairs(servers) do
        body = body ..
            writeUInt32BE(server.id) ..
            writeUInt32BE(server.userCnt) ..
            writeFixedString(server.ip, 16) ..
            writeUInt16BE(server.port) ..
            writeUInt32BE(server.friends)
    end
    
    ctx.sendResponse(buildResponse(106, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → RANGE_ONLINE response (%d-%d, %d servers)\27[0m", 
        startId, endId, #servers))
    return true
end

-- CMD 1001: LOGIN_IN (登录游戏服务器)
-- 这是最核心的命令，需要返回完整的用户信息
-- 响应由 SeerLoginResponse 模块生成
local function handleLoginIn(ctx)
    -- 从 body 中提取 session (如果有)
    local session = ""
    if #ctx.body >= 16 then
        session = ctx.body:sub(1, 16)
    end
    
    -- 获取完整用户数据
    local user = {}
    if ctx.gameServer and ctx.gameServer.userdb then
        local db = ctx.gameServer.userdb:new()
        
        -- 1. 账号数据
        local account = db:findByUserId(ctx.userId)
        if account then
            for k, v in pairs(account) do user[k] = v end
        end
        
        -- 2. 游戏数据
        local gameData = db:getOrCreateGameData(ctx.userId)
        if gameData then
            for k, v in pairs(gameData) do user[k] = v end
        end
    else
        -- 如果没有数据库，使用 getOrCreateUser
        user = ctx.getOrCreateUser(ctx.userId)
    end
    
    -- 确保基本字段存在
    user.userid = ctx.userId
    user.nick = user.nick or user.nickname or ("Seer" .. ctx.userId)
    user.coins = user.coins or 99999
    user.mapID = user.mapID or 1
    user.energy = user.energy or 100000
    
    -- 生成登录响应
    local SeerLoginResponse = require('../gameserver/seer_login_response')
    local responseBody, keySeed = SeerLoginResponse.makeLoginResponse(user)
    
    -- 更新密钥（如果支持）
    if ctx.gameServer and ctx.gameServer.cryptoMap and ctx.clientData then
        local crypto = ctx.gameServer.cryptoMap[ctx.clientData]
        if crypto then
            crypto:setKey(keySeed)
            print(string.format("\27[32m[Handler] 密钥已更新: userId=%d, keySeed=%d\27[0m", ctx.userId, keySeed))
        end
    end
    
    ctx.sendResponse(buildResponse(1001, ctx.userId, 0, responseBody))
    print(string.format("\27[32m[Handler] → LOGIN_IN response (user=%d)\27[0m", ctx.userId))
    
    -- 如果用户已经是超能NONO，发送 VIP_CO (8006) 强制更新客户端状态
    -- 这是必须的，因为客户端依赖 VIP_CO 来刷新 MainManager.actorInfo.superNono
    local nono = user.nono or {}
    if nono.superNono and nono.superNono > 0 then
        local vipBody = ""
        vipBody = vipBody .. writeUInt32BE(ctx.userId)                -- userId
        vipBody = vipBody .. writeUInt32BE(2)                         -- vipFlag=2 (超能NONO)
        vipBody = vipBody .. writeUInt32BE(nono.autoCharge or 0)      -- autoCharge
        local endTime = nono.vipEndTime
        if not endTime or endTime == 0 then
            endTime = 0x7FFFFFFF
        end
        vipBody = vipBody .. writeUInt32BE(endTime)      -- vipEndTime
        ctx.sendResponse(buildResponse(8006, ctx.userId, 0, vipBody))
        print(string.format("\27[35m[Handler] → VIP_CO 发送超能NONO状态 (endTime=%d)\27[0m", endTime))
    end
    
    -- 标记已登录并启动心跳（如果支持）
    if ctx.clientData then
        ctx.clientData.loggedIn = true
        if ctx.gameServer and ctx.gameServer.startHeartbeat then
            ctx.gameServer:startHeartbeat(ctx.clientData, ctx.userId)
        end
    end
    
    return true
end

-- CMD 1002: SYSTEM_TIME (系统时间)
-- SystemTimeInfo: timestamp(4) + num(4)
local function handleSystemTime(ctx)
    local timestamp = os.time()
    local body = writeUInt32BE(timestamp) .. writeUInt32BE(0)
    ctx.sendResponse(buildResponse(1002, ctx.userId, 0, body))
    -- 不打印日志，因为这个命令太频繁
    return true
end

-- CMD 1004: MAP_HOT (地图热度/热门地图列表)
-- MapHotInfo: count(4) + [mapId(4) + hotValue(4)]...
-- 地图列表与官服一致 (29个地图，固定顺序)
-- 在线人数从 OnlineTracker 实时获取
local function handleMapHot(ctx)
    -- 官服地图列表 (29个地图，固定顺序)
    local officialMaps = {
        1, 4, 5, 325, 6, 7, 8, 328, 9, 10,
        333, 15, 17, 338, 19, 20, 25, 30,
        101, 102, 103, 40, 107, 47, 51, 54, 57, 314, 60
    }
    
    -- 获取各地图的实时在线人数
    local mapOnlineCounts = {}
    local mapCounts = OnlineTracker.getAllMapCounts()
    for _, data in ipairs(mapCounts) do
        mapOnlineCounts[data.mapId] = data.count
    end
    
    -- 构建响应 (按官服顺序)
    local body = writeUInt32BE(#officialMaps)  -- count = 29
    for _, mapId in ipairs(officialMaps) do
        local onlineCount = mapOnlineCounts[mapId] or 0  -- 实时在线人数，默认0
        body = body .. writeUInt32BE(mapId)
        body = body .. writeUInt32BE(onlineCount)
    end
    
    ctx.sendResponse(buildResponse(1004, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → MAP_HOT response (%d maps, %d online)\27[0m", 
        #officialMaps, OnlineTracker.getOnlineCount()))
    return true
end

-- CMD 1005: GET_IMAGE_ADDRESS (获取图片地址)
-- GetImgAddrInfo: ip(16) + port(2) + session(16)
local function handleGetImageAddress(ctx)
    local ip = "127.0.0.1"
    local ipBytes = writeFixedString(ip, 16)
    local body = ipBytes ..
        string.char(0, 80) ..  -- port = 80 (big-endian)
        string.rep("\0", 16)   -- session (16字节)
    ctx.sendResponse(buildResponse(1005, ctx.userId, 0, body))
    print("\27[32m[Handler] → GET_IMAGE_ADDRESS response\27[0m")
    return true
end

-- CMD 1102: MONEY_BUY_PRODUCT (金币购买商品)
-- MoneyBuyProductInfo: unknown(4) + payMoney(4) + money(4)
local function handleMoneyBuyProduct(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local money = (user.money or 10000) * 100  -- 转换为分
    local body = writeUInt32BE(0) ..       -- unknown
                writeUInt32BE(0) ..        -- payMoney (花费0)
                writeUInt32BE(money)       -- 剩余金币
    ctx.sendResponse(buildResponse(1102, ctx.userId, 0, body))
    print("\27[32m[Handler] → MONEY_BUY_PRODUCT response\27[0m")
    return true
end

-- CMD 1104: GOLD_BUY_PRODUCT (钻石购买商品)
-- GoldBuyProductInfo: unknown(4) + payGold(4) + gold(4)
local function handleGoldBuyProduct(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local gold = (user.gold or 0) * 100  -- 转换为分
    local body = writeUInt32BE(0) ..       -- unknown
                writeUInt32BE(0) ..        -- payGold (花费0)
                writeUInt32BE(gold)        -- 剩余钻石
    ctx.sendResponse(buildResponse(1104, ctx.userId, 0, body))
    print("\27[32m[Handler] → GOLD_BUY_PRODUCT response\27[0m")
    return true
end

-- CMD 1106: GOLD_ONLINE_CHECK_REMAIN (检查金币余额)
local function handleGoldOnlineCheckRemain(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local body = writeUInt32BE(user.gold or 0)
    ctx.sendResponse(buildResponse(1106, ctx.userId, 0, body))
    print("\27[32m[Handler] → GOLD_ONLINE_CHECK_REMAIN response\27[0m")
    return true
end

-- 注册所有处理器
function SystemHandlers.register(Handlers)
    Handlers.register(105, handleCommendOnline)
    Handlers.register(106, handleRangeOnline)
    Handlers.register(1001, handleLoginIn)
    Handlers.register(1002, handleSystemTime)
    Handlers.register(1004, handleMapHot)
    Handlers.register(1005, handleGetImageAddress)
    Handlers.register(1102, handleMoneyBuyProduct)
    Handlers.register(1104, handleGoldBuyProduct)
    Handlers.register(1106, handleGoldOnlineCheckRemain)
    print("\27[36m[Handlers] 系统命令处理器已注册\27[0m")
end

return SystemHandlers
