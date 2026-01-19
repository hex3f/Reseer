-- 战斗相关命令处理器
-- 包括: 挑战BOSS、准备战斗、使用技能、捕捉精灵等
-- Protocol Version: 2026-01-20 (Refactored using BinaryWriter)

local Utils = require('./utils')
local BinaryWriter = require('../utils/binary_writer')
local BinaryReader = require('../utils/binary_reader')
local Elements = require('../game/seer_elements')
local SeerPets = require('../game/seer_pets')
local SeerSkills = require('../game/seer_skills')
local SeerBattle = require('../game/seer_battle')
local buildResponse = Utils.buildResponse

local FightHandlers = {}

-- ==================== Protocol Helpers ====================

-- 构建 FightPetInfo (CMD 2504)
-- 对应: com.robot.core.info.fightInfo.FightPetInfo
-- userID(4)+petID(4)+petName(16)+catchTime(4)+hp(4)+maxHP(4)+lv(4)+catchable(4)+battleLv(6)
local function buildFightPetInfo(userId, petId, catchTime, hp, maxHp, level, catchable)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(userId)
    writer:writeUInt32BE(petId)
    writer:writeStringFixed("", 16) -- petName (empty implies default?)
    writer:writeUInt32BE(catchTime)
    writer:writeUInt32BE(hp)
    writer:writeUInt32BE(maxHp)
    writer:writeUInt32BE(level)
    writer:writeUInt32BE(catchable)       -- 0 or 1
    writer:writeBytes(string.rep("\0", 6)) -- battleLv (6 bytes)
    return writer:toString()
end

-- 构建 AttackValue (CMD 2505)
-- 对应: com.robot.core.info.fightInfo.attack.AttackValue
local function buildAttackValue(userId, skillId, atkTimes, lostHP, gainHP, remainHp, maxHp, state, isCrit, status, battleLv, petType)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(userId)
    writer:writeUInt32BE(skillId or 0)
    writer:writeUInt32BE(atkTimes or 1)
    writer:writeUInt32BE(lostHP or 0)
    writer:writeInt32BE(gainHP or 0)     -- Int
    writer:writeInt32BE(remainHp or 0)   -- Int
    writer:writeUInt32BE(maxHp or 0)
    writer:writeUInt32BE(state or 0)
    
    writer:writeUInt32BE(0) -- skillListCount (PetSkillInfo list)
    -- If we needed to write skills: loop { id(4), pp(4) }
    
    writer:writeUInt32BE(isCrit or 0)
    
    -- Status (20 bytes)
    local stC = 0
    if status then
        for i = 0, 19 do
            writer:writeUInt8(status[i] or 0)
            stC = stC + 1
        end
    end
    if stC < 20 then writer:writeBytes(string.rep("\0", 20 - stC)) end
    
    -- BattleLv (6 bytes)
    local blC = 0
    if battleLv then
        for i = 1, 6 do
            writer:writeInt8(battleLv[i] or 0) -- Signed byte!
            blC = blC + 1
        end
    end
    if blC < 6 then writer:writeBytes(string.rep("\0", 6 - blC)) end
    
    writer:writeUInt32BE(0)           -- maxShield
    writer:writeUInt32BE(0)           -- curShield
    writer:writeUInt32BE(petType or 0) -- petType
    
    return writer:toString()
end

-- 构建 NoteReadyToFightInfo (CMD 2503) 部分
-- 需要: FighetUserInfo + PetInfo(simple)
local function buildFighetUserInfo(userId, nick)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(userId or 0)
    writer:writeStringFixed(nick or "Seer", 16)
    -- Assuming FighetUserInfo ends here based on generic usage, 
    -- but usually it matches specific logic. 
    -- Let's re-verify `FighetUserInfo.as` contents if needed.
    -- Based on NoteReadyToFightInfo usage: `new FighetUserInfo(param1)`
    return writer:toString()
end

local function buildSimplePetInfo(petId, level, hp, maxHp, catchTime, skills, catchMap)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(petId)
    writer:writeUInt32BE(level)
    writer:writeUInt32BE(hp)
    writer:writeUInt32BE(maxHp)
    
    -- Skills: valid count but writing 4 slots
    local validCnt = 0
    local skillList = {}
    if skills then
        for _, s in ipairs(skills) do
            if s and s.id > 0 then 
                validCnt = validCnt + 1 
                table.insert(skillList, s)
            end
        end
    end
    writer:writeUInt32BE(validCnt) -- skillNum
    
    for i = 1, 4 do
        local s = skillList[i] or {id=0, pp=0}
        writer:writeUInt32BE(s.id)
        writer:writeUInt32BE(s.pp)
    end
    
    writer:writeUInt32BE(catchTime)
    writer:writeUInt32BE(catchMap or 301)
    writer:writeUInt32BE(0) -- catchRect
    writer:writeUInt32BE(level) -- catchLevel
    writer:writeUInt32BE(0) -- skinID
    
    return writer:toString()
