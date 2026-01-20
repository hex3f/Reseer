-- 精灵相关命令处理器
-- 包括: 获取精灵信息、释放精灵、展示精灵、图鉴等
-- Protocol Version: 2026-01-20 (Refactored for Strict Frontend Compliance)

local BinaryWriter = require('utils/binary_writer')
local BinaryReader = require('utils/binary_reader')
local ResponseBuilder = require('utils/response_builder')
local Utils = { buildResponse = ResponseBuilder.build } -- Backward compatibility shim
local Pets = require('game/seer_pets')
local Skills = require('game/seer_skills')
local GameConfig = require('config/game_config')
local buildResponse = Utils.buildResponse

local PetHandlers = {}

-- 初始化时加载精灵数据库
Skills.load()
Pets.load()

-- ==================== 精灵数据构建 (Protocol Helpers) ====================

-- 构建完整版 PetInfo
-- 对应前端: com.robot.core.info.pet.PetInfo (isDefault/param2 = true)
-- 结构 check:
-- id(4) + name(16) + dv(4) + nature(4) + level(4) + exp(4) + lvExp(4) + nextLvExp(4) +
-- hp(4) + maxHp(4) + atk(4) + def(4) + sa(4) + sd(4) + spd(4) +
-- ev_hp(4) + ev_atk(4) + ev_def(4) + ev_sa(4) + ev_sd(4) + ev_sp(4) +
-- skillNum(4) + [id(4)+pp(4)]*4 +
-- catchTime(4) + catchMap(4) + catchRect(4) + catchLevel(4) +
-- effectCount(2) + [PetEffectInfo]*count +
-- skinID(4)
local function buildFullPetInfo(petId, catchTime, level)
    local defaults = GameConfig.PetDefaults or {}
    level = level or defaults.level or 5
    catchTime = catchTime or 0
    
    -- 使用精灵数据库创建实例
    local pet = Pets.createStarterPet(petId, level)
    
    -- 确保所有字段都有默认值
    pet.iv = pet.iv or 31
    pet.nature = pet.nature or 0
    pet.exp = pet.exp or 0
    
    -- 经验值信息
    local expInfo = Pets.getExpInfo(petId, level, pet.exp)
    
    -- 确保 ev 表存在
    if not pet.ev then
        pet.ev = {hp=0, atk=0, def=0, spa=0, spd=0, spe=0}
    end
    
    local writer = BinaryWriter.new()
    
    -- 1. 基础信息
    writer:writeUInt32BE(petId)                  -- id (4)
    writer:writeStringFixed("", 16)              -- name (16) -- TODO: Allow setting name
    writer:writeUInt32BE(pet.iv)                 -- dv (4)
    writer:writeUInt32BE(pet.nature)             -- nature (4)
    writer:writeUInt32BE(level)                  -- level (4)
    writer:writeUInt32BE(expInfo.exp or 0)       -- exp (4)
    writer:writeUInt32BE(expInfo.lvExp or 0)     -- lvExp (4)
    writer:writeUInt32BE(expInfo.nextLvExp or 0) -- nextLvExp (4)
    
    -- 2. 战斗属性
    writer:writeUInt32BE(pet.hp or 100)          -- hp (4)
    writer:writeUInt32BE(pet.maxHp or 100)       -- maxHp (4)
    writer:writeUInt32BE(pet.attack or 50)       -- attack (4)
    writer:writeUInt32BE(pet.defence or 50)      -- defence (4)
    writer:writeUInt32BE(pet.s_a or 50)          -- s_a (4)
    writer:writeUInt32BE(pet.s_d or 50)          -- s_d (4)
    writer:writeUInt32BE(pet.speed or 50)        -- speed (4)
    
    -- 3. 努力值
    writer:writeUInt32BE(pet.ev.hp or 0)         -- ev_hp (4)
    writer:writeUInt32BE(pet.ev.atk or 0)        -- ev_attack (4)
    writer:writeUInt32BE(pet.ev.def or 0)        -- ev_defence (4)
    writer:writeUInt32BE(pet.ev.spa or 0)        -- ev_sa (4)
    writer:writeUInt32BE(pet.ev.spd or 0)        -- ev_sd (4)
    writer:writeUInt32BE(pet.ev.spe or 0)        -- ev_sp (4)
    
    -- 4. 技能列表 (PetSkillInfo: id(4) + pp(4))
    -- 前端 logic: skillNum = readUInt32BE; while(i < 4) { read...; if id!=0 push }
    -- 所以后端必须写满 4 个槽位
    local rawSkills = pet.skills or {}
    
    -- 计算有效技能数（虽然 protocol 要求写 4 个 struct，但 skillNum 字段只是告诉前端有多少个）
    -- 查阅 PetInfo.as: this.skillNum = read(); while(i<4){...}; this.skillArray.slice(0, skillNum)
    -- 所以 written count 必须是 4，但 skillNum 值是有效技能数。
    local validCount = 0
    for i = 1, 4 do
        if rawSkills[i] and rawSkills[i] > 0 then
            validCount = validCount + 1
        end
    end
    writer:writeUInt32BE(validCount)
    
    for i = 1, 4 do
        local sid = rawSkills[i] or 0
        local pp = 0
        if sid > 0 then
            local skill = Skills.get(sid)
            pp = skill and skill.pp or 20
        end
        writer:writeUInt32BE(sid)                -- id (4)
        writer:writeUInt32BE(pp)                 -- pp (4)
    end
    
    -- 5. 捕获信息
    writer:writeUInt32BE(catchTime)              -- catchTime (4)
    writer:writeUInt32BE(pet.catchMap or 301)    -- catchMap (4)
    writer:writeUInt32BE(0)                      -- catchRect (4)
    writer:writeUInt32BE(pet.catchLevel or level)-- catchLevel (4)
    
    -- 6. 特效列表 (PetEffectInfo)
    -- count(2) + [EffectInfo]
    writer:writeUInt16BE(0)                      -- effectCount (2)
    -- If count > 0, write PetEffectInfo structs (24 bytes each)
    
    -- 7. Skin
    writer:writeUInt32BE(0)                      -- skinID (4)
    
    return writer:toString()
