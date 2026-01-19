-- Logger Module for RecSeer
-- 记录所有请求和交互到统一的日志文件
-- 提供带时间戳的 tprint 函数供所有模块使用

local fs = require('fs')
local os = require('os')

local Logger = {}
Logger.logFile = nil
Logger.logPath = "logs/server.log"  -- 固定的日志文件名

-- ==================== 工具函数 ====================

-- 获取当前时间戳 (时:分:秒)
function Logger.getTimeStr()
    return os.date("%H:%M:%S")
end

-- 带时间戳的 print 函数
function Logger.tprint(...)
    local args = {...}
    if #args > 0 then
        args[1] = string.format("[%s] %s", Logger.getTimeStr(), tostring(args[1]))
    end
    print(table.unpack(args))
end

-- 打印分割线 (用于 Enter 键)
function Logger.printSeparator()
    print("")
    print("\27[90m════════════════════════════════════════════════════════════════════════════════\27[0m")
    print("")
end

-- 初始化日志系统
function Logger.init()
    -- 创建 logs 目录
    pcall(function() fs.mkdirSync("logs") end)
    
    -- 以追加模式打开日志文件
    Logger.logFile = io.open(Logger.logPath, "a")
    
    if Logger.logFile then
        Logger.logFile:setvbuf("line") -- 行缓冲，立即写入
        Logger.write("")
        Logger.write("================================================================================")
        Logger.write("Server Started - " .. os.date("%Y-%m-%d %H:%M:%S"))
        Logger.write("================================================================================")
        Logger.write("")
        print(string.format("\27[36m[LOGGER] 日志文件: %s\27[0m", Logger.logPath))
        return true
    else
        print(string.format("\27[31m[LOGGER] 无法打开日志文件: %s\27[0m", Logger.logPath))
        return false
    end
end

-- 写入日志（不带时间戳）
function Logger.writeRaw(message)
    if Logger.logFile then
        Logger.logFile:write(message .. "\n")
    end
end

-- 写入日志（带时间戳）
function Logger.write(message)
    if Logger.logFile then
        local timestamp = os.date("%H:%M:%S")
        Logger.logFile:write(string.format("[%s] %s\n", timestamp, message))
    end
end

-- 记录资源请求
function Logger.logResource(method, path, status, size)
    local message = string.format("RES  | %s %s -> %d (%s bytes)", 
        method, path, status, size or "?")
    Logger.write(message)
end

-- 将 buffer 转换为 HEX 字符串（每行16字节）
local function bufferToHexFormatted(data, indent)
    indent = indent or "     "
    if type(data) ~= "string" or #data == 0 then return "" end
    
    local lines = {}
    local line = ""
    local ascii = ""
    
    for i = 1, #data do
        local byte = string.byte(data, i)
        line = line .. string.format("%02X ", byte)
        
        -- ASCII 可打印字符
        if byte >= 32 and byte <= 126 then
            ascii = ascii .. string.char(byte)
        else
            ascii = ascii .. "."
        end
        
        if i % 16 == 0 then
            table.insert(lines, indent .. line .. " | " .. ascii)
            line = ""
            ascii = ""
        elseif i % 8 == 0 then
            line = line .. " "
        end
    end
    
    -- 处理最后一行
    if #line > 0 then
        -- 补齐空格
        local remaining = 16 - (#data % 16)
        if remaining < 16 then
            for i = 1, remaining do
                line = line .. "   "
                if (#data % 16) + i == 8 then
                    line = line .. " "
                end
            end
        end
        table.insert(lines, indent .. line .. " | " .. ascii)
    end
    
    return table.concat(lines, "\n")
end

-- 简短的 HEX 字符串（单行）
local function bufferToHexShort(data, maxLen)
    maxLen = maxLen or 32
    if type(data) ~= "string" or #data == 0 then return "" end
    
    local hex = ""
    local len = math.min(#data, maxLen)
    for i = 1, len do
        hex = hex .. string.format("%02X ", string.byte(data, i))
    end
    if #data > maxLen then
        hex = hex .. "... (" .. #data .. " bytes total)"
    end
    return hex
end

-- 记录游戏命令（完整数据）
function Logger.logCommand(direction, cmdId, cmdName, uid, length, data)
    local arrow = direction == "SEND" and ">>>" or "<<<"
    local dirLabel = direction == "SEND" and "CLIENT->SERVER" or "SERVER->CLIENT"
    
    Logger.writeRaw("")
    Logger.writeRaw(string.format("---- %s CMD %d (%s) ----", dirLabel, cmdId, cmdName or "Unknown"))
    Logger.write(string.format("GAME | %s CMD=%d (%s) UID=%d LEN=%d", 
        arrow, cmdId, cmdName or "Unknown", uid or 0, length or 0))
    
    -- 记录完整的 HEX 数据
    if data and #data > 0 then
        Logger.writeRaw("     HEADER (17 bytes):")
        if #data >= 17 then
            Logger.writeRaw(bufferToHexFormatted(data:sub(1, 17), "       "))
        end
        
        if #data > 17 then
            Logger.writeRaw("     BODY (" .. (#data - 17) .. " bytes):")
            Logger.writeRaw(bufferToHexFormatted(data:sub(18), "       "))
        end
    end
    Logger.writeRaw("")
end

-- 记录登录事件
function Logger.logLogin(event, uid, info)
    Logger.write(string.format("AUTH | %s | UID=%d | %s", event, uid or 0, info or ""))
end

-- 记录官服发送 (用于 trafficlogger)
function Logger.logOfficialSend(cmdId, cmdName, userId, length, data)
    Logger.logCommand("SEND", cmdId, cmdName, userId, length, data)
end

-- 记录官服接收 (用于 trafficlogger)
function Logger.logOfficialRecv(cmdId, cmdName, userId, result, length, data)
    local arrow = "<<<"
    Logger.writeRaw("")
    Logger.writeRaw(string.format("---- SERVER->CLIENT CMD %d (%s) ----", cmdId, cmdName or "Unknown"))
    Logger.write(string.format("GAME | %s CMD=%d (%s) UID=%d RES=%d LEN=%d", 
        arrow, cmdId, cmdName or "Unknown", userId or 0, result or 0, length or 0))
    
    -- 记录完整的 HEX 数据
    if data and #data > 0 then
        Logger.writeRaw("     HEADER (17 bytes):")
        if #data >= 17 then
            Logger.writeRaw(bufferToHexFormatted(data:sub(1, 17), "       "))
        end
        
        if #data > 17 then
            Logger.writeRaw("     BODY (" .. (#data - 17) .. " bytes):")
            Logger.writeRaw(bufferToHexFormatted(data:sub(18), "       "))
        end
    end
    Logger.writeRaw("")
end

-- 记录错误
function Logger.logError(module, error)
    Logger.write(string.format("ERR  | [%s] %s", module, error))
end

-- 记录分隔线
function Logger.separator()
    Logger.writeRaw("--------------------------------------------------------------------------------")
end

-- 关闭日志文件
function Logger.close()
    if Logger.logFile then
        Logger.writeRaw("")
        Logger.writeRaw("================================================================================")
        Logger.write("Server Stopped")
        Logger.writeRaw("================================================================================")
        Logger.logFile:close()
        Logger.logFile = nil
    end
end

return Logger
