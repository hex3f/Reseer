-- TrafficLogger for Room Server (家园系统代理)
-- 记录房间服务器的数据包

local net = require "net"
local fs = require "fs"
local bit = require "../bitop_compat"
local timer = require "timer"

-- 从 Logger 模块获取 tprint
local Logger = require('../logger')
local tprint = Logger.tprint

-- 加载命令映射
local SeerCommands = require('../seer_commands')

local RoomTrafficLogger = {}
RoomTrafficLogger.__index = RoomTrafficLogger

-- 当前官服房间服务器信息 (由游戏服务器代理设置)
_G.officialRoomServer = _G.officialRoomServer or {
    ip = nil,
    port = nil,
    targetUserId = nil
}

-- 获取命令名称
local function getCmdName(cmdId)
    return SeerCommands.getName(cmdId)
end

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

-- 生成 HEX 字符串
local function toHexString(data, maxLen)
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

function RoomTrafficLogger:new()
    local obj = {
        port = conf.roomserver_port or 5100,
        clients = {},
        activeConnections = {}
    }
    setmetatable(obj, RoomTrafficLogger)
    obj:start()
    return obj
end

function RoomTrafficLogger:start()
    local self = self
    
    local server = net.createServer(function(client)
        local clientAddr = client:address()
        tprint(string.format("\27[35m[ROOM] 新客户端连接: %s:%d\27[0m", 
            clientAddr and clientAddr.address or "unknown", 
            clientAddr and clientAddr.port or 0))
        
        -- 检查是否有官服房间服务器信息
        if not _G.officialRoomServer.ip or not _G.officialRoomServer.port then
            tprint("\27[31m[ROOM] 错误: 没有官服房间服务器信息，无法代理\27[0m")
            tprint("\27[31m[ROOM] 请先通过游戏服务器获取房间地址 (GET_ROOM_ADDRES)\27[0m")
            client:destroy()
            return
        end
        
        local targetIP = _G.officialRoomServer.ip
        local targetPort = _G.officialRoomServer.port
        
        tprint(string.format("\27[35m[ROOM] 连接到官服房间服务器: %s:%d\27[0m", targetIP, targetPort))
        
        local officialSocket = nil
        local officialReady = false
        local officialClosed = false
        local clientClosed = false
        local pendingData = {}
        local userId = 0
        
        -- TCP 缓冲区
        local clientBuffer = ""
        local serverBuffer = ""
        
        -- 日志文件
        local sfile = os.time() .. "-" .. os.clock() .. "-room.bin"
        pcall(function() fs.mkdirSync("sessionlog") end)
        local fd = io.open("sessionlog/" .. sfile, "wb")
        
        local tmr = timer.setInterval(5000, function()
            if fd then fd:flush() end
        end)
        
        -- 记录数据包
        local function logPacket(direction, data)
            local marker = direction == "CLI" and "\r\n\xDE\xADCLI\xBE\xEF\r\n" or "\r\n\xDE\xADSRV\xBE\xEF\r\n"
            local timestamp = tostring(os.clock())
            if fd then
                fd:write(marker .. timestamp .. "\r\n" .. data)
            end
        end
        
        -- 处理单个数据包
        local function processSinglePacket(direction, data)
            local header = parsePacketHeader(data)
            
            if header and header.cmdId > 0 and header.cmdId < 100000 and header.length < 1000000 then
                local cmdName = getCmdName(header.cmdId)
                
                -- 记录 userId
                if header.userId > 0 then
                    userId = header.userId
                end
                
                -- 检查是否隐藏该命令
                if not shouldHideCmd(header.cmdId) then
                    local dirStr, color
                    if direction == "CLI" then
                        dirStr = "→官服房间"
                        color = "\27[35m"  -- 紫色
                    else
                        dirStr = "←官服房间"
                        color = "\27[36m"  -- 青色
                    end
                    
                    tprint(string.format("%s[%s] CMD %d (%s) UID=%d LEN=%d\27[0m", 
                        color, dirStr, header.cmdId, cmdName, header.userId, header.length))
                    
                    -- 显示 HEX 数据 (body 部分)
                    if #data > 17 then
                        local bodyData = data:sub(18)
                        tprint(string.format("\27[90m  HEX: %s\27[0m", toHexString(bodyData)))
                    end
                end
                
                -- 记录到日志文件
                Logger.logCommand(
                    direction == "CLI" and "ROOM_SEND" or "ROOM_RECV",
                    header.cmdId,
                    cmdName,
                    header.userId,
                    header.length,
                    data
                )
            else
                tprint(string.format("\27[31m[ROOM] 无法解析 %d bytes: %s\27[0m", 
                    #data, toHexString(data, 32)))
            end
            
            logPacket(direction, data)
        end
        
        -- 处理缓冲区中的数据包
        local function processBuffer(direction, buffer)
            local remaining = buffer
            
            while #remaining >= 4 do
                local pktLen = (remaining:byte(1) * 16777216) + 
                               (remaining:byte(2) * 65536) + 
                               (remaining:byte(3) * 256) + 
                               remaining:byte(4)
                
                if pktLen < 17 or pktLen > 1000000 then
                    tprint(string.format("\27[31m[ROOM] 异常包长度: %d, 跳过\27[0m", pktLen))
                    remaining = remaining:sub(2)
                elseif #remaining >= pktLen then
                    local packet = remaining:sub(1, pktLen)
                    remaining = remaining:sub(pktLen + 1)
                    processSinglePacket(direction, packet)
                else
                    break
                end
            end
            
            return remaining
        end
        
        -- 连接到官服房间服务器
        officialSocket = net.createConnection(targetPort, targetIP, function(err)
            if err then
                tprint(string.format("\27[31m[ROOM] 连接官服房间服务器失败: %s\27[0m", tostring(err)))
                pcall(function() client:destroy() end)
                return
            end
            
            tprint(string.format("\27[32m[ROOM] ✓ 已连接到官服房间服务器: %s:%d\27[0m", targetIP, targetPort))
            officialReady = true
            
            -- 发送缓存的数据
            for _, data in ipairs(pendingData) do
                tprint(string.format("\27[36m[ROOM] 发送缓存数据: %d bytes\27[0m", #data))
                officialSocket:write(data)
            end
            pendingData = {}
            
            -- 接收官服数据
            officialSocket:on("data", function(data)
                if clientClosed then return end
                tprint(string.format("\27[36m[ROOM] 收到官服房间数据: %d bytes\27[0m", #data))
                
                serverBuffer = serverBuffer .. data
                serverBuffer = processBuffer("SRV", serverBuffer)
                
                -- 转发给客户端
                pcall(function() client:write(data) end)
            end)
            
            officialSocket:on("error", function(err)
                tprint(string.format("\27[31m[ROOM] 官服房间服务器错误: %s\27[0m", tostring(err)))
                officialClosed = true
                if not clientClosed then pcall(function() client:destroy() end) end
            end)
            
            officialSocket:on("end", function()
                tprint("\27[33m[ROOM] 官服房间服务器断开连接\27[0m")
                officialClosed = true
                if not clientClosed then pcall(function() client:destroy() end) end
            end)
        end)
        
        -- 客户端事件
        client:on("data", function(data)
            tprint(string.format("\27[35m[ROOM] 收到客户端数据: %d bytes\27[0m", #data))
            
            clientBuffer = clientBuffer .. data
            clientBuffer = processBuffer("CLI", clientBuffer)
            
            if officialReady and not officialClosed then
                tprint(string.format("\27[35m[ROOM] 转发数据到官服房间: %d bytes\27[0m", #data))
                pcall(function() officialSocket:write(data) end)
            else
                tprint(string.format("\27[33m[ROOM] 官服房间未就绪，缓存数据: %d bytes\27[0m", #data))
                table.insert(pendingData, data)
            end
        end)
        
        client:on("close", function()
            tprint("\27[33m[ROOM] 客户端断开连接\27[0m")
            clientClosed = true
            if fd then fd:close() end
            tmr:close()
            if officialSocket and not officialClosed then
                pcall(function() officialSocket:destroy() end)
            end
        end)
        
        client:on("error", function(err)
            tprint(string.format("\27[31m[ROOM] 客户端错误: %s\27[0m", tostring(err)))
            clientClosed = true
        end)
        
        client:on("end", function()
            clientClosed = true
            if officialSocket and not officialClosed then
                pcall(function() officialSocket:destroy() end)
            end
        end)
    end)
    
    server:on('error', function(err)
        tprint(string.format("\27[31m[ROOM] 服务器错误: %s\27[0m", tostring(err)))
    end)
    
    server:listen(self.port, "0.0.0.0", function()
        tprint(string.format("\27[35m[ROOM] ✓ 房间服务器代理启动在端口 %d\27[0m", self.port))
        tprint("\27[35m[ROOM] 等待游戏服务器提供官服房间地址...\27[0m")
    end)
end

return { RoomTrafficLogger = RoomTrafficLogger }
