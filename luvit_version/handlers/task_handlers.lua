-- 任务相关命令处理器
-- 包括: 接受任务、完成任务、任务缓存等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local readUInt32BE = Utils.readUInt32BE
local buildResponse = Utils.buildResponse

local TaskHandlers = {}

-- ==================== 新手任务处理 ====================

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

-- 新手任务奖励配置 (与官服数据一致)
local NOVICE_REWARDS = {
    -- 任务85: 领取服装 - 官服抓包数据
    [85] = {
        petId = 0,
        items = {
            {id = 0x0186BB, count = 1},  -- 100027 服装
            {id = 0x0186BC, count = 1},  -- 100028 服装
            {id = 0x07A121, count = 1},  -- 500001 道具
            {id = 0x04966A, count = 3},  -- 300650 精灵道具
            {id = 0x0493F9, count = 3},  -- 300025 精灵道具
            {id = 0x049403, count = 3},  -- 300035 精灵道具
            {id = 0x07A316, count = 1},  -- 500502 道具
            {id = 0x07A317, count = 1},  -- 500503 道具
        }
    },
    -- 任务86: 选择精灵 - 获得选择的精灵 (使用NOVICE_PET_MAP映射)
    [86] = {
        petId = "param_mapped",  -- 使用映射后的精灵ID
        items = {}
    },
    -- 任务87: 战斗胜利 - 官服抓包数据
    [87] = {
        petId = 0,
        items = {
            {id = 0x0493E1, count = 5},  -- 300001 精灵道具
            {id = 0x0493EB, count = 3},  -- 300011 精灵道具
        }
    },
    -- 任务88: 使用道具 - 官服抓包数据
    [88] = {
        petId = 0,
        items = {
            {id = 1, count = 50000},     -- 金币 (0x00C350)
            {id = 3, count = 250000},    -- 经验? (0x03D090)
            {id = 5, count = 20},        -- 其他 (0x000014)
        }
    },
}

-- 构建任务完成响应
-- NoviceFinishInfo: taskID(4) + petID(4) + captureTm(4) + itemCount(4) + [itemID(4) + itemCnt(4)]...
local function buildTaskCompleteResponse(taskId, param, user)
    local reward = NOVICE_REWARDS[taskId]
    local petId = 0
    local captureTm = 0
    local body = ""
    
    if reward then
        -- 处理精灵奖励
        if reward.petId == "param_mapped" then
            -- 新手三选一精灵：使用映射表
            petId = NOVICE_PET_MAP[param] or param
            if petId == 0 then petId = 1 end  -- 默认布布种子
            captureTm = 0x69686700 + petId
            user.currentPetId = petId
            user.catchId = captureTm  -- 保存 catchId 供 PET_RELEASE 使用
            print(string.format("\27[36m[Handler] COMPLETE_TASK 86: param=%d -> petId=%d, catchId=0x%X\27[0m", param, petId, captureTm))
        elseif reward.petId == "param" then
            -- 直接使用参数作为精灵ID
            petId = param > 0 and param or 7
            captureTm = 0x69686700 + petId
            user.currentPetId = petId
            user.catchId = captureTm
        else
            petId = reward.petId
        end
        
        -- 构建响应
        body = writeUInt32BE(taskId) ..
               writeUInt32BE(petId) ..
               writeUInt32BE(captureTm) ..
               writeUInt32BE(#reward.items)
        
        -- 添加物品到用户背包并构建响应
        user.items = user.items or {}
        for _, item in ipairs(reward.items) do
            body = body .. writeUInt32BE(item.id) .. writeUInt32BE(item.count)
            
            -- 真正添加物品到用户数据 (id=1 是金币，特殊处理)
            if item.id == 1 then
                user.coins = (user.coins or 0) + item.count
                print(string.format("\27[32m[Handler] 任务奖励: +%d 金币 (总计: %d)\27[0m", item.count, user.coins))
            else
                local itemKey = tostring(item.id)
                if user.items[itemKey] then
                    user.items[itemKey].count = (user.items[itemKey].count or 1) + item.count
                else
                    user.items[itemKey] = {
                        count = item.count,
                        expireTime = 0x057E40  -- 永久
                    }
                end
                print(string.format("\27[32m[Handler] 任务奖励: 物品 %d x%d\27[0m", item.id, item.count))
            end
        end
    else
        -- 默认响应: 无奖励
        body = writeUInt32BE(taskId) ..
               writeUInt32BE(0) ..
               writeUInt32BE(0) ..
               writeUInt32BE(0)
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
    user.taskList[taskId] = 1  -- 1 = ALR_ACCEPT
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
    user.taskList[taskId] = 3  -- 3 = COMPLETE
    
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
-- TaskBufInfo: taskId(4) + flag(4) + buf(剩余字节)
local function handleGetTaskBuf(ctx)
    local body = writeUInt32BE(0) .. writeUInt32BE(0)
    ctx.sendResponse(buildResponse(2203, ctx.userId, 0, body))
    print("\27[32m[Handler] → GET_TASK_BUF response\27[0m")
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
function TaskHandlers.register(Handlers)
    Handlers.register(2201, handleAcceptTask)
    Handlers.register(2202, handleCompleteTask)
    Handlers.register(2203, handleGetTaskBuf)
    Handlers.register(2234, handleGetDailyTaskBuf)
    print("\27[36m[Handlers] 任务命令处理器已注册\27[0m")
end

return TaskHandlers
