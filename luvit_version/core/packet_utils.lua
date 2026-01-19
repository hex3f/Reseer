-- 协议处理工具函数

local Utils = {}

-- 写入 4 字节大端整数
function Utils.writeUInt32BE(value)
    return string.char(
        math.floor(value / 16777216) % 256,
        math.floor(value / 65536) % 256,
        math.floor(value / 256) % 256,
        value % 256
    )
end

-- 写入 2 字节大端整数
function Utils.writeUInt16BE(value)
    return string.char(
        math.floor(value / 256) % 256,
        value % 256
    )
end

-- 读取 4 字节大端整数
function Utils.readUInt32BE(data, offset)
    offset = offset or 1
    return data:byte(offset) * 16777216 + 
           data:byte(offset + 1) * 65536 + 
           data:byte(offset + 2) * 256 + 
           data:byte(offset + 3)
end

-- 读取 2 字节大端整数
function Utils.readUInt16BE(data, offset)
    offset = offset or 1
    return data:byte(offset) * 256 + data:byte(offset + 1)
end

-- 字符串截断 (UTF-8 安全)
-- 保证截断后的字符串不会包含半个 UTF-8 字符
function Utils.utf8Truncate(str, maxBytes)
    if #str <= maxBytes then return str end
    
    local sub = str:sub(1, maxBytes)
    local len = #sub
    
    -- 从末尾检查字节，如果是 UTF-8 前导字节或连续字节，需要判断是否完整
    -- UTF-8 格式:
    -- 1字节: 0xxxxxxx
    -- 2字节: 110xxxxx 10xxxxxx
    -- 3字节: 1110xxxx 10xxxxxx 10xxxxxx
    -- 4字节: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
    
    local i = len
    while i > 0 do
        local byte = sub:byte(i)
        if byte < 0x80 then
            -- ASCII 字符，肯定是完整的 (除非在多字节序列中间截断，但在 ASCII 范围不会发生)
            return sub:sub(1, i)
        elseif byte >= 0xC0 then
            -- 多字节序列的起始字节
            -- 检查从这里开始是否完整
            local charLen = 0
            if byte >= 0xF0 then charLen = 4
            elseif byte >= 0xE0 then charLen = 3
            elseif byte >= 0xC0 then charLen = 2 end
            
            if i + charLen - 1 <= len then
                -- 完整字符
                return sub:sub(1, i + charLen - 1)
            else
                -- 不完整，丢弃这个起始字节及其后的部分 (即截断到 i-1)
                return sub:sub(1, i - 1)
            end
        else
            -- 0x80 <= byte < 0xC0: 连续字节
            -- 继续向前寻找起始字节
            i = i - 1
        end
    end
    
    return "" -- 理论上不应到达这里，除非全是连续字节
end

-- 写入固定长度字符串
function Utils.writeFixedString(str, length)
    -- 使用 UTF-8 安全截断
    local result = Utils.utf8Truncate(str or "", length)
    
    -- 补零
    while #result < length do
        result = result .. "\0"
    end
    return result
end

-- 读取固定长度字符串 (去除尾部空字符)
function Utils.readFixedString(data, offset, length)
    local str = data:sub(offset, offset + length - 1)
    -- 去除尾部空字符
    return str:gsub("\0+$", "")
end

-- 调试辅助：生成 Hex Dump
function Utils.hexDump(data, title)
    title = title or "Hex Dump"
    local output = string.format("\27[36m[%s] (%d bytes):\27[0m\n", title, #data)
    
    for i = 1, #data, 16 do
        local hexPart = ""
        local asciiPart = ""
        for j = i, math.min(i + 15, #data) do
            local byte = data:byte(j)
            hexPart = hexPart .. string.format("%02X ", byte)
            if byte >= 32 and byte < 127 then
                asciiPart = asciiPart .. string.char(byte)
            else
                asciiPart = asciiPart .. "."
            end
        end
        -- Padding
        local padding = 16 - math.min(16, #data - i + 1)
        hexPart = hexPart .. string.rep("   ", padding)
        
        output = output .. string.format("\27[90m  %04X: %s |%s|\27[0m\n", i - 1, hexPart, asciiPart)
    end
    return output
end

-- 构建响应包
function Utils.buildResponse(cmdId, userId, result, body)
    body = body or ""
    local length = 17 + #body
    return string.char(
        math.floor(length / 16777216) % 256,
        math.floor(length / 65536) % 256,
        math.floor(length / 256) % 256,
        length % 256,
        0x37,  -- version
        math.floor(cmdId / 16777216) % 256,
        math.floor(cmdId / 65536) % 256,
        math.floor(cmdId / 256) % 256,
        cmdId % 256,
        math.floor(userId / 16777216) % 256,
        math.floor(userId / 65536) % 256,
        math.floor(userId / 256) % 256,
        userId % 256,
        math.floor(result / 16777216) % 256,
        math.floor(result / 65536) % 256,
        math.floor(result / 256) % 256,
        result % 256
    ) .. body
end

return Utils
