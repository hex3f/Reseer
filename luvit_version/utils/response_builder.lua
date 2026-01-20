-- 统一协议构建器
-- 职责: 构建符合 NieoCore SocketImpl 拆包逻辑的标准响应包
-- 协议头: Length(4) + Version(1) + CmdId(4) + UserId(4) + Result(4) + Body(...)

local BinaryWriter = require('utils/binary_writer')

local ResponseBuilder = {}

-- 构建响应包
-- @param cmdId (number) 命令ID
-- @param userId (number) 用户ID
-- @param result (number) 结果码 (0=成功)
-- @param body (string/BinaryWriter) 包体内容
function ResponseBuilder.build(cmdId, userId, result, body)
    local writer = BinaryWriter.new()
    local bodyStr = ""
    
    if type(body) == "string" then
        bodyStr = body
    elseif type(body) == "table" and body.toString then
        bodyStr = body:toString()
    end
    
    -- 计算包全长: Header(17) + BodyLen
    -- Header: Len(4) + Ver(1) + Cmd(4) + User(4) + Res(4) = 17 bytes
    local totalLen = 17 + #bodyStr
    
    writer:writeUInt32BE(totalLen)       -- 1. Length
    writer:writeUInt8(string.byte('1'))  -- 2. Version (Char '1' = 49)
    writer:writeUInt32BE(cmdId)          -- 3. Command ID
    writer:writeUInt32BE(userId)         -- 4. User ID
    writer:writeInt32BE(result)          -- 5. Result Code
    writer:writeBytes(bodyStr)           -- 6. Body
    
    return writer:toString()
end

return ResponseBuilder
