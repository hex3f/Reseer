-- 赛尔号游戏服务器协议处理模块
-- 移除了摩尔庄园相关代码

local gpp = {}
gpp.handler = {}

local Game = TO_BE_LOAD
local Map = TO_BE_LOAD
local mapsinfo = require "./mapsinfo"
local Algorithm = nil  -- 延迟加载
local bit = require "../bitop_compat"

local buffer = require "buffer"
local timer = require "timer"
require "../easybytewrite"
local offset = 17 -- 包头长度

-- 全局变量
gpp.Result = 0  -- 序列号
gpp.HaveLogin = false  -- 是否已登录

-- 安全读取辅助函数
function gpp.safeRead32(buf, length, pos)
    if length >= pos + 3 then
        return buf:ruint(pos)
    end
    return 0
end

function gpp.safeRead8(buf, length, pos)
    if length >= pos then
        return buf:rbyte(pos)
    end
    return 0
end

function gpp.initLibs()
    Game = require "./game"
    Map = require "./map"
    -- 尝试加载加密模块
    pcall(function()
        Algorithm = require "../seer_algorithm"
    end)
end

function gpp.makeHead(cmdId,userid,errorId,bodylen)
    local head = buffer.Buffer:new(offset)
    head:wuint(1,offset+bodylen) --PkgLen
    head:wbyte(5,0) --Version
    head:wuint(6,cmdId) --Command
    head:wuint(10,userid) --UserID
    head:wuint(14,errorId) --Result
    return tostring(head)
end

