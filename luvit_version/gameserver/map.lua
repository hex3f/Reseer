local Map = {}
local maps = {}
local mapsinfo = require "./mapsinfo"
local gpp = require "./gamepktprotocol"

-- 初始化地图（创建足够多的地图槽位）
for i = 1, 1000 do
    maps[i] = {}
end

function Map.getMap(mapid)
    if not maps[mapid] then
        maps[mapid] = {}
    end
    return maps[mapid]
end

function Map.getMapByUser(user)
    return Map.getMap(user.mapid or user.map or 1)
end

function Map.changeMapOfUser(user, newmap)
    local oldmap = user.mapid
    Map._userLeaveMap(user)
    user.mapid = newmap
    user.map = newmap
    Map._userEnterMap(user, newmap)
end

function Map.isMapVaild(mapid)
    return mapid and mapid > 0
end

function Map._userLeaveMap(user_leaving)
    local map = maps[user_leaving.mapid]
    if map == nil then return end
    
    -- 从地图中移除用户
    for i = #map, 1, -1 do
        if map[i] == user_leaving then
            table.remove(map, i)
            break
        end
    end
end

function Map._userEnterMap(user_entering, mapid)
    if not Map.isMapVaild(mapid) then
        return
    end
    
    local map = Map.getMap(mapid)
    
    -- 检查用户是否已在地图中
    for i = 1, #map do
        if map[i] == user_entering then
            return  -- 已经在地图中
        end
    end
    
    -- 添加用户到地图
    map[#map + 1] = user_entering
    
    -- 广播用户进入消息给地图中的其他玩家
    gpp.broadcastEnterMap(map, user_entering)
end

return Map