-- 其他命令处理器
-- 包括: NONO信息、客户端上报等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local MiscHandlers = {}

-- CMD 9003: NONO_INFO (获取NONO信息)
local function handleNonoInfo(ctx)
    local body = writeUInt32BE(ctx.userId) ..
        writeUInt32BE(1) ..  -- NONO count
        writeUInt32BE(1) ..  -- NONO ID
        writeFixedString("NONO", 20) ..
        writeUInt32BE(1) ..  -- level
        writeUInt32BE(0) ..  -- exp
        string.rep("\0", 40)
    ctx.sendResponse(buildResponse(9003, ctx.userId, 0, body))
    print("\27[32m[Handler] → NONO_INFO response\27[0m")
    return true
end

-- CMD 50004: XIN_CHECK (客户端信息上报)
local function handleXinCheck(ctx)
    ctx.sendResponse(buildResponse(50004, ctx.userId, 0, ""))
    print("\27[32m[Handler] → XIN_CHECK response\27[0m")
    return true
end

-- CMD 50008: XIN_GET_QUADRUPLE_EXE_TIME (获取四倍经验时间)
local function handleXinGetQuadrupleExeTime(ctx)
    ctx.sendResponse(buildResponse(50008, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → XIN_GET_QUADRUPLE_EXE_TIME response\27[0m")
    return true
end

-- 注册所有处理器
function MiscHandlers.register(Handlers)
    Handlers.register(9003, handleNonoInfo)
    Handlers.register(50004, handleXinCheck)
    Handlers.register(50008, handleXinGetQuadrupleExeTime)
    print("\27[36m[Handlers] 其他命令处理器已注册\27[0m")
end

return MiscHandlers
