-- 用户数据库 - 简单的JSON文件存储
local fs = require "fs"
local json = require "json"

local UserDB = {}
UserDB.__index = UserDB

function UserDB:new()
    local obj = {
        dbPath = "./users.json",
        users = {},
        -- 游戏数据存储 (按userId索引)
        gameData = {}
    }
    setmetatable(obj, UserDB)
    obj:load()
    return obj
end

-- 加载用户数据
function UserDB:load()
    if fs.existsSync(self.dbPath) then
        local data = fs.readFileSync(self.dbPath)
        local success, result = pcall(function()
            return json.parse(data)
        end)
        if success and result then
            self.users = result.users or result  -- 兼容旧格式
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

-- 保存用户数据
function UserDB:save()
    local data = json.stringify({
        users = self.users,
        gameData = self.gameData
    })
    fs.writeFileSync(self.dbPath, data)
end

-- 查找用户（通过邮箱）
function UserDB:findByEmail(email)
    for id, user in pairs(self.users) do
        if user.email == email then
            user.userId = tonumber(id) or user.userId
            return user
        end
    end
    return nil
end

-- 查找用户（通过用户名）
function UserDB:findByUsername(username)
    for id, user in pairs(self.users) do
        if user.username == username then
            user.userId = tonumber(id) or user.userId
            return user
        end
    end
    return nil
end

-- 查找用户（通过userId）
function UserDB:findByUserId(userId)
    local key = tostring(userId)
    if self.users[key] then
        self.users[key].userId = userId
        return self.users[key]
    end
    return nil
end

-- 保存单个用户
function UserDB:saveUser(user)
    if user and user.userId then
        local key = tostring(user.userId)
        self.users[key] = user
        self:save()
    end
end

-- 创建用户
function UserDB:createUser(email, password, username)
    -- 检查邮箱是否已存在
    if self:findByEmail(email) then
        return nil, "邮箱已被注册"
    end
    
    -- 检查用户名是否已存在
    if username and self:findByUsername(username) then
        return nil, "用户名已被使用"
    end
    
    -- 生成新的userId (从100000001开始)
    local maxId = 100000000
    for id, _ in pairs(self.users) do
        local numId = tonumber(id)
        if numId and numId > maxId then
            maxId = numId
        end
    end
    local newUserId = maxId + 1
    
    local user = {
        userId = newUserId,
        email = email,
        password = password,  -- 实际应该加密存储
        username = username or ("玩家" .. newUserId),
        registerTime = os.time(),
        lastLoginTime = os.time(),
        vipLevel = 10,
        coins = 999999,
        diamonds = 9999,
        level = 100,
        exp = 0
    }
    
    self.users[tostring(newUserId)] = user
    self:save()
    
    print(string.format("\27[32m[UserDB] 创建新用户: %s (ID: %d)\27[0m", user.username, newUserId))
    return user
end

-- 验证登录
function UserDB:verifyLogin(email, password)
    local user = self:findByEmail(email)
    if not user then
        return nil, "用户不存在"
    end
    
    if user.password ~= password then
        return nil, "密码错误"
    end
    
    -- 更新最后登录时间
    user.lastLoginTime = os.time()
    self:save()
    
    return user
end

-- 获取或创建游戏数据
function UserDB:getOrCreateGameData(userId)
    local key = tostring(userId)
    if not self.gameData[key] then
        self.gameData[key] = {
            -- 基础信息
            nick = "玩家" .. userId,
            color = 0x3399FF,
            texture = 0,
            mapId = 1,
            posX = 300,
            posY = 300,
            
            -- 货币
            coins = 999999,
            energy = 100,
            
            -- 精灵
            pets = {},
            petNum = 0,
            defaultPetIndex = 0,
            
            -- 物品/服装
            items = {},
            clothes = {},
            
            -- 任务
            tasks = {},
            taskList = {},
            
            -- NONO
            nono = nil,
            
            -- 战队
            teamId = 0,
            
            -- 其他
            regTime = os.time(),
            vipLevel = 10,
            vipValue = 9999,
            superNono = 1
        }
        self:save()
    end
    return self.gameData[key]
