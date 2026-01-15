-- TrafficLogger (Multi-Port Game Server)
-- 记录解密后的数据
-- 支持 WebSocket 和原始 TCP Socket

gs = require "core".Object:extend()
local timer = require "timer"
local net = require "net"
local fs = require "fs"
local bit = require "../bitop_compat"
local buffer = require "buffer"

-- MD5 库
local md5 = nil
pcall(function()
    md5 = require "../md5"
end)

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

-- 纯 Lua SHA1 实现（使用 bit 模块）
local function sha1_ws(msg)
    local function lrotate(a, n)
        return bit.bor(bit.lshift(a, n), bit.rshift(a, 32 - n))
    end
    
    local h0, h1, h2, h3, h4 = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0
    
    local msgLen = #msg
    local padLen = 64 - ((msgLen + 9) % 64)
    if padLen == 64 then padLen = 0 end
    
    msg = msg .. "\128" .. string.rep("\0", padLen) .. 
          string.char(0, 0, 0, 0,
                      bit.rshift(msgLen * 8, 24) % 256,
                      bit.rshift(msgLen * 8, 16) % 256,
                      bit.rshift(msgLen * 8, 8) % 256,
                      (msgLen * 8) % 256)
    
    for i = 1, #msg, 64 do
        local chunk = msg:sub(i, i + 63)
        local w = {}
        
        for j = 1, 16 do
            local idx = (j - 1) * 4 + 1
            w[j] = bit.lshift(chunk:byte(idx), 24) + bit.lshift(chunk:byte(idx + 1), 16) +
                   bit.lshift(chunk:byte(idx + 2), 8) + chunk:byte(idx + 3)
        end
        
        for j = 17, 80 do
            w[j] = lrotate(bit.bxor(bit.bxor(w[j-3], w[j-8]), bit.bxor(w[j-14], w[j-16])), 1)
        end
        
        local a, b, c, d, e = h0, h1, h2, h3, h4
        
        for j = 1, 80 do
            local f, k
            if j <= 20 then
                f = bit.bor(bit.band(b, c), bit.band(bit.bnot(b), d))
                k = 0x5A827999
            elseif j <= 40 then
                f = bit.bxor(bit.bxor(b, c), d)
                k = 0x6ED9EBA1
            elseif j <= 60 then
                f = bit.bor(bit.bor(bit.band(b, c), bit.band(b, d)), bit.band(c, d))
                k = 0x8F1BBCDC
            else
                f = bit.bxor(bit.bxor(b, c), d)
                k = 0xCA62C1D6
            end
            
            local temp = bit.band(lrotate(a, 5) + f + e + k + w[j], 0xFFFFFFFF)
            e = d
            d = c
            c = lrotate(b, 30)
            b = a
            a = temp
        end
        
        h0 = bit.band(h0 + a, 0xFFFFFFFF)
        h1 = bit.band(h1 + b, 0xFFFFFFFF)
        h2 = bit.band(h2 + c, 0xFFFFFFFF)
        h3 = bit.band(h3 + d, 0xFFFFFFFF)
        h4 = bit.band(h4 + e, 0xFFFFFFFF)
    end
    
    return string.char(
        bit.rshift(h0, 24) % 256, bit.rshift(h0, 16) % 256, bit.rshift(h0, 8) % 256, h0 % 256,
        bit.rshift(h1, 24) % 256, bit.rshift(h1, 16) % 256, bit.rshift(h1, 8) % 256, h1 % 256,
        bit.rshift(h2, 24) % 256, bit.rshift(h2, 16) % 256, bit.rshift(h2, 8) % 256, h2 % 256,
        bit.rshift(h3, 24) % 256, bit.rshift(h3, 16) % 256, bit.rshift(h3, 8) % 256, h3 % 256,
        bit.rshift(h4, 24) % 256, bit.rshift(h4, 16) % 256, bit.rshift(h4, 8) % 256, h4 % 256
    )
end
-- 解析 WebSocket 握手请求
local function parseWebSocketHandshake(data)
    if not data:match("^GET ") then return nil end
    local key = data:match("Sec%-WebSocket%-Key: ([^\r\n]+)")
    if not key then return nil end
    return { key = key, isWebSocket = true }
