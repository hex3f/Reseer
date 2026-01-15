-- 邮件/通知相关命令处理器
-- 包括: 邮件列表、未读邮件、通知等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local MailHandlers = {}

-- CMD 2751: MAIL_GET_LIST (获取邮件列表)
-- MailListInfo: total(4) + count(4) + [SingleMailInfo]...
local function handleMailGetList(ctx)
    local body = writeUInt32BE(0) .. writeUInt32BE(0)  -- total=0, count=0
    ctx.sendResponse(buildResponse(2751, ctx.userId, 0, body))
    print("\27[32m[Handler] → MAIL_GET_LIST response\27[0m")
    return true
end

-- CMD 2757: MAIL_GET_UNREAD (获取未读邮件)
local function handleMailGetUnread(ctx)
    ctx.sendResponse(buildResponse(2757, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → MAIL_GET_UNREAD response\27[0m")
    return true
end

-- CMD 8001: INFORM (通知)
-- InformInfo: type(4) + userID(4) + nick(16) + accept(4) + serverID(4) + mapType(4) + mapID(4) + mapName(64)
local function handleInform(ctx)
    local body = writeUInt32BE(0) ..
                writeUInt32BE(ctx.userId) ..
                writeFixedString("", 16) ..
                writeUInt32BE(0) ..
                writeUInt32BE(1) ..
                writeUInt32BE(0) ..
                writeUInt32BE(301) ..
                writeFixedString("", 64)
    ctx.sendResponse(buildResponse(8001, ctx.userId, 0, body))
    print("\27[32m[Handler] → INFORM response\27[0m")
    return true
end

-- CMD 8004: GET_BOSS_MONSTER (获取BOSS怪物)
-- BossMonsterInfo: bonusID(4) + petID(4) + captureTm(4) + itemCount(4) + [itemID(4) + itemCnt(4)]...
local function handleGetBossMonster(ctx)
    local body = writeUInt32BE(0) ..
                writeUInt32BE(0) ..
                writeUInt32BE(0) ..
                writeUInt32BE(0)
    ctx.sendResponse(buildResponse(8004, ctx.userId, 0, body))
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
