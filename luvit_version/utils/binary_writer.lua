local bit = require("bit")

local BinaryWriter = {}
BinaryWriter.__index = BinaryWriter

function BinaryWriter.new()
    local self = setmetatable({}, BinaryWriter)
    self.buffer = {}
    return self
end

function BinaryWriter:writeUInt8(val)
    val = math.floor(val or 0)
    if val < 0 then val = 0 end
    if val > 255 then val = 255 end
    table.insert(self.buffer, string.char(val))
    return self
end

function BinaryWriter:writeInt8(val)
    val = math.floor(val or 0)
    if val < -128 then val = -128 end
    if val > 127 then val = 127 end
    if val < 0 then val = 256 + val end
    table.insert(self.buffer, string.char(val))
    return self
end

function BinaryWriter:writeUInt16BE(val)
    val = math.floor(val or 0)
    if val < 0 then val = 0 end
    if val > 65535 then val = 65535 end
    local b1 = bit.rshift(val, 8)
    local b2 = bit.band(val, 0xFF)
    table.insert(self.buffer, string.char(b1, b2))
    return self
end

function BinaryWriter:writeInt16BE(val)
    val = math.floor(val or 0)
    if val < -32768 then val = -32768 end
    if val > 32767 then val = 32767 end
    if val < 0 then val = 65536 + val end
    local b1 = bit.rshift(val, 8)
    local b2 = bit.band(val, 0xFF)
    table.insert(self.buffer, string.char(b1, b2))
    return self
end

function BinaryWriter:writeUInt32BE(val)
    val = math.floor(val or 0)
    if val < 0 then val = 0 end
    if val > 4294967295 then val = 4294967295 end
    local b1 = bit.rshift(val, 24)
    local b2 = bit.band(bit.rshift(val, 16), 0xFF)
    local b3 = bit.band(bit.rshift(val, 8), 0xFF)
    local b4 = bit.band(val, 0xFF)
    table.insert(self.buffer, string.char(b1, b2, b3, b4))
    return self
end

function BinaryWriter:writeInt32BE(val)
    val = math.floor(val or 0)
    if val < -2147483648 then val = -2147483648 end
    if val > 2147483647 then val = 2147483647 end
    if val < 0 then val = 4294967296 + val end
    local b1 = bit.rshift(val, 24)
    local b2 = bit.band(bit.rshift(val, 16), 0xFF)
    local b3 = bit.band(bit.rshift(val, 8), 0xFF)
    local b4 = bit.band(val, 0xFF)
    table.insert(self.buffer, string.char(b1, b2, b3, b4))
    return self
end

function BinaryWriter:writeStringFixed(str, len)
    str = str or ""
    if #str > len then
        -- Truncate safely (simple byte truncation for now, 
        -- assuming UTF-8 safety is handled or acceptable for fixed fields)
        str = string.sub(str, 1, len)
    end
    table.insert(self.buffer, str)
    local padding = len - #str
    if padding > 0 then
        table.insert(self.buffer, string.rep("\0", padding))
    end
    return self
end

-- Write raw bytes (string)
function BinaryWriter:writeBytes(bytes)
    if bytes then
        table.insert(self.buffer, bytes)
    end
    return self
end

function BinaryWriter:toString()
    return table.concat(self.buffer)
end

function BinaryWriter:getLength()
    -- Note: This is an O(N) operation if called repeatedly, 
    -- but usually we only call toString() once at the end.
    -- If needed we can track length in a variable.
    local len = 0
    for _, s in ipairs(self.buffer) do
        len = len + #s
    end
    return len
end

return BinaryWriter
