local BinaryWriter = require('../utils/binary_writer')
local BinaryReader = require('../utils/binary_reader')

local Utils = {}

-- 构建响应包 (Protocol V1)
-- Header: Length(4) + Version(1) + CmdId(4) + UserId(4) + Result(4)
function Utils.buildResponse(cmdId, userId, result, body)
    if not body then body = "" end
    local headLen = 17
    local totalLen = headLen + #body
    
    local w = BinaryWriter.new()
    w:writeUInt32BE(totalLen)
    w:writeUInt8(0x31) -- Version '1' (0x31)
    w:writeUInt32BE(cmdId)
    w:writeUInt32BE(userId or 0)
    w:writeInt32BE(result or 0) -- Result can be error code (signed?)
    w:writeBytes(body)
    return w:toString()
end

-- ==================== Legacy Write Wrappers ====================

function Utils.writeUInt32BE(val)
    local w = BinaryWriter.new()
    w:writeUInt32BE(val)
    return w:toString()
end

function Utils.writeInt32BE(val)
    local w = BinaryWriter.new()
    w:writeInt32BE(val)
    return w:toString()
end

function Utils.writeUInt16BE(val)
    local w = BinaryWriter.new()
    w:writeUInt16BE(val)
    return w:toString()
end

function Utils.writeUInt8(val)
    local w = BinaryWriter.new()
    w:writeUInt8(val)
    return w:toString()
end

function Utils.writeFixedString(str, len)
     local w = BinaryWriter.new()
     w:writeStringFixed(str, len)
     return w:toString()
end

-- ==================== Legacy Read Wrappers ====================
-- Note: pos is 1-based index

function Utils.readUInt32BE(str, pos)
    if type(str) ~= "string" then return 0 end
    local b1, b2, b3, b4 = string.byte(str, pos, pos+3)
    if not b1 or not b4 then return 0 end
    return b1 * 16777216 + b2 * 65536 + b3 * 256 + b4
end

function Utils.readUInt16BE(str, pos)
    if type(str) ~= "string" then return 0 end
    local b1, b2 = string.byte(str, pos, pos+1)
    if not b1 or not b2 then return 0 end
    return b1 * 256 + b2
end

function Utils.readUInt8(str, pos)
    if type(str) ~= "string" then return 0 end
    local b = string.byte(str, pos)
    return b or 0
end

function Utils.readFixedString(str, pos, len)
    if type(str) ~= "string" then return "" end
    local sub = string.sub(str, pos, pos + len - 1)
    -- Remove trailing nulls
    local nullPos = sub:find("\0")
    if nullPos then
        return sub:sub(1, nullPos - 1)
    end
    return sub
end

return Utils