end

-- 构建简化版 PetInfo (用于战斗准备)
-- 对应前端: com.robot.core.info.pet.PetInfo (param2 = false)
local function buildSimplePetInfo(petId, level, hp, maxHp, catchTime)
    local defaults = GameConfig.PetDefaults or {}
    level = level or defaults.level or 5
    local pet = Pets.createStarterPet(petId, level)
    hp = hp or pet.hp
    maxHp = maxHp or pet.maxHp
    catchTime = catchTime or 0
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(petId)                  -- id (4)
    writer:writeUInt32BE(level)                  -- level (4)
    writer:writeUInt32BE(hp)                     -- hp (4)
    writer:writeUInt32BE(maxHp)                  -- maxHp (4)
    
    -- skillNum (4)
    local rawSkills = pet.skills or {}
    local validCount = 0
    for i = 1, 4 do
        if rawSkills[i] and rawSkills[i] > 0 then validCount = validCount + 1 end
    end
    writer:writeUInt32BE(validCount)
    
    -- 4 skills loop
    for i = 1, 4 do
        local sid = rawSkills[i] or 0
        local pp = 20 -- simplified
        writer:writeUInt32BE(sid)
        writer:writeUInt32BE(pp)
    end
    
    writer:writeUInt32BE(catchTime)              -- catchTime (4)
    writer:writeUInt32BE(301)                    -- catchMap (4)
    writer:writeUInt32BE(0)                      -- catchRect (4)
    writer:writeUInt32BE(level)                  -- catchLevel (4)
    
    -- No effectCount in simple mode
    writer:writeUInt32BE(0)                      -- skinID (4)
    
    return writer:toString()
end

-- ==================== 命令处理器 ====================

