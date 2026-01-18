-- 会话管理器 (Session Manager)
-- 统一管理所有服务器的会话状态和临时数据
-- 实现数据与逻辑分离

local Logger = require('./logger')
local tprint = Logger.tprint

local SessionManager = {}
SessionManager.__index = SessionManager

-- 创建新的会话管理器实例
function SessionManager:new()
    local obj = {
        -- 用户会话表 (userId -> session data)
        sessions = {},
        
        -- 在线用户表 (userId -> online info)
        onlineUsers = {},
        
        -- 临时状态表
        tempStates = {
            -- NoNo 跟随状态 (userId -> boolean)
            nonoFollowing = {},
            
            -- 战斗状态 (userId -> battle data)
            battles = {},
            
            -- 交易状态 (userId -> trade data)
            trades = {},
            
            -- 组队状态 (userId -> team data)
            teams = {},
            
            -- 邀请状态 (userId -> invite data)
            invites = {},
        },
        
        -- 服务器连接表 (userId -> server info)
        serverConnections = {},
    }
    setmetatable(obj, SessionManager)
    tprint("\27[36m[SessionManager] 会话管理器已初始化\27[0m")
    return obj
end

-- ==================== 会话管理 ====================

-- 创建用户会话
function SessionManager:createSession(userId, serverType)
    if not self.sessions[userId] then
        self.sessions[userId] = {
            userId = userId,
            createdAt = os.time(),
            lastActiveAt = os.time(),
            serverType = serverType,  -- 'game' or 'room'
            data = {},
        }
        tprint(string.format("\27[36m[SessionManager] 创建会话: userId=%d, server=%s\27[0m", 
            userId, serverType))
    end
    return self.sessions[userId]
end

-- 获取用户会话
function SessionManager:getSession(userId)
    return self.sessions[userId]
end

-- 更新会话活跃时间
function SessionManager:updateSessionActivity(userId)
    local session = self.sessions[userId]
    if session then
        session.lastActiveAt = os.time()
    end
end

-- 销毁用户会话
function SessionManager:destroySession(userId)
    if self.sessions[userId] then
        tprint(string.format("\27[36m[SessionManager] 销毁会话: userId=%d\27[0m", userId))
        self.sessions[userId] = nil
    end
end

-- 设置会话数据
function SessionManager:setSessionData(userId, key, value)
    local session = self:getSession(userId)
    if session then
        session.data[key] = value
    end
end

-- 获取会话数据
function SessionManager:getSessionData(userId, key)
    local session = self:getSession(userId)
    if session then
        return session.data[key]
    end
    return nil
end

-- ==================== 在线状态管理 ====================

-- 用户上线
function SessionManager:userOnline(userId, serverType, mapId)
    self.onlineUsers[userId] = {
        userId = userId,
        serverType = serverType,  -- 'game' or 'room'
        mapId = mapId or 0,
        onlineAt = os.time(),
        lastHeartbeat = os.time(),
    }
    tprint(string.format("\27[36m[SessionManager] 用户上线: userId=%d, server=%s, map=%d\27[0m", 
        userId, serverType, mapId or 0))
end

-- 用户下线
function SessionManager:userOffline(userId)
    if self.onlineUsers[userId] then
        tprint(string.format("\27[36m[SessionManager] 用户下线: userId=%d\27[0m", userId))
        self.onlineUsers[userId] = nil
        
        -- 清理临时状态
        self:clearUserTempStates(userId)
    end
end

-- 检查用户是否在线
function SessionManager:isUserOnline(userId)
    return self.onlineUsers[userId] ~= nil
end

-- 获取在线用户信息
function SessionManager:getOnlineUser(userId)
    return self.onlineUsers[userId]
end

-- 更新用户地图
function SessionManager:updateUserMap(userId, mapId)
    local user = self.onlineUsers[userId]
    if user then
        user.mapId = mapId
    end
end

-- 更新用户服务器类型
function SessionManager:updateUserServer(userId, serverType)
    local user = self.onlineUsers[userId]
    if user then
        user.serverType = serverType
        tprint(string.format("\27[36m[SessionManager] 用户切换服务器: userId=%d, server=%s\27[0m", 
            userId, serverType))
    end
end

-- 更新心跳
function SessionManager:updateHeartbeat(userId)
    local user = self.onlineUsers[userId]
    if user then
        user.lastHeartbeat = os.time()
    end
end

-- 获取所有在线用户
function SessionManager:getAllOnlineUsers()
    local users = {}
    for userId, user in pairs(self.onlineUsers) do
        table.insert(users, user)
    end
    return users
end

-- 获取指定地图的在线用户
function SessionManager:getUsersInMap(mapId)
    local users = {}
    for userId, user in pairs(self.onlineUsers) do
        if user.mapId == mapId then
            table.insert(users, userId)
        end
    end
    return users
end

-- ==================== NoNo 状态管理 ====================

