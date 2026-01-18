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
-- 请求格式: count(4) + userIDs[count] (每个4字节)
-- 响应格式: onlineCount(4) + [OnLineInfo]...
-- OnLineInfo: userID(4) + serverID(4) + mapType(4) + mapID(4) = 16 bytes
local function handleSeeOnline(ctx)
    -- 读取请求中的用户ID列表
    local requestCount = 0
    local userIds = {}
    
    if #ctx.body >= 4 then
        requestCount = readUInt32BE(ctx.body, 1)
    end
    
    -- 读取所有请求的用户ID
    for i = 1, requestCount do
        local offset = 5 + (i - 1) * 4
        if #ctx.body >= offset + 3 then
            local userId = readUInt32BE(ctx.body, offset)
            table.insert(userIds, userId)
        end
    end
    
    -- 构建在线用户列表
    local onlineUsers = {}
    local OnlineTracker = require('./online_tracker')
    
    for _, targetId in ipairs(userIds) do
        -- 检查用户是否在线
        local isOnline = OnlineTracker.isOnline(targetId)
        
        if isOnline then
            local user = ctx.getOrCreateUser(targetId)
            local mapId = OnlineTracker.getPlayerMap(targetId) or user.mapId or 0
            local mapType = user.mapType or 0
            local serverId = 1  -- 当前服务器ID
            
            table.insert(onlineUsers, {
                userID = targetId,
                serverID = serverId,
                mapType = mapType,
                mapID = mapId
            })
        end
    end
    
    -- 构建响应: count(4) + [OnLineInfo]...
    local body = writeUInt32BE(#onlineUsers)
    for _, info in ipairs(onlineUsers) do
        body = body .. writeUInt32BE(info.userID)     -- userID (4)
        body = body .. writeUInt32BE(info.serverID)   -- serverID (4)
        body = body .. writeUInt32BE(info.mapType)    -- mapType (4)
        body = body .. writeUInt32BE(info.mapID)      -- mapID (4)
    end
    
    ctx.sendResponse(buildResponse(2157, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → SEE_ONLINE (requested=%d, online=%d)\27[0m", requestCount, #onlineUsers))
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
