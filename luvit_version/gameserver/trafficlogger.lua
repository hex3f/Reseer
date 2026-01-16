-- TrafficLogger (Multi-Port Game Server)
-- 记录解密后的数据
-- 支持 WebSocket 和原始 TCP Socket

gs = require "core".Object:extend()
local timer = require "timer"
local net = require "net"
local fs = require "fs"
local bit = require "../bitop_compat"
local buffer = require "buffer"

-- 从 Logger 模块获取 tprint
local Logger = require('../logger')
local tprint = Logger.tprint

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
tprint("\27[36m[GAME] Seer command list loaded\27[0m")

-- 获取命令名称
local function getCmdName(cmdId)
    return SeerCommands.getName(cmdId)
end

local policy_file = "\
<?xml version=\"1.0\"?><!DOCTYPE cross-domain-policy><cross-domain-policy>\
<allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>\000\
"

-- 初始密钥（保留用于可能的加密数据解析）
-- 注意：Flash客户端发送的是明文，服务器返回的数据也可能是明文
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
        tprint(string.format("\27[32m[CRYPTO:%d] 密钥已初始化: %s (%d字符)\27[0m", self.port, keyStr, #keyStr))
    end
    
    -- 使用初始密钥
    function crypto:useInitialKey()
        self:initKey(INITIAL_KEY)
        tprint(string.format("\27[36m[CRYPTO:%d] 使用初始密钥\27[0m", self.port))
    end
    
    -- 从登录响应更新密钥
    function crypto:updateKeyFromLoginResponse(data, userId)
        -- 登录响应的body最后4字节是随机数
        local header = parsePacketHeader(data)
        if not header or header.length < 21 then
            tprint(string.format("\27[31m[CRYPTO:%d] 登录响应太短\27[0m", self.port))
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
        
        tprint(string.format("\27[32m[CRYPTO:%d] 密钥已更新: random=%d, xor=%d, key=%s\27[0m", 
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
    tprint(string.format("\27[36m[GAME] createGameServerForPort: port=%d, target=%s:%d, serverID=%d\27[0m", 
        localPort, targetIP, targetPort, serverID))
    
    if activeServers[localPort] then
        tprint(string.format("\27[33m[GAME] Port %d already listening\27[0m", localPort))
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
        
        tprint(string.format("\27[35m[GAME:%d] 新客户端连接 (Server ID=%d -> %s:%d)\27[0m", 
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
        
        -- 生成 HEX 字符串
        local function toHexString(data, maxLen)
            -- maxLen = nil 表示不限制长度，显示完整数据
            local hexStr = ""
            local len = maxLen and math.min(#data, maxLen) or #data
            for i = 1, len do
                hexStr = hexStr .. string.format("%02X ", data:byte(i))
            end
            if maxLen and #data > maxLen then
                hexStr = hexStr .. "..."
            end
            return hexStr
        end
        
        -- 检查是否应该隐藏该命令
        local function shouldHideCmd(cmdId)
            if not conf.hide_frequent_cmds then return false end
            if not conf.hide_cmd_list then return false end
            for _, hiddenCmd in ipairs(conf.hide_cmd_list) do
                if cmdId == hiddenCmd then return true end
            end
            return false
        end
        
        -- 处理单个数据包
        local function processSinglePacket(direction, data)
            local decryptedData = nil
            local header = nil
            
            -- 首先尝试直接解析为明文（Flash客户端发送的是明文）
            header = parsePacketHeader(data)
            
            -- 检查是否是有效的明文包
            local isValidPlaintext = header and 
                                     header.cmdId > 0 and 
                                     header.cmdId < 100000 and 
                                     header.length == #data and
                                     header.length >= 17 and
                                     header.length < 1000000
            
            if isValidPlaintext then
                -- 明文包，直接使用
                decryptedData = data
            else
                -- 尝试解密（服务器返回的数据可能是加密的）
                decryptedData = tryDecryptPacket(crypto, data)
                if decryptedData then
                    header = parsePacketHeader(decryptedData)
                else
                    -- 解密失败，尝试直接使用原始数据
                    header = parsePacketHeader(data)
                    decryptedData = data
                end
            end
            
            -- 打印信息
            if header and header.cmdId > 0 and header.cmdId < 100000 and header.length < 1000000 then
                local cmdName = getCmdName(header.cmdId)
                local isEncrypted = not isValidPlaintext and decryptedData ~= data
                
                -- 检查是否隐藏该命令
                if not shouldHideCmd(header.cmdId) then
                    -- 简洁的单行格式
                    local dirStr, color
                    if direction == "CLI" then
                        dirStr = "→官服"
                        color = "\27[32m"  -- 绿色
                    else
                        dirStr = "←官服"
                        color = "\27[33m"  -- 黄色
                    end
                    
                    -- 主日志行
                    tprint(string.format("%s[%s] CMD %d (%s) UID=%d LEN=%d\27[0m", 
                        color, dirStr, header.cmdId, cmdName, header.userId, header.length))
                    
                    -- 显示 HEX 数据 (body 部分，完整显示)
                    if #decryptedData > 17 then
                        local bodyData = decryptedData:sub(18)
                        tprint(string.format("\27[90m  HEX: %s\27[0m", toHexString(bodyData)))
                    end
                end
                
                -- 记录到日志文件（包含完整数据，不管是否隐藏）
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
                        tprint(string.format("\27[36m[GAME:%d] 检测到登录请求, UID=%d\27[0m", localPort, userId))
                    elseif direction == "SRV" and not loginResponseReceived then
                        -- 登录响应，更新密钥
                        loginResponseReceived = true
                        tprint(string.format("\27[36m[GAME:%d] 检测到登录响应, 准备更新密钥\27[0m", localPort))
                        crypto:updateKeyFromLoginResponse(decryptedData, userId)
                    end
                end
                
                -- 检测 GET_ROOM_ADDRES 响应 (CMD 10002)
                -- 拦截官服房间服务器地址，替换为本地代理
                if header.cmdId == 10002 and direction == "SRV" then
                    local body = decryptedData:sub(18)
                    if #body >= 30 then
                        -- 响应格式: session(24) + ip(4) + port(2)
                        local session = body:sub(1, 24)
                        local ip1 = body:byte(25)
                        local ip2 = body:byte(26)
                        local ip3 = body:byte(27)
                        local ip4 = body:byte(28)
                        local port = body:byte(29) * 256 + body:byte(30)
                        
                        local officialIP = string.format("%d.%d.%d.%d", ip1, ip2, ip3, ip4)
                        tprint(string.format("\27[35m[GAME:%d] 检测到官服房间服务器: %s:%d\27[0m", 
                            localPort, officialIP, port))
                        
                        -- 保存官服房间服务器信息
                        _G.officialRoomServer = _G.officialRoomServer or {}
                        _G.officialRoomServer.ip = officialIP
                        _G.officialRoomServer.port = port
                        _G.officialRoomServer.targetUserId = header.userId
                        
                        tprint(string.format("\27[32m[GAME:%d] ✓ 已保存官服房间服务器地址，房间代理已就绪\27[0m", localPort))
                        
                        -- 修改响应，替换为本地代理地址
                        local localRoomPort = conf.roomserver_port or 5100
                        local modifiedBody = session ..
                            string.char(127, 0, 0, 1) ..  -- 127.0.0.1
                            string.char(math.floor(localRoomPort / 256), localRoomPort % 256)
                        
                        -- 重建数据包
                        local newLen = 17 + #modifiedBody
                        local modifiedPacket = string.char(
                            math.floor(newLen / 16777216) % 256,
                            math.floor(newLen / 65536) % 256,
                            math.floor(newLen / 256) % 256,
                            newLen % 256
                        ) .. decryptedData:sub(5, 17) .. modifiedBody
                        
                        tprint(string.format("\27[35m[GAME:%d] 已修改响应: 127.0.0.1:%d\27[0m", 
                            localPort, localRoomPort))
                        
                        -- 返回修改后的数据包
                        return modifiedPacket, header, true  -- true 表示数据已修改
                    end
                end
            else
                -- 无法解析的数据
                tprint(string.format("\27[31m[GAME:%d] 无法解析 %d bytes: %s\27[0m", 
                    localPort, #data, toHexString(data, 32)))
                decryptedData = data  -- 记录原始数据
            end
            
            -- 记录到文件
            logPacket(direction, data, decryptedData)
            
            return decryptedData, header, false  -- false 表示数据未修改
        end
        
        -- 处理缓冲区中的数据包（处理TCP分片/合并）
        -- 返回: remaining, modifiedData (如果有修改的话)
        local function processBuffer(direction, buffer)
            local remaining = buffer
            local modifiedPackets = {}
            local hasModification = false
            
            while #remaining >= 4 do
                -- 读取包长度
                local pktLen = (remaining:byte(1) * 16777216) + 
                               (remaining:byte(2) * 65536) + 
                               (remaining:byte(3) * 256) + 
                               remaining:byte(4)
                
                -- 检查长度是否合理
                if pktLen < 17 or pktLen > 1000000 then
                    -- 长度不合理，可能是数据损坏，跳过一个字节
                    tprint(string.format("\27[31m[GAME:%d] 异常包长度: %d, 跳过\27[0m", localPort, pktLen))
                    remaining = remaining:sub(2)
                elseif #remaining >= pktLen then
                    -- 有完整的包
                    local packet = remaining:sub(1, pktLen)
                    remaining = remaining:sub(pktLen + 1)
                    local resultData, header, isModified = processSinglePacket(direction, packet)
                    if isModified and resultData then
                        table.insert(modifiedPackets, resultData)
                        hasModification = true
                    else
                        table.insert(modifiedPackets, packet)
                    end
                else
                    -- 包不完整，等待更多数据
                    break
                end
            end
            
            -- 返回剩余数据和修改后的数据包
            if hasModification then
                return remaining, table.concat(modifiedPackets)
            else
                return remaining, nil
            end
        end
        
        ce = net.createConnection(targetPort, targetIP, function(err)
            if err then 
                tprint(string.format("\27[31m[GAME:%d] Error connecting to official: %s\27[0m", localPort, tostring(err)))
                pcall(function() client:destroy() end)
                return
            end
    
            tprint(string.format("\27[32m[GAME:%d] Connected to official: %s:%d\27[0m", localPort, targetIP, targetPort))
            officialReady = true
            
            -- 发送缓存的数据
            if #pendingData > 0 then
                tprint(string.format("\27[36m[GAME:%d] 发送 %d 个缓存数据包到官服\27[0m", localPort, #pendingData))
            end
            for _, data in ipairs(pendingData) do
                tprint(string.format("\27[36m[GAME:%d] 发送缓存数据: %d bytes\27[0m", localPort, #data))
                ce:write(data)
            end
            pendingData = {}
            
            -- 设置超时检测
            local responseReceived = false
            timer.setTimeout(5000, function()
                if not responseReceived and not officialClosed then
                    tprint(string.format("\27[31m[GAME:%d] ⚠ 官服 5 秒内无响应！\27[0m", localPort))
                end
            end)

            ce:on("data", function(data)
                if clientClosed then return end
                responseReceived = true
                tprint(string.format("\27[32m[GAME:%d] 收到官服数据: %d bytes\27[0m", localPort, #data))
                -- 添加到缓冲区并处理
                serverBuffer = serverBuffer .. data
                local remaining, modifiedData = processBuffer("SRV", serverBuffer)
                serverBuffer = remaining
                -- 转发数据给客户端（如果有修改则使用修改后的数据）
                if modifiedData then
                    tprint(string.format("\27[35m[GAME:%d] 转发修改后的数据: %d bytes\27[0m", localPort, #modifiedData))
                    sendToClient(modifiedData)
                else
                    sendToClient(data)
                end
            end)
            
            ce:on("error", function(err)
                tprint(string.format("\27[31m[GAME:%d] Official error: %s\27[0m", localPort, tostring(err)))
                officialClosed = true
                if not clientClosed then pcall(function() client:destroy() end) end
            end)
            
            ce:on("end", function()
                officialClosed = true
                if not clientClosed then pcall(function() client:destroy() end) end
            end)
        end)

        client:on("close", function()
            tprint(string.format("Closed session (port %d)", localPort))
            clientClosed = true
            if fd then fd:close() end
            if fdDecrypted then fdDecrypted:close() end
            tmr:close()
            if ce and not officialClosed then pcall(function() ce:destroy() end) end
        end)
        
        client:on("error", function(err)
            tprint(string.format("[GAME:%d] Client error: %s", localPort, err))
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
                    tprint(string.format("\27[36m[GAME:%d] WebSocket 握手请求\27[0m", localPort))
                    isWebSocket = true
                    handshakeComplete = true
                    local response = generateWebSocketResponse(wsHandshake.key)
                    client:write(response)
                    tprint(string.format("\27[32m[GAME:%d] ✓ WebSocket 握手完成\27[0m", localPort))
                    return
                end
            end
            
            if data == "<policy-file-request/>\000" then
                tprint(string.format("Policy file requested (port %d)", localPort))
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
                        local remaining, _ = processBuffer("CLI", clientBuffer)
                        clientBuffer = remaining
                        
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
            local remaining, _ = processBuffer("CLI", clientBuffer)
            clientBuffer = remaining
            
            -- 转发原始数据给官服
            if officialReady and not officialClosed then
                tprint(string.format("\27[36m[GAME:%d] 转发数据到官服: %d bytes\27[0m", localPort, #data))
                local success, err = pcall(function() ce:write(data) end)
                if not success then
                    tprint(string.format("\27[31m[GAME:%d] 转发失败: %s\27[0m", localPort, tostring(err)))
                end
            else
                tprint(string.format("\27[33m[GAME:%d] 官服未就绪，缓存数据: %d bytes\27[0m", localPort, #data))
                table.insert(pendingData, data)
            end
        end)
    end)
    
    server:on('error', function(err)
        tprint(string.format("\27[31m[GAME] Error on port %d: %s\27[0m", localPort, tostring(err)))
    end)

    server:listen(localPort)
    activeServers[localPort] = true
    tprint(string.format("\27[36m[GAME] Listening on port %d -> %s:%d\27[0m", localPort, targetIP, targetPort))
end

function gs:initialize(port)
    tprint("\27[36m[GAME] ========== Initializing TrafficLogger ==========\27[0m")
    tprint("\27[36m[GAME] Initial key: " .. INITIAL_KEY .. "\27[0m")
    
    pcall(function() fs.mkdirSync("sessionlog") end)
    
    _G.portToServer = _G.portToServer or {}
    _G.serverMapping = _G.serverMapping or {}
    
    local defaultPort = conf.gameserver_port or 5000
    local defaultIP = conf.official_game_server or "101.35.207.167"
    local defaultTargetPort = conf.official_game_port or 1272
    
    createGameServerForPort(defaultPort, defaultIP, defaultTargetPort, 0)
    
    _G.createGameServerForPort = createGameServerForPort
    
    tprint("\27[36m[GAME] TrafficLogger initialized\27[0m")
    tprint("\27[36m[GAME] Session files: *.bin (raw), *-decrypted.bin (decrypted)\27[0m")
end

return {GameServer = gs}
