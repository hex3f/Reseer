-- 好友系统命令处理器
-- 包括: 添加好友、删除好友、黑名单等

local BinaryWriter = require('utils/binary_writer')
local BinaryReader = require('utils/binary_reader')
local ResponseBuilder = require('utils/response_builder')

local FriendHandlers = {}

-- CMD 2151: FRIEND_ADD (添加好友)
-- 将目标用户添加到好友列表并持久化
local function handleFriendAdd(ctx)
    local targetId = 0
    if #ctx.body >= 4 then
        local reader = BinaryReader.new(ctx.body)
        targetId = reader:readUInt32BE()
    end
    
    if targetId == 0 or targetId == ctx.userId then
        ctx.sendResponse(ResponseBuilder.build(2151, ctx.userId, 1, ""))
        return true
    end
    
    -- 获取用户数据
    local user = ctx.getOrCreateUser(ctx.userId)
    user.friends = user.friends or {}
    
    -- 检查是否已经是好友
    for _, friend in ipairs(user.friends) do
        if friend.userID == targetId then
            -- 已经是好友，直接返回成功
            local writer = BinaryWriter.new()
            writer:writeUInt32BE(targetId)
            ctx.sendResponse(ResponseBuilder.build(2151, ctx.userId, 0, writer:toString()))
            return true
        end
    end
    
    -- 添加好友
    table.insert(user.friends, {
        userID = targetId,
        timePoke = os.time()
    })
    ctx.saveUserDB()
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(targetId)
    
    ctx.sendResponse(ResponseBuilder.build(2151, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → FRIEND_ADD %d response (saved)\\27[0m", targetId))
    return true
end

-- CMD 2152: FRIEND_ANSWER (好友请求回复)
-- accept=1时双方互加好友
local function handleFriendAnswer(ctx)
    local targetId = 0
    local accept = 0
    if #ctx.body >= 8 then
        local reader = BinaryReader.new(ctx.body)
        targetId = reader:readUInt32BE()
        accept = reader:readUInt32BE()
    end
    
    if accept == 1 and targetId > 0 then
        -- 双方互加好友
        local user = ctx.getOrCreateUser(ctx.userId)
        user.friends = user.friends or {}
        
        -- 检查是否已是好友
        local found = false
        for _, f in ipairs(user.friends) do
            if f.userID == targetId then found = true break end
        end
        if not found then
            table.insert(user.friends, {userID = targetId, timePoke = os.time()})
            ctx.saveUserDB()
        end
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(accept)
    
    ctx.sendResponse(ResponseBuilder.build(2152, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → FRIEND_ANSWER %d accept=%d (saved)\27[0m", targetId, accept))
    return true
end

-- CMD 2153: FRIEND_REMOVE (删除好友)
-- 从好友列表中移除并持久化
local function handleFriendRemove(ctx)
    local targetId = 0
    if #ctx.body >= 4 then
        local reader = BinaryReader.new(ctx.body)
        targetId = reader:readUInt32BE()
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.friends = user.friends or {}
    
    -- 查找并移除好友
    for i, friend in ipairs(user.friends) do
        if friend.userID == targetId then
            table.remove(user.friends, i)
            ctx.saveUserDB()
            break
        end
    end
    
    ctx.sendResponse(ResponseBuilder.build(2153, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → FRIEND_REMOVE %d (saved)\27[0m", targetId))
    return true
end

-- CMD 2154: BLACK_ADD (添加黑名单)
-- 添加到黑名单，同时从好友列表移除
local function handleBlackAdd(ctx)
    local targetId = 0
    if #ctx.body >= 4 then
        local reader = BinaryReader.new(ctx.body)
        targetId = reader:readUInt32BE()
    end
    
    if targetId == 0 or targetId == ctx.userId then
        ctx.sendResponse(ResponseBuilder.build(2154, ctx.userId, 1, ""))
        return true
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.blacklist = user.blacklist or {}
    user.friends = user.friends or {}
    
    -- 从好友列表移除
    for i, friend in ipairs(user.friends) do
        if friend.userID == targetId then
            table.remove(user.friends, i)
            break
        end
    end
    
    -- 检查是否已在黑名单
    local found = false
    for _, b in ipairs(user.blacklist) do
        if b.userID == targetId then found = true break end
    end
    
    if not found then
        table.insert(user.blacklist, {userID = targetId})
    end
    ctx.saveUserDB()
    
    -- 响应格式: userID(4)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(targetId)
    ctx.sendResponse(ResponseBuilder.build(2154, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → BLACK_ADD %d (saved)\27[0m", targetId))
    return true
end

-- CMD 2155: BLACK_REMOVE (移除黑名单)
-- 从黑名单移除并持久化
local function handleBlackRemove(ctx)
    local targetId = 0
    if #ctx.body >= 4 then
        local reader = BinaryReader.new(ctx.body)
        targetId = reader:readUInt32BE()
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.blacklist = user.blacklist or {}
    
    -- 查找并移除
    for i, b in ipairs(user.blacklist) do
        if b.userID == targetId then
            table.remove(user.blacklist, i)
            ctx.saveUserDB()
            break
        end
    end
    
    ctx.sendResponse(ResponseBuilder.build(2155, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → BLACK_REMOVE %d (saved)\27[0m", targetId))
    return true
end

-- CMD 2157: SEE_ONLINE (查看在线状态)
local function handleSeeOnline(ctx)
    -- 读取请求中的用户ID列表
    local reader = BinaryReader.new(ctx.body)
    local requestCount = 0
    local userIds = {}
    
    if reader:getRemaining() ~= "" then
        requestCount = reader:readUInt32BE()
    end
    
    -- 读取所有请求的用户ID
    for i = 1, requestCount do
        if reader:getRemaining() ~= "" then
            local userId = reader:readUInt32BE()
            table.insert(userIds, userId)
        end
    end
    
    -- 构建在线用户列表
    local onlineUsers = {}
    local OnlineTracker = require('handlers/online_tracker')
    
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
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(#onlineUsers)
    
    for _, info in ipairs(onlineUsers) do
        writer:writeUInt32BE(info.userID)     -- userID (4)
        writer:writeUInt32BE(info.serverID)   -- serverID (4)
        writer:writeUInt32BE(info.mapType)    -- mapType (4)
        writer:writeUInt32BE(info.mapID)      -- mapID (4)
    end
    
    ctx.sendResponse(ResponseBuilder.build(2157, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → SEE_ONLINE (requested=%d, online=%d)\27[0m", requestCount, #onlineUsers))
    return true
end

-- CMD 2158: REQUEST_OUT (发送请求)
local function handleRequestOut(ctx)
    ctx.sendResponse(ResponseBuilder.build(2158, ctx.userId, 0, ""))
    print("\27[32m[Handler] → REQUEST_OUT response\27[0m")
    return true
end

-- CMD 2159: REQUEST_ANSWER (请求回复)
local function handleRequestAnswer(ctx)
    ctx.sendResponse(ResponseBuilder.build(2159, ctx.userId, 0, ""))
    print("\27[32m[Handler] → REQUEST_ANSWER response\27[0m")
    return true
end

-- CMD 2150: GET_RELATION_LIST (获取好友/黑名单列表)
-- 响应格式 (按 RelationManager.as 顺序):
--   friendCount(4) + [userID(4) + timePoke(4)]... + blackCount(4) + [userID(4)]...
local function handleGetRelationList(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    
    -- 获取好友列表
    local friends = user.friends or {}
    local blacklist = user.blacklist or {}
    
    local writer = BinaryWriter.new()
    
    -- 1. 好友数量
    writer:writeUInt32BE(#friends)
    
    -- 2. 好友列表 (userID + timePoke)
    for _, friend in ipairs(friends) do
        writer:writeUInt32BE(friend.userID or 0)
        writer:writeUInt32BE(friend.timePoke or 0)
    end
    
    -- 3. 黑名单数量
    writer:writeUInt32BE(#blacklist)
    
    -- 4. 黑名单列表 (userID only)
    for _, black in ipairs(blacklist) do
        writer:writeUInt32BE(black.userID or 0)
    end
    
    ctx.sendResponse(ResponseBuilder.build(2150, ctx.userId, 0, writer:toString()))
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