end

-- 生成 WebSocket 握手响应
local function generateWebSocketResponse(key)
    local GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
    local accept = base64_encode(sha1_ws(key .. GUID))
    return "HTTP/1.1 101 Switching Protocols\r\n" ..
           "Upgrade: websocket\r\n" ..
           "Connection: Upgrade\r\n" ..
           "Sec-WebSocket-Accept: " .. accept .. "\r\n\r\n"
end

-- 解码 WebSocket 帧
local function decodeWebSocketFrame(data)
    if #data < 2 then return nil, nil, data end
    
    local byte1 = data:byte(1)
    local byte2 = data:byte(2)
    local opcode = byte1 % 16
    local masked = math.floor(byte2 / 128) % 2 == 1
    local payloadLen = byte2 % 128
    local headerLen = 2
    
    if payloadLen == 126 then
        if #data < 4 then return nil, nil, data end
        payloadLen = data:byte(3) * 256 + data:byte(4)
        headerLen = 4
    elseif payloadLen == 127 then
        if #data < 10 then return nil, nil, data end
        payloadLen = 0
        for i = 3, 10 do payloadLen = payloadLen * 256 + data:byte(i) end
        headerLen = 10
    end
    
    local maskKey = nil
    if masked then
        if #data < headerLen + 4 then return nil, nil, data end
        maskKey = data:sub(headerLen + 1, headerLen + 4)
        headerLen = headerLen + 4
    end
    
    if #data < headerLen + payloadLen then return nil, nil, data end
    
    local payload = data:sub(headerLen + 1, headerLen + payloadLen)
    local remaining = data:sub(headerLen + payloadLen + 1)
    
    if masked and maskKey then
        local unmasked = {}
        for i = 1, #payload do
            local j = ((i - 1) % 4) + 1
            unmasked[i] = string.char(bit.bxor(payload:byte(i), maskKey:byte(j)))
        end
        payload = table.concat(unmasked)
    end
    
    return opcode, payload, remaining
end

-- 编码 WebSocket 帧
local function encodeWebSocketFrame(data, opcode)
    opcode = opcode or 0x02
    local len = #data
    local header
    
    if len <= 125 then
        header = string.char(0x80 + opcode, len)
    elseif len <= 65535 then
        header = string.char(0x80 + opcode, 126, math.floor(len / 256), len % 256)
    else
        header = string.char(0x80 + opcode, 127, 0, 0, 0, 0,
                            math.floor(len / 16777216) % 256,
                            math.floor(len / 65536) % 256,
                            math.floor(len / 256) % 256,
                            len % 256)
    end
    
    return header .. data
end

-- 简单MD5实现（如果没有md5库）
local function simpleMD5(str)
    -- 这是一个简化版本，用于没有MD5库的情况
    local h = 0x67452301
    local a, b, c, d = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476
    for i = 1, #str do
        local byte = str:byte(i)
        h = bit.bxor(h, byte)
        h = bit.band(bit.lshift(h, 5) + bit.rshift(h, 27) + byte, 0xFFFFFFFF)
        a = bit.bxor(a, bit.lshift(byte, (i % 4) * 8))
        b = bit.bxor(b, bit.rshift(byte, (i % 3)))
        c = bit.band(c + byte * i, 0xFFFFFFFF)
        d = bit.bxor(d, bit.lrotate and bit.lrotate(byte, i % 32) or bit.lshift(byte, i % 8))
    end
    return string.format("%08x%08x%08x%08x", a, b, c, d)
end

-- 加载赛尔号命令列表
-- 加载命令映射
local SeerCommands = require('../seer_commands')
print("\27[36m[GAME] Seer command list loaded\27[0m")

-- 获取命令名称
local function getCmdName(cmdId)
    return SeerCommands.getName(cmdId)
end

local policy_file = "\
<?xml version=\"1.0\"?><!DOCTYPE cross-domain-policy><cross-domain-policy>\
<allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>\000\
"

-- 初始密钥（客户端默认密钥）
local INITIAL_KEY = "!crAckmE4nOthIng:-)"

