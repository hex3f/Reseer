-- Logger Module for RecSeer
-- 记录所有请求和交互到统一的日志文件

local fs = require('fs')
local os = require('os')

local Logger = {}
Logger.logFile = nil
Logger.logPath = "logs/server.log"  -- 固定的日志文件名

-- 初始化日志系统
function Logger.init()
    -- 创建 logs 目录
    pcall(function() fs.mkdirSync("logs") end)
    
    -- 以追加模式打开日志文件
    Logger.logFile = io.open(Logger.logPath, "a")
    
    if Logger.logFile then
        Logger.logFile:setvbuf("line") -- 行缓冲，立即写入
        Logger.write("")
        Logger.write("========================================")
        Logger.write("Server Started")
        Logger.write("Time: " .. os.date("%Y-%m-%d %H:%M:%S"))
        Logger.write("========================================")
        Logger.write("")
        print(string.format("\27[36m[LOGGER] Logging to: %s\27[0m", Logger.logPath))
        return true
    else
        print(string.format("\27[31m[LOGGER] Failed to open log file: %s\27[0m", Logger.logPath))
        return false
    end
end

-- 写入日志
function Logger.write(message)
    if Logger.logFile then
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        Logger.logFile:write(string.format("[%s] %s\n", timestamp, message))
    end
end

-- 记录资源请求
function Logger.logResource(method, path, status, size)
    local message = string.format("RESOURCE | %s %s -> %d (%s bytes)", 
        method, path, status, size or "?")
    Logger.write(message)
    
    -- 对 SWF 文件特别标记
    if path:lower():match("%.swf$") then
        Logger.write("         SWF LOADED: " .. path)
    end
end

-- 记录 HTTP 请求
function Logger.logHttp(method, path, status)
    local message = string.format("HTTP | %s %s -> %d", method, path, status)
    Logger.write(message)
end

-- 记录 TCP 连接
function Logger.logTcp(event, port, info)
    local message = string.format("TCP | %s on port %d | %s", event, port, info or "")
    Logger.write(message)
end

-- 将 buffer 转换为 HEX 字符串（完整版，不截断）
local function bufferToHex(data)
    if type(data) == "string" then
        local hex = ""
        for i = 1, #data do
            hex = hex .. string.format("%02X ", string.byte(data, i))
            if i % 16 == 0 and i < #data then
                hex = hex .. "\n                    "
            end
        end
        return hex
    end
    return "N/A"
end

