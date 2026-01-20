-- 邮件/通知相关命令处理器
-- 包括: 邮件列表、未读邮件、通知等

local BinaryWriter = require('utils/binary_writer')
local ResponseBuilder = require('utils/response_builder')

local MailHandlers = {}

-- CMD 2751: MAIL_GET_LIST (获取邮件列表)
-- MailListInfo: total(4) + count(4) + [SingleMailInfo]...
-- CMD 2751: MAIL_GET_LIST (获取邮件列表)
local function handleMailGetList(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- total
    writer:writeUInt32BE(0) -- count
    ctx.sendResponse(ResponseBuilder.build(2751, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → MAIL_GET_LIST response\27[0m")
    return true
end

-- CMD 2757: MAIL_GET_UNREAD (获取未读邮件)
local function handleMailGetUnread(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2757, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → MAIL_GET_UNREAD response\27[0m")
    return true
end

-- CMD 8001: INFORM (通知)
local function handleInform(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- type
    writer:writeUInt32BE(ctx.userId)
    writer:writeStringFixed("", 16)
    writer:writeUInt32BE(0) -- accept
    writer:writeUInt32BE(1) -- serverID
    writer:writeUInt32BE(0) -- mapType
    writer:writeUInt32BE(301) -- mapID
    writer:writeStringFixed("", 64) -- mapName
    
    ctx.sendResponse(ResponseBuilder.build(8001, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → INFORM response\27[0m")
    return true
end

-- CMD 8004: GET_BOSS_MONSTER (获取BOSS怪物)
local function handleGetBossMonster(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- bonusID
    writer:writeUInt32BE(0) -- petID
    writer:writeUInt32BE(0) -- captureTm
    writer:writeUInt32BE(0) -- itemCount
    
    ctx.sendResponse(ResponseBuilder.build(8004, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → GET_BOSS_MONSTER response\27[0m")
    return true
end

-- 注册所有处理器
function MailHandlers.register(Handlers)
    Handlers.register(2751, handleMailGetList)
    Handlers.register(2757, handleMailGetUnread)
    Handlers.register(8001, handleInform)
    Handlers.register(8004, handleGetBossMonster)
    print("\27[36m[Handlers] 邮件/通知命令处理器已注册\27[0m")
end

return MailHandlers
