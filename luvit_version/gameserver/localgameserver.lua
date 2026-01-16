-- 本地游戏服务器 - 完整实现
-- 基于官服协议分析实现

local net = require('net')
local bit = require('../bitop_compat')
local json = require('json')
local fs = require('fs')

-- 从 Logger 模块获取 tprint
local Logger = require('../logger')
local tprint = Logger.tprint

local LocalGameServer = {}
LocalGameServer.__index = LocalGameServer

-- 加载命令映射
local SeerCommands = require('../seer_commands')

-- 加载精灵数据
local SeerMonsters = require('../seer_monsters')

-- 加载技能数据
local SeerSkills = require('../seer_skills')

-- 加载战斗系统
local SeerBattle = require('../seer_battle')

-- 加载在线追踪模块
local OnlineTracker = require('../handlers/online_tracker')

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
    tprint("\27[36m[LocalGame] 用户数据库已加载\27[0m")
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
    tprint(string.format("\27[36m[LocalGame] 初始化 %d 个服务器\27[0m", #self.serverList))
end

function LocalGameServer:start()
    local timer = require('timer')
    
    local server = net.createServer(function(client)
        local addr = client:address()
        tprint(string.format("\27[32m[LocalGame] 新连接: %s:%d\27[0m", 
            addr and addr.address or "unknown", addr and addr.port or 0))
        
        local clientData = {
            socket = client,
            buffer = "",
            userId = nil,
            session = nil,
            seqId = 0,
            heartbeatTimer = nil,  -- 心跳定时器
            loggedIn = false       -- 是否已登录
        }
        table.insert(self.clients, clientData)
        
        client:on('data', function(data)
            self:handleData(clientData, data)
        end)
        
        client:on('end', function()
            tprint("\27[33m[LocalGame] 客户端断开连接\27[0m")
            self:removeClient(clientData)
        end)
        
        client:on('error', function(err)
            tprint("\27[31m[LocalGame] 客户端错误: " .. tostring(err) .. "\27[0m")
            self:removeClient(clientData)
        end)
    end)
    
    server:listen(self.port, '0.0.0.0', function()
        tprint(string.format("\27[32m[LocalGame] ✓ 本地游戏服务器启动在端口 %d\27[0m", self.port))
    end)
    
    server:on('error', function(err)
        tprint("\27[31m[LocalGame] 服务器错误: " .. tostring(err) .. "\27[0m")
    end)
end

function LocalGameServer:removeClient(clientData)
    -- 清理心跳定时器
    if clientData.heartbeatTimer then
        local timer = require('timer')
        timer.clearInterval(clientData.heartbeatTimer)
        clientData.heartbeatTimer = nil
    end
    
    -- 从在线追踪系统移除玩家
    if clientData.userId then
        OnlineTracker.playerLogout(clientData.userId)
    end
    
    -- 设置用户离线状态 (用于好友系统)
    if clientData.userId and self.userdb then
        local db = self.userdb:new()
        db:setUserOffline(clientData.userId)
        tprint(string.format("\27[36m[LocalGame] 用户 %d 已离线\27[0m", clientData.userId))
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
    
    -- 检查是否应该隐藏该命令的日志
    local shouldHide = false
    if conf.hide_frequent_cmds and conf.hide_cmd_list then
        for _, hideCmdId in ipairs(conf.hide_cmd_list) do
            if cmdId == hideCmdId then
                shouldHide = true
                break
            end
        end
    end
    
    if not shouldHide then
        tprint(string.format("\27[36m[LocalGame] 收到 CMD=%d (%s) UID=%d SEQ=%d LEN=%d\27[0m", 
            cmdId, getCmdName(cmdId), userId, seqId, length))
    end
    
    -- 处理命令
    self:handleCommand(clientData, cmdId, userId, seqId, body)
end

-- 检查是否应该隐藏该命令
local function shouldHideCmd(cmdId)
    if not conf.hide_frequent_cmds then return false end
    if not conf.hide_cmd_list then return false end
    for _, hideCmdId in ipairs(conf.hide_cmd_list) do
        if cmdId == hideCmdId then return true end
    end
    return false
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
        [2151] = self.handleFriendAdd,         -- 添加好友请求
        [2152] = self.handleFriendAnswer,      -- 回应好友请求
        [2153] = self.handleFriendRemove,      -- 删除好友
        [2154] = self.handleBlackAdd,          -- 添加黑名单
        [2155] = self.handleBlackRemove,       -- 移除黑名单
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
        -- 家园系统
        [10001] = self.handleRoomLogin,        -- 家园登录
        [10002] = self.handleGetRoomAddress,   -- 获取房间地址
        [10003] = self.handleLeaveRoom,        -- 离开房间
        [10006] = self.handleFitmentUsering,   -- 正在使用的家具
        [10007] = self.handleFitmentAll,       -- 所有家具
        [10008] = self.handleSetFitment,       -- 设置家具
        [50004] = self.handleCmd50004,         -- 客户端信息上报
        [50008] = self.handleCmd50008,         -- 获取四倍经验时间
        [70001] = self.handleCmd70001,         -- 未知命令70001
        [80008] = self.handleNieoHeart,        -- 心跳包
    }
    
    local handler = handlers[cmdId]
    if handler then
        handler(self, clientData, cmdId, userId, seqId, body)
    else
        tprint(string.format("\27[33m[LocalGame] 未实现的命令: %d (%s)\27[0m", cmdId, getCmdName(cmdId)))
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
    
    if not shouldHideCmd(cmdId) then
        tprint(string.format("\27[32m[LocalGame] 发送 CMD=%d (%s) RESULT=%d LEN=%d\27[0m", 
            cmdId, getCmdName(cmdId), result, length))
    end
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
    tprint("\27[36m[LocalGame] 处理 CMD 105: 获取服务器列表\27[0m")
    
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
    tprint("\27[36m[LocalGame] 处理 CMD 106: 获取指定范围服务器\27[0m")
    
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
    tprint("\27[36m[LocalGame] 处理 CMD 1001: 登录游戏服务器\27[0m")
    
    -- 从 body 中提取 session (如果有)
    local session = ""
    if #body >= 16 then
        session = body:sub(1, 16)
    end
    
    -- 查找或创建用户数据
    local userData = self:getOrCreateUser(userId)
    clientData.session = session
    
    local nickname = userData.nick or userData.nickname or userData.username or tostring(userId)
    local nonoData = userData.nono or {}
    local teamInfo = userData.teamInfo or {}
    local teamPKInfo = userData.teamPKInfo or {}
    local pets = userData.pets or {}
    local clothes = userData.clothes or {}
    
    -- 构建响应 (按 UserInfo.setForLoginInfo 解析顺序)
    local responseBody = ""
    
    -- 1. 基本信息
    responseBody = responseBody .. writeUInt32BE(userId)                              -- userID
    -- 使用2009年的时间戳，让 checkIsNovice() 返回 false，跳过新手任务检查
    -- 2009-01-01 00:00:00 UTC = 1230768000
    responseBody = responseBody .. writeUInt32BE(1230768000)                          -- regTime (固定为2009年)
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
    
    -- 登录时默认地图: 如果新手任务完成则进地图1，否则进515
    -- 检查任务88是否完成来判断新手任务是否完成
    local defaultMapId = 1  -- 默认进地图1（克洛斯星）
    if self.userdb then
        local db = self.userdb:new()
        local gameData = db:getOrCreateGameData(userId)
        if gameData.tasks and gameData.tasks["88"] and gameData.tasks["88"].status == "completed" then
            defaultMapId = gameData.mapId or 1  -- 新手任务完成，进保存的地图或地图1
        else
            defaultMapId = 515  -- 新手任务未完成，进新手地图
        end
    end
    responseBody = responseBody .. writeUInt32BE(defaultMapId)                        -- mapID
    responseBody = responseBody .. writeUInt32BE(300)                                 -- posX
    responseBody = responseBody .. writeUInt32BE(200)                                 -- posY
    responseBody = responseBody .. writeUInt32BE(userData.timeToday or 0)             -- timeToday
    responseBody = responseBody .. writeUInt32BE(userData.timeLimit or 86400)         -- timeLimit (24小时=86400秒)
    
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
    -- 每个字节代表一个任务的状态: 0=未接受, 1=已接受, 3=已完成
    -- 任务ID从1开始，所以任务N的状态在taskList[N-1]
    local taskListBytes = {}
    for i = 1, 500 do
        taskListBytes[i] = 0  -- 默认未接受
    end
    
    -- 从数据库读取任务状态
    if self.userdb then
        local db = self.userdb:new()
        local gameData = db:getOrCreateGameData(userId)
        if gameData.tasks then
            local taskCount = 0
            for taskIdStr, task in pairs(gameData.tasks) do
                local taskId = tonumber(taskIdStr)
                if taskId and taskId >= 1 and taskId <= 500 then
                    if task.status == "completed" then
                        taskListBytes[taskId] = 3  -- COMPLETE
                        taskCount = taskCount + 1
                    elseif task.status == "accepted" then
                        taskListBytes[taskId] = 1  -- ALR_ACCEPT
                        taskCount = taskCount + 1
                    end
                end
            end
            -- 调试: 打印关键任务状态
            tprint(string.format("\27[35m[LocalGame] 登录任务状态: 任务85=%d, 任务86=%d, 任务87=%d, 任务88=%d (共%d个任务)\27[0m",
                taskListBytes[85], taskListBytes[86], taskListBytes[87], taskListBytes[88], taskCount))
        else
            tprint("\27[33m[LocalGame] 警告: 用户没有任务数据\27[0m")
        end
    end
    
    -- 写入taskList
    for i = 1, 500 do
        responseBody = responseBody .. string.char(taskListBytes[i])
    end
    
    -- 调试: 打印任务列表的前100个字节的HEX
    local taskHex = ""
    for i = 1, 100 do
        taskHex = taskHex .. string.format("%02X ", taskListBytes[i])
    end
    tprint(string.format("\27[35m[LocalGame] taskList[1-100]: %s\27[0m", taskHex))
    
    -- 17. petNum + PetInfo[]
    responseBody = responseBody .. writeUInt32BE(#pets)                               -- petNum
    
    -- 写入每个精灵的 PetInfo 数据
    for _, pet in ipairs(pets) do
        local petId = pet.id or 7
        local petLevel = pet.level or 1
        local petDv = pet.dv or 31
        local petNature = pet.nature or 1
        local petExp = pet.exp or 0
        local catchTime = pet.catchTime or os.time()
        
        -- 计算精灵属性
        local stats = SeerMonsters.calculateStats(petId, petLevel, petDv) or {
            hp = 20, maxHp = 20, attack = 12, defence = 12, spAtk = 11, spDef = 10, speed = 12
        }
        
        -- 获取经验信息
        local expInfo = SeerMonsters.getExpInfo(petId, petLevel, petExp)
        
        -- 获取精灵技能
        local skills = SeerMonsters.getSkillsForLevel(petId, petLevel) or {}
        
        -- PetInfo 结构
        responseBody = responseBody .. writeUInt32BE(petId)                           -- id
        responseBody = responseBody .. writeFixedString(pet.name or "", 16)           -- name (16字节)
        responseBody = responseBody .. writeUInt32BE(petDv)                           -- dv
        responseBody = responseBody .. writeUInt32BE(petNature)                       -- nature
        responseBody = responseBody .. writeUInt32BE(petLevel)                        -- level
        responseBody = responseBody .. writeUInt32BE(petExp)                          -- exp
        responseBody = responseBody .. writeUInt32BE(expInfo.lvExp or 0)              -- lvExp
        responseBody = responseBody .. writeUInt32BE(expInfo.nextLvExp or 100)        -- nextLvExp
        responseBody = responseBody .. writeUInt32BE(stats.hp or stats.maxHp)         -- hp
        responseBody = responseBody .. writeUInt32BE(stats.maxHp)                     -- maxHp
        responseBody = responseBody .. writeUInt32BE(stats.attack)                    -- attack
        responseBody = responseBody .. writeUInt32BE(stats.defence)                   -- defence
        responseBody = responseBody .. writeUInt32BE(stats.spAtk)                     -- s_a
        responseBody = responseBody .. writeUInt32BE(stats.spDef)                     -- s_d
        responseBody = responseBody .. writeUInt32BE(stats.speed)                     -- speed
        responseBody = responseBody .. writeUInt32BE(pet.ev_hp or 0)                  -- ev_hp
        responseBody = responseBody .. writeUInt32BE(pet.ev_attack or 0)              -- ev_attack
        responseBody = responseBody .. writeUInt32BE(pet.ev_defence or 0)             -- ev_defence
        responseBody = responseBody .. writeUInt32BE(pet.ev_sa or 0)                  -- ev_sa
        responseBody = responseBody .. writeUInt32BE(pet.ev_sd or 0)                  -- ev_sd
        responseBody = responseBody .. writeUInt32BE(pet.ev_sp or 0)                  -- ev_sp
        
        -- 技能数量和技能列表 (固定4个槽位)
        local skillCount = math.min(#skills, 4)
        responseBody = responseBody .. writeUInt32BE(skillCount)                      -- skillNum
        
        for i = 1, 4 do
            local skillId = skills[#skills - 4 + i]  -- 取最后学会的4个技能
            if skillId and skillId > 0 then
                responseBody = responseBody .. writeUInt32BE(skillId)                 -- skill id
                responseBody = responseBody .. writeUInt32BE(30)                      -- skill pp (默认30)
            else
                responseBody = responseBody .. writeUInt32BE(0)                       -- skill id = 0
                responseBody = responseBody .. writeUInt32BE(0)                       -- skill pp = 0
            end
        end
        
        responseBody = responseBody .. writeUInt32BE(catchTime)                       -- catchTime
        responseBody = responseBody .. writeUInt32BE(pet.catchMap or 515)             -- catchMap
        responseBody = responseBody .. writeUInt32BE(pet.catchRect or 0)              -- catchRect
        responseBody = responseBody .. writeUInt32BE(pet.catchLevel or petLevel)      -- catchLevel
        responseBody = responseBody .. writeUInt16BE(0)                               -- effectCount
        responseBody = responseBody .. writeUInt32BE(pet.skinID or 0)                 -- skinID
    end
    
    -- 18. clothCount + clothes[]
    responseBody = responseBody .. writeUInt32BE(#clothes)                            -- clothCount
    
    -- 写入每个服装的数据
    for _, cloth in ipairs(clothes) do
        responseBody = responseBody .. writeUInt32BE(cloth.id or cloth[1] or 0)       -- cloth id
        responseBody = responseBody .. writeUInt32BE(cloth.level or cloth[2] or 0)    -- cloth level
    end
    
    -- 19. curTitle
    responseBody = responseBody .. writeUInt32BE(userData.curTitle or 0)              -- curTitle
    
    -- 20. bossAchievement (200 bytes)
    responseBody = responseBody .. string.rep("\0", 200)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
    
    tprint(string.format("\27[32m[LocalGame] ✓ 用户 %d 登录成功，响应大小: %d bytes\27[0m", userId, 17 + #responseBody))
    
    -- 记录用户当前所在服务器 (用于好友系统)
    if self.userdb then
        local db = self.userdb:new()
        local serverId = conf.server_id or 1  -- 当前服务器ID
        db:setUserServer(userId, serverId)
        tprint(string.format("\27[36m[LocalGame] 用户 %d 登录到服务器 %d\27[0m", userId, serverId))
    end
    
    -- 登录成功后启动心跳定时器 (官服每6秒发送一次心跳)
    clientData.loggedIn = true
    self:startHeartbeat(clientData, userId)
    
    -- 注册玩家到在线追踪系统
    OnlineTracker.playerLogin(userId, clientData)
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
    tprint("\27[36m[LocalGame] 处理 CMD 2001: 进入地图\27[0m")
    
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
    local nickname = userData.nick or userData.nickname or userData.username or tostring(userId)
    local clothes = userData.clothes or {}
    local teamInfo = userData.teamInfo or {}
    
    -- 更新玩家位置到用户数据
    userData.x = posX
    userData.y = posY
    userData.mapId = mapId
    userData.mapType = mapType
    
    -- 更新在线追踪
    OnlineTracker.updatePlayerMap(userId, mapId, mapType)
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 进入地图 %d (type=%d) pos=(%d,%d)\27[0m", 
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
    tprint("\27[36m[LocalGame] 处理 CMD 2002: 离开地图\27[0m")
    -- 官服响应包含 userId
    local responseBody = writeUInt32BE(userId)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2051: 获取简单用户信息
function LocalGameServer:handleGetSimUserInfo(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2051: 获取简单用户信息\27[0m")
    
    local targetUserId = userId
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    local userData = self:getOrCreateUser(targetUserId)
    
    local responseBody = writeUInt32BE(targetUserId) ..
        writeFixedString(userData.nick or userData.nickname or userData.username or tostring(targetUserId), 20) ..
        writeUInt32BE(userData.level or 1)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2052: 获取详细用户信息
function LocalGameServer:handleGetMoreUserInfo(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2052: 获取详细用户信息\27[0m")
    
    local targetUserId = userId
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    local userData = self:getOrCreateUser(targetUserId)
    
    local responseBody = writeUInt32BE(targetUserId) ..
        writeFixedString(userData.nick or userData.nickname or userData.username or tostring(targetUserId), 20) ..
        writeUInt32BE(userData.level or 1) ..
        writeUInt32BE(userData.exp or 0) ..
        writeUInt32BE(userData.money or 10000) ..
        writeUInt32BE(userData.vipLevel or 0) ..
        writeUInt32BE(userData.petCount or 0)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2101: 人物移动
-- 请求格式: walkType(4) + x(4) + y(4) + amfLen(4) + amfData...
-- 响应格式: walkType(4) + userId(4) + x(4) + y(4) + amfLen(4) + amfData...
function LocalGameServer:handlePeopleWalk(clientData, cmdId, userId, seqId, body)
    local walkType = 0
    local x = 0
    local y = 0
    local amfLen = 0
    local amfData = ""
    
    if #body >= 4 then
        walkType = readUInt32BE(body, 1)
    end
    if #body >= 8 then
        x = readUInt32BE(body, 5)
    end
    if #body >= 12 then
        y = readUInt32BE(body, 9)
    end
    if #body >= 16 then
        amfLen = readUInt32BE(body, 13)
        if #body >= 16 + amfLen then
            amfData = body:sub(17, 16 + amfLen)
        end
    end
    
    -- 更新用户位置
    local userData = self:getOrCreateUser(userId)
    userData.x = x
    userData.y = y
    
    -- 更新活跃时间
    OnlineTracker.updateActivity(userId)
    
    -- 构建响应 (包含完整的 AMF 数据)
    local responseBody = writeUInt32BE(walkType) ..
                writeUInt32BE(userId) ..
                writeUInt32BE(x) ..
                writeUInt32BE(y) ..
                writeUInt32BE(amfLen) ..
                amfData
    
    -- 获取当前地图并广播给同地图所有玩家
    local currentMapId = OnlineTracker.getPlayerMap(userId)
    if currentMapId > 0 then
        local packet = self:buildPacket(cmdId, userId, 0, responseBody)
        -- 广播给同地图所有玩家 (包括自己)
        local playersInMap = OnlineTracker.getPlayersInMap(currentMapId)
        for _, playerId in ipairs(playersInMap) do
            OnlineTracker.sendToPlayer(playerId, packet)
        end
    else
        -- 如果没有地图信息，只回复给自己
        self:sendResponse(clientData, cmdId, userId, 0, responseBody)
    end
end

-- CMD 2102: 聊天
-- ChatInfo 结构: senderID(4) + senderNickName(16) + toID(4) + msgLen(4) + msg(msgLen)
function LocalGameServer:handleChat(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2102: 聊天\27[0m")
    
    -- 解析聊天内容
    local chatType = 0
    local message = ""
    if #body >= 4 then
        chatType = readUInt32BE(body, 1)
        if #body > 4 then
            message = body:sub(5)
        end
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 聊天: %s\27[0m", userId, message))
    
    local userData = self:getOrCreateUser(userId)
    local nickname = userData.nick or userData.nickname or userData.username or tostring(userId)
    
    -- 构建 ChatInfo 响应
    local responseBody = ""
    responseBody = responseBody .. writeUInt32BE(userId)                     -- senderID
    responseBody = responseBody .. writeFixedString(nickname, 16)            -- senderNickName (16字节)
    responseBody = responseBody .. writeUInt32BE(0)                          -- toID (0=公共聊天)
    responseBody = responseBody .. writeUInt32BE(#message)                   -- msgLen
    responseBody = responseBody .. message                                   -- msg
    
    -- 广播给同地图所有玩家
    local currentMapId = OnlineTracker.getPlayerMap(userId)
    if currentMapId > 0 then
        local packet = self:buildPacket(cmdId, userId, 0, responseBody)
        local playersInMap = OnlineTracker.getPlayersInMap(currentMapId)
        for _, playerId in ipairs(playersInMap) do
            OnlineTracker.sendToPlayer(playerId, packet)
        end
    else
        self:sendResponse(clientData, cmdId, userId, 0, responseBody)
    end
end

-- CMD 2201: 接受任务
function LocalGameServer:handleAcceptTask(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2201: 接受任务\27[0m")
    
    local taskId = 0
    if #body >= 4 then
        taskId = readUInt32BE(body, 1)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 接受任务 %d\27[0m", userId, taskId))
    
    -- 保存任务状态到数据库
    if self.userdb then
        local db = self.userdb:new()
        local gameData = db:getOrCreateGameData(userId)
        gameData.tasks = gameData.tasks or {}
        gameData.tasks[tostring(taskId)] = {
            status = "accepted",
            acceptTime = os.time()
        }
        db:saveGameData(userId, gameData)
        tprint(string.format("\27[32m[LocalGame] 任务 %d 状态已保存: accepted\27[0m", taskId))
    end
    
    local responseBody = writeUInt32BE(taskId)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2202: 完成任务
function LocalGameServer:handleCompleteTask(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2202: 完成任务\27[0m")
    
    local taskId = 0
    local param = 0
    if #body >= 4 then
        taskId = readUInt32BE(body, 1)
    end
    if #body >= 8 then
        param = readUInt32BE(body, 5)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 完成任务 %d (param=%d)\27[0m", userId, taskId, param))
    
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
        -- 官服给8个物品:
        -- 100027, 100028 (服装)
        -- 500001 (1个)
        -- 300650 (3个)
        -- 300025 (3个)
        -- 300035 (3个)
        -- 500502, 500503 (各1个)
        
        -- 保存物品到数据库
        if self.userdb then
            local db = self.userdb:new()
            db:addItem(userId, 100027, 1)   -- 0x0186BB 服装
            db:addItem(userId, 100028, 1)   -- 0x0186BC 服装
            db:addItem(userId, 500001, 1)   -- 0x07A121
            db:addItem(userId, 300650, 3)   -- 0x04966A
            db:addItem(userId, 300025, 3)   -- 0x0493F9
            db:addItem(userId, 300035, 3)   -- 0x049403
            db:addItem(userId, 500502, 1)   -- 0x07A316
            db:addItem(userId, 500503, 1)   -- 0x07A317
            tprint(string.format("\27[32m[LocalGame] 任务85: 已保存8个物品到数据库\27[0m"))
        end
        
        responseBody = writeUInt32BE(taskId) ..
            writeUInt32BE(0) ..  -- petID: 无精灵奖励
            writeUInt32BE(0) ..  -- captureTm: 无
            writeUInt32BE(8) ..  -- itemCount: 8个物品
            writeUInt32BE(100027) .. writeUInt32BE(1) ..  -- 服装
            writeUInt32BE(100028) .. writeUInt32BE(1) ..  -- 服装
            writeUInt32BE(500001) .. writeUInt32BE(1) ..
            writeUInt32BE(300650) .. writeUInt32BE(3) ..
            writeUInt32BE(300025) .. writeUInt32BE(3) ..
            writeUInt32BE(300035) .. writeUInt32BE(3) ..
            writeUInt32BE(500502) .. writeUInt32BE(1) ..
            writeUInt32BE(500503) .. writeUInt32BE(1)
            
    elseif taskId == 86 then  -- 0x56 - 新手任务2 (选择精灵)
        -- 官服响应: 00 00 00 56 00 00 00 04 69 69 C4 5E 00 00 00 00
        -- 选择映射 (基于客户端 DoctorGuideDialog.as):
        -- grassMC (草系) → choice=1 → petId=1 (布布种子)
        -- fireMC (火系) → choice=2 → petId=7 (小火猴)
        -- waterMC (水系) → choice=3 → petId=4 (伊优)
        local petMapping = {
            [1] = 1,   -- 布布种子
            [2] = 7,   -- 小火猴
            [3] = 4,   -- 伊优
        }
        petId = petMapping[param] or param
        
        -- 官服的 captureTm 格式: 0x6969XXXX (时间戳相关)
        -- 使用当前时间戳生成唯一的 catchTime
        captureTm = 0x6969C400 + os.time() % 0x10000
        
        userData.currentPetId = petId
        userData.catchId = captureTm
        
        -- 保存精灵到数据库 (会在 PET_RELEASE 时正式添加到背包)
        -- 这里只记录选择，实际添加在 handlePetRelease 中
        
        tprint(string.format("\27[32m[LocalGame] 任务86完成: 设置 currentPetId=%d, catchId=0x%08X\27[0m", petId, captureTm))
        
        responseBody = writeUInt32BE(taskId) ..
            writeUInt32BE(petId) ..      -- petID: 获得的精灵
            writeUInt32BE(captureTm) ..  -- captureTm: 精灵的catchId
            writeUInt32BE(0)             -- itemCount: 无物品奖励
            
    elseif taskId == 87 then  -- 0x57 - 新手任务3 (战斗胜利)
        -- 官服响应: 00 00 00 57 00 00 00 00 00 00 00 00 00 00 00 02 
        --           00 04 93 E1 00 00 00 05  (300001, 5)
        --           00 04 93 EB 00 00 00 03  (300011, 3)
        
        -- 保存物品到数据库
        if self.userdb then
            local db = self.userdb:new()
            db:addItem(userId, 0x0493E1, 5)  -- 300001 精灵胶囊
            db:addItem(userId, 0x0493EB, 3)  -- 300011 体力药剂
            tprint(string.format("\27[32m[LocalGame] 任务87: 已保存2个物品到数据库\27[0m"))
        end
        
        responseBody = writeUInt32BE(taskId) ..
            writeUInt32BE(0) ..
            writeUInt32BE(0) ..
            writeUInt32BE(2) ..  -- itemCount: 2个物品
            writeUInt32BE(0x0493E1) .. writeUInt32BE(5) ..  -- 300001 精灵胶囊
            writeUInt32BE(0x0493EB) .. writeUInt32BE(3)     -- 300011 体力药剂
            
    elseif taskId == 88 then  -- 0x58 - 新手任务4 (使用道具)
        -- 官服响应: 00 00 00 58 00 00 00 00 00 00 00 00 00 00 00 03 
        --           00 00 00 01 00 00 C3 50  (1=金币, 50000)
        --           00 00 00 03 00 03 D0 90  (3=?, 250000)
        --           00 00 00 05 00 00 00 14  (5=?, 20)
        
        -- 更新用户金币
        if self.userdb then
            local db = self.userdb:new()
            local gameData = db:getOrCreateGameData(userId)
            gameData.coins = (gameData.coins or 0) + 50000
            db:saveGameData(userId, gameData)
            tprint(string.format("\27[32m[LocalGame] 任务88: 已添加50000金币\27[0m"))
        end
        
        responseBody = writeUInt32BE(taskId) ..
            writeUInt32BE(0) ..
            writeUInt32BE(0) ..
            writeUInt32BE(3) ..  -- itemCount: 3个奖励
            writeUInt32BE(1) .. writeUInt32BE(50000) ..   -- 金币 50000
            writeUInt32BE(3) .. writeUInt32BE(250000) ..  -- 经验? 250000
            writeUInt32BE(5) .. writeUInt32BE(20)         -- ? 20
    else
        responseBody = writeUInt32BE(taskId) ..
            writeUInt32BE(0) ..
            writeUInt32BE(0) ..
            writeUInt32BE(0)
    end
    
    -- 保存任务完成状态到数据库
    if self.userdb then
        local db = self.userdb:new()
        local gameData = db:getOrCreateGameData(userId)
        gameData.tasks = gameData.tasks or {}
        gameData.tasks[tostring(taskId)] = {
            status = "completed",
            acceptTime = gameData.tasks[tostring(taskId)] and gameData.tasks[tostring(taskId)].acceptTime or os.time(),
            completeTime = os.time(),
            param = param
        }
        db:saveGameData(userId, gameData)
        tprint(string.format("\27[32m[LocalGame] 任务 %d 状态已保存: completed\27[0m", taskId))
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2203: 获取任务缓存
function LocalGameServer:handleGetTaskBuf(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2203: 获取任务缓存\27[0m")
    
    -- 从数据库读取任务状态
    local taskCount = 0
    local taskData = ""
    
    if self.userdb then
        local db = self.userdb:new()
        local gameData = db:getOrCreateGameData(userId)
        gameData.tasks = gameData.tasks or {}
        
        -- 统计已接受但未完成的任务
        for taskIdStr, task in pairs(gameData.tasks) do
            if task.status == "accepted" then
                taskCount = taskCount + 1
                local taskId = tonumber(taskIdStr) or 0
                -- TaskBufInfo: taskId(4) + progress(4)
                taskData = taskData .. writeUInt32BE(taskId) .. writeUInt32BE(0)
            end
        end
    end
    
    local responseBody = writeUInt32BE(taskCount) .. taskData
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2301: 获取精灵信息
-- PetInfo (完整版 param2=true) 结构:
-- id(4) + name(16) + dv(4) + nature(4) + level(4) + exp(4) + lvExp(4) + nextLvExp(4)
-- + hp(4) + maxHp(4) + attack(4) + defence(4) + s_a(4) + s_d(4) + speed(4)
-- + ev_hp(4) + ev_attack(4) + ev_defence(4) + ev_sa(4) + ev_sd(4) + ev_sp(4)
-- + skillNum(4) + skills[4]*(id(4)+pp(4)) + catchTime(4) + catchMap(4) + catchRect(4) + catchLevel(4)
-- + effectCount(2) + [PetEffectInfo]... + skinID(4)
function LocalGameServer:handleGetPetInfo(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2301: 获取精灵信息\27[0m")
    
    local catchId = 0
    if #body >= 4 then
        catchId = readUInt32BE(body, 1)
    end
    
    -- 从数据库读取精灵数据
    local pet = nil
    local petId = 0
    local petLevel = 5
    local petExp = 0
    local petDv = 31
    local petNature = 0
    
    if self.userdb then
        local db = self.userdb:new()
        pet = db:getPetByCatchTime(userId, catchId)
        if pet then
            petId = pet.id or 0
            petLevel = pet.level or 5
            petExp = pet.exp or 0
            petDv = pet.dv or 31
            petNature = pet.nature or 0
        end
    end
    
    -- 如果数据库没有，使用内存中的数据
    if not pet then
        local userData = self:getOrCreateUser(userId)
        petId = userData.currentPetId or 7
    end
    
    -- 计算精灵属性
    local stats = SeerMonsters.calculateStats(petId, petLevel, petDv) or {
        hp = 100, maxHp = 100, attack = 39, defence = 35, spAtk = 78, spDef = 36, speed = 39
    }
    
    -- 获取精灵技能
    local skills = SeerMonsters.getBattleSkills(petId, petLevel) or {}
    local skillCount = math.min(#skills, 4)
    
    -- 计算经验信息
    local expInfo = SeerMonsters.getExpInfo(petId, petLevel, petExp)
    
    local responseBody = ""
    
    -- PetInfo (完整版)
    responseBody = responseBody .. writeUInt32BE(petId)      -- id
    responseBody = responseBody .. writeFixedString(pet and pet.name or "", 16)  -- name (16字节)
    responseBody = responseBody .. writeUInt32BE(petDv)      -- dv (个体值)
    responseBody = responseBody .. writeUInt32BE(petNature)  -- nature (性格)
    responseBody = responseBody .. writeUInt32BE(petLevel)   -- level
    responseBody = responseBody .. writeUInt32BE(petExp)     -- exp (总经验)
    responseBody = responseBody .. writeUInt32BE(expInfo.lvExp)      -- lvExp (当前等级已获经验)
    responseBody = responseBody .. writeUInt32BE(expInfo.nextLvExp)  -- nextLvExp (升级所需经验)
    responseBody = responseBody .. writeUInt32BE(stats.hp or 100)     -- hp
    responseBody = responseBody .. writeUInt32BE(stats.maxHp or 100)  -- maxHp
    responseBody = responseBody .. writeUInt32BE(stats.attack or 39)  -- attack
    responseBody = responseBody .. writeUInt32BE(stats.defence or 35) -- defence
    responseBody = responseBody .. writeUInt32BE(stats.spAtk or 78)   -- s_a (特攻)
    responseBody = responseBody .. writeUInt32BE(stats.spDef or 36)   -- s_d (特防)
    responseBody = responseBody .. writeUInt32BE(stats.speed or 39)   -- speed
    -- 注意: 客户端 PetInfo.as 没有 addMaxHP/addMoreMaxHP/addAttack/addDefence/addSA/addSD/addSpeed 字段
    -- 直接跳到 ev_* 字段
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_hp
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_attack
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_defence
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sa
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sd
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sp
    responseBody = responseBody .. writeUInt32BE(skillCount) -- skillNum
    
    -- 4个技能槽 (id + pp) - 官服 PP: 30, 35, 0, 0
    local ppValues = {30, 35, 0, 0}
    for i = 1, 4 do
        local skillId = skills[i] or 0
        if type(skillId) == "table" then
            skillId = skillId.id or 0
        end
        responseBody = responseBody .. writeUInt32BE(skillId) .. writeUInt32BE(ppValues[i])
    end
    
    responseBody = responseBody .. writeUInt32BE(catchId)    -- catchTime
    responseBody = responseBody .. writeUInt32BE(0)          -- catchMap (官服=0)
    responseBody = responseBody .. writeUInt32BE(0)          -- catchRect
    responseBody = responseBody .. writeUInt32BE(0)          -- catchLevel (官服=0)
    -- effectCount (2字节) + effectList (如果有)
    responseBody = responseBody .. writeUInt16BE(0)          -- effectCount
    -- 注意: 客户端 PetInfo.as 在 effectCount 之后直接读取 skinID，没有 peteffect/shiny/freeForbidden/boss 字段
    responseBody = responseBody .. writeUInt32BE(0)          -- skinID
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
    tprint(string.format("\27[32m[LocalGame] → GET_PET_INFO catchId=0x%08X petId=%d level=%d\27[0m", catchId, petId, petLevel))
end

-- CMD 2303: 获取精灵列表
function LocalGameServer:handleGetPetList(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2303: 获取精灵列表\27[0m")
    
    -- 从数据库读取精灵列表
    local petCount = 0
    local petData = ""
    
    if self.userdb then
        local db = self.userdb:new()
        local pets = db:getPets(userId)
        
        for _, pet in ipairs(pets) do
            petCount = petCount + 1
            local petId = pet.id or 0
            local catchTime = pet.catchTime or 0
            local level = pet.level or 5
            
            -- 计算精灵属性（如果数据库没有保存）
            local stats = SeerMonsters.calculateStats(petId, level, pet.dv or 31) or {hp = 100, maxHp = 100}
            local hp = pet.hp or stats.hp or 100
            local maxHp = pet.maxHp or stats.maxHp or 100
            
            -- 获取精灵技能
            local skills = SeerMonsters.getBattleSkills(petId, level) or {}
            local skillCount = math.min(#skills, 4)
            
            -- PetListInfo: catchTime(4) + id(4) + level(4) + hp(4) + maxHp(4) + skillNum(4) + skills[4]*(id+pp)
            petData = petData ..
                writeUInt32BE(catchTime) ..
                writeUInt32BE(petId) ..
                writeUInt32BE(level) ..
                writeUInt32BE(hp) ..
                writeUInt32BE(maxHp) ..
                writeUInt32BE(skillCount)
            
            -- 写入技能 (最多4个)
            for i = 1, 4 do
                local skillId = skills[i] or 0
                if type(skillId) == "table" then
                    skillId = skillId.id or 0
                end
                petData = petData .. writeUInt32BE(skillId) .. writeUInt32BE(30)  -- pp 默认30
            end
            
            tprint(string.format("\27[36m[LocalGame] 返回精灵: id=%d, catchTime=0x%08X, level=%d\27[0m", petId, catchTime, level))
        end
    end
    
    local responseBody = writeUInt32BE(petCount) .. petData
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2354: 获取灵魂珠列表
function LocalGameServer:handleGetSoulBeadList(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2354: 获取灵魂珠列表\27[0m")
    
    -- 返回空列表
    local responseBody = writeUInt32BE(0)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end


-- CMD 2401: 邀请战斗
function LocalGameServer:handleInviteToFight(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2401: 邀请战斗\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 2405: 使用技能
function LocalGameServer:handleUseSkill(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2405: 使用技能\27[0m")
    
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
    tprint("\27[36m[LocalGame] 处理 CMD 2408: 战斗NPC怪物\27[0m")
    
    local monsterId = 0
    if #body >= 4 then
        monsterId = readUInt32BE(body, 1)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 挑战怪物 %d\27[0m", userId, monsterId))
    
    -- 返回战斗开始信息
    local responseBody = writeUInt32BE(monsterId) ..
        writeUInt32BE(1)  -- 战斗ID
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2410: 逃跑
function LocalGameServer:handleEscapeFight(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2410: 逃跑\27[0m")
    
    local responseBody = writeUInt32BE(1)  -- 逃跑成功
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2757: 获取未读邮件
function LocalGameServer:handleMailGetUnread(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2757: 获取未读邮件\27[0m")
    
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
    tprint("\27[36m[LocalGame] 处理 CMD 9003: 获取NONO信息\27[0m")
    
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
    responseBody = responseBody .. writeFixedString(nonoData.nick or userData.nonoNick or "NONO", 16)  -- nick (16字节, 官服默认"NONO")
    responseBody = responseBody .. writeUInt32BE(nonoData.superNono or userData.superNono or 0)    -- superNono
    responseBody = responseBody .. writeUInt32BE(nonoData.color or userData.nonoColor or 0x00FFFFFF)  -- color (官服=0x00FFFFFF)
    responseBody = responseBody .. writeUInt32BE(nonoData.power or 10000)         -- power (官服=10000)
    responseBody = responseBody .. writeUInt32BE(nonoData.mate or 10000)          -- mate (官服=10000)
    responseBody = responseBody .. writeUInt32BE(nonoData.iq or 0)                -- iq (官服=0)
    responseBody = responseBody .. writeUInt16BE(nonoData.ai or 0)                -- ai (2字节)
    responseBody = responseBody .. writeUInt32BE(nonoData.birth or userData.regTime or os.time())  -- birth
    responseBody = responseBody .. writeUInt32BE(nonoData.chargeTime or 500)      -- chargeTime (官服=500)
    responseBody = responseBody .. string.rep("\xFF", 20)                         -- func (20字节, 官服全是0xFF)
    responseBody = responseBody .. writeUInt32BE(nonoData.superEnergy or 0)       -- superEnergy
    responseBody = responseBody .. writeUInt32BE(nonoData.superLevel or 0)        -- superLevel
    responseBody = responseBody .. writeUInt32BE(nonoData.superStage or 0)        -- superStage (官服=0)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 50004: 客户端信息上报
function LocalGameServer:handleCmd50004(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 50004: 客户端信息上报\27[0m")
    
    -- 解析客户端信息 (User-Agent 等)
    if #body > 4 then
        local infoType = readUInt32BE(body, 1)
        local infoLen = readUInt32BE(body, 5)
        local info = body:sub(9, 8 + infoLen)
        tprint(string.format("\27[36m[LocalGame] 客户端信息: type=%d, info=%s\27[0m", infoType, info:sub(1, 50)))
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 50008: 获取四倍经验时间
function LocalGameServer:handleCmd50008(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 50008: 获取四倍经验时间\27[0m")
    -- 返回四倍经验剩余时间 (0 = 无)
    local responseBody = writeUInt32BE(0)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2003: 获取地图玩家列表
-- 返回同地图所有在线玩家的完整信息（包括服装）
function LocalGameServer:handleListMapPlayer(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2003: 获取地图玩家列表\27[0m")
    
    -- 获取当前玩家所在地图
    local currentMapId = OnlineTracker.getPlayerMap(userId)
    
    -- 获取同地图的所有玩家
    local playersInMap = OnlineTracker.getPlayersInMap(currentMapId)
    
    tprint(string.format("\27[36m[LocalGame] 地图 %d 有 %d 个玩家\27[0m", currentMapId, #playersInMap))
    
    -- 构建响应: playerCount(4) + [PeopleInfo...]
    local responseBody = writeUInt32BE(#playersInMap)
    
    for _, playerId in ipairs(playersInMap) do
        local playerData = self:getOrCreateUser(playerId)
        local nickname = playerData.nick or playerData.nickname or playerData.username or tostring(playerId)
        local clothes = playerData.clothes or {}
        local teamInfo = playerData.teamInfo or {}
        
        -- PeopleInfo 结构 (与 ENTER_MAP 响应相同，但不含 sysTime)
        responseBody = responseBody .. writeUInt32BE(playerId)                    -- userID
        responseBody = responseBody .. writeFixedString(nickname, 16)             -- nick (16字节)
        responseBody = responseBody .. writeUInt32BE(playerData.color or 0xFFFFFF) -- color
        responseBody = responseBody .. writeUInt32BE(playerData.texture or 0)     -- texture
        
        -- vipFlags
        local vipFlags = 0
        if playerData.vip then vipFlags = vipFlags + 1 end
        if playerData.viped then vipFlags = vipFlags + 2 end
        responseBody = responseBody .. writeUInt32BE(vipFlags)                    -- vipFlags
        responseBody = responseBody .. writeUInt32BE(playerData.vipStage or 1)    -- vipStage
        
        responseBody = responseBody .. writeUInt32BE(0)                           -- actionType
        responseBody = responseBody .. writeUInt32BE(playerData.x or 300)         -- posX
        responseBody = responseBody .. writeUInt32BE(playerData.y or 200)         -- posY
        responseBody = responseBody .. writeUInt32BE(0)                           -- action
        responseBody = responseBody .. writeUInt32BE(1)                           -- direction
        responseBody = responseBody .. writeUInt32BE(playerData.changeShape or 0) -- changeShape
        responseBody = responseBody .. writeUInt32BE(playerData.spiritTime or 0)  -- spiritTime
        responseBody = responseBody .. writeUInt32BE(playerData.spiritID or 0)    -- spiritID
        responseBody = responseBody .. writeUInt32BE(playerData.petDV or 31)      -- petDV
        responseBody = responseBody .. writeUInt32BE(playerData.petSkin or 0)     -- petSkin
        responseBody = responseBody .. writeUInt32BE(playerData.fightFlag or 0)   -- fightFlag
        responseBody = responseBody .. writeUInt32BE(playerData.teacherID or 0)   -- teacherID
        responseBody = responseBody .. writeUInt32BE(playerData.studentID or 0)   -- studentID
        responseBody = responseBody .. writeUInt32BE(playerData.nonoState or 0)   -- nonoState
        responseBody = responseBody .. writeUInt32BE(playerData.nonoColor or 0)   -- nonoColor
        responseBody = responseBody .. writeUInt32BE(playerData.superNono or 0)   -- superNono
        responseBody = responseBody .. writeUInt32BE(playerData.playerForm or 0)  -- playerForm
        responseBody = responseBody .. writeUInt32BE(playerData.transTime or 0)   -- transTime
        
        -- TeamInfo
        responseBody = responseBody .. writeUInt32BE(teamInfo.id or 0)            -- team.id
        responseBody = responseBody .. writeUInt32BE(teamInfo.coreCount or 0)     -- team.coreCount
        responseBody = responseBody .. writeUInt32BE(teamInfo.isShow or 0)        -- team.isShow
        responseBody = responseBody .. writeUInt16BE(teamInfo.logoBg or 0)        -- team.logoBg
        responseBody = responseBody .. writeUInt16BE(teamInfo.logoIcon or 0)      -- team.logoIcon
        responseBody = responseBody .. writeUInt16BE(teamInfo.logoColor or 0)     -- team.logoColor
        responseBody = responseBody .. writeUInt16BE(teamInfo.txtColor or 0)      -- team.txtColor
        responseBody = responseBody .. writeFixedString(teamInfo.logoWord or "", 4) -- team.logoWord
        
        -- clothes
        responseBody = responseBody .. writeUInt32BE(#clothes)                    -- clothCount
        for _, cloth in ipairs(clothes) do
            responseBody = responseBody .. writeUInt32BE(cloth.id or cloth[1] or 0)
            responseBody = responseBody .. writeUInt32BE(cloth.level or cloth[2] or 0)
        end
        
        -- curTitle
        responseBody = responseBody .. writeUInt32BE(playerData.curTitle or 0)    -- curTitle
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2103: 舞蹈动作
function LocalGameServer:handleDanceAction(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2103: 舞蹈动作\27[0m")
    
    local actionId = 0
    local actionType = 0
    if #body >= 8 then
        actionId = readUInt32BE(body, 1)
        actionType = readUInt32BE(body, 5)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 执行动作 %d 类型 %d\27[0m", userId, actionId, actionType))
    
    -- 广播给其他玩家
    local responseBody = writeUInt32BE(userId) ..
        writeUInt32BE(actionId) ..
        writeUInt32BE(actionType)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2104: 瞄准/交互
function LocalGameServer:handleAimat(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2104: 瞄准/交互\27[0m")
    
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
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 瞄准 type=%d id=%d pos=(%d,%d)\27[0m", 
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
    tprint("\27[36m[LocalGame] 处理 CMD 2111: 变身\27[0m")
    
    local transformId = 0
    if #body >= 4 then
        transformId = readUInt32BE(body, 1)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 变身为 %d\27[0m", userId, transformId))
    
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
-- + ev_hp(4) + ev_attack(4) + ev_defence(4) + ev_sa(4) + ev_sd(4) + ev_sp(4)
-- + skillNum(4) + skills[4]*(id(4)+pp(4)) + catchTime(4) + catchMap(4) + catchRect(4) + catchLevel(4)
-- + effectCount(2) + [PetEffectInfo]... + skinID(4)
function LocalGameServer:handlePetRelease(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2304: 释放精灵\27[0m")
    
    local catchId = 0
    local flag = 0
    
    if #body >= 4 then
        catchId = readUInt32BE(body, 1)
    end
    if #body >= 8 then
        flag = readUInt32BE(body, 5)
    end
    
    local userData = self:getOrCreateUser(userId)
    
    -- 根据 catchId 查找之前保存的精灵ID
    -- 如果 catchId 匹配之前任务返回的 catchId，使用保存的 petId
    local petId = userData.currentPetId or 1
    if userData.catchId and userData.catchId == catchId then
        petId = userData.currentPetId or 1
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 释放精灵 catchId=0x%08X flag=%d petId=%d (userData.catchId=%s)\27[0m", 
        userId, catchId, flag, petId, 
        userData.catchId and string.format("0x%08X", userData.catchId) or "nil"))
    
    -- 获取精灵数据
    local petLevel = 5
    local petDv = 31
    local petNature = math.random(0, 24)  -- 随机性格
    local stats = SeerMonsters.calculateStats(petId, petLevel, petDv) or {hp = 20, maxHp = 20}
    local skills = SeerMonsters.getBattleSkills(petId, petLevel)
    local skillCount = 0
    for _, s in ipairs(skills) do
        if s > 0 then skillCount = skillCount + 1 end
    end
    
    -- 计算经验信息
    -- 新精灵: exp=0 (官服行为), lvExp=0
    local expInfo = SeerMonsters.getExpInfo(petId, petLevel, 0)
    
    local responseBody = ""
    
    -- PetTakeOutInfo 结构 (官服格式)
    responseBody = responseBody .. writeUInt32BE(0)          -- homeEnergy (官服=0)
    responseBody = responseBody .. writeUInt32BE(catchId)    -- firstPetTime (官服=catchId)
    responseBody = responseBody .. writeUInt32BE(1)          -- flag (有精灵信息)
    
    -- PetInfo (完整版)
    responseBody = responseBody .. writeUInt32BE(petId)      -- id (使用正确的精灵ID)
    responseBody = responseBody .. writeFixedString("", 16)  -- name (16字节)
    responseBody = responseBody .. writeUInt32BE(petDv)      -- dv (个体值=31)
    responseBody = responseBody .. writeUInt32BE(petNature)  -- nature (随机性格)
    responseBody = responseBody .. writeUInt32BE(petLevel)   -- level
    responseBody = responseBody .. writeUInt32BE(0)          -- exp (官服新精灵=0)
    responseBody = responseBody .. writeUInt32BE(0)          -- lvExp (官服新精灵=0)
    responseBody = responseBody .. writeUInt32BE(expInfo.nextLvExp)  -- nextLvExp (官服=114)
    responseBody = responseBody .. writeUInt32BE(stats.hp)   -- hp
    responseBody = responseBody .. writeUInt32BE(stats.maxHp) -- maxHp
    responseBody = responseBody .. writeUInt32BE(stats.attack or 12)   -- attack
    responseBody = responseBody .. writeUInt32BE(stats.defence or 12)  -- defence
    responseBody = responseBody .. writeUInt32BE(stats.spAtk or 11)    -- s_a (特攻)
    responseBody = responseBody .. writeUInt32BE(stats.spDef or 10)    -- s_d (特防)
    responseBody = responseBody .. writeUInt32BE(stats.speed or 12)    -- speed
    -- 注意: 客户端 PetInfo.as 没有 addMaxHP/addMoreMaxHP/addAttack/addDefence/addSA/addSD/addSpeed 字段
    -- 直接跳到 ev_* 字段
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_hp
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_attack
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_defence
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sa
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sd
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sp
    responseBody = responseBody .. writeUInt32BE(skillCount) -- skillNum (官服=实际技能数)
    -- 4个技能槽 (id + pp) - 官服 PP: 30, 35
    responseBody = responseBody .. writeUInt32BE(skills[1] or 0) .. writeUInt32BE(30)
    responseBody = responseBody .. writeUInt32BE(skills[2] or 0) .. writeUInt32BE(35)
    responseBody = responseBody .. writeUInt32BE(skills[3] or 0) .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(skills[4] or 0) .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(catchId)    -- catchTime
    responseBody = responseBody .. writeUInt32BE(0)          -- catchMap (官服=0)
    responseBody = responseBody .. writeUInt32BE(0)          -- catchRect
    responseBody = responseBody .. writeUInt32BE(0)          -- catchLevel (官服=0)
    -- effectCount (2字节) + effectList (如果有)
    responseBody = responseBody .. writeUInt16BE(0)          -- effectCount
    -- 注意: 客户端 PetInfo.as 在 effectCount 之后直接读取 skinID，没有 peteffect/shiny/freeForbidden/boss 字段
    responseBody = responseBody .. writeUInt32BE(0)          -- skinID
    
    -- 保存精灵到数据库
    if self.userdb and flag == 1 then  -- flag=1 表示从仓库释放到背包
        local db = self.userdb:new()
        db:addPet(userId, petId, catchId, petLevel, petDv, petNature)
        tprint(string.format("\27[32m[LocalGame] 精灵已保存到数据库: petId=%d, catchId=0x%08X, nature=%d\27[0m", petId, catchId, petNature))
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2411: 挑战BOSS
function LocalGameServer:handleChallengeBoss(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2411: 挑战BOSS\27[0m")
    
    local bossId = 0
    if #body >= 4 then
        bossId = readUInt32BE(body, 1)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 挑战BOSS %d\27[0m", userId, bossId))
    
    local userData = self:getOrCreateUser(userId)
    
    -- 先响应 CMD 2411 (客户端需要收到响应才能继续)
    self:sendResponse(clientData, cmdId, userId, 0, "")
    
    -- 然后发送 NOTE_READY_TO_FIGHT (2503) 通知
    self:sendNoteReadyToFight(clientData, userId, bossId, userData)
end

-- 初始化战斗实例
function LocalGameServer:initBattle(userId, userData, enemyPetId)
    local petId = userData.currentPetId or 7
    local petLevel = 5
    local enemyLevel = 1  -- 官服新手教程比比鼠是 level=1
    
    -- 获取玩家精灵数据
    local playerStats = SeerMonsters.calculateStats(petId, petLevel, 31) or {hp = 20, maxHp = 20}
    local playerSkills = SeerMonsters.getBattleSkills(petId, petLevel)
    local playerMonster = SeerMonsters.get(petId)
    
    -- 获取敌方精灵数据
    local enemyStats = SeerMonsters.calculateStats(enemyPetId, enemyLevel, 15) or {hp = 12, maxHp = 12}
    local enemySkills = SeerMonsters.getBattleSkills(enemyPetId, enemyLevel)
    local enemyMonster = SeerMonsters.get(enemyPetId)
    
    -- 创建战斗实例
    local battle = SeerBattle.createBattle(userId, {
        id = petId,
        level = petLevel,
        hp = playerStats.hp,
        maxHp = playerStats.maxHp,
        attack = playerStats.attack,
        defence = playerStats.defence,
        spAtk = playerStats.spAtk,
        spDef = playerStats.spDef,
        speed = playerStats.speed,
        type = playerMonster and playerMonster.type or 8,
        skills = playerSkills,
        catchTime = userData.catchId or 0
    }, {
        id = enemyPetId,
        level = enemyLevel,
        hp = enemyStats.hp,
        maxHp = enemyStats.maxHp,
        attack = enemyStats.attack,
        defence = enemyStats.defence,
        spAtk = enemyStats.spAtk,
        spDef = enemyStats.spDef,
        speed = enemyStats.speed,
        type = enemyMonster and enemyMonster.type or 8,
        skills = enemySkills,
        catchTime = userData.enemyCatchTime or 0
    })
    
    -- 保存战斗实例
    userData.battle = battle
    
    tprint(string.format("\27[33m[LocalGame] 战斗初始化: 玩家精灵 %d (HP=%d) vs 敌方精灵 %d (HP=%d)\27[0m",
        petId, playerStats.hp, enemyPetId, enemyStats.hp))
    
    return battle
end

-- 发送战斗准备通知
-- NoteReadyToFightInfo 结构 (基于 AS3 代码分析):
-- fightType (4字节) - 战斗类型 (官服新手教程=3)
-- 循环2次:
--   FighetUserInfo: userId(4) + nickName(16)
--   petCount (4字节) - 精灵数量
--   循环 petCount 次:
--     PetInfo (简化版, param2=false):
--       id(4) + level(4) + hp(4) + maxHp(4) + skillNum(4) + skills[4]*(id(4)+pp(4)) + catchTime(4) + catchMap(4) + catchRect(4) + catchLevel(4) + skinID(4)
function LocalGameServer:sendNoteReadyToFight(clientData, userId, bossId, userData)
    tprint("\27[36m[LocalGame] 发送 CMD 2503: 战斗准备通知\27[0m")
    
    local petId = userData.currentPetId or 1
    local catchTime = userData.catchId or 0x6969C45E
    local petLevel = 5
    
    -- 敌人精灵的 catchTime (必须唯一，用于客户端查找 PetInfo)
    local enemyCatchTime = 0x69690000 + os.time() % 0x10000
    
    -- 从精灵数据库获取技能
    local skills = SeerMonsters.getBattleSkills(petId, petLevel)
    local skillCount = 0
    for _, s in ipairs(skills) do
        if s > 0 then skillCount = skillCount + 1 end
    end
    
    -- 计算精灵属性 (玩家 dv=31)
    local stats = SeerMonsters.calculateStats(petId, petLevel, 31) or {hp = 20, maxHp = 20}
    
    tprint(string.format("\27[36m[LocalGame] 精灵 %d (%s) Lv%d, HP=%d, 实际技能=%d个, 发送skillNum=4\27[0m", 
        petId, SeerMonsters.getName(petId), petLevel, stats.hp, skillCount))
    tprint(string.format("\27[33m[LocalGame] 玩家 catchTime=0x%08X, 敌人 catchTime=0x%08X\27[0m", 
        catchTime, enemyCatchTime))
    
    -- 构建 NoteReadyToFightInfo
    local responseBody = ""
    
    -- fightType (官服新手教程=3)
    responseBody = responseBody .. writeUInt32BE(3)
    
    -- === 玩家1 (自己) ===
    responseBody = responseBody .. writeUInt32BE(userId)
    responseBody = responseBody .. writeFixedString(userData.nick or userData.nickname or userData.username or tostring(userId), 16)
    
    -- petCount
    responseBody = responseBody .. writeUInt32BE(1)
    
    -- PetInfo
    responseBody = responseBody .. writeUInt32BE(petId)
    responseBody = responseBody .. writeUInt32BE(petLevel)
    responseBody = responseBody .. writeUInt32BE(stats.hp)
    responseBody = responseBody .. writeUInt32BE(stats.maxHp)
    -- 官服始终发送 skillNum=4，即使精灵只有2个技能
    responseBody = responseBody .. writeUInt32BE(4)
    -- 4个技能槽 (id + pp) - 官服 PP 值: 30, 35, 0, 0
    responseBody = responseBody .. writeUInt32BE(skills[1] or 0) .. writeUInt32BE(30)
    responseBody = responseBody .. writeUInt32BE(skills[2] or 0) .. writeUInt32BE(35)
    responseBody = responseBody .. writeUInt32BE(skills[3] or 0) .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(skills[4] or 0) .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(catchTime)
    responseBody = responseBody .. writeUInt32BE(0)  -- catchMap=0 (官服)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(petLevel)
    responseBody = responseBody .. writeUInt32BE(0)
    
    -- === 玩家2 (敌人/BOSS) ===
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeFixedString("", 16)
    
    -- petCount
    responseBody = responseBody .. writeUInt32BE(1)
    
    -- BOSS精灵 (新手教程=13 比比鼠, 官服 level=1)
    local enemyPetId = 13
    local enemyLevel = 1  -- 官服比比鼠是 level=1
    local enemySkills = SeerMonsters.getBattleSkills(enemyPetId, enemyLevel)
    local enemyStats = SeerMonsters.calculateStats(enemyPetId, enemyLevel, 15) or {hp = 12, maxHp = 12}
    local enemySkillCount = 0
    for _, s in ipairs(enemySkills) do
        if s > 0 then enemySkillCount = enemySkillCount + 1 end
    end
    
    responseBody = responseBody .. writeUInt32BE(enemyPetId)
    responseBody = responseBody .. writeUInt32BE(enemyLevel)
    responseBody = responseBody .. writeUInt32BE(enemyStats.hp)
    responseBody = responseBody .. writeUInt32BE(enemyStats.maxHp)
    -- 官服始终发送 skillNum=4
    responseBody = responseBody .. writeUInt32BE(4)
    -- 官服敌人技能 PP: 10001(35pp), 其他为0
    responseBody = responseBody .. writeUInt32BE(enemySkills[1] or 0) .. writeUInt32BE(35)
    responseBody = responseBody .. writeUInt32BE(enemySkills[2] or 0) .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(enemySkills[3] or 0) .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(enemySkills[4] or 0) .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(enemyCatchTime)  -- 敌人也需要唯一的 catchTime
    responseBody = responseBody .. writeUInt32BE(0)  -- catchMap=0 (官服)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(enemyLevel)
    responseBody = responseBody .. writeUInt32BE(0)
    
    -- 保存当前战斗信息
    userData.currentBossId = enemyPetId
    userData.enemyCatchTime = enemyCatchTime  -- 保存敌人的 catchTime
    userData.inFight = true
    userData.myPetStats = stats
    userData.enemyPetStats = enemyStats
    
    -- 初始化战斗实例
    self:initBattle(userId, userData, enemyPetId)
    
    tprint(string.format("\27[33m[LocalGame] 2503 包体大小: %d bytes\27[0m", #responseBody))
    
    -- 打印包体的十六进制内容（前64字节）
    local hexStr = ""
    for i = 1, math.min(64, #responseBody) do
        hexStr = hexStr .. string.format("%02X ", responseBody:byte(i))
        if i % 16 == 0 then hexStr = hexStr .. "\n" end
    end
    tprint("\27[33m[LocalGame] 2503 包体 (前64字节):\n" .. hexStr .. "\27[0m")
    
    self:sendResponse(clientData, 2503, userId, 0, responseBody)
end

-- CMD 2404: 准备战斗
function LocalGameServer:handleReadyToFight(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2404: 准备战斗\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    
    -- 调试: 检查 userData 中的战斗数据
    tprint(string.format("\27[33m[LocalGame] userData: currentPetId=%s, catchId=%s, enemyCatchTime=%s, currentBossId=%s\27[0m",
        tostring(userData.currentPetId), 
        userData.catchId and string.format("0x%08X", userData.catchId) or "nil",
        userData.enemyCatchTime and string.format("0x%08X", userData.enemyCatchTime) or "nil",
        tostring(userData.currentBossId)))
    
    -- 先响应 CMD 2404
    self:sendResponse(clientData, cmdId, userId, 0, "")
    
    -- 然后发送 NOTE_START_FIGHT (2504) 通知
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
    tprint("\27[36m[LocalGame] 发送 CMD 2504: 战斗开始通知\27[0m")
    
    local petId = userData.currentPetId or 4
    local catchTime = userData.catchId or 0x6969C45E
    local bossId = userData.currentBossId or 13  -- 新手教程BOSS=比比鼠(13)
    local enemyCatchTime = userData.enemyCatchTime or 0x69690000  -- 敌人的 catchTime
    local petLevel = 5
    local enemyLevel = 1  -- 官服比比鼠是 level=1
    
    tprint(string.format("\27[33m[LocalGame] 2504: 玩家 petId=%d catchTime=0x%08X, 敌人 bossId=%d catchTime=0x%08X\27[0m", 
        petId, catchTime, bossId, enemyCatchTime))
    
    -- 从精灵数据库获取属性 (玩家 dv=31, 敌人 dv=15)
    local myStats = SeerMonsters.calculateStats(petId, petLevel, 31) or {hp = 20, maxHp = 20}
    local enemyStats = SeerMonsters.calculateStats(bossId, enemyLevel, 15) or {hp = 12, maxHp = 12}
    
    local responseBody = ""
    
    -- isCanAuto (4字节)
    responseBody = responseBody .. writeUInt32BE(0)  -- 不允许自动战斗
    
    -- === FightPetInfo 1 (玩家精灵) ===
    responseBody = responseBody .. writeUInt32BE(userId)                      -- userID
    responseBody = responseBody .. writeUInt32BE(petId)                       -- petID
    responseBody = responseBody .. writeFixedString("", 16)                   -- petName (16字节)
    responseBody = responseBody .. writeUInt32BE(catchTime)                   -- catchTime
    responseBody = responseBody .. writeUInt32BE(myStats.hp)                  -- hp
    responseBody = responseBody .. writeUInt32BE(myStats.maxHp)               -- maxHP
    responseBody = responseBody .. writeUInt32BE(petLevel)                    -- lv
    responseBody = responseBody .. writeUInt32BE(0)                           -- catchable (玩家精灵不可捕捉)
    responseBody = responseBody .. string.char(0, 0, 0, 0, 0, 0)              -- battleLv (6字节)
    
    -- === FightPetInfo 2 (敌方精灵/BOSS) ===
    responseBody = responseBody .. writeUInt32BE(0)                           -- userID (敌人=0)
    responseBody = responseBody .. writeUInt32BE(bossId)                      -- petID
    responseBody = responseBody .. writeFixedString("", 16)                   -- petName (16字节)
    responseBody = responseBody .. writeUInt32BE(enemyCatchTime)              -- catchTime (必须与 2503 中一致)
    responseBody = responseBody .. writeUInt32BE(enemyStats.hp)               -- hp
    responseBody = responseBody .. writeUInt32BE(enemyStats.maxHp)            -- maxHP
    responseBody = responseBody .. writeUInt32BE(enemyLevel)                  -- lv (敌人等级=1)
    responseBody = responseBody .. writeUInt32BE(0)                           -- catchable (新手教程不可捕捉)
    responseBody = responseBody .. string.char(0, 0, 0, 0, 0, 0)              -- battleLv (6字节)
    
    tprint(string.format("\27[33m[LocalGame] 2504 包体大小: %d bytes\27[0m", #responseBody))
    self:sendResponse(clientData, 2504, userId, 0, responseBody)
end

-- CMD 2605: 物品列表
function LocalGameServer:handleItemList(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2605: 物品列表\27[0m")
    
    -- 解析请求的物品类型范围
    local itemType1 = 0
    local itemType2 = 0
    local itemType3 = 0
    
    if #body >= 12 then
        itemType1 = readUInt32BE(body, 1)
        itemType2 = readUInt32BE(body, 5)
        itemType3 = readUInt32BE(body, 9)
    end
    
    tprint(string.format("\27[36m[LocalGame] 查询物品类型: %d, %d, %d\27[0m", itemType1, itemType2, itemType3))
    
    -- 从数据库读取物品
    local itemCount = 0
    local itemData = ""
    
    if self.userdb then
        local db = self.userdb:new()
        local gameData = db:getOrCreateGameData(userId)
        gameData.items = gameData.items or {}
        
        -- 遍历所有物品，筛选在请求范围内的
        for itemIdStr, itemInfo in pairs(gameData.items) do
            local itemId = tonumber(itemIdStr) or 0
            -- 检查物品是否在请求的范围内
            if itemId >= itemType1 and itemId <= itemType2 then
                local count = itemInfo.count or 1
                local expireTime = itemInfo.expireTime or 0x057E40
                
                itemData = itemData ..
                    writeUInt32BE(itemId) ..
                    writeUInt32BE(count) ..
                    writeUInt32BE(expireTime) ..
                    writeUInt32BE(0)  -- 额外数据
                itemCount = itemCount + 1
                
                tprint(string.format("\27[36m[LocalGame] 返回物品: id=%d, count=%d\27[0m", itemId, count))
            end
        end
    end
    
    local responseBody = writeUInt32BE(itemCount) .. itemData
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 1106: 检查金币余额
function LocalGameServer:handleGoldOnlineCheckRemain(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 1106: 检查金币余额\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    
    -- 返回金币余额 (使用 coins 字段)
    local responseBody = writeUInt32BE(userData.coins or userData.gold or 999999)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- 处理技能使用 (增强版)
function LocalGameServer:handleUseSkillEnhanced(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2405: 使用技能 (增强版)\27[0m")
    
    local skillId = 0
    if #body >= 4 then
        skillId = readUInt32BE(body, 1)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 使用技能 %d (%s)\27[0m", 
        userId, skillId, SeerSkills.getName(skillId)))
    
    local userData = self:getOrCreateUser(userId)
    local battle = userData.battle
    
    -- 先发送技能确认
    self:sendResponse(clientData, cmdId, userId, 0, "")
    
    if battle then
        -- 执行战斗回合
        local result = SeerBattle.executeTurn(battle, skillId)
        
        tprint(string.format("\27[33m[LocalGame] 回合 %d: 玩家技能=%d, AI技能=%d\27[0m",
            result.turn, result.playerSkillId, result.enemySkillId or 0))
        
        -- 发送 NOTE_USE_SKILL (2505)
        self:sendNoteUseSkillWithResult(clientData, userId, result)
        
        -- 检查战斗是否结束
        if result.isOver then
            tprint(string.format("\27[32m[LocalGame] 战斗结束! 胜利者: %s\27[0m",
                result.winner == userId and "玩家" or "敌方"))
            self:sendFightOver(clientData, userId, result.winner)
        end
    else
        -- 没有战斗实例，使用旧逻辑
        self:sendNoteUseSkill(clientData, userId, skillId)
        self:sendFightOver(clientData, userId, userId)
    end
end

-- 发送技能使用通知 (使用战斗结果)
-- UseSkillInfo 结构 (基于 AS3 UseSkillInfo.as):
--   firstAttackInfo (AttackValue)
--   secondAttackInfo (AttackValue)
--
-- AttackValue 结构 (基于 AS3 AttackValue.as):
--   userID (4字节) - 使用技能的用户ID
--   skillID (4字节) - 技能ID
--   atkTimes (4字节) - 攻击次数 (0=MISS, 1=命中)
--   lostHP (4字节) - 该用户损失的HP (被对方攻击造成的伤害)
--   gainHP (4字节, signed) - 该用户获得的HP (吸血等)
--   remainHp (4字节, signed) - 该用户剩余HP
--   maxHp (4字节) - 该用户最大HP
--   state (4字节) - 状态 (1=麻痹滤镜, 2=中毒滤镜, 12=山神守护, 13=易燃)
--   skillListCount (4字节) - 技能列表数量
--   [PetSkillInfo]... - 技能列表 (id(4) + pp(4)) * skillListCount
--   isCrit (4字节) - 是否暴击 (1=是, 0=否)
--   status (20字节) - 状态数组 (每个状态的剩余回合数)
--   battleLv (6字节) - 能力等级变化数组 (攻击/防御/特攻/特防/速度/命中)
--   maxShield (4字节) - 最大护盾
--   curShield (4字节) - 当前护盾
--   petType (4字节) - 精灵类型
function LocalGameServer:sendNoteUseSkillWithResult(clientData, userId, result)
    tprint("\27[36m[LocalGame] 发送 CMD 2505: 技能使用通知 (战斗系统)\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    local battle = userData.battle
    local playerSkills = battle and battle.player.skills or {}
    local enemySkills = battle and battle.enemy.skills or {}
    
    local responseBody = ""
    
    -- 构建 AttackValue 结构
    -- 注意: lostHP 是该用户被对方攻击造成的伤害，不是该用户造成的伤害
    local function buildAttackValue(attackerUserId, skillId, atkTimes, lostHp, gainHp, remainHp, maxHp, isCrit, skills, battleLv, status)
        local data = ""
        data = data .. writeUInt32BE(attackerUserId)          -- userID
        data = data .. writeUInt32BE(skillId or 0)            -- skillID
        data = data .. writeUInt32BE(atkTimes or 1)           -- atkTimes (0=MISS)
        data = data .. writeUInt32BE(lostHp or 0)             -- lostHP (被对方攻击的伤害)
        
        -- gainHP 是有符号整数
        local gainHpValue = gainHp or 0
        if gainHpValue < 0 then
            gainHpValue = 0x100000000 + gainHpValue  -- 转换为无符号表示
        end
        data = data .. writeUInt32BE(gainHpValue)             -- gainHP (signed)
        
        -- remainHp 是有符号整数
        local remainHpValue = remainHp or 0
        if remainHpValue < 0 then
            remainHpValue = 0
        end
        data = data .. writeUInt32BE(remainHpValue)           -- remainHp (signed)
        data = data .. writeUInt32BE(maxHp or 100)            -- maxHp
        data = data .. writeUInt32BE(0)                       -- state
        
        -- 技能列表
        local skillCount = 0
        for _, s in ipairs(skills or {}) do
            if s and s > 0 then skillCount = skillCount + 1 end
        end
        data = data .. writeUInt32BE(skillCount)              -- skillListCount
        
        -- 写入技能信息 (id + pp)
        for i = 1, skillCount do
            local sid = skills[i] or 0
            local pp = 30  -- 默认PP
            data = data .. writeUInt32BE(sid)
            data = data .. writeUInt32BE(pp)
        end
        
        data = data .. writeUInt32BE(isCrit and 1 or 0)       -- isCrit
        
        -- status (20字节) - 状态数组
        if status then
            for i = 0, 19 do
                data = data .. string.char(status[i] or 0)
            end
        else
            data = data .. string.rep("\0", 20)
        end
        
        -- battleLv (6字节) - 能力等级变化
        if battleLv then
            for i = 1, 6 do
                local lv = battleLv[i] or 0
                if lv < 0 then lv = 256 + lv end  -- 转换为无符号
                data = data .. string.char(lv)
            end
        else
            data = data .. string.rep("\0", 6)
        end
        
        data = data .. writeUInt32BE(0)                       -- maxShield
        data = data .. writeUInt32BE(0)                       -- curShield
        data = data .. writeUInt32BE(0)                       -- petType
        
        return data
    end
    
    -- 获取先攻和后攻信息
    local first = result.firstAttack
    local second = result.secondAttack
    
    -- 构建先攻方的 AttackValue
    if first then
        local isPlayerFirst = first.userId == userId
        local attackerSkills = isPlayerFirst and playerSkills or enemySkills
        local attackerBattleLv = isPlayerFirst and (battle and battle.player.battleLv) or (battle and battle.enemy.battleLv)
        
        -- 先攻方的 lostHP = 后攻方对先攻方造成的伤害
        local firstLostHp = 0
        if second and not result.isOver then
            firstLostHp = second.damage or 0
        end
        
        responseBody = responseBody .. buildAttackValue(
            first.userId,
            first.skillId,
            first.atkTimes or 1,
            firstLostHp,
            first.gainHp or 0,
            first.attackerRemainHp,
            first.attackerMaxHp,
            first.isCrit,
            attackerSkills,
            attackerBattleLv,
            nil
        )
        
        tprint(string.format("\27[33m[LocalGame] 先攻: %s 使用 %s, 造成 %d 伤害%s, 剩余HP=%d\27[0m",
            first.userId == userId and "玩家" or "敌方",
            SeerSkills.getName(first.skillId),
            first.damage or 0,
            first.isCrit and " (暴击!)" or "",
            first.attackerRemainHp or 0))
    end
    
    -- 构建后攻方的 AttackValue
    if second then
        local isPlayerSecond = second.userId == userId
        local attackerSkills = isPlayerSecond and playerSkills or enemySkills
        local attackerBattleLv = isPlayerSecond and (battle and battle.player.battleLv) or (battle and battle.enemy.battleLv)
        
        -- 后攻方的 lostHP = 先攻方对后攻方造成的伤害
        local secondLostHp = first and first.damage or 0
        
        responseBody = responseBody .. buildAttackValue(
            second.userId,
            second.skillId,
            second.atkTimes or 1,
            secondLostHp,
            second.gainHp or 0,
            second.attackerRemainHp,
            second.attackerMaxHp,
            second.isCrit,
            attackerSkills,
            attackerBattleLv,
            nil
        )
        
        tprint(string.format("\27[33m[LocalGame] 后攻: %s 使用 %s, 造成 %d 伤害%s, 剩余HP=%d\27[0m",
            second.userId == userId and "玩家" or "敌方",
            SeerSkills.getName(second.skillId),
            second.damage or 0,
            second.isCrit and " (暴击!)" or "",
            second.attackerRemainHp or 0))
    else
        -- 如果没有第二次攻击（对方已死），发送空的攻击信息
        -- 但仍需要保持正确的结构
        local deadUserId = first.userId == userId and 0 or userId
        local deadSkills = deadUserId == userId and playerSkills or enemySkills
        
        responseBody = responseBody .. buildAttackValue(
            deadUserId,
            0,  -- 无技能
            0,  -- atkTimes=0 表示无法行动
            first.damage or 0,  -- 被先攻方造成的伤害
            0,
            0,  -- 剩余HP=0 (已死亡)
            100,
            false,
            deadSkills,
            nil,
            nil
        )
    end
    
    self:sendResponse(clientData, 2505, userId, 0, responseBody)
end

-- 发送技能使用通知 (旧版本，兼容)
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
-- maxShield (4字节) - 最大护盾
-- curShield (4字节) - 当前护盾
-- petType (4字节) - 精灵类型
function LocalGameServer:sendNoteUseSkill(clientData, userId, skillId)
    tprint("\27[36m[LocalGame] 发送 CMD 2505: 技能使用通知 (旧版)\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    local petId = userData.currentPetId or 4
    local bossId = userData.currentBossId or 13
    
    local responseBody = ""
    
    -- === firstAttackInfo (玩家攻击) ===
    responseBody = responseBody .. writeUInt32BE(userId)     -- userID
    responseBody = responseBody .. writeUInt32BE(skillId)    -- skillID
    responseBody = responseBody .. writeUInt32BE(1)          -- atkTimes
    responseBody = responseBody .. writeUInt32BE(0)          -- lostHP (玩家未受伤)
    responseBody = responseBody .. writeUInt32BE(0)          -- gainHP
    responseBody = responseBody .. writeUInt32BE(17)         -- remainHp
    responseBody = responseBody .. writeUInt32BE(21)         -- maxHp
    responseBody = responseBody .. writeUInt32BE(0)          -- state
    responseBody = responseBody .. writeUInt32BE(2)          -- skillListCount
    responseBody = responseBody .. writeUInt32BE(skillId) .. writeUInt32BE(39)
    responseBody = responseBody .. writeUInt32BE(10020) .. writeUInt32BE(10020)
    responseBody = responseBody .. writeUInt32BE(0)          -- isCrit
    responseBody = responseBody .. string.rep("\0", 20)      -- status
    responseBody = responseBody .. string.rep("\0", 6)       -- battleLv
    responseBody = responseBody .. writeUInt32BE(0)          -- maxShield
    responseBody = responseBody .. writeUInt32BE(0)          -- curShield
    responseBody = responseBody .. writeUInt32BE(0)          -- petType
    
    -- === secondAttackInfo (敌方/BOSS) ===
    responseBody = responseBody .. writeUInt32BE(0)          -- userID (敌人=0)
    responseBody = responseBody .. writeUInt32BE(skillId)    -- skillID
    responseBody = responseBody .. writeUInt32BE(0)          -- atkTimes
    responseBody = responseBody .. writeUInt32BE(17)         -- lostHP
    responseBody = responseBody .. writeUInt32BE(0)          -- gainHP
    responseBody = responseBody .. writeUInt32BE(0)          -- remainHp (敌人死亡)
    responseBody = responseBody .. writeUInt32BE(21)         -- maxHp
    responseBody = responseBody .. writeUInt32BE(0)          -- state
    responseBody = responseBody .. writeUInt32BE(0)          -- skillListCount
    responseBody = responseBody .. writeUInt32BE(0)          -- isCrit
    responseBody = responseBody .. string.rep("\0", 20)      -- status
    responseBody = responseBody .. string.rep("\0", 6)       -- battleLv
    responseBody = responseBody .. writeUInt32BE(0)          -- maxShield
    responseBody = responseBody .. writeUInt32BE(0)          -- curShield
    responseBody = responseBody .. writeUInt32BE(0)          -- petType
    
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
function LocalGameServer:sendFightOver(clientData, userId, winnerId)
    tprint("\27[36m[LocalGame] 发送战斗结束序列\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    
    -- 清理战斗状态
    userData.battle = nil
    userData.inFight = false
    
    -- 1. 发送 GET_BOSS_MONSTER (8004) - BOSS战斗奖励
    self:sendGetBossMonster(clientData, userId, userData)
    
    -- 2. 发送 NOTE_UPDATE_PROP (2508) 更新精灵属性
    self:sendNoteUpdateProp(clientData, userId, userData)
    
    -- 3. 发送 FIGHT_OVER (2506)
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

-- 发送 BOSS 战斗奖励
-- BossMonsterInfo 结构:
-- bonusID (4字节) - 奖励ID
-- petID (4字节) - 获得的精灵ID (0=无)
-- captureTm (4字节) - 精灵捕获时间
-- itemCount (4字节) - 物品数量
-- [itemID(4) + itemCnt(4)]... - 物品列表
function LocalGameServer:sendGetBossMonster(clientData, userId, userData)
    tprint("\27[36m[LocalGame] 发送 CMD 8004: BOSS战斗奖励\27[0m")
    
    local responseBody = ""
    
    -- 官服日志: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 03 00 00 00 02
    -- bonusID=0, petID=0, captureTm=0, itemCount=1, item=(3, 2)
    responseBody = responseBody .. writeUInt32BE(0)          -- bonusID
    responseBody = responseBody .. writeUInt32BE(0)          -- petID (无精灵奖励)
    responseBody = responseBody .. writeUInt32BE(0)          -- captureTm
    responseBody = responseBody .. writeUInt32BE(1)          -- itemCount
    responseBody = responseBody .. writeUInt32BE(3)          -- itemID (经验道具?)
    responseBody = responseBody .. writeUInt32BE(2)          -- itemCnt
    
    self:sendResponse(clientData, 8004, userId, 0, responseBody)
end

-- 发送精灵属性更新通知
-- PetUpdatePropInfo 结构:
-- addition (4字节) - 经验加成百分比 (100 = 100%)
-- petCount (4字节) - 精灵数量
-- UpdatePropInfo[]:
--   catchTime(4) + id(4) + level(4) + exp(4) + currentLvExp(4) + nextLvExp(4)
--   + maxHp(4) + attack(4) + defence(4) + sa(4) + sd(4) + sp(4)
--   + ev_hp(4) + ev_a(4) + ev_d(4) + ev_sa(4) + ev_sd(4) + ev_sp(4)
function LocalGameServer:sendNoteUpdateProp(clientData, userId, userData)
    tprint("\27[36m[LocalGame] 发送 CMD 2508: 精灵属性更新\27[0m")
    
    local petId = userData.currentPetId or 7
    local catchTime = userData.catchId or 0x6969C45E
    local petLevel = 5
    local petDv = 31
    
    -- 计算精灵属性
    local stats = SeerMonsters.calculateStats(petId, petLevel, petDv) or {
        hp = 20, maxHp = 20, attack = 12, defence = 12, spAtk = 11, spDef = 10, speed = 12
    }
    
    -- 战斗获得的经验 (官服新手教程=8)
    local gainedExp = 8
    
    -- 从数据库读取当前等级内的经验
    local currentLevelExp = 0
    if self.userdb then
        local db = self.userdb:new()
        local pet = db:getPetByCatchTime(userId, catchTime)
        if pet then
            currentLevelExp = pet.exp or 0
        end
    end
    
    -- 计算新的当前等级经验
    local newLevelExp = currentLevelExp + gainedExp
    local expInfo = SeerMonsters.getExpInfo(petId, petLevel, newLevelExp)
    
    local responseBody = ""
    
    responseBody = responseBody .. writeUInt32BE(0)          -- addition (无加成)
    responseBody = responseBody .. writeUInt32BE(1)          -- petCount
    
    -- UpdatePropInfo
    responseBody = responseBody .. writeUInt32BE(catchTime)  -- catchTime
    responseBody = responseBody .. writeUInt32BE(petId)      -- id
    responseBody = responseBody .. writeUInt32BE(petLevel)   -- level
    responseBody = responseBody .. writeUInt32BE(gainedExp)  -- exp (本次战斗获得的经验)
    responseBody = responseBody .. writeUInt32BE(expInfo.lvExp)      -- currentLvExp (累计经验)
    responseBody = responseBody .. writeUInt32BE(expInfo.nextLvExp)  -- nextLvExp
    responseBody = responseBody .. writeUInt32BE(stats.maxHp)        -- maxHp
    responseBody = responseBody .. writeUInt32BE(stats.attack)       -- attack
    responseBody = responseBody .. writeUInt32BE(stats.defence)      -- defence
    responseBody = responseBody .. writeUInt32BE(stats.spAtk)        -- sa
    responseBody = responseBody .. writeUInt32BE(stats.spDef)        -- sd
    responseBody = responseBody .. writeUInt32BE(stats.speed)        -- sp
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_hp
    responseBody = responseBody .. writeUInt32BE(1)          -- ev_a (官服=1)
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_d
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sa
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sd
    responseBody = responseBody .. writeUInt32BE(0)          -- ev_sp
    
    self:sendResponse(clientData, 2508, userId, 0, responseBody)
    
    -- 保存精灵经验到数据库
    if self.userdb then
        local db = self.userdb:new()
        local pet = db:getPetByCatchTime(userId, catchTime)
        if pet then
            db:updatePet(userId, catchTime, {
                exp = newLevelExp,
                level = petLevel
            })
            tprint(string.format("\27[32m[LocalGame] 精灵经验已保存: catchTime=0x%08X, exp=%d\27[0m", catchTime, newLevelExp))
        end
    end
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
            nick = tostring(userId),      -- 默认使用米米号，不加前缀
            nickname = tostring(userId),  -- 默认使用米米号，不加前缀
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
            -- 家园系统 - 默认家具
            fitments = {
                {id = 500001, x = 0, y = 0, dir = 0, status = 0}  -- 默认房间风格
            },
            allFitments = {
                {id = 500001, usedCount = 1, allCount = 1}  -- 默认房间风格
            },
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
    local userData = self.users[userId or 0]
    if not userData then return end
    
    -- 如果有 userId 参数，只保存该用户
    if userId then
        if self.userdb then
            local db = self.userdb:new()
            db:saveGameData(userId, userData)
            tprint(string.format("\27[36m[LocalGame] 用户 %d 数据已保存到数据库\27[0m", userId))
        end
    else
        -- 保存所有用户
        if self.userdb then
            local db = self.userdb:new()
            for uid, data in pairs(self.users) do
                db:saveGameData(uid, data)
            end
            tprint("\27[36m[LocalGame] 所有用户数据已保存\27[0m")
        end
    end
end

-- ==================== 新增命令处理器 ====================

-- CMD 1004: 地图热度
-- MapHotInfo: count(4) + [mapId(4) + hotValue(4)]...
function LocalGameServer:handleMapHot(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 1004: 地图热度\27[0m")
    
    -- 返回一些常用地图的热度
    local hotMaps = {
        {1, 5},      -- 新手村
        {5, 5},      -- 克洛斯星
        {4, 5},      -- 赫尔卡星
        {5, 15},     -- 
        {325, 1},    -- 
        {6, 1},      -- 
        {7, 1},      -- 
        {102, 10},   -- 实验室
        {301, 5},    -- 
        {515, 20},   -- 新手教程地图
    }
    
    local responseBody = writeUInt32BE(#hotMaps)
    for _, map in ipairs(hotMaps) do
        responseBody = responseBody .. writeUInt32BE(map[1]) .. writeUInt32BE(map[2])
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 1005: 获取图片地址
-- GetImgAddrInfo: 简单响应
function LocalGameServer:handleGetImageAddress(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 1005: 获取图片地址\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 1102: 金币购买商品
-- MoneyBuyProductInfo: unknown(4) + payMoney(4) + money(4)
function LocalGameServer:handleMoneyBuyProduct(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 1102: 金币购买商品\27[0m")
    
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
    tprint("\27[36m[LocalGame] 处理 CMD 1104: 钻石购买商品\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    local gold = (userData.gold or 0) * 100  -- 转换为分
    
    local responseBody = writeUInt32BE(0) ..       -- unknown
                        writeUInt32BE(0) ..        -- payGold (花费0)
                        writeUInt32BE(gold)        -- 剩余钻石
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2004: 地图怪物列表
function LocalGameServer:handleMapOgreList(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2004: 地图怪物列表\27[0m")
    
    -- 返回空怪物列表
    local responseBody = writeUInt32BE(0)  -- count = 0
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2061: 修改昵称
-- ChangeUserNameInfo: 简单响应
function LocalGameServer:handleChangeNickName(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2061: 修改昵称\27[0m")
    
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
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 修改昵称为: %s\27[0m", userId, newNick))
    
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 2234: 获取每日任务缓存
-- TaskBufInfo: taskId(4) + flag(4) + buf(剩余字节)
function LocalGameServer:handleGetDailyTaskBuf(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2234: 获取每日任务缓存\27[0m")
    
    local responseBody = writeUInt32BE(0) ..  -- taskId
                        writeUInt32BE(0)      -- flag
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2305: 展示精灵
-- PetShowInfo: userID(4) + catchTime(4) + petID(4) + flag(4) + dv(4) + shiny(4) + skinID(4) + ride(4) + padding(8)
function LocalGameServer:handlePetShow(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2305: 展示精灵\27[0m")
    
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
    tprint("\27[36m[LocalGame] 处理 CMD 2306: 治疗精灵\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 2309: 精灵图鉴列表
-- PetBargeListInfo: monCount(4) + [monID(4) + enCntCnt(4) + isCatched(4) + isKilled(4)]...
function LocalGameServer:handlePetBargeList(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2309: 精灵图鉴列表\27[0m")
    
    -- 返回空图鉴列表
    local responseBody = writeUInt32BE(0)  -- monCount = 0
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2406: 使用精灵道具
-- UsePetItemInfo: userID(4) + itemID(4) + userHP(4) + changeHp(4, signed)
function LocalGameServer:handleUsePetItem(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2406: 使用精灵道具\27[0m")
    
    local itemId = 0
    if #body >= 4 then
        itemId = readUInt32BE(body, 1)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 使用道具 %d\27[0m", userId, itemId))
    
    local responseBody = writeUInt32BE(userId) ..  -- userID
                        writeUInt32BE(itemId) ..   -- itemID
                        writeUInt32BE(100) ..      -- userHP (当前HP)
                        writeUInt32BE(50)          -- changeHp (恢复50HP)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2407: 更换精灵
-- ChangePetInfo: userID(4) + petID(4) + petName(16) + level(4) + hp(4) + maxHp(4) + catchTime(4)
function LocalGameServer:handleChangePet(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2407: 更换精灵\27[0m")
    
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
    tprint("\27[36m[LocalGame] 处理 CMD 2409: 捕捉精灵\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    local bossId = userData.currentBossId or 58
    local catchTime = os.time()
    
    local responseBody = writeUInt32BE(catchTime) ..  -- catchTime
                        writeUInt32BE(bossId)         -- petID
    
    tprint(string.format("\27[32m[LocalGame] 用户 %d 捕捉精灵 %d 成功\27[0m", userId, bossId))
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2601: 购买物品
-- BuyItemInfo: 简单响应
function LocalGameServer:handleItemBuy(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2601: 购买物品\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 2604: 更换服装
-- 请求: clothCount(4) + [clothId(4)]...
-- 响应: userID(4) + clothCount(4) + [clothId(4) + clothType(4)]...
-- 需要保存到数据库并广播给同地图其他玩家
function LocalGameServer:handleChangeCloth(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2604: 更换服装\27[0m")
    
    -- 解析请求
    local clothCount = 0
    local clothIds = {}
    
    if #body >= 4 then
        clothCount = readUInt32BE(body, 1)
        for i = 1, clothCount do
            local offset = 5 + (i - 1) * 4
            if #body >= offset + 3 then
                local clothId = readUInt32BE(body, offset)
                table.insert(clothIds, clothId)
            end
        end
    end
    
    tprint(string.format("\27[36m[LocalGame] 更换服装: %d 件\27[0m", #clothIds))
    
    -- 保存到用户数据
    local userData = self:getOrCreateUser(userId)
    -- 保存为 {id, level} 格式以兼容登录响应
    userData.clothes = {}
    for _, clothId in ipairs(clothIds) do
        table.insert(userData.clothes, {id = clothId, level = 1})
    end
    self:saveUserData()
    
    -- 构建响应体
    local responseBody = writeUInt32BE(userId) .. writeUInt32BE(#clothIds)
    for _, clothId in ipairs(clothIds) do
        responseBody = responseBody .. writeUInt32BE(clothId)
        responseBody = responseBody .. writeUInt32BE(1)  -- clothType/level
    end
    
    -- 发送响应给请求者
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
    
    -- 广播给同地图其他玩家
    local currentMapId = OnlineTracker.getPlayerMap(userId)
    if currentMapId > 0 then
        local packet = self:buildPacket(cmdId, userId, 0, responseBody)
        OnlineTracker.broadcastToMap(currentMapId, packet, userId)
        tprint(string.format("\27[32m[LocalGame] 服装变更已广播到地图 %d\27[0m", currentMapId))
    end
end

-- 辅助函数：构建数据包
function LocalGameServer:buildPacket(cmdId, userId, result, body)
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
    
    return header .. body
end

-- CMD 2751: 获取邮件列表
-- MailListInfo: total(4) + count(4) + [SingleMailInfo]...
-- SingleMailInfo: id(4) + template(4) + time(4) + fromID(4) + fromNick(16) + flag(4)
function LocalGameServer:handleMailGetList(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2751: 获取邮件列表\27[0m")
    
    local responseBody = writeUInt32BE(0) ..  -- total
                        writeUInt32BE(0)      -- count = 0
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 8001: 通知
-- InformInfo: type(4) + userID(4) + nick(16) + accept(4) + serverID(4) + mapType(4) + mapID(4) + mapName(64)
function LocalGameServer:handleInform(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 8001: 通知\27[0m")
    
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
-- BossMonsterInfo 结构:
-- bonusID (4字节) - 奖励ID
-- petID (4字节) - 获得的精灵ID (0=无)
-- captureTm (4字节) - 精灵捕获时间
-- itemCount (4字节) - 物品数量
-- [itemID(4) + itemCnt(4)]... - 物品列表
function LocalGameServer:handleGetBossMonster(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 8004: 获取BOSS怪物\27[0m")
    
    local responseBody = ""
    responseBody = responseBody .. writeUInt32BE(0)          -- bonusID
    responseBody = responseBody .. writeUInt32BE(0)          -- petID (无精灵奖励)
    responseBody = responseBody .. writeUInt32BE(0)          -- captureTm
    responseBody = responseBody .. writeUInt32BE(0)          -- itemCount (无物品奖励)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2150: 获取好友/黑名单列表
-- 响应结构: friendCount(4) + [userID(4) + timePoke(4)]... + blackCount(4) + [userID(4)]...
-- 官服新用户: friendCount=0, blackCount=0, body = 8 bytes
-- 官服有好友用户: 根据好友数量返回
function LocalGameServer:handleGetRelationList(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2150: 获取好友/黑名单列表\27[0m")
    
    -- 从数据库获取好友和黑名单
    local friends = {}
    local blacklist = {}
    
    if self.userdb then
        local db = self.userdb:new()
        friends = db:getFriends(userId)
        blacklist = db:getBlacklist(userId)
    end
    
    local responseBody = ""
    
    -- 好友列表
    responseBody = responseBody .. writeUInt32BE(#friends)
    for _, friend in ipairs(friends) do
        responseBody = responseBody .. writeUInt32BE(friend.userID or 0)
        responseBody = responseBody .. writeUInt32BE(friend.timePoke or 0)
    end
    
    -- 黑名单
    responseBody = responseBody .. writeUInt32BE(#blacklist)
    for _, black in ipairs(blacklist) do
        responseBody = responseBody .. writeUInt32BE(black.userID or 0)
    end
    
    tprint(string.format("\27[36m[LocalGame] 好友数: %d, 黑名单数: %d\27[0m", #friends, #blacklist))
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2151: 添加好友请求
-- 请求: targetUserId(4)
-- 响应: result(4) - 0=成功
function LocalGameServer:handleFriendAdd(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2151: 添加好友请求\27[0m")
    
    local targetUserId = 0
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 请求添加好友 %d\27[0m", userId, targetUserId))
    
    local result = 0
    if self.userdb then
        local db = self.userdb:new()
        
        -- 检查目标用户是否存在
        local targetUser = db:findByUserId(targetUserId)
        if not targetUser then
            result = 1  -- 用户不存在
        elseif db:isBlacklisted(targetUserId, userId) then
            result = 2  -- 被对方拉黑
        elseif db:isFriend(userId, targetUserId) then
            result = 3  -- 已经是好友
        else
            -- 直接添加好友（简化处理，跳过请求确认）
            db:addFriend(userId, targetUserId)
            db:addFriend(targetUserId, userId)  -- 双向添加
        end
    end
    
    local responseBody = writeUInt32BE(result)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2152: 回应好友请求
-- 请求: targetUserId(4) + accept(4)
-- 响应: result(4)
function LocalGameServer:handleFriendAnswer(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2152: 回应好友请求\27[0m")
    
    local targetUserId = 0
    local accept = 0
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    if #body >= 8 then
        accept = readUInt32BE(body, 5)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d %s 好友请求 from %d\27[0m", 
        userId, accept == 1 and "接受" or "拒绝", targetUserId))
    
    local result = 0
    if accept == 1 and self.userdb then
        local db = self.userdb:new()
        db:addFriend(userId, targetUserId)
        db:addFriend(targetUserId, userId)
    end
    
    local responseBody = writeUInt32BE(result)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2153: 删除好友
-- 请求: targetUserId(4)
-- 响应: result(4)
function LocalGameServer:handleFriendRemove(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2153: 删除好友\27[0m")
    
    local targetUserId = 0
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 删除好友 %d\27[0m", userId, targetUserId))
    
    local result = 0
    if self.userdb then
        local db = self.userdb:new()
        db:removeFriend(userId, targetUserId)
        db:removeFriend(targetUserId, userId)  -- 双向删除
    end
    
    local responseBody = writeUInt32BE(result)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2154: 添加黑名单
-- 请求: targetUserId(4)
-- 响应: result(4)
function LocalGameServer:handleBlackAdd(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2154: 添加黑名单\27[0m")
    
    local targetUserId = 0
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 拉黑 %d\27[0m", userId, targetUserId))
    
    local result = 0
    if self.userdb then
        local db = self.userdb:new()
        db:addBlacklist(userId, targetUserId)
        -- 同时删除好友关系
        db:removeFriend(userId, targetUserId)
        db:removeFriend(targetUserId, userId)
    end
    
    local responseBody = writeUInt32BE(result)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2155: 移除黑名单
-- 请求: targetUserId(4)
-- 响应: result(4)
function LocalGameServer:handleBlackRemove(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2155: 移除黑名单\27[0m")
    
    local targetUserId = 0
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 移除黑名单 %d\27[0m", userId, targetUserId))
    
    local result = 0
    if self.userdb then
        local db = self.userdb:new()
        db:removeBlacklist(userId, targetUserId)
    end
    
    local responseBody = writeUInt32BE(result)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 70001: 获取兑换信息 (GET_EXCHANGE_INFO)
-- 用于荣誉兑换手册，记录玩家已兑换的物品数量
-- 响应结构: count(4) + [exchangeID(4) + exchangeNum(4)]...
-- 官服新用户: count=0, body = 4 bytes
-- 官服有记录用户: 根据兑换记录数量返回
function LocalGameServer:handleCmd70001(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 70001: 获取兑换信息 (荣誉兑换手册)\27[0m")
    
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
-- 官服主动发送心跳，客户端收到后回复相同命令
-- 间隔约6秒，用于保持连接活跃和检测断线
function LocalGameServer:handleNieoHeart(clientData, cmdId, userId, seqId, body)
    -- 客户端回复的心跳包，不需要再回复
    -- 只记录收到心跳响应（可选）
end

-- 启动心跳定时器 (官服间隔约6秒)
function LocalGameServer:startHeartbeat(clientData, userId)
    local timer = require('timer')
    
    -- 如果已有定时器，先清理
    if clientData.heartbeatTimer then
        timer.clearInterval(clientData.heartbeatTimer)
    end
    
    -- 每6秒发送一次心跳包
    clientData.heartbeatTimer = timer.setInterval(6000, function()
        if clientData.socket and clientData.loggedIn then
            self:sendHeartbeat(clientData, userId)
        else
            -- 连接已断开，清理定时器
            if clientData.heartbeatTimer then
                timer.clearInterval(clientData.heartbeatTimer)
                clientData.heartbeatTimer = nil
            end
        end
    end)
end

-- 发送心跳包
function LocalGameServer:sendHeartbeat(clientData, userId)
    local cmdId = 80008  -- NIEO_HEART
    local length = 17    -- 只有包头，没有数据体
    
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
        0, 0, 0, 0  -- result = 0
    )
    
    pcall(function()
        clientData.socket:write(header)
    end)
end

-- ==================== 家园系统 ====================

-- CMD 10001: 家园登录 (ROOM_LOGIN)
-- 注意: 此命令由房间服务器处理，游戏服务器只保留壳
-- 请求: targetUserId(4) + session(24) + catchTime(4) + flag(4) + mapId(4) + x(4) + y(4)
function LocalGameServer:handleRoomLogin(clientData, cmdId, userId, seqId, body)
    tprint("\27[33m[LocalGame] CMD 10001: 家园登录 - 此命令应由房间服务器处理\27[0m")
    -- 房间服务器会处理此命令，游戏服务器不做任何处理
end

-- CMD 10002: 获取房间地址 (GET_ROOM_ADDRES)
-- 请求: targetUserId(4)
-- 响应: session(24) + ip(4) + port(2)
-- 客户端会用这个地址连接房间服务器
function LocalGameServer:handleGetRoomAddress(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 10002: 获取房间地址\27[0m")
    
    local targetUserId = userId
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 请求房间地址 (目标: %d)\27[0m", userId, targetUserId))
    
    -- 响应格式: session(24) + ip(4) + port(2) = 30 字节
    -- session 可以包含 targetUserId 作为前 4 字节
    local responseBody = writeUInt32BE(targetUserId)  -- session 前 4 字节 = targetUserId
    responseBody = responseBody .. string.rep("\0", 20)  -- session 剩余 20 字节
    
    -- IP 地址 (127.0.0.1 = 0x7F000001)
    responseBody = responseBody .. string.char(127, 0, 0, 1)
    
    -- 端口号 (使用房间服务器端口)
    local port = conf.roomserver_port or 5100
    responseBody = responseBody .. writeUInt16BE(port)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
    tprint(string.format("\27[32m[LocalGame] → GET_ROOM_ADDRES: 127.0.0.1:%d\27[0m", port))
end

-- CMD 10003: 离开房间 (LEAVE_ROOM)
-- 请求: flag(4) + mapID(4) + catchTime(4) + changeShape(4) + actionType(4)
function LocalGameServer:handleLeaveRoom(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 10003: 离开房间\27[0m")
    
    local flag = 0
    local mapID = 515
    local catchTime = 0
    local changeShape = 0
    local actionType = 0
    
    if #body >= 4 then flag = readUInt32BE(body, 1) end
    if #body >= 8 then mapID = readUInt32BE(body, 5) end
    if #body >= 12 then catchTime = readUInt32BE(body, 9) end
    if #body >= 16 then changeShape = readUInt32BE(body, 13) end
    if #body >= 20 then actionType = readUInt32BE(body, 17) end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 离开房间，返回地图 %d\27[0m", userId, mapID))
    
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 10006: 正在使用的家具 (FITMENT_USERING)
-- 游戏服务器处理此命令，返回用户正在使用的家具列表
-- 请求: targetUserId(4)
-- 响应: ownerUserId(4) + visitorUserId(4) + count(4) + [FitmentInfo]...
-- FitmentInfo: id(4) + x(4) + y(4) + dir(4) + status(4) = 20 bytes
function LocalGameServer:handleFitmentUsering(clientData, cmdId, userId, seqId, body)
    local targetUserId = userId
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    tprint(string.format("\27[36m[LocalGame] 处理 CMD 10006: 获取用户 %d 正在使用的家具\27[0m", targetUserId))
    
    -- 从数据库获取家具数据
    local fitments = {}
    if self.userdb then
        local db = self.userdb:new()
        local gameData = db:getOrCreateGameData(targetUserId)
        fitments = gameData.fitments or {}
    end
    
    local responseBody = writeUInt32BE(targetUserId)  -- ownerUserId
    responseBody = responseBody .. writeUInt32BE(userId)  -- visitorUserId
    responseBody = responseBody .. writeUInt32BE(#fitments)  -- count
    
    -- 写入每个家具信息
    for _, fitment in ipairs(fitments) do
        responseBody = responseBody .. writeUInt32BE(fitment.id or 500001)  -- id
        responseBody = responseBody .. writeUInt32BE(fitment.x or 0)        -- x
        responseBody = responseBody .. writeUInt32BE(fitment.y or 0)        -- y
        responseBody = responseBody .. writeUInt32BE(fitment.dir or 0)      -- dir
        responseBody = responseBody .. writeUInt32BE(fitment.status or 0)   -- status
    end
    
    tprint(string.format("\27[32m[LocalGame] → FITMENT_USERING: %d 个家具\27[0m", #fitments))
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 10007: 所有家具 (FITMENT_ALL)
-- 注意: 此命令由房间服务器处理，游戏服务器只保留壳
-- 响应: count(4) + [FitmentInfo]...
function LocalGameServer:handleFitmentAll(clientData, cmdId, userId, seqId, body)
    tprint("\27[33m[LocalGame] CMD 10007: 所有家具 - 此命令应由房间服务器处理\27[0m")
    -- 房间服务器会处理此命令，游戏服务器不做任何处理
end

-- CMD 10008: 设置家具 (SET_FITMENT)
-- 注意: 此命令由房间服务器处理，游戏服务器只保留壳
-- 请求: roomId(4) + count(4) + [id(4) + x(4) + y(4) + dir(4) + status(4)]...
function LocalGameServer:handleSetFitment(clientData, cmdId, userId, seqId, body)
    tprint("\27[33m[LocalGame] CMD 10008: 设置家具 - 此命令应由房间服务器处理\27[0m")
    -- 房间服务器会处理此命令，游戏服务器不做任何处理
end

return {LocalGameServer = LocalGameServer}
