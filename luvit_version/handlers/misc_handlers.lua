-- 其他命令处理器
-- 包括: 客户端上报、交换系统等
-- 注意: NONO_INFO (9003) 在 nono_handlers.lua 中实现

local BinaryWriter = require('utils/binary_writer')
local ResponseBuilder = require('utils/response_builder')

local MiscHandlers = {}

-- CMD 50004: XIN_CHECK (客户端信息上报)
local function handleXinCheck(ctx)
    ctx.sendResponse(ResponseBuilder.build(50004, ctx.userId, 0, ""))
    print("\27[32m[Handler] → XIN_CHECK response\27[0m")
    return true
end

-- CMD 50008: XIN_GET_QUADRUPLE_EXE_TIME (获取四倍经验时间)
local function handleXinGetQuadrupleExeTime(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(50008, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → XIN_GET_QUADRUPLE_EXE_TIME response\27[0m")
    return true
end

-- CMD 70001: GET_EXCHANGE_INFO (获取交换/荣誉信息)
local function handleGetExchangeInfo(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local honorValue = user.honorValue or 0
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(honorValue)
    ctx.sendResponse(ResponseBuilder.build(70001, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → GET_EXCHANGE_INFO honor=%d\27[0m", honorValue))
    return true
end

-- 注册所有处理器
function MiscHandlers.register(Handlers)
    -- 注意: 9003 NONO_INFO 由 nono_handlers.lua 处理
    Handlers.register(50004, handleXinCheck)
    Handlers.register(50008, handleXinGetQuadrupleExeTime)
    Handlers.register(70001, handleGetExchangeInfo)
    print("\27[36m[Handlers] 其他命令处理器已注册\27[0m")
end

return MiscHandlers
