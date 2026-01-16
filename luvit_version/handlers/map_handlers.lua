-- 地图相关命令处理器
-- 包括: 进入/离开地图、玩家列表、移动、聊天等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse
local OnlineTracker = require('./online_tracker')

local MapHandlers = {}

-- CMD 2001: ENTER_MAP (进入地图)
-- 请求: mapType(4) + mapId(4) + x(4) + y(4)
-- EnterMapInfo响应: UserInfo结构
local function handleEnterMap(ctx)
    local mapType = 0
    local mapId = 0
    local x = 500
    local y = 300
    
    if #ctx.body >= 4 then
        mapType = readUInt32BE(ctx.body, 1)
    end
    if #ctx.body >= 8 then
        mapId = readUInt32BE(ctx.body, 5)
    end
    if #ctx.body >= 12 then
        x = readUInt32BE(ctx.body, 9)
    end
    if #ctx.body >= 16 then
        y = readUInt32BE(ctx.body, 13)
    end
    
    -- 验证 mapId，如果为0则使用默认地图或用户上次的地图
    if mapId == 0 then
        local user = ctx.getOrCreateUser(ctx.userId)
        mapId = user.mapId or user.mapID or 515  -- 默认新手教程地图
        print(string.format("\27[33m[Handler] ENTER_MAP: mapId=0, 使用默认地图 %d\27[0m", mapId))
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    
    -- 保存玩家地图位置（用于下次登录恢复）
    -- 只保存非新手地图的位置
    if mapId ~= 515 then
        user.mapId = mapId
        user.mapID = mapId  -- 兼容两种字段名
        user.posX = x
        user.posY = y
        user.lastMapId = mapId
    end
    
    user.mapType = mapType
    user.x = x
    user.y = y
    ctx.saveUserDB()
    
    -- 更新在线追踪
    OnlineTracker.updatePlayerMap(ctx.userId, mapId, mapType)
    
    print(string.format("\27[36m[Handler] ENTER_MAP: mapType=%d, mapId=%d, pos=(%d,%d)\27[0m", mapType, mapId, x, y))
    
    -- 使用 buildUserInfo 构建响应 (在下面定义)
    local nickname = user.nick or user.nickname or user.username or ("赛尔" .. ctx.userId)
    local petId = user.currentPetId or 0
    local catchTime = user.catchId or 0
    
    -- 构建 UserInfo 响应 (setForPeoleInfo 格式)
    local body = ""
    body = body .. writeUInt32BE(ctx.userId)           -- userID (4)
    body = body .. writeFixedString(nickname, 16)      -- nick (16)
    body = body .. writeUInt32BE(0xFFFFFF)             -- color (4)
    body = body .. writeUInt32BE(0)                    -- texture (4)
    body = body .. writeUInt32BE(0)                    -- vip flags (4)
    body = body .. writeUInt32BE(0)                    -- vipStage (4)
    body = body .. writeUInt32BE(0)                    -- actionType (4)
    body = body .. writeUInt32BE(x)                    -- pos.x (4)
    body = body .. writeUInt32BE(y)                    -- pos.y (4)
    body = body .. writeUInt32BE(0)                    -- action (4)
    body = body .. writeUInt32BE(0)                    -- direction (4)
    body = body .. writeUInt32BE(0)                    -- changeShape (4)
    body = body .. writeUInt32BE(catchTime)            -- spiritTime (4)
    body = body .. writeUInt32BE(petId)                -- spiritID (4)
    body = body .. writeUInt32BE(31)                   -- petDV (4)
    body = body .. writeUInt32BE(0)                    -- petShiny (4)
    body = body .. writeUInt32BE(0)                    -- petSkin (4)
    body = body .. writeUInt32BE(0)                    -- achievementsId (4)
    body = body .. writeUInt32BE(0)                    -- petRide (4)
    body = body .. writeUInt32BE(0)                    -- padding (4)
    body = body .. writeUInt32BE(0)                    -- fightFlag (4)
    body = body .. writeUInt32BE(0)                    -- teacherID (4)
    body = body .. writeUInt32BE(0)                    -- studentID (4)
    body = body .. writeUInt32BE(0)                    -- nonoState (4)
    body = body .. writeUInt32BE(0)                    -- nonoColor (4)
    body = body .. writeUInt32BE(0)                    -- superNono (4)
    body = body .. writeUInt32BE(0)                    -- playerForm (4)
    body = body .. writeUInt32BE(0)                    -- transTime (4)
    -- TeamInfo
    body = body .. writeUInt32BE(0)                    -- teamInfo.id (4)
    body = body .. writeUInt32BE(0)                    -- teamInfo.coreCount (4)
    body = body .. writeUInt32BE(0)                    -- teamInfo.isShow (4)
    body = body .. writeUInt16BE(0)                    -- teamInfo.logoBg (2)
    body = body .. writeUInt16BE(0)                    -- teamInfo.logoIcon (2)
    body = body .. writeUInt16BE(0)                    -- teamInfo.logoColor (2)
    body = body .. writeUInt16BE(0)                    -- teamInfo.txtColor (2)
    body = body .. writeFixedString("", 4)             -- teamInfo.logoWord (4)
    body = body .. writeUInt32BE(0)                    -- clothCount (4)
    
    ctx.sendResponse(buildResponse(2001, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → ENTER_MAP %d at (%d,%d)\27[0m", mapId, x, y))
    return true
end

-- CMD 2002: LEAVE_MAP (离开地图)
-- 响应: userId(4)
local function handleLeaveMap(ctx)
    local body = writeUInt32BE(ctx.userId)
    ctx.sendResponse(buildResponse(2002, ctx.userId, 0, body))
    print("\27[32m[Handler] → LEAVE_MAP response\27[0m")
    return true
end

-- 构建 UserInfo (setForPeoleInfo 格式)
local function buildUserInfo(userId, user)
    local nickname = user.nick or user.nickname or user.username or ("赛尔" .. userId)
    local petId = user.currentPetId or 0
    local catchTime = user.catchId or 0
    local x = user.x or 500
    local y = user.y or 300
    
    local body = ""
    body = body .. writeUInt32BE(userId)               -- userID (4)
    body = body .. writeFixedString(nickname, 16)      -- nick (16)
    body = body .. writeUInt32BE(0xFFFFFF)             -- color (4)
    body = body .. writeUInt32BE(0)                    -- texture (4)
    body = body .. writeUInt32BE(0)                    -- vip flags (4)
    body = body .. writeUInt32BE(0)                    -- vipStage (4)
    body = body .. writeUInt32BE(0)                    -- actionType (4)
    body = body .. writeUInt32BE(x)                    -- pos.x (4)
    body = body .. writeUInt32BE(y)                    -- pos.y (4)
    body = body .. writeUInt32BE(0)                    -- action (4)
    body = body .. writeUInt32BE(0)                    -- direction (4)
    body = body .. writeUInt32BE(0)                    -- changeShape (4)
    body = body .. writeUInt32BE(catchTime)            -- spiritTime (4)
    body = body .. writeUInt32BE(petId)                -- spiritID (4)
    body = body .. writeUInt32BE(31)                   -- petDV (4)
    body = body .. writeUInt32BE(0)                    -- petShiny (4)
    body = body .. writeUInt32BE(0)                    -- petSkin (4)
    body = body .. writeUInt32BE(0)                    -- achievementsId (4)
    body = body .. writeUInt32BE(0)                    -- petRide (4)
    body = body .. writeUInt32BE(0)                    -- padding (4)
    body = body .. writeUInt32BE(0)                    -- fightFlag (4)
    body = body .. writeUInt32BE(0)                    -- teacherID (4)
    body = body .. writeUInt32BE(0)                    -- studentID (4)
    body = body .. writeUInt32BE(0)                    -- nonoState (4)
    body = body .. writeUInt32BE(0)                    -- nonoColor (4)
    body = body .. writeUInt32BE(0)                    -- superNono (4)
    body = body .. writeUInt32BE(0)                    -- playerForm (4)
    body = body .. writeUInt32BE(0)                    -- transTime (4)
    -- TeamInfo
    body = body .. writeUInt32BE(0)                    -- teamInfo.id (4)
    body = body .. writeUInt32BE(0)                    -- teamInfo.coreCount (4)
    body = body .. writeUInt32BE(0)                    -- teamInfo.isShow (4)
    body = body .. writeUInt16BE(0)                    -- teamInfo.logoBg (2)
    body = body .. writeUInt16BE(0)                    -- teamInfo.logoIcon (2)
    body = body .. writeUInt16BE(0)                    -- teamInfo.logoColor (2)
    body = body .. writeUInt16BE(0)                    -- teamInfo.txtColor (2)
    body = body .. writeFixedString("", 4)             -- teamInfo.logoWord (4)
    body = body .. writeUInt32BE(0)                    -- clothCount (4)
    
    return body
end

-- CMD 2003: LIST_MAP_PLAYER (地图玩家列表)
-- MapPlayerListInfo: playerCount(4) + [UserInfo]...
local function handleListMapPlayer(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local currentMapId = OnlineTracker.getPlayerMap(ctx.userId)
    
    -- 获取同地图的所有玩家
    local playersInMap = OnlineTracker.getPlayersInMap(currentMapId)
    
    local body = writeUInt32BE(#playersInMap)
    for _, playerId in ipairs(playersInMap) do
        local playerUser = ctx.getOrCreateUser(playerId)
        body = body .. buildUserInfo(playerId, playerUser)
    end
    
    ctx.sendResponse(buildResponse(2003, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → LIST_MAP_PLAYER response (%d players in map %d)\27[0m", 
        #playersInMap, currentMapId))
    return true
end

-- CMD 2004: MAP_OGRE_LIST (地图怪物列表)
-- 响应格式: 9个槽位 × (monsterID(4) + shiny(4)) = 72字节
-- monsterID=0 表示该位置没有怪物
-- shiny=1 表示稀有/闪光精灵
local function handleMapOgreList(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local mapId = user.mapId or 8
    
    -- 地图野怪配置 (可扩展)
    -- 格式: mapId -> {槽位索引 -> {petId, shiny, spawnRate}}
    local MAP_OGRES = {
        [8] = {  -- 新手地图
            [0] = {petId = 10, shiny = 0},   -- 皮皮
            [1] = {petId = 58, shiny = 0},   -- 比比鼠
        },
        [301] = {  -- 克洛斯星
            [0] = {petId = 1, shiny = 0},    -- 布布种子
            [1] = {petId = 4, shiny = 0},    -- 伊优
            [2] = {petId = 7, shiny = 0},    -- 小火猴
            [3] = {petId = 10, shiny = 0},   -- 皮皮
        },
    }
    
    local ogres = MAP_OGRES[mapId] or {}
    local body = ""
    
    -- 构建9个槽位的数据
    for i = 0, 8 do
        local ogre = ogres[i]
        if ogre then
            -- 稀有精灵随机出现 (10%几率变成闪光)
            local shiny = ogre.shiny
            if shiny == 0 and math.random() < 0.1 then
                shiny = 1
            end
            body = body .. writeUInt32BE(ogre.petId)
            body = body .. writeUInt32BE(shiny)
        else
            body = body .. writeUInt32BE(0)  -- 无怪物
            body = body .. writeUInt32BE(0)
        end
    end
    
    ctx.sendResponse(buildResponse(2004, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → MAP_OGRE_LIST response (map=%d)\27[0m", mapId))
    return true
end

-- CMD 2051: GET_SIM_USERINFO (获取简单用户信息)
-- 响应结构: userID(4) + nick(16) + color(4) + texture(4) + vip(4) + status(4) + 
--           mapType(4) + mapID(4) + isCanBeTeacher(4) + teacherID(4) + studentID(4) + 
--           graduationCount(4) + vipLevel(4) + teamId(4) + teamIsShow(4) + 
--           clothCount(4) + [clothId(4) + clothLevel(4)]...
local function handleGetSimUserInfo(ctx)
    -- 解析请求的目标用户ID
    local targetUserId = ctx.userId
    if #ctx.body >= 4 then
        targetUserId = readUInt32BE(ctx.body, 1)
    end
    
    local user = ctx.getOrCreateUser(targetUserId)
    local clothes = user.clothes or {}
    
    local body = writeUInt32BE(targetUserId) ..                    -- userID (4)
        writeFixedString(user.nick or user.nickname or user.username or ("赛尔" .. targetUserId), 16) ..              -- nick (16)
        writeUInt32BE(user.color or 0x3399FF) ..                   -- color (4)
        writeUInt32BE(user.texture or 0) ..                        -- texture (4)
        writeUInt32BE(user.vip or 1) ..                            -- vip (4)
        writeUInt32BE(0) ..                                        -- status (4)
        writeUInt32BE(user.mapType or 0) ..                        -- mapType (4)
        writeUInt32BE(user.mapId or 1) ..                          -- mapID (4)
        writeUInt32BE(0) ..                                        -- isCanBeTeacher (4)
        writeUInt32BE(user.teacherID or 0) ..                      -- teacherID (4)
        writeUInt32BE(user.studentID or 0) ..                      -- studentID (4)
        writeUInt32BE(user.graduationCount or 0) ..                -- graduationCount (4)
        writeUInt32BE(user.vipLevel or 10) ..                      -- vipLevel (4)
        writeUInt32BE(user.teamId or 0) ..                         -- teamId (4)
        writeUInt32BE(user.teamIsShow and 1 or 0) ..               -- teamIsShow (4)
        writeUInt32BE(#clothes)                                    -- clothCount (4)
    
    -- 添加服装列表
    for _, clothId in ipairs(clothes) do
        body = body .. writeUInt32BE(clothId) .. writeUInt32BE(0)  -- clothId + clothLevel
    end
    
    ctx.sendResponse(buildResponse(2051, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → GET_SIM_USERINFO for user %d response\27[0m", targetUserId))
    return true
end

-- CMD 2052: GET_MORE_USERINFO (获取详细用户信息)
-- 响应结构: userID(4) + nick(16) + regTime(4) + petAllNum(4) + petMaxLev(4) + 
--           bossAchievement(20) + graduationCount(4) + monKingWin(4) + 
--           messWin(4) + maxStage(4) + maxArenaWins(4)
-- 总长度: 4+16+4+4+4+20+4+4+4+4+4 = 72 bytes
local function handleGetMoreUserInfo(ctx)
    -- 解析请求的目标用户ID
    local targetUserId = ctx.userId
    if #ctx.body >= 4 then
        targetUserId = readUInt32BE(ctx.body, 1)
    end
    
    local user = ctx.getOrCreateUser(targetUserId)
    
    local body = writeUInt32BE(targetUserId) ..                    -- userID (4)
        writeFixedString(user.nick or user.nickname or user.username or ("赛尔" .. targetUserId), 16) ..              -- nick (16)
        writeUInt32BE(user.regTime or os.time()) ..                -- regTime (4)
        writeUInt32BE(user.petAllNum or 1) ..                      -- petAllNum (4)
        writeUInt32BE(user.petMaxLev or 100) ..                    -- petMaxLev (4)
        string.rep("\0", 20) ..                                    -- bossAchievement (20)
        writeUInt32BE(user.graduationCount or 0) ..                -- graduationCount (4)
        writeUInt32BE(user.monKingWin or 0) ..                     -- monKingWin (4)
        writeUInt32BE(user.messWin or 0) ..                        -- messWin (4)
        writeUInt32BE(user.maxStage or 0) ..                       -- maxStage (4)
        writeUInt32BE(user.maxArenaWins or 0)                      -- maxArenaWins (4)
    
    ctx.sendResponse(buildResponse(2052, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → GET_MORE_USERINFO for user %d response\27[0m", targetUserId))
    return true
end

-- CMD 2061: CHANGE_NICK_NAME (修改昵称)
-- ChangeUserNameInfo: userId(4) + nickName(16)
local function handleChangeNickName(ctx)
    local newNick = ""
    if #ctx.body >= 16 then
        newNick = Utils.readFixedString(ctx.body, 1, 16)
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.nick = newNick
    ctx.saveUserDB()
    
    print(string.format("\27[36m[Handler] 用户 %d 修改昵称为: %s\27[0m", ctx.userId, newNick))
    
    local body = writeUInt32BE(ctx.userId) .. writeFixedString(newNick, 16)
    ctx.sendResponse(buildResponse(2061, ctx.userId, 0, body))
    print("\27[32m[Handler] → CHANGE_NICK_NAME response\27[0m")
    return true
end

-- CMD 2101: PEOPLE_WALK (人物移动)
-- 请求格式: walkType(4) + x(4) + y(4) + amfLen(4) + amfData...
-- 响应格式: walkType(4) + userId(4) + x(4) + y(4) + amfLen(4) + amfData...
-- 需要广播给同地图其他玩家
local function handlePeopleWalk(ctx)
    local walkType = 0
    local x = 0
    local y = 0
    local amfLen = 0
    local amfData = ""
    
    if #ctx.body >= 4 then
        walkType = readUInt32BE(ctx.body, 1)
    end
    if #ctx.body >= 8 then
        x = readUInt32BE(ctx.body, 5)
    end
    if #ctx.body >= 12 then
        y = readUInt32BE(ctx.body, 9)
    end
    if #ctx.body >= 16 then
        amfLen = readUInt32BE(ctx.body, 13)
        if #ctx.body >= 16 + amfLen then
            amfData = ctx.body:sub(17, 16 + amfLen)
        end
    end
    
    -- 更新用户位置
    local user = ctx.getOrCreateUser(ctx.userId)
    user.x = x
    user.y = y
    
    -- 更新活跃时间
    OnlineTracker.updateActivity(ctx.userId)
    
    -- 构建响应 (包含完整的 AMF 数据)
    local body = writeUInt32BE(walkType) ..       -- walkType
                writeUInt32BE(ctx.userId) ..      -- userId
                writeUInt32BE(x) ..               -- x
                writeUInt32BE(y) ..               -- y
                writeUInt32BE(amfLen) ..          -- amfLen
                amfData                           -- amfData (透传)
    
    local response = buildResponse(2101, ctx.userId, 0, body)
    
    -- 获取当前地图并广播给同地图所有玩家
    local currentMapId = OnlineTracker.getPlayerMap(ctx.userId)
    if currentMapId > 0 then
        -- 广播给同地图所有玩家 (包括自己)
        local playersInMap = OnlineTracker.getPlayersInMap(currentMapId)
        for _, playerId in ipairs(playersInMap) do
            OnlineTracker.sendToPlayer(playerId, response)
        end
    else
        -- 如果没有地图信息，只回复给自己
        ctx.sendResponse(response)
    end
    
    return true
end

-- CMD 2102: CHAT (聊天)
-- ChatInfo: senderID(4) + senderNickName(16) + toID(4) + msgLen(4) + msg
local function handleChat(ctx)
    local chatType = 0
    local msgLen = 0
    local message = ""
    
    if #ctx.body >= 4 then
        chatType = readUInt32BE(ctx.body, 1)
    end
    if #ctx.body >= 8 then
        msgLen = readUInt32BE(ctx.body, 5)
        if #ctx.body >= 8 + msgLen then
            message = ctx.body:sub(9, 8 + msgLen)
        end
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local nickname = user.nick or user.nickname or user.username or ("赛尔" .. ctx.userId)
    
    -- 构建聊天响应
    local body = writeUInt32BE(ctx.userId) ..
                writeFixedString(nickname, 16) ..
                writeUInt32BE(0) ..              -- toID (0=公共)
                writeUInt32BE(#message) ..
                message
    
    local response = buildResponse(2102, ctx.userId, 0, body)
    
    -- 广播给同地图所有玩家
    local currentMapId = OnlineTracker.getPlayerMap(ctx.userId)
    if currentMapId > 0 then
        local playersInMap = OnlineTracker.getPlayersInMap(currentMapId)
        for _, playerId in ipairs(playersInMap) do
            OnlineTracker.sendToPlayer(playerId, response)
        end
    else
        ctx.sendResponse(response)
    end
    
    print(string.format("\27[32m[Handler] → CHAT: %s\27[0m", message:sub(1, 20)))
    return true
end
end

-- CMD 2103: DANCE_ACTION (舞蹈动作)
local function handleDanceAction(ctx)
    local actionId = 0
    local actionType = 0
    if #ctx.body >= 8 then
        actionId = readUInt32BE(ctx.body, 1)
        actionType = readUInt32BE(ctx.body, 5)
    end
    local body = writeUInt32BE(ctx.userId) ..
        writeUInt32BE(actionId) ..
        writeUInt32BE(actionType)
    ctx.sendResponse(buildResponse(2103, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → DANCE_ACTION %d response\27[0m", actionId))
    return true
end

-- CMD 2104: AIMAT (瞄准/交互)
local function handleAimat(ctx)
    local targetType, targetId, x, y = 0, 0, 0, 0
    if #ctx.body >= 16 then
        targetType = readUInt32BE(ctx.body, 1)
        targetId = readUInt32BE(ctx.body, 5)
        x = readUInt32BE(ctx.body, 9)
        y = readUInt32BE(ctx.body, 13)
    end
    local body = writeUInt32BE(ctx.userId) ..
        writeUInt32BE(targetType) ..
        writeUInt32BE(targetId) ..
        writeUInt32BE(x) ..
        writeUInt32BE(y)
    ctx.sendResponse(buildResponse(2104, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → AIMAT type=%d id=%d pos=(%d,%d)\27[0m", targetType, targetId, x, y))
    return true
end

-- CMD 2111: PEOPLE_TRANSFROM (变身)
-- TransformInfo: userID(4) + changeShape(4)
local function handlePeopleTransform(ctx)
    local transformId = 0
    if #ctx.body >= 4 then
        transformId = readUInt32BE(ctx.body, 1)
    end
    local body = writeUInt32BE(ctx.userId) .. writeUInt32BE(transformId)
    ctx.sendResponse(buildResponse(2111, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → PEOPLE_TRANSFROM %d response\27[0m", transformId))
    return true
end

-- 注册所有处理器
function MapHandlers.register(Handlers)
    Handlers.register(2001, handleEnterMap)
    Handlers.register(2002, handleLeaveMap)
    Handlers.register(2003, handleListMapPlayer)
    Handlers.register(2004, handleMapOgreList)
    Handlers.register(2051, handleGetSimUserInfo)
    Handlers.register(2052, handleGetMoreUserInfo)
    Handlers.register(2061, handleChangeNickName)
    Handlers.register(2101, handlePeopleWalk)
    Handlers.register(2102, handleChat)
    Handlers.register(2103, handleDanceAction)
    Handlers.register(2104, handleAimat)
    Handlers.register(2111, handlePeopleTransform)
    print("\27[36m[Handlers] 地图命令处理器已注册\27[0m")
end

return MapHandlers
