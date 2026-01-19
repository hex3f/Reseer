-- 任务相关命令处理器
-- 包括: 接受任务、完成任务、任务缓存等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local readUInt32BE = Utils.readUInt32BE
local buildResponse = Utils.buildResponse
local SeerPets = require('../game/seer_pets')

local TaskHandlers = {}

-- ==================== 新手任务处理 ====================

-- 新手任务ID定义
local SeerTaskConfig = require('../data/seer_task_config')

-- 新手任务ID定义
local NOVICE_TASK = {
    GET_CLOTH = 85,      -- 0x55 - 领取服装
    SELECT_PET = 86,     -- 0x56 - 选择精灵
    WIN_BATTLE = 87,     -- 0x57 - 战斗胜利
    USE_ITEM = 88,       -- 0x58 - 使用道具
}

-- 新手三选一精灵映射
-- 根据前端代码分析 (MapProcess_102.as)，选择面板发送位置索引 1,2,3
-- UI 顺序 (从左到右): 布布种子, 小火猴, 伊优
-- grassMC = 布布种子 (petId=1) - 位置1
-- fireMC = 小火猴 (petId=7) - 位置2
-- waterMC = 伊优 (petId=4) - 位置3
local NOVICE_PET_MAP = {
    [1] = 1,   -- 选择1 -> 布布种子
    [2] = 7,   -- 选择2 -> 小火猴
    [3] = 4,   -- 选择3 -> 伊优
}

