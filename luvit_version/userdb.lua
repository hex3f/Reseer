-- 用户数据库 - 简单的JSON文件存储
-- 数据结构说明:
-- users: 账号数据 (登录验证用)
--   - userId, email, password, nickname, color, registerTime, roleCreated
-- gameData: 游戏数据 (游戏内使用)
--   - coins, energy, pets, items, tasks, clothes, petBook, nono, mapId, posX, posY

local fs = require "fs"
local json = require "json"

local UserDB = {}
UserDB.__index = UserDB

-- 单例实例
local _instance = nil

function UserDB:new()
    -- 使用单例模式，避免多次加载覆盖数据
    if _instance then
        return _instance
    end
    
    -- 获取当前脚本所在目录，确保 users.json 在正确的位置
    local scriptPath = debug.getinfo(1, "S").source:sub(2)
    -- 支持 Windows 和 Unix 路径分隔符
    local scriptDir = scriptPath:match("(.*[/\\])")
    if not scriptDir then
        scriptDir = "./"
    end
    
    local obj = {
        dbPath = scriptDir .. "users.json",
        users = {},
        gameData = {}
    }
    setmetatable(obj, UserDB)
    print(string.format("\27[32m[UserDB] 数据库路径: %s\27[0m", obj.dbPath))
    obj:load()
    _instance = obj
    return obj
end

function UserDB:load()
    if fs.existsSync(self.dbPath) then
        local data = fs.readFileSync(self.dbPath)
        local success, result = pcall(function()
            return json.parse(data)
        end)
        if success and result then
            self.users = result.users or {}
            self.gameData = result.gameData or {}
            local userCount = 0
            for _ in pairs(self.users) do userCount = userCount + 1 end
            -- 只在首次加载时打印
            if not self._loaded then
                print("\27[32m[UserDB] 加载了 " .. userCount .. " 个用户\27[0m")
                self._loaded = true
            end
        else
            print("\27[33m[UserDB] 用户数据解析失败，使用空数据库\27[0m")
            self.users = {}
            self.gameData = {}
        end
    else
        print("\27[33m[UserDB] 用户数据库不存在，创建新数据库\27[0m")
        self.users = {}
        self.gameData = {}
        self:save()
    end
end

function UserDB:save()
    local data = json.stringify({
        users = self.users,
        gameData = self.gameData
    })
    fs.writeFileSync(self.dbPath, data)
end

function UserDB:saveGameData(userId, data)
    self.gameData[tostring(userId)] = data
    self:save()
    -- 调试: 打印保存的任务状态
    if data.tasks then
        local taskCount = 0
        for taskId, task in pairs(data.tasks) do
            taskCount = taskCount + 1
        end
        if taskCount > 0 then
            print(string.format("\27[35m[UserDB] 保存游戏数据: userId=%d, 任务数=%d\27[0m", userId, taskCount))
        end
    end
end

-- ==================== 账号管理 ====================

function UserDB:findByEmail(email)
    for id, user in pairs(self.users) do
        if user.email == email then
            user.userId = tonumber(id) or user.userId
            return user
        end
    end
    return nil
end

function UserDB:findByUserId(userId)
    local key = tostring(userId)
    if self.users[key] then
        self.users[key].userId = userId
        return self.users[key]
    end
    return nil
end

function UserDB:saveUser(user)
    if user and user.userId then
        self.users[tostring(user.userId)] = user
        self:save()
    end
end

-- 创建用户 (仅账号数据，不含游戏数据)
function UserDB:createUser(email, password)
    if self:findByEmail(email) then
        return nil, "邮箱已被注册"
    end
    
    -- 生成新的userId
    local maxId = 100000000
    for id, _ in pairs(self.users) do
        local numId = tonumber(id)
        if numId and numId > maxId then
            maxId = numId
        end
    end
    local newUserId = maxId + 1
    
    -- 账号数据 (仅登录验证需要的字段)
    local user = {
        userId = newUserId,
        email = email,
        password = password,
        nickname = tostring(newUserId),  -- 默认昵称=米米号
        color = 0,                        -- 角色颜色 (创建角色时设置)
        registerTime = os.time(),
        roleCreated = false               -- 是否已创建角色
    }
    
    self.users[tostring(newUserId)] = user
    self:save()
    
    print(string.format("\27[32m[UserDB] 创建新用户: %d\27[0m", newUserId))
    return user
end

-- ==================== 游戏数据管理 ====================

