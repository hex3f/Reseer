-- 本地游戏服务器 - 完整实现
-- 基于官服协议分析实现

local net = require('net')
local bit = require('../bitop_compat')
local json = require('json')
local fs = require('fs')

local LocalGameServer = {}
LocalGameServer.__index = LocalGameServer

-- 加载命令映射
local SeerCommands = require('../seer_commands')

local function getCmdName(cmdId)
    return SeerCommands.getName(cmdId)
end

-- 数据包结构:
-- 17 字节头部: length(4) + version(1) + cmdId(4) + userId(4) + result(4)
-- 然后是数据体

function LocalGameServer:new()
    local obj = {
        port = conf.gameserver_port or 5000,
        clients = {},
        sessions = {},  -- session -> user data
        users = {},     -- userId -> user data
        serverList = {},
        nextSeqId = 1,
    }
    setmetatable(obj, LocalGameServer)
    obj:loadUserData()
    obj:initServerList()
    obj:start()
    return obj
end

function LocalGameServer:loadUserData()
    -- 从 userdb 加载用户数据
    local userdb = require('../userdb')
    self.userdb = userdb
    print("\27[36m[LocalGame] 用户数据库已加载\27[0m")
end

function LocalGameServer:initServerList()
    -- 初始化服务器列表 (模拟官服的 29 个服务器)
    for i = 1, 29 do
        table.insert(self.serverList, {
            id = i,
            userCnt = math.random(10, 60),
            ip = "127.0.0.1",
            port = 5000 + i,
            friends = 0
        })
    end
    print(string.format("\27[36m[LocalGame] 初始化 %d 个服务器\27[0m", #self.serverList))
end

function LocalGameServer:start()
    local timer = require('timer')
    
    local server = net.createServer(function(client)
        local addr = client:address()
        print(string.format("\27[32m[LocalGame] 新连接: %s:%d\27[0m", 
            addr and addr.address or "unknown", addr and addr.port or 0))
        
        local clientData = {
            socket = client,
            buffer = "",
            userId = nil,
            session = nil,
            seqId = 0,
            heartbeatTimer = nil
        }
        table.insert(self.clients, clientData)
        
        -- 启动心跳定时器 (每3秒发送一次)
        clientData.heartbeatTimer = timer.setInterval(3000, function()
            if clientData.userId and clientData.userId > 0 then
                self:sendHeartbeat(clientData)
            end
        end)
        
        client:on('data', function(data)
            self:handleData(clientData, data)
        end)
        
        client:on('end', function()
            print("\27[33m[LocalGame] 客户端断开连接\27[0m")
            self:removeClient(clientData)
        end)
        
        client:on('error', function(err)
            print("\27[31m[LocalGame] 客户端错误: " .. tostring(err) .. "\27[0m")
            self:removeClient(clientData)
        end)
    end)
    
    server:listen(self.port, '0.0.0.0', function()
        print(string.format("\27[32m[LocalGame] ✓ 本地游戏服务器启动在端口 %d\27[0m", self.port))
    end)
    
    server:on('error', function(err)
        print("\27[31m[LocalGame] 服务器错误: " .. tostring(err) .. "\27[0m")
    end)
end

-- 发送心跳包
function LocalGameServer:sendHeartbeat(clientData)
    if not clientData.userId then return end
    -- CMD 80008 心跳包，只有包头，无body
    self:sendResponse(clientData, 80008, clientData.userId, 0, "")
end

function LocalGameServer:removeClient(clientData)
    -- 停止心跳定时器
    if clientData.heartbeatTimer then
        clientData.heartbeatTimer:close()
        clientData.heartbeatTimer = nil
    end
    
    for i, c in ipairs(self.clients) do
        if c == clientData then
            table.remove(self.clients, i)
            break
        end
    end
end

function LocalGameServer:handleData(clientData, data)
    -- 累积数据到缓冲区
    clientData.buffer = clientData.buffer .. data
    
    -- 尝试解析完整的数据包
    while #clientData.buffer >= 17 do
        -- 读取长度
        local length = clientData.buffer:byte(1) * 16777216 + 
                      clientData.buffer:byte(2) * 65536 + 
                      clientData.buffer:byte(3) * 256 + 
                      clientData.buffer:byte(4)
        
        if #clientData.buffer < length then
            break  -- 等待更多数据
        end
        
        -- 提取完整数据包
        local packet = clientData.buffer:sub(1, length)
        clientData.buffer = clientData.buffer:sub(length + 1)
        
        -- 解析数据包
        self:processPacket(clientData, packet)
    end
end

function LocalGameServer:processPacket(clientData, packet)
    if #packet < 17 then return end
    
    local length = packet:byte(1) * 16777216 + packet:byte(2) * 65536 + 
                   packet:byte(3) * 256 + packet:byte(4)
    local version = packet:byte(5)
    local cmdId = packet:byte(6) * 16777216 + packet:byte(7) * 65536 + 
                  packet:byte(8) * 256 + packet:byte(9)
    local userId = packet:byte(10) * 16777216 + packet:byte(11) * 65536 + 
                   packet:byte(12) * 256 + packet:byte(13)
    local seqId = packet:byte(14) * 16777216 + packet:byte(15) * 65536 + 
                  packet:byte(16) * 256 + packet:byte(17)
    
    local body = #packet > 17 and packet:sub(18) or ""
    
    clientData.userId = userId
    clientData.seqId = seqId
    
    print(string.format("\27[36m[LocalGame] 收到 CMD=%d (%s) UID=%d SEQ=%d LEN=%d\27[0m", 
        cmdId, getCmdName(cmdId), userId, seqId, length))
    
    -- 处理命令
    self:handleCommand(clientData, cmdId, userId, seqId, body)
end

function LocalGameServer:handleCommand(clientData, cmdId, userId, seqId, body)
    local handlers = {
        [105] = self.handleCommendOnline,      -- 获取服务器列表
        [106] = self.handleRangeOnline,        -- 获取指定范围服务器
        [1001] = self.handleLoginIn,           -- 登录游戏服务器
        [1002] = self.handleSystemTime,        -- 获取系统时间
        [1004] = self.handleMapHot,            -- 地图热度
        [1005] = self.handleGetImageAddress,   -- 获取图片地址
        [1102] = self.handleMoneyBuyProduct,   -- 金币购买商品
        [1104] = self.handleGoldBuyProduct,    -- 钻石购买商品
        [1106] = self.handleGoldOnlineCheckRemain, -- 检查金币余额
        [2001] = self.handleEnterMap,          -- 进入地图
        [2002] = self.handleLeaveMap,          -- 离开地图
        [2003] = self.handleListMapPlayer,     -- 地图玩家列表
        [2004] = self.handleMapOgreList,       -- 地图怪物列表
        [2051] = self.handleGetSimUserInfo,    -- 获取简单用户信息
        [2052] = self.handleGetMoreUserInfo,   -- 获取详细用户信息
        [2061] = self.handleChangeNickName,    -- 修改昵称
        [2101] = self.handlePeopleWalk,        -- 人物移动
        [2102] = self.handleChat,              -- 聊天
        [2103] = self.handleDanceAction,       -- 舞蹈动作
        [2104] = self.handleAimat,             -- 瞄准/交互
        [2111] = self.handlePeopleTransform,   -- 变身
        [2150] = self.handleGetRelationList,   -- 获取好友/黑名单列表
        [2201] = self.handleAcceptTask,        -- 接受任务
        [2202] = self.handleCompleteTask,      -- 完成任务
        [2203] = self.handleGetTaskBuf,        -- 获取任务缓存
        [2234] = self.handleGetDailyTaskBuf,   -- 获取每日任务缓存
        [2301] = self.handleGetPetInfo,        -- 获取精灵信息
        [2303] = self.handleGetPetList,        -- 获取精灵列表
        [2304] = self.handlePetRelease,        -- 释放精灵
        [2305] = self.handlePetShow,           -- 展示精灵
        [2306] = self.handlePetCure,           -- 治疗精灵
        [2309] = self.handlePetBargeList,      -- 精灵图鉴列表
        [2354] = self.handleGetSoulBeadList,   -- 获取灵魂珠列表
        [2401] = self.handleInviteToFight,     -- 邀请战斗
        [2404] = self.handleReadyToFight,      -- 准备战斗
        [2405] = self.handleUseSkillEnhanced,  -- 使用技能 (增强版)
        [2406] = self.handleUsePetItem,        -- 使用精灵道具
        [2407] = self.handleChangePet,         -- 更换精灵
        [2408] = self.handleFightNpcMonster,   -- 战斗NPC怪物
        [2409] = self.handleCatchMonster,      -- 捕捉精灵
        [2410] = self.handleEscapeFight,       -- 逃跑
        [2411] = self.handleChallengeBoss,     -- 挑战BOSS
        [2601] = self.handleItemBuy,           -- 购买物品
        [2604] = self.handleChangeCloth,       -- 更换服装
        [2605] = self.handleItemList,          -- 物品列表
        [2751] = self.handleMailGetList,       -- 获取邮件列表
        [2757] = self.handleMailGetUnread,     -- 获取未读邮件
        [8001] = self.handleInform,            -- 通知
        [8004] = self.handleGetBossMonster,    -- 获取BOSS怪物
        [9003] = self.handleNonoInfo,          -- 获取NONO信息
        [50004] = self.handleCmd50004,         -- 客户端信息上报
        [50008] = self.handleCmd50008,         -- 获取四倍经验时间
        [70001] = self.handleCmd70001,         -- 未知命令70001
        [80008] = self.handleNieoHeart,        -- 心跳包
    }
    
    local handler = handlers[cmdId]
    if handler then
        handler(self, clientData, cmdId, userId, seqId, body)
    else
        print(string.format("\27[33m[LocalGame] 未实现的命令: %d (%s)\27[0m", cmdId, getCmdName(cmdId)))
        -- 返回空响应
        self:sendResponse(clientData, cmdId, userId, 0, "")
    end
end

-- 构建响应数据包
function LocalGameServer:sendResponse(clientData, cmdId, userId, result, body)
    body = body or ""
    local length = 17 + #body
    
    local header = string.char(
        math.floor(length / 16777216) % 256,
        math.floor(length / 65536) % 256,
        math.floor(length / 256) % 256,
        length % 256,
        0x37,  -- version
        math.floor(cmdId / 16777216) % 256,
        math.floor(cmdId / 65536) % 256,
        math.floor(cmdId / 256) % 256,
        cmdId % 256,
        math.floor(userId / 16777216) % 256,
        math.floor(userId / 65536) % 256,
        math.floor(userId / 256) % 256,
        userId % 256,
        math.floor(result / 16777216) % 256,
        math.floor(result / 65536) % 256,
        math.floor(result / 256) % 256,
        result % 256
    )
    
    local packet = header .. body
    
    pcall(function()
        clientData.socket:write(packet)
    end)
    
    print(string.format("\27[32m[LocalGame] 发送 CMD=%d (%s) RESULT=%d LEN=%d\27[0m", 
        cmdId, getCmdName(cmdId), result, length))
end

-- 辅助函数：写入 4 字节大端整数
local function writeUInt32BE(value)
    return string.char(
        math.floor(value / 16777216) % 256,
        math.floor(value / 65536) % 256,
        math.floor(value / 256) % 256,
        value % 256
    )
end

-- 辅助函数：写入 2 字节大端整数
local function writeUInt16BE(value)
    return string.char(
        math.floor(value / 256) % 256,
        value % 256
    )
end

-- 辅助函数：写入固定长度字符串
local function writeFixedString(str, length)
    local result = str:sub(1, length)
    while #result < length do
        result = result .. "\0"
    end
    return result
end

-- 辅助函数：读取 4 字节大端整数
local function readUInt32BE(data, offset)
    offset = offset or 1
    return data:byte(offset) * 16777216 + 
           data:byte(offset + 1) * 65536 + 
           data:byte(offset + 2) * 256 + 
           data:byte(offset + 3)
end


-- ==================== 命令处理函数 ====================

-- CMD 105: 获取服务器列表
function LocalGameServer:handleCommendOnline(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 105: 获取服务器列表\27[0m")
    
    -- 响应结构:
    -- maxOnlineID: 4 字节
    -- isVIP: 4 字节
    -- onlineCnt: 4 字节
    -- 然后是 onlineCnt 个 ServerInfo (每个 30 字节)
    
    local maxOnlineID = #self.serverList
    local isVIP = 0
    local onlineCnt = #self.serverList
    
    local responseBody = writeUInt32BE(maxOnlineID) ..
                        writeUInt32BE(isVIP) ..
                        writeUInt32BE(onlineCnt)
    
    for _, server in ipairs(self.serverList) do
        -- ServerInfo: onlineID(4) + userCnt(4) + ip(16) + port(2) + friends(4) = 30 bytes
        responseBody = responseBody ..
            writeUInt32BE(server.id) ..
            writeUInt32BE(server.userCnt) ..
            writeFixedString(server.ip, 16) ..
            writeUInt16BE(server.port) ..
            writeUInt32BE(server.friends)
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 106: 获取指定范围服务器
function LocalGameServer:handleRangeOnline(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 106: 获取指定范围服务器\27[0m")
    
    local startId = 1
    local endId = #self.serverList
    
    if #body >= 8 then
        startId = readUInt32BE(body, 1)
        endId = readUInt32BE(body, 5)
    end
    
    local servers = {}
    for _, server in ipairs(self.serverList) do
        if server.id >= startId and server.id <= endId then
            table.insert(servers, server)
        end
    end
    
    local responseBody = writeUInt32BE(#servers)
    
    for _, server in ipairs(servers) do
        responseBody = responseBody ..
            writeUInt32BE(server.id) ..
            writeUInt32BE(server.userCnt) ..
            writeFixedString(server.ip, 16) ..
            writeUInt16BE(server.port) ..
            writeUInt32BE(server.friends)
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 1001: 登录游戏服务器
-- 响应结构完全按照 UserInfo.setForLoginInfo 解析顺序
-- 所有数据从用户数据读取
function LocalGameServer:handleLoginIn(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 1001: 登录游戏服务器\27[0m")
    
    -- 从 body 中提取 session (如果有)
    local session = ""
    if #body >= 16 then
        session = body:sub(1, 16)
    end
    
    -- 查找或创建用户数据
    local userData = self:getOrCreateUser(userId)
    clientData.session = session
    
    local nickname = userData.nick or userData.nickname or userData.username or ("赛尔" .. userId)
    local nonoData = userData.nono or {}
    local teamInfo = userData.teamInfo or {}
    local teamPKInfo = userData.teamPKInfo or {}
    local pets = userData.pets or {}
    local clothes = userData.clothes or {}
    
    -- 构建响应 (按 UserInfo.setForLoginInfo 解析顺序)
    local responseBody = ""
    
    -- 1. 基本信息
    responseBody = responseBody .. writeUInt32BE(userId)                              -- userID
    responseBody = responseBody .. writeUInt32BE(userData.regTime or os.time())       -- regTime
    responseBody = responseBody .. writeFixedString(nickname, 16)                     -- nick (16字节)
    
    -- vipFlags: bit0=vip, bit1=viped
    local vipFlags = 0
    if userData.vip then vipFlags = vipFlags + 1 end
    if userData.viped then vipFlags = vipFlags + 2 end
    responseBody = responseBody .. writeUInt32BE(vipFlags)                            -- vipFlags
    responseBody = responseBody .. writeUInt32BE(userData.dsFlag or 0)                -- dsFlag
    responseBody = responseBody .. writeUInt32BE(userData.color or 1)                 -- color
    responseBody = responseBody .. writeUInt32BE(userData.texture or 1)               -- texture
    responseBody = responseBody .. writeUInt32BE(userData.energy or 100)              -- energy
    responseBody = responseBody .. writeUInt32BE(userData.coins or 1000)              -- coins
    responseBody = responseBody .. writeUInt32BE(userData.fightBadge or 0)            -- fightBadge
    responseBody = responseBody .. writeUInt32BE(userData.mapID or 515)               -- mapID
    responseBody = responseBody .. writeUInt32BE(userData.posX or 300)                -- posX
    responseBody = responseBody .. writeUInt32BE(userData.posY or 200)                -- posY
    responseBody = responseBody .. writeUInt32BE(userData.timeToday or 0)             -- timeToday
    responseBody = responseBody .. writeUInt32BE(userData.timeLimit or 0)             -- timeLimit
    
    -- 2. halfDayFlags (4个byte)
    responseBody = responseBody .. string.char(
        userData.isClothHalfDay and 1 or 0,
        userData.isRoomHalfDay and 1 or 0,
        userData.iFortressHalfDay and 1 or 0,
        userData.isHQHalfDay and 1 or 0
    )
    
    -- 3. 登录/邀请信息
    responseBody = responseBody .. writeUInt32BE(userData.loginCnt or 1)              -- loginCnt
    responseBody = responseBody .. writeUInt32BE(userData.inviter or 0)               -- inviter
    responseBody = responseBody .. writeUInt32BE(userData.newInviteeCnt or 0)         -- newInviteeCnt
    
    -- 4. VIP信息
    responseBody = responseBody .. writeUInt32BE(userData.vipLevel or 0)              -- vipLevel
    responseBody = responseBody .. writeUInt32BE(userData.vipValue or 0)              -- vipValue
    responseBody = responseBody .. writeUInt32BE(userData.vipStage or 1)              -- vipStage
    responseBody = responseBody .. writeUInt32BE(userData.autoCharge or 0)            -- autoCharge
    responseBody = responseBody .. writeUInt32BE(userData.vipEndTime or 0)            -- vipEndTime
    responseBody = responseBody .. writeUInt32BE(userData.freshManBonus or 0)         -- freshManBonus
    
    -- 5. nonoChipList (80 bytes)
    responseBody = responseBody .. string.rep("\0", 80)
    
    -- 6. dailyResArr (50 bytes)
    responseBody = responseBody .. string.rep("\0", 50)
    
    -- 7. 师徒系统
    responseBody = responseBody .. writeUInt32BE(userData.teacherID or 0)             -- teacherID
    responseBody = responseBody .. writeUInt32BE(userData.studentID or 0)             -- studentID
    responseBody = responseBody .. writeUInt32BE(userData.graduationCount or 0)       -- graduationCount
    responseBody = responseBody .. writeUInt32BE(userData.maxPuniLv or 100)           -- maxPuniLv
    
    -- 8. 精灵相关
    responseBody = responseBody .. writeUInt32BE(userData.petMaxLev or 100)           -- petMaxLev
    responseBody = responseBody .. writeUInt32BE(userData.petAllNum or 0)             -- petAllNum
    responseBody = responseBody .. writeUInt32BE(userData.monKingWin or 0)            -- monKingWin
    
    -- 9. 关卡进度
    responseBody = responseBody .. writeUInt32BE(userData.curStage or 0)              -- curStage
    responseBody = responseBody .. writeUInt32BE(userData.maxStage or 0)              -- maxStage
    responseBody = responseBody .. writeUInt32BE(userData.curFreshStage or 0)         -- curFreshStage
    responseBody = responseBody .. writeUInt32BE(userData.maxFreshStage or 0)         -- maxFreshStage
    responseBody = responseBody .. writeUInt32BE(userData.maxArenaWins or 0)          -- maxArenaWins
    
    -- 10. 战斗加成
    responseBody = responseBody .. writeUInt32BE(userData.twoTimes or 0)              -- twoTimes
    responseBody = responseBody .. writeUInt32BE(userData.threeTimes or 0)            -- threeTimes
    responseBody = responseBody .. writeUInt32BE(userData.autoFight or 0)             -- autoFight
    responseBody = responseBody .. writeUInt32BE(userData.autoFightTimes or 0)        -- autoFightTimes
    responseBody = responseBody .. writeUInt32BE(userData.energyTimes or 0)           -- energyTimes
    responseBody = responseBody .. writeUInt32BE(userData.learnTimes or 0)            -- learnTimes
    
    -- 11. 其他
    responseBody = responseBody .. writeUInt32BE(userData.monBtlMedal or 0)           -- monBtlMedal
    responseBody = responseBody .. writeUInt32BE(userData.recordCnt or 0)             -- recordCnt
    responseBody = responseBody .. writeUInt32BE(userData.obtainTm or 0)              -- obtainTm
    responseBody = responseBody .. writeUInt32BE(userData.soulBeadItemID or 0)        -- soulBeadItemID
    responseBody = responseBody .. writeUInt32BE(userData.expireTm or 0)              -- expireTm
    responseBody = responseBody .. writeUInt32BE(userData.fuseTimes or 0)             -- fuseTimes
    
    -- 12. NONO信息
    responseBody = responseBody .. writeUInt32BE(userData.hasNono or nonoData.flag or 1)  -- hasNono
    responseBody = responseBody .. writeUInt32BE(userData.superNono or nonoData.superNono or 0)  -- superNono
    responseBody = responseBody .. writeUInt32BE(userData.nonoState or nonoData.state or 0)      -- nonoState
    responseBody = responseBody .. writeUInt32BE(userData.nonoColor or nonoData.color or 1)      -- nonoColor
    responseBody = responseBody .. writeFixedString(userData.nonoNick or nonoData.nick or "", 16) -- nonoNick
    
    -- 13. TeamInfo: id(4) + priv(4) + superCore(4) + isShow(4) + allContribution(4) + canExContribution(4) = 24字节
    responseBody = responseBody .. writeUInt32BE(teamInfo.id or 0)                    -- team.id
    responseBody = responseBody .. writeUInt32BE(teamInfo.priv or 0)                  -- team.priv
    responseBody = responseBody .. writeUInt32BE(teamInfo.superCore or 0)             -- team.superCore
    responseBody = responseBody .. writeUInt32BE(teamInfo.isShow and 1 or 0)          -- team.isShow
    responseBody = responseBody .. writeUInt32BE(teamInfo.allContribution or 0)       -- team.allContribution
    responseBody = responseBody .. writeUInt32BE(teamInfo.canExContribution or 0)     -- team.canExContribution
    
    -- 14. TeamPKInfo: groupID(4) + homeTeamID(4) = 8字节
    responseBody = responseBody .. writeUInt32BE(teamPKInfo.groupID or 0)             -- teamPK.groupID
    responseBody = responseBody .. writeUInt32BE(teamPKInfo.homeTeamID or 0)          -- teamPK.homeTeamID
    
    -- 15. 保留字段
    responseBody = responseBody .. string.char(0)                                     -- reserved (1 byte)
    responseBody = responseBody .. writeUInt32BE(userData.badge or 0)                 -- badge
    responseBody = responseBody .. string.rep("\0", 27)                               -- reserved (27 bytes)
    
    -- 16. taskList (500 bytes) - 任务状态
    responseBody = responseBody .. string.rep("\0", 500)
    
    -- 17. petNum + PetInfo[]
    responseBody = responseBody .. writeUInt32BE(#pets)                               -- petNum
    -- TODO: 如果有精灵，需要写入 PetInfo 数据
    
    -- 18. clothCount + clothes[]
    responseBody = responseBody .. writeUInt32BE(#clothes)                            -- clothCount
    -- TODO: 如果有服装，需要写入 clothes 数据
    
    -- 19. curTitle
    responseBody = responseBody .. writeUInt32BE(userData.curTitle or 0)              -- curTitle
    
    -- 20. bossAchievement (200 bytes)
    responseBody = responseBody .. string.rep("\0", 200)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
    
    print(string.format("\27[32m[LocalGame] ✓ 用户 %d 登录成功，响应大小: %d bytes\27[0m", userId, 17 + #responseBody))
end

-- CMD 1002: 获取系统时间
-- SystemTimeInfo 结构: timestamp(4) 只有一个字段
function LocalGameServer:handleSystemTime(clientData, cmdId, userId, seqId, body)
    local timestamp = os.time()
    local responseBody = writeUInt32BE(timestamp)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2001: 进入地图
-- 响应结构 (基于 UserInfo.setForPeoleInfo):
-- sysTime(4) + userID(4) + nick(16) + color(4) + texture(4) + vipFlags(4) + vipStage(4)
-- + actionType(4) + posX(4) + posY(4) + action(4) + direction(4) + changeShape(4)
-- + spiritTime(4) + spiritID(4) + petDV(4) + petSkin(4) + fightFlag(4)
-- + teacherID(4) + studentID(4) + nonoState(4) + nonoColor(4) + superNono(4)
-- + playerForm(4) + transTime(4)
-- + TeamInfo: id(4) + coreCount(4) + isShow(4) + logoBg(2) + logoIcon(2) + logoColor(2) + txtColor(2) + logoWord(4)
-- + clothCount(4) + clothes[clothCount]*(id(4)+level(4)) + curTitle(4)
-- 官服新用户: 161 bytes (body=144, clothCount=0)
function LocalGameServer:handleEnterMap(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2001: 进入地图\27[0m")
    
    local mapType = 0
    local mapId = 0
    local posX = 300
    local posY = 200
    
    if #body >= 4 then
        mapType = readUInt32BE(body, 1)
    end
    if #body >= 8 then
        mapId = readUInt32BE(body, 5)
    end
    if #body >= 12 then
        posX = readUInt32BE(body, 9)
    end
    if #body >= 16 then
        posY = readUInt32BE(body, 13)
    end
    
    local userData = self:getOrCreateUser(userId)
    local nickname = userData.nick or userData.nickname or userData.username or ("赛尔" .. userId)
    local clothes = userData.clothes or {}
    local teamInfo = userData.teamInfo or {}
    
    print(string.format("\27[36m[LocalGame] 用户 %d 进入地图 %d (type=%d) pos=(%d,%d)\27[0m", 
        userId, mapId, mapType, posX, posY))
    
    -- 构建 PeopleInfo 响应
    local responseBody = ""
    
    responseBody = responseBody .. writeUInt32BE(os.time())                 -- sysTime
    responseBody = responseBody .. writeUInt32BE(userId)                    -- userID
    responseBody = responseBody .. writeFixedString(nickname, 16)           -- nick (16字节)
    responseBody = responseBody .. writeUInt32BE(userData.color or 1)       -- color
    responseBody = responseBody .. writeUInt32BE(userData.texture or 1)     -- texture
    
    -- vipFlags: bit0=vip, bit1=viped
    local vipFlags = 0
    if userData.vip then vipFlags = vipFlags + 1 end
    if userData.viped then vipFlags = vipFlags + 2 end
    responseBody = responseBody .. writeUInt32BE(vipFlags)                  -- vipFlags
    responseBody = responseBody .. writeUInt32BE(userData.vipStage or 1)    -- vipStage
    
    responseBody = responseBody .. writeUInt32BE(0)                         -- actionType (0=走路)
    responseBody = responseBody .. writeUInt32BE(posX)                      -- posX
    responseBody = responseBody .. writeUInt32BE(posY)                      -- posY
    responseBody = responseBody .. writeUInt32BE(0)                         -- action
    responseBody = responseBody .. writeUInt32BE(1)                         -- direction
    responseBody = responseBody .. writeUInt32BE(userData.changeShape or 0) -- changeShape
    responseBody = responseBody .. writeUInt32BE(userData.spiritTime or 0)  -- spiritTime
    responseBody = responseBody .. writeUInt32BE(userData.spiritID or 0)    -- spiritID
    responseBody = responseBody .. writeUInt32BE(userData.petDV or 0)       -- petDV
    responseBody = responseBody .. writeUInt32BE(userData.petSkin or 0)     -- petSkin
    responseBody = responseBody .. writeUInt32BE(userData.fightFlag or 0)   -- fightFlag
    responseBody = responseBody .. writeUInt32BE(userData.teacherID or 0)   -- teacherID
    responseBody = responseBody .. writeUInt32BE(userData.studentID or 0)   -- studentID
    responseBody = responseBody .. writeUInt32BE(userData.nonoState or 0)   -- nonoState
    responseBody = responseBody .. writeUInt32BE(userData.nonoColor or 0)   -- nonoColor
    responseBody = responseBody .. writeUInt32BE(userData.superNono or 0)   -- superNono
    responseBody = responseBody .. writeUInt32BE(userData.playerForm or 0)  -- playerForm
    responseBody = responseBody .. writeUInt32BE(userData.transTime or 0)   -- transTime
    
    -- TeamInfo
    responseBody = responseBody .. writeUInt32BE(teamInfo.id or 0)          -- team.id
    responseBody = responseBody .. writeUInt32BE(teamInfo.coreCount or 0)   -- team.coreCount
    responseBody = responseBody .. writeUInt32BE(teamInfo.isShow or 0)      -- team.isShow
    responseBody = responseBody .. writeUInt16BE(teamInfo.logoBg or 0)      -- team.logoBg
    responseBody = responseBody .. writeUInt16BE(teamInfo.logoIcon or 0)    -- team.logoIcon
    responseBody = responseBody .. writeUInt16BE(teamInfo.logoColor or 0)   -- team.logoColor
    responseBody = responseBody .. writeUInt16BE(teamInfo.txtColor or 0)    -- team.txtColor
    responseBody = responseBody .. writeFixedString(teamInfo.logoWord or "", 4)  -- team.logoWord (4字节)
    
    -- clothes
    responseBody = responseBody .. writeUInt32BE(#clothes)                  -- clothCount
    for _, cloth in ipairs(clothes) do
        responseBody = responseBody .. writeUInt32BE(cloth.id or cloth[1] or 0)
        responseBody = responseBody .. writeUInt32BE(cloth.level or cloth[2] or 0)
    end
    
    -- curTitle
    responseBody = responseBody .. writeUInt32BE(userData.curTitle or 0)    -- curTitle
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2002: 离开地图
function LocalGameServer:handleLeaveMap(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2002: 离开地图\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 2051: 获取简单用户信息
function LocalGameServer:handleGetSimUserInfo(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2051: 获取简单用户信息\27[0m")
    
    local targetUserId = userId
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    local userData = self:getOrCreateUser(targetUserId)
    
    local responseBody = writeUInt32BE(targetUserId) ..
        writeFixedString(userData.nick or userData.nickname or userData.username or ("赛尔" .. targetUserId), 20) ..
        writeUInt32BE(userData.level or 1)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2052: 获取详细用户信息
function LocalGameServer:handleGetMoreUserInfo(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2052: 获取详细用户信息\27[0m")
    
    local targetUserId = userId
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    local userData = self:getOrCreateUser(targetUserId)
    
    local responseBody = writeUInt32BE(targetUserId) ..
        writeFixedString(userData.nick or userData.nickname or userData.username or ("赛尔" .. targetUserId), 20) ..
        writeUInt32BE(userData.level or 1) ..
        writeUInt32BE(userData.exp or 0) ..
        writeUInt32BE(userData.money or 10000) ..
        writeUInt32BE(userData.vipLevel or 0) ..
        writeUInt32BE(userData.petCount or 0)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2101: 人物移动
function LocalGameServer:handlePeopleWalk(clientData, cmdId, userId, seqId, body)
    -- 移动不需要响应，或者广播给其他玩家
    print("\27[36m[LocalGame] 处理 CMD 2101: 人物移动\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 2102: 聊天
-- ChatInfo 结构: senderID(4) + senderNickName(16) + toID(4) + msgLen(4) + msg(msgLen)
function LocalGameServer:handleChat(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2102: 聊天\27[0m")
    
    -- 解析聊天内容
    local chatType = 0
    local message = ""
    if #body >= 4 then
        chatType = readUInt32BE(body, 1)
        if #body > 4 then
            message = body:sub(5)
        end
    end
    
    print(string.format("\27[36m[LocalGame] 用户 %d 聊天: %s\27[0m", userId, message))
    
    local userData = self:getOrCreateUser(userId)
    local nickname = userData.nick or userData.nickname or userData.username or ("赛尔" .. userId)
    
    -- 构建 ChatInfo 响应
    local responseBody = ""
    responseBody = responseBody .. writeUInt32BE(userId)                     -- senderID
    responseBody = responseBody .. writeFixedString(nickname, 16)            -- senderNickName (16字节)
    responseBody = responseBody .. writeUInt32BE(0)                          -- toID (0=公共聊天)
    responseBody = responseBody .. writeUInt32BE(#message)                   -- msgLen
    responseBody = responseBody .. message                                   -- msg
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2201: 接受任务
function LocalGameServer:handleAcceptTask(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2201: 接受任务\27[0m")
    
    local taskId = 0
    if #body >= 4 then
        taskId = readUInt32BE(body, 1)
    end
    
    print(string.format("\27[36m[LocalGame] 用户 %d 接受任务 %d\27[0m", userId, taskId))
    
    local responseBody = writeUInt32BE(taskId)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2202: 完成任务
function LocalGameServer:handleCompleteTask(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2202: 完成任务\27[0m")
    
    local taskId = 0
    local param = 0
    if #body >= 4 then
        taskId = readUInt32BE(body, 1)
    end
    if #body >= 8 then
        param = readUInt32BE(body, 5)
    end
    
    print(string.format("\27[36m[LocalGame] 用户 %d 完成任务 %d (param=%d)\27[0m", userId, taskId, param))
    
    -- 响应格式 (NoviceFinishInfo):
    -- taskID (4字节) - 任务ID
    -- petID (4字节) - 精灵ID (完成任务获得的精灵，0表示无)
    -- captureTm (4字节) - 捕获时间戳 (精灵的catchId)
    -- itemCount (4字节) - 奖励物品数量
    -- [itemID(4) + itemCnt(4)]... - 物品列表
    
    local userData = self:getOrCreateUser(userId)
    local petId = 0
    local captureTm = 0
    local responseBody = ""
    
    if taskId == 85 then  -- 0x55 - 新手任务1 (领取服装)
        responseBody = writeUInt32BE(taskId) ..
            writeUInt32BE(0) ..  -- petID: 无精灵奖励
            writeUInt32BE(0) ..  -- captureTm: 无
            writeUInt32BE(8) ..  -- itemCount: 8个物品
            writeUInt32BE(0x0186BB) .. writeUInt32BE(1) ..
            writeUInt32BE(0x0186BC) .. writeUInt32BE(1) ..
            writeUInt32BE(0x0186A1) .. writeUInt32BE(1) ..
            writeUInt32BE(0x0186A2) .. writeUInt32BE(1) ..
            writeUInt32BE(0x0186A3) .. writeUInt32BE(1) ..
            writeUInt32BE(0x0186A4) .. writeUInt32BE(1) ..
            writeUInt32BE(0x0186A5) .. writeUInt32BE(1) ..
            writeUInt32BE(0x0186A6) .. writeUInt32BE(1)
            
    elseif taskId == 86 then  -- 0x56 - 新手任务2 (选择精灵)
        petId = param > 0 and param or 7
        captureTm = 0x69686700 + petId
        userData.currentPetId = petId
        
        responseBody = writeUInt32BE(taskId) ..
            writeUInt32BE(petId) ..      -- petID: 获得的精灵
            writeUInt32BE(captureTm) ..  -- captureTm: 精灵的catchId
            writeUInt32BE(0)             -- itemCount: 无物品奖励
            
    elseif taskId == 87 then  -- 0x57 - 新手任务3 (战斗胜利)
        responseBody = writeUInt32BE(taskId) ..
            writeUInt32BE(0) ..
            writeUInt32BE(0) ..
            writeUInt32BE(3) ..
            writeUInt32BE(0x0493E1) .. writeUInt32BE(5) ..
            writeUInt32BE(0x0493EB) .. writeUInt32BE(5) ..
            writeUInt32BE(0x0493E6) .. writeUInt32BE(5)
            
    elseif taskId == 88 then  -- 0x58 - 新手任务4 (使用道具)
        responseBody = writeUInt32BE(taskId) ..
            writeUInt32BE(0) ..
            writeUInt32BE(0) ..
            writeUInt32BE(1) ..
            writeUInt32BE(1) .. writeUInt32BE(5000)
    else
        responseBody = writeUInt32BE(taskId) ..
            writeUInt32BE(0) ..
            writeUInt32BE(0) ..
            writeUInt32BE(0)
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2203: 获取任务缓存
function LocalGameServer:handleGetTaskBuf(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2203: 获取任务缓存\27[0m")
    
    -- 返回空任务列表
    local responseBody = writeUInt32BE(0)  -- 任务数量
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2301: 获取精灵信息
-- PetInfo (完整版 param2=true) 结构:
-- id(4) + name(16) + dv(4) + nature(4) + level(4) + exp(4) + lvExp(4) + nextLvExp(4)
-- + hp(4) + maxHp(4) + attack(4) + defence(4) + s_a(4) + s_d(4) + speed(4)
-- + addMaxHP(4) + addMoreMaxHP(4) + addAttack(4) + addDefence(4) + addSA(4) + addSD(4) + addSpeed(4)
-- + ev_hp(4) + ev_attack(4) + ev_defence(4) + ev_sa(4) + ev_sd(4) + ev_sp(4)
-- + skillNum(4) + skills[4]*(id(4)+pp(4)) + catchTime(4) + catchMap(4) + catchRect(4) + catchLevel(4)
-- + effectCount(2) + [PetEffectInfo]... + peteffect(4) + skinID(4) + shiny(4) + freeForbidden(4) + boss(4)
function LocalGameServer:handleGetPetInfo(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2301: 获取精灵信息\27[0m")
    
    local catchId = 0
    if #body >= 4 then
        catchId = readUInt32BE(body, 1)
    end
    
    local userData = self:getOrCreateUser(userId)
    local petId = userData.currentPetId or 7
    
    local responseBody = ""
    
    -- PetInfo (完整版)
    responseBody = responseBody .. writeUInt32BE(petId)      -- id
    responseBody = responseBody .. writeFixedString("", 16)  -- name (16字节)
    responseBody = responseBody .. writeUInt32BE(31)         -- dv (个体值)
    responseBody = responseBody .. writeUInt32BE(0)          -- nature (性格)
    responseBody = responseBody .. writeUInt32BE(16)         -- level
    responseBody = responseBody .. writeUInt32BE(0)          -- exp
    responseBody = responseBody .. writeUInt32BE(0)          -- lvExp
    responseBody = responseBody .. writeUInt32BE(1000)       -- nextLvExp
    responseBody = responseBody .. writeUInt32BE(100)        -- hp
    responseBody = responseBody .. writeUInt32BE(100)        -- maxHp
    responseBody = responseBody .. writeUInt32BE(39)         -- attack
    responseBody = responseBody .. writeUInt32BE(35)         -- defence
    responseBody = responseBody .. writeUInt32BE(78)         -- s_a (特攻)
    responseBody = responseBody .. writeUInt32BE(36)         -- s_d (特防)
    responseBody = responseBody .. writeUInt32BE(39)         -- speed
    responseBody = responseBody .. writeUInt32BE(0)          -- addMaxHP
    responseBody = responseBody .. writeUInt32BE(0)          -- addMoreMaxHP
    responseBody = responseBody .. writeUInt32BE(0)          -- addAttack
    responseBody = responseBody .. writeUInt32BE(0)          -- addDefence
    responseBody = responseBody .. writeUInt32BE(0)          -- addSA
    responseBody = responseBody .. writeUInt32BE(0)          -- addSD
    responseBody = responseBody .. writeUInt32BE(0)          -- addSpeed
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_hp
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_attack
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_defence
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sa
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sd
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sp
    responseBody = responseBody .. writeUInt32BE(4)          -- skillNum
    -- 4个技能槽 (id + pp)
    responseBody = responseBody .. writeUInt32BE(10022) .. writeUInt32BE(30)  -- 技能1
    responseBody = responseBody .. writeUInt32BE(10035) .. writeUInt32BE(25)  -- 技能2
    responseBody = responseBody .. writeUInt32BE(20036) .. writeUInt32BE(20)  -- 技能3
    responseBody = responseBody .. writeUInt32BE(0) .. writeUInt32BE(0)       -- 技能4 (空)
    responseBody = responseBody .. writeUInt32BE(catchId)    -- catchTime
    responseBody = responseBody .. writeUInt32BE(301)        -- catchMap
    responseBody = responseBody .. writeUInt32BE(0)          -- catchRect
    responseBody = responseBody .. writeUInt32BE(5)          -- catchLevel
    responseBody = responseBody .. writeUInt16BE(0)          -- effectCount
    responseBody = responseBody .. writeUInt32BE(0)          -- peteffect
    responseBody = responseBody .. writeUInt32BE(0)          -- skinID
    responseBody = responseBody .. writeUInt32BE(0)          -- shiny
    responseBody = responseBody .. writeUInt32BE(0)          -- freeForbidden
    responseBody = responseBody .. writeUInt32BE(0)          -- boss
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
    print(string.format("\27[32m[LocalGame] → GET_PET_INFO catchId=%d petId=%d\27[0m", catchId, petId))
end

-- CMD 2303: 获取精灵列表
function LocalGameServer:handleGetPetList(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2303: 获取精灵列表\27[0m")
    
    -- 返回空精灵列表
    local responseBody = writeUInt32BE(0)  -- 精灵数量
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2354: 获取灵魂珠列表
function LocalGameServer:handleGetSoulBeadList(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2354: 获取灵魂珠列表\27[0m")
    
    -- 返回空列表
    local responseBody = writeUInt32BE(0)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end


-- CMD 2401: 邀请战斗
function LocalGameServer:handleInviteToFight(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2401: 邀请战斗\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 2405: 使用技能
function LocalGameServer:handleUseSkill(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2405: 使用技能\27[0m")
    
    local skillId = 0
    if #body >= 4 then
        skillId = readUInt32BE(body, 1)
    end
    
    -- 返回技能使用结果
    local responseBody = writeUInt32BE(skillId) ..
        writeUInt32BE(100) ..  -- 伤害
        writeUInt32BE(0)       -- 效果
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2408: 战斗NPC怪物
function LocalGameServer:handleFightNpcMonster(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2408: 战斗NPC怪物\27[0m")
    
    local monsterId = 0
    if #body >= 4 then
        monsterId = readUInt32BE(body, 1)
    end
    
    print(string.format("\27[36m[LocalGame] 用户 %d 挑战怪物 %d\27[0m", userId, monsterId))
    
    -- 返回战斗开始信息
    local responseBody = writeUInt32BE(monsterId) ..
        writeUInt32BE(1)  -- 战斗ID
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2410: 逃跑
function LocalGameServer:handleEscapeFight(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2410: 逃跑\27[0m")
    
    local responseBody = writeUInt32BE(1)  -- 逃跑成功
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2757: 获取未读邮件
function LocalGameServer:handleMailGetUnread(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2757: 获取未读邮件\27[0m")
    
    -- 返回未读邮件数量
    local responseBody = writeUInt32BE(0)  -- 0 封未读邮件
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 9003: 获取NONO信息
-- NonoInfo 结构 (基于 NonoInfo.as):
-- userID(4) + flag(4) + [如果flag!=0: state(4) + nick(16) + superNono(4) + color(4)
--   + power(4) + mate(4) + iq(4) + ai(2) + birth(4) + chargeTime(4) + func(20)
--   + superEnergy(4) + superLevel(4) + superStage(4)]
-- 官服新用户默认有 NONO，返回完整结构 90 bytes body
function LocalGameServer:handleNonoInfo(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 9003: 获取NONO信息\27[0m")
    
    local targetUserId = userId
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    local userData = self:getOrCreateUser(targetUserId)
    local nonoData = userData.nono or {}
    
    local responseBody = writeUInt32BE(targetUserId)
    
    -- 新用户默认有 NONO，flag=1
    local flag = nonoData.flag or userData.hasNono or 1
    
    responseBody = responseBody .. writeUInt32BE(flag)                      -- flag (32位标志)
    responseBody = responseBody .. writeUInt32BE(nonoData.state or userData.nonoState or 0)  -- state
    responseBody = responseBody .. writeFixedString(nonoData.nick or userData.nonoNick or "", 16)  -- nick (16字节)
    responseBody = responseBody .. writeUInt32BE(nonoData.superNono or userData.superNono or 0)    -- superNono
    responseBody = responseBody .. writeUInt32BE(nonoData.color or userData.nonoColor or 1)        -- color (默认1)
    responseBody = responseBody .. writeUInt32BE((nonoData.power or 50) * 1000)   -- power (×1000, 默认50%)
    responseBody = responseBody .. writeUInt32BE((nonoData.mate or 50) * 1000)    -- mate (×1000, 默认50%)
    responseBody = responseBody .. writeUInt32BE(nonoData.iq or 100)              -- iq (默认100)
    responseBody = responseBody .. writeUInt16BE(nonoData.ai or 0)                -- ai (2字节)
    responseBody = responseBody .. writeUInt32BE(nonoData.birth or os.time())     -- birth (默认当前时间)
    responseBody = responseBody .. writeUInt32BE(nonoData.chargeTime or 0)        -- chargeTime
    responseBody = responseBody .. string.rep("\0", 20)                           -- func (20字节)
    responseBody = responseBody .. writeUInt32BE(nonoData.superEnergy or 0)       -- superEnergy
    responseBody = responseBody .. writeUInt32BE(nonoData.superLevel or 0)        -- superLevel
    responseBody = responseBody .. writeUInt32BE(nonoData.superStage or 1)        -- superStage (默认1)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 50004: 客户端信息上报
function LocalGameServer:handleCmd50004(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 50004: 客户端信息上报\27[0m")
    
    -- 解析客户端信息 (User-Agent 等)
    if #body > 4 then
        local infoType = readUInt32BE(body, 1)
        local infoLen = readUInt32BE(body, 5)
        local info = body:sub(9, 8 + infoLen)
        print(string.format("\27[36m[LocalGame] 客户端信息: type=%d, info=%s\27[0m", infoType, info:sub(1, 50)))
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 50008: 获取四倍经验时间
function LocalGameServer:handleCmd50008(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 50008: 获取四倍经验时间\27[0m")
    -- 返回四倍经验剩余时间 (0 = 无)
    local responseBody = writeUInt32BE(0)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2003: 获取地图玩家列表
function LocalGameServer:handleListMapPlayer(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2003: 获取地图玩家列表\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    
    -- 返回当前玩家信息 (只有自己)
    -- 结构: playerCount(4) + [PlayerInfo...]
    -- PlayerInfo: userId(4) + nickname(20) + x(4) + y(4) + direction(4) + ...
    
    local responseBody = writeUInt32BE(1)  -- 1个玩家
    
    -- 玩家信息
    responseBody = responseBody ..
        writeUInt32BE(userId) ..
        writeFixedString(userData.nick or userData.nickname or userData.username or ("赛尔" .. userId), 20) ..
        string.rep("\0", 20) ..  -- 额外数据
        writeUInt32BE(0xFFFFFF) ..  -- 颜色
        writeUInt32BE(0) ..  -- 未知
        writeUInt32BE(15) ..  -- 等级
        writeUInt32BE(0) ..  -- 未知
        writeUInt32BE(userData.currentPetId or 7) ..  -- 当前精灵ID
        string.rep("\0", 60)  -- 更多数据
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2103: 舞蹈动作
function LocalGameServer:handleDanceAction(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2103: 舞蹈动作\27[0m")
    
    local actionId = 0
    local actionType = 0
    if #body >= 8 then
        actionId = readUInt32BE(body, 1)
        actionType = readUInt32BE(body, 5)
    end
    
    print(string.format("\27[36m[LocalGame] 用户 %d 执行动作 %d 类型 %d\27[0m", userId, actionId, actionType))
    
    -- 广播给其他玩家
    local responseBody = writeUInt32BE(userId) ..
        writeUInt32BE(actionId) ..
        writeUInt32BE(actionType)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2104: 瞄准/交互
function LocalGameServer:handleAimat(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2104: 瞄准/交互\27[0m")
    
    local targetType = 0
    local targetId = 0
    local x = 0
    local y = 0
    
    if #body >= 16 then
        targetType = readUInt32BE(body, 1)
        targetId = readUInt32BE(body, 5)
        x = readUInt32BE(body, 9)
        y = readUInt32BE(body, 13)
    end
    
    print(string.format("\27[36m[LocalGame] 用户 %d 瞄准 type=%d id=%d pos=(%d,%d)\27[0m", 
        userId, targetType, targetId, x, y))
    
    local responseBody = writeUInt32BE(userId) ..
        writeUInt32BE(targetType) ..
        writeUInt32BE(targetId) ..
        writeUInt32BE(x) ..
        writeUInt32BE(y)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2111: 变身
-- TransformInfo 结构: userID(4) + changeShape(4)
function LocalGameServer:handlePeopleTransform(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2111: 变身\27[0m")
    
    local transformId = 0
    if #body >= 4 then
        transformId = readUInt32BE(body, 1)
    end
    
    print(string.format("\27[36m[LocalGame] 用户 %d 变身为 %d\27[0m", userId, transformId))
    
    -- 构建 TransformInfo 响应
    local responseBody = writeUInt32BE(userId) .. writeUInt32BE(transformId)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2304: 释放精灵
-- PetTakeOutInfo 结构 (基于 AS3 代码分析):
-- homeEnergy (4字节) - 家园能量
-- firstPetTime (4字节) - 首次精灵时间
-- flag (4字节) - 标志 (非0时有精灵信息)
-- [PetInfo] - 精灵完整信息 (仅当 flag != 0)
--
-- PetInfo (完整版 param2=true):
-- id(4) + name(16) + dv(4) + nature(4) + level(4) + exp(4) + lvExp(4) + nextLvExp(4)
-- + hp(4) + maxHp(4) + attack(4) + defence(4) + s_a(4) + s_d(4) + speed(4)
-- + addMaxHP(4) + addMoreMaxHP(4) + addAttack(4) + addDefence(4) + addSA(4) + addSD(4) + addSpeed(4)
-- + ev_hp(4) + ev_attack(4) + ev_defence(4) + ev_sa(4) + ev_sd(4) + ev_sp(4)
-- + skillNum(4) + skills[4]*(id(4)+pp(4)) + catchTime(4) + catchMap(4) + catchRect(4) + catchLevel(4)
-- + effectCount(2) + [PetEffectInfo]... + peteffect(4) + skinID(4) + shiny(4) + freeForbidden(4) + boss(4)
function LocalGameServer:handlePetRelease(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2304: 释放精灵\27[0m")
    
    local catchId = 0
    local petType = 0
    
    if #body >= 8 then
        catchId = readUInt32BE(body, 1)
        petType = readUInt32BE(body, 5)
    end
    
    print(string.format("\27[36m[LocalGame] 用户 %d 释放精灵 catchId=%d type=%d\27[0m", 
        userId, catchId, petType))
    
    local userData = self:getOrCreateUser(userId)
    userData.currentPetId = petType
    userData.catchId = catchId
    
    local responseBody = ""
    
    -- PetTakeOutInfo 结构
    responseBody = responseBody .. writeUInt32BE(100)        -- homeEnergy
    responseBody = responseBody .. writeUInt32BE(os.time())  -- firstPetTime
    responseBody = responseBody .. writeUInt32BE(1)          -- flag (有精灵信息)
    
    -- PetInfo (完整版)
    responseBody = responseBody .. writeUInt32BE(petType)    -- id
    responseBody = responseBody .. writeFixedString("", 16)  -- name (16字节)
    responseBody = responseBody .. writeUInt32BE(31)         -- dv (个体值)
    responseBody = responseBody .. writeUInt32BE(0)          -- nature (性格)
    responseBody = responseBody .. writeUInt32BE(16)         -- level
    responseBody = responseBody .. writeUInt32BE(0)          -- exp
    responseBody = responseBody .. writeUInt32BE(0)          -- lvExp
    responseBody = responseBody .. writeUInt32BE(1000)       -- nextLvExp
    responseBody = responseBody .. writeUInt32BE(100)        -- hp
    responseBody = responseBody .. writeUInt32BE(100)        -- maxHp
    responseBody = responseBody .. writeUInt32BE(39)         -- attack
    responseBody = responseBody .. writeUInt32BE(35)         -- defence
    responseBody = responseBody .. writeUInt32BE(78)         -- s_a (特攻)
    responseBody = responseBody .. writeUInt32BE(36)         -- s_d (特防)
    responseBody = responseBody .. writeUInt32BE(39)         -- speed
    responseBody = responseBody .. writeUInt32BE(0)          -- addMaxHP
    responseBody = responseBody .. writeUInt32BE(0)          -- addMoreMaxHP
    responseBody = responseBody .. writeUInt32BE(0)          -- addAttack
    responseBody = responseBody .. writeUInt32BE(0)          -- addDefence
    responseBody = responseBody .. writeUInt32BE(0)          -- addSA
    responseBody = responseBody .. writeUInt32BE(0)          -- addSD
    responseBody = responseBody .. writeUInt32BE(0)          -- addSpeed
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_hp
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_attack
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_defence
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sa
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sd
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sp
    responseBody = responseBody .. writeUInt32BE(4)          -- skillNum
    -- 4个技能槽 (id + pp)
    responseBody = responseBody .. writeUInt32BE(10022) .. writeUInt32BE(30)  -- 技能1
    responseBody = responseBody .. writeUInt32BE(10035) .. writeUInt32BE(25)  -- 技能2
    responseBody = responseBody .. writeUInt32BE(20036) .. writeUInt32BE(20)  -- 技能3
    responseBody = responseBody .. writeUInt32BE(0) .. writeUInt32BE(0)       -- 技能4 (空)
    responseBody = responseBody .. writeUInt32BE(catchId)    -- catchTime
    responseBody = responseBody .. writeUInt32BE(301)        -- catchMap
    responseBody = responseBody .. writeUInt32BE(0)          -- catchRect
    responseBody = responseBody .. writeUInt32BE(5)          -- catchLevel
    responseBody = responseBody .. writeUInt16BE(0)          -- effectCount
    responseBody = responseBody .. writeUInt32BE(0)          -- peteffect
    responseBody = responseBody .. writeUInt32BE(0)          -- skinID
    responseBody = responseBody .. writeUInt32BE(0)          -- shiny
    responseBody = responseBody .. writeUInt32BE(0)          -- freeForbidden
    responseBody = responseBody .. writeUInt32BE(0)          -- boss
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2411: 挑战BOSS
function LocalGameServer:handleChallengeBoss(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2411: 挑战BOSS\27[0m")
    
    local bossId = 0
    if #body >= 4 then
        bossId = readUInt32BE(body, 1)
    end
    
    print(string.format("\27[36m[LocalGame] 用户 %d 挑战BOSS %d\27[0m", userId, bossId))
    
    local userData = self:getOrCreateUser(userId)
    
    -- 发送 NOTE_READY_TO_FIGHT (2503) 通知
    self:sendNoteReadyToFight(clientData, userId, bossId, userData)
end

-- 发送战斗准备通知
-- NoteReadyToFightInfo 结构 (基于 AS3 代码分析):
-- userCount (4字节) - 用户数量 (固定为2: 玩家和敌人)
-- 循环2次:
--   FighetUserInfo: userId(4) + nickName(16)
--   petCount (4字节) - 精灵数量
--   循环 petCount 次:
--     PetInfo (简化版, param2=false):
--       id(4) + level(4) + hp(4) + maxHp(4) + skillNum(4) + skills[4]*(id(4)+pp(4)) + catchTime(4) + catchMap(4) + catchRect(4) + catchLevel(4) + skinID(4) + shiny(4) + freeForbidden(4) + boss(4)
function LocalGameServer:sendNoteReadyToFight(clientData, userId, bossId, userData)
    print("\27[36m[LocalGame] 发送 CMD 2503: 战斗准备通知\27[0m")
    
    local petId = userData.currentPetId or 7
    local catchTime = userData.catchId or (0x69686700 + petId)
    
    -- 构建 NoteReadyToFightInfo
    local responseBody = ""
    
    -- 用户数量 (固定为2)
    responseBody = responseBody .. writeUInt32BE(2)
    
    -- === 玩家1 (自己) ===
    -- FighetUserInfo: userId(4) + nickName(16)
    responseBody = responseBody .. writeUInt32BE(userId)
    responseBody = responseBody .. writeFixedString(userData.nick or userData.nickname or userData.username or ("赛尔" .. userId), 16)
    
    -- petCount
    responseBody = responseBody .. writeUInt32BE(1)
    
    -- PetInfo (简化版 param2=false):
    -- id(4) + level(4) + hp(4) + maxHp(4) + skillNum(4) + skills[4]*(id(4)+pp(4)) + catchTime(4) + catchMap(4) + catchRect(4) + catchLevel(4) + skinID(4) + shiny(4) + freeForbidden(4) + boss(4)
    responseBody = responseBody .. writeUInt32BE(petId)      -- id
    responseBody = responseBody .. writeUInt32BE(16)         -- level
    responseBody = responseBody .. writeUInt32BE(100)        -- hp
    responseBody = responseBody .. writeUInt32BE(100)        -- maxHp
    responseBody = responseBody .. writeUInt32BE(4)          -- skillNum
    -- 4个技能槽 (id + pp)
    responseBody = responseBody .. writeUInt32BE(10022) .. writeUInt32BE(30)  -- 技能1
    responseBody = responseBody .. writeUInt32BE(10035) .. writeUInt32BE(25)  -- 技能2
    responseBody = responseBody .. writeUInt32BE(20036) .. writeUInt32BE(20)  -- 技能3
    responseBody = responseBody .. writeUInt32BE(0) .. writeUInt32BE(0)       -- 技能4 (空)
    responseBody = responseBody .. writeUInt32BE(catchTime)  -- catchTime
    responseBody = responseBody .. writeUInt32BE(301)        -- catchMap
    responseBody = responseBody .. writeUInt32BE(0)          -- catchRect
    responseBody = responseBody .. writeUInt32BE(5)          -- catchLevel
    responseBody = responseBody .. writeUInt32BE(0)          -- skinID
    responseBody = responseBody .. writeUInt32BE(0)          -- shiny
    responseBody = responseBody .. writeUInt32BE(0)          -- freeForbidden
    responseBody = responseBody .. writeUInt32BE(0)          -- boss
    
    -- === 玩家2 (敌人/BOSS) ===
    -- FighetUserInfo: userId(4) + nickName(16)
    responseBody = responseBody .. writeUInt32BE(0)          -- 敌人userId = 0
    responseBody = responseBody .. writeFixedString("", 16)  -- 敌人无昵称
    
    -- petCount
    responseBody = responseBody .. writeUInt32BE(1)
    
    -- PetInfo (简化版 param2=false) - BOSS精灵
    responseBody = responseBody .. writeUInt32BE(bossId)     -- id (BOSS精灵ID)
    responseBody = responseBody .. writeUInt32BE(5)          -- level
    responseBody = responseBody .. writeUInt32BE(50)         -- hp
    responseBody = responseBody .. writeUInt32BE(50)         -- maxHp
    responseBody = responseBody .. writeUInt32BE(2)          -- skillNum
    -- 4个技能槽 (id + pp)
    responseBody = responseBody .. writeUInt32BE(10001) .. writeUInt32BE(30)  -- 技能1
    responseBody = responseBody .. writeUInt32BE(10002) .. writeUInt32BE(25)  -- 技能2
    responseBody = responseBody .. writeUInt32BE(0) .. writeUInt32BE(0)       -- 技能3 (空)
    responseBody = responseBody .. writeUInt32BE(0) .. writeUInt32BE(0)       -- 技能4 (空)
    responseBody = responseBody .. writeUInt32BE(0)          -- catchTime (野生精灵无)
    responseBody = responseBody .. writeUInt32BE(301)        -- catchMap
    responseBody = responseBody .. writeUInt32BE(0)          -- catchRect
    responseBody = responseBody .. writeUInt32BE(5)          -- catchLevel
    responseBody = responseBody .. writeUInt32BE(0)          -- skinID
    responseBody = responseBody .. writeUInt32BE(0)          -- shiny
    responseBody = responseBody .. writeUInt32BE(0)          -- freeForbidden
    responseBody = responseBody .. writeUInt32BE(0)          -- boss
    
    self:sendResponse(clientData, 2503, userId, 0, responseBody)
end

-- CMD 2404: 准备战斗
function LocalGameServer:handleReadyToFight(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2404: 准备战斗\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    
    -- 发送 NOTE_START_FIGHT (2504) 通知
    self:sendNoteStartFight(clientData, userId, userData)
end

-- 发送战斗开始通知
-- FightStartInfo 结构 (基于 AS3 代码分析):
-- isCanAuto (4字节) - 是否可以自动战斗 (1=是, 0=否)
-- FightPetInfo x 2 (玩家精灵 + 敌方精灵)
--
-- FightPetInfo 结构:
-- userID (4字节)
-- petID (4字节)
-- petName (16字节)
-- catchTime (4字节)
-- hp (4字节)
-- maxHP (4字节)
-- lv (4字节)
-- catchable (4字节) - 是否可捕捉 (1=是, 0=否)
-- battleLv (6字节) - 战斗等级数组
function LocalGameServer:sendNoteStartFight(clientData, userId, userData)
    print("\27[36m[LocalGame] 发送 CMD 2504: 战斗开始通知\27[0m")
    
    local petId = userData.currentPetId or 7
    local catchTime = userData.catchId or (0x69686700 + petId)
    local bossId = userData.currentBossId or 58  -- 默认新手BOSS
    
    local responseBody = ""
    
    -- isCanAuto (4字节)
    responseBody = responseBody .. writeUInt32BE(0)  -- 不允许自动战斗
    
    -- === FightPetInfo 1 (玩家精灵) ===
    responseBody = responseBody .. writeUInt32BE(userId)                      -- userID
    responseBody = responseBody .. writeUInt32BE(petId)                       -- petID
    responseBody = responseBody .. writeFixedString("", 16)                   -- petName (16字节)
    responseBody = responseBody .. writeUInt32BE(catchTime)                   -- catchTime
    responseBody = responseBody .. writeUInt32BE(100)                         -- hp
    responseBody = responseBody .. writeUInt32BE(100)                         -- maxHP
    responseBody = responseBody .. writeUInt32BE(16)                          -- lv
    responseBody = responseBody .. writeUInt32BE(0)                           -- catchable (玩家精灵不可捕捉)
    responseBody = responseBody .. string.char(0, 0, 0, 0, 0, 0)              -- battleLv (6字节)
    
    -- === FightPetInfo 2 (敌方精灵/BOSS) ===
    responseBody = responseBody .. writeUInt32BE(0)                           -- userID (敌人=0)
    responseBody = responseBody .. writeUInt32BE(bossId)                      -- petID (BOSS精灵ID)
    responseBody = responseBody .. writeFixedString("", 16)                   -- petName (16字节)
    responseBody = responseBody .. writeUInt32BE(0)                           -- catchTime (野生精灵无)
    responseBody = responseBody .. writeUInt32BE(50)                          -- hp
    responseBody = responseBody .. writeUInt32BE(50)                          -- maxHP
    responseBody = responseBody .. writeUInt32BE(5)                           -- lv
    responseBody = responseBody .. writeUInt32BE(1)                           -- catchable (可捕捉)
    responseBody = responseBody .. string.char(0, 0, 0, 0, 0, 0)              -- battleLv (6字节)
    
    self:sendResponse(clientData, 2504, userId, 0, responseBody)
end

-- CMD 2605: 物品列表
function LocalGameServer:handleItemList(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2605: 物品列表\27[0m")
    
    -- 解析请求的物品类型
    local itemType1 = 0
    local itemType2 = 0
    local itemType3 = 0
    
    if #body >= 12 then
        itemType1 = readUInt32BE(body, 1)
        itemType2 = readUInt32BE(body, 5)
        itemType3 = readUInt32BE(body, 9)
    end
    
    print(string.format("\27[36m[LocalGame] 查询物品类型: %d, %d, %d\27[0m", itemType1, itemType2, itemType3))
    
    local userData = self:getOrCreateUser(userId)
    
    -- 返回物品列表 (基于官服响应)
    -- 结构: itemCount(4) + [ItemInfo...]
    -- ItemInfo: itemId(4) + count(4) + expireTime(4)
    
    local items = userData.items or {}
    local itemCount = 0
    local itemData = ""
    
    -- 添加一些默认物品
    if itemType1 == 0x018686A1 or itemType2 == 0x018686A1 then
        -- 服装类物品
        itemData = itemData ..
            writeUInt32BE(0x0186BB) ..  -- 物品ID (100027)
            writeUInt32BE(1) ..  -- 数量
            writeUInt32BE(0x057E40) ..  -- 过期时间
            writeUInt32BE(0) ..
            writeUInt32BE(0x0186BC) ..  -- 物品ID (100028)
            writeUInt32BE(1) ..
            writeUInt32BE(0x057E40) ..
            writeUInt32BE(0)
        itemCount = 2
    end
    
    if itemType1 == 0x0493E1 or itemType2 == 0x0493E1 then
        -- 精灵道具
        itemData = itemData ..
            writeUInt32BE(0x049468) ..  -- 物品ID (300136)
            writeUInt32BE(1) ..
            writeUInt32BE(0x057E40) ..
            writeUInt32BE(0) ..
            writeUInt32BE(0x077A1C) ..  -- 物品ID (489500)
            writeUInt32BE(10) ..
            writeUInt32BE(0x057E40) ..
            writeUInt32BE(0)
        itemCount = itemCount + 2
    end
    
    local responseBody = writeUInt32BE(itemCount) .. itemData
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 1106: 检查金币余额
function LocalGameServer:handleGoldOnlineCheckRemain(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 1106: 检查金币余额\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    
    -- 返回金币余额
    local responseBody = writeUInt32BE(userData.gold or 0)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- 处理技能使用 (增强版)
function LocalGameServer:handleUseSkillEnhanced(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2405: 使用技能 (增强版)\27[0m")
    
    local skillId = 0
    if #body >= 4 then
        skillId = readUInt32BE(body, 1)
    end
    
    print(string.format("\27[36m[LocalGame] 用户 %d 使用技能 %d\27[0m", userId, skillId))
    
    -- 先发送技能确认
    self:sendResponse(clientData, cmdId, userId, 0, "")
    
    -- 然后发送 NOTE_USE_SKILL (2505)
    self:sendNoteUseSkill(clientData, userId, skillId)
    
    -- 最后发送 FIGHT_OVER (2506) - 新手教程一击必杀
    self:sendFightOver(clientData, userId)
end

-- 发送技能使用通知
-- UseSkillInfo 结构 (基于 AS3 代码分析):
-- firstAttackInfo (AttackValue) - 先攻方攻击信息
-- secondAttackInfo (AttackValue) - 后攻方攻击信息
--
-- AttackValue 结构:
-- userID (4字节)
-- skillID (4字节)
-- atkTimes (4字节) - 攻击次数
-- lostHP (4字节) - 损失HP
-- gainHP (4字节, signed) - 获得HP
-- remainHp (4字节, signed) - 剩余HP
-- maxHp (4字节)
-- state (4字节) - 状态
-- skillListCount (4字节) - 技能列表数量
-- [PetSkillInfo]... - 技能列表 (id(4) + pp(4))
-- isCrit (4字节) - 是否暴击
-- status (20字节) - 状态数组
-- battleLv (6字节) - 战斗等级数组
function LocalGameServer:sendNoteUseSkill(clientData, userId, skillId)
    print("\27[36m[LocalGame] 发送 CMD 2505: 技能使用通知\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    local petId = userData.currentPetId or 7
    local bossId = userData.currentBossId or 58
    
    local responseBody = ""
    
    -- === firstAttackInfo (玩家攻击) ===
    responseBody = responseBody .. writeUInt32BE(userId)     -- userID
    responseBody = responseBody .. writeUInt32BE(skillId)    -- skillID
    responseBody = responseBody .. writeUInt32BE(1)          -- atkTimes
    responseBody = responseBody .. writeUInt32BE(0)          -- lostHP (玩家未受伤)
    responseBody = responseBody .. writeUInt32BE(0)          -- gainHP
    responseBody = responseBody .. writeUInt32BE(100)        -- remainHp
    responseBody = responseBody .. writeUInt32BE(100)        -- maxHp
    responseBody = responseBody .. writeUInt32BE(0)          -- state
    responseBody = responseBody .. writeUInt32BE(0)          -- skillListCount (无新技能)
    responseBody = responseBody .. writeUInt32BE(0)          -- isCrit (非暴击)
    responseBody = responseBody .. string.rep("\0", 20)      -- status (20字节)
    responseBody = responseBody .. string.rep("\0", 6)       -- battleLv (6字节)
    
    -- === secondAttackInfo (敌方/BOSS) ===
    responseBody = responseBody .. writeUInt32BE(0)          -- userID (敌人=0)
    responseBody = responseBody .. writeUInt32BE(0)          -- skillID (敌人未使用技能)
    responseBody = responseBody .. writeUInt32BE(0)          -- atkTimes
    responseBody = responseBody .. writeUInt32BE(50)         -- lostHP (敌人受到50伤害)
    responseBody = responseBody .. writeUInt32BE(0)          -- gainHP
    responseBody = responseBody .. writeUInt32BE(0)          -- remainHp (敌人被击败)
    responseBody = responseBody .. writeUInt32BE(50)         -- maxHp
    responseBody = responseBody .. writeUInt32BE(0)          -- state
    responseBody = responseBody .. writeUInt32BE(0)          -- skillListCount
    responseBody = responseBody .. writeUInt32BE(0)          -- isCrit
    responseBody = responseBody .. string.rep("\0", 20)      -- status (20字节)
    responseBody = responseBody .. string.rep("\0", 6)       -- battleLv (6字节)
    
    self:sendResponse(clientData, 2505, userId, 0, responseBody)
end

-- 发送战斗结束通知
-- FightOverInfo 结构 (基于 AS3 代码分析):
-- reason (4字节) - 结束原因
-- winnerID (4字节) - 胜利者ID
-- twoTimes (4字节) - 双倍经验次数
-- threeTimes (4字节) - 三倍经验次数
-- autoFightTimes (4字节) - 自动战斗次数
-- energyTimes (4字节) - 体力次数
-- learnTimes (4字节) - 学习次数
function LocalGameServer:sendFightOver(clientData, userId)
    print("\27[36m[LocalGame] 发送 CMD 2506: 战斗结束\27[0m")
    
    local responseBody = ""
    
    responseBody = responseBody .. writeUInt32BE(0)          -- reason (0=正常结束)
    responseBody = responseBody .. writeUInt32BE(userId)     -- winnerID (玩家胜利)
    responseBody = responseBody .. writeUInt32BE(0)          -- twoTimes
    responseBody = responseBody .. writeUInt32BE(0)          -- threeTimes
    responseBody = responseBody .. writeUInt32BE(0)          -- autoFightTimes
    responseBody = responseBody .. writeUInt32BE(0)          -- energyTimes
    responseBody = responseBody .. writeUInt32BE(0)          -- learnTimes
    
    self:sendResponse(clientData, 2506, userId, 0, responseBody)
end

-- ==================== 用户数据管理 ====================

function LocalGameServer:getOrCreateUser(userId)
    -- 首先尝试从 userdb 获取游戏数据
    if self.userdb then
        local db = self.userdb:new()
        
        -- 获取登录服务器保存的用户基础数据 (包含 color)
        local loginUser = db:findByUserId(userId)
        
        -- 获取游戏数据
        local gameData = db:getOrCreateGameData(userId)
        
        if gameData then
            -- 合并到本地缓存
            if not self.users[userId] then
                self.users[userId] = {}
            end
            
            -- 先合并游戏数据
            for k, v in pairs(gameData) do
                self.users[userId][k] = v
            end
            
            -- 再合并登录用户数据 (优先级更高，包含注册时选择的 color)
            if loginUser then
                if loginUser.color then
                    self.users[userId].color = loginUser.color
                end
                if loginUser.username then
                    self.users[userId].nick = loginUser.username
                    self.users[userId].nickname = loginUser.username
                end
                if loginUser.registerTime then
                    self.users[userId].regTime = loginUser.registerTime
                end
            end
            
            self.users[userId].id = userId
            return self.users[userId]
        end
    end
    
    -- 如果没有 userdb，使用本地缓存
    if not self.users[userId] then
        self.users[userId] = {
            id = userId,
            nick = "玩家" .. userId,
            nickname = "玩家" .. userId,
            level = 1,
            exp = 0,
            money = 10000,
            coins = 1000,           -- 官服默认 1000
            energy = 100,           -- 官服默认 100
            color = 1,              -- 官服默认 1
            texture = 1,            -- 官服默认 1
            mapID = 515,            -- 官服默认新手地图
            vipLevel = 0,
            vipStage = 1,           -- 官服默认 1
            vip = false,
            viped = false,
            petCount = 0,
            petAllNum = 0,
            pets = {},
            tasks = {},
            items = {},
            clothes = {},           -- 服装列表
            friends = {},           -- 好友列表
            blacklist = {},         -- 黑名单
            exchangeList = {},      -- 兑换记录 (新用户为空)
            -- NONO 默认数据 (新用户默认有 NONO)
            hasNono = 1,            -- flag=1 表示有 NONO
            nonoState = 0,
            nonoColor = 1,          -- 默认颜色 1
            nonoNick = "",
            superNono = 0,
            nono = {
                flag = 1,
                state = 0,
                nick = "",
                superNono = 0,
                color = 1,
                power = 50,         -- 默认 50%
                mate = 50,          -- 默认 50%
                iq = 100,           -- 默认 100
                ai = 0,
                birth = os.time(),
                chargeTime = 0,
                superEnergy = 0,
                superLevel = 0,
                superStage = 1,
            },
            teacherID = 0,
            studentID = 0,
            teamInfo = {},          -- 战队信息
            curTitle = 0,           -- 当前称号
        }
    end
    return self.users[userId]
end

function LocalGameServer:saveUserData(userId)
    local userData = self.users[userId]
    if userData then
        -- 保存到文件
        local filename = string.format("users/%d.json", userId)
        local data = json.stringify(userData)
        pcall(function()
            fs.writeFileSync(filename, data)
        end)
    end
end

-- ==================== 新增命令处理器 ====================

-- CMD 1004: 地图热度
-- MapHotInfo: count(4) + [mapId(4) + hotValue(4)]...
function LocalGameServer:handleMapHot(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 1004: 地图热度\27[0m")
    
    -- 返回空地图热度列表
    local responseBody = writeUInt32BE(0)  -- count = 0
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 1005: 获取图片地址
-- GetImgAddrInfo: 简单响应
function LocalGameServer:handleGetImageAddress(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 1005: 获取图片地址\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 1102: 金币购买商品
-- MoneyBuyProductInfo: unknown(4) + payMoney(4) + money(4)
function LocalGameServer:handleMoneyBuyProduct(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 1102: 金币购买商品\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    local money = (userData.money or 10000) * 100  -- 转换为分
    
    local responseBody = writeUInt32BE(0) ..       -- unknown
                        writeUInt32BE(0) ..        -- payMoney (花费0)
                        writeUInt32BE(money)       -- 剩余金币
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 1104: 钻石购买商品
-- GoldBuyProductInfo: unknown(4) + payGold(4) + gold(4)
function LocalGameServer:handleGoldBuyProduct(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 1104: 钻石购买商品\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    local gold = (userData.gold or 0) * 100  -- 转换为分
    
    local responseBody = writeUInt32BE(0) ..       -- unknown
                        writeUInt32BE(0) ..        -- payGold (花费0)
                        writeUInt32BE(gold)        -- 剩余钻石
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2004: 地图怪物列表
function LocalGameServer:handleMapOgreList(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2004: 地图怪物列表\27[0m")
    
    -- 返回空怪物列表
    local responseBody = writeUInt32BE(0)  -- count = 0
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2061: 修改昵称
-- ChangeUserNameInfo: 简单响应
function LocalGameServer:handleChangeNickName(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2061: 修改昵称\27[0m")
    
    -- 解析新昵称
    local newNick = ""
    if #body >= 16 then
        for i = 1, 16 do
            local b = body:byte(i)
            if b and b > 0 then
                newNick = newNick .. string.char(b)
            end
        end
    end
    
    local userData = self:getOrCreateUser(userId)
    userData.nickname = newNick
    
    print(string.format("\27[36m[LocalGame] 用户 %d 修改昵称为: %s\27[0m", userId, newNick))
    
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 2234: 获取每日任务缓存
-- TaskBufInfo: taskId(4) + flag(4) + buf(剩余字节)
function LocalGameServer:handleGetDailyTaskBuf(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2234: 获取每日任务缓存\27[0m")
    
    local responseBody = writeUInt32BE(0) ..  -- taskId
                        writeUInt32BE(0)      -- flag
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2305: 展示精灵
-- PetShowInfo: userID(4) + catchTime(4) + petID(4) + flag(4) + dv(4) + shiny(4) + skinID(4) + ride(4) + padding(8)
function LocalGameServer:handlePetShow(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2305: 展示精灵\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    local petId = userData.currentPetId or 7
    local catchTime = userData.catchId or (0x69686700 + petId)
    
    local responseBody = writeUInt32BE(userId) ..     -- userID
                        writeUInt32BE(catchTime) ..   -- catchTime
                        writeUInt32BE(petId) ..       -- petID
                        writeUInt32BE(1) ..           -- flag
                        writeUInt32BE(31) ..          -- dv
                        writeUInt32BE(0) ..           -- shiny
                        writeUInt32BE(0) ..           -- skinID
                        writeUInt32BE(0) ..           -- ride
                        writeUInt32BE(0) ..           -- padding1
                        writeUInt32BE(0)              -- padding2
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2306: 治疗精灵
function LocalGameServer:handlePetCure(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2306: 治疗精灵\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 2309: 精灵图鉴列表
-- PetBargeListInfo: monCount(4) + [monID(4) + enCntCnt(4) + isCatched(4) + isKilled(4)]...
function LocalGameServer:handlePetBargeList(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2309: 精灵图鉴列表\27[0m")
    
    -- 返回空图鉴列表
    local responseBody = writeUInt32BE(0)  -- monCount = 0
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2406: 使用精灵道具
-- UsePetItemInfo: userID(4) + itemID(4) + userHP(4) + changeHp(4, signed)
function LocalGameServer:handleUsePetItem(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2406: 使用精灵道具\27[0m")
    
    local itemId = 0
    if #body >= 4 then
        itemId = readUInt32BE(body, 1)
    end
    
    print(string.format("\27[36m[LocalGame] 用户 %d 使用道具 %d\27[0m", userId, itemId))
    
    local responseBody = writeUInt32BE(userId) ..  -- userID
                        writeUInt32BE(itemId) ..   -- itemID
                        writeUInt32BE(100) ..      -- userHP (当前HP)
                        writeUInt32BE(50)          -- changeHp (恢复50HP)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2407: 更换精灵
-- ChangePetInfo: userID(4) + petID(4) + petName(16) + level(4) + hp(4) + maxHp(4) + catchTime(4)
function LocalGameServer:handleChangePet(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2407: 更换精灵\27[0m")
    
    local catchTime = 0
    if #body >= 4 then
        catchTime = readUInt32BE(body, 1)
    end
    
    local userData = self:getOrCreateUser(userId)
    local petId = userData.currentPetId or 7
    
    local responseBody = writeUInt32BE(userId) ..           -- userID
                        writeUInt32BE(petId) ..             -- petID
                        writeFixedString("", 16) ..         -- petName (16字节)
                        writeUInt32BE(16) ..                -- level
                        writeUInt32BE(100) ..               -- hp
                        writeUInt32BE(100) ..               -- maxHp
                        writeUInt32BE(catchTime)            -- catchTime
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2409: 捕捉精灵
-- CatchPetInfo: catchTime(4) + petID(4)
function LocalGameServer:handleCatchMonster(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2409: 捕捉精灵\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    local bossId = userData.currentBossId or 58
    local catchTime = os.time()
    
    local responseBody = writeUInt32BE(catchTime) ..  -- catchTime
                        writeUInt32BE(bossId)         -- petID
    
    print(string.format("\27[32m[LocalGame] 用户 %d 捕捉精灵 %d 成功\27[0m", userId, bossId))
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2601: 购买物品
-- BuyItemInfo: 简单响应
function LocalGameServer:handleItemBuy(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2601: 购买物品\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 2604: 更换服装
-- ChangeClothInfo: userID(4) + clothCount(4) + [clothId(4) + clothType(4)]...
function LocalGameServer:handleChangeCloth(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2604: 更换服装\27[0m")
    
    local responseBody = writeUInt32BE(userId) ..  -- userID
                        writeUInt32BE(0)           -- clothCount = 0
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2751: 获取邮件列表
-- MailListInfo: total(4) + count(4) + [SingleMailInfo]...
-- SingleMailInfo: id(4) + template(4) + time(4) + fromID(4) + fromNick(16) + flag(4)
function LocalGameServer:handleMailGetList(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2751: 获取邮件列表\27[0m")
    
    local responseBody = writeUInt32BE(0) ..  -- total
                        writeUInt32BE(0)      -- count = 0
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 8001: 通知
-- InformInfo: type(4) + userID(4) + nick(16) + accept(4) + serverID(4) + mapType(4) + mapID(4) + mapName(64)
function LocalGameServer:handleInform(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 8001: 通知\27[0m")
    
    local responseBody = writeUInt32BE(0) ..           -- type
                        writeUInt32BE(userId) ..       -- userID
                        writeFixedString("", 16) ..    -- nick
                        writeUInt32BE(0) ..            -- accept
                        writeUInt32BE(1) ..            -- serverID
                        writeUInt32BE(0) ..            -- mapType
                        writeUInt32BE(301) ..          -- mapID
                        writeFixedString("", 64)       -- mapName
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 8004: 获取BOSS怪物
-- BossMonsterInfo: 简单响应
function LocalGameServer:handleGetBossMonster(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 8004: 获取BOSS怪物\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 2150: 获取好友/黑名单列表
-- 响应结构: friendCount(4) + [userID(4) + timePoke(4)]... + blackCount(4) + [userID(4)]...
-- 官服新用户: friendCount=0, blackCount=0, body = 8 bytes
-- 官服有好友用户: 根据好友数量返回
function LocalGameServer:handleGetRelationList(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 2150: 获取好友/黑名单列表\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    local friends = userData.friends or {}
    local blacklist = userData.blacklist or {}
    
    local responseBody = ""
    
    -- 好友列表
    responseBody = responseBody .. writeUInt32BE(#friends)
    for _, friend in ipairs(friends) do
        responseBody = responseBody .. writeUInt32BE(friend.userID or friend.id or 0)
        responseBody = responseBody .. writeUInt32BE(friend.timePoke or 0)
    end
    
    -- 黑名单
    responseBody = responseBody .. writeUInt32BE(#blacklist)
    for _, black in ipairs(blacklist) do
        responseBody = responseBody .. writeUInt32BE(black.userID or black.id or black)
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 70001: 获取兑换信息 (GET_EXCHANGE_INFO)
-- 用于荣誉兑换手册，记录玩家已兑换的物品数量
-- 响应结构: count(4) + [exchangeID(4) + exchangeNum(4)]...
-- 官服新用户: count=0, body = 4 bytes
-- 官服有记录用户: 根据兑换记录数量返回
function LocalGameServer:handleCmd70001(clientData, cmdId, userId, seqId, body)
    print("\27[36m[LocalGame] 处理 CMD 70001: 获取兑换信息 (荣誉兑换手册)\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    local exchangeList = userData.exchangeList or {}
    
    local responseBody = writeUInt32BE(#exchangeList)
    
    for _, exchange in ipairs(exchangeList) do
        responseBody = responseBody .. writeUInt32BE(exchange.exchangeID or exchange.id or 0)
        responseBody = responseBody .. writeUInt32BE(exchange.exchangeNum or exchange.num or 0)
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 80008: 心跳包 (NIEO_HEART)
-- 服务器定期发送，客户端收到后回复相同命令
-- 用于保持连接活跃
function LocalGameServer:handleNieoHeart(clientData, cmdId, userId, seqId, body)
    -- 心跳包只需要返回空响应
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

return {LocalGameServer = LocalGameServer}
