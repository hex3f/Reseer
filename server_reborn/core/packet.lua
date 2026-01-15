
local Packet = {}
local Buffer = require('./bytebuffer').Buffer

-- Header Length: 17 Bytes
-- [Len:4][Ver:1][Cmd:4][Uid:4][Res:4]
Packet.HEADER_LEN = 17

function Packet.readHeader(chunk)
    if #chunk < Packet.HEADER_LEN then return nil end
    local buf = Buffer:new(chunk)
    
    local header = {
        len = buf:readInt32BE(1),
        ver = buf:readUInt8(5),
        cmdId = buf:readInt32BE(6),
        userId = buf:readInt32BE(10),
        result = buf:readInt32BE(14)
    }
    return header
end

function Packet.makeHeader(cmdId, userId, result, bodyLen)
    local totalLen = Packet.HEADER_LEN + bodyLen
    local buf = Buffer:new(Packet.HEADER_LEN)
    
    buf:writeInt32BE(1, totalLen)
    buf:writeUInt8(5, 49) -- Version, often '1' or '49' ('1')
    buf:writeInt32BE(6, cmdId)
    buf:writeInt32BE(10, userId)
    buf:writeInt32BE(14, result)
    
    return buf:toString()
end

return Packet
