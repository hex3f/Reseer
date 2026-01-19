-- servers
local srv = {}
local UserDB = require "../../core/userdb"

-- 获取在线用户数量
function srv.getOnlineCount()
    local userDB = UserDB:new()
    local count = 0
    
    -- 遍历所有用户的游戏数据，统计在线用户
    if userDB.gameData then
        for userId, data in pairs(userDB.gameData) do
            if data.currentServer and data.currentServer > 0 then
                count = count + 1
            end
        end
    end
    
    return count
end

function srv.getGoodSrvList()
    local gamePort = conf and conf.gameserver_port or 5000
    local serverId = conf and conf.server_id or 1
    
    -- 返回单个服务器，在线人数从数据库获取
    -- friends 固定为 1，表示有好友在线（避免 statusHeadMC 闪烁）
    return {
        {
            id = serverId,
            userCount = srv.getOnlineCount(),
            ip = "127.0.0.1",
            port = gamePort,
            friends = 1,  -- 固定为1，避免UI闪烁
        },
    }
end

function srv.getServerList()
    return srv.getGoodSrvList()
end

function srv.getMaxServerID()
    return 18
end

return srv