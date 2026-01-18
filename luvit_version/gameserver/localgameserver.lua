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

-- 加载精灵数据 (Pets via SeerPets)
-- SeerMonsters logic moved to SeerPets/SeerSkills
-- local SeerMonsters = require('../seer_monsters')
-- if SeerMonsters.load then SeerMonsters.load() end

local SeerPets = require('../seer_pets')
if SeerPets.load then SeerPets.load() end

-- 加载技能数据
local SeerSkills = require('../seer_skills')

-- 加载物品数据
local SeerItems = require('../seer_items')
if SeerItems.load then SeerItems.load() end

-- 加载技能效果数据
local SeerSkillEffects = require('../seer_skill_effects')
if SeerSkillEffects.load then SeerSkillEffects.load() end

-- 加载战斗系统
local SeerBattle = require('../seer_battle')

-- 加载协议验证器
local ProtocolValidator = require('../protocol_validator')

-- 加载在线追踪模块
local OnlineTracker = require('../handlers/online_tracker')

-- ==================== 全局处理器注册系统 ====================
-- 处理器模块可以注册到这里,由 handleCommand 统一调用
local GlobalHandlers = {}
local GlobalHandlerRegistry = {
    handlers = {},  -- cmdId -> handler function
    register = function(cmdId, handler)
        GlobalHandlers[cmdId] = handler
    end
}

-- 加载所有处理器模块
local handlerModules = {
    '../handlers/nono_handlers',
    '../handlers/pet_handlers',
    '../handlers/pet_advanced_handlers',
    '../handlers/task_handlers',
    '../handlers/fight_handlers',
    '../handlers/item_handlers',
    '../handlers/friend_handlers',
    '../handlers/mail_handlers',
    '../handlers/map_handlers',
    '../handlers/room_handlers',
    '../handlers/team_handlers',
    '../handlers/teampk_handlers',
    '../handlers/arena_handlers',
    '../handlers/exchange_handlers',
    '../handlers/game_handlers',
    '../handlers/misc_handlers',
    '../handlers/special_handlers',
    '../handlers/system_handlers',
    '../handlers/teacher_handlers',
    '../handlers/work_handlers',
    '../handlers/xin_handlers',
}

for _, modulePath in ipairs(handlerModules) do
    local ok, module = pcall(require, modulePath)
    if ok and module and module.register then
        module.register(GlobalHandlerRegistry)
        tprint(string.format("\27[36m[LocalGame] 已加载处理器模块: %s\27[0m", modulePath))
    elseif not ok then
        tprint(string.format("\27[33m[LocalGame] 加载处理器模块失败: %s - %s\27[0m", modulePath, tostring(module)))
    end
end

tprint(string.format("\27[32m[LocalGame] 共注册 %d 个全局命令处理器\27[0m", (function() local n=0 for _ in pairs(GlobalHandlers) do n=n+1 end return n end)()))

-- 加载配置
local GameConfig = require('../game_config')
local SeerLoginResponse = require('./seer_login_response')
local SeerTaskConfig = require('../data/seer_task_config')

local function getCmdName(cmdId)
    return SeerCommands.getName(cmdId)
end

-- 数据包结构:
-- 17 字节头部: length(4) + version(1) + cmdId(4) + userId(4) + result(4)
-- 然后是数据体

-- 辅助函数：获取配置值 (可能是常量也可能是函数)
local function getConfigValue(val)
    if type(val) == "function" then
        return val()
    end
    return val
end

