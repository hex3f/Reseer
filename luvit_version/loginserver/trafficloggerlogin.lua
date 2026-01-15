-- Login Server (TrafficLogger Mode)
-- 支持 WebSocket 代理到官服
-- 客户端 WebSocket → 本地代理 → 官服 WebSocket

local net = require "net"
local bit = require "../bitop_compat"
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

local function logTraffic(direction, cmdId, userId, data)
    local entry = {
        time = os.date("%Y-%m-%d %H:%M:%S"),
        direction = direction,
        cmdId = cmdId,
        cmdName = getCmdName(cmdId),
        userId = userId,
        length = #data,
        hex = ""
    }
    
    -- 转换为 hex（完整，不截断）
    local hex = {}
    for i = 1, #data do
        hex[i] = string.format("%02X", data:byte(i))
    end
    entry.hex = table.concat(hex, " ")
    
    table.insert(trafficLog, entry)
    
    -- 记录到统一日志文件
    if direction == "client_to_server" then
        Logger.logOfficialSend(cmdId, getCmdName(cmdId), userId, #data, data)
    else
        -- 解析 result
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

_G.serverMapping = _G.serverMapping or {}
_G.lastServerList = _G.lastServerList or {}

-- Base64 编码
local function base64_encode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- SHA1 实现
local function sha1(msg)
    local function lrotate(a, n) return bit.bor(bit.lshift(a, n), bit.rshift(a, 32 - n)) end
    local h0, h1, h2, h3, h4 = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0
    local msgLen = #msg
    local padLen = 64 - ((msgLen + 9) % 64)
    if padLen == 64 then padLen = 0 end
    msg = msg .. "\128" .. string.rep("\0", padLen) .. string.char(0, 0, 0, 0,
        bit.rshift(msgLen * 8, 24) % 256, bit.rshift(msgLen * 8, 16) % 256,
        bit.rshift(msgLen * 8, 8) % 256, (msgLen * 8) % 256)
    for i = 1, #msg, 64 do
        local chunk = msg:sub(i, i + 63)
        local w = {}
        for j = 1, 16 do
            local idx = (j - 1) * 4 + 1
            w[j] = bit.lshift(chunk:byte(idx), 24) + bit.lshift(chunk:byte(idx + 1), 16) +
                   bit.lshift(chunk:byte(idx + 2), 8) + chunk:byte(idx + 3)
        end
        for j = 17, 80 do w[j] = lrotate(bit.bxor(bit.bxor(w[j-3], w[j-8]), bit.bxor(w[j-14], w[j-16])), 1) end
        local a, b, c, d, e = h0, h1, h2, h3, h4
        for j = 1, 80 do
            local f, k
            if j <= 20 then f = bit.bor(bit.band(b, c), bit.band(bit.bnot(b), d)); k = 0x5A827999
            elseif j <= 40 then f = bit.bxor(bit.bxor(b, c), d); k = 0x6ED9EBA1
            elseif j <= 60 then f = bit.bor(bit.bor(bit.band(b, c), bit.band(b, d)), bit.band(c, d)); k = 0x8F1BBCDC
            else f = bit.bxor(bit.bxor(b, c), d); k = 0xCA62C1D6 end
            local temp = bit.band(lrotate(a, 5) + f + e + k + w[j], 0xFFFFFFFF)
            e, d, c, b, a = d, c, lrotate(b, 30), a, temp
        end
        h0, h1, h2, h3, h4 = bit.band(h0+a, 0xFFFFFFFF), bit.band(h1+b, 0xFFFFFFFF), 
            bit.band(h2+c, 0xFFFFFFFF), bit.band(h3+d, 0xFFFFFFFF), bit.band(h4+e, 0xFFFFFFFF)
    end
    return string.char(bit.rshift(h0,24)%256, bit.rshift(h0,16)%256, bit.rshift(h0,8)%256, h0%256,
        bit.rshift(h1,24)%256, bit.rshift(h1,16)%256, bit.rshift(h1,8)%256, h1%256,
        bit.rshift(h2,24)%256, bit.rshift(h2,16)%256, bit.rshift(h2,8)%256, h2%256,
        bit.rshift(h3,24)%256, bit.rshift(h3,16)%256, bit.rshift(h3,8)%256, h3%256,
        bit.rshift(h4,24)%256, bit.rshift(h4,16)%256, bit.rshift(h4,8)%256, h4%256)
end

-- 生成随机 WebSocket Key (16 随机字节的 base64 编码)
local function generateWebSocketKey()
    local bytes = {}
    for i = 1, 16 do
        bytes[i] = string.char(math.random(0, 255))
    end
    return base64_encode(table.concat(bytes))
end

local function parseWebSocketHandshake(data)
    if not data:match("^GET ") then return nil end
    local key = data:match("Sec%-WebSocket%-Key: ([^\r\n]+)")
    return key and { key = key } or nil
end

local function generateWebSocketResponse(key)
    return "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: " ..
           base64_encode(sha1(key .. "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")) .. "\r\n\r\n"
end

local function decodeWebSocketFrame(data)
    if #data < 2 then return nil, nil, data end
    local byte1, byte2 = data:byte(1), data:byte(2)
    local opcode = byte1 % 16
    local masked = math.floor(byte2 / 128) % 2 == 1
    local payloadLen = byte2 % 128
    local headerLen = 2
    if payloadLen == 126 then
        if #data < 4 then return nil, nil, data end
        payloadLen = data:byte(3) * 256 + data:byte(4); headerLen = 4
    elseif payloadLen == 127 then
        if #data < 10 then return nil, nil, data end
        payloadLen = 0; for i = 3, 10 do payloadLen = payloadLen * 256 + data:byte(i) end; headerLen = 10
    end
    local maskKey = nil
    if masked then
        if #data < headerLen + 4 then return nil, nil, data end
        maskKey = data:sub(headerLen + 1, headerLen + 4); headerLen = headerLen + 4
    end
    if #data < headerLen + payloadLen then return nil, nil, data end
    local payload = data:sub(headerLen + 1, headerLen + payloadLen)
    local remaining = data:sub(headerLen + payloadLen + 1)
    if masked and maskKey then
        local unmasked = {}
        for i = 1, #payload do unmasked[i] = string.char(bit.bxor(payload:byte(i), maskKey:byte(((i-1)%4)+1))) end
        payload = table.concat(unmasked)
    end
    return opcode, payload, remaining
end

-- 编码 WebSocket 帧（带 mask，用于发送到服务器）
local function encodeWebSocketFrameMasked(data, opcode)
    opcode = opcode or 0x02
    local len = #data
    local header
    if len <= 125 then 
        header = string.char(0x80 + opcode, 0x80 + len)  -- 0x80 表示有 mask
    elseif len <= 65535 then 
        header = string.char(0x80 + opcode, 0x80 + 126, math.floor(len / 256), len % 256)
    else 
        header = string.char(0x80 + opcode, 0x80 + 127, 0, 0, 0, 0, 
            math.floor(len/16777216)%256, math.floor(len/65536)%256, 
            math.floor(len/256)%256, len%256) 
    end
    -- 生成随机 mask key
    local maskKey = string.char(math.random(0, 255), math.random(0, 255), 
                                math.random(0, 255), math.random(0, 255))
    -- 对数据进行 mask
    local masked = {}
    for i = 1, #data do
        masked[i] = string.char(bit.bxor(data:byte(i), maskKey:byte(((i-1)%4)+1)))
    end
    return header .. maskKey .. table.concat(masked)
end

-- 编码 WebSocket 帧（不带 mask，用于发送到客户端）
local function encodeWebSocketFrame(data, opcode)
    opcode = opcode or 0x02
    local len = #data
    local header
    if len <= 125 then header = string.char(0x80 + opcode, len)
    elseif len <= 65535 then header = string.char(0x80 + opcode, 126, math.floor(len / 256), len % 256)
    else header = string.char(0x80 + opcode, 127, 0, 0, 0, 0, math.floor(len/16777216)%256, math.floor(len/65536)%256, math.floor(len/256)%256, len%256) end
    return header .. data
end

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

local function toHex(data)
    local hex = {}
    for i = 1, #data do
        hex[i] = string.format("%02X", data:byte(i))
    end
    return table.concat(hex, " ")
end

-- 处理服务器列表响应
local function processServerList(data)
    print("\27[36m[服务器列表] 处理 CMD 105 响应\27[0m")
    local bytes = {}
    for i = 1, #data do bytes[i] = data:byte(i) end
    
    -- CMD 105 响应结构:
    -- 17 字节头部: length(4) + version(1) + cmdId(4) + userId(4) + result(4)
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
    
    local serverStart = headerSize + 12 + 1  -- 第 30 字节开始 (1-indexed)
    local serverSize = 30  -- 每个服务器 30 字节
    
    _G.lastServerList = {}
    
    for i = 0, serverCount - 1 do
        local offset = serverStart + (i * serverSize)
        
        -- ServerInfo 结构 (30 字节):
        -- onlineID: 4 字节
        -- userCnt: 4 字节
        -- ip: 16 字节 (UTF-8 字符串)
        -- port: 2 字节
        -- friends: 4 字节
        
        if offset + serverSize - 1 <= #bytes then
            local onlineID = (bytes[offset] or 0) * 16777216 + (bytes[offset+1] or 0) * 65536 + 
                            (bytes[offset+2] or 0) * 256 + (bytes[offset+3] or 0)
            local userCnt = (bytes[offset+4] or 0) * 16777216 + (bytes[offset+5] or 0) * 65536 + 
                           (bytes[offset+6] or 0) * 256 + (bytes[offset+7] or 0)
            
            -- IP 地址从 offset+8 开始，16 字节
            local ipStart = offset + 8
            local currentIP = ""
            for j = 0, 15 do 
                local b = bytes[ipStart + j]
                if b and b > 0 then 
                    currentIP = currentIP .. string.char(b) 
                end 
            end
            
            -- 端口从 offset+24 开始，2 字节 (big-endian)
            local portStart = offset + 24
            local currentPort = (bytes[portStart] or 0) * 256 + (bytes[portStart + 1] or 0)
            
            -- friends 从 offset+26 开始，4 字节
            local friends = (bytes[offset+26] or 0) * 16777216 + (bytes[offset+27] or 0) * 65536 + 
                           (bytes[offset+28] or 0) * 256 + (bytes[offset+29] or 0)
            
            if onlineID > 0 and currentIP ~= "" and currentPort > 0 then
                local localPort = 5000 + (onlineID % 1000)
                print(string.format("\27[36m[服务器列表] #%d: ID=%d, 人数=%d, %s:%d -> 127.0.0.1:%d\27[0m", 
                    i+1, onlineID, userCnt, currentIP, currentPort, localPort))
                
                _G.serverMapping[onlineID] = { ip = currentIP, port = currentPort, localPort = localPort }
                _G.portToServer = _G.portToServer or {}
                _G.portToServer[localPort] = { id = onlineID, ip = currentIP, port = currentPort }
                table.insert(_G.lastServerList, { id = onlineID, ip = currentIP, port = currentPort, localPort = localPort })
                
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

local server = net.createServer(function(client)
    print("\27[36m[LOGIN] 新客户端连接\27[0m")
    
    local officialConn, clientClosed, officialClosed = nil, false, false
    local officialWsReady = false
    local pendingData = {}
    local isWebSocket, handshakeComplete = false, false
    local wsBuffer, officialWsBuffer = "", ""
    
    local function sendToClient(data)
        if clientClosed then return end
        if isWebSocket then
            pcall(function() client:write(encodeWebSocketFrame(data, 0x02)) end)
        else
            pcall(function() client:write(data) end)
        end
    end
    
    local function sendToOfficial(data)
        if officialClosed or not officialConn then 
            print("\27[31m[LOGIN] 无法发送到官服: officialClosed=" .. tostring(officialClosed) .. ", officialConn=" .. tostring(officialConn ~= nil) .. "\27[0m")
            return 
        end
        -- 发送到官服时需要带 mask（WebSocket 客户端规范要求）
        local frame = encodeWebSocketFrameMasked(data, 0x02)
        
        -- 检查是否应该隐藏此命令的日志
        local header = parsePacketHeader(data)
        local shouldHide = header and shouldHideCmd(header.cmdId)
        
        if not shouldHide then
            print(string.format("\27[35m[LOGIN] 发送到官服: %d bytes (帧: %d bytes)\27[0m", #data, #frame))
            print(string.format("\27[35m[LOGIN] 帧 HEX: %s\27[0m", toHex(frame)))
        end
        
        local ok, err = pcall(function() officialConn:write(frame) end)
        if not ok then
            print("\27[31m[LOGIN] 发送失败: " .. tostring(err) .. "\27[0m")
        end
    end
    
    local function processClientData(data)
        local header = parsePacketHeader(data)
        if header then
            -- 检查是否应该隐藏此命令的日志
            if not shouldHideCmd(header.cmdId) then
                print(string.format("\27[35m╔══════════════════════════════════════════════════════════════╗\27[0m"))
                print(string.format("\27[35m║ [客户端→官服] CMD=%d (%s)\27[0m", header.cmdId, getCmdName(header.cmdId)))
                print(string.format("\27[35m╚══════════════════════════════════════════════════════════════╝\27[0m"))
                print(string.format("\27[35m[客户端→官服] UID=%d, 长度=%d bytes\27[0m", header.userId, header.length))
                print(string.format("\27[35m[客户端→官服] HEX: %s\27[0m", toHex(data)))
            end
            
            -- 记录流量（始终记录到文件，不受隐藏设置影响）
            logTraffic("client_to_server", header.cmdId, header.userId, data)
        end
        
        if officialWsReady then
            sendToOfficial(data)
        else
            table.insert(pendingData, data)
            print(string.format("\27[33m[LOGIN] 数据已缓存，等待官服连接 (缓存数量: %d)\27[0m", #pendingData))
        end
    end
    
    local function processOfficialData(data)
        local header = parsePacketHeader(data)
        local modified = data
        
        if header then
            -- 检查是否应该隐藏此命令的日志
            if not shouldHideCmd(header.cmdId) then
                print(string.format("\27[33m╔══════════════════════════════════════════════════════════════╗\27[0m"))
                print(string.format("\27[33m║ [官服→客户端] CMD=%d (%s)\27[0m", header.cmdId, getCmdName(header.cmdId)))
                print(string.format("\27[33m╚══════════════════════════════════════════════════════════════╝\27[0m"))
                print(string.format("\27[33m[官服→客户端] UID=%d, RESULT=%d, 长度=%d bytes\27[0m", header.userId, header.result, header.length))
                print(string.format("\27[33m[官服→客户端] HEX: %s\27[0m", toHex(data)))
            end
            
            -- 记录流量（始终记录到文件，不受隐藏设置影响）
            logTraffic("server_to_client", header.cmdId, header.userId, data)
            
            if header.cmdId == 105 and conf.proxy_game_server then
                modified = processServerList(data)
            end
        end
        
        sendToClient(modified)
    end

    local function connectToOfficial()
        if officialConn then return end
        
        -- 官服使用 WebSocket 端口 12345 (从 ip.txt 获取)
        local targetPort = conf.official_login_port or 12345
        local targetHost = conf.official_login_server or '45.125.46.70'
        
        print(string.format("\27[36m[LOGIN] 连接官服 WebSocket %s:%d...\27[0m", targetHost, targetPort))
        
        officialConn = net.createConnection(targetPort, targetHost, function(err)
            if err then
                print("\27[31m[LOGIN] 连接官服失败: " .. tostring(err) .. "\27[0m")
                pcall(function() client:destroy() end)
                return
            end
            
            print("\27[32m[LOGIN] ✓ TCP 已连接到官服 " .. targetHost .. ":" .. targetPort .. "\27[0m")
            
            -- 发送 WebSocket 握手请求
            local wsKey = generateWebSocketKey()
            local wsReq = "GET / HTTP/1.1\r\n" ..
                "Host: " .. targetHost .. ":" .. targetPort .. "\r\n" ..
                "Upgrade: websocket\r\n" ..
                "Connection: Upgrade\r\n" ..
                "Sec-WebSocket-Key: " .. wsKey .. "\r\n" ..
                "Sec-WebSocket-Version: 13\r\n" ..
                "Origin: http://61.160.213.26:12346\r\n" ..
                "\r\n"
            
            print("\27[36m[LOGIN] 发送 WebSocket 握手...\27[0m")
            officialConn:write(wsReq)
            
            officialConn:on("data", function(data)
                if clientClosed then return end
                
                print(string.format("\27[36m[LOGIN] 收到官服数据: %d bytes\27[0m", #data))
                print(string.format("\27[36m[LOGIN] 数据预览: %s\27[0m", data:sub(1, 200):gsub("[%c]", ".")))
                
                if not officialWsReady then
                    -- 等待 WebSocket 握手响应
                    local headerEnd = data:find("\r\n\r\n")
                    if data:match("^HTTP/1.1 101") and headerEnd then
                        print("\27[32m[LOGIN] ✓ 官服 WebSocket 握手成功!\27[0m")
                        officialWsReady = true
                        
                        -- 检查是否有额外数据（握手响应后紧跟的 WebSocket 帧）
                        local extraData = data:sub(headerEnd + 4)
                        if #extraData > 0 then
                            print(string.format("\27[36m[LOGIN] 握手响应后有额外数据: %d bytes\27[0m", #extraData))
                            officialWsBuffer = extraData
                        end
                        
                        -- 发送所有缓存的数据
                        print(string.format("\27[36m[LOGIN] 发送 %d 条缓存数据到官服\27[0m", #pendingData))
                        for _, d in ipairs(pendingData) do 
                            sendToOfficial(d) 
                        end
                        pendingData = {}
                        
                        -- 如果没有额外数据，直接返回等待下一次数据
                        if #officialWsBuffer == 0 then
                            return
                        end
                        -- 有额外数据，继续到下面的 WebSocket 帧处理（不要再追加 data）
                    else
                        print("\27[31m[LOGIN] 官服 WebSocket 握手失败!\27[0m")
                        print("\27[31m[LOGIN] 响应: " .. data:sub(1, 500) .. "\27[0m")
                        pcall(function() client:destroy() end)
                        return
                    end
                else
                    -- 已经握手完成，追加新数据到缓冲区
                    officialWsBuffer = officialWsBuffer .. data
                end
                print(string.format("\27[36m[LOGIN] WebSocket 缓冲区: %d bytes\27[0m", #officialWsBuffer))
                
                while #officialWsBuffer > 0 do
                    local opcode, payload, remaining = decodeWebSocketFrame(officialWsBuffer)
                    if not opcode then 
                        print("\27[33m[LOGIN] 等待更多数据...\27[0m")
                        break 
                    end
                    officialWsBuffer = remaining
                    
                    print(string.format("\27[36m[LOGIN] WebSocket 帧: opcode=%d, payload=%d bytes\27[0m", opcode, payload and #payload or 0))
                    
                    if opcode == 0x01 or opcode == 0x02 then 
                        -- 文本或二进制数据
                        processOfficialData(payload)
                    elseif opcode == 0x08 then 
                        -- 关闭帧
                        local closeCode = 0
                        local closeReason = ""
                        if payload and #payload >= 2 then
                            closeCode = payload:byte(1) * 256 + payload:byte(2)
                            closeReason = #payload > 2 and payload:sub(3) or ""
                        end
                        print(string.format("\27[33m[LOGIN] 官服发送关闭帧: code=%d, reason=%s\27[0m", closeCode, closeReason))
                        officialClosed = true
                        pcall(function() client:destroy() end)
                        return
                    elseif opcode == 0x09 then 
                        -- Ping
                        print("\27[36m[LOGIN] 收到官服 Ping，回复 Pong\27[0m")
                        officialConn:write(encodeWebSocketFrameMasked(payload, 0x0A))
                    elseif opcode == 0x0A then
                        -- Pong
                        print("\27[36m[LOGIN] 收到官服 Pong\27[0m")
                    end
                end
            end)
            
            officialConn:on("error", function(err)
                print("\27[31m[LOGIN] 官服连接错误: " .. tostring(err) .. "\27[0m")
                officialClosed = true
                if not clientClosed then pcall(function() client:destroy() end) end
            end)
            
            officialConn:on("end", function()
                print("\27[33m[LOGIN] 官服断开连接\27[0m")
                officialClosed = true
                if not clientClosed then pcall(function() client:destroy() end) end
            end)
        end)
    end

    client:on("error", function(err) 
        print("\27[31m[LOGIN] 客户端错误: " .. tostring(err) .. "\27[0m")
        clientClosed = true
        if officialConn then pcall(function() officialConn:destroy() end) end 
    end)
    
    client:on("end", function() 
        print("\27[33m[LOGIN] 客户端断开连接\27[0m")
        clientClosed = true
        if officialConn then pcall(function() officialConn:destroy() end) end 
    end)
    
    client:on("data", function(data)
        -- 检查是否是 WebSocket 握手
        if not handshakeComplete and data:match("^GET ") then
            local ws = parseWebSocketHandshake(data)
            if ws then
                print("\27[36m[WebSocket] 客户端握手请求\27[0m")
                isWebSocket, handshakeComplete = true, true
                client:write(generateWebSocketResponse(ws.key))
                print("\27[32m[WebSocket] ✓ 客户端握手完成\27[0m")
                connectToOfficial()
                return
            end
        end
        
        -- 检查是否是 Flash 策略文件请求
        if data == "<policy-file-request/>\000" then 
            print("\27[36m[LOGIN] Flash 策略文件请求\27[0m")
            client:write(policy_file)
            return 
        end
        
        -- 如果还没连接官服，先连接
        if not officialConn then 
            handshakeComplete = true  -- 标记为非 WebSocket 模式
            connectToOfficial() 
        end
        
        -- 处理数据
        if isWebSocket then
            wsBuffer = wsBuffer .. data
            while #wsBuffer > 0 do
                local opcode, payload, remaining = decodeWebSocketFrame(wsBuffer)
                if not opcode then break end
                wsBuffer = remaining
                
                if opcode == 0x01 or opcode == 0x02 then 
                    processClientData(payload)
                elseif opcode == 0x08 then 
                    print("\27[33m[LOGIN] 客户端发送关闭帧\27[0m")
                    pcall(function() client:destroy() end)
                    return
                elseif opcode == 0x09 then 
                    -- Ping
                    client:write(encodeWebSocketFrame(payload, 0x0A))
                end
            end
        else
            processClientData(data)
        end
    end)
end)

server:on('error', function(err) 
    if err then print("\27[31m[LOGIN] Server error: " .. tostring(err) .. "\27[0m") end 
end)

server:listen(conf.login_port)

print("\27[36m╔══════════════════════════════════════════════════════════════╗\27[0m")
print("\27[36m║ TrafficLogger 登录服务器已启动                               ║\27[0m")
print("\27[36m║ 本地: ws://127.0.0.1:" .. conf.login_port .. " → 官服: ws://" .. (conf.official_login_server or '45.125.46.70') .. ":" .. (conf.official_login_port or 12345) .. "  ║\27[0m")
print("\27[36m║ 协议: WebSocket (二进制帧)                                   ║\27[0m")
print("\27[36m╚══════════════════════════════════════════════════════════════╝\27[0m")
