local bit = require("bit")

local BinaryReader = {}
BinaryReader.__index = BinaryReader

function BinaryReader.new(data)
    local self = setmetatable({}, BinaryReader)
    self.data = data or ""
    self.pos = 1
    self.len = #self.data
    return self
end

function BinaryReader:checkBound(n)
    if self.pos + n - 1 > self.len then
        return false
    end
    return true
end

function BinaryReader:readUInt8()
    if not self:checkBound(1) then return 0 end
    local b = string.byte(self.data, self.pos)
    self.pos = self.pos + 1
    return b
end

function BinaryReader:readInt8()
    local b = self:readUInt8()
    if b > 127 then b = b - 256 end
    return b
end

function BinaryReader:readUInt16BE()
    if not self:checkBound(2) then return 0 end
    local b1, b2 = string.byte(self.data, self.pos, self.pos + 1)
    self.pos = self.pos + 2
    return bit.lshift(b1, 8) + b2
end

function BinaryReader:readInt16BE()
    local val = self:readUInt16BE()
    if val > 32767 then val = val - 65536 end
    return val
end

function BinaryReader:readUInt32BE()
    if not self:checkBound(4) then return 0 end
    local b1, b2, b3, b4 = string.byte(self.data, self.pos, self.pos + 3)
    self.pos = self.pos + 4
    return bit.lshift(b1, 24) + bit.lshift(b2, 16) + bit.lshift(b3, 8) + b4
end

function BinaryReader:readInt32BE()
    local val = self:readUInt32BE()
    if val > 2147483647 then val = val - 4294967296 end
    return val
end

function BinaryReader:readStringFixed(len)
    if not self:checkBound(len) then return "" end
    local str = string.sub(self.data, self.pos, self.pos + len - 1)
    self.pos = self.pos + len
    -- Remove null padding
    local nullPos = string.find(str, "\0")
    if nullPos then
        str = string.sub(str, 1, nullPos - 1)
    end
    return str
end

function BinaryReader:readBytes(len)
    if not self:checkBound(len) then return "" end
    local str = string.sub(self.data, self.pos, self.pos + len - 1)
    self.pos = self.pos + len
    return str
end

function BinaryReader:getRemaining()
    if self.pos > self.len then return "" end
    return string.sub(self.data, self.pos)
end

return BinaryReader
