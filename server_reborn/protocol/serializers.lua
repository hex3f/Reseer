
local Buffer = require('../core/bytebuffer').Buffer
local bit = require('../core/bit')

local Serializers = {}

-- Helper to write 0 bytes
local function writeZeros(buf, pos, count)
    for i = 1, count do
        buf:wbyte(pos, 0)
        pos = pos + 1
    end
    return pos
end

-- Strictly matches UserInfo.as setForPeoleInfo
-- This is the "Gold Standard" for serialization
function Serializers.makeSeerMapUserInfo(user)
    -- Estimate size: 4KB is safe
    local buf = Buffer:new(4096)
    local pos = 1
    
    -- param1.hasSimpleInfo = true (Internal logic, not serialized)
    
    -- sysTime (4)
    buf:wuint(pos, os.time())
    pos = pos + 4
    
    -- userID (4)
    buf:wuint(pos, user.userid or 0)
    pos = pos + 4
    
    -- nick (16)
    buf:write(pos, user.nick or "Seer", 16)
    pos = pos + 16
    
    -- curTitle (4)
    buf:wuint(pos, user.curTitle or 0)
    pos = pos + 4
    
    -- color (4)
    buf:wuint(pos, user.color or 0)
    pos = pos + 4
    
    -- texture (4)
    buf:wuint(pos, user.texture or 0)
    pos = pos + 4
    
    -- jobTitle (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- isFamous (4) - Boolean as uint
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- vipTitle (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- vip/viped (4) (Bitmask)
    -- bit 0: vip, bit 1: viped
    local vipFlags = 0
    if user.vip then vipFlags = bit.bor(vipFlags, 1) end
    buf:wuint(pos, vipFlags)
    pos = pos + 4
    
    -- isExtremeNono (1)
    buf:wbyte(pos, 0)
    pos = pos + 1
    
    -- vipStage (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- actionType (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- pos (Point) -> x(4), y(4)
    buf:wuint(pos, user.x or 300)
    pos = pos + 4
    buf:wuint(pos, user.y or 300)
    pos = pos + 4
    
    -- action (4)
    buf:wuint(pos, user.action or 0)
    pos = pos + 4
    
    -- direction (4)
    buf:wuint(pos, user.direction or 0)
    pos = pos + 4
    
    -- changeShape (4)
    buf:wuint(pos, user.changeShape or 0)
    pos = pos + 4
    
    -- darkLight (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- luoboteStatus (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- aresUnionTeam (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- aiErFuAndMiYouLaStatus (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- usersCamp (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- spiritTime (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- spiritID (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- isBright (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- specialBright (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- otherPetID (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- otherBright (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- otherEatBright (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- fightFlag (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- teacherID (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- studentID (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- nonoState (4) -> Loop 32 bits read
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- nonoColor (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- superNono (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- nonoChangeToPet (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- transId (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- transDuration (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- Open flags array
    -- readUnsignedInt count -> then loop count
    -- UserInfo.as line 651: `var _loc7_:uint = uint(param2.readUnsignedInt());`
    
    -- We will send 2 entries (standard)
    buf:wuint(pos, 2) 
    pos = pos + 4
    
    -- Entry 1 (Flags 0-31)
    buf:wuint(pos, 0xFFFFFFFF)
    pos = pos + 4
    
    -- Entry 2 (Flags 32-63)
    buf:wuint(pos, 0xFFFFFFFF)
    pos = pos + 4
    
    -- mountId (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- GroupInfo
    -- GroupIDInfo (This was the bug!)
    buf:wushort(pos, 0) -- svrID (2)
    pos = pos + 2
    buf:wuint(pos, 0)   -- seqID (4)
    pos = pos + 4
    buf:wuint(pos, 0)   -- time (4)
    pos = pos + 4
    
    -- GroupInfo fields
    buf:wuint(pos, 0)   -- leaderID (4)
    pos = pos + 4
    buf:write(pos, "", 16) -- groupName (16)
    pos = pos + 16
    buf:wbyte(pos, 0)   -- sctID (1)
    pos = pos + 1
    buf:wbyte(pos, 0)   -- pointID (1)
    pos = pos + 1
    
    -- TeamInfo
    buf:wuint(pos, 0)   -- id (4)
    pos = pos + 4
    buf:wuint(pos, 0)   -- coreCount (4)
    pos = pos + 4
    buf:wuint(pos, 0)   -- isShow (4)
    pos = pos + 4
    buf:wushort(pos, 0) -- logoBg (2)
    pos = pos + 2
    buf:wushort(pos, 0) -- logoIcon (2)
    pos = pos + 2
    buf:wushort(pos, 0) -- logoColor (2)
    pos = pos + 2
    buf:wushort(pos, 0) -- txtColor (2)
    pos = pos + 2
    buf:write(pos, "", 4) -- logoWord (4)
    pos = pos + 4
    
    -- Clothes Array
    -- count (4)
    buf:wuint(pos, 0) 
    pos = pos + 4
    -- Loop items: param2.readUnsignedInt(), param2.readUnsignedInt() -> PeopleItemInfo(id, level)
    -- Writing 0 items
    
    -- topFightEffect (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- fireBuff (1)
    buf:wbyte(pos, 0)
    pos = pos + 1
    
    -- tangyuan (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- foolsdayMask (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- tigerFightTeam (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- tigerFightScore (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- crackCupTeamId (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- lordOfWarTeamId (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- decorateList count (4)
    -- UserInfo.as line 731
    buf:wuint(pos, 5) -- Count, actually unused by the loop logic (hardcoded 5) but read. 
                        -- Wait, AS code reads count, then ignores it and loops 5 times?
                        -- _loc15_ = readUint(). Loop _loc16_ < 5.
                        -- Yes.
    pos = pos + 4
    
    -- decorateList Items (5 * 4 bytes)
    -- PeopleItemInfo constructor takes (id, level=0)
    -- readUnsignedInt() is passed as ID.
    for i=1, 5 do
        buf:wuint(pos, 0)
        pos = pos + 4
    end
    
    -- reserved (4)
    -- UserInfo.as Line 738
    buf:wuint(pos, 0)
    pos = pos + 4
    
    return buf:toString():sub(1, pos-1)
end

return Serializers
