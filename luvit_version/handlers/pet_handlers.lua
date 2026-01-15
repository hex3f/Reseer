-- 精灵相关命令处理器
-- 包括: 获取精灵信息、释放精灵、展示精灵、图鉴等

local Utils = require('./utils')
local Pets = require('../seer_pets')
local Monsters = require('../seer_monsters')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local PetHandlers = {}

-- 初始化时加载精灵数据库
Monsters.load()

-- ==================== 精灵数据构建 ====================

-- 构建完整版 PetInfo (param2=true)
-- 用于 GET_PET_INFO (2301), PET_RELEASE (2304) 等
local function buildFullPetInfo(petId, catchTime, level)
    level = level or 5
    
    -- 使用精灵数据库创建实例
    local pet = Pets.createStarterPet(petId, level)
    
    local body = ""
    body = body .. writeUInt32BE(petId)          -- id
    body = body .. writeFixedString(pet.name, 16) -- name (16字节)
    body = body .. writeUInt32BE(pet.iv)         -- dv (个体值)
    body = body .. writeUInt32BE(pet.nature)     -- nature (性格)
    body = body .. writeUInt32BE(level)          -- level
    body = body .. writeUInt32BE(pet.exp)        -- exp
    body = body .. writeUInt32BE(0)              -- lvExp
    body = body .. writeUInt32BE(1000)           -- nextLvExp
    body = body .. writeUInt32BE(pet.hp)         -- hp
    body = body .. writeUInt32BE(pet.maxHp)      -- maxHp
    body = body .. writeUInt32BE(pet.attack)     -- attack
    body = body .. writeUInt32BE(pet.defence)    -- defence
    body = body .. writeUInt32BE(pet.s_a)        -- s_a (特攻)
    body = body .. writeUInt32BE(pet.s_d)        -- s_d (特防)
    body = body .. writeUInt32BE(pet.speed)      -- speed
    body = body .. writeUInt32BE(0)              -- addMaxHP
    body = body .. writeUInt32BE(0)              -- addMoreMaxHP
    body = body .. writeUInt32BE(0)              -- addAttack
    body = body .. writeUInt32BE(0)              -- addDefence
    body = body .. writeUInt32BE(0)              -- addSA
    body = body .. writeUInt32BE(0)              -- addSD
    body = body .. writeUInt32BE(0)              -- addSpeed
    body = body .. writeUInt32BE(pet.ev.hp)      -- ev_hp
    body = body .. writeUInt32BE(pet.ev.atk)     -- ev_attack
    body = body .. writeUInt32BE(pet.ev.def)     -- ev_defence
    body = body .. writeUInt32BE(pet.ev.spa)     -- ev_sa
    body = body .. writeUInt32BE(pet.ev.spd)     -- ev_sd
    body = body .. writeUInt32BE(pet.ev.spe)     -- ev_sp
    body = body .. writeUInt32BE(4)              -- skillNum
    -- 4个技能槽 (id + pp)
    local skills = pet.skills or {10001, 0, 0, 0}
    body = body .. writeUInt32BE(skills[1] or 0) .. writeUInt32BE(30)
    body = body .. writeUInt32BE(skills[2] or 0) .. writeUInt32BE(25)
    body = body .. writeUInt32BE(skills[3] or 0) .. writeUInt32BE(20)
    body = body .. writeUInt32BE(skills[4] or 0) .. writeUInt32BE(15)
    body = body .. writeUInt32BE(catchTime)      -- catchTime
    body = body .. writeUInt32BE(pet.catchMap)   -- catchMap
    body = body .. writeUInt32BE(0)              -- catchRect
    body = body .. writeUInt32BE(pet.catchLevel) -- catchLevel
    body = body .. writeUInt16BE(0)              -- effectCount (2字节)
    body = body .. writeUInt32BE(0)              -- peteffect
    body = body .. writeUInt32BE(0)              -- skinID
    body = body .. writeUInt32BE(0)              -- shiny
    body = body .. writeUInt32BE(0)              -- freeForbidden
    body = body .. writeUInt32BE(0)              -- boss
    
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
    body = body .. writeUInt32BE(4)              -- skillNum (4)
    -- 4个技能槽 (id + pp) = 32字节
    local skills = pet.skills or {10001, 0, 0, 0}
    body = body .. writeUInt32BE(skills[1] or 0) .. writeUInt32BE(30)
    body = body .. writeUInt32BE(skills[2] or 0) .. writeUInt32BE(25)
    body = body .. writeUInt32BE(skills[3] or 0) .. writeUInt32BE(20)
    body = body .. writeUInt32BE(skills[4] or 0) .. writeUInt32BE(15)
    body = body .. writeUInt32BE(catchTime)      -- catchTime (4)
    body = body .. writeUInt32BE(301)            -- catchMap (4)
    body = body .. writeUInt32BE(0)              -- catchRect (4)
    body = body .. writeUInt32BE(level)          -- catchLevel (4)
    body = body .. writeUInt32BE(0)              -- skinID (4)
    body = body .. writeUInt32BE(0)              -- shiny (4)
    body = body .. writeUInt32BE(0)              -- freeForbidden (4)
    body = body .. writeUInt32BE(0)              -- boss (4)
    
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
    body = body .. writeUInt32BE(100)            -- homeEnergy
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
-- 请求: startIndex(4) + count(4)
-- PetBargeListInfo响应: monCount(4) + [monID(4) + enCntCnt(4) + isCatched(4) + isKilled(4)]...
local function handlePetBargeList(ctx)
    local startIndex = 1
    local count = 100
    
    if ctx.body and #ctx.body >= 4 then
        startIndex = readUInt32BE(ctx.body, 1)
    end
    if ctx.body and #ctx.body >= 8 then
        count = readUInt32BE(ctx.body, 5)
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    
    -- 获取用户独立的图鉴记录
    local userPetBook = {}
    if ctx.userDB and ctx.userDB.getPetBook then
        userPetBook = ctx.userDB:getPetBook(ctx.userId)
    end
    
    -- 获取所有精灵ID（从数据库）
    local allPetIds = Monsters.getAllIds()
    
    -- 构建图鉴列表
    -- 只返回用户有记录的精灵（遭遇过、捕获过或击败过）
    local petList = {}
    
    for _, petId in ipairs(allPetIds) do
        local petIdStr = tostring(petId)
        local userRecord = userPetBook[petIdStr]
        
        -- 只有用户有记录的精灵才加入列表
        if userRecord then
            table.insert(petList, {
                id = petId,
                encountered = userRecord.encountered or 0,
                caught = userRecord.caught or 0,
                killed = userRecord.killed or 0
            })
        end
    end
    
    -- 确保用户当前精灵在图鉴中（已捕获状态）
    if user.currentPetId then
        local found = false
        for _, pet in ipairs(petList) do
            if pet.id == user.currentPetId then
                pet.caught = 1  -- 确保标记为已捕获
                found = true
                break
            end
        end
        if not found then
            -- 添加当前精灵到图鉴
            table.insert(petList, {
                id = user.currentPetId,
                encountered = 1,
                caught = 1,
                killed = 0
            })
            -- 同时更新数据库
            if ctx.userDB and ctx.userDB.recordCatch then
                ctx.userDB:recordCatch(ctx.userId, user.currentPetId)
            end
        end
    end
    
    -- 按精灵ID排序
    table.sort(petList, function(a, b) return a.id < b.id end)
    
    -- 构建响应
    local body = writeUInt32BE(#petList)  -- monCount
    for _, pet in ipairs(petList) do
        body = body .. writeUInt32BE(pet.id)          -- monID
        body = body .. writeUInt32BE(pet.encountered) -- enCntCnt (遭遇次数)
        body = body .. writeUInt32BE(pet.caught)      -- isCatched (是否捕获: 0/1)
        body = body .. writeUInt32BE(pet.killed)      -- isKilled (击败次数)
    end
    
    ctx.sendResponse(buildResponse(2309, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → PET_BARGE_LIST response (%d pets, user=%d)\27[0m", #petList, ctx.userId))
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