-- 解析数据包头
local function parsePacketHeader(data)
    if #data < 17 then return nil end
    local length = (data:byte(1) * 16777216) + (data:byte(2) * 65536) + (data:byte(3) * 256) + data:byte(4)
    local version = data:byte(5)
    local cmdId = (data:byte(6) * 16777216) + (data:byte(7) * 65536) + (data:byte(8) * 256) + data:byte(9)
    local userId = (data:byte(10) * 16777216) + (data:byte(11) * 65536) + (data:byte(12) * 256) + data:byte(13)
    local result = (data:byte(14) * 16777216) + (data:byte(15) * 65536) + (data:byte(16) * 256) + data:byte(17)
    return {
        length = length,
        version = version,
        cmdId = cmdId,
        userId = userId,
        result = result,
        body = data:sub(18)
    }
end

-- 已创建的服务器端口列表
local activeServers = {}

-- 创建会话加密器类
local function createSessionCrypto(localPort)
    local crypto = {
        key = nil,
        keyInitialized = false,
        port = localPort,
        userId = 0
    }
    
    -- 初始化密钥
    function crypto:initKey(keyStr)
        self.key = {keyStr:byte(1, #keyStr)}
        self.keyInitialized = true
        print(string.format("\27[32m[CRYPTO:%d] 密钥已初始化: %s (%d字符)\27[0m", self.port, keyStr, #keyStr))
    end
    
    -- 使用初始密钥
    function crypto:useInitialKey()
        self:initKey(INITIAL_KEY)
        print(string.format("\27[36m[CRYPTO:%d] 使用初始密钥\27[0m", self.port))
    end
    
    -- 从登录响应更新密钥
    function crypto:updateKeyFromLoginResponse(data, userId)
        -- 登录响应的body最后4字节是随机数
        local header = parsePacketHeader(data)
        if not header or header.length < 21 then
            print(string.format("\27[31m[CRYPTO:%d] 登录响应太短\27[0m", self.port))
            return false
        end
        
        -- 读取body最后4字节
        local bodyEnd = header.length
        if bodyEnd > #data then bodyEnd = #data end
        
        local randomNum = (data:byte(bodyEnd-3) * 16777216) + 
                          (data:byte(bodyEnd-2) * 65536) + 
                          (data:byte(bodyEnd-1) * 256) + 
                          data:byte(bodyEnd)
        
        -- XOR 用户ID
        local xorResult = bit.bxor(randomNum, userId)
        local s = tostring(xorResult)
        
        -- MD5 哈希
        local hash
        if md5 then
            hash = md5.sumhexa(s)
        else
            hash = simpleMD5(s)
        end
        
        -- 取前10个字符作为新密钥
        local newKey = hash:sub(1, 10)
        self:initKey(newKey)
        
        print(string.format("\27[32m[CRYPTO:%d] 密钥已更新: random=%d, xor=%d, key=%s\27[0m", 
            self.port, randomNum, xorResult, newKey))
        
        return true
    end
    
    -- 解密
    function crypto:decrypt(cipher)
        if not self.keyInitialized then return nil end
        
        local cipherLen = #cipher
        local keyLen = #self.key
        
        if cipherLen < 2 then return nil end
        
        -- 第一步：循环移位
        local result = self.key[(cipherLen - 1) % keyLen + 1] * 13 % cipherLen
        local temp = {}
        for i = 1, cipherLen do
            local idx = (cipherLen - result + i - 1) % cipherLen + 1
            temp[i] = cipher:byte(idx)
        end
        
        -- 第二步：位移操作
        local plain = {}
        for i = 1, cipherLen - 1 do
            plain[i] = bit.band(bit.bor(bit.rshift(temp[i], 5), bit.lshift(temp[i + 1], 3)), 0xFF)
        end
        
        -- 第三步：异或密钥
        local j = 1
        local needBecomeZero = false
        for i = 1, #plain do
            if j == 2 and needBecomeZero then
                j = 1
                needBecomeZero = false
            end
            if j > keyLen then
                j = 1
                needBecomeZero = true
            end
            plain[i] = bit.bxor(plain[i], self.key[j])
            j = j + 1
        end
        
        return string.char(table.unpack(plain))
    end
    
    return crypto
end

-- 尝试解密并返回明文
local function tryDecryptPacket(crypto, data)
    if not crypto.keyInitialized then return nil end
    if #data < 5 then return nil end
    
    -- 提取加密部分（跳过前4字节长度）
    local encryptedPart = data:sub(5)
    
    local success, decrypted = pcall(function()
        return crypto:decrypt(encryptedPart)
    end)
    
    if success and decrypted and #decrypted > 0 then
        -- 重新计算长度（解密后长度减1）
        local newLen = #decrypted + 4
        local lenBytes = string.char(
            math.floor(newLen / 16777216) % 256,
            math.floor(newLen / 65536) % 256,
            math.floor(newLen / 256) % 256,
            newLen % 256
        )
        return lenBytes .. decrypted
    end
    
    return nil
end

-- 创建单个端口的游戏服务器
local function createGameServerForPort(localPort, targetIP, targetPort, serverID)
    print(string.format("\27[36m[GAME] createGameServerForPort: port=%d, target=%s:%d, serverID=%d\27[0m", 
        localPort, targetIP, targetPort, serverID))
    
    if activeServers[localPort] then
        print(string.format("\27[33m[GAME] Port %d already listening\27[0m", localPort))
        return
    end
    
    local server = net.createServer(function(client)
        local ce = nil
        local fd, fdDecrypted
        local sfile = os.time().."-"..os.clock().."-"..serverID..".bin"
        local sfileDecrypted = os.time().."-"..os.clock().."-"..serverID.."-decrypted.bin"
        local officialReady = false
        local officialClosed = false
        local clientClosed = false
        local pendingData = {}
        local userId = 0
        local loginResponseReceived = false
        
        -- TCP 缓冲区（处理分片）
        local clientBuffer = ""
        local serverBuffer = ""
        
        -- WebSocket 相关
        local isWebSocket = false
        local wsBuffer = ""
        local handshakeComplete = false
        
        -- 创建会话加密器，使用初始密钥
        local crypto = createSessionCrypto(localPort)
        crypto:useInitialKey()
        
        print(string.format("\27[35m[GAME:%d] 新客户端连接 (Server ID=%d -> %s:%d)\27[0m", 
            localPort, serverID, targetIP, targetPort))
        
        pcall(function() fs.mkdirSync("sessionlog") end)
        fd = io.open("sessionlog/"..sfile, "wb")
        fdDecrypted = io.open("sessionlog/"..sfileDecrypted, "wb")
        
        local tmr = timer.setInterval(5000, function()
            if fd then fd:flush() end
            if fdDecrypted then fdDecrypted:flush() end
        end)
        
        -- 发送数据到客户端（自动处理 WebSocket 封装）
        local function sendToClient(data)
            if clientClosed then return end
            if isWebSocket then
                local frame = encodeWebSocketFrame(data, 0x02)
                pcall(function() client:write(frame) end)
            else
                pcall(function() client:write(data) end)
            end
        end
        
        -- 记录数据包
        local function logPacket(direction, data, decryptedData)
            local marker = direction == "CLI" and "\r\n\xDE\xADCLI\xBE\xEF\r\n" or "\r\n\xDE\xADSRV\xBE\xEF\r\n"
            local timestamp = tostring(os.clock())
            
            if fd then
                fd:write(marker .. timestamp .. "\r\n" .. data)
            end
            
            if fdDecrypted and decryptedData then
                fdDecrypted:write(marker .. timestamp .. "\r\n" .. decryptedData)
            end
        end
        
        -- 处理单个数据包
        local function processSinglePacket(direction, data)
            local decryptedData = nil
            local header = nil
            
            -- 尝试解密
            decryptedData = tryDecryptPacket(crypto, data)
            if decryptedData then
                header = parsePacketHeader(decryptedData)
            end
            
            -- 打印信息
            local arrow = direction == "CLI" and "->" or "<-"
            if header and header.cmdId < 100000 and header.length < 1000000 then
                local cmdName = getCmdName(header.cmdId)
                
                -- 使用醒目的框架显示
                if direction == "CLI" then
                    print("\27[32m╔══════════════════════════════════════════════════════════════╗\27[0m")
                    print(string.format("\27[32m║ [Flash→官服游戏] CMD=%d (%s)\27[0m", header.cmdId, cmdName))
                    print("\27[32m╚══════════════════════════════════════════════════════════════╝\27[0m")
                    print(string.format("\27[32m[Flash→官服] 端口=%d, UID=%d, 长度=%d bytes\27[0m",
                        localPort, header.userId, header.length))
                else
                    print("\27[33m╔══════════════════════════════════════════════════════════════╗\27[0m")
                    print(string.format("\27[33m║ [官服游戏→Flash] CMD=%d (%s)\27[0m", header.cmdId, cmdName))
                    print("\27[33m╚══════════════════════════════════════════════════════════════╝\27[0m")
                    print(string.format("\27[33m[官服→Flash] 端口=%d, UID=%d, 长度=%d bytes\27[0m",
                        localPort, header.userId, header.length))
                end
                
                -- 记录到日志文件（包含完整数据）
                local Logger = require("../logger")
                Logger.logCommand(
                    direction == "CLI" and "SEND" or "RECV",
                    header.cmdId,
                    cmdName,
                    header.userId,
                    header.length,
                    decryptedData
                )
                
                -- 检测登录包
                if header.cmdId == 1001 then
                    if direction == "CLI" then
                        userId = header.userId
                        crypto.userId = userId
                        print(string.format("\27[36m[GAME:%d] 检测到登录请求, UID=%d\27[0m", localPort, userId))
                    elseif direction == "SRV" and not loginResponseReceived then
                        -- 登录响应，更新密钥
                        loginResponseReceived = true
                        print(string.format("\27[36m[GAME:%d] 检测到登录响应, 准备更新密钥\27[0m", localPort))
                        crypto:updateKeyFromLoginResponse(decryptedData, userId)
                    end
                end
            else
                print(string.format("\27[31m[GAME:%d] %s (解密失败) %d bytes\27[0m", localPort, arrow, #data))
                decryptedData = data  -- 解密失败，记录原始数据
            end
            
            -- 记录
            logPacket(direction, data, decryptedData)
            
            return decryptedData, header
        end
        
        -- 处理缓冲区中的数据包（处理TCP分片/合并）
        local function processBuffer(direction, buffer)
            local remaining = buffer
            
            while #remaining >= 4 do
                -- 读取包长度
                local pktLen = (remaining:byte(1) * 16777216) + 
                               (remaining:byte(2) * 65536) + 
                               (remaining:byte(3) * 256) + 
                               remaining:byte(4)
                
                -- 检查长度是否合理
                if pktLen < 17 or pktLen > 1000000 then
                    -- 长度不合理，可能是数据损坏，跳过一个字节
                    print(string.format("\27[31m[GAME:%d] 异常包长度: %d, 跳过\27[0m", localPort, pktLen))
                    remaining = remaining:sub(2)
                elseif #remaining >= pktLen then
                    -- 有完整的包
                    local packet = remaining:sub(1, pktLen)
                    remaining = remaining:sub(pktLen + 1)
                    processSinglePacket(direction, packet)
                else
                    -- 包不完整，等待更多数据
                    break
                end
            end
            
            return remaining
        end
        
        ce = net.createConnection(targetPort, targetIP, function(err)
            if err then 
                print(string.format("\27[31m[GAME:%d] Error connecting to official: %s\27[0m", localPort, tostring(err)))
                pcall(function() client:destroy() end)
                return
            end
    
            print(string.format("\27[32m[GAME:%d] Connected to official: %s:%d\27[0m", localPort, targetIP, targetPort))
            officialReady = true
            
            for _, data in ipairs(pendingData) do
                ce:write(data)
            end
            pendingData = {}

            ce:on("data", function(data)
                if clientClosed then return end
                -- 添加到缓冲区并处理
                serverBuffer = serverBuffer .. data
                serverBuffer = processBuffer("SRV", serverBuffer)
                -- 转发原始数据给客户端（自动处理 WebSocket）
                sendToClient(data)
            end)
            
            ce:on("error", function(err)
                print(string.format("\27[31m[GAME:%d] Official error: %s\27[0m", localPort, tostring(err)))
                officialClosed = true
                if not clientClosed then pcall(function() client:destroy() end) end
            end)
            
            ce:on("end", function()
                officialClosed = true
                if not clientClosed then pcall(function() client:destroy() end) end
            end)
        end)

        client:on("close", function()
            print(string.format("Closed session (port %d)", localPort))
            clientClosed = true
            if fd then fd:close() end
            if fdDecrypted then fdDecrypted:close() end
            tmr:close()
            if ce and not officialClosed then pcall(function() ce:destroy() end) end
        end)
        
        client:on("error", function(err)
            print(string.format("[GAME:%d] Client error: %s", localPort, err))
            clientClosed = true
        end)
        
        client:on("end", function()
            clientClosed = true
            if ce and not officialClosed then pcall(function() ce:destroy() end) end
        end)
        
        client:on("data", function(data)
            -- 检测 WebSocket 握手请求
            if not handshakeComplete and data:match("^GET ") then
                local wsHandshake = parseWebSocketHandshake(data)
                if wsHandshake then
                    print(string.format("\27[36m[GAME:%d] WebSocket 握手请求\27[0m", localPort))
                    isWebSocket = true
                    handshakeComplete = true
                    local response = generateWebSocketResponse(wsHandshake.key)
                    client:write(response)
                    print(string.format("\27[32m[GAME:%d] ✓ WebSocket 握手完成\27[0m", localPort))
                    return
                end
            end
            
            if data == "<policy-file-request/>\000" then
                print(string.format("Policy file requested (port %d)", localPort))
                client:write(policy_file)
                return
            end
            
            -- 处理 WebSocket 帧
            if isWebSocket then
                wsBuffer = wsBuffer .. data
                
                while #wsBuffer > 0 do
                    local opcode, payload, remaining = decodeWebSocketFrame(wsBuffer)
                    
                    if opcode == nil then break end
                    
                    wsBuffer = remaining
                    
                    if opcode == 0x08 then
                        -- 关闭帧
                        pcall(function() client:destroy() end)
                        return
                    elseif opcode == 0x09 then
                        -- Ping，回复 Pong
                        local pong = encodeWebSocketFrame(payload, 0x0A)
                        client:write(pong)
                    elseif opcode == 0x01 or opcode == 0x02 then
                        -- 文本/二进制帧，处理游戏数据
                        clientBuffer = clientBuffer .. payload
                        clientBuffer = processBuffer("CLI", clientBuffer)
                        
                        -- 转发原始数据给官服
                        if officialReady and not officialClosed then
                            ce:write(payload)
                        else
                            table.insert(pendingData, payload)
                        end
                    end
                end
                return
            end
            
            -- 原始 TCP Socket 处理
            -- 添加到缓冲区并处理
            clientBuffer = clientBuffer .. data
            clientBuffer = processBuffer("CLI", clientBuffer)
            
            -- 转发原始数据给官服
            if officialReady and not officialClosed then
                ce:write(data)
            else
                table.insert(pendingData, data)
            end
        end)
    end)
    
    server:on('error', function(err)
        print(string.format("\27[31m[GAME] Error on port %d: %s\27[0m", localPort, tostring(err)))
    end)

    server:listen(localPort)
    activeServers[localPort] = true
    print(string.format("\27[36m[GAME] Listening on port %d -> %s:%d\27[0m", localPort, targetIP, targetPort))
end

function gs:initialize(port)
    print("\27[36m[GAME] ========== Initializing TrafficLogger ==========\27[0m")
    print("\27[36m[GAME] Initial key: " .. INITIAL_KEY .. "\27[0m")
    
    pcall(function() fs.mkdirSync("sessionlog") end)
    
    _G.portToServer = _G.portToServer or {}
    _G.serverMapping = _G.serverMapping or {}
    
    local defaultPort = conf.gameserver_port or 5000
    local defaultIP = conf.official_game_server or "101.35.207.167"
    local defaultTargetPort = conf.official_game_port or 1272
    
    createGameServerForPort(defaultPort, defaultIP, defaultTargetPort, 0)
    
    _G.createGameServerForPort = createGameServerForPort
    
    print("\27[36m[GAME] TrafficLogger initialized\27[0m")
    print("\27[36m[GAME] Session files: *.bin (raw), *-decrypted.bin (decrypted)\27[0m")
end

return {GameServer = gs}
