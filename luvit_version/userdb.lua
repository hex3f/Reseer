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

function UserDB:new()
    local obj = {
        dbPath = "./users.json",
        users = {},
        gameData = {}
    }
    setmetatable(obj, UserDB)
    obj:load()
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
            print("\27[32m[UserDB] 加载了 " .. userCount .. " 个用户\27[0m")
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
        -- 从账号数据获取昵称和颜色
        local loginUser = self:findByUserId(userId)
        local nickname = tostring(userId)
        local color = 0x3399FF
        
        if loginUser then
            nickname = loginUser.nickname or nickname
            color = loginUser.color or color
        end
        
        -- 游戏数据 (仅游戏内需要的字段)
        self.gameData[key] = {
            -- 基础信息
            nick = nickname,
            color = color,
            
            -- 货币
            coins = 999999,
            energy = 100,
            
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
            
            -- 位置
            mapId = 515,
            posX = 300,
            posY = 300,
            
            -- 家园系统 - 默认家具
            -- fitments: 正在使用的家具 (摆放在房间里的)
            fitments = {
                {id = 500001, x = 0, y = 0, dir = 0, status = 0}  -- 默认房间风格
            },
            -- allFitments: 所有拥有的家具 (仓库)
            allFitments = {
                {id = 500001, usedCount = 1, allCount = 1}  -- 默认房间风格
            }
        }
        self:save()
        print(string.format("\27[32m[UserDB] 创建游戏数据: userId=%d (含默认家具)\27[0m", userId))
    end
    return self.gameData[key]
end

function UserDB:saveGameData(userId, data)
    self.gameData[tostring(userId)] = data
    self:save()
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

return UserDB
