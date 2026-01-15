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

-- 写入固定长度字符串
function Utils.writeFixedString(str, length)
    local result = str:sub(1, length)
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