-- CMD 2301: GET_PET_INFO (获取精灵信息)
local function handleGetPetInfo(ctx)
    local reader = BinaryReader.new(ctx.body)
    local petCatchId = reader:readUInt32BE()
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local petId = user.currentPetId or 7
    -- TODO: get real pet from DB using catchTime (petCatchId)
    
    local body = buildFullPetInfo(petId, petCatchId)
    ctx.sendResponse(buildResponse(2301, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → GET_PET_INFO catchId=%d\27[0m", petCatchId))
    return true
end

-- CMD 2303: GET_PET_LIST (获取仓库列表)
local function handleGetPetList(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- count = 0 for now
    
    ctx.sendResponse(buildResponse(2303, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → GET_PET_LIST response\27[0m")
    return true
end

-- CMD 2304: PET_RELEASE (释放/背包仓库互转)
-- Request: catchId(4) + flag(4)
-- Response: PetTakeOutInfo
-- homeEnergy(4) + firstPetTime(4) + flag(4) + [PetInfo]
local function handlePetRelease(ctx)
    local reader = BinaryReader.new(ctx.body)
    local catchId = reader:readUInt32BE()
    local flag = reader:readUInt32BE()
    
    -- 从 catchId 提取 petType (catchId = 0x69686700 + petType for hack)
    local petType = catchId - 0x69686700
    if petType < 1 or petType > 2000 then
        petType = 7
    end
    
    print(string.format("\27[36m[Handler] PET_RELEASE: catchId=0x%X, flag=%d, petType=%d\27[0m", catchId, flag, petType))
    
    local user = ctx.getOrCreateUser(ctx.userId)
    user.currentPetId = petType
    user.catchId = catchId
    ctx.saveUserDB()
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)                      -- homeEnergy (4)
    writer:writeUInt32BE(catchId)                -- firstPetTime (4)
    writer:writeUInt32BE(1)                      -- flag (4) -> 1 means specific pet info follows
    
    -- If flag != 0, write PetInfo
    local petBody = buildFullPetInfo(petType, catchId)
    writer:writeBytes(petBody)
    
    local respBody = writer:toString()
    ctx.sendResponse(buildResponse(2304, ctx.userId, 0, respBody))
    print(string.format("\27[32m[Handler] → PET_RELEASE sent len=%d\27[0m", #respBody))
    return true
end

-- CMD 2305: PET_SHOW (展示精灵)
-- Response: PetShowInfo
-- userID(4) + catchTime(4) + petID(4) + flag(4) + dv(4) + skinID(4)
local function handlePetShow(ctx)
    local reader = BinaryReader.new(ctx.body)
    -- Request might contain something, but mostly we check user state
    -- Original implementation read params from request? 
    -- Nope, it seems to respond with "My current pet".
    -- Wait, looking at PetManager.showPet: SocketConnection.send(CommandID.PET_SHOW, catchTime, 1/0);
    local reqCatchTime = reader:readUInt32BE()
    local reqFlag = reader:readUInt32BE()
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local petId = user.currentPetId or 7
    local catchTime = user.catchId or (0x69686700 + petId)
    
    if reqCatchTime > 0 then catchTime = reqCatchTime end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)             -- userID (4)
    writer:writeUInt32BE(catchTime)              -- catchTime (4)
    writer:writeUInt32BE(petId)                  -- petID (4)
    writer:writeUInt32BE(reqFlag)                -- flag (4)
    writer:writeUInt32BE(31)                     -- dv (4)
    writer:writeUInt32BE(0)                      -- skinID (4)
    
    ctx.sendResponse(buildResponse(2305, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_SHOW response\27[0m")
    return true
end

-- CMD 2306: PET_CURE (治疗精灵)
local function handlePetCure(ctx)
    ctx.sendResponse(buildResponse(2306, ctx.userId, 0, ""))
    return true
end

-- CMD 2309: PET_BARGE_LIST (精灵图鉴列表)
-- Request: type(4) + maxId(4)
-- Response: maxId(4) + flag(4) + [unknown(4) + encountered(4) + caught(4) + petId(4)]...
local function handlePetBargeList(ctx)
    local reader = BinaryReader.new(ctx.body)
    local reqType = reader:readUInt32BE()
    local maxId = reader:readUInt32BE()
    if maxId == 0 then maxId = 1500 end -- Default
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(maxId)
    writer:writeUInt32BE(reqType)
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local userPetBook = {}
    if ctx.userDB and ctx.userDB.getPetBook then
        userPetBook = ctx.userDB:getPetBook(ctx.userId)
    end
    
    for petId = 1, maxId do
        local petIdStr = tostring(petId)
        local userRecord = userPetBook[petIdStr] or {}
        local encountered = userRecord.encountered or 0
        local caught = userRecord.caught or 0
        
        -- Override if in memory
        if user.pets and user.pets[petIdStr] then
            caught = 1
            encountered = math.max(encountered, 1)
        end
        
        writer:writeUInt32BE(0)          -- unknown
        writer:writeUInt32BE(encountered)
        writer:writeUInt32BE(caught)
        writer:writeUInt32BE(petId)
    end
    
    local respBody = writer:toString()
    ctx.sendResponse(buildResponse(2309, ctx.userId, 0, respBody))
    print(string.format("\27[32m[Handler] → PET_BARGE_LIST sent (%d pets)\27[0m", maxId))
    return true
end

-- CMD 2354: GET_SOUL_BEAD_LIST
local function handleGetSoulBeadList(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(buildResponse(2354, ctx.userId, 0, writer:toString()))
    return true
end

function PetHandlers.register(Handlers)
    Handlers.register(2301, handleGetPetInfo)
    Handlers.register(2303, handleGetPetList)
    Handlers.register(2304, handlePetRelease)
    Handlers.register(2305, handlePetShow)
    Handlers.register(2306, handlePetCure)
    Handlers.register(2309, handlePetBargeList)
    Handlers.register(2354, handleGetSoulBeadList)
    print("\27[36m[Handlers] Pet Handlers Registered (v2.0 fixed)\27[0m")
end

PetHandlers.buildFullPetInfo = buildFullPetInfo
PetHandlers.buildSimplePetInfo = buildSimplePetInfo

return PetHandlers
