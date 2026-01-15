-- 工作/连接系统命令处理器
-- 包括: 工作连接、全部连接、用户举报等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local WorkHandlers = {}

-- CMD 6001: WORK_CONNECTION (工作连接)
local function handleWorkConnection(ctx)
    ctx.sendResponse(buildResponse(6001, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → WORK_CONNECTION response\27[0m")
    return true
end

-- CMD 6003: ALL_CONNECTION (全部连接)
local function handleAllConnection(ctx)
    ctx.sendResponse(buildResponse(6003, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ALL_CONNECTION response\27[0m")
    return true
end

-- CMD 1007: READ_COUNT (阅读计数)
local function handleReadCount(ctx)
    local body = writeUInt32BE(0)  -- count
    ctx.sendResponse(buildResponse(1007, ctx.userId, 0, body))
    print("\27[32m[Handler] → READ_COUNT response\27[0m")
    return true
end

-- CMD 7001: USER_REPORT / COMPLAIN_USER (用户举报)
local function handleUserReport(ctx)
    ctx.sendResponse(buildResponse(7001, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → USER_REPORT response\27[0m")
    return true
end

-- CMD 7002: USER_CONTRIBUTE (用户贡献)
local function handleUserContribute(ctx)
    ctx.sendResponse(buildResponse(7002, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → USER_CONTRIBUTE response\27[0m")
    return true
end

-- CMD 7003: USER_INDAGATE (用户调查)
local function handleUserIndagate(ctx)
    ctx.sendResponse(buildResponse(7003, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → USER_INDAGATE response\27[0m")
    return true
end

-- CMD 7501: INVITE_JOIN_GROUP (邀请加入群组)
local function handleInviteJoinGroup(ctx)
    ctx.sendResponse(buildResponse(7501, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → INVITE_JOIN_GROUP response\27[0m")
    return true
end

-- CMD 7502: REPLY_JOIN_GROUP (回复加入群组)
local function handleReplyJoinGroup(ctx)
    ctx.sendResponse(buildResponse(7502, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → REPLY_JOIN_GROUP response\27[0m")
    return true
end

-- 注册所有处理器
function WorkHandlers.register(Handlers)
    Handlers.register(6001, handleWorkConnection)
    Handlers.register(6003, handleAllConnection)
    Handlers.register(1007, handleReadCount)
    Handlers.register(7001, handleUserReport)
    Handlers.register(7002, handleUserContribute)
    Handlers.register(7003, handleUserIndagate)
    Handlers.register(7501, handleInviteJoinGroup)
    Handlers.register(7502, handleReplyJoinGroup)
    print("\27[36m[Handlers] 工作命令处理器已注册\27[0m")
end

return WorkHandlers