function UserDB:getOrCreateGameData(userId)
    local key = tostring(userId)
    if not self.gameData[key] then
        -- 加载游戏配置
        local GameConfig = require("./game_config")
        
        -- 从账号数据获取昵称和颜色
        local loginUser = self:findByUserId(userId)
        local nickname = tostring(userId)
        local color = GameConfig.InitialPlayer.color or 0x66CCFF
        
        if loginUser then
            nickname = loginUser.nickname or nickname
            color = loginUser.color or color
        end
        
        -- 游戏数据 (仅游戏内需要的字段) - 使用 game_config 的初始值
        self.gameData[key] = {
            -- 基础信息
            nick = nickname,
            color = color,
            
            -- 货币 (从配置读取)
            coins = GameConfig.InitialPlayer.coins or 2000,
            energy = GameConfig.InitialPlayer.energy or 100,
            
            -- 精灵背包
            pets = {},
            
            -- 物品背包
            items = {},
            
            -- 服装
            clothes = {},
            
            -- 任务状态
            tasks = {},
            
            -- 精灵图鉴
            petBook = {},
            
            -- 位置 (从配置读取)
            mapId = GameConfig.InitialPlayer.mapID or 1,
            posX = GameConfig.InitialPlayer.posX or 300,
            posY = GameConfig.InitialPlayer.posY or 300,
            
            -- 家园系统 - 默认家具
            -- fitments: 正在使用的家具 (摆放在房间里的)
            fitments = {
                {id = 500001, x = 0, y = 0, dir = 0, status = 0}  -- 默认房间风格
            },
            -- allFitments: 所有拥有的家具 (仓库)
            allFitments = {
                {id = 500001, usedCount = 1, allCount = 1}  -- 默认房间风格
            },
            
            -- NoNo信息
            nono = {
                flag = 0,
                color = 0,
                nick = "NoNo",
                chip = 0,
                grow = 0,     -- 成长值
                expire = 0,   -- SuperNoNo过期时间
                isSuper = false,
                energy = 100, -- 电池能量
                mate = 0,
                ai = 0
            },
            
            -- 成就信息
            achievements = {
                total = 0,
                rank = 0,
                list = {} -- ID list
            },
            
            -- 精灵仓库 (不在背包的精灵)
            storagePets = {}
        }
        self:save()
        print(string.format("\27[32m[UserDB] 创建游戏数据: userId=%d (含默认家具)\27[0m", userId))
    end
    return self.gameData[key]
end

function UserDB:updateUserCoins(userId, coins)
    local data = self:getOrCreateGameData(userId)
    data.coins = coins
    self:saveGameData(userId, data)
    return true
end

function UserDB:consumeCoins(userId, amount)
    local data = self:getOrCreateGameData(userId)
    local currentCoins = data.coins or 0
    if currentCoins >= amount then
        data.coins = currentCoins - amount
        self:saveGameData(userId, data)
        return true, data.coins
    else
        return false, currentCoins
    end
end

-- ==================== 物品管理 ====================

function UserDB:addItem(userId, itemId, count)
    local data = self:getOrCreateGameData(userId)
    data.items = data.items or {}
    
    local key = tostring(itemId)
    if data.items[key] then
        data.items[key].count = (data.items[key].count or 1) + (count or 1)
    else
        data.items[key] = { count = count or 1 }
    end
    self:saveGameData(userId, data)
    
    -- 检查是否有任务需要此物品（获得物品类型任务）
    -- 使用 pcall 避免 require 失败导致整个函数崩溃
    local success, SeerTaskConfig = pcall(require, "data/seer_task_config")
    if not success then
        -- 如果加载失败，尝试相对路径
        success, SeerTaskConfig = pcall(require, "./data/seer_task_config")
    end
    
    if success and data.tasks then
        for taskIdStr, taskData in pairs(data.tasks) do
            if taskData.status == "accepted" then
                local taskId = tonumber(taskIdStr)
                local taskConfig = SeerTaskConfig.get(taskId)
                
                -- 检查是否是获得物品任务
                if taskConfig and taskConfig.type == "get_item" and taskConfig.targetItemId == itemId then
                    -- 自动完成任务
                    taskData.status = "completed"
                    taskData.completeTime = os.time()
                    self:saveGameData(userId, data)
                    print(string.format("\27[32m[UserDB] 获得物品 %d 自动完成任务 %d\27[0m", itemId, taskId))
                end
            end
        end
    end
    
    return true
end

function UserDB:removeItem(userId, itemId, count)
    local data = self:getOrCreateGameData(userId)
    data.items = data.items or {}
    
    local key = tostring(itemId)
    if data.items[key] then
        data.items[key].count = (data.items[key].count or 1) - (count or 1)
        if data.items[key].count <= 0 then
            data.items[key] = nil
        end
        self:saveGameData(userId, data)
        return true
    end
    return false
end

