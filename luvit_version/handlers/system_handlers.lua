-- 系统相关命令处理器
-- 包括: 登录、时间、服务器列表等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

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

-- CMD 1004: MAP_HOT (地图热度)
-- MapHotInfo: count(4) + [mapId(4) + hotValue(4)]...
local function handleMapHot(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(1004, ctx.userId, 0, body))
    print("\27[32m[Handler] → MAP_HOT response\27[0m")
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