-- 构建任务完成响应
-- NoviceFinishInfo: taskID(4) + petID(4) + captureTm(4) + itemCount(4) + [itemID(4) + itemCnt(4)]...
-- 构建任务完成响应
-- NoviceFinishInfo: taskID(4) + petID(4) + captureTm(4) + itemCount(4) + [itemID(4) + itemCnt(4)]...
local function buildTaskCompleteResponse(taskId, param, user)
    local taskConfig = SeerTaskConfig.get(taskId)
    -- 如果没有配置，使用默认空响应
    if not taskConfig then
        return writeUInt32BE(taskId) ..
               writeUInt32BE(0) ..
               writeUInt32BE(0) ..
               writeUInt32BE(0), 0
    end

    local rewards = taskConfig.rewards or {}
    local petId = 0
    local captureTm = 0
    local body = ""
    local responseItems = {} -- 收集所有奖励物品用于构建包
    
    -- 1. 处理精灵奖励逻辑
    if taskConfig.type == "select_pet" then
        if taskConfig.paramMap then
             petId = taskConfig.paramMap[param] or 1
        else
             petId = (param > 0) and param or 1
        end
        captureTm = 0x69686700 + petId
        user.currentPetId = petId
        user.catchId = captureTm
        
        -- ★ 关键修复：创建完整精灵对象并添加到 user.pets 数组
        -- 这样登录响应才能正确序列化发送给客户端
        local starterLevel = 5
        local petData = SeerPets.get(petId)
        local stats = SeerPets.getStats(petId, starterLevel, 31, {hp=0, atk=0, def=0, spAtk=0, spDef=0, spd=0})
        local skills = SeerPets.getSkillsForLevel(petId, starterLevel)
        
        local newPet = {
            id = petId,
            name = petData and petData.defName or "",
            dv = 31,  -- 个体值
            nature = math.random(0, 24),  -- 随机性格
            level = starterLevel,
            exp = 0,
            catchTime = captureTm,
            catchMap = 102,  -- 新手教程地图
            catchLevel = starterLevel,
            skinID = 0,
            -- 属性
            hp = stats.hp,
            maxHp = stats.hp,
            attack = stats.attack,
            defence = stats.defence,
            s_a = stats.spAtk,
            s_d = stats.spDef,
            speed = stats.speed,
            -- 努力值
            ev_hp = 0,
            ev_attack = 0,
            ev_defence = 0,
            ev_sa = 0,
            ev_sd = 0,
            ev_sp = 0,
            -- 技能 (转换为技能对象格式)
            skills = {}
        }
        
        -- 转换技能格式
        for i, skillId in ipairs(skills) do
            if skillId and skillId > 0 then
                table.insert(newPet.skills, {id = skillId, pp = 20})
            end
        end
        
        -- 添加到 user.pets 数组
        user.pets = user.pets or {}
        table.insert(user.pets, newPet)
        
        print(string.format("\27[36m[Handler] COMPLETE_TASK %d: Choice=%d -> petId=%d, 已添加到背包\27[0m", taskId, param, petId))
    elseif rewards.petId and rewards.petId > 0 then
        petId = rewards.petId
    end
    
    -- 2. 收集普通物品奖励
    if rewards.items then
        for _, item in ipairs(rewards.items) do
            table.insert(responseItems, {id = item.id, count = item.count})
            
            -- 给用户加物品
            local itemKey = tostring(item.id)
            user.items = user.items or {}
            if user.items[itemKey] then
                user.items[itemKey].count = (user.items[itemKey].count or 1) + item.count
            else
                user.items[itemKey] = {
                    count = item.count,
                    expireTime = 0x057E40
                }
            end
            print(string.format("\27[32m[Handler] 任务奖励: 物品 %d x%d\27[0m", item.id, item.count))
        end
    end
    
    -- 3. 收集特殊奖励 (如金币)
    -- 官服协议将金币等特殊奖励也放在 item 列表里返回，ID为 1, 3, 5 等
    if rewards.special then
        for _, spec in ipairs(rewards.special) do
            table.insert(responseItems, {id = spec.type, count = spec.value})
            
            if spec.type == 1 then -- 金币
                 user.coins = (user.coins or 0) + spec.value
                 print(string.format("\27[32m[Handler] 任务奖励: +%d 金币\27[0m", spec.value))
            end
        end
    end
    
    -- 4. 收集直接金币/经验配置
    if rewards.coins then
        table.insert(responseItems, {id = 1, count = rewards.coins})
        user.coins = (user.coins or 0) + rewards.coins
    end
    
    -- 构建响应包
    body = writeUInt32BE(taskId) ..
           writeUInt32BE(petId) ..
           writeUInt32BE(captureTm) ..
           writeUInt32BE(#responseItems)
           
    for _, item in ipairs(responseItems) do
        body = body .. writeUInt32BE(item.id) .. writeUInt32BE(item.count)
    end
    
    return body, petId
end

-- ==================== 命令处理器 ====================

-- CMD 2201: ACCEPT_TASK (接受任务)
local function handleAcceptTask(ctx)
    local taskId = 0
    if #ctx.body >= 4 then
        taskId = readUInt32BE(ctx.body, 1)
    end
    
    -- 保存任务接受状态
    local user = ctx.getOrCreateUser(ctx.userId)
    if not user.taskList then
        user.taskList = {}
    end
    user.taskList[tostring(taskId)] = 1  -- 1 = ALR_ACCEPT
    ctx.saveUserDB()
    
    ctx.sendResponse(buildResponse(2201, ctx.userId, 0, writeUInt32BE(taskId)))
    print(string.format("\27[32m[Handler] → ACCEPT_TASK %d response\27[0m", taskId))
    
    -- 任务87: 新手战斗教程
    -- 如果客户端没有主动发起战斗，服务端可以主动触发
    -- 但这需要客户端配合，暂时只记录日志
    if taskId == 87 then
        print("\27[33m[Handler] 任务87已接受 - 等待客户端发送 CHALLENGE_BOSS (2411) 开始战斗\27[0m")
        print("\27[33m[Handler] 如果客户端跳过战斗，可能是 isPlay=false 或资源加载失败\27[0m")
    end
    
    return true
end

-- CMD 2202: COMPLETE_TASK (完成任务)
local function handleCompleteTask(ctx)
    local taskId = 0
    local param = 0
    if #ctx.body >= 4 then
        taskId = readUInt32BE(ctx.body, 1)
    end
    if #ctx.body >= 8 then
        param = readUInt32BE(ctx.body, 5)
    end
    
    print(string.format("\27[36m[Handler] COMPLETE_TASK taskId=%d param=%d\27[0m", taskId, param))
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local body, petId = buildTaskCompleteResponse(taskId, param, user)
    
    -- 保存任务完成状态
    if not user.taskList then
        user.taskList = {}
    end
    user.taskList[tostring(taskId)] = 3  -- 3 = COMPLETE
    
    if petId > 0 then
        ctx.saveUserDB()
    else
        ctx.saveUserDB()
    end
    
    ctx.sendResponse(buildResponse(2202, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → COMPLETE_TASK %d response (petId=%d)\27[0m", taskId, petId))
    return true
end

-- CMD 2203: GET_TASK_BUF (获取任务缓存)
-- 请求: taskId(4)
-- 响应: taskId(4) + flag(4) + buf (20 字节)
-- 官服格式: taskId(4) + flag(4) + buf[0..4] (每个4字节)
local function handleGetTaskBuf(ctx)
    local taskId = 0
    if #ctx.body >= 4 then
        taskId = readUInt32BE(ctx.body, 1)
    end
    
    -- 从用户数据获取任务缓存
    local user = ctx.getOrCreateUser(ctx.userId)
    if not user.taskBufs then user.taskBufs = {} end
    local taskBuf = user.taskBufs[tostring(taskId)] or {}
    
    -- 构建响应: taskId(4) + flag(4) + buf[0..4] (5个4字节 = 20字节缓存)
    local body = writeUInt32BE(taskId) ..
                 writeUInt32BE(1)  -- flag = 1 表示有缓存数据
    
    -- 添加5个缓存值            
    for i = 0, 4 do
        local val = taskBuf[i] or 0
        body = body .. writeUInt32BE(val)
    end
    
    ctx.sendResponse(buildResponse(2203, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → GET_TASK_BUF taskId=%d\27[0m", taskId))
    return true
end

-- CMD 2204: ADD_TASK_BUF (添加/更新任务缓存)
-- 请求: taskId(4) + index(1) + value (20字节缓存数据)
-- 响应: 空
local function handleAddTaskBuf(ctx)
    local taskId = 0
    local index = 0
    local value = 0
    
    if #ctx.body >= 4 then
        taskId = readUInt32BE(ctx.body, 1)
    end
    if #ctx.body >= 5 then
        index = string.byte(ctx.body, 5) or 0
    end
    if #ctx.body >= 9 then
        value = readUInt32BE(ctx.body, 6)
    end
    
    -- 保存任务缓存
    local user = ctx.getOrCreateUser(ctx.userId)
    if not user.taskBufs then user.taskBufs = {} end
    if not user.taskBufs[tostring(taskId)] then
        user.taskBufs[tostring(taskId)] = {}
    end
    user.taskBufs[tostring(taskId)][index] = value
    ctx.saveUserDB()
    
    -- 响应: 空
    ctx.sendResponse(buildResponse(2204, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → ADD_TASK_BUF taskId=%d index=%d value=%d\27[0m", taskId, index, value))
    return true
end

-- CMD 2234: GET_DAILY_TASK_BUF (获取每日任务缓存)
local function handleGetDailyTaskBuf(ctx)
    local body = writeUInt32BE(0) .. writeUInt32BE(0)
    ctx.sendResponse(buildResponse(2234, ctx.userId, 0, body))
    print("\27[32m[Handler] → GET_DAILY_TASK_BUF response\27[0m")
    return true
end

-- 注册所有处理器
-- 注意: PEOPLE_WALK (2101) 在 map_handlers.lua 中注册
-- 注意: NONO_GET_CHIP (9023) 在 nono_handlers.lua 中注册
function TaskHandlers.register(Handlers)
    Handlers.register(2201, handleAcceptTask)
    Handlers.register(2202, handleCompleteTask)
    Handlers.register(2203, handleGetTaskBuf)
    Handlers.register(2204, handleAddTaskBuf)
    Handlers.register(2234, handleGetDailyTaskBuf)
    print("\27[36m[Handlers] 任务命令处理器已注册\27[0m")
end

return TaskHandlers

