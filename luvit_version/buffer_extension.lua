local buffer = require "buffer"

-- 优化的字符串写入函数
-- 写入固定长度的字符串，不足部分用 null 填充
buffer.Buffer.write = function(buf, pos, str, len)
    local str_len = #str
    local write_len = math.min(str_len, len)
    
    -- 写入字符串内容
    for i = 0, write_len - 1 do
        buf:writeUInt8(pos + i, string.byte(str, i + 1))
    end
    
    -- 填充剩余部分为 0
    for i = write_len, len - 1 do
        buf:writeUInt8(pos + i, 0)
    end
end

buffer.Buffer.wuint = buffer.Buffer.writeUInt32BE
buffer.Buffer.wbyte = buffer.Buffer.writeUInt8
buffer.Buffer.wushort = buffer.Buffer.writeUInt16BE

buffer.Buffer.ruint = buffer.Buffer.readUInt32BE
buffer.Buffer.rint = buffer.Buffer.readInt32BE
buffer.Buffer.rbyte = buffer.Buffer.readUInt8