function UserDB:getItemCount(userId, itemId)
    local data = self:getOrCreateGameData(userId)
    local key = tostring(itemId)
    if data.items and data.items[key] then
        return data.items[key].count or 0
    end
    return 0
end

function UserDB:getItemList(userId)
    local data = self:getOrCreateGameData(userId)
    local list = {}
    
    if data.items then
        for itemId, itemData in pairs(data.items) do
            table.insert(list, {
                itemId = tonumber(itemId),
                count = itemData.count or 0,
                expireTime = itemData.expireTime or 360000 -- 默认给个过期时间，或者无限制
            })
        end
    end
    
    return list
end

-- ==================== 精灵图鉴 ====================

function UserDB:recordEncounter(userId, petId)
    local data = self:getOrCreateGameData(userId)
    data.petBook = data.petBook or {}
    local key = tostring(petId)
    
    if not data.petBook[key] then
        data.petBook[key] = { encountered = 0, caught = 0, killed = 0 }
    end
    data.petBook[key].encountered = (data.petBook[key].encountered or 0) + 1
    self:saveGameData(userId, data)
    return data.petBook[key]
end

function UserDB:recordKill(userId, petId)
    local data = self:getOrCreateGameData(userId)
    data.petBook = data.petBook or {}
    local key = tostring(petId)
    
    if not data.petBook[key] then
        data.petBook[key] = { encountered = 1, caught = 0, killed = 0 }
    end
    data.petBook[key].killed = (data.petBook[key].killed or 0) + 1
    self:saveGameData(userId, data)
    return data.petBook[key]
end

function UserDB:recordCatch(userId, petId)
    local data = self:getOrCreateGameData(userId)
    data.petBook = data.petBook or {}
    local key = tostring(petId)
    
    if not data.petBook[key] then
        data.petBook[key] = { encountered = 1, caught = 0, killed = 0 }
    end
    data.petBook[key].caught = 1
    self:saveGameData(userId, data)
    return data.petBook[key]
end

-- ==================== 精灵背包 ====================

function UserDB:addPet(userId, petId, catchTime, level, dv, nature)
    local data = self:getOrCreateGameData(userId)
    data.pets = data.pets or {}
    
    local pet = {
        id = petId,
        catchTime = catchTime,
        level = level or 5,
        dv = dv or 31,
        nature = nature or 0,
        exp = 0,
        name = ""
    }
    
    table.insert(data.pets, pet)
    self:recordCatch(userId, petId)
    self:saveGameData(userId, data)
    
    print(string.format("\27[32m[UserDB] 添加精灵: userId=%d, petId=%d, catchTime=0x%08X\27[0m", 
        userId, petId, catchTime))
    return pet
end

function UserDB:getPets(userId)
    local data = self:getOrCreateGameData(userId)
    return data.pets or {}
end

function UserDB:getPetByCatchTime(userId, catchTime)
    local data = self:getOrCreateGameData(userId)
    for _, pet in ipairs(data.pets or {}) do
        if pet.catchTime == catchTime then
            return pet
        end
    end
    return nil
end

function UserDB:updatePet(userId, catchTime, updates)
    local data = self:getOrCreateGameData(userId)
    for _, pet in ipairs(data.pets or {}) do
        if pet.catchTime == catchTime then
            for k, v in pairs(updates) do
                pet[k] = v
            end
            self:saveGameData(userId, data)
            return pet
        end
    end
    return nil
end

function UserDB:removePet(userId, catchTime)
    local data = self:getOrCreateGameData(userId)
    for i, pet in ipairs(data.pets or {}) do
        if pet.catchTime == catchTime then
            table.remove(data.pets, i)
            self:saveGameData(userId, data)
            return true
        end
    end
    return false
end

-- ==================== 好友管理 ====================

-- 添加好友
function UserDB:addFriend(userId, friendId)
    local data = self:getOrCreateGameData(userId)
    data.friends = data.friends or {}
    
    -- 检查是否已经是好友
    for _, friend in ipairs(data.friends) do
        if friend.userID == friendId then
            return false, "已经是好友"
        end
    end
    
    table.insert(data.friends, {
        userID = friendId,
        timePoke = 0,  -- 戳一戳时间
        addTime = os.time()
    })
    self:saveGameData(userId, data)
    
    print(string.format("\27[32m[UserDB] 添加好友: userId=%d, friendId=%d\27[0m", userId, friendId))
    return true
end

-- 删除好友
function UserDB:removeFriend(userId, friendId)
    local data = self:getOrCreateGameData(userId)
    data.friends = data.friends or {}
    
    for i, friend in ipairs(data.friends) do
        if friend.userID == friendId then
            table.remove(data.friends, i)
            self:saveGameData(userId, data)
            print(string.format("\27[32m[UserDB] 删除好友: userId=%d, friendId=%d\27[0m", userId, friendId))
            return true
        end
    end
    return false
