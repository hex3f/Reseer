-- 官服房间代理服务器
-- 监听 5100 端口，转发所有数据到官服房间服务器

local net = require('net')
local Logger = require('../core/logger')
local tprint = Logger.tprint

local RoomProxy = {}
RoomProxy.__index = RoomProxy

function RoomProxy:new(port)
    local obj = {
        port = port or 5100,
        clients = {},
    }
    setmetatable(obj, RoomProxy)
    obj:start()
    return obj
end

function RoomProxy:start()
    local server = net.createServer(function(client)
        local clientAddr = "unknown"
        local clientPort = 0
        pcall(function()
            local addr = client:address()
            if addr then
                clientAddr = addr.ip or "unknown"
                clientPort = addr.port or 0
            end
        end)
        tprint(string.format("\27[35m[RoomProxy] 新客户端连接: %s:%d\27[0m", clientAddr, clientPort))
        
        -- 获取官服房间服务器地址
        local officialRoom = _G.officialRoomServer
        if not officialRoom or not officialRoom.ip or not officialRoom.port then
            tprint("\27[31m[RoomProxy] 错误: 未找到官服房间服务器地址\27[0m")
            client:destroy()
            return
        end
        
        tprint(string.format("\27[36m[RoomProxy] 连接到官服房间服务器: %s:%d\27[0m", 
            officialRoom.ip, officialRoom.port))
        
        -- 连接到官服房间服务器
        local officialClient = net.createConnection(officialRoom.port, officialRoom.ip, function()
            tprint("\27[32m[RoomProxy] ✓ 已连接到官服房间服务器\27[0m")
        end)
        
        local clientData = {
            client = client,
            official = officialClient,
            buffer = "",
        }
        table.insert(self.clients, clientData)
        
        -- 客户端 -> 官服
        client:on('data', function(data)
            if officialClient then
                local success, err = pcall(function() officialClient:write(data) end)
                if success then
                    -- 打印前32字节的hex
                    local hexStr = ""
                    for i = 1, math.min(#data, 32) do
                        hexStr = hexStr .. string.format("%02X ", data:byte(i))
                    end
                    tprint(string.format("\27[90m[RoomProxy] 客户端 → 官服: %d bytes\27[0m", #data))
                    tprint(string.format("\27[90m[RoomProxy]   HEX: %s\27[0m", hexStr))
                else
                    tprint(string.format("\27[31m[RoomProxy] 转发到官服失败: %s\27[0m", tostring(err)))
                end
            else
                tprint("\27[31m[RoomProxy] 官服连接不可用\27[0m")
            end
        end)
        
        -- 官服 -> 客户端
        officialClient:on('data', function(data)
            if client then
                local success, err = pcall(function() client:write(data) end)
                if success then
                    tprint(string.format("\27[90m[RoomProxy] 官服 → 客户端: %d bytes\27[0m", #data))
                else
                    tprint(string.format("\27[31m[RoomProxy] 转发到客户端失败: %s\27[0m", tostring(err)))
                end
            else
                tprint("\27[31m[RoomProxy] 客户端连接不可用\27[0m")
            end
        end)
        
        -- 错误处理
        client:on('end', function()
            tprint("\27[35m[RoomProxy] 客户端断开连接\27[0m")
            if officialClient then
                pcall(function() officialClient:destroy() end)
            end
            self:removeClient(clientData)
        end)
        
        client:on('error', function(err)
            tprint("\27[31m[RoomProxy] 客户端错误: " .. tostring(err) .. "\27[0m")
            if officialClient then
                pcall(function() officialClient:destroy() end)
            end
            self:removeClient(clientData)
        end)
        
        officialClient:on('end', function()
            tprint("\27[35m[RoomProxy] 官服断开连接\27[0m")
            if client then
                pcall(function() client:destroy() end)
            end
            self:removeClient(clientData)
        end)
        
        officialClient:on('error', function(err)
            tprint("\27[31m[RoomProxy] 官服连接错误: " .. tostring(err) .. "\27[0m")
            if client then
                pcall(function() client:destroy() end)
            end
            self:removeClient(clientData)
        end)
    end)
    
    server:listen(self.port, "0.0.0.0", function()
        tprint(string.format("\27[35m[RoomProxy] 房间代理服务器启动在端口 %d\27[0m", self.port))
    end)
    
    server:on('error', function(err)
        tprint("\27[31m[RoomProxy] 服务器错误: " .. tostring(err) .. "\27[0m")
    end)
end

function RoomProxy:removeClient(clientData)
    for i, c in ipairs(self.clients) do
        if c == clientData then
            table.remove(self.clients, i)
            break
        end
    end
end

return RoomProxy
