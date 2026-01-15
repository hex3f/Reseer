-- WebSocket Login Server
-- 使用模块化的 Handler 系统处理命令

local net = require "net"
local fs = require "fs"
local JSON = require "json"

-- 获取日志模块
local Logger = require("../logger")

-- 服务器列表管理模块
local ServerList = require("../serverlist")

-- 命令ID映射
local SeerCommands = require("../seer_commands")

-- 加载 Handler 系统
local Handlers = require("../handlers/init")

-- bit 操作
local bit = require("../bitop_compat")

-- 命令名称映射
local function getCmdName(cmdId)
    return SeerCommands.getName(cmdId)
end

-- 检查命令是否应该被隐藏
local function shouldHideCmd(cmdId)
    if not conf.hide_frequent_cmds then
        return false
    end
    for _, hideCmdId in ipairs(conf.hide_cmd_list or {}) do
        if cmdId == hideCmdId then
            return true
        end
    end
    return false
end

-- ========== WebSocket 协议实现 ==========

-- Base64 编码表
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function base64_encode(data)
    return ((data:gsub('.', function(x) 
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
        return b64chars:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

-- SHA1 实现
local function sha1(msg)
    local h0, h1, h2, h3, h4 = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0
    local nativebit = require('bit')
    local band, bor, bxor, bnot, rol, tobit = nativebit.band, nativebit.bor, nativebit.bxor, nativebit.bnot, nativebit.rol, nativebit.tobit
    local lshift, rshift = nativebit.lshift, nativebit.rshift
    
    local msgLen = #msg
    local bitLen = msgLen * 8
    msg = msg .. string.char(0x80)
    while (#msg % 64) ~= 56 do msg = msg .. string.char(0) end
    msg = msg .. string.char(0, 0, 0, 0)
    msg = msg .. string.char(band(rshift(bitLen, 24), 0xFF), band(rshift(bitLen, 16), 0xFF), band(rshift(bitLen, 8), 0xFF), band(bitLen, 0xFF))
    
    for i = 1, #msg, 64 do
        local w = {}
        for j = 0, 15 do
            local idx = i + j * 4
            w[j] = bor(lshift(msg:byte(idx), 24), lshift(msg:byte(idx + 1), 16), lshift(msg:byte(idx + 2), 8), msg:byte(idx + 3))
        end
        for j = 16, 79 do w[j] = rol(bxor(w[j-3], w[j-8], w[j-14], w[j-16]), 1) end
        
        local a, b, c, d, e = h0, h1, h2, h3, h4
        for j = 0, 79 do
            local f, k
            if j <= 19 then f = bor(band(b, c), band(bnot(b), d)); k = 0x5A827999
            elseif j <= 39 then f = bxor(b, c, d); k = 0x6ED9EBA1
            elseif j <= 59 then f = bor(band(b, c), band(b, d), band(c, d)); k = 0x8F1BBCDC
            else f = bxor(b, c, d); k = 0xCA62C1D6 end
            local temp = tobit(tobit(tobit(tobit(rol(a, 5) + f) + e) + k) + w[j])
            e, d, c, b, a = d, c, rol(b, 30), a, temp
        end
        h0, h1, h2, h3, h4 = tobit(h0 + a), tobit(h1 + b), tobit(h2 + c), tobit(h3 + d), tobit(h4 + e)
    end
    
    local function tounsigned(x) return x < 0 and x + 0x100000000 or x end
    local hash = ""
    for _, v in ipairs({h0, h1, h2, h3, h4}) do
        v = tounsigned(v)
        hash = hash .. string.char(band(rshift(v, 24), 0xFF), band(rshift(v, 16), 0xFF), band(rshift(v, 8), 0xFF), band(v, 0xFF))
    end
    return hash
end

local function computeAcceptKey(key)
    return base64_encode(sha1(key .. "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"))
end

-- WebSocket 帧操作码
local OPCODE_TEXT, OPCODE_BINARY, OPCODE_CLOSE, OPCODE_PING, OPCODE_PONG = 0x1, 0x2, 0x8, 0x9, 0xA

-- 解析 WebSocket 帧
local function parseWebSocketFrame(data)
    if #data < 2 then return nil end
    local byte1, byte2 = data:byte(1), data:byte(2)
    local opcode = bit.band(byte1, 0x0F)
    local masked = bit.band(byte2, 0x80) ~= 0
    local payloadLen = bit.band(byte2, 0x7F)
    local offset = 2
    
    if payloadLen == 126 then
        if #data < 4 then return nil end
        payloadLen = data:byte(3) * 256 + data:byte(4); offset = 4
    elseif payloadLen == 127 then
        if #data < 10 then return nil end
        payloadLen = 0
        for i = 3, 10 do payloadLen = payloadLen * 256 + data:byte(i) end
        offset = 10
    end
    
    local maskKey = nil
    if masked then
        if #data < offset + 4 then return nil end
        maskKey = data:sub(offset + 1, offset + 4); offset = offset + 4
    end
    
    if #data < offset + payloadLen then return nil end
    local payload = data:sub(offset + 1, offset + payloadLen)
    
    if masked and maskKey then
        local decoded = {}
        for i = 1, #payload do decoded[i] = string.char(bit.bxor(payload:byte(i), maskKey:byte(((i - 1) % 4) + 1))) end
        payload = table.concat(decoded)
    end
    
    return { opcode = opcode, payload = payload, totalLen = offset + payloadLen }
end

-- 构建 WebSocket 帧
local function buildWebSocketFrame(opcode, payload)
    local len = #payload
    local frame = string.char(0x80 + opcode)
    if len < 126 then frame = frame .. string.char(len)
    elseif len < 65536 then frame = frame .. string.char(126, math.floor(len / 256), len % 256)
    else
        frame = frame .. string.char(127)
        for i = 7, 0, -1 do frame = frame .. string.char(bit.band(bit.rshift(len, i * 8), 0xFF)) end
    end
    return frame .. payload
end

-- ========== 用户数据库 ==========

local USER_DB_FILE = "users.json"

local function loadUserDB()
    local success, content = pcall(function() return fs.readFileSync(USER_DB_FILE) end)
    if success and content then
        local ok, data = pcall(function() return JSON.parse(content) end)
        if ok and data then return data end
    end
    return { users = {}, nextUid = 100000001 }
end

local function saveUserDB(db)
    fs.writeFileSync(USER_DB_FILE, JSON.stringify(db))
end

local userDB = loadUserDB()

local function getOrCreateUser(uid, session)
    local uidStr = tostring(uid)
    if not userDB.users[uidStr] then
        userDB.users[uidStr] = { uid = uid, session = session, nick = "赛尔" .. uid, created = os.time() }
        saveUserDB(userDB)
        print(string.format("\27[32m[WS-LOGIN] Created new user: %d\27[0m", uid))
    else
        userDB.users[uidStr].session = session
        saveUserDB(userDB)
    end
    return userDB.users[uidStr]
end

-- ========== 协议工具函数 ==========

local function parsePacketHeader(data)
    if #data < 17 then return nil end
    local length = (data:byte(1) * 16777216) + (data:byte(2) * 65536) + (data:byte(3) * 256) + data:byte(4)
    local cmdId = (data:byte(6) * 16777216) + (data:byte(7) * 65536) + (data:byte(8) * 256) + data:byte(9)
    local userId = (data:byte(10) * 16777216) + (data:byte(11) * 65536) + (data:byte(12) * 256) + data:byte(13)
    return { length = length, cmdId = cmdId, userId = userId, body = data:sub(18) }
end

local function buildResponse(cmdId, userId, result, body)
    body = body or ""
    local length = 17 + #body
    return string.char(
        math.floor(length / 16777216) % 256, math.floor(length / 65536) % 256, math.floor(length / 256) % 256, length % 256,
        0x37,
        math.floor(cmdId / 16777216) % 256, math.floor(cmdId / 65536) % 256, math.floor(cmdId / 256) % 256, cmdId % 256,
        math.floor(userId / 16777216) % 256, math.floor(userId / 65536) % 256, math.floor(userId / 256) % 256, userId % 256,
        math.floor(result / 16777216) % 256, math.floor(result / 65536) % 256, math.floor(result / 256) % 256, result % 256
    ) .. body
end

local function writeUInt32BE(value)
    return string.char(math.floor(value / 16777216) % 256, math.floor(value / 65536) % 256, math.floor(value / 256) % 256, value % 256)
end

local function writeFixedString(str, length)
    str = str or ""
    if #str > length then
        str = str:sub(1, length)
    end
    while #str < length do
        str = str .. "\0"
    end
    return str
end

-- ========== 初始化 Handler 系统 ==========

Handlers.loadAll()

-- ========== 特殊命令处理 (登录流程相关) ==========

local function handleSpecialCommand(header, data, sendResponse)
    local cmdId = header.cmdId
    
    -- 登录流程相关命令需要特殊处理
    if cmdId == 104 then  -- MAIN_LOGIN_IN (邮箱登录)
        local email = ""
        if #data >= 17 + 64 then
            for i = 18, 17 + 64 do
                local b = data:byte(i)
                if b and b > 0 then email = email .. string.char(b) end
            end
        end
        print(string.format("\27[36m[WS-LOGIN] 邮箱登录: %s\27[0m", email))
        
        local userId = header.userId
        if userId == 0 then userId = 100000001 + math.random(0, 999999) end
        getOrCreateUser(userId, "")
        
        local sessionBytes = writeUInt32BE(userId)
        for i = 1, 12 do sessionBytes = sessionBytes .. string.char(math.random(0, 255)) end
        local responseBody = sessionBytes .. writeUInt32BE(1)
        
        sendResponse(buildResponse(104, userId, 0, responseBody))
        print(string.format("\27[32m[WS-LOGIN] → MAIN_LOGIN_IN response (userId=%d)\27[0m", userId))
        return true
        
    elseif cmdId == 111 then  -- FENGHAO_TIME
        sendResponse(buildResponse(111, header.userId, 0, writeUInt32BE(0)))
        print("\27[32m[WS-LOGIN] → FENGHAO_TIME response\27[0m")
        return true
        
    elseif cmdId == 109 then  -- SYS_ROLE
        local sessionHex = ""
        if #data >= 33 then
            for i = 18, 33 do sessionHex = sessionHex .. string.format("%02x", data:byte(i)) end
        end
        getOrCreateUser(header.userId, sessionHex)
        sendResponse(buildResponse(109, header.userId, 0, writeUInt32BE(0)))
        print("\27[32m[WS-LOGIN] → SYS_ROLE response\27[0m")
        return true
        
    elseif cmdId == 105 then  -- COMMEND_ONLINE
        local body = ServerList.buildCommendOnlineBody(1)
        sendResponse(buildResponse(105, header.userId, 0, body))
        print(string.format("\27[32m[WS-LOGIN] → Server list (%d servers)\27[0m", ServerList.getCount()))
        return true
        
    elseif cmdId == 106 then  -- RANGE_ONLINE
        local startId, endId = 1, 100
        if #data >= 25 then
            startId = (data:byte(18) * 16777216) + (data:byte(19) * 65536) + (data:byte(20) * 256) + data:byte(21)
            endId = (data:byte(22) * 16777216) + (data:byte(23) * 65536) + (data:byte(24) * 256) + data:byte(25)
        end
        sendResponse(buildResponse(106, header.userId, 0, ServerList.buildRangeOnlineBody(startId, endId)))
        print(string.format("\27[32m[WS-LOGIN] → Range server list (%d-%d)\27[0m", startId, endId))
        return true
    
    elseif cmdId == 1001 then  -- LOGIN_IN
        local user = getOrCreateUser(header.userId, "")
        local sessionHex, sessionBytes = "", ""
        if #data >= 33 then
            sessionBytes = data:sub(26, 33)
            for i = 26, 33 do sessionHex = sessionHex .. string.format("%02X", data:byte(i) or 0) end
        end
        print(string.format("\27[36m[WS-LOGIN] CMD 1001 session: %s\27[0m", sessionHex))
        
        -- 获取用户昵称，优先级: nick > nickname > username > 默认
        local nickname = user.nick or user.nickname or user.username or ("赛尔" .. header.userId)
        local nicknameBytes = nickname:sub(1, 16)
        while #nicknameBytes < 16 do nicknameBytes = nicknameBytes .. "\0" end
        
        -- regTime: 必须是2010年3月11日之后的时间戳才能使用新手教程
        -- checkIsNovice() 检查: regTime * 1000 转换为日期，格式化为 YYYYMMDDHHmm
        -- 如果 < 201003112359 则返回 false (使用旧教程)
        -- 使用当前时间戳确保是新用户
        local regTime = os.time()
        
        -- 检查用户是否已完成新手任务
        -- 注意: JSON 解析后 key 是字符串，需要用字符串索引
        local taskList = user.taskList or {}
        local task88Status = taskList[88] or taskList["88"] or 0
        local isNoviceComplete = (task88Status == 3)  -- 任务88完成状态
        
        -- 登录时的地图逻辑：
        -- 1. 新手未完成：进入新手地图515
        -- 2. 新手已完成：固定进入地图8（但保存玩家实际位置到 lastMapId）
        local mapId = 515  -- 默认新手教程地图
        if isNoviceComplete then
            -- 保存玩家上次的地图位置（用于后续可能的恢复）
            if user.mapId and user.mapId ~= 515 then
                user.lastMapId = user.mapId  -- 保存实际地图位置
            end
            mapId = 8  -- 固定进入地图8
            print(string.format("\27[32m[WS-LOGIN] 用户 %d 已完成新手任务，进入地图 8 (上次位置: %s)\27[0m", 
                header.userId, tostring(user.lastMapId or "无")))
        else
            print(string.format("\27[33m[WS-LOGIN] 用户 %d 新手任务未完成 (task88=%s)，进入新手地图 515\27[0m", header.userId, tostring(task88Status)))
        end
        
        -- ========== UserInfo.setForLoginInfo 完整结构 ==========
        -- 按照前端 UserInfo.as 的 setForLoginInfo 方法严格构建
        local body = ""
        
        -- 基础信息 (offset 0-23)
        body = body .. writeUInt32BE(header.userId)    -- userID (4)
        body = body .. writeUInt32BE(regTime)          -- regTime (4) - 重要！决定新手教程
        body = body .. nicknameBytes                   -- nick (16)
        
        -- VIP和标志 (offset 24-35)
        body = body .. writeUInt32BE(0)                -- vipFlags (4) - bit0=vip, bit1=viped
        body = body .. writeUInt32BE(0)                -- dsFlag (4)
        body = body .. writeUInt32BE(0xFFFFFF)         -- color (4)
        
        -- 外观和资源 (offset 36-55)
        body = body .. writeUInt32BE(0)                -- texture (4)
        body = body .. writeUInt32BE(100)              -- energy (4)
        body = body .. writeUInt32BE(10000)            -- coins (4)
        body = body .. writeUInt32BE(0)                -- fightBadge (4)
        body = body .. writeUInt32BE(mapId)            -- mapID (4) - 新手教程地图515
        
        -- 位置 (offset 56-63)
        body = body .. writeUInt32BE(500)              -- posX (4)
        body = body .. writeUInt32BE(300)              -- posY (4)
        
        -- 时间限制 (offset 64-75)
        body = body .. writeUInt32BE(0)                -- timeToday (4)
        body = body .. writeUInt32BE(0)                -- timeLimit (4)
        body = body .. string.char(0, 0, 0, 0)         -- halfDayFlags (4 bytes) - isClothHalfDay等
        
        -- 登录信息 (offset 76-87)
        body = body .. writeUInt32BE(0)                -- loginCnt (4) - 0表示首次登录
        body = body .. writeUInt32BE(0)                -- inviter (4)
        body = body .. writeUInt32BE(0)                -- newInviteeCnt (4)
        
        -- VIP详细信息 (offset 88-111)
        body = body .. writeUInt32BE(0)                -- vipLevel (4)
        body = body .. writeUInt32BE(0)                -- vipValue (4)
        body = body .. writeUInt32BE(1)                -- vipStage (4) - 默认1
        body = body .. writeUInt32BE(0)                -- autoCharge (4)
        body = body .. writeUInt32BE(0)                -- vipEndTime (4)
        body = body .. writeUInt32BE(0)                -- freshManBonus (4)
        
        -- nonoChipList (80 bytes) + dailyResArr (50 bytes) = 130 bytes
        body = body .. string.rep("\0", 80)            -- nonoChipList (80 bytes)
        body = body .. string.rep("\0", 50)            -- dailyResArr (50 bytes)
        
        -- 师徒系统 (offset 242-257)
        body = body .. writeUInt32BE(0)                -- teacherID (4)
        body = body .. writeUInt32BE(0)                -- studentID (4)
        body = body .. writeUInt32BE(0)                -- graduationCount (4)
        body = body .. writeUInt32BE(0)                -- maxPuniLv (4)
        
        -- 精灵统计 (offset 258-269)
        body = body .. writeUInt32BE(0)                -- petMaxLev (4)
        body = body .. writeUInt32BE(0)                -- petAllNum (4)
        body = body .. writeUInt32BE(0)                -- monKingWin (4)
        
        -- 关卡信息 (offset 270-289)
        body = body .. writeUInt32BE(0)                -- curStage (4) - 会+1
        body = body .. writeUInt32BE(0)                -- maxStage (4)
        body = body .. writeUInt32BE(0)                -- curFreshStage (4)
        body = body .. writeUInt32BE(0)                -- maxFreshStage (4)
        body = body .. writeUInt32BE(0)                -- maxArenaWins (4)
        
        -- 战斗次数 (offset 290-313)
        body = body .. writeUInt32BE(0)                -- twoTimes (4)
        body = body .. writeUInt32BE(0)                -- threeTimes (4)
        body = body .. writeUInt32BE(0)                -- autoFight (4)
        body = body .. writeUInt32BE(0)                -- autoFightTimes (4)
        body = body .. writeUInt32BE(0)                -- energyTimes (4)
        body = body .. writeUInt32BE(0)                -- learnTimes (4)
        
        -- 其他统计 (offset 314-337)
        body = body .. writeUInt32BE(0)                -- monBtlMedal (4)
        body = body .. writeUInt32BE(0)                -- recordCnt (4)
        body = body .. writeUInt32BE(0)                -- obtainTm (4)
        body = body .. writeUInt32BE(0)                -- soulBeadItemID (4)
        body = body .. writeUInt32BE(0)                -- expireTm (4)
        body = body .. writeUInt32BE(0)                -- fuseTimes (4)
        
        -- Nono信息 (offset 338-369)
        -- 从用户数据加载NONO信息
        local nonoData = user.nono or {}
        local hasNono = (nonoData.state and nonoData.state > 0) and 1 or 1  -- 默认有NONO
        local superNono = nonoData.superNono or 1
        local nonoState = nonoData.state or 1
        local nonoColor = nonoData.color or 0x00FBF4E1
        local nonoNick = nonoData.nick or "NoNo"
        
        body = body .. writeUInt32BE(hasNono)              -- hasNono (4) - 1=有NONO
        body = body .. writeUInt32BE(superNono)            -- superNono (4)
        body = body .. writeUInt32BE(nonoState)            -- nonoState (4) - 32位标志
        body = body .. writeUInt32BE(nonoColor)            -- nonoColor (4)
        body = body .. writeFixedString(nonoNick, 16)      -- nonoNick (16)
        
        -- TeamInfo (根据 TeamInfo.as 构造函数)
        -- id(4) + priv(4) + superCore(4) + isShow(4) + allContribution(4) + canExContribution(4)
        body = body .. writeUInt32BE(0)                -- teamInfo.id (4)
        body = body .. writeUInt32BE(0)                -- teamInfo.priv (4)
        body = body .. writeUInt32BE(0)                -- teamInfo.superCore (4)
        body = body .. writeUInt32BE(0)                -- teamInfo.isShow (4)
        body = body .. writeUInt32BE(0)                -- teamInfo.allContribution (4)
        body = body .. writeUInt32BE(0)                -- teamInfo.canExContribution (4)
        
        -- TeamPKInfo (根据 TeamPKInfo.as 构造函数)
        -- groupID(4) + homeTeamID(4)
        body = body .. writeUInt32BE(0)                -- teamPKInfo.groupID (4)
        body = body .. writeUInt32BE(0)                -- teamPKInfo.homeTeamID (4)
        
        -- 其他字段
        body = body .. string.char(0)                  -- 1 byte padding
        body = body .. writeUInt32BE(0)                -- badge (4)
        body = body .. string.rep("\0", 27)            -- reserved (27 bytes)
        
        -- ========== 任务列表 (500 bytes) - 关键！==========
        -- TasksManager.taskList 从这里读取
        -- 每个字节代表一个任务的状态: 0=未接受, 1=已接受, 3=已完成
        -- 注意: JSON 解析后 key 是字符串，需要同时检查数字和字符串索引
        local taskListBytes = ""
        local completedTasks = {}
        for i = 1, 500 do
            local taskStatus = taskList[i] or taskList[tostring(i)] or 0
            taskListBytes = taskListBytes .. string.char(taskStatus)
            if taskStatus == 3 then
                table.insert(completedTasks, i)
            end
        end
        body = body .. taskListBytes
        
        if #completedTasks > 0 then
            print(string.format("\27[32m[WS-LOGIN] 已完成任务: %s\27[0m", table.concat(completedTasks, ", ")))
        end
        
        -- ========== 精灵列表 ==========
        local petNum = 0
        local petId = user.currentPetId or 0
        local catchId = user.catchId or 0
        
        if petId > 0 and catchId > 0 then
            petNum = 1
        end
        
        body = body .. writeUInt32BE(petNum)           -- petNum (4)
        
        -- 如果有精灵，添加精灵信息
        -- PetInfo 结构 (根据 PetInfo.as 构造函数)
        if petNum > 0 then
            local petName = ""
            while #petName < 16 do petName = petName .. "\0" end
            
            body = body .. writeUInt32BE(petId)        -- id (4)
            body = body .. petName                     -- name (16)
            body = body .. writeUInt32BE(31)           -- dv (4)
            body = body .. writeUInt32BE(0)            -- nature (4)
            body = body .. writeUInt32BE(16)           -- level (4)
            body = body .. writeUInt32BE(100)          -- exp (4)
            body = body .. writeUInt32BE(0)            -- lvExp (4)
            body = body .. writeUInt32BE(1000)         -- nextLvExp (4)
            body = body .. writeUInt32BE(100)          -- hp (4)
            body = body .. writeUInt32BE(100)          -- maxHp (4)
            body = body .. writeUInt32BE(50)           -- attack (4)
            body = body .. writeUInt32BE(50)           -- defence (4)
            body = body .. writeUInt32BE(50)           -- s_a (4)
            body = body .. writeUInt32BE(50)           -- s_d (4)
            body = body .. writeUInt32BE(50)           -- speed (4)
            body = body .. writeUInt32BE(0)            -- addMaxHP (4)
            body = body .. writeUInt32BE(0)            -- addMoreMaxHP (4)
            body = body .. writeUInt32BE(0)            -- addAttack (4)
            body = body .. writeUInt32BE(0)            -- addDefence (4)
            body = body .. writeUInt32BE(0)            -- addSA (4)
            body = body .. writeUInt32BE(0)            -- addSD (4)
            body = body .. writeUInt32BE(0)            -- addSpeed (4)
            body = body .. writeUInt32BE(0)            -- ev_hp (4)
            body = body .. writeUInt32BE(0)            -- ev_attack (4)
            body = body .. writeUInt32BE(0)            -- ev_defence (4)
            body = body .. writeUInt32BE(0)            -- ev_sa (4)
            body = body .. writeUInt32BE(0)            -- ev_sd (4)
            body = body .. writeUInt32BE(0)            -- ev_sp (4)
            body = body .. writeUInt32BE(4)            -- skillNum (4)
            -- 4个技能 (每个: skillId(4) + pp(4) = 8字节)
            body = body .. writeUInt32BE(1) .. writeUInt32BE(35)   -- skill1
            body = body .. writeUInt32BE(2) .. writeUInt32BE(35)   -- skill2
            body = body .. writeUInt32BE(3) .. writeUInt32BE(35)   -- skill3
            body = body .. writeUInt32BE(4) .. writeUInt32BE(35)   -- skill4
            body = body .. writeUInt32BE(catchId)      -- catchTime (4)
            body = body .. writeUInt32BE(515)          -- catchMap (4)
            body = body .. writeUInt32BE(0)            -- catchRect (4)
            body = body .. writeUInt32BE(5)            -- catchLevel (4)
            -- effectCount (2) + effects
            body = body .. string.char(0, 0)           -- effectCount (2)
            body = body .. writeUInt32BE(0)            -- peteffect (4)
            body = body .. writeUInt32BE(0)            -- skinID (4)
            body = body .. writeUInt32BE(0)            -- shiny (4)
            body = body .. writeUInt32BE(0)            -- freeForbidden (4)
            body = body .. writeUInt32BE(0)            -- boss (4)
        end
        
        -- ========== 服装列表 ==========
        body = body .. writeUInt32BE(0)                -- clothNum (4)
        
        -- achievementsId
        body = body .. writeUInt32BE(0)                -- achievementsId (4)
        
        sendResponse(buildResponse(1001, header.userId, 0, body))
        print(string.format("\27[32m[WS-LOGIN] → LOGIN_IN response (userId=%d, regTime=%d, mapId=%d, bodyLen=%d)\27[0m", 
            header.userId, regTime, mapId, #body))
        return true
    end
    
    return false  -- 未处理
end

-- ========== 命令处理主函数 ==========

-- 存储当前连接的客户端 (用于广播)
local connectedClients = {}

local function handleCommand(header, data, sendResponse, clientId)
    local cmdId = header.cmdId
    local cmdName = getCmdName(cmdId)
    
    -- 检查是否应该隐藏此命令的日志
    local hideLog = shouldHideCmd(cmdId)
    
    if not hideLog then
        print(string.format("\27[36m[WS-LOGIN] CMD %d (%s) - User %d\27[0m", cmdId, cmdName, header.userId))
    end
    
    -- 记录接收到的命令到日志（始终记录到文件，不受隐藏设置影响）
    Logger.logCommand("RECV", cmdId, cmdName, header.userId, #data, data)
    
    -- 包装 sendResponse 以记录发送的数据
    local originalSendResponse = sendResponse
    local function loggingSendResponse(responseData)
        -- 解析响应头
        if responseData and #responseData >= 20 then
            local respLen = (responseData:byte(1) * 16777216) + (responseData:byte(2) * 65536) + 
                           (responseData:byte(3) * 256) + responseData:byte(4)
            local respCmd = (responseData:byte(5) * 256) + responseData:byte(6)
            local respUid = (responseData:byte(9) * 16777216) + (responseData:byte(10) * 65536) + 
                           (responseData:byte(11) * 256) + responseData:byte(12)
            local respResult = (responseData:byte(17) * 16777216) + (responseData:byte(18) * 65536) + 
                              (responseData:byte(19) * 256) + responseData:byte(20)
            local respBody = responseData:sub(21)
            
            Logger.logCommand("SEND", respCmd, getCmdName(respCmd), respUid, #responseData, respBody)
        end
        originalSendResponse(responseData)
    end
    
    -- 先尝试特殊命令处理
    if handleSpecialCommand(header, data, loggingSendResponse) then
        return
    end
    
    -- 广播函数 - 发送给同地图的其他玩家
    local function broadcastToMap(responseData, excludeUserId)
        local user = getOrCreateUser(header.userId)
        local currentMapId = user.mapId or 1
        
        for cid, clientInfo in pairs(connectedClients) do
            if clientInfo.userId ~= excludeUserId then
                local otherUser = getOrCreateUser(clientInfo.userId)
                if otherUser.mapId == currentMapId then
                    pcall(function()
                        clientInfo.sendResponse(responseData)
                    end)
                end
            end
        end
    end
    
    -- 保存用户数据的便捷函数
    local function saveUser(userId, userData)
        local key = tostring(userId)
        userDB.gameData = userDB.gameData or {}
        userDB.gameData[key] = userData
        saveUserDB(userDB)
    end
    
    -- 使用 Handler 系统处理
    local ctx = {
        userId = header.userId,
        body = header.body,
        data = data,
        sendResponse = loggingSendResponse,
        getOrCreateUser = getOrCreateUser,
        saveUserDB = function() saveUserDB(userDB) end,
        saveUser = saveUser,
        broadcastToMap = broadcastToMap,
        userDB = userDB,
    }
    
    if Handlers.has(cmdId) then
        Handlers.execute(cmdId, ctx)
    else
        -- 未实现的命令，返回空响应
        loggingSendResponse(buildResponse(cmdId, header.userId, 0, ""))
        print(string.format("\27[33m[WS-LOGIN] → Default response for CMD %d (%s)\27[0m", cmdId, getCmdName(cmdId)))
    end
end

-- ========== TCP 服务器 ==========

local nextClientId = 1

local server = net.createServer(function(client)
    local clientAddr = client:address()
    local clientId = nextClientId
    nextClientId = nextClientId + 1
    
    print(string.format("\27[36m[WS-LOGIN] New connection from %s (clientId=%d)\27[0m", clientAddr and clientAddr.ip or "unknown", clientId))
    
    local handshakeComplete = false
    local wsBuffer = ""
    local httpBuffer = ""
    local currentUserId = nil
    
    local function sendResponse(data)
        if handshakeComplete then
            local frame = buildWebSocketFrame(OPCODE_BINARY, data)
            client:write(frame)
        end
    end
    
    -- 注册客户端连接
    connectedClients[clientId] = {
        sendResponse = sendResponse,
        userId = nil
    }
    
    client:on("data", function(data)
        if not handshakeComplete then
            httpBuffer = httpBuffer .. data
            local headerEnd = httpBuffer:find("\r\n\r\n")
            if headerEnd then
                local wsKey = httpBuffer:match("Sec%-WebSocket%-Key:%s*([^\r\n]+)")
                local upgrade = httpBuffer:match("Upgrade:%s*([^\r\n]+)")
                
                if wsKey and upgrade and upgrade:lower() == "websocket" then
                    local acceptKey = computeAcceptKey(wsKey)
                    local response = "HTTP/1.1 101 Switching Protocols\r\n" ..
                        "Upgrade: websocket\r\n" ..
                        "Connection: Upgrade\r\n" ..
                        "Sec-WebSocket-Accept: " .. acceptKey .. "\r\n\r\n"
                    client:write(response)
                    handshakeComplete = true
                    print("\27[32m[WS-LOGIN] WebSocket handshake complete\27[0m")
                    
                    wsBuffer = httpBuffer:sub(headerEnd + 4)
                    httpBuffer = ""
                else
                    client:write("HTTP/1.1 400 Bad Request\r\n\r\n")
                    client:destroy()
                    return
                end
            end
        else
            wsBuffer = wsBuffer .. data
            while #wsBuffer > 0 do
                local frame = parseWebSocketFrame(wsBuffer)
                if not frame then break end
                wsBuffer = wsBuffer:sub(frame.totalLen + 1)
                
                if frame.opcode == OPCODE_CLOSE then
                    client:write(buildWebSocketFrame(OPCODE_CLOSE, ""))
                    client:destroy()
                    return
                elseif frame.opcode == OPCODE_PING then
                    client:write(buildWebSocketFrame(OPCODE_PONG, frame.payload))
                elseif frame.opcode == OPCODE_BINARY or frame.opcode == OPCODE_TEXT then
                    local header = parsePacketHeader(frame.payload)
                    if header then
                        -- 更新客户端的userId
                        if header.userId and header.userId > 0 then
                            currentUserId = header.userId
                            connectedClients[clientId].userId = header.userId
                        end
                        handleCommand(header, frame.payload, sendResponse, clientId)
                    end
                end
            end
        end
    end)
    
    client:on("error", function(err)
        print(string.format("\27[31m[WS-LOGIN] Client error: %s\27[0m", tostring(err)))
        connectedClients[clientId] = nil
    end)
    
    client:on("end", function()
        print("\27[36m[WS-LOGIN] Client disconnected\27[0m")
        connectedClients[clientId] = nil
    end)
end)

-- ========== 启动服务器 ==========

local function start(port)
    port = port or 1863
    server:listen(port, "0.0.0.0")
    print(string.format("\27[32m[WS-LOGIN] WebSocket Login Server started on port %d\27[0m", port))
    print(string.format("\27[32m[WS-LOGIN] Loaded %d command handlers\27[0m", Handlers.count()))
end

return {
    start = start,
    server = server
}
