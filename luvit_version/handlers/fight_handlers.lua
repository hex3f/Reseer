-- 战斗相关命令处理器
-- 包括: 挑战BOSS、准备战斗、使用技能、捕捉精灵等

local Utils = require('./utils')
local PetHandlers = require('./pet_handlers')
local Elements = require('../seer_elements')
local writeUInt32BE = Utils.writeUInt32BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local FightHandlers = {}

local SeerPets = require('../seer_pets')
local SeerSkills = require('../seer_skills')
local SeerBattle = require('../seer_battle')

-- 获取精灵属性
function FightHandlers.getPetElement(petId)
    local pet = SeerPets.getData(petId)
    return pet and pet.element or Elements.TYPE.NORMAL
end

-- 获取技能数据
function FightHandlers.getSkillData(skillId)
    local skill = SeerSkills.get(skillId)
    return skill or {type = Elements.TYPE.NORMAL, power = 40}
end

-- 计算伤害（包含属性克制和本系加成）
function FightHandlers.calculateDamage(attackerPetId, defenderPetId, skillId, baseDamage)
    local attackerType = FightHandlers.getPetElement(attackerPetId)
    local defenderType = FightHandlers.getPetElement(defenderPetId)
    local skillData = FightHandlers.getSkillData(skillId)
    local skillType = skillData.type
    
    -- 属性克制倍率
    local effectiveness = Elements.getEffectiveness(skillType, defenderType)
    
    -- 本系加成
    local stab = Elements.getSTABMultiplier(attackerType, nil, skillType, nil)
    
    -- 最终伤害
    local finalDamage = math.floor(baseDamage * effectiveness * stab)
    
    print(string.format("\27[33m[战斗] 伤害计算: 攻击方=%s(%d) 技能=%s 防守方=%s(%d)\27[0m",
        Elements.getTypeName(attackerType), attackerPetId,
        Elements.getTypeName(skillType),
        Elements.getTypeName(defenderType), defenderPetId))
    print(string.format("\27[33m[战斗] 基础伤害=%d 克制=x%.2f(%s) STAB=x%.1f 最终=%d\27[0m",
        baseDamage, effectiveness, Elements.getEffectivenessText(effectiveness), stab, finalDamage))
    
    return finalDamage, effectiveness, stab
end

-- ==================== 战斗数据构建 ====================

-- 构建 FightPetInfo
-- FightPetInfo: userID(4) + petID(4) + petName(16) + catchTime(4) + hp(4) + maxHP(4) + lv(4) + catchable(4) + battleLv(6)
local function buildFightPetInfo(userId, petId, catchTime, hp, maxHp, level, catchable)
    local body = ""
    body = body .. writeUInt32BE(userId)
    body = body .. writeUInt32BE(petId)
    body = body .. writeFixedString("", 16)      -- petName
    body = body .. writeUInt32BE(catchTime)
    body = body .. writeUInt32BE(hp)
    body = body .. writeUInt32BE(maxHp)
    body = body .. writeUInt32BE(level)
    body = body .. writeUInt32BE(catchable)
    body = body .. string.char(0,0,0,0,0,0)      -- battleLv (6字节)
    return body
end

-- 构建 AttackValue
-- AttackValue: userID(4) + skillID(4) + atkTimes(4) + lostHP(4) + gainHP(4) + remainHp(4) + maxHp(4) + state(4) + skillListCount(4) + [skills] + isCrit(4) + status(20) + battleLv(6)
local function buildAttackValue(userId, skillId, atkTimes, lostHP, gainHP, remainHp, maxHp, isCrit)
    local body = ""
    body = body .. writeUInt32BE(userId)
    body = body .. writeUInt32BE(skillId)
    body = body .. writeUInt32BE(atkTimes or 1)
    body = body .. writeUInt32BE(lostHP or 0)
    body = body .. writeUInt32BE(gainHP or 0)
    body = body .. writeUInt32BE(remainHp or 100)
    body = body .. writeUInt32BE(maxHp or 100)
    body = body .. writeUInt32BE(0)              -- state
    body = body .. writeUInt32BE(0)              -- skillListCount
    body = body .. writeUInt32BE(isCrit or 0)
    body = body .. string.rep("\0", 20)          -- status (20字节)
    body = body .. string.rep("\0", 6)           -- battleLv (6字节)
    return body
end

