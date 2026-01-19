-- 本地游戏服务器 - 完整实现
-- 基于官服协议分析实现

local net = require('net')
local bit = require('../../utils/bitop_compat')
local json = require('json')
local fs = require('fs')

-- 从 Logger 模块获取 tprint
local Logger = require('../../core/logger')
local tprint = Logger.tprint

local ProtocolValidator = require('../../core/protocol_validator')
local PacketUtils = require('../../core/packet_utils')

local LocalGameServer = {}
LocalGameServer.__index = LocalGameServer

-- 加载命令映射
local SeerCommands = require('../../game/seer_commands')

-- 加载精灵数据 (Pets via SeerPets)
-- SeerMonsters logic moved to SeerPets/SeerSkills
-- local SeerMonsters = require('../seer_monsters')
-- if SeerMonsters.load then SeerMonsters.load() end

local SeerPets = require('../../game/seer_pets')
if SeerPets.load then SeerPets.load() end

-- 加载技能数据
local SeerSkills = require('../../game/seer_skills')

-- 加载物品数据
local SeerItems = require('../../game/seer_items')
if SeerItems.load then SeerItems.load() end

-- 加载技能效果数据
local SeerSkillEffects = require('../../game/seer_skill_effects')
if SeerSkillEffects.load then SeerSkillEffects.load() end

-- 加载战斗系统
local SeerBattle = require('../../game/seer_battle')

-- 加载协议验证器
local ProtocolValidator = require('../../core/protocol_validator')

-- 加载在线追踪模块
local OnlineTracker = require('../../handlers/online_tracker')

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
    '../../handlers/nono_handlers',
    '../../handlers/pet_handlers',
    '../../handlers/pet_advanced_handlers',
    '../../handlers/task_handlers',
    '../../handlers/fight_handlers',
    '../../handlers/item_handlers',
    '../../handlers/friend_handlers',
    '../../handlers/mail_handlers',
    '../../handlers/map_handlers',
    '../../handlers/room_handlers',
    '../../handlers/team_handlers',
    '../../handlers/teampk_handlers',
    '../../handlers/arena_handlers',
    '../../handlers/exchange_handlers',
    '../../handlers/game_handlers',
    '../../handlers/misc_handlers',
    '../../handlers/special_handlers',
    '../../handlers/system_handlers',
    '../../handlers/teacher_handlers',
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
local GameConfig = require('../../config/game_config')
local SeerLoginResponse = require('./seer_login_response')
local SeerTaskConfig = require('../../data/seer_task_config')

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

function LocalGameServer:new(userdb, sessionManager, dataClient)
    local obj = {
        port = conf.gameserver_port or 5000,
        clients = {},
        sessions = {},  -- session -> user data
        users = {},     -- userId -> user data
        serverList = {},
        nextSeqId = 1,
        cryptoMap = {}, -- map<client, crypto>
        sessionManager = sessionManager,  -- 会话管理器引用
        dataClient = dataClient,  -- 数据客户端（微服务模式）
        -- 移除 nonoFollowingStates，改用 sessionManager
    }
    setmetatable(obj, LocalGameServer)
    obj:loadUserData()
    obj:initServerList()
    obj:start()
    return obj
end