function LocalGameServer:new()
    local obj = {
        port = conf.gameserver_port or 5000,
        clients = {},
        sessions = {},  -- session -> user data
        users = {},     -- userId -> user data
        serverList = {},
        nextSeqId = 1,
        cryptoMap = {}, -- map<client, crypto>
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

-- 构建处理器上下文 (供模块处理器使用)
-- 处理器模块使用 ctx 对象访问服务器功能
function LocalGameServer:buildHandlerContext(clientData, cmdId, userId, seqId, body)
    local self_ref = self
    local ctx = {
        userId = userId,
        cmdId = cmdId,
        seqId = seqId,
        body = body,
        clientData = clientData,
        
        -- 发送响应
        sendResponse = function(packet)
            local ok, err = pcall(function()
                clientData.socket:write(packet)
            end)
            if ok then
                tprint(string.format("\27[32m[GlobalHandler] 发送响应 %d bytes 到客户端\27[0m", #packet))
            else
                tprint(string.format("\27[31m[GlobalHandler] 发送响应失败: %s\27[0m", tostring(err)))
            end
        end,
        
        -- 获取或创建用户
        getOrCreateUser = function(uid)
            return self_ref:getOrCreateUser(uid or userId)
        end,
        
        -- 保存用户数据
        saveUser = function(uid, userData)
            if self_ref.userdb then
                local db = self_ref.userdb:new()
                db:saveGameData(uid or userId, userData)
            end
        end,
        
        -- 保存用户数据库 (整体)
        saveUserDB = function()
            if self_ref.userdb then
                local db = self_ref.userdb:new()
                local user = self_ref:getOrCreateUser(userId)
                db:saveGameData(userId, user)
            end
        end,
        
        -- 广播到同地图玩家
        broadcastToMap = function(packet, excludeUserId)
            -- 获取同地图的其他玩家
            for _, otherClient in ipairs(self_ref.clients) do
                if otherClient.userId ~= excludeUserId then
                    local otherUser = self_ref.users[otherClient.userId]
                    local thisUser = self_ref.users[userId]
                    if otherUser and thisUser and otherUser.mapId == thisUser.mapId then
                        pcall(function()
                            otherClient.socket:write(packet)
                        end)
                    end
                end
            end
        end,
        
        -- 在线追踪器
        onlineTracker = OnlineTracker,
        
        -- 用户数据库引用
        userDB = self_ref.userdb and self_ref.userdb:new() or nil,
    }
    return ctx
end

-- 获取本地处理器表（供 handleCommand 和 handleCommandDirect 共用）
function LocalGameServer:getLocalHandlers()
    return {
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
        [2306] = self.handlePetCure,           -- 精灵恢复
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
        [2606] = self.handleMultiItemBuy,      -- 批量购买物品
        [2751] = self.handleMailGetList,       -- 获取邮件列表
        [2757] = self.handleMailGetUnread,     -- 获取未读邮件
        [8001] = self.handleInform,            -- 通知
        [8004] = self.handleGetBossMonster,    -- 获取BOSS怪物
        [9003] = self.handleNonoInfo,          -- NoNo信息
        -- 家园系统
        [10001] = self.handleRoomLogin,        -- 家园登录
        [10002] = self.handleGetRoomAddress,   -- 获取房间地址
        [10003] = self.handleLeaveRoom,        -- 离开房间
        [10006] = self.handleFitmentUsering,   -- 正在使用的家具
        [10007] = self.handleFitmentAll,       -- 所有家具
        [10008] = self.handleSetFitment,       -- 设置家具
        [50004] = self.handleCmd50004,         -- 客户端信息上报
        [50008] = self.handleCmd50008,         -- 获取四倍经验时间
        [70001] = self.handleCmd70001,         -- 兑换信息
        [80008] = self.handleNieoHeart,        -- 心跳包
    }
end

function LocalGameServer:handleCommand(clientData, cmdId, userId, seqId, body)
    local localHandlers = self:getLocalHandlers()
    
    -- 优先使用本地处理器 (直接方法)
    local handler = localHandlers[cmdId]
    if handler then
        handler(self, clientData, cmdId, userId, seqId, body)
        return
    end
    
    -- 尝试全局处理器 (模块处理器,需要 ctx 上下文)
    local globalHandler = GlobalHandlers[cmdId]
    if globalHandler then
        local ctx = self:buildHandlerContext(clientData, cmdId, userId, seqId, body)
        local ok, err = pcall(globalHandler, ctx)
        if not ok then
            tprint(string.format("\27[31m[LocalGame] 全局处理器错误 CMD=%d: %s\27[0m", cmdId, tostring(err)))
        end
        return
    end
    
    -- 未实现的命令
    tprint(string.format("\27[33m[LocalGame] 未实现的命令: %d (%s)\27[0m", cmdId, getCmdName(cmdId)))
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- 直接处理命令（供 RoomServer 调用，实现命令处理器共享）
-- 返回 true 表示命令已处理，false 表示未找到处理器
function LocalGameServer:handleCommandDirect(clientData, cmdId, userId, seqId, body)
    local localHandlers = self:getLocalHandlers()
    
    -- 检查是否有本地处理器
    local handler = localHandlers[cmdId]
    if handler then
        handler(self, clientData, cmdId, userId, seqId, body)
        return true
    end
    
    -- 尝试全局处理器 (模块处理器)
    local globalHandler = GlobalHandlers[cmdId]
    if globalHandler then
        local ctx = self:buildHandlerContext(clientData, cmdId, userId, seqId, body)
        local ok, err = pcall(globalHandler, ctx)
        if not ok then
            tprint(string.format("\27[31m[LocalGame] 全局处理器错误 CMD=%d: %s\27[0m", cmdId, tostring(err)))
        end
        return true
    end
    
    -- 未找到处理器
    return false
end

-- 构建响应数据包
function LocalGameServer:sendResponse(clientData, cmdId, userId, result, body)
    body = body or ""
    
    -- 验证包体大小
    local isValid, expectedSize, actualSize, message = ProtocolValidator.validate(cmdId, body)
    if not isValid then
        tprint(string.format("\27[31m%s\27[0m", message))
    elseif not shouldHideCmd(cmdId) then
        tprint(string.format("\27[32m%s\27[0m", message))
    end
    
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
        
        -- 详细包体输出 (完整十六进制)
        if #body > 0 then
            tprint(string.format("\27[36m[PACKET] CMD=%d 包体详情 (%d bytes):\27[0m", cmdId, #body))
            
            -- 十六进制格式输出 (每行16字节)
            local hexLines = {}
            for i = 1, #body, 16 do
                local hexPart = ""
                local asciiPart = ""
                for j = i, math.min(i + 15, #body) do
                    local byte = body:byte(j)
                    hexPart = hexPart .. string.format("%02X ", byte)
                    if byte >= 32 and byte < 127 then
                        asciiPart = asciiPart .. string.char(byte)
                    else
                        asciiPart = asciiPart .. "."
                    end
                end
                -- 补齐不足16字节的行
                local padding = 16 - ((#body - i + 1) < 16 and (#body - i + 1) or 16)
                hexPart = hexPart .. string.rep("   ", padding)
                
                table.insert(hexLines, string.format("  %04X: %s |%s|", i - 1, hexPart, asciiPart))
            end
            
            for _, line in ipairs(hexLines) do
                tprint(string.format("\27[90m%s\27[0m", line))
            end
            tprint(string.format("\27[36m[PACKET] --- 包体结束 ---\27[0m"))
        end
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
local SeerLoginResponse = require("./seer_login_response")

-- 响应结构完全按照 UserInfo.setForLoginInfo 解析顺序
-- 所有数据从用户数据读取
function LocalGameServer:handleLoginIn(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 1001: 登录游戏服务器\27[0m")
    
    -- 从 body 中提取 session (如果有)
    local session = ""
    if #body >= 16 then
        session = body:sub(1, 16)
    end
    clientData.session = session
    
    -- 获取完整用户数据 (账号 + 游戏数据)
    local user = {}
    if self.userdb then
        local db = self.userdb:new()
        
        -- 1. 账号数据 (Account)
        local account = db:findByUserId(userId)
        if account then
            for k, v in pairs(account) do user[k] = v end
        end
        
        -- 2. 游戏数据 (GameData)
        local gameData = db:getOrCreateGameData(userId)
        if gameData then
            for k, v in pairs(gameData) do user[k] = v end
            -- 调试: 打印任务数据
            if gameData.tasks then
                local taskCount = 0
                for _ in pairs(gameData.tasks) do taskCount = taskCount + 1 end
                print(string.format("\27[35m[LOGIN] 从数据库加载了 %d 个任务\27[0m", taskCount))
            else
                print("\27[33m[LOGIN] 警告: gameData.tasks 为 nil\27[0m")
            end
        end
    end
    
    -- 确保基本字段存在
    user.userid = userId
    user.nick = user.nick or user.nickname or ("Seer" .. userId)
    user.coins = user.coins or 99999
    user.coins = user.coins or 99999
    user.mapID = user.mapID or GameConfig.InitialPlayer.mapID or 1
    user.energy = user.energy or 100000 -- Ensure high energy to prevent "Power Depleted"
    
    -- 生成完整响应
    local responseBody, keySeed = SeerLoginResponse.makeLoginResponse(user)
    
    -- 更新密钥
    if self.cryptoMap[clientData] then
        local crypto = self.cryptoMap[clientData]
        crypto:setKey(keySeed)
        tprint(string.format("\27[32m[LocalGame] 密钥已更新: userId=%d, keySeed=%d\27[0m", userId, keySeed))
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
    
    -- 标记已登录并启动心跳
    clientData.loggedIn = true
    self:startHeartbeat(clientData, userId)
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
-- 响应格式 (根据 UserInfo.setForMoreInfo):
-- userID(4) + nick(16) + regTime(4) + petAllNum(4) + petMaxLev(4) + 
-- bossAchievement(200) + graduationCount(4) + monKingWin(4) + messWin(4) + 
-- maxStage(4) + maxArenaWins(4) + curTitle(4) = 256 bytes
function LocalGameServer:handleGetMoreUserInfo(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2052: 获取详细用户信息\27[0m")
    
    local targetUserId = userId
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    local userData = self:getOrCreateUser(targetUserId)
    local nickname = userData.nick or userData.nickname or userData.username or tostring(targetUserId)
    
    local responseBody = ""
    responseBody = responseBody .. writeUInt32BE(targetUserId)                      -- userID (4)
    responseBody = responseBody .. writeFixedString(nickname, 16)                   -- nick (16)
    responseBody = responseBody .. writeUInt32BE(userData.regTime or os.time())     -- regTime (4)
    local ach = userData.achievements or {total=0, rank=0, list={}}
    
    responseBody = responseBody .. writeUInt32BE(userData.petAllNum or 0)           -- petAllNum (4)
    responseBody = responseBody .. writeUInt32BE(userData.petMaxLev or 100)         -- petMaxLev (4)
    -- bossAchievement: 200 bytes
    -- TODO: Convert ach.list to 200 bytes bitmap if needed, or just 0s for now
    responseBody = responseBody .. string.rep("\0", 200)                            -- bossAchievement (200)
    responseBody = responseBody .. writeUInt32BE(userData.graduationCount or 0)     -- graduationCount (4)
    responseBody = responseBody .. writeUInt32BE(ach.total or 0)                    -- monKingWin (reused as achievement total?) - Wait, monKingWin is simple field
    -- Official fields:
    -- monKingWin (4)
    -- messWin (4)
    -- maxStage (4)
    -- maxArenaWins (4)
    -- curTitle (4)
    responseBody = responseBody .. writeUInt32BE(userData.monKingWin or 0)          -- monKingWin (4)
    responseBody = responseBody .. writeUInt32BE(userData.messWin or 0)             -- messWin (4)
    responseBody = responseBody .. writeUInt32BE(userData.maxStage or 0)            -- maxStage (4)
    responseBody = responseBody .. writeUInt32BE(userData.maxArenaWins or 0)        -- maxArenaWins (4)
    responseBody = responseBody .. writeUInt32BE(userData.curTitle or 0)            -- curTitle (4)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2101: 人物移动
-- 请求格式: walkType(4) + x(4) + y(4) + amfLen(4) + amfData...
-- CMD 2101: 人物移动
-- 请求格式: walkType(4) + x(4) + y(4) + amfLen(4) + amfData...
-- 响应格式: walkType(4) + userId(4) + x(4) + y(4) + amfData... (注意：没有 amfLen 字段)
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
    
    -- 构建响应 (不包含 amfLen，直接拼接 amfData)
    local responseBody = writeUInt32BE(walkType) ..
                writeUInt32BE(userId) ..
                writeUInt32BE(x) ..
                writeUInt32BE(y) ..
                amfData  -- 直接拼接路径数据，不包含长度字段
    
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
        
        -- 检查任务是否已经完成，如果已完成则不允许重新接受
        local existingTask = gameData.tasks[tostring(taskId)]
        if existingTask and existingTask.status == "completed" then
            tprint(string.format("\27[33m[LocalGame] 任务 %d 已完成，拒绝重新接受\27[0m", taskId))
            -- 仍然返回成功响应，但不修改数据库
            local responseBody = writeUInt32BE(taskId)
            self:sendResponse(clientData, cmdId, userId, 0, responseBody)
            return
        end
        
        -- 如果任务未完成或不存在，则接受任务
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
    
    local taskConfig = SeerTaskConfig.get(taskId)
    local userData = self:getOrCreateUser(userId)
    local db = self.userdb and self.userdb:new()
    
    local responseParts = {}
    local rewardPetId = 0
    local rewardCaptureTm = 0
    local rewardItems = {}
    local shouldGiveRewards = true
    
    -- 检查任务是否已经完成过
    if db then
        local gameData = db:getOrCreateGameData(userId)
        gameData.tasks = gameData.tasks or {}
        local existingTask = gameData.tasks[tostring(taskId)]
        
        if existingTask and existingTask.status == "completed" then
            tprint(string.format("\27[33m[LocalGame] 任务 %d 已完成过，不再发放奖励\27[0m", taskId))
            shouldGiveRewards = false
        end
    end
    
    -- 只有首次完成才发放奖励
    if shouldGiveRewards and taskConfig then
        -- 1. 精灵奖励 (特殊处理 Task 86)
        if taskConfig.type == "select_pet" and taskConfig.paramMap then
            local petId = taskConfig.paramMap[param] or 1
            local catchTime = os.time()
            userData.currentPetId = petId
            userData.catchId = 0x6969C400 
            
            rewardPetId = petId
            rewardCaptureTm = 0x6969C400
            tprint(string.format("\27[32m[LocalGame] 发放精灵奖励: petId=%d\27[0m", petId))
        end
        
        -- 2. 物品奖励
        if taskConfig.rewards and taskConfig.rewards.items then
            for _, item in ipairs(taskConfig.rewards.items) do
                table.insert(rewardItems, item)
                if db then
                    db:addItem(userId, item.id, item.count)
                    tprint(string.format("\27[32m[LocalGame] 发放物品奖励: itemId=%d, count=%d\27[0m", item.id, item.count))
                end
            end
        end
        
        -- 3. 金币奖励
        if taskConfig.rewards and taskConfig.rewards.coins then
            if db then
                local gameData = db:getOrCreateGameData(userId)
                gameData.coins = (gameData.coins or 0) + taskConfig.rewards.coins
                db:saveGameData(userId, gameData)
                tprint(string.format("\27[32m[LocalGame] 发放金币奖励: %d\27[0m", taskConfig.rewards.coins))
            end
            table.insert(rewardItems, {id=1, count=taskConfig.rewards.coins})
        end
        
        -- 4. 特殊奖励
        if taskConfig.rewards and taskConfig.rewards.special then
             for _, sp in ipairs(taskConfig.rewards.special) do
                 table.insert(rewardItems, {id=sp.type, count=sp.value})
                 tprint(string.format("\27[32m[LocalGame] 发放特殊奖励: type=%d, value=%d\27[0m", sp.type, sp.value))
             end
        end
    end
    
    -- 构建响应体 (NoviceFinishInfo)
    local responseBody = writeUInt32BE(taskId) ..
                         writeUInt32BE(rewardPetId) ..
                         writeUInt32BE(rewardCaptureTm) ..
                         writeUInt32BE(#rewardItems)
                         
    for _, item in ipairs(rewardItems) do
        responseBody = responseBody .. writeUInt32BE(item.id) .. writeUInt32BE(item.count)
    end
    
    -- 保存任务完成状态到数据库
    if db then
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
    local petLevel = getConfigValue(GameConfig.PetDefaults.level) or 5
    local petExp = 0
    local petDv = getConfigValue(GameConfig.PetDefaults.dv) or 31
    local petNature = getConfigValue(GameConfig.PetDefaults.nature) or 0
    
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
    local stats = SeerPets.getStats(petId, petLevel, petDv) or {
        hp = 100, maxHp = 100, attack = 39, defence = 35, spAtk = 78, spDef = 36, speed = 39
    }
    
    -- 获取精灵技能
    local skills = SeerPets.getSkillsForLevel(petId, petLevel) or {}
    local skillCount = math.min(#skills, 4)
    
    -- 计算经验信息
    local expInfo = SeerPets.getExpInfo(petId, petLevel, petExp)
    
    local responseBody = ""
    
    -- PetInfo (完整版)
    responseBody = responseBody .. writeUInt32BE(petId)      -- id
    responseBody = responseBody .. writeFixedString(SeerPets.getName(petId), 16)  -- name
    responseBody = responseBody .. writeUInt32BE(petDv)      -- dv (个体值)
    responseBody = responseBody .. writeUInt32BE(petNature)  -- nature (性格)
    responseBody = responseBody .. writeUInt32BE(petLevel)   -- level
    responseBody = responseBody .. writeUInt32BE(petExp)     -- exp (总经验)
    responseBody = responseBody .. writeUInt32BE(expInfo.currentLevelExp or 0)      -- lvExp (当前等级已获经验)
    responseBody = responseBody .. writeUInt32BE(expInfo.nextLevelExp or 100)  -- nextLvExp (升级所需经验)
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
    
    -- 计算实际技能数量（官服格式）
    local actualSkillCount = 0
    for i = 1, 4 do
        local skillId = skills[i] or 0
        if type(skillId) == "table" then
            skillId = skillId.id or 0
        end
        if skillId ~= 0 then
            actualSkillCount = actualSkillCount + 1
        end
    end
    responseBody = responseBody .. writeUInt32BE(actualSkillCount)  -- skillNum (实际技能数量)
    
    -- 4个技能槽 (id + pp) - 使用技能的默认PP值
    for i = 1, 4 do
        local skillId = skills[i] or 0
        if type(skillId) == "table" then
            skillId = skillId.id or 0
        end
        -- 获取技能的默认PP值
        local skillPP = 0
        if skillId ~= 0 then
            local skillInfo = SeerSkills.get(skillId)
            skillPP = (skillInfo and skillInfo.pp) or 30
        end
        responseBody = responseBody .. writeUInt32BE(skillId) .. writeUInt32BE(skillPP)
    end
    
    responseBody = responseBody .. writeUInt32BE(catchId)    -- catchTime
    responseBody = responseBody .. writeUInt32BE(0)          -- catchMap (官服为0)
    responseBody = responseBody .. writeUInt32BE(0)          -- catchRect
    responseBody = responseBody .. writeUInt32BE(0)          -- catchLevel (官服为0)
    -- effectCount (2字节) + effectList (如果有)
    responseBody = responseBody .. writeUInt16BE(0)          -- effectCount
    -- 注意: 客户端 PetInfo.as 在 effectCount 之后直接读取 skinID，没有 peteffect/shiny/freeForbidden/boss 字段
    responseBody = responseBody .. writeUInt32BE(0)          -- skinID
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
    tprint(string.format("\27[32m[LocalGame] → GET_PET_INFO catchId=0x%08X petId=%d level=%d\27[0m", catchId, petId, petLevel))
end

-- CMD 2303: 获取精灵列表
-- CMD 2303: 获取精灵列表
-- 响应格式: petCount(4) + [PetListInfo * petCount]
-- PetListInfo: id(4) + catchTime(4) + skinID(4) = 12 bytes
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
            local catchTime = pet.catchTime or os.time()
            local skinID = pet.skinID or 0
            
            -- PetListInfo: id(4) + catchTime(4) + skinID(4)
            petData = petData ..
                writeUInt32BE(petId) ..
                writeUInt32BE(catchTime) ..
                writeUInt32BE(skinID)
            
            tprint(string.format("\27[36m[LocalGame] 返回精灵: id=%d, catchTime=%d, skinID=%d\27[0m", 
                petId, catchTime, skinID))
        end
    end
    
    local responseBody = writeUInt32BE(petCount) .. petData
    tprint(string.format("\27[32m[LocalGame] 返回 %d 只精灵\27[0m", petCount))
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

-- CMD 9003: 获取 NoNo 信息
-- NonoInfo 结构 (86 bytes body):
-- userID(4) + flag(4) + state(4) + nick(16) + superNono(4) + color(4) + 
-- power(4) + mate(4) + iq(4) + ai(2) + birth(4) + chargeTime(4) + 
-- func(20) + superEnergy(4) + superLevel(4) + superStage(4)
function LocalGameServer:handleNonoInfo(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 9003: 获取NoNo信息\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    
    -- 从 game_config 获取默认 NONO 配置
    local nonoDefaults = GameConfig.InitialPlayer.nono or {}
    
    -- 确保用户有 nono 数据 (所有字段从配置读取)
    if not userData.nono then
        userData.nono = {
            -- 基础状态
            hasNono = nonoDefaults.hasNono or 1,
            flag = nonoDefaults.flag or 1,
            state = nonoDefaults.state or 0,
            nick = nonoDefaults.nick or "NoNo",
            color = nonoDefaults.color or 0xFFFFFF,
            
            -- VIP/超能NoNo
            superNono = nonoDefaults.superNono or 0,
            vipLevel = nonoDefaults.vipLevel or 0,
            vipStage = nonoDefaults.vipStage or 0,
            vipValue = nonoDefaults.vipValue or 0,
            autoCharge = nonoDefaults.autoCharge or 0,
            vipEndTime = nonoDefaults.vipEndTime or 0,
            freshManBonus = nonoDefaults.freshManBonus or 0,
            
            -- 超能属性
            superEnergy = nonoDefaults.superEnergy or 0,
            superLevel = nonoDefaults.superLevel or 0,
            superStage = nonoDefaults.superStage or 0,
            
            -- NoNo属性值
            power = nonoDefaults.power or 10000,
            mate = nonoDefaults.mate or 10000,
            iq = nonoDefaults.iq or 0,
            ai = nonoDefaults.ai or 0,
            hp = nonoDefaults.hp or 100000,
            maxHp = nonoDefaults.maxHp or 100000,
            energy = nonoDefaults.energy or 100,
            
            -- 时间相关
            birth = (nonoDefaults.birth == 0) and os.time() or (nonoDefaults.birth or os.time()),
            chargeTime = nonoDefaults.chargeTime or 500,
            expire = nonoDefaults.expire or 0,
            
            -- 其他
            chip = nonoDefaults.chip or 0,
            grow = nonoDefaults.grow or 0,
            isFollowing = nonoDefaults.isFollowing or false
        }
    end
    
    local nono = userData.nono
    
    local responseBody = ""
    responseBody = responseBody .. writeUInt32BE(userId)                        -- userID
    responseBody = responseBody .. writeUInt32BE(nono.flag or 1)                -- flag
    responseBody = responseBody .. writeUInt32BE(nono.state or 0)               -- state
    responseBody = responseBody .. writeFixedString(nono.nick or "NoNo", 16)    -- nick
    responseBody = responseBody .. writeUInt32BE(nono.superNono or 0)           -- superNono
    responseBody = responseBody .. writeUInt32BE(nono.color or 0xFFFFFF)        -- color
    responseBody = responseBody .. writeUInt32BE(nono.power or 10000)           -- power
    responseBody = responseBody .. writeUInt32BE(nono.mate or 10000)            -- mate
    responseBody = responseBody .. writeUInt32BE(nono.iq or 0)                  -- iq
    responseBody = responseBody .. writeUInt16BE(nono.ai or 0)                  -- ai
    responseBody = responseBody .. writeUInt32BE(nono.birth or os.time())       -- birth
    responseBody = responseBody .. writeUInt32BE(nono.chargeTime or 500)        -- chargeTime
    responseBody = responseBody .. string.rep("\xFF", 20)                       -- func (所有功能开启)
    responseBody = responseBody .. writeUInt32BE(nono.superEnergy or 0)         -- superEnergy
    responseBody = responseBody .. writeUInt32BE(nono.superLevel or 0)          -- superLevel
    responseBody = responseBody .. writeUInt32BE(nono.superStage or 0)          -- superStage
    
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
        
        -- PeopleInfo 结构 (参照官服格式，包含 sysTime)
        responseBody = responseBody .. writeUInt32BE(os.time())                     -- sysTime (官服格式必须)
        responseBody = responseBody .. writeUInt32BE(playerId)                      -- userID
        responseBody = responseBody .. writeFixedString(nickname, 16)               -- nick (16字节)
        responseBody = responseBody .. writeUInt32BE(playerData.color or 0xFFFFFF)  -- color
        responseBody = responseBody .. writeUInt32BE(playerData.texture or 0)       -- texture
        
        -- vipFlags
        local vipFlags = 0
        if playerData.vip then vipFlags = vipFlags + 1 end
        if playerData.viped then vipFlags = vipFlags + 2 end
        responseBody = responseBody .. writeUInt32BE(vipFlags)                      -- vipFlags
        responseBody = responseBody .. writeUInt32BE(playerData.vipStage or 0)      -- vipStage
        
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
    local stats = SeerPets.getStats(petId, petLevel, petDv) or {hp = 20, maxHp = 20}
    local skills = SeerPets.getSkillsForLevel(petId, petLevel)
    local skillCount = 0
    for _, s in ipairs(skills) do
        if s > 0 then skillCount = skillCount + 1 end
    end
    
    -- 计算经验信息
    -- 新精灵: exp=0 (官服行为), lvExp=0
    local expInfo = SeerPets.getExpInfo(petId, petLevel, 0)
    
    local responseBody = ""
    
    -- PetTakeOutInfo 结构 (官服格式)
    responseBody = responseBody .. writeUInt32BE(0)          -- homeEnergy (官服为0)
    responseBody = responseBody .. writeUInt32BE(catchId)    -- firstPetTime (官服=catchId)
    responseBody = responseBody .. writeUInt32BE(1)          -- flag (有精灵信息)
    
    -- PetInfo (完整版)
    responseBody = responseBody .. writeUInt32BE(petId)      -- id
    responseBody = responseBody .. string.rep("\0", 16)      -- name (野生精灵名字为空)
    responseBody = responseBody .. writeUInt32BE(petDv)      -- dv
    responseBody = responseBody .. writeUInt32BE(petNature)  -- nature
    responseBody = responseBody .. writeUInt32BE(petLevel)   -- level
    responseBody = responseBody .. writeUInt32BE(0)          -- exp
    responseBody = responseBody .. writeUInt32BE(0)          -- lvExp
    responseBody = responseBody .. writeUInt32BE(expInfo.nextLevelExp or 100)  -- nextLvExp
    responseBody = responseBody .. writeUInt32BE(stats.hp or 20)   -- hp
    responseBody = responseBody .. writeUInt32BE(stats.maxHp or 20) -- maxHp
    responseBody = responseBody .. writeUInt32BE(stats.attack or 12)   -- attack
    responseBody = responseBody .. writeUInt32BE(stats.defence or 12)  -- defence
    responseBody = responseBody .. writeUInt32BE(stats.spAtk or 11)    -- s_a
    responseBody = responseBody .. writeUInt32BE(stats.spDef or 10)    -- s_d
    responseBody = responseBody .. writeUInt32BE(stats.speed or 12)    -- speed
    -- ev_* (all 0)
    responseBody = responseBody .. writeUInt32BE(0) .. writeUInt32BE(0) .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0) .. writeUInt32BE(0) .. writeUInt32BE(0)
    
    -- 技能数量（固定4个槽位，官服格式）
    local skillNum = 0
    for i = 1, 4 do
        if skills[i] and skills[i] > 0 then
            skillNum = skillNum + 1
        end
    end
    
    responseBody = responseBody .. writeUInt32BE(skillNum) -- skillNum (实际技能数)
    
    -- 写入4个技能槽位（官服格式：固定4个槽位，无论是否有技能）
    for i = 1, 4 do
        local sid = skills[i] or 0
        local pp = (sid > 0) and 35 or 0
        responseBody = responseBody .. writeUInt32BE(sid) .. writeUInt32BE(pp)
    end
    
    responseBody = responseBody .. writeUInt32BE(catchId)    -- catchTime
    responseBody = responseBody .. writeUInt32BE(301)        -- catchMap
    responseBody = responseBody .. writeUInt32BE(0)          -- catchRect
    responseBody = responseBody .. writeUInt32BE(petLevel)   -- catchLevel
    -- ... (CMD 2304 continues) ...
    -- (End of CMD 2304 Skills)
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
    
    -- 获取玩家精灵数据 (使用 SeerPets)
    local playerStats = SeerPets.getStats(petId, petLevel, 31) or {hp = 20, maxHp = 20}
    local playerSkills = SeerPets.getSkillsForLevel(petId, petLevel)
    local playerPetData = SeerPets.getData(petId)
    
    -- 获取敌方精灵数据 (使用 SeerPets)
    local enemyStats = SeerPets.getStats(enemyPetId, enemyLevel, 15) or {hp = 12, maxHp = 12}
    local enemySkills = SeerPets.getSkillsForLevel(enemyPetId, enemyLevel)
    local enemyPetData = SeerPets.getData(enemyPetId)
    
    -- 创建战斗实例
    local battle = SeerBattle.createBattle(userId, {
        id = petId,
        level = petLevel,
        hp = playerStats.hp,
        maxHp = playerStats.maxHp,
        attack = playerStats.atk or 12,
        defence = playerStats.def or 12,
        spAtk = playerStats.spa or 11,
        spDef = playerStats.spd or 10,
        speed = playerStats.spe or 12,
        type = playerPetData and playerPetData.element or 8,
        skills = playerSkills,
        skillPP = {30, 35, 0, 0},  -- 初始PP
        battleLv = {0, 0, 0, 0, 0, 0},  -- 能力等级变化: atk, def, spa, spd, spe, acc
        catchTime = userData.catchId or 0
    }, {
        id = enemyPetId,
        level = enemyLevel,
        hp = enemyStats.hp,
        maxHp = enemyStats.maxHp,
        attack = enemyStats.atk or 10,
        defence = enemyStats.def or 10,
        spAtk = enemyStats.spa or 8,
        spDef = enemyStats.spd or 8,
        speed = enemyStats.spe or 10,
        type = enemyPetData and enemyPetData.element or 8,
        skills = enemySkills,
        skillPP = {35, 0, 0, 0},  -- 初始PP
        battleLv = {0, 0, 0, 0, 0, 0},  -- 能力等级变化: atk, def, spa, spd, spe, acc
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
    local skills = SeerPets.getSkillsForLevel(petId, petLevel)
    local skillCount = 0
    for _, s in ipairs(skills) do
        if s > 0 then skillCount = skillCount + 1 end
    end
    
    -- 计算精灵属性 (玩家 dv=31)
    local stats = SeerPets.getStats(petId, petLevel, 31) or {hp = 20, maxHp = 20}
    
    tprint(string.format("\27[36m[LocalGame] 精灵 %d (%s) Lv%d, HP=%d, 实际技能=%d个, 发送skillNum=4\27[0m", 
        petId, SeerPets.getName(petId), petLevel, stats.hp, skillCount))
    tprint(string.format("\27[33m[LocalGame] 玩家 catchTime=0x%08X, 敌人 catchTime=0x%08X\27[0m", 
        catchTime, enemyCatchTime))
    
    -- 构建 NoteReadyToFightInfo
    local responseBody = ""
    
    -- fightType/userCount (Fix: 3 -> 2 matching fight_handlers.lua)
    responseBody = responseBody .. writeUInt32BE(2)
    
    -- === 玩家1 (自己) ===
    responseBody = responseBody .. writeUInt32BE(userId)
    responseBody = responseBody .. writeFixedString(userData.nick or userData.nickname or userData.username or tostring(userId), 16)
    
    -- petCount (Restored)
    responseBody = responseBody .. writeUInt32BE(1)
    
    -- PetInfo (Simple Version - Reverted with fixes)
    responseBody = responseBody .. writeUInt32BE(petId)
    responseBody = responseBody .. writeUInt32BE(petLevel)
    responseBody = responseBody .. writeUInt32BE(stats.hp)
    responseBody = responseBody .. writeUInt32BE(stats.maxHp)
    
    -- 过滤有效技能 (Player)
    local validSkills = {}
    for i = 1, 4 do
        local skillId = skills[i] or 0
        if skillId > 0 then
            table.insert(validSkills, skillId)
        end
    end
    
    responseBody = responseBody .. writeUInt32BE(#validSkills) -- skillNum (Real Count)
    
    -- Fixed 4 Skills (Write Valid then Padding)
    for i = 1, 4 do
        local skillId = 0
        if i <= #validSkills then skillId = validSkills[i] end
        
        local pp = 0
        if skillId > 0 then
            local skillData = SeerSkills.get(skillId)
            pp = skillData and skillData.pp or 20
        end
        responseBody = responseBody .. writeUInt32BE(skillId) .. writeUInt32BE(pp)
    end
    
    responseBody = responseBody .. writeUInt32BE(catchTime)
    responseBody = responseBody .. writeUInt32BE(301) -- catchMap
    responseBody = responseBody .. writeUInt32BE(0)   -- catchRect
    responseBody = responseBody .. writeUInt32BE(petLevel) -- catchLevel
    
    responseBody = responseBody .. writeUInt32BE(0) -- skinID/padding
    
    -- === 玩家2 (敌人/BOSS) ===
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeFixedString("", 16)
    
    -- petCount
    responseBody = responseBody .. writeUInt32BE(1)
    
    -- BOSS精灵 (新手教程=13 比比鼠, 官服 level=1)
    local enemyPetId = bossId
    if not enemyPetId or enemyPetId == 0 then enemyPetId = 13 end
    local enemyLevel = 1  -- 官服比比鼠是 level=1
    local enemySkills = SeerPets.getSkillsForLevel(enemyPetId, enemyLevel)
    local enemyStats = SeerPets.getStats(enemyPetId, enemyLevel, 15) or {hp = 12, maxHp = 12}
    
    -- 过滤有效技能 (Enemy)
    local enemyValidSkills = {}
    for _, s in ipairs(enemySkills) do
        if s > 0 then table.insert(enemyValidSkills, s) end
    end
    
    -- Enemy PetInfo
    responseBody = responseBody .. writeUInt32BE(enemyPetId)
    responseBody = responseBody .. writeUInt32BE(enemyLevel)
    responseBody = responseBody .. writeUInt32BE(enemyStats.hp)
    responseBody = responseBody .. writeUInt32BE(enemyStats.maxHp)
    
    responseBody = responseBody .. writeUInt32BE(#enemyValidSkills) -- skillNum
    
    -- Fixed 4 Skills (Write Valid then Padding)
    for i = 1, 4 do
        local s = 0
        local pp = 0
        if i <= #enemyValidSkills then 
            s = enemyValidSkills[i] 
            pp = 35
        end
        responseBody = responseBody .. writeUInt32BE(s) .. writeUInt32BE(pp)
    end
    
    responseBody = responseBody .. writeUInt32BE(enemyCatchTime)
    responseBody = responseBody .. writeUInt32BE(0) -- catchMap (0 for NPC)
    responseBody = responseBody .. writeUInt32BE(0) -- catchRect
    responseBody = responseBody .. writeUInt32BE(enemyLevel) -- catchLevel
    
    responseBody = responseBody .. writeUInt32BE(0) -- skinID/padding
    
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
    local myStats = SeerPets.getStats(petId, petLevel, 31) or {hp = 20, maxHp = 20}
    local enemyStats = SeerPets.getStats(bossId, enemyLevel, 15) or {hp = 12, maxHp = 12}
    
    local responseBody = ""
    
    -- isCanAuto (4字节)
    responseBody = responseBody .. writeUInt32BE(0)  -- 不允许自动战斗
    
    -- === FightPetInfo 1 (玩家精灵) ===
    responseBody = responseBody .. writeUInt32BE(userId)                      -- userID
    responseBody = responseBody .. writeUInt32BE(petId)                       -- petID
    responseBody = responseBody .. writeFixedString(SeerPets.getName(petId), 16) -- petName (Restored)
    responseBody = responseBody .. writeUInt32BE(catchTime)                   -- catchTime
    responseBody = responseBody .. writeUInt32BE(myStats.hp)                  -- hp
    responseBody = responseBody .. writeUInt32BE(myStats.maxHp)               -- maxHP
    responseBody = responseBody .. writeUInt32BE(petLevel)                    -- lv
    responseBody = responseBody .. writeUInt32BE(0)                           -- catchable
    responseBody = responseBody .. string.char(0, 0, 0, 0, 0, 0)              -- battleLv
    
    -- === FightPetInfo 2 (敌方精灵/BOSS) ===
    responseBody = responseBody .. writeUInt32BE(0)                           -- userID
    responseBody = responseBody .. writeUInt32BE(bossId)                      -- petID
    responseBody = responseBody .. writeFixedString("", 16)                   -- petName (Restored)
    responseBody = responseBody .. writeUInt32BE(enemyCatchTime)              -- catchTime
    responseBody = responseBody .. writeUInt32BE(enemyStats.hp)               -- hp
    responseBody = responseBody .. writeUInt32BE(enemyStats.maxHp)            -- maxHP
    responseBody = responseBody .. writeUInt32BE(enemyLevel)                  -- lv
    responseBody = responseBody .. writeUInt32BE(0)                           -- catchable
    responseBody = responseBody .. string.char(0, 0, 0, 0, 0, 0)              -- battleLv
    
    tprint(string.format("\27[33m[LocalGame] 2504 包体大小: %d bytes\27[0m", #responseBody))
    self:sendResponse(clientData, 2504, userId, 0, responseBody)
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
    
    local skillData = SeerSkills.get(skillId)
    local skillName = skillData and skillData.name or "未知技能"
    tprint(string.format("\27[36m[LocalGame] 用户 %d 使用技能 %d (%s)\27[0m", 
        userId, skillId, skillName))
    
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
    local function buildAttackValue(attackerUserId, skillId, atkTimes, lostHp, gainHp, remainHp, maxHp, isCrit, skills, battleLv, status, petType)
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
            -- 从 battle.player.skillPP 或 battle.enemy.skillPP 获取实际PP
            local pp = 30
            if battle then
               -- 尝试查找 PP
               -- 这里的 skills 只是 id array，我们不知道 index。
               -- 但是 caller 传递的 skills 应该是 battle.player.skills
               -- 我们可以假设 index 一致
               if battle.player.skills == skills then
                   pp = battle.player.skillPP[i] or 30
               elseif battle.enemy.skills == skills then
                   pp = battle.enemy.skillPP[i] or 30
               end
            end
            
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
        data = data .. writeUInt32BE(petType or 0)            -- petType (精灵属性类型)
        
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
        local attackerPetType = isPlayerFirst and (battle and battle.player.type or 0) or (battle and battle.enemy.type or 0)
        
        -- 先攻方的 lostHP = 先攻方造成的伤害 (Damage Dealt)
        local firstLostHp = first.damage or 0
        
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
            nil,
            attackerPetType
        )
        
        local firstSkillData = SeerSkills.get(first.skillId)
        local firstSkillName = firstSkillData and firstSkillData.name or "未知技能"
        tprint(string.format("\27[33m[LocalGame] 先攻: %s 使用 %s, 造成 %d 伤害%s, 剩余HP=%d\27[0m",
            first.userId == userId and "玩家" or "敌方",
            firstSkillName,
            first.damage or 0,
            first.isCrit and " (暴击!)" or "",
            first.attackerRemainHp or 0))
    end
    
    -- 构建后攻方的 AttackValue
    if second then
        local isPlayerSecond = second.userId == userId
        local attackerSkills = isPlayerSecond and playerSkills or enemySkills
        local attackerBattleLv = isPlayerSecond and (battle and battle.player.battleLv) or (battle and battle.enemy.battleLv)
        local attackerPetType = isPlayerSecond and (battle and battle.player.type or 0) or (battle and battle.enemy.type or 0)
        
        -- 后攻方的 lostHP = 后攻方造成的伤害 (Damage Dealt)
        local secondLostHp = second.damage or 0
        
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
            nil,
            attackerPetType
        )
        
        local secondSkillData = SeerSkills.get(second.skillId)
        local secondSkillName = secondSkillData and secondSkillData.name or "未知技能"
        tprint(string.format("\27[33m[LocalGame] 后攻: %s 使用 %s, 造成 %d 伤害%s, 剩余HP=%d\27[0m",
            second.userId == userId and "玩家" or "敌方",
            secondSkillName,
            second.damage or 0,
            second.isCrit and " (暴击!)" or "",
            second.attackerRemainHp or 0))
    else
        tprint(string.format("\27[35m[LocalGame] DEBUG: 敌方已死亡，发送空AttackValue (secondAttack=%s, result.isOver=%s)\27[0m",
            tostring(second), tostring(result.isOver)))
        -- 如果没有第二次攻击（对方已死），发送空的攻击信息
        -- 但仍需要保持正确的结构
        local deadUserId = first.userId == userId and 0 or userId
        local deadSkills = deadUserId == userId and playerSkills or enemySkills
        local deadPetType = deadUserId == userId and (battle and battle.player.type or 0) or (battle and battle.enemy.type or 0)
        local deadMaxHp = deadUserId == userId and (battle and battle.player.maxHp or 100) or (battle and battle.enemy.maxHp or 100)
        
        responseBody = responseBody .. buildAttackValue(
            deadUserId,
            0,  -- 无技能
            0,  -- atkTimes=0 表示无法行动
            0,  -- lostHP=0 (阵亡方未造成伤害)
            0,
            0,  -- 剩余HP=0 (已死亡)
            deadMaxHp,
            false,
            deadSkills,
            nil,
            nil,
            deadPetType
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
    local stats = SeerPets.getStats(petId, petLevel, petDv) or {
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
    local expInfo = SeerPets.getExpInfo(petId, petLevel, newLevelExp)
    
    local responseBody = ""
    
    responseBody = responseBody .. writeUInt32BE(0)          -- addition (无加成)
    responseBody = responseBody .. writeUInt32BE(1)          -- petCount
    
    -- UpdatePropInfo
    responseBody = responseBody .. writeUInt32BE(catchTime)  -- catchTime
    responseBody = responseBody .. writeUInt32BE(petId)      -- id
    responseBody = responseBody .. writeUInt32BE(petLevel)   -- level
    responseBody = responseBody .. writeUInt32BE(gainedExp)  -- exp (本次战斗获得的经验)
    responseBody = responseBody .. writeUInt32BE(expInfo.currentLevelExp or 0)      -- currentLvExp (累计经验)
    responseBody = responseBody .. writeUInt32BE(expInfo.nextLevelExp or 100)  -- nextLvExp
    responseBody = responseBody .. writeUInt32BE(stats.maxHp or 20)        -- maxHp
    responseBody = responseBody .. writeUInt32BE(stats.atk or 12)          -- attack (注: Algorithm返回atk)
    responseBody = responseBody .. writeUInt32BE(stats.def or 12)          -- defence (注: Algorithm返回def)
    responseBody = responseBody .. writeUInt32BE(stats.spa or 11)          -- sa (注: Algorithm返回spa)
    responseBody = responseBody .. writeUInt32BE(stats.spd or 10)          -- sd (注: Algorithm返回spd)
    responseBody = responseBody .. writeUInt32BE(stats.spe or 12)          -- sp (注: Algorithm返回spe)
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
            
            -- 检查服装数量（不再自动从 items 提取服装）
            -- 服装应该由玩家手动穿戴，而不是自动穿上
            if not self.users[userId].clothes then
                self.users[userId].clothes = {}
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
-- CMD 2061: 修改昵称
-- 请求: nick(16)
-- 响应: userId(4) + nick(16)
function LocalGameServer:handleChangeNickName(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2061: 修改昵称\27[0m")
    
    -- 解析新昵称 (16字节)
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
    userData.nick = newNick
    userData.nickname = newNick
    
    -- 保存到数据库
    self:saveUserData(userId)
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 修改昵称为: %s\27[0m", userId, newNick))
    
    -- 响应: userId(4) + nick(16)
    local responseBody = writeUInt32BE(userId) .. writeFixedString(newNick, 16)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
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
-- CMD 2601: 购买物品
-- BuyItemInfo: 购买响应 (包含最新金币数)
function LocalGameServer:handleItemBuy(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2601: 购买物品\27[0m")
    
    local itemId = 0
    local count = 0
    if #body >= 8 then
        itemId = readUInt32BE(body, 1)
        count = readUInt32BE(body, 5)
    end
    
    local coins = 0  -- 默认金币为0，后面会从数据库读取
    
    -- 简单的数据库处理
    if self.userdb then
        local db = self.userdb:new()
        local user = db:findByUserId(userId)
        
        if user then
            coins = user.coins or 0
            
            -- 获取物品价格
            local price = SeerItems.getPrice(itemId)
            local totalCost = price * count
            
            -- 扣除金币 (Atomic consume)
            local success, newCoins = db:consumeCoins(userId, totalCost)
            if not success then
                tprint(string.format("\27[31m[LocalGame] 金币不足! 需要: %d, 拥有: %d\27[0m", totalCost, newCoins))
                self:sendResponse(clientData, cmdId, userId, 10016, "")
                return
            end
            
            -- 添加物品
            db:addItem(userId, itemId, count)
            
            -- 更新返回的金币数
            coins = newCoins
            tprint(string.format("\27[32m[LocalGame] 购买成功! 物品ID=%d, 数量=%d, 剩余金币: %d\27[0m", itemId, count, coins))
        end
    end
    
    -- 官服响应格式: Coins(4) + ItemID(4) + Count(4) + Padding(4)
    local responseBody = writeUInt32BE(coins) .. 
                        writeUInt32BE(itemId) .. 
                        writeUInt32BE(count) .. 
                        writeUInt32BE(0)
                        
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2605: 获取物品列表
-- 响应: count(4) + [itemID(4) + count(4) + expireTime(4) + padding(4)]...
-- 官服ItemInfo 16字节
function LocalGameServer:handleItemList(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2605: 获取物品列表\27[0m")
    
    -- 解析请求的物品类型范围
    local itemType1, itemType2, itemType3 = 0, 0, 0
    if #body >= 12 then
        itemType1 = readUInt32BE(body, 1)
        itemType2 = readUInt32BE(body, 5)
        itemType3 = readUInt32BE(body, 9)
    end
    
    tprint(string.format("\27[36m[LocalGame] ITEM_LIST 查询范围: %d-%d, %d\27[0m", itemType1, itemType2, itemType3))
    
    local allItems = {}
    if self.userdb then
        local db = self.userdb:new()
        allItems = db:getItemList(userId)
    end
    
    -- 过滤物品
    local filteredItems = {}
    for _, item in ipairs(allItems) do
        local id = item.itemId or 0
        local inRange = (id >= itemType1 and id <= itemType2) or (id == itemType3)
        -- 特殊处理: 如果范围全为0，可能是不通过Item_List获取所有? 
        -- 不，通常 Item_List 必须带范围。全0可能是特定逻辑，暂时视为不返回或返回所有。
        -- 官服日志显示都有范围。
        
        if inRange then
            table.insert(filteredItems, item)
        end
    end
    
    local responseBody = writeUInt32BE(#filteredItems)
    for _, item in ipairs(filteredItems) do
        responseBody = responseBody .. writeUInt32BE(item.itemId or 0)
        responseBody = responseBody .. writeUInt32BE(item.count or 0)
        responseBody = responseBody .. writeUInt32BE(item.expireTime or 0) -- 0x00057E40? 官服似乎发这个
        responseBody = responseBody .. writeUInt32BE(0) -- Padding
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
    tprint(string.format("\27[32m[LocalGame] 返回物品 %d 个 (总拥有的 %d 个)\27[0m", #filteredItems, #allItems))
end

-- CMD 2606: 批量购买物品
-- 请求: count(4) + [itemID(4)]...
-- 响应: coins(4)
function LocalGameServer:handleMultiItemBuy(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2606: 批量购买物品\27[0m")
    
    local count = 0
    local itemIds = {}
    
    if #body >= 4 then
        count = readUInt32BE(body, 1)
        for i = 1, count do
            if #body >= 4 + i * 4 then
                local id = readUInt32BE(body, 1 + i * 4)
                table.insert(itemIds, id)
            end
        end
    end
    
    tprint(string.format("\27[36m[LocalGame] 批量购买 %d 个物品\27[0m", #itemIds))
    
    local coins = 0 -- 默认金币为0
    
    if self.userdb then
        local db = self.userdb:new()
        
        -- 计算总价格
        local totalCost = 0
        for _, id in ipairs(itemIds) do
            local price = SeerItems.getPrice(id)
            totalCost = totalCost + price
        end
        
        -- 尝试扣款
        local success, newCoins = db:consumeCoins(userId, totalCost)
        if success then
            for _, id in ipairs(itemIds) do
                db:addItem(userId, id, 1)
            end
            coins = newCoins
            tprint(string.format("\27[32m[LocalGame] 批量购买成功! 花费: %d, 剩余: %d\27[0m", totalCost, coins))
        else
            tprint(string.format("\27[31m[LocalGame] 批量购买失败: 金币不足! 需要: %d, 拥有: %d\27[0m", totalCost, newCoins))
            local user = db:findByUserId(userId)
            coins = user and user.coins or 0
        end
    end
    
    local responseBody = writeUInt32BE(coins)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
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
    
    -- 保存到数据库
    if self.userdb then
        local db = self.userdb:new()
        db:saveGameData(userId, userData)
        tprint(string.format("\27[32m[LocalGame] 用户 %d 服装已保存到数据库\27[0m", userId))
    end
    
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

-- CMD 2305: 获取仓库精灵列表
function LocalGameServer:handleGetStorageList(clientData, cmdId, userId, seqId, body)
    -- ... (existing code) ...
    local storagePets = {}
    if self.userdb then
        local db = self.userdb:new()
        storagePets = db:getStoragePets(userId)
    end
    
    local responseBody = writeUInt32BE(#storagePets)
    for _, pet in ipairs(storagePets) do
        responseBody = responseBody .. writeUInt32BE(pet.id or 1)
        responseBody = responseBody .. writeUInt32BE(pet.catchTime or 0)
        responseBody = responseBody .. writeUInt32BE(pet.level or 1)
        responseBody = responseBody .. writeUInt32BE(pet.nature or 0)
        responseBody = responseBody .. writeUInt32BE(0) -- flag/status
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2306: 精灵恢复 (消耗NoNo能量)
function LocalGameServer:handlePetCure(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 2306: 精灵恢复\27[0m")
    
    local db = self.userdb:new()
    local nono = db:getNonoData(userId)
    
    -- 检查能量
    if (nono.energy or 0) < 10 then
        -- 能量不足
        -- Send standard error? Or custom?
        -- For now, just fail silently or return 0
        -- Client might expect specific error code
    end
    
    -- 扣除能量
    nono.energy = math.max(0, (nono.energy or 100) - 10)
    db:updateNonoData(userId, {energy = nono.energy})
    
    -- 恢复所有背包精灵
    local userData = self:getOrCreateUser(userId)
    -- We don't track HP in simple userData, it's calculated dynamically or stored in DB if complex.
    -- Assuming client just needs "OK" response to update UI.
    -- But we should update DB if we were tracking currentHP.
    -- Currently we generate HP on fly or don't persist damaged state fully for wild/starter?
    -- Actually we need to make sure subsequent 'getPetInfo' returns full HP.
    -- But since we use 'SeerPets.getStats' and don't seem to persist 'currentHp' in DB yet (only IV/EV/Level),
    -- they always spawn full HP on login/get info unless handled.
    -- Wait, if they always spawn full HP, then cure is visual?
    -- No, battle logic might cache it.
    
    -- For now, just acknowledge the cure.
    local responseBody = writeUInt32BE(nono.energy)
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
-- 响应: 先发送 CMD 2001 (ENTER_MAP) 让玩家进入目标地图，再发送 CMD 10003 确认
function LocalGameServer:handleLeaveRoom(clientData, cmdId, userId, seqId, body)
    tprint("\27[36m[LocalGame] 处理 CMD 10003: 离开房间\27[0m")
    
    local flag = 0
    local mapID = 1  -- 默认地图1
    local catchTime = 0
    local changeShape = 0
    local actionType = 0
    
    if #body >= 4 then flag = readUInt32BE(body, 1) end
    if #body >= 8 then mapID = readUInt32BE(body, 5) end
    if #body >= 12 then catchTime = readUInt32BE(body, 9) end
    if #body >= 16 then changeShape = readUInt32BE(body, 13) end
    if #body >= 20 then actionType = readUInt32BE(body, 17) end
    
    tprint(string.format("\27[36m[LocalGame] 用户 %d 离开房间，返回地图 %d\27[0m", userId, mapID))
    
    -- 获取用户数据
    local userData = self:getOrCreateUser(userId)
    local nickname = userData.nick or userData.nickname or tostring(userId)
    local clothes = userData.clothes or {}
    local teamInfo = userData.teamInfo or {}
    
    -- 发送 CMD 2001 (ENTER_MAP) - 使用 setForPeoleInfo 格式
    -- 按照 UserInfo.setForPeoleInfo 的解析顺序构建数据
    local enterMapBody = ""
    
    -- 1. 基本信息
    enterMapBody = enterMapBody .. writeUInt32BE(os.time())                    -- sysTime (4)
    enterMapBody = enterMapBody .. writeUInt32BE(userId)                       -- userID (4)
    enterMapBody = enterMapBody .. writeFixedString(nickname, 16)              -- nick (16)
    enterMapBody = enterMapBody .. writeUInt32BE(userData.color or 0)          -- color (4)
    enterMapBody = enterMapBody .. writeUInt32BE(userData.texture or 0)        -- texture (4)
    
    -- vipFlags: bit0=vip, bit1=viped
    local vipFlags = 0
    if userData.vip then vipFlags = vipFlags + 1 end
    if userData.viped then vipFlags = vipFlags + 2 end
    enterMapBody = enterMapBody .. writeUInt32BE(vipFlags)                     -- vipFlags (4)
    enterMapBody = enterMapBody .. writeUInt32BE(userData.vipStage or 1)       -- vipStage (4)
    enterMapBody = enterMapBody .. writeUInt32BE(actionType)                   -- actionType (4)
    enterMapBody = enterMapBody .. writeUInt32BE(300)                          -- posX (4)
    enterMapBody = enterMapBody .. writeUInt32BE(200)                          -- posY (4)
    
    -- 2. 动作和状态
    enterMapBody = enterMapBody .. writeUInt32BE(0)                            -- action (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                            -- direction (4)
    enterMapBody = enterMapBody .. writeUInt32BE(changeShape)                  -- changeShape (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                            -- spiritTime (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                            -- spiritID (4)
    enterMapBody = enterMapBody .. writeUInt32BE(31)                           -- petDV (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                            -- petSkin (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                            -- fightFlag (4)
    
    -- 3. 师徒和NONO
    enterMapBody = enterMapBody .. writeUInt32BE(userData.teacherID or 0)      -- teacherID (4)
    enterMapBody = enterMapBody .. writeUInt32BE(userData.studentID or 0)      -- studentID (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                            -- nonoState - 32 bits (4)
    enterMapBody = enterMapBody .. writeUInt32BE(userData.nonoColor or 1)      -- nonoColor (4)
    enterMapBody = enterMapBody .. writeUInt32BE(userData.superNono and 1 or 0) -- superNono (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                            -- playerForm (4)
    enterMapBody = enterMapBody .. writeUInt32BE(0)                            -- transTime (4)
    
    -- 4. TeamInfo: id(4) + coreCount(4) + isShow(4) + logoBg(2) + logoIcon(2) + logoColor(2) + txtColor(2) + logoWord(4) = 24 bytes
    enterMapBody = enterMapBody .. writeUInt32BE(teamInfo.id or 0)             -- team.id (4)
    enterMapBody = enterMapBody .. writeUInt32BE(teamInfo.coreCount or 0)      -- team.coreCount (4)
    enterMapBody = enterMapBody .. writeUInt32BE(teamInfo.isShow and 1 or 0)   -- team.isShow (4)
    enterMapBody = enterMapBody .. writeUInt16BE(teamInfo.logoBg or 0)         -- team.logoBg (2)
    enterMapBody = enterMapBody .. writeUInt16BE(teamInfo.logoIcon or 0)       -- team.logoIcon (2)
    enterMapBody = enterMapBody .. writeUInt16BE(teamInfo.logoColor or 0)      -- team.logoColor (2)
    enterMapBody = enterMapBody .. writeUInt16BE(teamInfo.txtColor or 0)       -- team.txtColor (2)
    enterMapBody = enterMapBody .. writeFixedString(teamInfo.logoWord or "", 4) -- team.logoWord (4)
    
    -- 5. 服装
    enterMapBody = enterMapBody .. writeUInt32BE(#clothes)                     -- clothCount (4)
    for _, cloth in ipairs(clothes) do
        enterMapBody = enterMapBody .. writeUInt32BE(cloth.id or cloth[1] or 0)   -- cloth.id (4)
        enterMapBody = enterMapBody .. writeUInt32BE(cloth.level or cloth[2] or 0) -- cloth.level (4)
    end
    
    -- 6. 称号
    enterMapBody = enterMapBody .. writeUInt32BE(0)                            -- curTitle (4)
    
    -- 总计: 52 + 32 + 28 + 24 + 8 = 144 bytes (无服装时)
    tprint(string.format("\27[35m[LocalGame] ENTER_MAP body size: %d bytes\27[0m", #enterMapBody))
    
    self:sendResponse(clientData, 2001, userId, 0, enterMapBody)
    tprint(string.format("\27[32m[LocalGame] → ENTER_MAP: 地图 %d\27[0m", mapID))
    
    -- 再发送 CMD 10003 确认
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