end

-- ==================== 命令处理器 ====================

local NOVICE_BOSS_ID = 13 -- 比比鼠

-- CMD 2411: CHALLENGE_BOSS (挑战BOSS)
local function handleChallengeBoss(ctx)
    local reader = BinaryReader.new(ctx.body)
    local bossId = 0
    if reader:getRemaining() ~= "" then
        bossId = reader:readUInt32BE()
    end
    if bossId == 0 then bossId = NOVICE_BOSS_ID end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local petId = user.currentPetId or 7
    local nickname = user.nick or user.nickname or ("Seer" .. ctx.userId)
    local catchTime = user.catchId or 0
    if catchTime == 0 then catchTime = 0x69686700 + petId end
    
    -- Prepare Data
    local Config = require('../config/game_config')
    local defaults = Config.PetDefaults or {}
    local defaultLevel = defaults.level or 5
    
    local petIdStr = tostring(petId)
    local userPetData = user.pets and user.pets[petIdStr]
    local playerLevel = userPetData and userPetData.level or defaultLevel
    local playerDV = (userPetData and (userPetData.iv or userPetData.dv)) or 31
    if not userPetData and defaults.dv then 
        if type(defaults.dv) == "function" then
            playerDV = defaults.dv()
        else
            playerDV = defaults.dv 
        end
    end
    
    local playerStats = SeerPets.getStats(petId, playerLevel, playerDV, nil)
    local bossLevel = user.currentBossLevel or 1
    local bossStats = SeerPets.getStats(bossId, bossLevel, 15, nil)
    
    -- Save State
    user.currentBossId = bossId
    user.currentBossLevel = bossLevel
    ctx.saveUserDB()
    
    if ctx.userDB and ctx.userDB.recordEncounter then
        ctx.userDB:recordEncounter(ctx.userId, bossId)
    end
    
    print(string.format("\27[36m[Handler] CHALLENGE_BOSS: bossId=%d, petId=%d(Lv%d)\27[0m", bossId, petId, playerLevel))
    
    -- Send NOTE_READY_TO_FIGHT (2503)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(2) -- userCount
    
    -- User 1: Player
    writer:writeBytes(buildFighetUserInfo(ctx.userId, nickname))
    
    writer:writeUInt32BE(1) -- petCount
    -- PetInfo(Simple)
    -- Need skills
    local playerSkills = {}
    if userPetData and userPetData.skills then
        for _, sid in ipairs(userPetData.skills) do
            if sid > 0 then 
                local skdata = SeerSkills.get(sid)
                table.insert(playerSkills, {id=sid, pp=skdata and skdata.pp or 20})
            end
        end
    else
        local sks = SeerPets.getSkillsForLevel(petId, playerLevel)
        for _, sid in ipairs(sks) do
            if sid > 0 then
                local skdata = SeerSkills.get(sid)
                table.insert(playerSkills, {id=sid, pp=skdata and skdata.pp or 20})
            end
        end
    end
    writer:writeBytes(buildSimplePetInfo(petId, playerLevel, playerStats.hp, playerStats.maxHp, catchTime, playerSkills, 301))
    
    -- User 2: Boss
    writer:writeUInt32BE(0)
    writer:writeStringFixed("", 16)
    writer:writeUInt32BE(1) -- petCount
    -- Boss Skills
    local bossSkills = {}
    local bsks = SeerPets.getSkillsForLevel(bossId, bossLevel)
    for _, sid in ipairs(bsks) do
            if sid > 0 then
                local skdata = SeerSkills.get(sid)
                table.insert(bossSkills, {id=sid, pp=skdata and skdata.pp or 20})
            end
    end
    writer:writeBytes(buildSimplePetInfo(bossId, bossLevel, bossStats.hp, bossStats.maxHp, 0, bossSkills, 301))
    
    ctx.sendResponse(buildResponse(2503, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 2404: READY_TO_FIGHT
local function handleReadyToFight(ctx)
    -- Initialization logic similar to Challenge Boss, but creates Battle Instance
    local user = ctx.getOrCreateUser(ctx.userId)
    local petId = user.currentPetId or 7
    local catchTime = user.catchId or (0x69686700 + petId)
    local bossId = user.currentBossId or NOVICE_BOSS_ID
    
    -- 1. Get Player Data
    local petIdStr = tostring(petId)
    local userPetData = user.pets and user.pets[petIdStr]
    local Config = require('../config/game_config')
    local defaults = Config.PetDefaults or {}
    local playerLevel = (userPetData and userPetData.level) or defaults.level or 5
    local playerDV = (userPetData and (userPetData.iv or userPetData.dv)) or 31
    
    local playerStats = SeerPets.getStats(petId, playerLevel, playerDV, nil)
    local playerPetDef = SeerPets.getData(petId)
    
    -- Skills
    local playerSkills = {}
    local rawSkills = (userPetData and userPetData.skills) or SeerPets.getSkillsForLevel(petId, playerLevel)
    for _, sid in ipairs(rawSkills) do
        if sid and sid > 0 then table.insert(playerSkills, sid) end
    end
    if #playerSkills == 0 then playerSkills = {10001} end
    
    -- 2. Get Enemy Data
    local enemyLevel = user.currentBossLevel or 1
    local enemyStats = SeerPets.getStats(bossId, enemyLevel, 15, nil)
    local enemyPetDef = SeerPets.getData(bossId)
    
    local enemySkills = {}
    local rawESkills = SeerPets.getSkillsForLevel(bossId, enemyLevel)
    for _, sid in ipairs(rawESkills) do
        if sid and sid > 0 then table.insert(enemySkills, sid) end
    end
    if #enemySkills == 0 then enemySkills = {10001} end -- Tackle
    
    -- 3. Create Battle Instance
    local BattleAI = require('../game/seer_battle_ai')
    local aiType = BattleAI.getBossAIType(bossId)
    
    local playerBattleData = {
        id = petId,
        name = playerPetDef and playerPetDef.defName or "Pet",
        level = playerLevel,
        hp = playerStats.hp,
        maxHp = playerStats.maxHp,
        attack = playerStats.attack,
        defence = playerStats.defence,
        spAtk = playerStats.spAtk,
        spDef = playerStats.spDef,
        speed = playerStats.speed,
        type = playerPetDef and playerPetDef.type or 8,
        skills = playerSkills,
        catchTime = catchTime
    }
    
    local enemyBattleData = {
        id = bossId,
        name = enemyPetDef and enemyPetDef.defName or "Boss",
        level = enemyLevel,
        hp = enemyStats.hp,
        maxHp = enemyStats.maxHp,
        attack = enemyStats.attack,
        defence = enemyStats.defence,
        spAtk = enemyStats.spAtk,
        spDef = enemyStats.spDef,
        speed = enemyStats.speed,
        type = enemyPetDef and enemyPetDef.type or 8,
        skills = enemySkills,
        catchTime = 0
    }
    
    user.battle = SeerBattle.createBattle(ctx.userId, playerBattleData, enemyBattleData)
    user.battle.aiType = aiType
    user.inFight = true
    ctx.saveUserDB()
    
    print(string.format("\27[36m[Handler] READY_TO_FIGHT: Started battle Pet(%d) vs Boss(%d)\27[0m", petId, bossId))
    
    -- Send NOTE_START_FIGHT (2504)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- isCanAuto
    writer:writeBytes(buildFightPetInfo(ctx.userId, petId, catchTime, playerStats.hp, playerStats.maxHp, playerLevel, 0))
    writer:writeBytes(buildFightPetInfo(0, bossId, 0, enemyStats.hp, enemyStats.maxHp, enemyLevel, 1))
    
    ctx.sendResponse(buildResponse(2504, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 2405: USE_SKILL
local function handleUseSkill(ctx)
    local reader = BinaryReader.new(ctx.body)
    local skillId = 0
    if reader:getRemaining() ~= "" then skillId = reader:readUInt32BE() end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local battle = user.battle
    
    -- Ack
    ctx.sendResponse(buildResponse(2405, ctx.userId, 0, ""))
    
    if battle and not battle.isOver then
        print(string.format("\27[36m[Handler] USE_SKILL: Turn %d (Skill %d)\27[0m", (battle.turn or 0) + 1, skillId))
        
        local result = SeerBattle.executeTurn(battle, skillId)
        local writer = BinaryWriter.new()
        
        local playerPetId = battle.player.id
        local enemyPetId = battle.enemy.id
        
        -- First Attack
        if result.firstAttack then
            local atk1 = result.firstAttack
            local petType = (atk1.userId == ctx.userId) and battle.player.type or battle.enemy.type
            local state = (atk1.missed or atk1.blocked) and 1 or 0
            
            writer:writeBytes(buildAttackValue(
                atk1.userId, atk1.skillId, atk1.atkTimes, 
                atk1.damage, atk1.gainHp, 
                atk1.attackerRemainHp, atk1.attackerMaxHp, 
                state, atk1.isCrit and 1 or 0,
                atk1.attackerStatus, atk1.attackerBattleLv, petType
            ))
        else
            -- Empty Placeholder
            writer:writeBytes(buildAttackValue(ctx.userId, 0, 0, 0, 0, battle.player.hp, battle.player.maxHp, 0, 0, 
                battle.player.status, battle.player.battleLv, 0))
        end
        
        -- Second Attack
        if result.secondAttack then
            local atk2 = result.secondAttack
            local petType = (atk2.userId == ctx.userId) and battle.player.type or battle.enemy.type
            local state = (atk2.missed or atk2.blocked) and 1 or 0
            
            writer:writeBytes(buildAttackValue(
                atk2.userId, atk2.skillId, atk2.atkTimes, 
                atk2.damage, atk2.gainHp, 
                atk2.attackerRemainHp, atk2.attackerMaxHp, 
                state, atk2.isCrit and 1 or 0,
                atk2.attackerStatus, atk2.attackerBattleLv, petType
            ))
        else
             -- Empty Placeholder
            writer:writeBytes(buildAttackValue(0, 0, 0, 0, 0, battle.enemy.hp, battle.enemy.maxHp, 0, 0, 
                battle.enemy.status, battle.enemy.battleLv, 0))
        end
        
        ctx.sendResponse(buildResponse(2505, ctx.userId, 0, writer:toString()))
        
        -- Check Is Over
        if result.isOver then
            local winnerId = result.winner or 0
            local reason = result.reason or 0
             if winnerId == ctx.userId and ctx.userDB and ctx.userDB.recordKill then
                 local bossId = user.currentBossId or 0
                 ctx.userDB:recordKill(ctx.userId, bossId)
            end
            
            local endWriter = BinaryWriter.new()
            endWriter:writeUInt32BE(reason)
            endWriter:writeUInt32BE(winnerId)
            endWriter:writeBytes(string.rep("\0", 20))
            
            ctx.sendResponse(buildResponse(2506, ctx.userId, 0, endWriter:toString()))
            
            user.battle = nil
            user.inFight = false
            print(string.format("\27[32m[Handler] Fight Over: Winner=%d Reason=%d\27[0m", winnerId, reason))
        end
        
    else
        -- No battle or error, just end it
        local endWriter = BinaryWriter.new()
        endWriter:writeUInt32BE(0)
        endWriter:writeUInt32BE(0)
        endWriter:writeBytes(string.rep("\0", 20))
        ctx.sendResponse(buildResponse(2506, ctx.userId, 0, endWriter:toString()))
    end
    
    ctx.saveUserDB()
    return true
end

-- CMD 2406: USE_PET_ITEM
local function handleUsePetItem(ctx)
    local reader = BinaryReader.new(ctx.body)
    local itemId = 0
    if reader:getRemaining() ~= "" then itemId = reader:readUInt32BE() end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeUInt32BE(itemId)
    writer:writeUInt32BE(100) -- hp
    writer:writeUInt32BE(50)  -- change
    
    ctx.sendResponse(buildResponse(2406, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 2407: CHANGE_PET
local function handleChangePet(ctx)
    local reader = BinaryReader.new(ctx.body)
    local catchTime = 0
    if reader:getRemaining() ~= "" then catchTime = reader:readUInt32BE() end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local petId = user.currentPetId or 7
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(ctx.userId)
    writer:writeUInt32BE(petId)
    writer:writeStringFixed("", 16)
    writer:writeUInt32BE(16) -- level
    writer:writeUInt32BE(100)
    writer:writeUInt32BE(100)
    writer:writeUInt32BE(catchTime)
    
    ctx.sendResponse(buildResponse(2407, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 2409: CATCH_MONSTER
local function handleCatchMonster(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local bossId = user.currentBossId or 58
    local catchTime = os.time()
    
    if ctx.userDB and ctx.userDB.recordCatch then
         ctx.userDB:recordCatch(ctx.userId, bossId)
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(catchTime)
    writer:writeUInt32BE(bossId)
    
    ctx.sendResponse(buildResponse(2409, ctx.userId, 0, writer:toString()))
    return true
end

-- CMD 2410: ESCAPE_FIGHT
local function handleEscapeFight(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(1)
    
    ctx.sendResponse(buildResponse(2410, ctx.userId, 0, writer:toString()))
    return true
end

function FightHandlers.register(Handlers)
    Handlers.register(2404, handleReadyToFight)
    Handlers.register(2405, handleUseSkill)
    Handlers.register(2406, handleUsePetItem)
    Handlers.register(2407, handleChangePet)
    Handlers.register(2409, handleCatchMonster)
    Handlers.register(2410, handleEscapeFight)
    Handlers.register(2411, handleChallengeBoss)
    print("\27[36m[Handlers] Fight Handlers Registered (v2.0 fixed)\27[0m")
end

return FightHandlers
