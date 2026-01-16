-- 系统相关命令处理器
-- 包括: 登录、时间、服务器列表等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse
local OnlineTracker = require('./online_tracker')

local SystemHandlers = {}

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
-- 返回实时在线人数统计
local function handleMapHot(ctx)
    -- 获取所有有人的地图
    local mapCounts = OnlineTracker.getAllMapCounts()
    
    -- 预设的常用地图列表 (即使没人也显示)
    local defaultMaps = {
        1, 3, 4, 5, 6, 7, 8, 9, 10, 15, 17, 19, 20, 25, 30,
        40, 47, 51, 54, 57, 60,  -- 家园
        101, 102, 103, 107,      -- 克洛斯星系列
        314, 325, 328, 333, 338  -- 其他地图
    }
    
    -- 合并实时数据和预设地图
    local mapData = {}
    local seenMaps = {}
    
    -- 先添加有人的地图
    for _, data in ipairs(mapCounts) do
        table.insert(mapData, {data.mapId, data.count})
        seenMaps[data.mapId] = true
    end
    
    -- 再添加预设地图 (人数为0)
    for _, mapId in ipairs(defaultMaps) do
        if not seenMaps[mapId] then
            table.insert(mapData, {mapId, 0})
        end
    end
    
    -- 构建响应
    local body = writeUInt32BE(#mapData)  -- count
    for _, map in ipairs(mapData) do
        body = body .. writeUInt32BE(map[1])  -- mapId
        body = body .. writeUInt32BE(map[2])  -- hotValue (在线人数)
    end
    
    ctx.sendResponse(buildResponse(1004, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → MAP_HOT response (%d maps, %d online)\27[0m", 
        #mapData, OnlineTracker.getOnlineCount()))
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
    Handlers.register(1002, handleSystemTime)
    Handlers.register(1004, handleMapHot)
    Handlers.register(1005, handleGetImageAddress)
    Handlers.register(1102, handleMoneyBuyProduct)
    Handlers.register(1104, handleGoldBuyProduct)
    Handlers.register(1106, handleGoldOnlineCheckRemain)
    print("\27[36m[Handlers] 系统命令处理器已注册\27[0m")
end

return SystemHandlers