function gpp.mapBroadcast(map,cmdId,errorId,body)
    for i=1,#map do
        local iuser = map[i]
        local head = gpp.makeHead(cmdId,iuser.userid,errorId,#body)
        if iuser.send then
            iuser:send(head .. body)
        else
            iuser.socket:write(head)
            iuser.socket:write(body)
        end
    end
end

function gpp.makeAllSceneUser(map)
    local buft = {}
    local buf = buffer.Buffer:new(4)
    buf:wuint(1,#map)
    buft[#buft+1] = tostring(buf)
    for i=1,#map do
        local iuser = map[i]
        local infodata = gpp.makeSeerMapUserInfo(iuser)
        buft[#buft+1] = infodata
    end
    return table.concat(buft)
end

-- 赛尔号地图用户信息
function gpp.makeSeerMapUserInfo(user)
    -- 根据 setForPeoleInfo 格式
    local buf = buffer.Buffer:new(4096)
    local pos = 1
    
    -- sysTime (4)
    buf:wuint(pos, os.time())
    pos = pos + 4
    
    -- userID (4)
    buf:wuint(pos, user.userid)
    pos = pos + 4
    
    -- nick (16)
    buf:write(pos, user.nick or "赛尔", 16)
    pos = pos + 16
    
    -- curTitle (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- color (4) - Blue character color
    buf:wuint(pos, user.color or 0x66CCFF)
    pos = pos + 4
    
    -- texture (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- jobTitle (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- isFamous (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- vipTitle (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- vip flags (4) - Set VIP to show VIP badge
    buf:wuint(pos, user.vip and 1 or 1)  -- Default VIP on
    pos = pos + 4
    
    -- isExtremeNono (1)
    buf:wbyte(pos, 0)
    pos = pos + 1
    
    -- vipStage (4) - VIP stage 1-4
    buf:wuint(pos, user.vipStage or 2)
    pos = pos + 4
    
    -- actionType (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- pos.x (4)
    buf:wuint(pos, user.x or 300)
    pos = pos + 4
    
    -- pos.y (4)
    buf:wuint(pos, user.y or 300)
    pos = pos + 4
    
    -- action (4)
    buf:wuint(pos, user.action or 0)
    pos = pos + 4
    
    -- direction (4)
    buf:wuint(pos, user.direction or 0)
    pos = pos + 4
    
    -- changeShape (4)
    buf:wuint(pos, 0)
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
    
    -- nonoState (4)
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
    
    -- openFlags count (4)
    buf:wuint(pos, 2)
    pos = pos + 4
    
    -- openFlags[0] (4)
    buf:wuint(pos, 0xFFFFFFFF)
    pos = pos + 4
    
    -- openFlags[1] (4)
    buf:wuint(pos, 0xFFFFFFFF)
    pos = pos + 4
    
    -- mountId (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- GroupInfo
    -- GroupIDInfo
    buf:wushort(pos, 0)  -- svrID (2)
    pos = pos + 2
    buf:wuint(pos, 0)    -- seqID (4)
    pos = pos + 4
    buf:wuint(pos, 0)    -- time (4)
    pos = pos + 4
    buf:wuint(pos, 0)  -- leaderID
    pos = pos + 4
    buf:write(pos, "", 16)  -- groupName
    pos = pos + 16
    buf:wbyte(pos, 0)  -- sctID
    pos = pos + 1
    buf:wbyte(pos, 0)  -- pointID
    pos = pos + 1
    
    -- TeamInfo
    buf:wuint(pos, 0)  -- id
    pos = pos + 4
    buf:wuint(pos, 0)  -- coreCount
    pos = pos + 4
    buf:wuint(pos, 0)  -- isShow
    pos = pos + 4
    buf:wushort(pos, 0)  -- logoBg
    pos = pos + 2
    buf:wushort(pos, 0)  -- logoIcon
    pos = pos + 2
    buf:wushort(pos, 0)  -- logoColor
    pos = pos + 2
    buf:wushort(pos, 0)  -- txtColor
    pos = pos + 2
    buf:write(pos, "", 4)  -- logoWord
    pos = pos + 4
    
    -- clothes count (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
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
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- decorateList[5] (20)
    for i = 0, 4 do
        buf:wuint(pos, 0)
        pos = pos + 4
    end
    
    -- reserved (4)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    print(string.format("\27[35m[DEBUG] makeSeerMapUserInfo size: %d bytes\27[0m", pos-1))
    return tostring(buf):sub(1, pos-1)
end

function gpp.sendAllSceneUser(user,mapid)
    local body = gpp.makeAllSceneUser(Map.getMap(mapid or user.mapid))
    local head = gpp.makeHead(2003,user.userid,0,#body)
    user:send(head .. body)
end

function gpp.sendEnterMap(user,user_entering)
    local body = gpp.makeSeerMapUserInfo(user_entering)
    local head = gpp.makeHead(2001,user.userid,0,#body)
    user:send(head .. body)
end

function gpp.broadcastEnterMap(map,user_entering)
    local body = gpp.makeSeerMapUserInfo(user_entering)
    gpp.mapBroadcast(map,2001,0,body)
end

function gpp.makeMapInfo(mapid,type)
    local buf = buffer.Buffer:new(80)
    buf:wuint(1,mapid) --MapId
    buf:wuint(5,type) --MapType
    buf:write(9,mapsinfo[mapid] or "",64) --Name
    buf:wuint(73,1) --type
    buf:wuint(77,0) --itemCount
    return tostring(buf)
end

function gpp.makeChat(user,towho,str)
    local buf = buffer.Buffer:new(28+#str)
    buf:wuint(1,user.userid)
    buf:write(5,user.nick or "赛尔",16)
    buf:wuint(21,0) --friend
    buf:wuint(25,#str) --msglen
    buf:write(29,str,#str) --msg
    return tostring(buf)
end

function gpp.sendChat(user,user_sender,towho,str)
    local body = gpp.makeChat(user_sender,towho,str)
    local head = gpp.makeHead(2102,user.userid,0,#body)
    user:send(head .. body)
end

function gpp.broadcastChat(map,user_sender,towho,str)
    local body = gpp.makeChat(user_sender,towho,str)
    gpp.mapBroadcast(map,2102,0,body)
end

function gpp.makeWalk(userid,endx,endy)
    local buf = buffer.Buffer:new(128)
    buf:wuint(1,userid)
    buf:wuint(5,endx)
    buf:wuint(9,endy)
    return tostring(buf)
end

function gpp.broadcastWalk(map,userid,endx,endy)
    local body = gpp.makeWalk(userid,endx,endy)
    gpp.mapBroadcast(map,2101,0,body)  -- PEOPLE_WALK
end

function gpp.makeAction(userid,action,direction)
    local buf = buffer.Buffer:new(128)
    buf:wuint(1,userid)
    buf:wuint(5,action)
    buf:wbyte(9,direction)
    return tostring(buf):sub(1, 9)
end

function gpp.broadcastAction(map,user,action,direction)
    local body = gpp.makeAction(user.userid,action,direction)
    gpp.mapBroadcast(map,2103,0,body)  -- PEOPLE_ACTION
end

function gpp.makeLeaveMap(userid)
    local buf = buffer.Buffer:new(4)
    buf:wuint(1, userid)
    return tostring(buf)
end

function gpp.makeServerTime()
    local buf = buffer.Buffer:new(8)
    buf:wuint(1,os.time()) --sec
    buf:wuint(5,0) -- millisec
    return tostring(buf)
end

function gpp.makeBlacklist(userid)
    local buf = buffer.Buffer:new(4)
    buf:wuint(1,0) --Count
    return tostring(buf)
end

function gpp.preparse(data)
    local buf = buffer.Buffer:new(data)
    return buf:readUInt32BE(1)
end

function gpp.parse(data,socket,user)
    local buf = buffer.Buffer:new(data)
    local length = math.min(buf:ruint(1),buf.length)
    if length < 17 then return end
    
    local cmdId = buf:ruint(6)
    local userid = buf:ruint(10)
    local result = buf:ruint(14)
    
    -- 记录到日志文件
    local Logger = require("../logger")
    local seerCmdList = nil
    pcall(function()
        seerCmdList = require('../session_analyze/seer_cmdlist')
    end)
    
    local cmdName = "Unknown"
    if seerCmdList and seerCmdList[cmdId] then
        cmdName = seerCmdList[cmdId].note
    end
    
    Logger.logCommand("RECV", cmdId, cmdName, userid, length, data)
    
    local handler = gpp.handler[cmdId]
    if handler then
        handler(socket,userid,buf,length,user)
    else
        print(string.format("\27[31m[GAME] Unhandled CMD=%d, LEN=%d\27[0m", cmdId, length))
    end
end


-- ============================================================
-- 赛尔号命令处理器
-- ============================================================

-- 登录Online Server (CMD 1001)
-- 登录Online Server (CMD 1001)
gpp.handler[1001] = function(socket,userid,buf,length,user)
    -- Client sends: [Session(16)][Tmcid(64)][LoginType(4)]...
    -- Offset is 17 (Head length)
    
    local session = buf:toString(offset+1, offset+16) -- 16 bytes
    local tmcid = buf:toString(offset+17, offset+80) -- 64 bytes
    local loginType = buf:readInt32BE(offset+81) -- 4 bytes
    
    -- Use user's connected serverID
    local serverID = user.serverID or 1
    local magicString = "1234567890123456" -- Dummy string since client doesn't send it
    
    print(string.format(
        "\27[1m[赛尔号登录]\n\t米米号:%d\n\tserverID:%d\n\tsession:%s\n\ttmcid:%s\n\tloginType:%d\27[0m",
        userid, serverID, "******", tmcid:gsub("%z", ""), loginType
    ))
    
    -- 设置用户信息
    Game.login(user, userid, serverID, magicString, session, loginType)
    user.mapid = 1 -- Force default map for 1022 response logic
    
    -- 发送登录响应
    gpp.sendSeerLoginResponse(user)
end

-- 发送赛尔号登录响应
function gpp.sendSeerLoginResponse(user)
    local socket = user.socket
    local SeerLogin = require "./seer_login_response"
    
    -- 发送系统通知 (CMD 8002) - 暂时屏蔽，防止客户端解析错误
    -- for i = 1, 3 do
    --     local notice = SeerLogin.makeSystemNotice(user, i)
    --     local head = gpp.makeHead(8002, user.userid, 0, #notice)
    --     if user.send then
    --         user:send(head .. notice)
    --     else
    --         socket:write(head .. notice)
    --     end
    -- end
    
    -- 发送登录响应 (CMD 1001)
    local body, keySeed = SeerLogin.makeLoginResponse(user)
    local head = gpp.makeHead(1001, user.userid, 0, #body)
    if user.send then
        user:send(head .. body)
    else
        socket:write(head .. body)
    end
    
    print(string.format("\27[32m[GAME] Sent login response to user %d (%d bytes)\27[0m", user.userid, #body))
    
    -- 更新加密密钥 (客户端收到响应后会立即更新密钥)
    if keySeed and user.crypto then
        -- 算法移植自 MainEntry.as initKey
        -- Client implementation (MainEntry.as initKey):
        -- 1. val = seed XOR userid
        -- 2. hash = MD5(val)
        -- 3. key = First 10 chars of hash
        local val = bit.bxor(keySeed, user.userid)
        
        -- MD5 hash
        local md5 = require("../md5")
        local hash = md5.sumhexa(tostring(val))
        
        -- Key is first 10 chars
        local keyStr = hash:sub(1, 10)
        
        print(string.format("\27[33m[CRYPTO] Updating key. Seed=%d, Val=%d, Hash=%s, Key=%s\27[0m", 
            keySeed, val, hash, keyStr))
            
        user.crypto:initKey(keyStr)
        
        -- 确保下一条消息开始使用新密钥
        if not user.encryptionEnabled then
            user.encryptionEnabled = true
            print(string.format("\27[33m[LOCAL-GAME] Encryption actually enabled now (post-1001)\27[0m"))
        end
        
        -- REMOVED: Forced packet sending is a workaround, not a proper solution.
        -- The client should send CMD 2001 naturally after parsing the login response.
        -- If client hangs, the login response packet structure is incorrect.
        
        --[[ DEBUG: Uncomment to force-send packets if needed
        timer.setTimeout(1500, function()
            local uid = user.userid or 0
            print(string.format("\27[35m[DEBUG] Force sending CMD 1022 (Empty) + CMD 2001 (MapInfo) to user %d\27[0m", uid))
            
            local head1022 = gpp.makeHead(1022, uid, 0, 0)
            if user.send then
                user:send(head1022)
            else
                socket:write(head1022)
            end
            
            local body2001 = gpp.makeSeerMapUserInfo(user)
            local head2001 = gpp.makeHead(2001, uid, 0, #body2001)
            
            if user.send then
                user:send(head2001 .. body2001)
            else
                socket:write(head2001 .. body2001)
            end
        end)
        --]]
    end
end

-- 心跳包/时间校验 (CMD 1002)
gpp.handler[1002] = function(socket,userid,buf,length,user)
    -- Silent heartbeat
    local body = buf:toString(offset+1, length)
    local head = gpp.makeHead(1002,userid,0,#body)
    if user and user.send then
        user:send(head .. body)
    else
        socket:write(head)
        socket:write(body)
    end
end

-- 进入地图 (CMD 2001) - 集成版本在下方
-- 离开地图 (CMD 2002)
gpp.handler[2002] = function(socket,userid,buf,length,user)
    local oldmapid = gpp.safeRead32(buf, length, offset+1)
    local oldmaptype = gpp.safeRead32(buf, length, offset+5)
    
    print(string.format("\27[36m[GAME] User %d leaving map %d\27[0m", userid, oldmapid))
    
    local map = Map.getMap(oldmapid)
    if map then
        local body = gpp.makeLeaveMap(userid)
        gpp.mapBroadcast(map, 2002, 0, body)
    end
    
    -- Client needs to receive its own leave notification to close old map and load new one
    local responseBody = gpp.makeLeaveMap(userid)
    local head = gpp.makeHead(2002, userid, 0, #responseBody)
    user:send(head .. responseBody)
end

-- 获取地图用户列表 (CMD 2003) - 集成版本在下方

-- 走路 (CMD 2101)
gpp.handler[2101] = function(socket,userid,buf,length,user)
    local endx = gpp.safeRead32(buf, length, offset+1)
    local endy = gpp.safeRead32(buf, length, offset+5)
    Game.walk(user,endx,endy)
end

-- 聊天 (CMD 2102)
gpp.handler[2102] = function(socket,userid,buf,length,user)
    local towho = gpp.safeRead32(buf, length, offset+1)
    local msglen = gpp.safeRead32(buf, length, offset+5)
    if msglen > 0 and length >= offset + 8 + msglen then
        local str = buf:toString(offset+9,offset+9+msglen-1)
        Game.talk(user,towho,str)
    end
end

-- 动作 (CMD 2103)
gpp.handler[2103] = function(socket,userid,buf,length,user)
    local action = gpp.safeRead32(buf, length, offset+1)
    local direction = gpp.safeRead8(buf, length, offset+5)
    Game.doAction(user,action,direction)
end

-- 获取精灵列表 (CMD 2303)
gpp.handler[2303] = function(socket,userid,buf,length,user)
    -- 返回空精灵列表
    local body = buffer.Buffer:new(128)
    body:wuint(1, 0)  -- petCount = 0
    local head = gpp.makeHead(2303, userid, 0, 4)
    user:send(head .. tostring(body):sub(1, 4))
end

-- 获取好友列表 (CMD 47334)
gpp.handler[47334] = function(socket,userid,buf,length,user)
    local body = buffer.Buffer:new(128)
    body:wuint(1, 0)  -- count = 0
    local head = gpp.makeHead(47334, userid, 0, 4)
    user:send(head .. tostring(body):sub(1, 4))
end

-- 获取黑名单 (CMD 47335)
gpp.handler[47335] = function(socket,userid,buf,length,user)
    local body = gpp.makeBlacklist(userid)
    local head = gpp.makeHead(47335,userid,0,#body)
    user:send(head .. body)
end

-- 获取服务器时间 (CMD 10301)
gpp.handler[10301] = function(socket,userid,buf,length,user)
    local body = gpp.makeServerTime()
    local head = gpp.makeHead(10301,userid,0,#body)
    user:send(head .. body)
end

-- 获取物品列表 (CMD 4475)
gpp.handler[4475] = function(socket,userid,buf,length,user)
    local body = buffer.Buffer:new(8)
    body:wuint(1, 0)  -- itemCount = 0
    body:wuint(5, 0)  -- updateTime = 0
    local head = gpp.makeHead(4475, userid, 0, 8)
    user:send(head .. tostring(body))
end

-- 获取任务缓冲 (CMD 2203)
gpp.handler[2203] = function(socket,userid,buf,length,user)
    local body = buffer.Buffer:new(128)
    body:wuint(1, 0)  -- count = 0
    local head = gpp.makeHead(2203, userid, 0, 4)
    user:send(head .. tostring(body))
end

-- 验证战斗码 (CMD 1022)
gpp.handler[1022] = function(socket,userid,buf,length,user)
    -- 返回成功 (Encrypted)
    print(string.format("\27[34m[GAME] Handled CMD 1022 (FIGHT_GIFT_TYPE)\27[0m"))
    local head = gpp.makeHead(1022, userid, 0, 0)
    user:send(head)
end

-- 获取用户简单信息 (CMD 2051)
gpp.handler[2051] = function(socket,userid,buf,length,user)
    local targetId = gpp.safeRead32(buf, length, offset+1)
    -- 返回简单用户信息
    local body = buffer.Buffer:new(128)
    body:wuint(1, targetId)
    body:write(5, "赛尔", 16)
    body:wuint(21, 0xFFFFFF)  -- color
    body:wuint(25, 0)  -- texture
    body:wuint(29, 0)  -- vip
    body:wbyte(33, 0)  -- isExtremeNono
    body:wuint(34, 0)  -- status
    body:wuint(38, 0)  -- mapType
    body:wuint(42, 101)  -- mapID
    
    local bodyData = tostring(body):sub(1, 46)
    local head = gpp.makeHead(2051, userid, 0, #bodyData)
    user:send(head .. bodyData)
end

-- 通用空响应处理 (使用加密发送)
local function emptyResponse(cmdId, size)
    return function(socket, userid, buf, length, user)
        local head = gpp.makeHead(cmdId, userid, 0, size)
        local body = string.rep("\0", size)
        if user and user.send then
            user:send(head .. body)
        else
            socket:write(head .. body)
        end
    end
end

-- 注册通用空响应
gpp.handler[2204] = emptyResponse(2204, 4)  -- ADD_TASK_BUF
gpp.handler[2231] = emptyResponse(2231, 4)  -- ACCEPT_DAILY_TASK
gpp.handler[2234] = emptyResponse(2234, 4)  -- GET_DAILY_TASK_BUF
gpp.handler[41080] = emptyResponse(41080, 4)  -- GET_FOREVER_VALUE

gpp.handler[46046] = function(socket, userid, buf, length, user)
    -- GET_MULTI_FOREVER (updateDecorate) - 返回5个0
    print(string.format("\27[34m[GAME] Handled CMD 46046 (GET_MULTI_FOREVER)\27[0m"))
    local body = buffer.Buffer:new(128)
    body:wuint(1, 5)  -- count = 5
    body:wuint(5, 0)  -- val 1
    body:wuint(9, 0)  -- val 2
    body:wuint(13, 0) -- val 3
    body:wuint(17, 0) -- val 4
    body:wuint(21, 0) -- val 5
    local head = gpp.makeHead(46046, userid, 0, 24)
    user:send(head .. tostring(body):sub(1, 24))
end

-- 新增处理器 (用于支持登录后的功能)
gpp.handler[40001] = function(socket, userid, buf, length, user)
    -- GET_SUPER_VALUE (获取超级数值) - 返回空数组
    print(string.format("\27[34m[GAME] Handled CMD 40001 (GET_SUPER_VALUE)\27[0m"))
    local body = buffer.Buffer:new(128)
    body:wuint(1, 0)  -- count = 0
    local head = gpp.makeHead(40001, userid, 0, 4)
    user:send(head .. tostring(body):sub(1, 4))
end

gpp.handler[40002] = function(socket, userid, buf, length, user)
    -- GET_SUPER_VALUE_BY_IDS - 返回空数组
    print(string.format("\27[34m[GAME] Handled CMD 40002\27[0m"))
    local body = buffer.Buffer:new(128)
    body:wuint(1, 0)  -- count = 0
    local head = gpp.makeHead(40002, userid, 0, 4)
    user:send(head .. tostring(body):sub(1, 4))
end

gpp.handler[42023] = function(socket, userid, buf, length, user)
    -- BATCH_GET_BITSET - 返回空数组 (4字节count=0)
    print(string.format("\27[34m[GAME] Handled CMD 42023 (BATCH_GET_BITSET)\27[0m"))
    local body = buffer.Buffer:new(128)
    body:wuint(1, 0)  -- count = 0
    local head = gpp.makeHead(42023, userid, 0, 4)
    user:send(head .. tostring(body):sub(1, 4))
end

gpp.handler[46057] = function(socket, userid, buf, length, user)
    -- GET_MULTI_FOREVER_BY_DB - 返回空数组 (4字节count=0)
    print(string.format("\27[34m[GAME] Handled CMD 46057\27[0m"))
    local body = buffer.Buffer:new(128)
    body:wuint(1, 0)  -- count = 0
    local head = gpp.makeHead(46057, userid, 0, 4)
    user:send(head .. tostring(body):sub(1, 4))
end

-- CMD 2001 - 进入地图 (ENTER_MAP)
gpp.handler[2001] = function(socket, userid, buf, length, user)
    local newmapid = 1
    local newmaptype = 0
    
    if length > offset + 4 then
        newmaptype = gpp.safeRead32(buf, length, offset+1)
        newmapid = gpp.safeRead32(buf, length, offset+5)
    end
    
    print(string.format("\27[32m[GAME] User %d entering map %d (type=%d)\27[0m", userid, newmapid, newmaptype))
    
    -- 更新用户地图信息
    user.map = newmapid
    user.mapType = newmaptype
    user.x = 300
    user.y = 300
    
    -- 发送地图用户信息响应
    local body = gpp.makeSeerMapUserInfo(user)
    local head = gpp.makeHead(2001, userid, 0, #body)
    user:send(head .. body)
end

-- CMD 9049 - OPEN_BAG_GET
gpp.handler[9049] = function(socket, userid, buf, length, user)
    print(string.format("\27[34m[GAME] Handled CMD 9049 (OPEN_BAG_GET)\27[0m"))
    local body = buffer.Buffer:new(8)
    body:wuint(1, 0)  -- count = 0
    body:wuint(5, 0)  -- extra
    local head = gpp.makeHead(9049, userid, 0, 8)
    user:send(head .. tostring(body):sub(1, 8))
end

-- CMD 8002 - 系统消息
gpp.handler[8002] = function(socket, userid, buf, length, user)
    print(string.format("\27[34m[GAME] CMD 8002 - System message from client (ignored)\27[0m"))
end

-- CMD 11003 - GET_PET_INFO
gpp.handler[11003] = function(socket, userid, buf, length, user)
    print(string.format("\27[34m[GAME] Handled CMD 11003 (GET_PET_INFO)\27[0m"))
    -- 空精灵背包
    local body = buffer.Buffer:new(128)
    body:wuint(1, 0)  -- petCount = 0
    local head = gpp.makeHead(11003, userid, 0, 4)
    user:send(head .. tostring(body):sub(1, 4))
end

-- CMD 11007 - GET_PET_BY_CATCH_TIME
gpp.handler[11007] = function(socket, userid, buf, length, user)
    print(string.format("\27[34m[GAME] Handled CMD 11007 (GET_PET_BY_CATCH_TIME)\27[0m"))
    -- 返回空
    local head = gpp.makeHead(11007, userid, 0, 0)
    user:send(head)
end

-- CMD 11022 - GET_SECOND_BAG
gpp.handler[11022] = function(socket, userid, buf, length, user)
    print(string.format("\27[34m[GAME] Handled CMD 11022 (GET_SECOND_BAG)\27[0m"))
    local body = buffer.Buffer:new(128)
    body:wuint(1, 0)  -- count = 0
    local head = gpp.makeHead(11022, userid, 0, 4)
    user:send(head .. tostring(body):sub(1, 4))
end

-- CMD 41983 - RECONNECT
gpp.handler[41983] = function(socket, userid, buf, length, user)
    print(string.format("\27[33m[GAME] Handled CMD 41983 (RECONNECT)\27[0m"))
    -- 重连处理，返回成功
    local head = gpp.makeHead(41983, userid, 0, 0)
    user:send(head)
end

-- CMD 2003 - LIST_MAP_PLAYER
gpp.handler[2003] = function(socket, userid, buf, length, user)
    print(string.format("\27[34m[GAME] Handled CMD 2003 (LIST_MAP_PLAYER)\27[0m"))
    local userInfoBody = gpp.makeSeerMapUserInfo(user)
    local body = buffer.Buffer:new(4 + #userInfoBody + 128)
    body:wuint(1, 1)  -- count = 1
    body:write(5, userInfoBody, #userInfoBody)
    local head = gpp.makeHead(2003, userid, 0, 4 + #userInfoBody)
    user:send(head .. tostring(body):sub(1, 4 + #userInfoBody))
end

-- 批量注册空响应处理器 (避免 client 卡死)
local emptyCmds = {
    41253, 3405, 45793, 45524, 40007, 1011, 5005, 9112, 2289, 4359, 4364, 
    9677, 2313, 41006, 4148, 4178, 4181, 4501, 45512, 47309, 40006, 45824, 
    45773, 2361, 45798, 1016, 9003, 45071, 41249, 2354, 2196, 2192, 43706
}

for _, id in ipairs(emptyCmds) do
    if not gpp.handler[id] then
        gpp.handler[id] = function(socket, userid, buf, length, user)
            -- print(string.format("\27[33m[GAME] Handled CMD %d (AUTO-EMPTY)\27[0m", id))
            local head = gpp.makeHead(id, userid, 0, 0)
            user:send(head)
        end
    end
end

-- 添加一个后置打印确认
local count = 0
for _ in pairs(gpp.handler) do count = count + 1 end
print(string.format("\27[32m[PROTOCOL] Registered %d handlers total\27[0m", count))

return gpp
