-- 本地房间服务器 (家园系统)
-- 独立于游戏服务器，但共享用户数据

local net = require('net')
local json = require('json')
local fs = require('fs')

-- 从 Logger 模块获取 tprint
local Logger = require('../logger')
local tprint = Logger.tprint

local LocalRoomServer = {}
LocalRoomServer.__index = LocalRoomServer

-- 加载命令映射
local SeerCommands = require('../seer_commands')

-- 加载在线追踪模块
local OnlineTracker = require('../handlers/online_tracker')

local function getCmdName(cmdId)
    return SeerCommands.getName(cmdId)
end

-- 数据包结构:
-- 17 字节头部: length(4) + version(1) + cmdId(4) + userId(4) + result(4)

function LocalRoomServer:new(sharedUserDB)
    local obj = {
        port = conf.roomserver_port or 5100,
        clients = {},
        userdb = sharedUserDB,  -- 共享用户数据库
        users = {},             -- userId -> user data (缓存)
    }
    setmetatable(obj, LocalRoomServer)
    obj:start()
    return obj
end

function LocalRoomServer:start()
    local server = net.createServer(function(client)
        tprint(string.format("\27[35m[RoomServer] 新客户端连接: %s:%d\27[0m", 
            client:address().ip, client:address().port))
        
        local clientData = {
            socket = client,
            buffer = "",
            userId = 0,
            session = "",
            roomId = 0,
            loggedIn = false,
            heartbeatTimer = nil  -- 心跳定时器
        }
        table.insert(self.clients, clientData)
        
        client:on('data', function(data)
            self:handleData(clientData, data)
        end)
        
        client:on('end', function()
            tprint("\27[35m[RoomServer] 客户端断开连接\27[0m")
            self:removeClient(clientData)
        end)
        
        client:on('error', function(err)
            tprint("\27[31m[RoomServer] 客户端错误: " .. tostring(err) .. "\27[0m")
            self:removeClient(clientData)
        end)
    end)
    
    server:listen(self.port, "0.0.0.0", function()
        tprint(string.format("\27[35m[RoomServer] 房间服务器启动在端口 %d\27[0m", self.port))
    end)
end

function LocalRoomServer:removeClient(clientData)
    -- 清理心跳定时器
    if clientData.heartbeatTimer then
        local timer = require('timer')
        timer.clearInterval(clientData.heartbeatTimer)
        clientData.heartbeatTimer = nil
    end
    
    -- 从在线追踪移除
    if clientData.userId and clientData.userId > 0 then
        -- 不完全移除，只是标记离开房间
        tprint(string.format("\27[35m[RoomServer] 用户 %d 离开房间\27[0m", clientData.userId))
    end
    
    for i, c in ipairs(self.clients) do
        if c == clientData then
            table.remove(self.clients, i)
            break
        end
    end
end

function LocalRoomServer:handleData(clientData, data)
    clientData.buffer = clientData.buffer .. data
    
    while #clientData.buffer >= 17 do
        local length = clientData.buffer:byte(1) * 16777216 + 
                      clientData.buffer:byte(2) * 65536 + 
                      clientData.buffer:byte(3) * 256 + 
                      clientData.buffer:byte(4)
        
        if #clientData.buffer < length then
            break
        end
        
        local packet = clientData.buffer:sub(1, length)
        clientData.buffer = clientData.buffer:sub(length + 1)
        
        self:processPacket(clientData, packet)
    end
end

-- 检查是否应该隐藏该命令的日志
local function shouldHideCmd(cmdId)
    if not conf.hide_frequent_cmds then return false end
    if not conf.hide_cmd_list then return false end
    for _, hideCmdId in ipairs(conf.hide_cmd_list) do
        if cmdId == hideCmdId then return true end
    end
    return false
end