-- 设置 NoNo 跟随状态
function SessionManager:setNonoFollowing(userId, isFollowing)
    self.tempStates.nonoFollowing[userId] = isFollowing
    tprint(string.format("\27[36m[SessionManager] NoNo 跟随状态: userId=%d, following=%s\27[0m", 
        userId, tostring(isFollowing)))
end

-- 获取 NoNo 跟随状态
function SessionManager:getNonoFollowing(userId)
    return self.tempStates.nonoFollowing[userId] or false
end

-- 清除 NoNo 跟随状态
function SessionManager:clearNonoFollowing(userId)
    self.tempStates.nonoFollowing[userId] = nil
end

-- ==================== 战斗状态管理 ====================

-- 创建战斗
function SessionManager:createBattle(userId, battleData)
    self.tempStates.battles[userId] = battleData
    tprint(string.format("\27[36m[SessionManager] 创建战斗: userId=%d\27[0m", userId))
end

-- 获取战斗状态
function SessionManager:getBattle(userId)
    return self.tempStates.battles[userId]
end

-- 更新战斗状态
function SessionManager:updateBattle(userId, battleData)
    if self.tempStates.battles[userId] then
        for k, v in pairs(battleData) do
            self.tempStates.battles[userId][k] = v
        end
    end
end

-- 结束战斗
function SessionManager:endBattle(userId)
    if self.tempStates.battles[userId] then
        tprint(string.format("\27[36m[SessionManager] 结束战斗: userId=%d\27[0m", userId))
        self.tempStates.battles[userId] = nil
    end
end

-- 检查是否在战斗中
function SessionManager:isInBattle(userId)
    return self.tempStates.battles[userId] ~= nil
end

-- ==================== 交易状态管理 ====================

-- 创建交易
function SessionManager:createTrade(userId1, userId2, tradeData)
    local tradeId = string.format("%d_%d", userId1, userId2)
    self.tempStates.trades[tradeId] = tradeData
    tprint(string.format("\27[36m[SessionManager] 创建交易: %d <-> %d\27[0m", userId1, userId2))
    return tradeId
end

-- 获取交易状态
function SessionManager:getTrade(userId)
    -- 查找包含该用户的交易
    for tradeId, trade in pairs(self.tempStates.trades) do
        if trade.userId1 == userId or trade.userId2 == userId then
            return trade
        end
    end
    return nil
end

-- 结束交易
function SessionManager:endTrade(tradeId)
    if self.tempStates.trades[tradeId] then
        tprint(string.format("\27[36m[SessionManager] 结束交易: %s\27[0m", tradeId))
        self.tempStates.trades[tradeId] = nil
    end
end

-- ==================== 组队状态管理 ====================

-- 创建队伍
function SessionManager:createTeam(leaderId, teamData)
    self.tempStates.teams[leaderId] = teamData
    tprint(string.format("\27[36m[SessionManager] 创建队伍: leader=%d\27[0m", leaderId))
end

-- 获取队伍
function SessionManager:getTeam(userId)
    -- 查找用户所在的队伍
    for leaderId, team in pairs(self.tempStates.teams) do
        if team.leaderId == userId then
            return team
        end
        if team.members then
            for _, memberId in ipairs(team.members) do
                if memberId == userId then
                    return team
                end
            end
        end
    end
    return nil
end

-- 解散队伍
function SessionManager:disbandTeam(leaderId)
    if self.tempStates.teams[leaderId] then
        tprint(string.format("\27[36m[SessionManager] 解散队伍: leader=%d\27[0m", leaderId))
        self.tempStates.teams[leaderId] = nil
    end
end

-- ==================== 邀请状态管理 ====================

-- 创建邀请
function SessionManager:createInvite(fromUserId, toUserId, inviteType, inviteData)
    local inviteId = string.format("%d_%d_%s", fromUserId, toUserId, inviteType)
    self.tempStates.invites[inviteId] = {
        fromUserId = fromUserId,
        toUserId = toUserId,
        inviteType = inviteType,  -- 'friend', 'team', 'trade', 'battle'
        data = inviteData,
        createdAt = os.time(),
    }
    tprint(string.format("\27[36m[SessionManager] 创建邀请: %d -> %d (%s)\27[0m", 
        fromUserId, toUserId, inviteType))
    return inviteId
end

-- 获取邀请
function SessionManager:getInvite(inviteId)
    return self.tempStates.invites[inviteId]
end

-- 获取用户的所有邀请
function SessionManager:getUserInvites(userId)
    local invites = {}
    for inviteId, invite in pairs(self.tempStates.invites) do
        if invite.toUserId == userId then
            table.insert(invites, invite)
        end
    end
    return invites
end

-- 删除邀请
function SessionManager:removeInvite(inviteId)
    if self.tempStates.invites[inviteId] then
        self.tempStates.invites[inviteId] = nil
    end
end

-- ==================== 服务器连接管理 ====================

