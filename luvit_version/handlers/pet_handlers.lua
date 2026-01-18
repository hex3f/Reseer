-- 精灵相关命令处理器
-- 包括: 获取精灵信息、释放精灵、展示精灵、图鉴等

local Utils = require('./utils')
local Pets = require('../seer_pets')
local Pets = require('../seer_pets')
-- local Monsters = require('../seer_monsters') -- Not used for skills anymore
local Skills = require('../seer_skills')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local PetHandlers = {}

-- 初始化时加载精灵数据库
-- 初始化时加载数据库
-- Monsters.load()
Skills.load()
Pets.load()

-- ==================== 精灵数据构建 ====================

-- 构建完整版 PetInfo (param2=true)
-- 用于 GET_PET_INFO (2301), PET_RELEASE (2304) 等
-- 官服格式 (183 bytes): 基础信息 + 属性 + 努力值 + 技能 + 捕获信息 + 特效 + skinID
local function buildFullPetInfo(petId, catchTime, level)
    level = level or 5
    
    -- 使用精灵数据库创建实例
    local pet = Pets.createStarterPet(petId, level)
    
    local body = ""
    -- 基础信息 (60 bytes)
    body = body .. writeUInt32BE(petId)          -- id (4)
    body = body .. string.rep("\0", 16)          -- name (16字节) - 野生精灵名字为空
    body = body .. writeUInt32BE(pet.iv)         -- dv (个体值) (4)
    body = body .. writeUInt32BE(pet.nature)     -- nature (性格) (4)
    body = body .. writeUInt32BE(level)          -- level (4)
    
    -- 经验值信息 (16 bytes)
    local expInfo = Pets.getExpInfo(petId, level, pet.exp)
    body = body .. writeUInt32BE(expInfo.exp)        -- exp (4)
    body = body .. writeUInt32BE(expInfo.lvExp)      -- lvExp (4)
    body = body .. writeUInt32BE(expInfo.nextLvExp)  -- nextLvExp (4)
    body = body .. writeUInt32BE(0)                  -- padding (4)
    
    -- 战斗属性 (28 bytes)
    body = body .. writeUInt32BE(pet.hp)         -- hp (4)
    body = body .. writeUInt32BE(pet.maxHp)      -- maxHp (4)
    body = body .. writeUInt32BE(pet.attack)     -- attack (4)
    body = body .. writeUInt32BE(pet.defence)    -- defence (4)
    body = body .. writeUInt32BE(pet.s_a)        -- s_a (特攻) (4)
    body = body .. writeUInt32BE(pet.s_d)        -- s_d (特防) (4)
    body = body .. writeUInt32BE(pet.speed)      -- speed (4)
    
    -- 努力值 (24 bytes)
    body = body .. writeUInt32BE(pet.ev.hp)      -- ev_hp (4)
    body = body .. writeUInt32BE(pet.ev.atk)     -- ev_attack (4)
    body = body .. writeUInt32BE(pet.ev.def)     -- ev_defence (4)
    body = body .. writeUInt32BE(pet.ev.spa)     -- ev_sa (4)
    body = body .. writeUInt32BE(pet.ev.spd)     -- ev_sd (4)
    body = body .. writeUInt32BE(pet.ev.spe)     -- ev_sp (4)
    
    -- 技能列表 (动态长度)
    local validSkills = {}
    local rawSkills = pet.skills or {10001, 0, 0, 0}
    for i = 1, 4 do
        local sid = rawSkills[i] or 0
        if sid > 0 then
            table.insert(validSkills, sid)
        end
    end
    
    body = body .. writeUInt32BE(#validSkills)   -- skillNum (4)
    
    -- 写入有效技能 (每个技能 8 bytes)
    for _, sid in ipairs(validSkills) do
        local skill = Skills.get(sid)
        local pp = skill and skill.pp or 20
        body = body .. writeUInt32BE(sid)        -- skillID (4)
        body = body .. writeUInt32BE(pp)         -- pp (4)
    end
    
    -- 捕获信息 (16 bytes)
    body = body .. writeUInt32BE(catchTime)      -- catchTime (4)
    body = body .. writeUInt32BE(pet.catchMap)   -- catchMap (4)
    body = body .. writeUInt32BE(0)              -- catchRect (4)
    body = body .. writeUInt32BE(pet.catchLevel) -- catchLevel (4)
    
    -- 特效列表 (2 bytes + 动态)
    body = body .. writeUInt16BE(0)              -- effectCount (2字节)
    -- 如果 effectCount > 0，这里应该有 effectList，但我们没有特效
    
    -- skinID (4 bytes)
    body = body .. writeUInt32BE(0)              -- skinID (4)
    
    return body
end

-- 构建简化版 PetInfo (param2=false)
-- 用于战斗准备 NoteReadyToFightInfo
local function buildSimplePetInfo(petId, level, hp, maxHp, catchTime)
    level = level or 5
    
    -- 使用精灵数据库获取数据
    local pet = Pets.createStarterPet(petId, level)
    hp = hp or pet.hp
    maxHp = maxHp or pet.maxHp
    catchTime = catchTime or 0
    
    local body = ""
    body = body .. writeUInt32BE(petId)          -- id (4)
    body = body .. writeUInt32BE(level)          -- level (4)
    body = body .. writeUInt32BE(hp)             -- hp (4)
    body = body .. writeUInt32BE(maxHp)          -- maxHp (4)
    -- 过滤有效技能
    local validSkills = {}
    local rawSkills = pet.skills or {10001, 0, 0, 0}
    for i = 1, 4 do
        local sid = rawSkills[i] or 0
        if sid > 0 then
            table.insert(validSkills, sid)
        end
    end

    body = body .. writeUInt32BE(#validSkills)   -- skillNum
    
    -- 写入有效技能
    for _, sid in ipairs(validSkills) do
        -- 简化版我们也尽量给个合理PP
        body = body .. writeUInt32BE(sid) .. writeUInt32BE(20) 
    end
    body = body .. writeUInt32BE(catchTime)      -- catchTime (4)
    body = body .. writeUInt32BE(301)            -- catchMap (4)
    body = body .. writeUInt32BE(0)              -- catchRect (4)
    body = body .. writeUInt32BE(level)          -- catchLevel (4)
    -- 注意: 简化版 PetInfo (param2=false) 没有 effectCount，直接读取 skinID
    body = body .. writeUInt32BE(0)              -- skinID (4)
    
    return body
end

-- ==================== 命令处理器 ====================

-- CMD 2301: GET_PET_INFO (获取精灵信息)
local function handleGetPetInfo(ctx)
    local petCatchId = 0
    if #ctx.body >= 4 then
        petCatchId = readUInt32BE(ctx.body, 1)
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local petId = user.currentPetId or 7
    
    local body = buildFullPetInfo(petId, petCatchId)
    ctx.sendResponse(buildResponse(2301, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → GET_PET_INFO catchId=%d\27[0m", petCatchId))
    return true
end

-- CMD 2303: GET_PET_LIST (获取精灵列表)
local function handleGetPetList(ctx)
    ctx.sendResponse(buildResponse(2303, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → GET_PET_LIST response\27[0m")
    return true
end

-- CMD 2304: PET_RELEASE (释放精灵)
-- 请求: catchId(4) + flag(4)
-- flag: 0=从背包释放, 1=从仓库释放
-- PetTakeOutInfo响应: homeEnergy(4) + firstPetTime(4) + flag(4) + [PetInfo]
local function handlePetRelease(ctx)
    local catchId = 0
    local flag = 0
    
    -- 解析请求参数
    if ctx.body and #ctx.body >= 4 then
        catchId = readUInt32BE(ctx.body, 1)
    end
    if ctx.body and #ctx.body >= 8 then
        flag = readUInt32BE(ctx.body, 5)
    end
    
    -- 从 catchId 提取 petType (catchId = 0x69686700 + petType)
    local petType = catchId - 0x69686700
    if petType < 1 or petType > 1000 then
        petType = 7  -- 默认精灵
    end
    
    print(string.format("\27[36m[Handler] PET_RELEASE: body=%d bytes, catchId=0x%X, flag=%d, petType=%d\27[0m", 
        ctx.body and #ctx.body or 0, catchId, flag, petType))
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.currentPetId = petType
    user.catchId = catchId
    ctx.saveUserDB()
    
    -- 构建 PetTakeOutInfo 响应
    local body = ""
    body = body .. writeUInt32BE(0)              -- homeEnergy = 0 (Official)
    body = body .. writeUInt32BE(catchId)        -- firstPetTime (使用 catchId)
    body = body .. writeUInt32BE(1)              -- flag (有精灵信息)
    body = body .. buildFullPetInfo(petType, catchId)
    
    print(string.format("\27[36m[Handler] PET_RELEASE body length: %d bytes\27[0m", #body))
    
    local response = buildResponse(2304, ctx.userId, 0, body)
    print(string.format("\27[36m[Handler] PET_RELEASE response length: %d bytes\27[0m", #response))
    
    ctx.sendResponse(response)
    print(string.format("\27[32m[Handler] → PET_RELEASE sent (catchId=0x%X petType=%d)\27[0m", catchId, petType))
    return true
end

-- CMD 2305: PET_SHOW (展示精灵)
-- PetShowInfo: userID(4) + catchTime(4) + petID(4) + flag(4) + dv(4) + shiny(4) + skinID(4) + ride(4) + padding(8)
local function handlePetShow(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local petId = user.currentPetId or 7
    local catchTime = user.catchId or (0x69686700 + petId)
    
    local body = writeUInt32BE(ctx.userId) ..
                writeUInt32BE(catchTime) ..
                writeUInt32BE(petId) ..
                writeUInt32BE(1) ..           -- flag
                writeUInt32BE(31) ..          -- dv
                writeUInt32BE(0) ..           -- shiny
                writeUInt32BE(0) ..           -- skinID
                writeUInt32BE(0) ..           -- ride
                writeUInt32BE(0) ..           -- padding1
                writeUInt32BE(0)              -- padding2
    
    ctx.sendResponse(buildResponse(2305, ctx.userId, 0, body))
    print("\27[32m[Handler] → PET_SHOW response\27[0m")
    return true
end

-- CMD 2306: PET_CURE (治疗精灵)
local function handlePetCure(ctx)
    ctx.sendResponse(buildResponse(2306, ctx.userId, 0, ""))
    print("\27[32m[Handler] → PET_CURE response\27[0m")
    return true
end

-- CMD 2309: PET_BARGE_LIST (精灵图鉴列表)
-- 请求: type(4) + maxId(4)
-- 官服响应: maxId(4) + flag(4) + [unknown(4) + encountered(4) + caught(4) + petId(4)]...
-- 返回全部精灵，格式与官服一致
local function handlePetBargeList(ctx)
    local reqType = 1
    local maxId = 1498  -- 默认最大精灵ID
    
    if ctx.body and #ctx.body >= 4 then
        reqType = readUInt32BE(ctx.body, 1)
    end
    if ctx.body and #ctx.body >= 8 then
        maxId = readUInt32BE(ctx.body, 5)
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    
    -- 获取用户独立的图鉴记录
    local userPetBook = {}
    if ctx.userDB and ctx.userDB.getPetBook then
        userPetBook = ctx.userDB:getPetBook(ctx.userId)
    end
    
    -- 从 XML 获取精灵数据以确定实际存在的精灵
    -- 如果没有加载 Pets，则使用请求的 maxId
    local actualMaxId = maxId
    
    -- 构建响应头: maxId(4) + flag(4)
    local body = writeUInt32BE(maxId) .. writeUInt32BE(reqType)
    
    -- 遍历所有精灵 ID (1 到 maxId)
    for petId = 1, maxId do
        local petIdStr = tostring(petId)
        local userRecord = userPetBook[petIdStr] or {}
        
        -- 检查用户是否拥有此精灵
        local encountered = userRecord.encountered or 0
        local caught = userRecord.caught or 0
        local killed = userRecord.killed or 0
        
        -- 如果用户拥有该精灵，标记为已捕获
        if user.pets and user.pets[petIdStr] then
            caught = 1
            encountered = math.max(encountered, 1)
        end
        
        -- 官服格式: unknown(4) + encountered(4) + caught(4) + petId(4)
        body = body .. writeUInt32BE(0)            -- unknown (总是0)
        body = body .. writeUInt32BE(encountered)  -- 遭遇次数
        body = body .. writeUInt32BE(caught)       -- 是否捕获
        body = body .. writeUInt32BE(petId)        -- 精灵ID
    end
    
    ctx.sendResponse(buildResponse(2309, ctx.userId, 0, body))
    print(string.format("\\27[32m[Handler] → PET_BARGE_LIST response (%d pets, maxId=%d)\\27[0m", maxId, maxId))
    return true
end

-- CMD 2354: GET_SOUL_BEAD_LIST (获取灵魂珠列表)
local function handleGetSoulBeadList(ctx)
    ctx.sendResponse(buildResponse(2354, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → GET_SOUL_BEAD_LIST response\27[0m")
    return true
end

-- 注册所有处理器
function PetHandlers.register(Handlers)
    Handlers.register(2301, handleGetPetInfo)
    Handlers.register(2303, handleGetPetList)
    Handlers.register(2304, handlePetRelease)
    Handlers.register(2305, handlePetShow)
    Handlers.register(2306, handlePetCure)
    Handlers.register(2309, handlePetBargeList)
    Handlers.register(2354, handleGetSoulBeadList)
    print("\27[36m[Handlers] 精灵命令处理器已注册\27[0m")
end

-- 导出构建函数供其他模块使用
PetHandlers.buildFullPetInfo = buildFullPetInfo
PetHandlers.buildSimplePetInfo = buildSimplePetInfo

return PetHandlers
