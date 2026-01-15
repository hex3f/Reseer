

local bit = require('bit')

local ByteBuffer = {}
ByteBuffer.__index = ByteBuffer

function ByteBuffer:new(size)
    local obj = {
        data = {},
        size = size or 4096,
        pos = 1
    }
    setmetatable(obj, ByteBuffer)
    return obj
end

function ByteBuffer:wbyte(pos, val)
    self.data[pos] = val % 256
end

function ByteBuffer:wushort(pos, val)
    self.data[pos] = bit.rshift(val, 8) % 256
    self.data[pos+1] = val % 256
end

function ByteBuffer:wuint(pos, val)
    self.data[pos]   = bit.rshift(val, 24) % 256
    self.data[pos+1] = bit.rshift(val, 16) % 256
    self.data[pos+2] = bit.rshift(val, 8) % 256
    self.data[pos+3] = val % 256
end

function ByteBuffer:writeInt32BE(pos, val)
    self:wuint(pos, val)
end

function ByteBuffer:writeUInt8(pos, val)
    self:wbyte(pos, val)
end

function ByteBuffer:write(pos, str, maxLen)
    for i = 1, #str do
        if maxLen and i > maxLen then break end
        self.data[pos + i - 1] = string.byte(str, i)
    end
    -- Zero pad if maxLen provided
    if maxLen and #str < maxLen then
        for i = #str + 1, maxLen do
            self.data[pos + i - 1] = 0
        end
    end
end

function ByteBuffer:toString()
    local t = {}
    -- Find max index
    local max = 0
    for k,v in pairs(self.data) do
        if k > max then max = k end
    end
    
    for i = 1, max do
        table.insert(t, string.char(self.data[i] or 0))
    end
    return table.concat(t)
end

-- Read methods for Packet parser
function ByteBuffer:readInt32BE(pos)
    local b1 = self.data[pos] or 0
    local b2 = self.data[pos+1] or 0
    local b3 = self.data[pos+2] or 0
    local b4 = self.data[pos+3] or 0
    return bit.bor(bit.lshift(b1, 24), bit.lshift(b2, 16), bit.lshift(b3, 8), b4)
end

function ByteBuffer:readUInt8(pos)
    return self.data[pos] or 0
end

-- Constructor wrapper to match require('buffer').Buffer:new() pattern
return {
    Buffer = {
        new = function(self, content_or_size)
            if type(content_or_size) == 'string' then
                local b = ByteBuffer:new(#content_or_size)
                for i=1, #content_or_size do
                    b.data[i] = string.byte(content_or_size, i)
                end
                return b
            else
                return ByteBuffer:new(content_or_size)
            end
        end
    }
}
