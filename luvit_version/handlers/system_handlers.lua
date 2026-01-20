-- 系统相关命令处理器
-- 包括: 登录、时间、服务器列表等
-- Protocol Version: 2026-01-20 (Refactored using BinaryWriter)

local BinaryWriter = require('utils/binary_writer')
local BinaryReader = require('utils/binary_reader')
local ResponseBuilder = require('utils/response_builder')
local buildResponse = ResponseBuilder.build
local Utils = { buildResponse = buildResponse }
local OnlineTracker = require('handlers/online_tracker')

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
            port = 5000,
            friends = 0
        })
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(#serverList)            -- maxOnlineID
    writer:writeUInt32BE(0)                      -- isVIP
    writer:writeUInt32BE(#serverList)            -- onlineCnt
    
    for _, server in ipairs(serverList) do
        writer:writeUInt32BE(server.id)
        writer:writeUInt32BE(server.userCnt)
        writer:writeStringFixed(server.ip, 16)
        writer:writeUInt16BE(server.port)
        writer:writeUInt32BE(server.friends)
    end
    
    ctx.sendResponse(buildResponse(105, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → COMMEND_ONLINE response (%d servers)\27[0m", #serverList))
    return true
end

-- CMD 106: RANGE_ONLINE (获取指定范围服务器)
-- 请求: startId(4) + endId(4)
-- 响应: count(4) + [ServerInfo]...
local function handleRangeOnline(ctx)
    local startId = 1
    local endId = 29
    
    local reader = BinaryReader.new(ctx.body)
    if reader:getRemaining() ~= "" then
        startId = reader:readUInt32BE()
        endId = reader:readUInt32BE()
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
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(#servers)
    
    for _, server in ipairs(servers) do
        writer:writeUInt32BE(server.id)
        writer:writeUInt32BE(server.userCnt)
        writer:writeStringFixed(server.ip, 16)
        writer:writeUInt16BE(server.port)
        writer:writeUInt32BE(server.friends)
    end
    
    ctx.sendResponse(buildResponse(106, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → RANGE_ONLINE response (%d-%d, %d servers)\27[0m", 
        startId, endId, #servers))
    return true
end

-- CMD 1001: LOGIN_IN (登录游戏服务器)
local function handleLoginIn(ctx)
    local session = ""
    if ctx.body and #ctx.body >= 16 then
        session = ctx.body:sub(1, 16)
    end
    
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
        user = ctx.getOrCreateUser(ctx.userId)
    end
    
    -- 确保基本字段
    user.userid = ctx.userId
    user.nick = user.nick or user.nickname or ("Seer" .. ctx.userId)
    user.coins = user.coins or 2000
    user.mapID = user.mapID or 1
    
    -- 生成登录响应
    local SeerLoginResponse = require('game/seer_login_response')
    local responseBody, keySeed = SeerLoginResponse.makeLoginResponse(user)
    
    -- Update Crypto Key
    if ctx.gameServer and ctx.gameServer.cryptoMap and ctx.clientData then
        local crypto = ctx.gameServer.cryptoMap[ctx.clientData]
        if crypto then
            crypto:setKey(keySeed)
            print(string.format("\27[32m[Handler] 密钥已更新: userId=%d, keySeed=%d\27[0m", ctx.userId, keySeed))
        end
    end
    
    ctx.sendResponse(buildResponse(1001, ctx.userId, 0, responseBody))
    print(string.format("\27[32m[Handler] → LOGIN_IN response (user=%d)\27[0m", ctx.userId))
    
    -- VIP_CO Check
    local nono = user.nono or {}
    if nono.superNono and nono.superNono > 0 then
        local writer = BinaryWriter.new()
        writer:writeUInt32BE(ctx.userId)
        writer:writeUInt32BE(2) -- flag
        writer:writeUInt32BE(nono.autoCharge or 0)
        local endTime = nono.vipEndTime or 0
        if endTime == 0 then endTime = 0x7FFFFFFF end
        writer:writeUInt32BE(endTime)
        ctx.sendResponse(buildResponse(8006, ctx.userId, 0, writer:toString()))
        print(string.format("\27[35m[Handler] → VIP_CO 发送超能NONO状态 (endTime=%d)\27[0m", endTime))
    end
    
    -- Start Heartbeat
    if ctx.clientData then
        ctx.clientData.loggedIn = true
        if ctx.gameServer and ctx.gameServer.startHeartbeat then
            ctx.gameServer:startHeartbeat(ctx.clientData, ctx.userId)
        end
    end
    
    return true
end

-- CMD 1002: SYSTEM_TIME (系统时间)
local function handleSystemTime(ctx)
    local timestamp = os.time()
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(timestamp)
    writer:writeUInt32BE(0) -- num
    ctx.sendResponse(buildResponse(1002, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 1004: MAP_HOT (地图热度)
local function handleMapHot(ctx)
    local officialMaps = {
        1, 4, 5, 325, 6, 7, 8, 328, 9, 10,
        333, 15, 17, 338, 19, 20, 25, 30,
        101, 102, 103, 40, 107, 47, 51, 54, 57, 314, 60
    }
    
    local mapOnlineCounts = {}
    local mapCounts = OnlineTracker.getAllMapCounts()
    for _, data in ipairs(mapCounts) do
        mapOnlineCounts[data.mapId] = data.count
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(#officialMaps)
    for _, mapId in ipairs(officialMaps) do
        local onlineCount = mapOnlineCounts[mapId] or 0
        writer:writeUInt32BE(mapId)
        writer:writeUInt32BE(onlineCount)
    end
    
    ctx.sendResponse(buildResponse(1004, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → MAP_HOT response (%d maps, %d online)\27[0m", 
        #officialMaps, OnlineTracker.getOnlineCount()))
    return true
end

-- CMD 1005: GET_IMAGE_ADDRESS
local function handleGetImageAddress(ctx)
    local writer = BinaryWriter.new()
    writer:writeStringFixed("127.0.0.1", 16)
    writer:writeUInt16BE(80)           -- port
    writer:writeStringFixed("", 16)    -- session
    ctx.sendResponse(buildResponse(1005, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → GET_IMAGE_ADDRESS response\27[0m")
    return true
end

-- CMD 1102: MONEY_BUY_PRODUCT
local function handleMoneyBuyProduct(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local money = (user.money or 10000) * 100
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)      -- unknown
    writer:writeUInt32BE(0)      -- payMoney
    writer:writeUInt32BE(money)  -- remain
    ctx.sendResponse(buildResponse(1102, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 1104: GOLD_BUY_PRODUCT
local function handleGoldBuyProduct(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local gold = (user.gold or 0) * 100
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)      -- unknown
    writer:writeUInt32BE(0)      -- payGold
    writer:writeUInt32BE(gold)   -- remain
    ctx.sendResponse(buildResponse(1104, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 1106: GOLD_ONLINE_CHECK_REMAIN
local function handleGoldOnlineCheckRemain(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(user.gold or 0)
    ctx.sendResponse(buildResponse(1106, ctx.userId, 0, writer:toString()))
    return true
end

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
    print("\27[36m[Handlers] System Handlers Registered (v2.0 fixed)\27[0m")
end

return SystemHandlers
