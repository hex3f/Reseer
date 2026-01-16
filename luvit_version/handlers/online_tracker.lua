-- 在线玩家追踪模块
-- 追踪玩家所在地图，提供实时在线人数统计

local OnlineTracker = {}

-- 在线玩家表: userId -> {mapId, mapType, loginTime, lastActive, socket, clientData}
local onlinePlayers = {}

-- 地图玩家计数缓存: mapId -> count
local mapPlayerCount = {}

-- 记录玩家上线 (带 socket 连接)
function OnlineTracker.playerLogin(userId, clientData)
    if not onlinePlayers[userId] then
        onlinePlayers[userId] = {
            mapId = 0,
            mapType = 0,
            loginTime = os.time(),
            lastActive = os.time(),
            clientData = clientData
        }
        print(string.format("\27[36m[OnlineTracker] 玩家 %d 上线\27[0m", userId))
    elseif clientData then
        -- 更新连接
        onlinePlayers[userId].clientData = clientData
    end
end

-- 记录玩家下线
function OnlineTracker.playerLogout(userId)
    local player = onlinePlayers[userId]
    if player and player.mapId > 0 then
        -- 从旧地图移除
        if mapPlayerCount[player.mapId] then
            mapPlayerCount[player.mapId] = mapPlayerCount[player.mapId] - 1
            if mapPlayerCount[player.mapId] <= 0 then
                mapPlayerCount[player.mapId] = nil
            end
        end
    end
    onlinePlayers[userId] = nil
    print(string.format("\27[36m[OnlineTracker] 玩家 %d 下线\27[0m", userId))
end

-- 更新玩家所在地图
function OnlineTracker.updatePlayerMap(userId, newMapId, mapType)
    if not onlinePlayers[userId] then
        OnlineTracker.playerLogin(userId, nil)
    end
    
    local player = onlinePlayers[userId]
    local oldMapId = player.mapId
    
    -- 从旧地图移除计数
    if oldMapId > 0 and oldMapId ~= newMapId then
        if mapPlayerCount[oldMapId] then
            mapPlayerCount[oldMapId] = mapPlayerCount[oldMapId] - 1
            if mapPlayerCount[oldMapId] <= 0 then
                mapPlayerCount[oldMapId] = nil
            end
        end
    end
    
    -- 添加到新地图计数
    if newMapId > 0 and oldMapId ~= newMapId then
        mapPlayerCount[newMapId] = (mapPlayerCount[newMapId] or 0) + 1
    end
    
    -- 更新玩家信息
    player.mapId = newMapId
    player.mapType = mapType or 0
    player.lastActive = os.time()
    
    print(string.format("\27[36m[OnlineTracker] 玩家 %d 进入地图 %d (旧地图: %d)\27[0m", userId, newMapId, oldMapId))
end

-- 设置玩家的 clientData (用于广播)
function OnlineTracker.setClientData(userId, clientData)
    if onlinePlayers[userId] then
        onlinePlayers[userId].clientData = clientData
    end
end

-- 获取玩家的 clientData
function OnlineTracker.getClientData(userId)
    local player = onlinePlayers[userId]
    return player and player.clientData or nil
end

-- 获取地图在线人数
function OnlineTracker.getMapPlayerCount(mapId)
    return mapPlayerCount[mapId] or 0
end

-- 获取所有有人的地图及人数
function OnlineTracker.getAllMapCounts()
    local result = {}
    for mapId, count in pairs(mapPlayerCount) do
        if count > 0 then
            table.insert(result, {mapId = mapId, count = count})
        end
    end
    -- 按人数降序排序
    table.sort(result, function(a, b) return a.count > b.count end)
    return result
end

-- 获取在线玩家总数
function OnlineTracker.getOnlineCount()
    local count = 0
    for _ in pairs(onlinePlayers) do
        count = count + 1
    end
    return count
end

-- 获取玩家当前地图
function OnlineTracker.getPlayerMap(userId)
    local player = onlinePlayers[userId]
    return player and player.mapId or 0
end

-- 获取指定地图的所有玩家ID
function OnlineTracker.getPlayersInMap(mapId)
    local players = {}
    for userId, player in pairs(onlinePlayers) do
        if player.mapId == mapId then
            table.insert(players, userId)
        end
    end
    return players
end

-- 广播消息给指定地图的所有玩家
function OnlineTracker.broadcastToMap(mapId, packet, excludeUserId)
    local players = OnlineTracker.getPlayersInMap(mapId)
    local sent = 0
    for _, userId in ipairs(players) do
        if userId ~= excludeUserId then
            local player = onlinePlayers[userId]
            if player and player.clientData and player.clientData.socket then
                pcall(function()
                    player.clientData.socket:write(packet)
                    sent = sent + 1
                end)
            end
        end
    end
    return sent
end

-- 发送消息给指定玩家
function OnlineTracker.sendToPlayer(userId, packet)
    local player = onlinePlayers[userId]
    if player and player.clientData and player.clientData.socket then
        pcall(function()
            player.clientData.socket:write(packet)
        end)
        return true
    end
    return false
end

-- 检查玩家是否在线
function OnlineTracker.isOnline(userId)
    return onlinePlayers[userId] ~= nil
end

-- 更新玩家活跃时间
function OnlineTracker.updateActivity(userId)
    if onlinePlayers[userId] then
        onlinePlayers[userId].lastActive = os.time()
    end
end

-- 清理超时玩家 (超过指定秒数无活动)
function OnlineTracker.cleanupInactive(timeoutSeconds)
    timeoutSeconds = timeoutSeconds or 300  -- 默认5分钟
    local now = os.time()
    local removed = 0
    
    for userId, player in pairs(onlinePlayers) do
        if now - player.lastActive > timeoutSeconds then
            OnlineTracker.playerLogout(userId)
            removed = removed + 1
        end
    end
    
    if removed > 0 then
        print(string.format("\27[33m[OnlineTracker] 清理了 %d 个超时玩家\27[0m", removed))
    end
    return removed
end

return OnlineTracker
