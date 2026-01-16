-- Login Server (TrafficLogger Mode)
-- TCP Socket 代理到官服，记录所有流量
-- 客户端 TCP -> 本地代理 -> 官服 TCP

local net = require "net"
local fs = require "fs"
local json = require "json"

-- 从 Logger 模块获取 tprint
local Logger = require('../logger')
local tprint = Logger.tprint

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
    tprint("\27[36m[服务器列表] 处理 CMD 105 响应\27[0m")
    local bytes = {}
    for i = 1, #data do bytes[i] = data:byte(i) end
    
    local headerSize = 17
    local maxOnlineID = (bytes[headerSize + 1] or 0) * 16777216 + (bytes[headerSize + 2] or 0) * 65536 + 
                        (bytes[headerSize + 3] or 0) * 256 + (bytes[headerSize + 4] or 0)
    local isVIP = (bytes[headerSize + 5] or 0) * 16777216 + (bytes[headerSize + 6] or 0) * 65536 + 
                  (bytes[headerSize + 7] or 0) * 256 + (bytes[headerSize + 8] or 0)
    local serverCount = (bytes[headerSize + 9] or 0) * 16777216 + (bytes[headerSize + 10] or 0) * 65536 + 
                        (bytes[headerSize + 11] or 0) * 256 + (bytes[headerSize + 12] or 0)
    
    tprint(string.format("\27[36m[服务器列表] maxOnlineID=%d, isVIP=%d, 服务器数量=%d\27[0m", maxOnlineID, isVIP, serverCount))
    
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
            
            local isLocalServer = currentIP:match("^127%.") or currentIP:match("^localhost")
            
            if onlineID > 0 and currentIP ~= "" and currentPort > 0 then
                local localPort = 5000 + (onlineID % 1000)
                
                if isLocalServer then
                    tprint(string.format("\27[33m[服务器列表] #%d: ID=%d, 人数=%d, %s:%d (本地服务器，跳过代理)\27[0m", 
                        i+1, onlineID, userCnt, currentIP, currentPort))
                else
                    tprint(string.format("\27[36m[服务器列表] #%d: ID=%d, 人数=%d, %s:%d -> 127.0.0.1:%d\27[0m", 
                        i+1, onlineID, userCnt, currentIP, currentPort, localPort))
                    
                    _G.serverMapping[onlineID] = { ip = currentIP, port = currentPort, localPort = localPort }
                    _G.portToServer = _G.portToServer or {}
                    _G.portToServer[localPort] = { id = onlineID, ip = currentIP, port = currentPort }
                    table.insert(_G.lastServerList, { id = onlineID, ip = currentIP, port = currentPort, localPort = localPort })
                    
                    if _G.createGameServerForPort then 
                        _G.createGameServerForPort(localPort, currentIP, currentPort, onlineID) 
                    end
                    
                    local newIP = "127.0.0.1"
                    for j = 1, 16 do 
                        bytes[ipStart + j - 1] = j <= #newIP and newIP:byte(j) or 0 
                    end
                    
                    bytes[portStart] = math.floor(localPort / 256)
                    bytes[portStart + 1] = localPort % 256
                end
            end
        end
    end
    
    tprint(string.format("\27[35m[服务器列表] 总计映射 %d 个服务器\27[0m", #_G.lastServerList))
    return string.char(table.unpack(bytes))
end

-- TCP 代理服务器
local server = net.createServer(function(client)
    local clientAddr = client:address()
    tprint(string.format("\27[36m[LOGIN-PROXY] 新客户端连接: %s\27[0m", clientAddr and clientAddr.ip or "unknown"))
    
    local officialConn = nil
    local clientClosed = false
    local officialClosed = false
    local officialConnected = false
    local clientBuffer = ""
    local officialBuffer = ""
    
    local targetHost = conf.official_login_server or "115.238.192.7"
    local targetPort = conf.official_login_port or 9999
    
    tprint(string.format("\27[36m[LOGIN-PROXY] 连接官服 TCP %s:%d...\27[0m", targetHost, targetPort))
    
    officialConn = net.createConnection(targetPort, targetHost, function(err)
        if err then
            tprint("\27[31m[LOGIN-PROXY] 连接官服失败: " .. tostring(err) .. "\27[0m")
            pcall(function() client:destroy() end)
            return
        end
        
        officialConnected = true
        tprint(string.format("\27[32m[LOGIN-PROXY] OK 已连接到官服 %s:%d\27[0m", targetHost, targetPort))
        
        officialConn:on("data", function(data)
            if clientClosed then return end
            
            officialBuffer = officialBuffer .. data
            
            while #officialBuffer >= 4 do
                local packetLen = officialBuffer:byte(1)*16777216 + officialBuffer:byte(2)*65536 + 
                                  officialBuffer:byte(3)*256 + officialBuffer:byte(4)
                
                if #officialBuffer < packetLen then
                    break
                end
                
                local packet = officialBuffer:sub(1, packetLen)
                officialBuffer = officialBuffer:sub(packetLen + 1)
                
                local header = parsePacketHeader(packet)
                local modified = packet
                
                if header then
                    if not shouldHideCmd(header.cmdId) then
                        tprint(string.format("\27[33m[<-官服] CMD %d (%s) UID=%d RES=%d LEN=%d\27[0m", 
                            header.cmdId, getCmdName(header.cmdId), header.userId, header.result, header.length))
                    end
                    
                    logTraffic("server_to_client", header.cmdId, header.userId, packet)
                    
                    if header.cmdId == 105 and conf.proxy_game_server then
                        modified = processServerList(packet)
                    end
                    
                    if header.cmdId == 3 and header.result == 0 then
                        local verifyCode = ""
                        for i = 18, math.min(49, #packet) do
                            local b = packet:byte(i)
                            if b and b > 0 then
                                verifyCode = verifyCode .. string.char(b)
                            end
                        end
                        tprint(string.format("\27[32m[LOGIN] 邮箱验证码: %s\27[0m", verifyCode))
                    end
                    
                    if header.cmdId == 104 and header.result == 0 then
                        local sessionHex = ""
                        for i = 18, math.min(33, #packet) do
                            sessionHex = sessionHex .. string.format("%02X", packet:byte(i) or 0)
                        end
                        local roleCreate = 0
                        if #packet >= 37 then
                            roleCreate = (packet:byte(34) or 0) * 16777216 + (packet:byte(35) or 0) * 65536 + 
                                        (packet:byte(36) or 0) * 256 + (packet:byte(37) or 0)
                        end
                        tprint(string.format("\27[32m[LOGIN] 登录成功! UID=%d Session=%s Role=%s\27[0m", 
                            header.userId, sessionHex, roleCreate == 1 and "已创建" or "未创建"))
                    end
                end
                
                pcall(function() client:write(modified) end)
            end
        end)
        
        officialConn:on("error", function(err)
            tprint("\27[31m[LOGIN-PROXY] 官服连接错误: " .. tostring(err) .. "\27[0m")
            officialClosed = true
            if not clientClosed then 
                pcall(function() client:destroy() end) 
            end
        end)
        
        officialConn:on("end", function()
            tprint("\27[33m[LOGIN-PROXY] 官服断开连接\27[0m")
            officialClosed = true
            if not clientClosed then 
                pcall(function() client:destroy() end) 
            end
        end)
        
        if #clientBuffer > 0 then
            tprint(string.format("\27[36m[LOGIN-PROXY] 发送缓存数据到官服: %d bytes\27[0m", #clientBuffer))
            officialConn:write(clientBuffer)
            clientBuffer = ""
        end
    end)
    
    client:on("data", function(data)
        if officialClosed then return end
        
        if data == "<policy-file-request/>\000" then
            tprint("\27[36m[LOGIN-PROXY] Flash 策略文件请求\27[0m")
            client:write(policy_file)
            return
        end
        
        if not officialConnected then
            clientBuffer = clientBuffer .. data
            tprint(string.format("\27[33m[LOGIN-PROXY] 缓存数据等待连接: %d bytes\27[0m", #clientBuffer))
            return
        end
        
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
                    tprint(string.format("\27[35m[->官服] CMD %d (%s) UID=%d LEN=%d\27[0m", 
                        header.cmdId, getCmdName(header.cmdId), header.userId, header.length))
                end
                
                logTraffic("client_to_server", header.cmdId, header.userId, packet)
            end
        end
        
        pcall(function() officialConn:write(data) end)
    end)
    
    client:on("error", function(err)
        tprint("\27[31m[LOGIN-PROXY] 客户端错误: " .. tostring(err) .. "\27[0m")
        clientClosed = true
        if officialConn then 
            pcall(function() officialConn:destroy() end) 
        end
    end)
    
    client:on("end", function()
        tprint("\27[33m[LOGIN-PROXY] 客户端断开连接\27[0m")
        clientClosed = true
        if officialConn then 
            pcall(function() officialConn:destroy() end) 
        end
    end)
end)

server:on('error', function(err)
    if err then 
        tprint("\27[31m[LOGIN-PROXY] 服务器错误: " .. tostring(err) .. "\27[0m") 
    end
end)

server:listen(conf.login_port)

tprint("\27[36m[LOGIN-PROXY] 登录代理服务器已启动 port=" .. conf.login_port .. "\27[0m")
