-- Login Server (TrafficLogger Mode)
-- TCP Socket 代理到官服，记录所有流量
-- 客户端 TCP → 本地代理 → 官服 TCP

local net = require "net"
local fs = require "fs"
local json = require "json"

-- 加载赛尔号命令映射
local SeerCommands = require('../seer_commands')
-- 加载统一日志模块
local Logger = require('../logger')

local function getCmdName(cmdId)
    return SeerCommands.getName(cmdId)
end

-- 检查命令是否应该被隐藏
local function shouldHideCmd(cmdId)
    if not conf.hide_frequent_cmds then
        return false
    end
    for _, hideCmdId in ipairs(conf.hide_cmd_list or {}) do
        if cmdId == hideCmdId then
            return true
        end
    end
    return false
end

-- 流量日志
local trafficLog = {}
local sessionId = os.date("%Y%m%d_%H%M%S")

local function toHex(data)
    local hex = {}
    for i = 1, math.min(#data, 200) do
        hex[i] = string.format("%02X", data:byte(i))
    end
    if #data > 200 then
        table.insert(hex, "...")
    end
    return table.concat(hex, " ")
end

local function logTraffic(direction, cmdId, userId, data)
    local entry = {
        time = os.date("%Y-%m-%d %H:%M:%S"),
        direction = direction,
        cmdId = cmdId,
        cmdName = getCmdName(cmdId),
        userId = userId,
        length = #data,
    }
    
    table.insert(trafficLog, entry)
    
    -- 记录到统一日志文件
    if direction == "client_to_server" then
        Logger.logOfficialSend(cmdId, getCmdName(cmdId), userId, #data, data)
    else
        local result = 0
        if #data >= 17 then
            result = data:byte(14)*16777216 + data:byte(15)*65536 + data:byte(16)*256 + data:byte(17)
        end
        Logger.logOfficialRecv(cmdId, getCmdName(cmdId), userId, result, #data, data)
    end
    
    -- 每 100 条保存一次到 JSON
    if #trafficLog % 100 == 0 then
        pcall(function()
            local logDir = "sessionlog"
            if not fs.existsSync(logDir) then
                fs.mkdirSync(logDir)
            end
            local filename = logDir .. "/login_" .. sessionId .. ".json"
            fs.writeFileSync(filename, json.stringify(trafficLog))
        end)
    end
end

local policy_file = '<?xml version="1.0"?><!DOCTYPE cross-domain-policy><cross-domain-policy><allow-access-from domain="*" to-ports="*" /></cross-domain-policy>\000'

-- 服务器映射（用于游戏服务器代理）
_G.serverMapping = _G.serverMapping or {}
_G.lastServerList = _G.lastServerList or {}

local function parsePacketHeader(data)
    if #data < 17 then return nil end
    return {
        length = data:byte(1)*16777216 + data:byte(2)*65536 + data:byte(3)*256 + data:byte(4),
        version = data:byte(5),
        cmdId = data:byte(6)*16777216 + data:byte(7)*65536 + data:byte(8)*256 + data:byte(9),
        userId = data:byte(10)*16777216 + data:byte(11)*65536 + data:byte(12)*256 + data:byte(13),
        result = data:byte(14)*16777216 + data:byte(15)*65536 + data:byte(16)*256 + data:byte(17)
    }
end

-- 处理服务器列表响应 (CMD 105)
local function processServerList(data)
    print("\27[36m[服务器列表] 处理 CMD 105 响应\27[0m")
    local bytes = {}
    for i = 1, #data do bytes[i] = data:byte(i) end
    
    -- CMD 105 响应结构:
    -- 17 字节头部
    -- 4 字节 maxOnlineID
    -- 4 字节 isVIP
    -- 4 字节 onlineCnt (服务器数量)
    -- 然后是 onlineCnt 个 ServerInfo (每个 30 字节)
    
    local headerSize = 17
    local maxOnlineID = (bytes[headerSize + 1] or 0) * 16777216 + (bytes[headerSize + 2] or 0) * 65536 + 
                        (bytes[headerSize + 3] or 0) * 256 + (bytes[headerSize + 4] or 0)
    local isVIP = (bytes[headerSize + 5] or 0) * 16777216 + (bytes[headerSize + 6] or 0) * 65536 + 
                  (bytes[headerSize + 7] or 0) * 256 + (bytes[headerSize + 8] or 0)
    local serverCount = (bytes[headerSize + 9] or 0) * 16777216 + (bytes[headerSize + 10] or 0) * 65536 + 
                        (bytes[headerSize + 11] or 0) * 256 + (bytes[headerSize + 12] or 0)
    
    print(string.format("\27[36m[服务器列表] maxOnlineID=%d, isVIP=%d, 服务器数量=%d\27[0m", maxOnlineID, isVIP, serverCount))
    
    local serverStart = headerSize + 12 + 1
    local serverSize = 30
    
    _G.lastServerList = {}
    
    for i = 0, serverCount - 1 do
        local offset = serverStart + (i * serverSize)
        
        if offset + serverSize - 1 <= #bytes then
            local onlineID = (bytes[offset] or 0) * 16777216 + (bytes[offset+1] or 0) * 65536 + 
                            (bytes[offset+2] or 0) * 256 + (bytes[offset+3] or 0)
            local userCnt = (bytes[offset+4] or 0) * 16777216 + (bytes[offset+5] or 0) * 65536 + 
                           (bytes[offset+6] or 0) * 256 + (bytes[offset+7] or 0)
            
            local ipStart = offset + 8
            local currentIP = ""
            for j = 0, 15 do 
                local b = bytes[ipStart + j]
                if b and b > 0 then 
                    currentIP = currentIP .. string.char(b) 
                end 
            end
            
            local portStart = offset + 24
            local currentPort = (bytes[portStart] or 0) * 256 + (bytes[portStart + 1] or 0)
            
            if onlineID > 0 and currentIP ~= "" and currentPort > 0 then
                local localPort = 5000 + (onlineID % 1000)
                print(string.format("\27[36m[服务器列表] #%d: ID=%d, 人数=%d, %s:%d -> 127.0.0.1:%d\27[0m", 
                    i+1, onlineID, userCnt, currentIP, currentPort, localPort))
                
                _G.serverMapping[onlineID] = { ip = currentIP, port = currentPort, localPort = localPort }
                _G.portToServer = _G.portToServer or {}
                _G.portToServer[localPort] = { id = onlineID, ip = currentIP, port = currentPort }
                table.insert(_G.lastServerList, { id = onlineID, ip = currentIP, port = currentPort, localPort = localPort })
                
                -- 创建游戏服务器代理
                if _G.createGameServerForPort then 
                    _G.createGameServerForPort(localPort, currentIP, currentPort, onlineID) 
                end
                
                -- 替换 IP 为本地代理地址
                local newIP = "127.0.0.1"
                for j = 1, 16 do 
                    bytes[ipStart + j - 1] = j <= #newIP and newIP:byte(j) or 0 
                end
                
                -- 替换端口为本地代理端口
                bytes[portStart] = math.floor(localPort / 256)
                bytes[portStart + 1] = localPort % 256
            end
        end
    end
    
    print(string.format("\27[35m[服务器列表] 总计映射 %d 个服务器\27[0m", #_G.lastServerList))
    return string.char(table.unpack(bytes))
end

-- TCP 代理服务器
local server = net.createServer(function(client)
    local clientAddr = client:address()
    print(string.format("\27[36m[LOGIN-PROXY] 新客户端连接: %s\27[0m", clientAddr and clientAddr.ip or "unknown"))
    
    local officialConn = nil
    local clientClosed = false
    local officialClosed = false
    local officialConnected = false  -- 新增：标记是否真正连接成功
    local clientBuffer = ""
    local officialBuffer = ""
    
    -- 连接到官服
    local targetHost = conf.official_login_server or "115.238.192.7"
    local targetPort = conf.official_login_port or 9999
    
    print(string.format("\27[36m[LOGIN-PROXY] 连接官服 TCP %s:%d...\27[0m", targetHost, targetPort))
    
    officialConn = net.createConnection(targetPort, targetHost, function(err)
        if err then
            print("\27[31m[LOGIN-PROXY] 连接官服失败: " .. tostring(err) .. "\27[0m")
            pcall(function() client:destroy() end)
            return
        end
        
        officialConnected = true  -- 标记连接成功
        print(string.format("\27[32m[LOGIN-PROXY] ✓ 已连接到官服 %s:%d\27[0m", targetHost, targetPort))
        
        -- 官服数据处理
        officialConn:on("data", function(data)
            if clientClosed then return end
            
            officialBuffer = officialBuffer .. data
            
            -- 解析完整的数据包
            while #officialBuffer >= 4 do
                local packetLen = officialBuffer:byte(1)*16777216 + officialBuffer:byte(2)*65536 + 
                                  officialBuffer:byte(3)*256 + officialBuffer:byte(4)
                
                if #officialBuffer < packetLen then
                    break  -- 等待更多数据
                end
                
                local packet = officialBuffer:sub(1, packetLen)
                officialBuffer = officialBuffer:sub(packetLen + 1)
                
                local header = parsePacketHeader(packet)
                local modified = packet
                
                if header then
                    if not shouldHideCmd(header.cmdId) then
                        print(string.format("\27[33m╔══════════════════════════════════════════════════════════════╗\27[0m"))
                        print(string.format("\27[33m║ [官服→客户端] CMD=%d (%s)\27[0m", header.cmdId, getCmdName(header.cmdId)))
                        print(string.format("\27[33m╚══════════════════════════════════════════════════════════════╝\27[0m"))
                        print(string.format("\27[33m[官服→客户端] UID=%d, RESULT=%d, 长度=%d bytes\27[0m", 
                            header.userId, header.result, header.length))
                        print(string.format("\27[33m[官服→客户端] HEX: %s\27[0m", toHex(packet)))
                    end
                    
                    logTraffic("server_to_client", header.cmdId, header.userId, packet)
                    
                    -- 处理服务器列表（替换IP为本地代理）
                    if header.cmdId == 105 and conf.proxy_game_server then
                        modified = processServerList(packet)
                    end
                    
                    -- 解析 CMD 3 响应（邮箱验证码）
                    if header.cmdId == 3 and header.result == 0 then
                        -- 验证码在 body 里，从第18字节开始，32字节
                        local verifyCode = ""
                        for i = 18, math.min(49, #packet) do
                            local b = packet:byte(i)
                            if b and b > 0 then
                                verifyCode = verifyCode .. string.char(b)
                            end
                        end
                        print(string.format("\27[32m╔══════════════════════════════════════════════════════════════╗\27[0m"))
                        print(string.format("\27[32m║ 📧 邮箱验证码: %s\27[0m", verifyCode))
                        print(string.format("\27[32m╚══════════════════════════════════════════════════════════════╝\27[0m"))
                    end
                end
                
                -- 发送给客户端
                pcall(function() client:write(modified) end)
            end
        end)
        
        officialConn:on("error", function(err)
            print("\27[31m[LOGIN-PROXY] 官服连接错误: " .. tostring(err) .. "\27[0m")
            officialClosed = true
            if not clientClosed then 
                pcall(function() client:destroy() end) 
            end
        end)
        
        officialConn:on("end", function()
            print("\27[33m[LOGIN-PROXY] 官服断开连接\27[0m")
            officialClosed = true
            if not clientClosed then 
                pcall(function() client:destroy() end) 
            end
        end)
        
        -- 如果有缓存的客户端数据，发送到官服
        if #clientBuffer > 0 then
            print(string.format("\27[36m[LOGIN-PROXY] 发送缓存数据到官服: %d bytes\27[0m", #clientBuffer))
            officialConn:write(clientBuffer)
            clientBuffer = ""
        end
    end)
    
    -- 客户端数据处理
    client:on("data", function(data)
        if officialClosed then return end
        
        -- Flash 策略文件请求
        if data == "<policy-file-request/>\000" then
            print("\27[36m[LOGIN-PROXY] Flash 策略文件请求\27[0m")
            client:write(policy_file)
            return
        end
        
        -- 如果官服还没连接好，先缓存
        if not officialConn or officialClosed then
            clientBuffer = clientBuffer .. data
            return
        end
        
        -- 解析并记录数据包
        local tempBuffer = data
        while #tempBuffer >= 4 do
            local packetLen = tempBuffer:byte(1)*16777216 + tempBuffer:byte(2)*65536 + 
                              tempBuffer:byte(3)*256 + tempBuffer:byte(4)
            
            if #tempBuffer < packetLen then
                break
            end
            
            local packet = tempBuffer:sub(1, packetLen)
            tempBuffer = tempBuffer:sub(packetLen + 1)
            
            local header = parsePacketHeader(packet)
            if header then
                if not shouldHideCmd(header.cmdId) then
                    print(string.format("\27[35m╔══════════════════════════════════════════════════════════════╗\27[0m"))
                    print(string.format("\27[35m║ [客户端→官服] CMD=%d (%s)\27[0m", header.cmdId, getCmdName(header.cmdId)))
                    print(string.format("\27[35m╚══════════════════════════════════════════════════════════════╝\27[0m"))
                    print(string.format("\27[35m[客户端→官服] UID=%d, 长度=%d bytes\27[0m", header.userId, header.length))
                    print(string.format("\27[35m[客户端→官服] HEX: %s\27[0m", toHex(packet)))
                end
                
                logTraffic("client_to_server", header.cmdId, header.userId, packet)
            end
        end
        
        -- 转发原始数据到官服
        pcall(function() officialConn:write(data) end)
    end)
    
    client:on("error", function(err)
        print("\27[31m[LOGIN-PROXY] 客户端错误: " .. tostring(err) .. "\27[0m")
        clientClosed = true
        if officialConn then 
            pcall(function() officialConn:destroy() end) 
        end
    end)
    
    client:on("end", function()
        print("\27[33m[LOGIN-PROXY] 客户端断开连接\27[0m")
        clientClosed = true
        if officialConn then 
            pcall(function() officialConn:destroy() end) 
        end
    end)
end)

server:on('error', function(err)
    if err then 
        print("\27[31m[LOGIN-PROXY] 服务器错误: " .. tostring(err) .. "\27[0m") 
    end
end)

server:listen(conf.login_port)

print("\27[36m╔══════════════════════════════════════════════════════════════╗\27[0m")
print("\27[36m║ TrafficLogger 登录代理服务器已启动                           ║\27[0m")
print("\27[36m╠══════════════════════════════════════════════════════════════╣\27[0m")
print(string.format("\27[36m║ 本地: tcp://127.0.0.1:%d                                    ║\27[0m", conf.login_port))
print(string.format("\27[36m║ 官服: tcp://%s:%d                              ║\27[0m", 
    conf.official_login_server or "115.238.192.7", conf.official_login_port or 9999))
print("\27[36m║ 协议: TCP Socket (原始二进制)                                ║\27[0m")
print("\27[36m╚══════════════════════════════════════════════════════════════╝\27[0m")