function LocalGameServer:loadUserData()
    -- 从 userdb 加载用户数据
    local userdb = require('../../core/userdb')
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
        -- Reading length using PacketUtils
        local length = PacketUtils.readUInt32BE(clientData.buffer, 1)
        
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
    
    local length = PacketUtils.readUInt32BE(packet, 1)
    local version = packet:byte(5)
    local cmdId = PacketUtils.readUInt32BE(packet, 6)
    local userId = PacketUtils.readUInt32BE(packet, 10)
    local seqId = PacketUtils.readUInt32BE(packet, 14)
    
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
    
    -- 获取服务器 IP 和 Port (用于 GET_ROOM_ADDRES 等需要返回服务器地址的命令)
    -- 优先从配置读取，如果没有配置则使用默认值
    local serverIP = (conf and conf.server_ip) or "127.0.0.1"
    local serverPort = (conf and conf.gameserver_port) or self.port or 5000
    
    local ctx = {
        userId = userId,
        cmdId = cmdId,
        seqId = seqId,
        body = body,
        clientData = clientData,
        gameServer = self_ref,  -- 添加游戏服务器引用（用于访问共享状态）
        sessionManager = self_ref.sessionManager,  -- 添加会话管理器引用
        dataClient = self_ref.dataClient,  -- 添加数据客户端（微服务模式）
        
        -- 服务器连接信息 (用于 GET_ROOM_ADDRES 返回正确的地址，确保 isIlk=true)
        serverIP = serverIP,
        serverPort = serverPort,
        
        -- 发送响应
        sendResponse = function(packet)
            local ok, err = pcall(function()
                clientData.socket:write(packet)
            end)
            if ok then
                tprint(string.format("\27[32m[GlobalHandler] 发送响应 %d bytes 到客户端\27[0m", #packet))
                
                -- 显示详细的十六进制数据（用于调试）
                if #packet > 17 then
                    local body = packet:sub(18)  -- 跳过 17 字节包头
                    local cmdId = packet:byte(6) * 16777216 + packet:byte(7) * 65536 + 
                                  packet:byte(8) * 256 + packet:byte(9)
                    
                    tprint(string.format("\27[36m[PACKET] CMD=%d 包体详情 (%d bytes):\27[0m", cmdId, #body))
                    
                    -- 十六进制格式输出 (每行16字节)
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
                        local padding = 16 - math.min(16, #body - i + 1)
                        hexPart = hexPart .. string.rep("   ", padding)
                        
                        tprint(string.format("\27[90m  %04X: %s |%s|\27[0m", i - 1, hexPart, asciiPart))
                    end
                    tprint(string.format("\27[36m[PACKET] --- 包体结束 ---\27[0m"))
                end
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
                -- 获取最新用户数据并保存
                local user = self_ref.users[userId]
                if user then
                    db:saveGameData(userId, user)
                    -- 强制写入磁盘 (解决重启回档问题)
                    db:save()
                end
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
-- 注意: 根据架构原则 "localgameserver尽量不放命令，命令都放在handle文件夹里"
-- 本地只保留核心必需的命令，其他命令都由 handlers 文件夹处理
function LocalGameServer:getLocalHandlers()
    return {
        -- 只保留心跳包在本地处理（核心连接维护功能）
        [80008] = self.handleNieoHeart,        -- 心跳包
        
        -- 所有其他命令（包括登录、地图、精灵、战斗、家园等）都由 handlers 文件夹处理
        -- 共 204 个命令在 GlobalHandlers 中注册
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

-- 直接处理命令（供其他模块调用，实现命令处理器共享）
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
    
    local packet = PacketUtils.buildResponse(cmdId, userId, result, body)
    
    pcall(function()
        clientData.socket:write(packet)
    end)
    
    if not shouldHideCmd(cmdId) then
        tprint(string.format("\27[32m[LocalGame] 发送 CMD=%d (%s) RESULT=%d LEN=%d\27[0m", 
            cmdId, getCmdName(cmdId), result, length))
        
        -- 调试增强: 关键协议强制 Hex Dump
        -- 1001: 登录 (检查 nonoNick/nonoState)
        -- 9003: NONO_INFO (检查 body 长度和偏移)
        -- 9013: NONO_PLAY (检查 6 字段)
        -- 9019: FOLLOW/HOOM (检查跟随状态)
        local debugCmds = {[1001]=true, [9003]=true, [9013]=true, [9019]=true}
        
        -- 详细包体输出
        if #body > 0 and (debugCmds[cmdId] or conf.debug_packets) then
            tprint(PacketUtils.hexDump(body, string.format("PACKET CMD=%d", cmdId)))
        end
    end
end

-- Helper functions removed (converted to core/packet_utils)

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
            
            -- 合并登录用户数据 (仅作为回退值，不覆盖已保存的游戏数据)
            -- 这样玩家修改的颜色/昵称等数据才能正确持久化
            if loginUser then
                -- color: 只有当游戏数据中没有时，才使用注册时的颜色
                if self.users[userId].color == nil and loginUser.color then
                    self.users[userId].color = loginUser.color
                end
                -- nick/nickname: 只有当游戏数据中没有时，才使用用户名
                if self.users[userId].nick == nil and loginUser.username then
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
    -- CMD 80008: NIEO_HEART (Heartbeat)
    local packet = PacketUtils.buildResponse(80008, userId, 0, "")
    
    pcall(function()
        clientData.socket:write(packet)
    end)
end

return {LocalGameServer = LocalGameServer}