-- 解析为 INT32 数组（大端序）
local function parseAsInt32Array(data)
    if type(data) ~= "string" or #data == 0 then return "" end
    
    local ints = {}
    local i = 1
    while i <= #data - 3 do
        local val = (string.byte(data, i) * 16777216) + 
                    (string.byte(data, i+1) * 65536) + 
                    (string.byte(data, i+2) * 256) + 
                    string.byte(data, i+3)
        
        -- 处理有符号整数
        if val >= 2147483648 then
            val = val - 4294967296
        end
        
        table.insert(ints, val)
        i = i + 4
    end
    
    -- 处理剩余字节
    local remaining = ""
    if i <= #data then
        remaining = " + " .. (#data - i + 1) .. " bytes"
    end
    
    if #ints > 0 then
        return table.concat(ints, ", ") .. remaining
    end
    return ""
end

-- 智能解析：尝试识别数据类型
local function smartParse(data)
    if type(data) ~= "string" or #data == 0 then return "" end
    
    local result = {}
    
    -- 1. 总是尝试解析 INT32 数组（如果数据足够）
    if #data >= 4 then
        local int32s = parseAsInt32Array(data)
        if int32s ~= "" then
            table.insert(result, "INT32[]: " .. int32s)
        end
    end
    
    -- 2. 显示所有字节值（不截断）
    local bytes = {}
    for i = 1, #data do
        table.insert(bytes, string.byte(data, i))
    end
    table.insert(result, "BYTES: " .. table.concat(bytes, ","))
    
    return table.concat(result, " | ")
end

-- 记录游戏命令（完整数据）
function Logger.logCommand(direction, cmdId, cmdName, uid, length, data)
    local arrow = direction == "SEND" and "->" or "<-"
    local message = string.format("GAME | %s CMD=%d (%s), UID=%d, LEN=%d", 
        arrow, cmdId, cmdName or "Unknown", uid or 0, length or 0)
    Logger.write(message)
    
    -- 记录完整的 HEX 数据（不截断）
    if data and #data > 0 then
        local hexData = bufferToHex(data)
        Logger.write("       HEX: " .. hexData)
        
        -- 智能解析（INT32数组等）
        local parsed = smartParse(data)
        if parsed ~= "" then
            Logger.write("       PARSE: " .. parsed)
        end
    end
end

-- 记录游戏命令（带解析数据）
function Logger.logCommandWithParsed(direction, cmdId, cmdName, uid, length, data, parsed)
    local arrow = direction == "SEND" and "->" or "<-"
    local message = string.format("GAME | %s CMD=%d (%s), UID=%d, LEN=%d", 
        arrow, cmdId, cmdName or "Unknown", uid or 0, length or 0)
    Logger.write(message)
    
    -- 记录完整 HEX 数据（不截断）
    if data and #data > 0 then
        local hexData = bufferToHex(data)
        Logger.write("       HEX: " .. hexData)
        
        -- 智能解析（INT32数组等）
        local smartParsed = smartParse(data)
        if smartParsed ~= "" then
            Logger.write("       PARSE: " .. smartParsed)
        end
    end
    
    -- 记录解析后的数据
    if parsed then
        Logger.write("       PARSED: " .. parsed)
    end
end

-- 记录登录事件
function Logger.logLogin(event, uid, info)
    local message = string.format("LOGIN | %s | UID=%d | %s", event, uid or 0, info or "")
    Logger.write(message)
end

-- 记录错误
function Logger.logError(module, error)
    local message = string.format("ERROR | [%s] %s", module, error)
    Logger.write(message)
end

-- 记录官服交互（客户端→官服）
function Logger.logOfficialSend(cmdId, cmdName, uid, length, data)
    local message = string.format("OFFICIAL | -> CMD=%d (%s), UID=%d, LEN=%d", 
        cmdId, cmdName or "Unknown", uid or 0, length or 0)
    Logger.write(message)
    
    -- 记录完整的 HEX 数据
    if data and #data > 0 then
        local hexData = bufferToHex(data)
        Logger.write("           HEX: " .. hexData)
    end
end

-- 记录官服交互（官服→客户端）
function Logger.logOfficialRecv(cmdId, cmdName, uid, result, length, data)
    local message = string.format("OFFICIAL | <- CMD=%d (%s), UID=%d, RESULT=%d, LEN=%d", 
        cmdId, cmdName or "Unknown", uid or 0, result or 0, length or 0)
    Logger.write(message)
    
    -- 记录完整的 HEX 数据
    if data and #data > 0 then
        local hexData = bufferToHex(data)
        Logger.write("           HEX: " .. hexData)
        
        -- 智能解析
        local parsed = smartParse(data)
        if parsed ~= "" then
            Logger.write("           PARSE: " .. parsed)
        end
    end
end

-- 记录分隔线
function Logger.separator()
    Logger.write("----------------------------------------")
end

-- 关闭日志文件
function Logger.close()
    if Logger.logFile then
        Logger.write("")
        Logger.write("========================================")
        Logger.write("Server Stopped")
        Logger.write("Time: " .. os.date("%Y-%m-%d %H:%M:%S"))
        Logger.write("========================================")
        Logger.write("")
        Logger.logFile:close()
        Logger.logFile = nil
        print(string.format("\27[36m[LOGGER] Log file closed: %s\27[0m", Logger.logPath))
    end
end

return Logger
