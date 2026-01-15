local net = require "net"
local index = getmetatable(net.Socket).__index
local char = string.char
local band = bit.band
local rshift = bit.rshift
local rep = string.rep
local sub = string.sub

-- 写入 32 位无符号整数（大端序）
function index.wuint(socket, data)
    socket:write(char(rshift(band(data, 0xFF000000), 24)))
    socket:write(char(rshift(band(data, 0xFF0000), 16)))
    socket:write(char(rshift(band(data, 0xFF00), 8)))
    socket:write(char(band(data, 0xFF)))
end

-- 写入 16 位无符号整数（大端序）
function index.wushort(socket, data)
    socket:write(char(rshift(band(data, 0xFF00), 8)))
    socket:write(char(band(data, 0xFF)))
end

-- 写入 8 位无符号整数（字节）
function index.wbyte(socket, data)
    socket:write(char(band(data, 0xFF)))
end

-- 写入固定长度字符串，不足部分用 null 填充
function index.wstr(socket, data, len)
    local actual_len = #data
    if len < actual_len then
        -- 字符串太长，截断
        socket:write(sub(data, 1, len))
    else
        -- 写入字符串
        socket:write(data)
        -- 填充剩余部分
        if len > actual_len then
            socket:write(rep("\0", len - actual_len))
        end
    end
end