-- ==================== 命令处理器 ====================

-- 新手教程BOSS ID (当bossId=0时使用)
local NOVICE_BOSS_ID = 58  -- 默认新手BOSS

-- CMD 2411: CHALLENGE_BOSS (挑战BOSS)
local function handleChallengeBoss(ctx)
    local bossId = 0
    if #ctx.body >= 4 then
        bossId = readUInt32BE(ctx.body, 1)
    end
    
    -- 新手教程BOSS
    if bossId == 0 then
        bossId = NOVICE_BOSS_ID
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local petId = user.currentPetId or 7
    local nickname = user.nick or user.nickname or user.username or ("赛尔" .. ctx.userId)
    local catchTime = user.catchId or (0x69686700 + petId)
    
    -- 保存当前BOSS ID
    user.currentBossId = bossId
    ctx.saveUserDB()
    
    -- 记录遭遇 (进入战斗)
    if ctx.userDB and ctx.userDB.recordEncounter then
        ctx.userDB:recordEncounter(ctx.userId, bossId)
    end
    
    print(string.format("\27[36m[Handler] CHALLENGE_BOSS: bossId=%d, petId=%d, catchTime=0x%X\27[0m", bossId, petId, catchTime))
    
    -- 发送 NOTE_READY_TO_FIGHT (2503)
    -- NoteReadyToFightInfo: userCount(4) + [FighetUserInfo + petCount(4) + PetInfo[]]...
    -- 结构: userCount(4) + User1 + User2
    -- User: UID(4) + Nick(16) + PetCount(4) + PetInfo...
    -- PetInfo: petId(4) + catchTime(4) + hp(4) + maxHp(4) + lv(4) + mode(4) + extra(4) + SkillCount(4) + Skills(4x4) + CatchMap(4)
    
    local body = ""
    body = body .. writeUInt32BE(2)  -- userCount = 2 (玩家 + 敌人)
    
    -- Helper to build Battle Pet Info (战斗模式 PetInfo, param2=false)
    -- 客户端解析顺序 (PetInfo.as 第107-141行):
    -- id(4) + level(4) + hp(4) + maxHp(4) + skillNum(4) + [skillId(4)+pp(4)]x4 + catchTime(4) + catchMap(4) + catchRect(4) + catchLevel(4) + skinID(4)
    local function buildBattlePetInfo(pId, _catchTime, hp, maxHp, lv)
        local pb = ""
        pb = pb .. writeUInt32BE(pId)       -- id
        pb = pb .. writeUInt32BE(lv)        -- level
        pb = pb .. writeUInt32BE(hp)        -- hp
        pb = pb .. writeUInt32BE(maxHp)     -- maxHp
        
        -- Get Skills for Pet using SeerPets.getLearnableMoves
        local skills = {}
        local success, moves = pcall(function()
            return SeerPets.getLearnableMoves(pId, lv)
        end)
        
        if success and moves and #moves > 0 then
            -- 获取最后学会的4个技能
            local startIdx = math.max(1, #moves - 3)
            for i = startIdx, #moves do
                if moves[i] and moves[i].id then
                    table.insert(skills, {id = moves[i].id, pp = moves[i].maxPP or 20})
                end
            end
        end
        
        -- 如果没有技能，使用默认技能
        if #skills == 0 then
            skills = {{id = 10006, pp = 35}, {id = 20004, pp = 40}}
        end
        
        pb = pb .. writeUInt32BE(#skills > 4 and 4 or #skills) -- skillNum
        -- 每个技能需要 id(4) + pp(4) = 8 字节
        for i=1, 4 do
            if skills[i] then
                pb = pb .. writeUInt32BE(skills[i].id)
                pb = pb .. writeUInt32BE(skills[i].pp or 20)
            else
                pb = pb .. writeUInt32BE(0) .. writeUInt32BE(0)
            end
        end
        
        pb = pb .. writeUInt32BE(_catchTime) -- catchTime
        pb = pb .. writeUInt32BE(301)        -- catchMap
        pb = pb .. writeUInt32BE(0)          -- catchRect
        pb = pb .. writeUInt32BE(lv)         -- catchLevel
        pb = pb .. writeUInt32BE(0)          -- skinID
        return pb
    end
    
    -- 玩家1 (自己)
    body = body .. writeUInt32BE(ctx.userId)
    body = body .. writeFixedString(nickname, 16)
    body = body .. writeUInt32BE(1)  -- petCount
    body = body .. buildBattlePetInfo(petId, catchTime, 100, 100, 16)
    
    -- 玩家2 (敌人/BOSS)
    body = body .. writeUInt32BE(0)
    body = body .. writeFixedString("", 16)
    body = body .. writeUInt32BE(1)  -- petCount
    body = body .. buildBattlePetInfo(bossId, 0, 50, 50, 5)
    
    ctx.sendResponse(buildResponse(2503, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → CHALLENGE_BOSS %d (sent NOTE_READY_TO_FIGHT, body=%d bytes)\27[0m", bossId, #body))
    return true
end

-- CMD 2404: READY_TO_FIGHT (准备战斗)
local function handleReadyToFight(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local petId = user.currentPetId or 7
    local catchTime = user.catchId or (0x69686700 + petId)
    local bossId = user.currentBossId or NOVICE_BOSS_ID
    
    -- 从用户数据获取玩家精灵信息
    local petIdStr = tostring(petId)
    local userPetData = user.pets and user.pets[petIdStr]
    
    -- 如果用户没有该精灵数据，使用 Config.PetDefaults 创建
    local Config = require('../game_config')
    local defaults = Config.PetDefaults or {}
    local defaultLevel = defaults.level or 5
    
    -- 获取玩家精灵等级 (从用户数据或默认值)
    local playerLevel = defaultLevel
    if userPetData then
        playerLevel = userPetData.level or defaultLevel
    end
    
    -- 获取或生成个体值和性格
    local playerDV = 31
    local playerNature = 0
    if userPetData then
        playerDV = userPetData.iv or userPetData.dv or 31
        playerNature = userPetData.nature or 0
    elseif defaults.dv then
        playerDV = type(defaults.dv) == "function" and defaults.dv() or defaults.dv
        playerNature = type(defaults.nature) == "function" and defaults.nature() or (defaults.nature or 0)
    end
    
    -- 使用 SeerPets.getStats 计算玩家精灵属性
    local playerStats = SeerPets.getStats(petId, playerLevel, playerDV, nil)
    local playerPetData = SeerPets.getData(petId)
    
    -- 获取玩家技能 (从用户数据或 XML)
    local playerSkills = {}
    if userPetData and userPetData.skills then
        playerSkills = userPetData.skills
    else
        -- 从 XML 读取该等级可学技能
        playerSkills = SeerPets.getSkillsForLevel(petId, playerLevel)
    end
    
    -- 确保至少有一个技能
    if #playerSkills == 0 or (playerSkills[1] == 0 and playerSkills[2] == 0) then
        -- 使用 XML 默认技能
        local moves = SeerPets.getLearnableMoves(petId, playerLevel)
        for i = 1, math.min(4, #moves) do
            if moves[i] and moves[i].id then
                playerSkills[i] = moves[i].id
            end
        end
    end
    
    -- 过滤掉0值
    local validPlayerSkills = {}
    for _, sid in ipairs(playerSkills) do
        if sid and sid > 0 then
            table.insert(validPlayerSkills, sid)
        end
    end
    if #validPlayerSkills == 0 then
        validPlayerSkills = {10001}  -- 最后备用：撞击
    end
    
    -- 获取敌人精灵数据 (从 XML)
    local enemyPetData = SeerPets.getData(bossId)
    local enemyLevel = user.currentBossLevel or 1  -- BOSS等级可配置
    local enemyStats = SeerPets.getStats(bossId, enemyLevel, 15, nil)
    
    -- 获取敌人技能
    local enemySkills = SeerPets.getSkillsForLevel(bossId, enemyLevel)
    local validEnemySkills = {}
    for _, sid in ipairs(enemySkills) do
        if sid and sid > 0 then
            table.insert(validEnemySkills, sid)
        end
    end
    if #validEnemySkills == 0 then
        validEnemySkills = {10001}
    end
    
    -- 获取敌人AI类型
    local BattleAI = require('../seer_battle_ai')
    local aiType = BattleAI.getBossAIType(bossId)
    
    -- 创建战斗实例数据
    local playerBattleData = {
        id = petId,
        name = playerPetData and playerPetData.defName or "精灵",
        level = playerLevel,
        hp = playerStats.hp,
        maxHp = playerStats.maxHp,
        attack = playerStats.attack,
        defence = playerStats.defence,
        spAtk = playerStats.spAtk,
        spDef = playerStats.spDef,
        speed = playerStats.speed,
        type = playerPetData and playerPetData.type or 8,
        skills = validPlayerSkills,
        catchTime = catchTime
    }
    
    local enemyBattleData = {
        id = bossId,
        name = enemyPetData and enemyPetData.defName or "野生精灵",
        level = enemyLevel,
        hp = enemyStats.hp,
        maxHp = enemyStats.maxHp,
        attack = enemyStats.attack,
        defence = enemyStats.defence,
        spAtk = enemyStats.spAtk,
        spDef = enemyStats.spDef,
        speed = enemyStats.speed,
        type = enemyPetData and enemyPetData.type or 8,
        skills = validEnemySkills,
        catchTime = 0
    }
    
    -- 创建 SeerBattle 战斗实例并保存到用户数据
    user.battle = SeerBattle.createBattle(ctx.userId, playerBattleData, enemyBattleData)
    user.battle.aiType = aiType  -- 保存AI类型
    user.inFight = true
    ctx.saveUserDB()
    
    print(string.format("\27[36m[Handler] READY_TO_FIGHT: 创建战斗 petId=%d(Lv%d) vs bossId=%d(Lv%d), AI类型=%d\27[0m", 
        petId, playerLevel, bossId, enemyLevel, aiType))
    print(string.format("\27[36m[Handler] 玩家技能=%s, 敌人技能=%s\27[0m", 
        table.concat(validPlayerSkills, ","), table.concat(validEnemySkills, ",")))
    
    -- 发送 NOTE_START_FIGHT (2504)
    local body = ""
    body = body .. writeUInt32BE(0)  -- isCanAuto
    body = body .. buildFightPetInfo(ctx.userId, petId, catchTime, playerStats.hp, playerStats.maxHp, playerLevel, 0)
    body = body .. buildFightPetInfo(0, bossId, 0, enemyStats.hp, enemyStats.maxHp, enemyLevel, 1)  -- catchable=1
    
    ctx.sendResponse(buildResponse(2504, ctx.userId, 0, body))
    print("\27[32m[Handler] → READY_TO_FIGHT (sent NOTE_START_FIGHT)\27[0m")
    return true
end

-- CMD 2405: USE_SKILL (使用技能)
local function handleUseSkill(ctx)
    local skillId = 0
    if #ctx.body >= 4 then
        skillId = readUInt32BE(ctx.body, 1)
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    
    -- 尝试使用 localgameserver 创建的战斗实例
    local battle = user.battle
    
    -- 响应 CMD 2405 确认
    ctx.sendResponse(buildResponse(2405, ctx.userId, 0, ""))
    
    if battle and not battle.isOver then
        print(string.format("\27[36m[Handler] USE_SKILL: 使用 SeerBattle 引擎 (Turn %d)\27[0m", battle.turn + 1))
        
        -- 执行回合
        local result = SeerBattle.executeTurn(battle, skillId)
        
        -- 构建响应 NOTE_USE_SKILL (2505)
        local body2505 = ""
        
        -- 第一次攻击 (通常是先手)
        if result.firstAttack then
            local atk1 = result.firstAttack
            body2505 = body2505 .. buildAttackValue(atk1.userId, atk1.skillId, 1, 
                atk1.damage, 0, atk1.attackerRemainHp, atk1.attackerMaxHp, atk1.isCrit and 1 or 0)
        end
        
        -- 第二次攻击 (反击)
        if result.secondAttack then
            local atk2 = result.secondAttack
            body2505 = body2505 .. buildAttackValue(atk2.userId, atk2.skillId, 1, 
                atk2.damage, 0, atk2.attackerRemainHp, atk2.attackerMaxHp, atk2.isCrit and 1 or 0)
        end
        
        ctx.sendResponse(buildResponse(2505, ctx.userId, 0, body2505))
        
        -- 检查战斗结束
        if result.isOver then
            local winnerId = result.winner or 0
            local reason = result.reason or 0
            
            -- 记录击败
            if winnerId == ctx.userId and ctx.userDB and ctx.userDB.recordKill then
                 local bossId = user.currentBossId or 0
                 ctx.userDB:recordKill(ctx.userId, bossId)
            end
            
            -- 发送 FIGHT_OVER (2506)
            local body2506 = ""
            body2506 = body2506 .. writeUInt32BE(reason)
            body2506 = body2506 .. writeUInt32BE(winnerId)
            body2506 = body2506 .. string.rep("\0", 20) -- unused fields
            
            ctx.sendResponse(buildResponse(2506, ctx.userId, 0, body2506))
            
            -- 清除战斗
            user.battle = nil
            user.inFight = false
            print(string.format("\27[32m[Handler] 战斗结束: Winner=%d Reason=%d\27[0m", winnerId, reason))
        end
        
    else
        -- Fallback to simplified logic if no battle instance (Legacy/Safety)
        print("\27[33m[Handler] USE_SKILL: 未找到战斗实例，使用简易逻辑\27[0m")
        -- ... (Legacy logic could go here, but omitted to enforce correct flow)
        -- Just end the fight to prevent stuck state
        local body2506 = writeUInt32BE(0) .. writeUInt32BE(0) .. string.rep("\0", 20)
        ctx.sendResponse(buildResponse(2506, ctx.userId, 0, body2506))
    end

    ctx.saveUserDB()
    return true
end

-- CMD 2406: USE_PET_ITEM (使用精灵道具)
-- UsePetItemInfo: userID(4) + itemID(4) + userHP(4) + changeHp(4, signed)
local function handleUsePetItem(ctx)
    local itemId = 0
    if #ctx.body >= 4 then
        itemId = readUInt32BE(ctx.body, 1)
    end
    
    local body = writeUInt32BE(ctx.userId) ..
                writeUInt32BE(itemId) ..
                writeUInt32BE(100) ..         -- userHP
                writeUInt32BE(50)             -- changeHp
    
    ctx.sendResponse(buildResponse(2406, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → USE_PET_ITEM %d response\27[0m", itemId))
    return true
end

-- CMD 2407: CHANGE_PET (更换精灵)
-- ChangePetInfo: userID(4) + petID(4) + petName(16) + level(4) + hp(4) + maxHp(4) + catchTime(4)
local function handleChangePet(ctx)
    local catchTime = 0
    if #ctx.body >= 4 then
        catchTime = readUInt32BE(ctx.body, 1)
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local petId = user.currentPetId or 7
    
    local body = writeUInt32BE(ctx.userId) ..
                writeUInt32BE(petId) ..
                writeFixedString("", 16) ..
                writeUInt32BE(16) ..          -- level
                writeUInt32BE(100) ..         -- hp
                writeUInt32BE(100) ..         -- maxHp
                writeUInt32BE(catchTime)
    
    ctx.sendResponse(buildResponse(2407, ctx.userId, 0, body))
    print("\27[32m[Handler] → CHANGE_PET response\27[0m")
    return true
end

-- CMD 2409: CATCH_MONSTER (捕捉精灵)
-- CatchPetInfo: catchTime(4) + petID(4)
local function handleCatchMonster(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local bossId = user.currentBossId or 58
    local catchTime = os.time()
    
    -- 记录捕获
    if ctx.userDB and ctx.userDB.recordCatch then
        ctx.userDB:recordCatch(ctx.userId, bossId)
    end
    
    local body = writeUInt32BE(catchTime) .. writeUInt32BE(bossId)
    
    ctx.sendResponse(buildResponse(2409, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → CATCH_MONSTER %d response (已记录捕获)\27[0m", bossId))
    return true
end

-- CMD 2410: ESCAPE_FIGHT (逃跑)
local function handleEscapeFight(ctx)
    local body = writeUInt32BE(1)  -- 逃跑成功
    ctx.sendResponse(buildResponse(2410, ctx.userId, 0, body))
    print("\27[32m[Handler] → ESCAPE_FIGHT response\27[0m")
    return true
end

-- 注册所有处理器
function FightHandlers.register(Handlers)
    Handlers.register(2404, handleReadyToFight)
    Handlers.register(2405, handleUseSkill)
    Handlers.register(2406, handleUsePetItem)
    Handlers.register(2407, handleChangePet)
    Handlers.register(2409, handleCatchMonster)
    Handlers.register(2410, handleEscapeFight)
    Handlers.register(2411, handleChallengeBoss)
    print("\27[36m[Handlers] 战斗命令处理器已注册\27[0m")
end

return FightHandlers