function LocalRoomServer:processPacket(clientData, packet)
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
    
    -- 根据配置决定是否打印日志
    if not shouldHideCmd(cmdId) then
        tprint(string.format("\27[35m[RoomServer] 收到 CMD=%d (%s) UID=%d LEN=%d\27[0m", 
            cmdId, getCmdName(cmdId), userId, length))
        
        -- 打印 HEX 数据
        if #body > 0 then
            local hexStr = ""
            for i = 1, math.min(#body, 100) do
                hexStr = hexStr .. string.format("%02X ", body:byte(i))
            end
            if #body > 100 then hexStr = hexStr .. "..." end
            tprint(string.format("\27[35m[RoomServer]   HEX: %s\27[0m", hexStr))
        end
    end
    
    self:handleCommand(clientData, cmdId, userId, seqId, body)
end

function LocalRoomServer:handleCommand(clientData, cmdId, userId, seqId, body)
    local handlers = {
        [10001] = self.handleRoomLogin,        -- 房间登录
        [10003] = self.handleLeaveRoom,        -- 离开房间
        [10006] = self.handleFitmentUsering,   -- 正在使用的家具
        [10007] = self.handleFitmentAll,       -- 所有家具
        [10008] = self.handleSetFitment,       -- 设置家具
        [10004] = self.handleBuyFitment,       -- 购买家具
        [10005] = self.handleBetrayFitment,    -- 出售家具
        [2001] = self.handleEnterMap,          -- 进入地图 (房间内切换)
        [2002] = self.handleLeaveMap,          -- 离开地图
        [2003] = self.handleListMapPlayer,     -- 地图玩家列表
        [2101] = self.handlePeopleWalk,        -- 人物移动
        [2102] = self.handleChat,              -- 聊天
        [2103] = self.handleDanceAction,       -- 舞蹈动作
        [2157] = self.handleSeeOnline,         -- 查看在线状态
        [2201] = self.handleAcceptTask,        -- 接受任务
        [2324] = self.handlePetRoomList,       -- 房间精灵列表
        [9003] = self.handleNonoInfo,          -- NONO信息
        [80008] = self.handleHeartbeat,        -- 心跳包
    }
    
    local handler = handlers[cmdId]
    if handler then
        handler(self, clientData, cmdId, userId, seqId, body)
    else
        tprint(string.format("\27[33m[RoomServer] 未实现的命令: %d (%s)\27[0m", cmdId, getCmdName(cmdId)))
        self:sendResponse(clientData, cmdId, userId, 0, "")
    end
end

-- 构建响应数据包
function LocalRoomServer:sendResponse(clientData, cmdId, userId, result, body)
    body = body or ""
    local length = 17 + #body
    
    local header = string.char(
        math.floor(length / 16777216) % 256,
        math.floor(length / 65536) % 256,
        math.floor(length / 256) % 256,
        length % 256,
        0x37,
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
    
    -- 根据配置决定是否打印日志
    if not shouldHideCmd(cmdId) then
        tprint(string.format("\27[32m[RoomServer] 发送 CMD=%d (%s) RESULT=%d LEN=%d\27[0m", 
            cmdId, getCmdName(cmdId), result, length))
        
        -- 打印响应 HEX
        if #body > 0 then
            local hexStr = ""
            for i = 1, math.min(#body, 100) do
                hexStr = hexStr .. string.format("%02X ", body:byte(i))
            end
            if #body > 100 then hexStr = hexStr .. "..." end
            tprint(string.format("\27[32m[RoomServer]   HEX: %s\27[0m", hexStr))
        end
    end
end

-- 辅助函数
local function writeUInt32BE(value)
    return string.char(
        math.floor(value / 16777216) % 256,
        math.floor(value / 65536) % 256,
        math.floor(value / 256) % 256,
        value % 256
    )
end

local function writeUInt16BE(value)
    return string.char(
        math.floor(value / 256) % 256,
        value % 256
    )
end

local function writeFixedString(str, length)
    local result = str:sub(1, length)
    while #result < length do
        result = result .. "\0"
    end
    return result
end

local function readUInt32BE(data, offset)
    offset = offset or 1
    if #data < offset + 3 then return 0 end
    return data:byte(offset) * 16777216 + 
           data:byte(offset + 1) * 65536 + 
           data:byte(offset + 2) * 256 + 
           data:byte(offset + 3)
end

-- 获取或创建用户数据 (从共享数据库)
function LocalRoomServer:getOrCreateUser(userId)
    -- 首先检查缓存
    if self.users[userId] then
        return self.users[userId]
    end
    
    -- 从共享数据库获取
    if self.userdb then
        local db = self.userdb:new()
        
        -- 获取用户基础数据
        local loginUser = db:findByUserId(userId)
        
        -- 获取游戏数据
        local gameData = db:getOrCreateGameData(userId)
        
        -- 合并数据
        local userData = {}
        for k, v in pairs(gameData) do
            userData[k] = v
        end
        
        -- 合并登录用户数据
        if loginUser then
            if loginUser.nickname then
                userData.nick = loginUser.nickname
                userData.nickname = loginUser.nickname
            end
            if loginUser.color then
                userData.color = loginUser.color
            end
        end
        
        userData.id = userId
        self.users[userId] = userData
        return userData
    end
    
    -- 默认用户数据
    self.users[userId] = {
        id = userId,
        nick = "赛尔" .. userId,
        fitments = {{id = 500001, x = 0, y = 0, dir = 0, status = 0}},
        allFitments = {{id = 500001, usedCount = 1, allCount = 1}}
    }
    return self.users[userId]
end

-- 保存用户数据
function LocalRoomServer:saveUserData()
    if self.userdb then
        local db = self.userdb:new()
        for uId, userData in pairs(self.users) do
            -- 只保存游戏数据 (包含家具)
            db:saveGameData(uId, userData)
        end
        tprint("\27[35m[RoomServer] 用户数据已保存\27[0m")
    end
end

-- ==================== 命令处理器 ====================

-- CMD 10001: 房间登录 (ROOM_LOGIN)
-- 请求: targetUserId(4) + session(24) + catchTime(4) + flag(4) + mapId(4) + x(4) + y(4)
-- 注意: mapId 实际上是房主的 userId
function LocalRoomServer:handleRoomLogin(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 10001: 房间登录\27[0m")
    
    local targetUserId = userId
    local catchTime = 0
    local flag = 0
    local mapId = 500001
    local x = 300
    local y = 200
    
    -- 解析请求参数
    if #body >= 4 then targetUserId = readUInt32BE(body, 1) end
    -- session 在 5-28 字节，跳过
    if #body >= 32 then catchTime = readUInt32BE(body, 29) end
    if #body >= 36 then flag = readUInt32BE(body, 33) end
    if #body >= 40 then mapId = readUInt32BE(body, 37) end  -- 实际是房主ID
    if #body >= 44 then x = readUInt32BE(body, 41) end
    if #body >= 48 then y = readUInt32BE(body, 45) end
    
    clientData.loggedIn = true
    clientData.roomId = mapId
    clientData.userId = userId
    clientData.targetUserId = targetUserId
    
    tprint(string.format("\27[35m[RoomServer] 用户 %d 进入房间 (房主=%d) pos=(%d,%d)\27[0m", 
        userId, mapId, x, y))
    
    -- 获取用户数据
    local userData = self:getOrCreateUser(userId)
    local nickname = userData.nick or userData.nickname or ("赛尔" .. userId)
    local clothes = userData.clothes or {}
    local teamInfo = userData.teamInfo or {}
    
    -- 先发送 ENTER_MAP 响应
    local enterMapBody = ""
    enterMapBody = enterMapBody .. writeUInt32BE(os.time())                 -- sysTime
    enterMapBody = enterMapBody .. writeUInt32BE(userId)                    -- userID
    enterMapBody = enterMapBody .. writeFixedString(nickname, 16)           -- nick
    enterMapBody = enterMapBody .. writeUInt32BE(userData.color or 0x0F)    -- color
    enterMapBody = enterMapBody .. writeUInt32BE(userData.texture or 0)     -- texture
    enterMapBody = enterMapBody .. writeUInt32BE(userData.vip and 1 or 0)   -- vipFlags
    enterMapBody = enterMapBody .. writeUInt32BE(userData.vipStage or 1)    -- vipStage
    enterMapBody = enterMapBody .. writeUInt32BE(0)                         -- actionType
    enterMapBody = enterMapBody .. writeUInt32BE(x)                         -- posX
    enterMapBody = enterMapBody .. writeUInt32BE(y)                         -- posY
    enterMapBody = enterMapBody .. writeUInt32BE(0)                         -- action
    enterMapBody = enterMapBody .. writeUInt32BE(2)                         -- direction
    enterMapBody = enterMapBody .. writeUInt32BE(0)                         -- changeShape
    enterMapBody = enterMapBody .. writeUInt32BE(catchTime)                 -- spiritTime
    enterMapBody = enterMapBody .. writeUInt32BE(userData.spiritID or 0)    -- spiritID
    enterMapBody = enterMapBody .. writeUInt32BE(31)                        -- petDV
    enterMapBody = enterMapBody .. writeUInt32BE(0)                         -- petSkin
    enterMapBody = enterMapBody .. writeUInt32BE(0)                         -- fightFlag
    enterMapBody = enterMapBody .. writeUInt32BE(0)                         -- teacherID
    enterMapBody = enterMapBody .. writeUInt32BE(0)                         -- studentID
    enterMapBody = enterMapBody .. writeUInt32BE(userData.nonoState or 1)   -- nonoState
    enterMapBody = enterMapBody .. writeUInt32BE(userData.nonoColor or 0)   -- nonoColor
    enterMapBody = enterMapBody .. writeUInt32BE(userData.superNono or 0)   -- superNono
    enterMapBody = enterMapBody .. writeUInt32BE(0)                         -- playerForm
    enterMapBody = enterMapBody .. writeUInt32BE(0)                         -- transTime
    -- TeamInfo
    enterMapBody = enterMapBody .. writeUInt32BE(teamInfo.id or 0)
    enterMapBody = enterMapBody .. writeUInt32BE(teamInfo.coreCount or 0)
    enterMapBody = enterMapBody .. writeUInt32BE(teamInfo.isShow or 0)
    enterMapBody = enterMapBody .. writeUInt16BE(teamInfo.logoBg or 0)
    enterMapBody = enterMapBody .. writeUInt16BE(teamInfo.logoIcon or 0)
    enterMapBody = enterMapBody .. writeUInt16BE(teamInfo.logoColor or 0xFFFFFF)
    enterMapBody = enterMapBody .. writeUInt16BE(teamInfo.txtColor or 0)
    enterMapBody = enterMapBody .. writeFixedString(teamInfo.logoWord or "", 4)
    -- clothes
    enterMapBody = enterMapBody .. writeUInt32BE(#clothes)
    for _, cloth in ipairs(clothes) do
        enterMapBody = enterMapBody .. writeUInt32BE(cloth.id or cloth[1] or 0)
        enterMapBody = enterMapBody .. writeUInt32BE(cloth.level or cloth[2] or 0)
    end
    enterMapBody = enterMapBody .. writeUInt32BE(0)                         -- curTitle
    
    self:sendResponse(clientData, 2001, userId, 0, enterMapBody)
    tprint(string.format("\27[32m[RoomServer] → ENTER_MAP (家园)\27[0m"))
    
    -- 然后发送 ROOM_LOGIN 空响应
    self:sendResponse(clientData, cmdId, userId, 0, "")
    tprint(string.format("\27[32m[RoomServer] → ROOM_LOGIN 成功\27[0m"))
    
    -- 启动心跳定时器
    self:startHeartbeat(clientData, userId)
end

-- CMD 10003: 离开房间 (LEAVE_ROOM)
function LocalRoomServer:handleLeaveRoom(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 10003: 离开房间\27[0m")
    clientData.loggedIn = false
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 10006: 正在使用的家具 (FITMENT_USERING)
function LocalRoomServer:handleFitmentUsering(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 10006: 正在使用的家具\27[0m")
    
    local targetUserId = userId
    if #body >= 4 then
        targetUserId = readUInt32BE(body, 1)
    end
    
    local userData = self:getOrCreateUser(targetUserId)
    
    -- 初始化默认家具
    if not userData.fitments or #userData.fitments == 0 then
        userData.fitments = {{id = 500001, x = 0, y = 0, dir = 0, status = 0}}
        self:saveUserData()
    end
    
    local fitments = userData.fitments or {}
    
    local responseBody = writeUInt32BE(targetUserId) ..
                        writeUInt32BE(userId) ..
                        writeUInt32BE(#fitments)
    
    for _, fitment in ipairs(fitments) do
        responseBody = responseBody .. writeUInt32BE(fitment.id or 0)
        responseBody = responseBody .. writeUInt32BE(fitment.x or 0)
        responseBody = responseBody .. writeUInt32BE(fitment.y or 0)
        responseBody = responseBody .. writeUInt32BE(fitment.dir or 0)
        responseBody = responseBody .. writeUInt32BE(fitment.status or 0)
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 10007: 所有家具 (FITMENT_ALL)
function LocalRoomServer:handleFitmentAll(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 10007: 所有家具\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    
    if not userData.allFitments or #userData.allFitments == 0 then
        userData.allFitments = {{id = 500001, usedCount = 1, allCount = 1}}
        self:saveUserData()
    end
    
    local allFitments = userData.allFitments or {}
    
    local responseBody = writeUInt32BE(#allFitments)
    
    for _, fitment in ipairs(allFitments) do
        responseBody = responseBody .. writeUInt32BE(fitment.id or 0)
        responseBody = responseBody .. writeUInt32BE(fitment.usedCount or 0)
        responseBody = responseBody .. writeUInt32BE(fitment.allCount or 1)
    end
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 10008: 设置家具 (SET_FITMENT)
function LocalRoomServer:handleSetFitment(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 10008: 设置家具\27[0m")
    
    local roomId = 0
    local count = 0
    local fitments = {}
    
    if #body >= 4 then roomId = readUInt32BE(body, 1) end
    if #body >= 8 then count = readUInt32BE(body, 5) end
    
    local offset = 9
    for i = 1, count do
        if #body >= offset + 19 then
            local fitment = {
                id = readUInt32BE(body, offset),
                x = readUInt32BE(body, offset + 4),
                y = readUInt32BE(body, offset + 8),
                dir = readUInt32BE(body, offset + 12),
                status = readUInt32BE(body, offset + 16)
            }
            table.insert(fitments, fitment)
            offset = offset + 20
        end
    end
    
    local userData = self:getOrCreateUser(userId)
    userData.fitments = fitments
    self:saveUserData()
    
    self:sendResponse(clientData, cmdId, userId, 0, writeUInt32BE(0))
    tprint(string.format("\27[32m[RoomServer] 保存 %d 件家具\27[0m", #fitments))
end

-- CMD 10004: 购买家具 (BUY_FITMENT)
function LocalRoomServer:handleBuyFitment(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 10004: 购买家具\27[0m")
    
    local fitmentId = 0
    local count = 1
    if #body >= 4 then fitmentId = readUInt32BE(body, 1) end
    if #body >= 8 then count = readUInt32BE(body, 5) end
    
    local userData = self:getOrCreateUser(userId)
    local coins = userData.coins or 10000
    
    -- 添加到仓库
    userData.allFitments = userData.allFitments or {}
    local found = false
    for _, f in ipairs(userData.allFitments) do
        if f.id == fitmentId then
            f.allCount = (f.allCount or 0) + count
            found = true
            break
        end
    end
    if not found then
        table.insert(userData.allFitments, {id = fitmentId, usedCount = 0, allCount = count})
    end
    
    self:saveUserData()
    
    local responseBody = writeUInt32BE(coins) ..
                        writeUInt32BE(fitmentId) ..
                        writeUInt32BE(count)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 10005: 出售家具 (BETRAY_FITMENT)
function LocalRoomServer:handleBetrayFitment(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 10005: 出售家具\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, writeUInt32BE(0))
end

-- CMD 2001: 进入地图 (房间内)
function LocalRoomServer:handleEnterMap(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 2001: 进入地图\27[0m")
    
    local mapType = 0
    local mapId = 500001
    local x = 300
    local y = 200
    
    if #body >= 4 then mapType = readUInt32BE(body, 1) end
    if #body >= 8 then mapId = readUInt32BE(body, 5) end
    if #body >= 12 then x = readUInt32BE(body, 9) end
    if #body >= 16 then y = readUInt32BE(body, 13) end
    
    local userData = self:getOrCreateUser(userId)
    local nickname = userData.nick or userData.nickname or ("赛尔" .. userId)
    local clothes = userData.clothes or {}
    local teamInfo = userData.teamInfo or {}
    
    local responseBody = ""
    responseBody = responseBody .. writeUInt32BE(os.time())
    responseBody = responseBody .. writeUInt32BE(userId)
    responseBody = responseBody .. writeFixedString(nickname, 16)
    responseBody = responseBody .. writeUInt32BE(userData.color or 0xFFFFFF)
    responseBody = responseBody .. writeUInt32BE(userData.texture or 0)
    responseBody = responseBody .. writeUInt32BE(userData.vip and 1 or 0)
    responseBody = responseBody .. writeUInt32BE(userData.vipStage or 1)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(x)
    responseBody = responseBody .. writeUInt32BE(y)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(1)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(31)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    -- TeamInfo
    responseBody = responseBody .. writeUInt32BE(teamInfo.id or 0)
    responseBody = responseBody .. writeUInt32BE(teamInfo.coreCount or 0)
    responseBody = responseBody .. writeUInt32BE(teamInfo.isShow or 0)
    responseBody = responseBody .. writeUInt16BE(teamInfo.logoBg or 0)
    responseBody = responseBody .. writeUInt16BE(teamInfo.logoIcon or 0)
    responseBody = responseBody .. writeUInt16BE(teamInfo.logoColor or 0)
    responseBody = responseBody .. writeUInt16BE(teamInfo.txtColor or 0)
    responseBody = responseBody .. writeFixedString(teamInfo.logoWord or "", 4)
    -- clothes
    responseBody = responseBody .. writeUInt32BE(#clothes)
    for _, cloth in ipairs(clothes) do
        responseBody = responseBody .. writeUInt32BE(cloth.id or cloth[1] or 0)
        responseBody = responseBody .. writeUInt32BE(cloth.level or cloth[2] or 0)
    end
    responseBody = responseBody .. writeUInt32BE(0)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2002: 离开地图
function LocalRoomServer:handleLeaveMap(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 2002: 离开地图\27[0m")
    self:sendResponse(clientData, cmdId, userId, 0, writeUInt32BE(userId))
end

-- CMD 2003: 地图玩家列表
function LocalRoomServer:handleListMapPlayer(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 2003: 地图玩家列表\27[0m")
    
    -- 返回房间内的玩家 (目前只有自己)
    local userData = self:getOrCreateUser(userId)
    local nickname = userData.nick or userData.nickname or ("赛尔" .. userId)
    local clothes = userData.clothes or {}
    local teamInfo = userData.teamInfo or {}
    
    local responseBody = writeUInt32BE(1)  -- 1个玩家
    
    -- PeopleInfo
    responseBody = responseBody .. writeUInt32BE(userId)
    responseBody = responseBody .. writeFixedString(nickname, 16)
    responseBody = responseBody .. writeUInt32BE(userData.color or 0xFFFFFF)
    responseBody = responseBody .. writeUInt32BE(userData.texture or 0)
    responseBody = responseBody .. writeUInt32BE(userData.vip and 1 or 0)
    responseBody = responseBody .. writeUInt32BE(userData.vipStage or 1)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(userData.x or 300)
    responseBody = responseBody .. writeUInt32BE(userData.y or 200)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(1)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(31)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    responseBody = responseBody .. writeUInt32BE(0)
    -- TeamInfo
    responseBody = responseBody .. writeUInt32BE(teamInfo.id or 0)
    responseBody = responseBody .. writeUInt32BE(teamInfo.coreCount or 0)
    responseBody = responseBody .. writeUInt32BE(teamInfo.isShow or 0)
    responseBody = responseBody .. writeUInt16BE(teamInfo.logoBg or 0)
    responseBody = responseBody .. writeUInt16BE(teamInfo.logoIcon or 0)
    responseBody = responseBody .. writeUInt16BE(teamInfo.logoColor or 0)
    responseBody = responseBody .. writeUInt16BE(teamInfo.txtColor or 0)
    responseBody = responseBody .. writeFixedString(teamInfo.logoWord or "", 4)
    -- clothes
    responseBody = responseBody .. writeUInt32BE(#clothes)
    for _, cloth in ipairs(clothes) do
        responseBody = responseBody .. writeUInt32BE(cloth.id or cloth[1] or 0)
        responseBody = responseBody .. writeUInt32BE(cloth.level or cloth[2] or 0)
    end
    responseBody = responseBody .. writeUInt32BE(0)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2101: 人物移动
function LocalRoomServer:handlePeopleWalk(clientData, cmdId, userId, seqId, body)
    local walkType = 0
    local x = 0
    local y = 0
    local amfLen = 0
    local amfData = ""
    
    if #body >= 4 then walkType = readUInt32BE(body, 1) end
    if #body >= 8 then x = readUInt32BE(body, 5) end
    if #body >= 12 then y = readUInt32BE(body, 9) end
    if #body >= 16 then
        amfLen = readUInt32BE(body, 13)
        if #body >= 16 + amfLen then
            amfData = body:sub(17, 16 + amfLen)
        end
    end
    
    local userData = self:getOrCreateUser(userId)
    userData.x = x
    userData.y = y
    
    local responseBody = writeUInt32BE(walkType) ..
                writeUInt32BE(userId) ..
                writeUInt32BE(x) ..
                writeUInt32BE(y) ..
                writeUInt32BE(amfLen) ..
                amfData
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2102: 聊天
function LocalRoomServer:handleChat(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 2102: 聊天\27[0m")
    
    local chatType = 0
    local message = ""
    if #body >= 4 then
        chatType = readUInt32BE(body, 1)
        if #body > 4 then
            message = body:sub(5)
        end
    end
    
    local userData = self:getOrCreateUser(userId)
    local nickname = userData.nick or userData.nickname or ("赛尔" .. userId)
    
    local responseBody = writeUInt32BE(userId) ..
                writeFixedString(nickname, 16) ..
                writeUInt32BE(0) ..
                writeUInt32BE(#message) ..
                message
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2103: 舞蹈动作
function LocalRoomServer:handleDanceAction(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 2103: 舞蹈动作\27[0m")
    
    local actionId = 0
    local actionType = 0
    if #body >= 8 then
        actionId = readUInt32BE(body, 1)
        actionType = readUInt32BE(body, 5)
    end
    
    local responseBody = writeUInt32BE(userId) ..
        writeUInt32BE(actionId) ..
        writeUInt32BE(actionType)
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 2157: 查看在线状态 (SEE_ONLINE)
function LocalRoomServer:handleSeeOnline(clientData, cmdId, userId, seqId, body)
    -- 响应: count(4) = 0 (没有在线好友)
    self:sendResponse(clientData, cmdId, userId, 0, writeUInt32BE(0))
end

-- CMD 2201: 接受任务 (ACCEPT_TASK)
function LocalRoomServer:handleAcceptTask(clientData, cmdId, userId, seqId, body)
    -- 返回空响应
    self:sendResponse(clientData, cmdId, userId, 0, "")
end

-- CMD 2324: 房间精灵列表 (PET_ROOM_LIST)
function LocalRoomServer:handlePetRoomList(clientData, cmdId, userId, seqId, body)
    -- 响应: count(4) = 0 (没有精灵在房间)
    self:sendResponse(clientData, cmdId, userId, 0, writeUInt32BE(0))
end

-- CMD 9003: NONO信息 (NONO_INFO)
function LocalRoomServer:handleNonoInfo(clientData, cmdId, userId, seqId, body)
    tprint("\27[35m[RoomServer] 处理 CMD 9003: NONO信息\27[0m")
    
    local userData = self:getOrCreateUser(userId)
    local nono = userData.nono or {}
    
    local responseBody = ""
    responseBody = responseBody .. writeUInt32BE(userId)                    -- userId
    responseBody = responseBody .. writeUInt32BE(nono.flag or 1)            -- hasNono
    responseBody = responseBody .. writeUInt32BE(nono.state or 1)           -- state
    responseBody = responseBody .. writeFixedString(nono.nick or "NONO", 16) -- nick
    responseBody = responseBody .. writeUInt32BE(nono.color or 0xFFFFFF)    -- color
    responseBody = responseBody .. writeUInt32BE(nono.power or 10000)       -- power
    responseBody = responseBody .. writeUInt32BE(nono.mate or 10000)        -- mate
    responseBody = responseBody .. writeUInt32BE(nono.iq or 0)              -- iq
    responseBody = responseBody .. writeUInt32BE(nono.ai or 0)              -- ai
    responseBody = responseBody .. writeUInt32BE(nono.birth or os.time())   -- birth
    responseBody = responseBody .. writeUInt32BE(nono.chargeTime or 500)    -- chargeTime
    -- 20 bytes reserved
    responseBody = responseBody .. string.rep("\xFF", 20)
    responseBody = responseBody .. writeUInt32BE(0)                         -- reserved
    responseBody = responseBody .. writeUInt32BE(0)                         -- reserved
    responseBody = responseBody .. writeUInt32BE(0)                         -- reserved
    
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
end

-- CMD 80008: 心跳包
function LocalRoomServer:handleHeartbeat(clientData, cmdId, userId, seqId, body)
    -- 客户端回复的心跳包，不需要再回复
    -- 服务器主动发送心跳，客户端收到后回复
    -- 不打印日志，避免刷屏
end

-- 启动心跳定时器 (每6秒发送一次)
function LocalRoomServer:startHeartbeat(clientData, userId)
    local timer = require('timer')
    
    -- 如果已有定时器，先清理
    if clientData.heartbeatTimer then
        timer.clearInterval(clientData.heartbeatTimer)
    end
    
    -- 每6秒发送一次心跳包 (官服间隔约6秒)
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
function LocalRoomServer:sendHeartbeat(clientData, userId)
    local cmdId = 80008  -- NIEO_HEART
    local length = 17    -- 只有包头，没有数据体
    
    local header = string.char(
        0, 0, 0, 17,  -- length = 17
        0x37,         -- version
        0, 1, 56, 136, -- cmdId = 80008 (0x00013888)
        math.floor(userId / 16777216) % 256,
        math.floor(userId / 65536) % 256,
        math.floor(userId / 256) % 256,
        userId % 256,
        0, 0, 0, 0    -- result = 0
    )
    
    pcall(function()
        clientData.socket:write(header)
    end)
end

return {LocalRoomServer = LocalRoomServer}
