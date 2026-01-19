-- 服务器列表管理模块
-- 管理游戏服务器列表，支持动态配置

local fs = require('fs')
local JSON = require('json')

local PacketUtils = require('../core/packet_utils')

local ServerList = {}
ServerList.__index = ServerList

-- 服务器列表配置文件
local CONFIG_FILE = "serverlist.json"


-- 默认服务器列表 (模拟官服29个服务器)
local DEFAULT_SERVERS = {}
for i = 1, 29 do
    table.insert(DEFAULT_SERVERS, {
        id = i,
        name = "服务器" .. i,
        ip = "127.0.0.1",
        port = 5000 + i,  -- 端口 5001-5029
        maxUsers = 300,
        status = 1  -- 1=正常, 0=维护
    })
end

-- 在线用户计数（模拟）
local onlineUsers = {}

-- 初始化
function ServerList.init()
    -- 尝试加载配置文件
    local success, content = pcall(function()
        return fs.readFileSync(CONFIG_FILE)
    end)
    
    if success and content then
        local ok, data = pcall(function()
            return JSON.parse(content)
        end)
        if ok and data and data.servers then
            ServerList.servers = data.servers
            print(string.format("\27[32m[ServerList] 已加载 %d 个服务器配置\27[0m", #ServerList.servers))
            return
        end
    end
    
    -- 使用默认配置
    ServerList.servers = DEFAULT_SERVERS
    ServerList.save()
    print(string.format("\27[33m[ServerList] 使用默认配置，已创建 %d 个服务器\27[0m", #ServerList.servers))
end

-- 保存配置
function ServerList.save()
    local content = JSON.stringify({
        servers = ServerList.servers,
        lastModified = os.date("%Y-%m-%d %H:%M:%S")
    })
    fs.writeFileSync(CONFIG_FILE, content)
end

-- 获取所有服务器
function ServerList.getAll()
    return ServerList.servers or DEFAULT_SERVERS
end

-- 获取服务器数量
function ServerList.getCount()
    return #(ServerList.servers or DEFAULT_SERVERS)
end

-- 获取最大服务器ID
function ServerList.getMaxId()
    local maxId = 0
    for _, srv in ipairs(ServerList.servers or DEFAULT_SERVERS) do
        if srv.id > maxId then
            maxId = srv.id
        end
    end
    return maxId
end

-- 获取指定服务器
function ServerList.getById(id)
    for _, srv in ipairs(ServerList.servers or DEFAULT_SERVERS) do
        if srv.id == id then
            return srv
        end
    end
    return nil
end

-- 获取服务器在线人数（模拟）
function ServerList.getOnlineCount(serverId)
    return onlineUsers[serverId] or math.random(0, 50)
end

-- 设置服务器在线人数
function ServerList.setOnlineCount(serverId, count)
    onlineUsers[serverId] = count
end

-- 增加在线人数
function ServerList.incrementOnline(serverId)
    onlineUsers[serverId] = (onlineUsers[serverId] or 0) + 1
end

-- 减少在线人数
function ServerList.decrementOnline(serverId)
    local count = onlineUsers[serverId] or 0
    if count > 0 then
        onlineUsers[serverId] = count - 1
    end
end

-- 添加服务器
function ServerList.add(server)
    if not server.id then
        server.id = ServerList.getMaxId() + 1
    end
    table.insert(ServerList.servers, server)
    ServerList.save()
    return server.id
end

-- 删除服务器
function ServerList.remove(id)
    for i, srv in ipairs(ServerList.servers) do
        if srv.id == id then
            table.remove(ServerList.servers, i)
            ServerList.save()
            return true
        end
    end
    return false
end

-- 更新服务器
function ServerList.update(id, updates)
    for _, srv in ipairs(ServerList.servers) do
        if srv.id == id then
            for k, v in pairs(updates) do
                srv[k] = v
            end
            ServerList.save()
            return true
        end
    end
    return false
end

-- 构建 CMD 105 响应的 body 数据
-- 严格按照 CommendSvrInfo.as 和 ServerInfo.as 的解析格式
function ServerList.buildCommendOnlineBody(isVIP)
    isVIP = isVIP or 1
    
    local servers = ServerList.getAll()
    local body = ""
    
    -- CommendSvrInfo.as 解析顺序:
    -- 1. maxOnlineID (4字节) - 最大服务器ID，用于分页
    -- 2. isVIP (4字节) - 是否VIP (超能NONO)
    -- 3. onlineCnt (4字节) - 服务器数量
    -- 4. 服务器列表 (每个30字节)
    -- 5. friendData (剩余数据)
    
    body = body .. PacketUtils.writeUInt32BE(ServerList.getMaxId())  -- maxOnlineID
    body = body .. PacketUtils.writeUInt32BE(isVIP)                   -- isVIP
    body = body .. PacketUtils.writeUInt32BE(#servers)                -- onlineCnt
    
    -- ServerInfo.as 解析顺序 (每个服务器30字节):
    -- 1. onlineID (4字节)
    -- 2. userCnt (4字节)
    -- 3. ip (16字节, null-terminated string)
    -- 4. port (2字节)
    -- 5. friends (4字节)
    
    for _, srv in ipairs(servers) do
        -- onlineID
        body = body .. PacketUtils.writeUInt32BE(srv.id)
        
        -- userCnt (在线人数)
        local userCnt = ServerList.getOnlineCount(srv.id)
        body = body .. PacketUtils.writeUInt32BE(userCnt)
        
        -- IP地址 (16字节，不足补0)
        local ip = srv.ip or "127.0.0.1"
        body = body .. PacketUtils.writeFixedString(ip, 16)
        
        -- port (2字节)
        body = body .. PacketUtils.writeUInt16BE(srv.port or 5000)
        
        -- friends (好友在此服务器数量)
        body = body .. PacketUtils.writeUInt32BE(0)
    end
    
    -- friendData 部分
    -- CommendSvrInfo 会保存剩余数据作为 friendData
    -- 这部分数据会传递给 Login.dispatch() 和后续的 RelationManager
    -- 简化处理：只写入空的好友列表和黑名单
    body = body .. PacketUtils.writeUInt32BE(0)  -- friends count
    body = body .. PacketUtils.writeUInt32BE(0)  -- blacklist count
    
    return body
end

-- 构建 CMD 106 (RANGE_ONLINE) 响应的 body 数据
-- 用于获取指定范围的服务器列表
function ServerList.buildRangeOnlineBody(startId, endId)
    local body = ""
    
    local function writeUInt32BE(value)
        return string.char(
            math.floor(value / 16777216) % 256,
            math.floor(value / 65536) % 256,
            math.floor(value / 256) % 256,
            value % 256
        )
    end
    
    local function writeUInt16BE(value)
        return string.char(
            math.floor(value / 256) % 256,
            value % 256
        )
    end
    
    -- 筛选指定范围的服务器
    local filteredServers = {}
    for _, srv in ipairs(ServerList.getAll()) do
        if srv.id >= startId and srv.id <= endId then
            table.insert(filteredServers, srv)
        end
    end
    
    -- RangeSvrInfo.as 解析格式:
    -- 1. onlineCnt (4字节)
    -- 2. 服务器列表
    
    body = body .. writeUInt32BE(#filteredServers)
    
    for _, srv in ipairs(filteredServers) do
        body = body .. writeUInt32BE(srv.id)
        body = body .. writeUInt32BE(ServerList.getOnlineCount(srv.id))
        
        local ip = srv.ip or "127.0.0.1"
        for i = 1, 16 do
            if i <= #ip then
                body = body .. ip:sub(i, i)
            else
                body = body .. "\0"
            end
        end
        
        body = body .. writeUInt16BE(srv.port or 5000)
        body = body .. writeUInt32BE(0)  -- friends
    end
    
    return body
end

-- 初始化模块
ServerList.init()

return ServerList