-- 注册服务器连接
function SessionManager:registerConnection(userId, serverType, clientData)
    self.serverConnections[userId] = {
        serverType = serverType,
        clientData = clientData,
        connectedAt = os.time(),
    }
end

-- 注销服务器连接
function SessionManager:unregisterConnection(userId)
    self.serverConnections[userId] = nil
end

-- 获取服务器连接
function SessionManager:getConnection(userId)
    return self.serverConnections[userId]
end

-- ==================== 清理操作 ====================

-- 清理用户的所有临时状态
function SessionManager:clearUserTempStates(userId)
    -- 清理 NoNo 状态
    self:clearNonoFollowing(userId)
    
    -- 清理战斗状态
    self:endBattle(userId)
    
    -- 清理交易状态
    local trade = self:getTrade(userId)
    if trade then
        self:endTrade(trade.tradeId)
    end
    
    -- 清理队伍状态
    local team = self:getTeam(userId)
    if team and team.leaderId == userId then
        self:disbandTeam(userId)
    end
    
    -- 清理邀请
    for inviteId, invite in pairs(self.tempStates.invites) do
        if invite.fromUserId == userId or invite.toUserId == userId then
            self:removeInvite(inviteId)
        end
    end
    
    tprint(string.format("\27[36m[SessionManager] 清理用户临时状态: userId=%d\27[0m", userId))
end

-- 清理过期会话 (超过指定时间未活跃)
function SessionManager:cleanupExpiredSessions(timeoutSeconds)
    timeoutSeconds = timeoutSeconds or 3600  -- 默认 1 小时
    local now = os.time()
    local expiredCount = 0
    
    for userId, session in pairs(self.sessions) do
        if now - session.lastActiveAt > timeoutSeconds then
            self:destroySession(userId)
            expiredCount = expiredCount + 1
        end
    end
    
    if expiredCount > 0 then
        tprint(string.format("\27[36m[SessionManager] 清理过期会话: %d 个\27[0m", expiredCount))
    end
end

-- 清理离线用户 (超过指定时间未心跳)
function SessionManager:cleanupOfflineUsers(timeoutSeconds)
    timeoutSeconds = timeoutSeconds or 300  -- 默认 5 分钟
    local now = os.time()
    local offlineCount = 0
    
    for userId, user in pairs(self.onlineUsers) do
        if now - user.lastHeartbeat > timeoutSeconds then
            self:userOffline(userId)
            offlineCount = offlineCount + 1
        end
    end
    
    if offlineCount > 0 then
        tprint(string.format("\27[36m[SessionManager] 清理离线用户: %d 个\27[0m", offlineCount))
    end
end

-- ==================== 统计信息 ====================

-- 获取统计信息
function SessionManager:getStats()
    local stats = {
        totalSessions = 0,
        onlineUsers = 0,
        activeBattles = 0,
        activeTrades = 0,
        activeTeams = 0,
        pendingInvites = 0,
        nonoFollowing = 0,
    }
    
    for _ in pairs(self.sessions) do
        stats.totalSessions = stats.totalSessions + 1
    end
    
    for _ in pairs(self.onlineUsers) do
        stats.onlineUsers = stats.onlineUsers + 1
    end
    
    for _ in pairs(self.tempStates.battles) do
        stats.activeBattles = stats.activeBattles + 1
    end
    
    for _ in pairs(self.tempStates.trades) do
        stats.activeTrades = stats.activeTrades + 1
    end
    
    for _ in pairs(self.tempStates.teams) do
        stats.activeTeams = stats.activeTeams + 1
    end
    
    for _ in pairs(self.tempStates.invites) do
        stats.pendingInvites = stats.pendingInvites + 1
    end
    
    for _, following in pairs(self.tempStates.nonoFollowing) do
        if following then
            stats.nonoFollowing = stats.nonoFollowing + 1
        end
    end
    
    return stats
end

-- 打印统计信息
function SessionManager:printStats()
    local stats = self:getStats()
    tprint("\27[36m[SessionManager] ========== 统计信息 ==========\27[0m")
    tprint(string.format("\27[36m[SessionManager] 总会话数: %d\27[0m", stats.totalSessions))
    tprint(string.format("\27[36m[SessionManager] 在线用户: %d\27[0m", stats.onlineUsers))
    tprint(string.format("\27[36m[SessionManager] 活跃战斗: %d\27[0m", stats.activeBattles))
    tprint(string.format("\27[36m[SessionManager] 活跃交易: %d\27[0m", stats.activeTrades))
    tprint(string.format("\27[36m[SessionManager] 活跃队伍: %d\27[0m", stats.activeTeams))
    tprint(string.format("\27[36m[SessionManager] 待处理邀请: %d\27[0m", stats.pendingInvites))
    tprint(string.format("\27[36m[SessionManager] NoNo 跟随: %d\27[0m", stats.nonoFollowing))
    tprint("\27[36m[SessionManager] ================================\27[0m")
end

return SessionManager
