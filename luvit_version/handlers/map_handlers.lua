-- 地图相关命令处理器
-- 包括: 进入/离开地图、玩家列表、移动、聊天等
-- Protocol Version: 2026-01-20 (Refactored using BinaryWriter)

local BinaryWriter = require('utils/binary_writer')
local BinaryReader = require('utils/binary_reader')
local ResponseBuilder = require('utils/response_builder')
local buildResponse = ResponseBuilder.build
local Utils = { buildResponse = buildResponse }
local OnlineTracker = require('handlers/online_tracker')
local GameConfig = require('config/game_config')
local InitialPlayer = GameConfig.InitialPlayer or {}

local MapHandlers = {}

-- ==================== 协议构建 Helper ====================

-- 构建 UserInfo (setForPeoleInfo)
-- 对应前端: com.robot.core.info.UserInfo.setForPeoleInfo
local function buildPeopleInfo(userId, user, sysTime)
    user = user or {}
    sysTime = sysTime or os.time()
    
    local writer = BinaryWriter.new()
    
    -- 1. 基本信息
    writer:writeInt32BE(sysTime)                -- sysTime (4) (Int)
    writer:writeUInt32BE(userId)                -- userID (4)
    local nickname = user.nick or user.nickname or ("Seer" .. userId)
    writer:writeStringFixed(nickname, 16)       -- nick (16)
    
    writer:writeUInt32BE(user.color or InitialPlayer.color or 0x66CCFF)-- color (4)
    
    writer:writeUInt32BE(user.texture or InitialPlayer.texture or 0)     -- texture (4)
    
    -- 2. VIP Flags (bit 0=vip, bit 1=viped)
    local vipFlags = 0
    local nono = user.nono or {}
    local superNono = nono.superNono or user.superNono or 0
    if superNono > 0 then
        vipFlags = 3
    end
    writer:writeUInt32BE(vipFlags)              -- vipFlags (4)
    
    writer:writeUInt32BE(nono.vipStage or 0)    -- vipStage (4)
    
    local actionType = (user.flyMode and user.flyMode > 0) and 1 or 0
    writer:writeUInt32BE(actionType)            -- actionType (4)
    
    -- 3. Pos & Action
    writer:writeUInt32BE(user.x or InitialPlayer.posX or 300)         -- pos.x (4)
    writer:writeUInt32BE(user.y or InitialPlayer.posY or 270)         -- pos.y (4)
    writer:writeUInt32BE(0)                     -- action (4)
    writer:writeUInt32BE(0)                     -- direction (4)
    writer:writeUInt32BE(0)                     -- changeShape (4)
    
    -- 4. Pet & Spirit
    local catchTime = user.catchId or 0
    local petId = user.currentPetId or 0
    local petDV = 31
    -- 尝试查找 DV
    if user.pets then
        for _, p in ipairs(user.pets) do
            if p.id == petId then 
                petDV = p.dv or 31 
                break
            end
        end
    end
    
    writer:writeUInt32BE(catchTime)             -- spiritTime (4)
    writer:writeUInt32BE(petId)                 -- spiritID (4)
    writer:writeUInt32BE(petDV)                 -- petDV (4)
    writer:writeUInt32BE(0)                     -- petSkin (4)
    writer:writeUInt32BE(0)                     -- fightFlag (4)
    
    -- 5. Teacher/Student
    writer:writeUInt32BE(user.teacherID or 0)
    writer:writeUInt32BE(user.studentID or 0)
    
    -- 6. NoNo State
    -- nonoState (Uint -> 32 bits)
    local nonoState = nono.flag or user.nonoState or 0
    -- 逻辑修正: 如果 actionType=1 (Fly)，则 nonoState 不应该显示跟随(bit 1)?
    -- 前端 setForPeoleInfo 直接读取通过 BitUtil.getBit 解析 bits
    writer:writeUInt32BE(nonoState)             -- nonoState (4)
    writer:writeUInt32BE(nono.color or 0xFFFFFF) -- nonoColor (4) - 默认白色
    writer:writeUInt32BE(superNono > 0 and 1 or 0) -- superNono (4) (Boolean)
    
    writer:writeUInt32BE(0)                     -- playerForm (4) (Boolean)
    writer:writeUInt32BE(0)                     -- transTime (4)
    
    -- 7. TeamInfo (Inline)
    -- id(4), coreCount(4), isShow(4), logoBg(2), logoIcon(2), logoColor(2), txtColor(2), logoWord(4)
    local team = user.teamInfo or {}
    writer:writeUInt32BE(team.id or 0)
    writer:writeUInt32BE(team.coreCount or 0)
    writer:writeUInt32BE(team.isShow and 1 or 0)
    writer:writeUInt16BE(team.logoBg or 0)
    writer:writeUInt16BE(team.logoIcon or 0)
    writer:writeUInt16BE(team.logoColor or 0)
    writer:writeUInt16BE(team.txtColor or 0)
    writer:writeStringFixed(team.logoWord or "", 4)
    
    -- 8. Clothes
    local clothes = user.clothes or {}
    writer:writeUInt32BE(#clothes)              -- count (4)
    for _, cloth in ipairs(clothes) do
        local cid = 0
        local clev = 0
        if type(cloth) == "table" then
            cid = cloth.id or 0
            clev = cloth.level or 0
        elseif type(cloth) == "number" then
            cid = cloth
            clev = 0
        end
        writer:writeUInt32BE(cid)
        writer:writeUInt32BE(clev)
    end
    
    -- 9. Title
    writer:writeUInt32BE(user.curTitle or 0)
    
    return writer:toString()
end

-- ==================== 命令处理器 ====================

-- CMD 2001: ENTER_MAP (进入地图)
local function handleEnterMap(ctx)
    local reader = BinaryReader.new(ctx.body)
    local mapType = 0
    local mapId = 0
    local x, y = 500, 300
    
    if reader:getRemaining() ~= "" then
        mapType = reader:readUInt32BE()
        mapId = reader:readUInt32BE()
        x = reader:readUInt32BE()
        y = reader:readUInt32BE()
    end
    
    -- 验证与默认地图逻辑
    local user = ctx.getOrCreateUser(ctx.userId)
    if mapId == 0 then
        mapId = user.mapId or 1
    end
    
    -- 更新用户状态
    if mapId ~= 515 then -- 不是教程地图
        user.mapId = mapId
        user.mapID = mapId
        user.lastMapId = mapId
        user.posX = x
        user.posY = y
    end
    user.mapType = mapType
    user.x = x
    user.y = y
    ctx.saveUserDB()
    
    -- 更新在线追踪
    OnlineTracker.updatePlayerMap(ctx.userId, mapId, mapType)
    
    print(string.format("\27[36m[Handler] ENTER_MAP: type=%d, id=%d, pos=(%d,%d)\27[0m", mapType, mapId, x, y))
    
    -- 构建响应 (UserInfo setForPeoleInfo)
    local body = buildPeopleInfo(ctx.userId, user, os.time())
    ctx.sendResponse(buildResponse(2001, ctx.userId, 0, body))
    
    -- 主动推送 LIST_MAP_PLAYER (包含自己)
    -- count(4) + [PeopleInfo]
    local listWriter = BinaryWriter.new()
    listWriter:writeUInt32BE(1)
    listWriter:writeBytes(body)
    ctx.sendResponse(buildResponse(2003, ctx.userId, 0, listWriter:toString()))
    
    -- 家园地图特殊逻辑
    if mapId > 10000 or mapId == ctx.userId then
        local isFollowing = false
        if ctx.sessionManager and ctx.sessionManager.getNonoFollowing then
            isFollowing = ctx.sessionManager:getNonoFollowing(ctx.userId)
        end
        local isFlying = (user.flyMode and user.flyMode > 0)
        
        -- 只有当 NoNo "在家" (不跟随且不飞行) 时才发送 9003
        if not isFollowing and not isFlying then
            local nono = user.nono or {}
            local nw = BinaryWriter.new()
            nw:writeUInt32BE(ctx.userId)
            nw:writeUInt32BE(nono.flag or 1)
            nw:writeUInt32BE(1) -- state=1 (NONO在家)
            nw:writeStringFixed(nono.nick or "NoNo", 16)
            nw:writeUInt32BE(nono.superNono or 0)
            
            nw:writeUInt32BE(nono.color or 0xFFFFFF)
            
            nw:writeUInt32BE(nono.power or 100)
            nw:writeUInt32BE(nono.mate or 100)
            nw:writeUInt32BE(nono.iq or 0)
            nw:writeUInt16BE(nono.ai or 0)
            nw:writeUInt32BE(nono.birth or os.time())
            nw:writeUInt32BE(nono.chargeTime or 0)
            nw:writeStringFixed("", 20) -- func (20 bytes padding or full FFs)
            nw:writeUInt32BE(nono.superEnergy or 0)
            nw:writeUInt32BE(nono.superLevel or 0)
            nw:writeUInt32BE(nono.superStage or 0)
            
            ctx.sendResponse(buildResponse(9003, ctx.userId, 0, nw:toString()))
            print("\27[32m[Handler] → NONO_INFO (9003) sent for Home\27[0m")
        end
    end
    
    return true
end

-- CMD 2002: LEAVE_MAP (离开地图)
local function handleLeaveMap(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    ctx.sendResponse(buildResponse(2002, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 2003: LIST_MAP_PLAYER (地图玩家列表)
local function handleListMapPlayer(ctx)
    local currentMapId = OnlineTracker.getPlayerMap(ctx.userId)
    local playersInMap = OnlineTracker.getPlayersInMap(currentMapId)
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(#playersInMap)
    
    for _, pid in ipairs(playersInMap) do
        local pUser = ctx.getOrCreateUser(pid)
        local pInfo = buildPeopleInfo(pid, pUser, os.time())
        writer:writeBytes(pInfo)
    end
    
    ctx.sendResponse(buildResponse(2003, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → LIST_MAP_PLAYER (%d players in map %d)\27[0m", #playersInMap, currentMapId))
    return true
end

-- CMD 2004: MAP_OGRE_LIST (地图怪物列表)
local function handleMapOgreList(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local mapId = user.mapId or 1
    
    -- Config: { [slot] = {petId, shiny} }
    local MAP_OGRES = {
        [8] = { [0] = {10,0}, [1] = {58,0} },
        [301] = { [0] = {1,0}, [1] = {4,0}, [2] = {7,0}, [3] = {10,0} }
    }
    
    local ogres = MAP_OGRES[mapId] or {}
    local writer = BinaryWriter.new()
    
    for i = 0, 8 do
        local data = ogres[i]
        if data then
            local pid = data[1]
            local shiny = data[2]
            if shiny == 0 and math.random() < 0.1 then shiny = 1 end
            writer:writeUInt32BE(pid)
            writer:writeUInt32BE(shiny)
        else
            writer:writeUInt32BE(0)
            writer:writeUInt32BE(0)
        end
    end
    
    ctx.sendResponse(buildResponse(2004, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 2051: GET_SIM_USERINFO
local function handleGetSimUserInfo(ctx)
    local reader = BinaryReader.new(ctx.body)
    local targetId = ctx.userId
    if reader:getRemaining() ~= "" then targetId = reader:readUInt32BE() end
    
    local user = ctx.getOrCreateUser(targetId)
    local writer = BinaryWriter.new()
    
    local nickname = user.nick or user.nickname or ("Seer" .. targetId)
    writer:writeUInt32BE(targetId)
    writer:writeStringFixed(nickname, 16)
    
    writer:writeUInt32BE(user.color or InitialPlayer.color or 0x66CCFF)
    
    writer:writeUInt32BE(user.texture or InitialPlayer.texture or 0)
    writer:writeUInt32BE(user.vip or 0)
    writer:writeUInt32BE(0) -- status
    writer:writeUInt32BE(user.mapType or 0)
    writer:writeUInt32BE(user.mapId or 1)
    writer:writeUInt32BE(user.isCanBeTeacher and 1 or 0)
    writer:writeUInt32BE(user.teacherID or 0)
    writer:writeUInt32BE(user.studentID or 0)
    writer:writeUInt32BE(user.graduationCount or 0)
    writer:writeUInt32BE(user.vipLevel or 0)
    writer:writeUInt32BE(user.teamId or 0)
    writer:writeUInt32BE(user.teamIsShow and 1 or 0)
    
    local clothes = user.clothes or {}
    writer:writeUInt32BE(#clothes)
    for _, c in ipairs(clothes) do
        local cid = (type(c)=="table") and c.id or c
        writer:writeUInt32BE(cid)
        writer:writeUInt32BE(0)
    end
    
    ctx.sendResponse(buildResponse(2051, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 2052: GET_MORE_USERINFO
local function handleGetMoreUserInfo(ctx)
    local reader = BinaryReader.new(ctx.body)
    local targetId = ctx.userId
    if reader:getRemaining() ~= "" then targetId = reader:readUInt32BE() end
    
    local user = ctx.getOrCreateUser(targetId)
    local writer = BinaryWriter.new()
    
    writer:writeUInt32BE(targetId)
    local nickname = user.nick or user.nickname or ("Seer" .. targetId)
    writer:writeStringFixed(nickname, 16)
    writer:writeUInt32BE(user.regTime or os.time())
    writer:writeUInt32BE(user.petAllNum or 0)
    writer:writeUInt32BE(user.petMaxLev or 100)
    writer:writeStringFixed("", 200) -- bossAchievement
    writer:writeUInt32BE(user.graduationCount or 0)
    writer:writeUInt32BE(user.monKingWin or 0)
    writer:writeUInt32BE(user.messWin or 0)
    writer:writeUInt32BE(user.maxStage or 0)
    writer:writeUInt32BE(user.maxArenaWins or 0)
    writer:writeUInt32BE(user.curTitle or 0)
    
    ctx.sendResponse(buildResponse(2052, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 2061: CHANGE_NICK_NAME
local function handleChangeNickName(ctx)
    local reader = BinaryReader.new(ctx.body)
    local newNick = reader:readStringFixed(16)
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.nick = newNick
    ctx.saveUserDB()
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeStringFixed(newNick, 16)
    
    ctx.sendResponse(buildResponse(2061, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] User %d changed nick to %s\27[0m", ctx.userId, newNick))
    return true
end

-- CMD 2063: CHANGE_COLOR
local function handleChangeColor(ctx)
    local reader = BinaryReader.new(ctx.body)
    local newColor = reader:readUInt32BE()
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.color = newColor
    ctx.saveUserDB()
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeUInt32BE(newColor)
    writer:writeUInt32BE(0) -- cost
    writer:writeUInt32BE(user.coins or 0) -- remain
    
    ctx.sendResponse(buildResponse(2063, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] User %d changed color to 0x%X\27[0m", ctx.userId, newColor))
    return true
end

-- CMD 2101: PEOPLE_WALK
local function handlePeopleWalk(ctx)
    local reader = BinaryReader.new(ctx.body)
    local walkType = reader:readUInt32BE()
    local x = reader:readUInt32BE()
    local y = reader:readUInt32BE()
    local amfLen = reader:readUInt32BE()
    local amfData = reader:readBytes(amfLen)
    
    -- Update User
    local user = ctx.getOrCreateUser(ctx.userId)
    user.x = x
    user.y = y
    OnlineTracker.updateActivity(ctx.userId)
    
    -- Construct Response
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(walkType)
    writer:writeUInt32BE(ctx.userId)
    writer:writeUInt32BE(x)
    writer:writeUInt32BE(y)
    writer:writeUInt32BE(amfLen)
    writer:writeBytes(amfData)
    
    local resp = buildResponse(2101, ctx.userId, 0, writer:toString())
    
    -- Broadcast
    local mapId = OnlineTracker.getPlayerMap(ctx.userId)
    if mapId > 0 then
        local players = OnlineTracker.getPlayersInMap(mapId)
        for _, pid in ipairs(players) do
            OnlineTracker.sendToPlayer(pid, resp)
        end
    else
        ctx.sendResponse(resp)
    end
    
    return true
end

-- CMD 2102: CHAT
local function handleChat(ctx)
    local reader = BinaryReader.new(ctx.body)
    local chatType = reader:readUInt32BE() -- Unused by client in response?
    local msgLen = reader:readUInt32BE()
    local msg = reader:readBytes(msgLen)
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local nickname = user.nick or user.nickname or ("Seer" .. ctx.userId)
    
    -- Client ChatInfo: senderID(4), senderNick(16), toID(4), msgLen(4), msg
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeStringFixed(nickname, 16)
    writer:writeUInt32BE(0) -- toID (0=public)
    writer:writeUInt32BE(#msg)
    writer:writeBytes(msg)
    
    local resp = buildResponse(2102, ctx.userId, 0, writer:toString())
    
    local mapId = OnlineTracker.getPlayerMap(ctx.userId)
    if mapId > 0 then
        local players = OnlineTracker.getPlayersInMap(mapId)
        for _, pid in ipairs(players) do
            OnlineTracker.sendToPlayer(pid, resp)
        end
    else
        ctx.sendResponse(resp)
    end
    
    print(string.format("\27[32m[Handler] CHAT: %s\27[0m", msg))
    return true
end

-- CMD 2111: PEOPLE_TRANSFROM
local function handlePeopleTransform(ctx)
    local reader = BinaryReader.new(ctx.body)
    local transId = reader:readUInt32BE()
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeUInt32BE(transId)
    
    ctx.sendResponse(buildResponse(2111, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 2112: ON_OR_OFF_FLYING
local function handleOnOrOffFlying(ctx)
    local reader = BinaryReader.new(ctx.body)
    local flyMode = reader:readUInt32BE()
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.flyMode = flyMode
    user.actionType = (flyMode > 0) and 1 or 0
    ctx.saveUserDB()
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeUInt32BE(flyMode)
    
    local resp = buildResponse(2112, ctx.userId, 0, writer:toString())
    ctx.sendResponse(resp)
    
    if ctx.broadcastToMap then
        ctx.broadcastToMap(resp, ctx.userId)
    end
    
    return true
end

-- CMD 2103: DANCE_ACTION
local function handleDanceAction(ctx)
    local reader = BinaryReader.new(ctx.body)
    local aid = reader:readUInt32BE()
    local atype = reader:readUInt32BE()
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeUInt32BE(aid)
    writer:writeUInt32BE(atype)
    
    ctx.sendResponse(buildResponse(2103, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 2104: AIMAT (交互/瞄准)
local function handleAimat(ctx)
    local reader = BinaryReader.new(ctx.body)
    local tType = reader:readUInt32BE()
    local tId = reader:readUInt32BE()
    local x = reader:readUInt32BE()
    local y = reader:readUInt32BE()
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeUInt32BE(tType)
    writer:writeUInt32BE(tId)
    writer:writeUInt32BE(x)
    writer:writeUInt32BE(y)
    
    ctx.sendResponse(buildResponse(2104, ctx.userId, 0, writer:toString()))
    return true
end

function MapHandlers.register(Handlers)
    Handlers.register(2001, handleEnterMap)
    Handlers.register(2002, handleLeaveMap)
    Handlers.register(2003, handleListMapPlayer)
    Handlers.register(2004, handleMapOgreList)
    Handlers.register(2051, handleGetSimUserInfo)
    Handlers.register(2052, handleGetMoreUserInfo)
    Handlers.register(2061, handleChangeNickName)
    Handlers.register(2063, handleChangeColor)
    Handlers.register(2101, handlePeopleWalk)
    Handlers.register(2102, handleChat)
    Handlers.register(2103, handleDanceAction)
    Handlers.register(2104, handleAimat)
    Handlers.register(2111, handlePeopleTransform)
    Handlers.register(2112, handleOnOrOffFlying)
    print("\27[36m[Handlers] Map Handlers Registered (v2.0 fixed)\27[0m")
end

return MapHandlers
