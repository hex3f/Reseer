-- 好友系统命令处理器
-- 包括: 添加好友、删除好友、黑名单等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local FriendHandlers = {}

-- CMD 2151: FRIEND_ADD (添加好友)
local function handleFriendAdd(ctx)
    local targetId = 0
    if #ctx.body >= 4 then
        targetId = readUInt32BE(ctx.body, 1)
    end
    ctx.sendResponse(buildResponse(2151, ctx.userId, 0, writeUInt32BE(targetId)))
    print(string.format("\27[32m[Handler] → FRIEND_ADD %d response\27[0m", targetId))
    return true
end

-- CMD 2152: FRIEND_ANSWER (好友请求回复)
local function handleFriendAnswer(ctx)
    local targetId = 0
    local accept = 0
    if #ctx.body >= 8 then
        targetId = readUInt32BE(ctx.body, 1)
        accept = readUInt32BE(ctx.body, 5)
    end
    ctx.sendResponse(buildResponse(2152, ctx.userId, 0, writeUInt32BE(accept)))
    print(string.format("\27[32m[Handler] → FRIEND_ANSWER %d accept=%d\27[0m", targetId, accept))
    return true
end

-- CMD 2153: FRIEND_REMOVE (删除好友)
local function handleFriendRemove(ctx)
    local targetId = 0
    if #ctx.body >= 4 then
        targetId = readUInt32BE(ctx.body, 1)
    end
    ctx.sendResponse(buildResponse(2153, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → FRIEND_REMOVE %d response\27[0m", targetId))
    return true
end

-- CMD 2154: BLACK_ADD (添加黑名单)
local function handleBlackAdd(ctx)
    local targetId = 0
    if #ctx.body >= 4 then
        targetId = readUInt32BE(ctx.body, 1)
    end
    ctx.sendResponse(buildResponse(2154, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → BLACK_ADD %d response\27[0m", targetId))
    return true
end

-- CMD 2155: BLACK_REMOVE (移除黑名单)
local function handleBlackRemove(ctx)
    local targetId = 0
    if #ctx.body >= 4 then
        targetId = readUInt32BE(ctx.body, 1)
    end
    ctx.sendResponse(buildResponse(2155, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → BLACK_REMOVE %d response\27[0m", targetId))
    return true
end

-- CMD 2157: SEE_ONLINE (查看在线状态)
local function handleSeeOnline(ctx)
    local targetId = 0
    if #ctx.body >= 4 then
        targetId = readUInt32BE(ctx.body, 1)
    end
    
    -- 获取真实在线状态
    local isOnline = 0
    if ctx.onlineTracker and ctx.onlineTracker.isOnline then
        isOnline = ctx.onlineTracker.isOnline(targetId) and 1 or 0
    elseif ctx.userDB then
        -- 备选方案: 检查用户是否有当前服务器记录
        local serverId = ctx.userDB:getUserServer(targetId)
        isOnline = (serverId and serverId > 0) and 1 or 0
    end
    
    local body = writeUInt32BE(targetId) .. writeUInt32BE(isOnline)
    ctx.sendResponse(buildResponse(2157, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → SEE_ONLINE %d online=%d\27[0m", targetId, isOnline))
    return true
end

-- CMD 2158: REQUEST_OUT (发送请求)
local function handleRequestOut(ctx)
    ctx.sendResponse(buildResponse(2158, ctx.userId, 0, ""))
    print("\27[32m[Handler] → REQUEST_OUT response\27[0m")
    return true
end

-- CMD 2159: REQUEST_ANSWER (请求回复)
local function handleRequestAnswer(ctx)
    ctx.sendResponse(buildResponse(2159, ctx.userId, 0, ""))
    print("\27[32m[Handler] → REQUEST_ANSWER response\27[0m")
    return true
end

-- CMD 2150: GET_RELATION_LIST (获取好友/黑名单列表)
-- 响应: friendCount(4) + blackCount(4) + [FriendInfo]... + [BlackInfo]...
-- FriendInfo: userID(4) + timePoke(4)
-- BlackInfo: userID(4)
local function handleGetRelationList(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    
    -- 获取好友列表
    local friends = user.friends or {}
    local blacklist = user.blacklist or {}
    
    local body = writeUInt32BE(#friends) .. writeUInt32BE(#blacklist)
    
    -- 写入好友列表
    for _, friend in ipairs(friends) do
        body = body .. writeUInt32BE(friend.userID or 0)
        body = body .. writeUInt32BE(friend.timePoke or 0)
    end
    
    -- 写入黑名单列表
    for _, black in ipairs(blacklist) do
        body = body .. writeUInt32BE(black.userID or 0)
    end
    
    ctx.sendResponse(buildResponse(2150, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → GET_RELATION_LIST friends=%d black=%d\27[0m", #friends, #blacklist))
    return true
end

-- 注册所有处理器
function FriendHandlers.register(Handlers)
    Handlers.register(2150, handleGetRelationList)
    Handlers.register(2151, handleFriendAdd)
    Handlers.register(2152, handleFriendAnswer)
    Handlers.register(2153, handleFriendRemove)
    Handlers.register(2154, handleBlackAdd)
    Handlers.register(2155, handleBlackRemove)
    Handlers.register(2157, handleSeeOnline)
    Handlers.register(2158, handleRequestOut)
    Handlers.register(2159, handleRequestAnswer)
    print("\27[36m[Handlers] 好友命令处理器已注册\27[0m")
end

return FriendHandlers