end

-- 获取好友列表
function UserDB:getFriends(userId)
    local data = self:getOrCreateGameData(userId)
    return data.friends or {}
end

-- 检查是否是好友
function UserDB:isFriend(userId, friendId)
    local friends = self:getFriends(userId)
    for _, friend in ipairs(friends) do
        if friend.userID == friendId then
            return true
        end
    end
    return false
end

-- 更新戳一戳时间
function UserDB:updatePoke(userId, friendId)
    local data = self:getOrCreateGameData(userId)
    data.friends = data.friends or {}
    
    for _, friend in ipairs(data.friends) do
        if friend.userID == friendId then
            friend.timePoke = os.time()
            self:saveGameData(userId, data)
            return true
        end
    end
    return false
end

-- ==================== 黑名单管理 ====================

-- 添加黑名单
function UserDB:addBlacklist(userId, targetId)
    local data = self:getOrCreateGameData(userId)
    data.blacklist = data.blacklist or {}
    
    -- 检查是否已在黑名单
    for _, black in ipairs(data.blacklist) do
        if black.userID == targetId then
            return false, "已在黑名单"
        end
    end
    
    -- 如果是好友，先删除好友关系
    self:removeFriend(userId, targetId)
    
    table.insert(data.blacklist, {
        userID = targetId,
        addTime = os.time()
    })
    self:saveGameData(userId, data)
    
    print(string.format("\27[32m[UserDB] 添加黑名单: userId=%d, targetId=%d\27[0m", userId, targetId))
    return true
end

-- 移除黑名单
function UserDB:removeBlacklist(userId, targetId)
    local data = self:getOrCreateGameData(userId)
    data.blacklist = data.blacklist or {}
    
    for i, black in ipairs(data.blacklist) do
        if black.userID == targetId then
            table.remove(data.blacklist, i)
            self:saveGameData(userId, data)
            print(string.format("\27[32m[UserDB] 移除黑名单: userId=%d, targetId=%d\27[0m", userId, targetId))
            return true
        end
    end
    return false
end

-- 获取黑名单
function UserDB:getBlacklist(userId)
    local data = self:getOrCreateGameData(userId)
    return data.blacklist or {}
end

-- 检查是否在黑名单
function UserDB:isBlacklisted(userId, targetId)
    local blacklist = self:getBlacklist(userId)
    for _, black in ipairs(blacklist) do
        if black.userID == targetId then
            return true
        end
    end
    return false
end

-- ==================== 在线状态管理 ====================

-- 记录用户当前所在服务器
function UserDB:setUserServer(userId, serverId)
    local data = self:getOrCreateGameData(userId)
    data.currentServer = serverId
    data.lastOnline = os.time()
    self:saveGameData(userId, data)
end

-- 获取用户当前所在服务器
function UserDB:getUserServer(userId)
    local data = self:getOrCreateGameData(userId)
    return data.currentServer or 0
end

-- 用户下线
function UserDB:setUserOffline(userId)
    local data = self:getOrCreateGameData(userId)
    data.currentServer = 0
    data.lastOnline = os.time()
    self:saveGameData(userId, data)
end

-- 获取好友在各服务器的数量
function UserDB:getFriendsOnServers(userId)
    local friends = self:getFriends(userId)
    local serverCounts = {}  -- serverId -> count
    
    for _, friend in ipairs(friends) do
        local serverId = self:getUserServer(friend.userID)
        if serverId and serverId > 0 then
            serverCounts[serverId] = (serverCounts[serverId] or 0) + 1
        end
    end
    
    return serverCounts
end

-- ==================== NoNo & 仓库管理 ====================

function UserDB:getNonoData(userId)
    local data = self:getOrCreateGameData(userId)
    return data.nono or {flag=0, color=0, nick="NoNo", chip=0, energy=100}
end

function UserDB:updateNonoData(userId, nonoData)
    local data = self:getOrCreateGameData(userId)
    data.nono = data.nono or {}
    for k, v in pairs(nonoData) do
        data.nono[k] = v
    end
    self:saveGameData(userId, data)
    return data.nono
end

function UserDB:getStoragePets(userId)
    local data = self:getOrCreateGameData(userId)
    return data.storagePets or {}
end

function UserDB:addStoragePet(userId, pet)
    local data = self:getOrCreateGameData(userId)
    data.storagePets = data.storagePets or {}
    table.insert(data.storagePets, pet)
    self:saveGameData(userId, data)
    return true
end

return UserDB
