-- 交换/交易系统命令处理器
-- 包括: 服装交换、精灵交换、矿石交换等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local ExchangeHandlers = {}

-- CMD 2901: EXCHANGE_CLOTH_COMPLETE (服装交换完成)
local function handleExchangeClothComplete(ctx)
    ctx.sendResponse(buildResponse(2901, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → EXCHANGE_CLOTH_COMPLETE response\27[0m")
    return true
end

-- CMD 2902: EXCHANGE_PET_COMPLETE (精灵交换完成)
local function handleExchangePetComplete(ctx)
    ctx.sendResponse(buildResponse(2902, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → EXCHANGE_PET_COMPLETE response\27[0m")
    return true
end

-- CMD 2251: EXCHANGE_ORE (矿石交换)
-- ExchangeOreInfo
local function handleExchangeOre(ctx)
    local body = writeUInt32BE(0) ..      -- ret
                writeUInt32BE(0)          -- count
    ctx.sendResponse(buildResponse(2251, ctx.userId, 0, body))
    print("\27[32m[Handler] → EXCHANGE_ORE response\27[0m")
    return true
end

-- CMD 2065: EXCHANGE_NEXYEAR (新年交换)
local function handleExchangeNewYear(ctx)
    ctx.sendResponse(buildResponse(2065, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → EXCHANGE_NEXYEAR response\27[0m")
    return true
end

-- CMD 2701: TALK_COUNT (对话计数)
-- MiningCountInfo
local function handleTalkCount(ctx)
    local body = writeUInt32BE(0) ..      -- ret
                writeUInt32BE(0)          -- count
    ctx.sendResponse(buildResponse(2701, ctx.userId, 0, body))
    print("\27[32m[Handler] → TALK_COUNT response\27[0m")
    return true
end

-- CMD 2702: TALK_CATE (对话分类)
-- DayTalkInfo
local function handleTalkCate(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(2702, ctx.userId, 0, body))
    print("\27[32m[Handler] → TALK_CATE response\27[0m")
    return true
end

-- 注册所有处理器
function ExchangeHandlers.register(Handlers)
    Handlers.register(2901, handleExchangeClothComplete)
    Handlers.register(2902, handleExchangePetComplete)
    Handlers.register(2251, handleExchangeOre)
    Handlers.register(2065, handleExchangeNewYear)
    Handlers.register(2701, handleTalkCount)
    Handlers.register(2702, handleTalkCate)
    print("\27[36m[Handlers] 交换命令处理器已注册\27[0m")
end

return ExchangeHandlers
