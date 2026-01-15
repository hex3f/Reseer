
local Serializers = require('./serializers')
local Packet = require('../core/packet')
-- We can add modules later. For now, inline logic for Login/Map to verify architecture.

local Handlers = {}

-- CMD 1001: Login
Handlers[1001] = function(client, header, body)
    print("Handling Login...")
    -- Simple mock login response
    -- Structure: session(16) + keySeed(4) + UserInfo(setForLoginInfo)
    -- This is complex. For immediate testing, we might want to just handle Map Entry if getting past login is assumed?
    -- No, user restarts client. We MUST handle login.
    
    -- IMPORTANT: Protocol 1001 response is handled by Client.as / MainEntry.as
    -- Payload:
    -- session (16 bytes)
    -- keySeed (4 bytes)
    -- UserInfo for Login (See UserInfo.setForLoginInfo)
    
    -- Since we don't have the serializer for `setForLoginInfo` yet (it's different from `setForPeoleInfo`),
    -- We'll implement a basic one here or mock it carefully.
    
    -- Let's construct a minimal valid 1001 response.
    -- But honestly, implementing `setForLoginInfo` accurately is Phase 3.
    -- The user wants "Map Loading" fixed.
    -- If I fail 1001, we never get to 2001.
    
    local buf = require('../core/bytebuffer').Buffer:new(4096)
    local pos = 1
    
    -- Session (16)
    buf:write(pos, "1234567890123456", 16)
    pos = pos + 16
    
    -- KeySeed (4)
    buf:wuint(pos, 12345)
    pos = pos + 4
    
    -- UserInfo.setForLoginInfo
    -- userID (4)
    buf:wuint(pos, header.userId)
    pos = pos + 4
    -- regTime (4)
    buf:wuint(pos, os.time())
    pos = pos + 4
    -- nick (16)
    buf:write(pos, "SeerV2", 16)
    pos = pos + 16
    -- decorateList count? No, loop 5.
    for i=1,5 do buf:wuint(pos, 0); pos = pos + 4 end -- decorate (5*4=20)
    buf:wuint(pos, 0); pos = pos + 4 -- skipped int
    buf:wuint(pos, 0); pos = pos + 4 -- skipped int
    buf:wuint(pos, 0); pos = pos + 4 -- _loc4_
    buf:wuint(pos, 10000); pos = pos + 4 -- coins
    buf:wuint(pos, 0); pos = pos + 4 -- _loc5_ (vip flags)
    buf:wbyte(pos, 0); pos = pos + 1 -- _loc6_
    buf:wbyte(pos, 0); pos = pos + 1 -- cuteType
    buf:wuint(pos, 0); pos = pos + 4 -- dsFlag
    buf:wuint(pos, 0); pos = pos + 4 -- color
    buf:wuint(pos, 0); pos = pos + 4 -- texture
    buf:wuint(pos, 100); pos = pos + 4 -- energy
    buf:wbyte(pos, 0); pos = pos + 1 -- fireBuff
    buf:wuint(pos, 0); pos = pos + 4 -- jobTitle
    buf:wuint(pos, 0); pos = pos + 4 -- isActive
    buf:wuint(pos, 0); pos = pos + 4 -- oldSeerInvateCount
    buf:wuint(pos, 0); pos = pos + 4 -- blanketInvateCount
    buf:wuint(pos, 0); pos = pos + 4 -- toDayGetGiftCount
    buf:wuint(pos, 0); pos = pos + 4 -- totalGiftCount
    buf:wuint(pos, 0); pos = pos + 4 -- getGiftDate
    buf:wuint(pos, 0); pos = pos + 4 -- getGiftTime
    buf:wuint(pos, 0); pos = pos + 4 -- fightBadge
    buf:wuint(pos, 0); pos = pos + 4 -- fightBadge1
    buf:wuint(pos, 0); pos = pos + 4 -- fightPkBadge
    buf:wuint(pos, 0); pos = pos + 4 -- fightRoyale
    buf:wuint(pos, 1); pos = pos + 4 -- mapID (Default 1)
    buf:wuint(pos, 300); pos = pos + 4 -- x
    buf:wuint(pos, 300); pos = pos + 4 -- y
    buf:wuint(pos, 0); pos = pos + 4 -- timeToday
    buf:wuint(pos, 0); pos = pos + 4 -- lastLoginTime
    buf:wuint(pos, 0); pos = pos + 4 -- timeLimit
    buf:wuint(pos, 0); pos = pos + 4 -- logintimeThisTime
    
    local bodyData = buf:toString():sub(1, pos-1)
    local headData = Packet.makeHeader(1001, header.userId, 0, #bodyData)
    
    client:write(headData .. bodyData)
    print("Sent Login Response")
    
    -- Force send MapInfo in 1 second (Simulating the fix)
    local timer = require('timer')
    timer.setTimeout(1000, function()
        -- 1022 (Empty)
        -- 2001 (MapInfo)
        print("Force sending Map Info...")
        
        -- 2001
        local user = {userid=header.userId, nick="SeerV2"}
        local mapBody = Serializers.makeSeerMapUserInfo(user)
        local mapHead = Packet.makeHeader(2001, header.userId, 0, #mapBody)
        client:write(mapHead .. mapBody)
    end)
end

-- CMD 2001: Enter Map
Handlers[2001] = function(client, header, body)
    -- Client requesting map change
    print("Received Enter Map Request")
    -- Just echo the updated map info
    local user = {userid=header.userId, nick="SeerV2"}
    local mapBody = Serializers.makeSeerMapUserInfo(user)
    local mapHead = Packet.makeHeader(2001, header.userId, 0, #mapBody)
    client:write(mapHead .. mapBody)
end


return Handlers
