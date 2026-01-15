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

-- ==================== 精灵属性数据 ====================
-- 精灵ID -> 属性ID (可扩展)
local PET_ELEMENTS = {
    [1] = Elements.TYPE.GRASS,      -- 布布种子 - 草
    [2] = Elements.TYPE.GRASS,      -- 布布草 - 草
    [3] = Elements.TYPE.GRASS,      -- 布布花 - 草
    [4] = Elements.TYPE.WATER,      -- 伊优 - 水
    [5] = Elements.TYPE.WATER,      -- 尤里安 - 水
    [6] = Elements.TYPE.WATER,      -- 巴鲁斯 - 水
    [7] = Elements.TYPE.FIRE,       -- 小火猴 - 火
    [8] = Elements.TYPE.FIRE,       -- 烈火猴 - 火
    [9] = Elements.TYPE.FIRE,       -- 烈焰猩猩 - 火
    [58] = Elements.TYPE.NORMAL,    -- 新手BOSS - 普通
}

-- 技能ID -> {属性ID, 威力} (可扩展)
local SKILL_DATA = {
    [1] = {type = Elements.TYPE.NORMAL, power = 40},    -- 撞击
    [2] = {type = Elements.TYPE.GRASS, power = 50},     -- 藤鞭
    [3] = {type = Elements.TYPE.WATER, power = 50},     -- 水枪
    [4] = {type = Elements.TYPE.FIRE, power = 50},      -- 火花
}

-- 获取精灵属性
function FightHandlers.getPetElement(petId)
    return PET_ELEMENTS[petId] or Elements.TYPE.NORMAL
end

-- 获取技能数据
function FightHandlers.getSkillData(skillId)
    return SKILL_DATA[skillId] or {type = Elements.TYPE.NORMAL, power = 40}
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
    local body = ""
    body = body .. writeUInt32BE(2)  -- userCount
    
    -- 玩家1 (自己)
    body = body .. writeUInt32BE(ctx.userId)
    body = body .. writeFixedString(nickname, 16)
    body = body .. writeUInt32BE(1)  -- petCount
    body = body .. PetHandlers.buildSimplePetInfo(petId, 16, 100, 100, catchTime)
    
    -- 玩家2 (敌人/BOSS)
    body = body .. writeUInt32BE(0)
    body = body .. writeFixedString("", 16)
    body = body .. writeUInt32BE(1)  -- petCount
    body = body .. PetHandlers.buildSimplePetInfo(bossId, 5, 50, 50, 0)
    
    ctx.sendResponse(buildResponse(2503, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → CHALLENGE_BOSS %d (sent NOTE_READY_TO_FIGHT)\27[0m", bossId))
    return true
end

-- CMD 2404: READY_TO_FIGHT (准备战斗)
local function handleReadyToFight(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local petId = user.currentPetId or 7
    local catchTime = user.catchId or (0x69686700 + petId)
    local bossId = user.currentBossId or NOVICE_BOSS_ID
    
    -- 发送 NOTE_START_FIGHT (2504)
    -- FightStartInfo: isCanAuto(4) + FightPetInfo x 2
    local body = ""
    body = body .. writeUInt32BE(0)  -- isCanAuto
    body = body .. buildFightPetInfo(ctx.userId, petId, catchTime, 100, 100, 16, 0)
    body = body .. buildFightPetInfo(0, bossId, 0, 50, 50, 5, 1)  -- catchable=1
    
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
    local petId = user.currentPetId or 7
    local bossId = user.currentBossId or NOVICE_BOSS_ID
    
    -- 初始化战斗状态
    user.fightState = user.fightState or {}
    user.fightState.playerHp = user.fightState.playerHp or 100
    user.fightState.playerMaxHp = user.fightState.playerMaxHp or 100
    user.fightState.enemyHp = user.fightState.enemyHp or 50
    user.fightState.enemyMaxHp = user.fightState.enemyMaxHp or 50
    
    -- 计算玩家对敌人的伤害（使用属性系统）
    local baseDamage = 25
    local playerDamage, effectiveness, stab = FightHandlers.calculateDamage(petId, bossId, skillId, baseDamage)
    
    -- 敌人反击伤害（简化：固定10点）
    local enemyDamage = 10
    
    -- 更新HP
    user.fightState.enemyHp = math.max(0, user.fightState.enemyHp - playerDamage)
    user.fightState.playerHp = math.max(0, user.fightState.playerHp - enemyDamage)
    
    -- 判断暴击（10%几率）
    local isCrit = math.random() < 0.1 and 1 or 0
    if isCrit == 1 then
        playerDamage = math.floor(playerDamage * 1.5)
        user.fightState.enemyHp = math.max(0, user.fightState.enemyHp - math.floor(baseDamage * 0.5))
    end
    
    -- 发送技能确认
    ctx.sendResponse(buildResponse(2405, ctx.userId, 0, ""))
    
    -- 发送 NOTE_USE_SKILL (2505)
    local body2505 = ""
    body2505 = body2505 .. buildAttackValue(ctx.userId, skillId, 1, 0, 0, 
        user.fightState.playerHp, user.fightState.playerMaxHp, isCrit)
    body2505 = body2505 .. buildAttackValue(0, 0, 0, playerDamage, 0, 
        user.fightState.enemyHp, user.fightState.enemyMaxHp, 0)
    
    ctx.sendResponse(buildResponse(2505, ctx.userId, 0, body2505))
    
    -- 检查战斗是否结束
    local fightOver = false
    local winnerId = 0
    local reason = 0
    
    if user.fightState.enemyHp <= 0 then
        fightOver = true
        winnerId = ctx.userId
        print("\27[32m[战斗] 玩家胜利!\27[0m")
    elseif user.fightState.playerHp <= 0 then
        fightOver = true
        winnerId = 0
        print("\27[31m[战斗] 玩家失败!\27[0m")
    end
    
    if fightOver then
        -- 记录击败 (玩家胜利时)
        if winnerId == ctx.userId and ctx.userDB and ctx.userDB.recordKill then
            ctx.userDB:recordKill(ctx.userId, bossId)
        end
        
        -- 发送 FIGHT_OVER (2506)
        local body2506 = ""
        body2506 = body2506 .. writeUInt32BE(reason)
        body2506 = body2506 .. writeUInt32BE(winnerId)
        body2506 = body2506 .. writeUInt32BE(0)  -- twoTimes
        body2506 = body2506 .. writeUInt32BE(0)  -- threeTimes
        body2506 = body2506 .. writeUInt32BE(0)  -- autoFightTimes
        body2506 = body2506 .. writeUInt32BE(0)  -- energyTimes
        body2506 = body2506 .. writeUInt32BE(0)  -- learnTimes
        
        ctx.sendResponse(buildResponse(2506, ctx.userId, 0, body2506))
        
        -- 清除战斗状态
        user.fightState = nil
    end
    
    ctx.saveUserDB()
    
    print(string.format("\27[32m[Handler] → USE_SKILL %d (伤害=%d 克制=x%.2f STAB=x%.1f)\27[0m", 
        skillId, playerDamage, effectiveness, stab))
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