end

-- 保存游戏数据
function UserDB:saveGameData(userId, data)
    local key = tostring(userId)
    self.gameData[key] = data
    self:save()
end

-- 生成session
function UserDB:generateSession(userId)
    return "local_session_" .. userId .. "_" .. os.time()
end

-- 生成token
function UserDB:generateToken(userId)
    return "local_token_" .. userId .. "_" .. os.time()
end

-- 添加物品
function UserDB:addItem(userId, itemId, count)
    local data = self:getOrCreateGameData(userId)
    data.items = data.items or {}
    
    local key = tostring(itemId)
    if data.items[key] then
        data.items[key].count = (data.items[key].count or 1) + (count or 1)
    else
        data.items[key] = {
            count = count or 1,
            expireTime = 0x057E40  -- 永久
        }
    end
    self:saveGameData(userId, data)
    return true
end

-- 移除物品
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

-- 获取物品数量
function UserDB:getItemCount(userId, itemId)
    local data = self:getOrCreateGameData(userId)
    data.items = data.items or {}
    
    local key = tostring(itemId)
    if data.items[key] then
        return data.items[key].count or 0
    end
    return 0
end

-- ==================== 精灵图鉴统计 ====================

-- 记录遭遇精灵 (进入战斗时调用)
function UserDB:recordEncounter(userId, petId)
    local data = self:getOrCreateGameData(userId)
    data.petBook = data.petBook or {}
    
    local key = tostring(petId)
    if not data.petBook[key] then
        data.petBook[key] = {
            encountered = 0,
            caught = 0,
            killed = 0
        }
    end
    
    data.petBook[key].encountered = (data.petBook[key].encountered or 0) + 1
    self:saveGameData(userId, data)
    
    print(string.format("\27[36m[UserDB] 记录遭遇: userId=%d, petId=%d, 遭遇次数=%d\27[0m", 
        userId, petId, data.petBook[key].encountered))
    return data.petBook[key]
end

-- 记录击败精灵 (战斗胜利时调用)
function UserDB:recordKill(userId, petId)
    local data = self:getOrCreateGameData(userId)
    data.petBook = data.petBook or {}
    
    local key = tostring(petId)
    if not data.petBook[key] then
        data.petBook[key] = {
            encountered = 1,  -- 击败必然遭遇过
            caught = 0,
            killed = 0
        }
    end
    
    data.petBook[key].killed = (data.petBook[key].killed or 0) + 1
    self:saveGameData(userId, data)
    
    print(string.format("\27[36m[UserDB] 记录击败: userId=%d, petId=%d, 击败次数=%d\27[0m", 
        userId, petId, data.petBook[key].killed))
    return data.petBook[key]
end

-- 记录捕获精灵 (捕获成功时调用)
function UserDB:recordCatch(userId, petId)
    local data = self:getOrCreateGameData(userId)
    data.petBook = data.petBook or {}
    
    local key = tostring(petId)
    if not data.petBook[key] then
        data.petBook[key] = {
            encountered = 1,  -- 捕获必然遭遇过
            caught = 0,
            killed = 0
        }
    end
    
    data.petBook[key].caught = 1  -- 是否捕获只记录0/1
    self:saveGameData(userId, data)
    
    print(string.format("\27[36m[UserDB] 记录捕获: userId=%d, petId=%d\27[0m", userId, petId))
    return data.petBook[key]
end

-- 获取精灵图鉴数据
function UserDB:getPetBook(userId)
    local data = self:getOrCreateGameData(userId)
    data.petBook = data.petBook or {}
    return data.petBook
end

-- 获取单个精灵的图鉴记录
function UserDB:getPetBookEntry(userId, petId)
    local data = self:getOrCreateGameData(userId)
    data.petBook = data.petBook or {}
    
    local key = tostring(petId)
    return data.petBook[key] or {
        encountered = 0,
        caught = 0,
        killed = 0
    }
end

return UserDB
