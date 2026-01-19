-- seer_battle.lua
-- 赛尔号战斗系统 - 完整实现
-- 基于前端 PetFightDLL 代码分析

-- local SeerMonsters = require('./seer_monsters') -- Deprecated
local SeerSkills = require('./seer_skills')
local SkillEffects = require('./seer_skill_effects')

local SeerBattle = {}

-- ==================== 常量定义 ====================

-- 战斗倒计时 (与前端 TimerManager.TIME_COUNT 一致)
SeerBattle.TURN_TIMEOUT = 10  -- 10秒

-- 自动战斗延迟 (与前端 autoTimer 一致)
SeerBattle.AUTO_FIGHT_DELAY = 2  -- 2秒

-- 战斗状态
SeerBattle.STATUS = {
    PARALYSIS = 0,    -- 麻痹
    POISON = 1,       -- 中毒
    BURN = 2,         -- 烧伤
    DRAIN = 3,        -- 吸取对方体力
    DRAINED = 4,      -- 被对方吸取体力
    FREEZE = 5,       -- 冻伤
    FEAR = 6,         -- 害怕
    FATIGUE = 7,      -- 疲惫
    SLEEP = 8,        -- 睡眠
    PETRIFY = 9,      -- 石化
    CONFUSION = 10,   -- 混乱
    WEAKNESS = 11,    -- 衰弱
    MOUNTAIN_GUARD = 12,  -- 山神守护
    FLAMMABLE = 13,   -- 易燃
    RAGE = 14,        -- 狂暴
    ICE_SEAL = 15,    -- 冰封
    BLEED = 16,       -- 流血
    IMMUNE_DOWN = 17, -- 免疫能力下降
    IMMUNE_STATUS = 18 -- 免疫异常状态
}

-- 能力等级变化 (与前端 TRAIT_STATUS_ARRAY 对应)
SeerBattle.TRAIT = {
    ATTACK = 0,   -- 攻击
    DEFENCE = 1,  -- 防御
    SP_ATK = 2,   -- 特攻
    SP_DEF = 3,   -- 特防
    SPEED = 4,    -- 速度
    ACCURACY = 5  -- 命中
}

-- 属性克制表 (攻击属性 -> 被克制属性列表)
-- Type: 1草, 2水, 3火, 4飞行, 5电, 6机械, 7地面, 8普通, 9冰, 10超能, 11战斗, 12光, 13暗影, 14神秘, 15龙, 16圣灵
SeerBattle.typeChart = {
    [1] = {2, 7},           -- 草克水、地面
    [2] = {3, 7},           -- 水克火、地面
    [3] = {1, 6, 9},        -- 火克草、机械、冰
    [4] = {1, 11},          -- 飞行克草、战斗
    [5] = {2, 4},           -- 电克水、飞行
    [6] = {9},              -- 机械克冰
    [7] = {3, 5, 6},        -- 地面克火、电、机械
    [8] = {},               -- 普通无克制
    [9] = {1, 4, 7, 15},    -- 冰克草、飞行、地面、龙
    [10] = {11},            -- 超能克战斗
    [11] = {8, 9},          -- 战斗克普通、冰
    [12] = {13},            -- 光克暗影
    [13] = {10, 12},        -- 暗影克超能、光
    [14] = {},              -- 神秘
    [15] = {15},            -- 龙克龙
    [16] = {13, 15}         -- 圣灵克暗影、龙
}

-- 能力等级倍率表 (等级 -6 到 +6)
SeerBattle.statMultipliers = {
    [-6] = 2/8, [-5] = 2/7, [-4] = 2/6, [-3] = 2/5, [-2] = 2/4, [-1] = 2/3,
    [0] = 1,
    [1] = 3/2, [2] = 4/2, [3] = 5/2, [4] = 6/2, [5] = 7/2, [6] = 8/2
}

-- ==================== 属性克制计算 ====================

-- 计算属性克制倍率
function SeerBattle.getTypeMultiplier(atkType, defType)
    local dominated = SeerBattle.typeChart[atkType] or {}
    for _, t in ipairs(dominated) do
        if t == defType then
            return 2.0  -- 克制
        end
    end
    -- 检查是否被克制
    local dominated2 = SeerBattle.typeChart[defType] or {}
    for _, t in ipairs(dominated2) do
        if t == atkType then
            return 0.5  -- 被克制
        end
    end
    return 1.0  -- 普通
end

-- ==================== 能力等级计算 ====================

-- 获取能力等级倍率
function SeerBattle.getStatMultiplier(stage)
    stage = math.max(-6, math.min(6, stage or 0))
    return SeerBattle.statMultipliers[stage] or 1
end

-- 应用能力等级变化
function SeerBattle.applyStatChange(pet, stat, change)
    pet.battleLv = pet.battleLv or {0, 0, 0, 0, 0, 0}
    local index = stat + 1  -- Lua 索引从1开始
    local oldStage = pet.battleLv[index] or 0
    local newStage = math.max(-6, math.min(6, oldStage + change))
    pet.battleLv[index] = newStage
    return newStage ~= oldStage  -- 返回是否有变化
end

-- ==================== 伤害计算 ====================

-- 计算伤害
-- 公式: ((2*Lv/5+2)*Power*Atk/Def/50+2)*STAB*TypeMod*Crit*Random
-- 参考前端 UseSkillController.as 的伤害显示逻辑
-- move_flag: DmgBindLv(伤害=等级), PwrBindDv(威力=个体值*5), PwrDouble(异常时威力翻倍)
function SeerBattle.calculateDamage(attacker, defender, skill, isCrit)
    local level = attacker.level or 5
    local power = skill.power or 40
    
    -- DmgBindLv: 伤害等于自身等级
    if skill.dmgBindLv then
        return level, 1.0, isCrit
    end
    
    -- PwrBindDv: 威力=个体值*5 (值可能是1或2，2表示更强的倍率)
    if skill.pwrBindDv then
        local dv = attacker.dv or 15
        local multiplier = skill.pwrBindDv == 2 and 10 or 5  -- 2时倍率更高
        power = dv * multiplier
    end
    
    -- PwrDouble: 对方处于异常状态时威力翻倍
    if skill.pwrDouble and defender.status then
        local hasStatus = false
        for k, v in pairs(defender.status) do
            if v and v > 0 then
                hasStatus = true
                break
            end
        end
        if hasStatus then
            power = power * 2
        end
    end
    
    -- 物理/特殊攻击 (category: 1=物理, 2=特殊, 4=变化)
    local atk, def
    local atkStage, defStage = 0, 0
    
    if skill.category == 1 then  -- 物理
        atk = attacker.attack or 39
        def = defender.defence or 35
        atkStage = (attacker.battleLv and attacker.battleLv[1]) or 0
        defStage = (defender.battleLv and defender.battleLv[2]) or 0
    elseif skill.category == 2 then  -- 特殊
        atk = attacker.spAtk or 78
        def = defender.spDef or 36
        atkStage = (attacker.battleLv and attacker.battleLv[3]) or 0
        defStage = (defender.battleLv and defender.battleLv[4]) or 0
    else  -- 变化技能无伤害
        return 0, 1.0, false
    end
    
    -- 应用能力等级
    atk = math.floor(atk * SeerBattle.getStatMultiplier(atkStage))
    def = math.floor(def * SeerBattle.getStatMultiplier(defStage))
    def = math.max(1, def)  -- 防止除以0
    
    -- 基础伤害
    local baseDamage = math.floor((2 * level / 5 + 2) * power * atk / def / 50 + 2)
    
    -- STAB (同属性加成)
    local stab = 1.0
    if skill.type == attacker.type then
        stab = 1.5
    end
    
    -- 属性克制
    local typeMod = SeerBattle.getTypeMultiplier(skill.type or 8, defender.type or 8)
    
    -- 暴击
    local critMod = isCrit and 1.5 or 1.0
    
    -- 随机波动 (85%-100%)
    local randomMod = (85 + math.random(0, 15)) / 100
    
    local damage = math.floor(baseDamage * stab * typeMod * critMod * randomMod)
    
    -- 最小伤害为1
    return math.max(1, damage), typeMod, isCrit
end

-- 判断是否暴击
-- 考虑 move_flag: CritAtkFirst, CritAtkSecond, CritSelfHalfHp, CritFoeHalfHp
function SeerBattle.checkCrit(attacker, defender, skill, isFirst)
    -- CritAtkFirst: 先出手必暴击
    if skill.critAtkFirst and isFirst then
        return true
    end
    
    -- CritAtkSecond: 后出手必暴击
    if skill.critAtkSecond and not isFirst then
        return true
    end
    
    -- CritSelfHalfHp: 自身HP低于一半必暴击
    if skill.critSelfHalfHp and attacker.hp and attacker.maxHp then
        if attacker.hp < attacker.maxHp / 2 then
            return true
        end
    end
    
    -- CritFoeHalfHp: 对方HP低于一半必暴击
    if skill.critFoeHalfHp and defender.hp and defender.maxHp then
        if defender.hp < defender.maxHp / 2 then
            return true
        end
    end
    
    local critRate = skill.critRate or 1
    -- 基础暴击率 = critRate / 16
    -- 速度等级加成
    local speedStage = (attacker.battleLv and attacker.battleLv[5]) or 0
    local bonusCrit = math.max(0, speedStage)  -- 速度等级正值增加暴击
    return math.random(1, 16) <= (critRate + bonusCrit)
end

-- 判断是否命中
function SeerBattle.checkHit(attacker, defender, skill)
    local accuracy = skill.accuracy or 100
    if accuracy >= 100 then return true end
    
    -- 命中等级修正
    local accStage = (attacker.battleLv and attacker.battleLv[6]) or 0
    local evaStage = 0  -- 闪避等级 (暂未实现)
    local stageMod = SeerBattle.getStatMultiplier(accStage - evaStage)
    
    local finalAcc = math.floor(accuracy * stageMod)
    return math.random(1, 100) <= finalAcc
end

-- ==================== 状态效果处理 ====================

-- 应用状态效果
function SeerBattle.applyStatus(target, statusType, duration)
    target.status = target.status or {}
    target.status[statusType] = duration
end

-- 处理回合开始时的状态效果
function SeerBattle.processStatusEffects(pet)
    if not pet.status then pet.status = {} end
    
    local statusDamage = 0
    
    -- 中毒伤害 (每回合损失1/8最大HP)
    if pet.status[SeerBattle.STATUS.POISON] and pet.status[SeerBattle.STATUS.POISON] > 0 then
        statusDamage = statusDamage + math.floor(pet.maxHp / 8)
        pet.status[SeerBattle.STATUS.POISON] = pet.status[SeerBattle.STATUS.POISON] - 1
    end
    if pet.status.poison and pet.status.poison > 0 then
        statusDamage = statusDamage + math.floor(pet.maxHp / 8)
        pet.status.poison = pet.status.poison - 1
    end
    
    -- 烧伤伤害 (每回合损失1/16最大HP)
    if pet.status[SeerBattle.STATUS.BURN] and pet.status[SeerBattle.STATUS.BURN] > 0 then
        statusDamage = statusDamage + math.floor(pet.maxHp / 16)
        pet.status[SeerBattle.STATUS.BURN] = pet.status[SeerBattle.STATUS.BURN] - 1
    end
    if pet.status.burn and pet.status.burn > 0 then
        statusDamage = statusDamage + math.floor(pet.maxHp / 16)
        pet.status.burn = pet.status.burn - 1
    end
    
    -- 冻伤伤害 (每回合损失1/16最大HP)
    if pet.status[SeerBattle.STATUS.FREEZE] and pet.status[SeerBattle.STATUS.FREEZE] > 0 then
        statusDamage = statusDamage + math.floor(pet.maxHp / 16)
        pet.status[SeerBattle.STATUS.FREEZE] = pet.status[SeerBattle.STATUS.FREEZE] - 1
    end
    
    -- 流血伤害 (每回合损失1/8最大HP)
    if pet.status[SeerBattle.STATUS.BLEED] and pet.status[SeerBattle.STATUS.BLEED] > 0 then
        statusDamage = statusDamage + math.floor(pet.maxHp / 8)
        pet.status[SeerBattle.STATUS.BLEED] = pet.status[SeerBattle.STATUS.BLEED] - 1
    end
    
    -- 紧勒伤害
    if pet.bound and pet.boundTurns and pet.boundTurns > 0 then
        statusDamage = statusDamage + math.floor(pet.maxHp / 16)
        pet.boundTurns = pet.boundTurns - 1
        if pet.boundTurns <= 0 then
            pet.bound = false
        end
    end
    
    return statusDamage
end

-- 检查是否可以行动
function SeerBattle.canAct(pet)
    if not pet.status then pet.status = {} end
    
    -- 疲惫状态无法行动
    if pet.fatigue and pet.fatigue > 0 then
        pet.fatigue = pet.fatigue - 1
        return false, "fatigue"
    end
    
    -- 睡眠状态无法行动
    if pet.status[SeerBattle.STATUS.SLEEP] and pet.status[SeerBattle.STATUS.SLEEP] > 0 then
        pet.status[SeerBattle.STATUS.SLEEP] = pet.status[SeerBattle.STATUS.SLEEP] - 1
        return false, "sleep"
    end
    
    -- 也检查新格式的睡眠状态
    if pet.status.sleep and pet.status.sleep > 0 then
        pet.status.sleep = pet.status.sleep - 1
        return false, "sleep"
    end
    
    -- 石化状态无法行动
    if pet.status[SeerBattle.STATUS.PETRIFY] and pet.status[SeerBattle.STATUS.PETRIFY] > 0 then
        return false, "petrify"
    end
    if pet.status.petrify and pet.status.petrify > 0 then
        pet.status.petrify = pet.status.petrify - 1
        return false, "petrify"
    end
    
    -- 冰封状态无法行动
    if pet.status[SeerBattle.STATUS.ICE_SEAL] and pet.status[SeerBattle.STATUS.ICE_SEAL] > 0 then
        pet.status[SeerBattle.STATUS.ICE_SEAL] = pet.status[SeerBattle.STATUS.ICE_SEAL] - 1
        return false, "ice_seal"
    end
    
    -- 冰冻状态无法行动
    if pet.status.freeze and pet.status.freeze > 0 then
        pet.status.freeze = pet.status.freeze - 1
        return false, "freeze"
    end
    
    -- 麻痹有25%几率无法行动
    if pet.status[SeerBattle.STATUS.PARALYSIS] and pet.status[SeerBattle.STATUS.PARALYSIS] > 0 then
        if math.random(1, 4) == 1 then
            return false, "paralysis"
        end
    end
    if pet.status.paralysis and pet.status.paralysis > 0 then
        if math.random(1, 4) == 1 then
            return false, "paralysis"
        end
    end
    
    -- 害怕有50%几率无法行动
    if pet.status[SeerBattle.STATUS.FEAR] and pet.status[SeerBattle.STATUS.FEAR] > 0 then
        pet.status[SeerBattle.STATUS.FEAR] = pet.status[SeerBattle.STATUS.FEAR] - 1
        if math.random(1, 2) == 1 then
            return false, "fear"
        end
    end
    if pet.status.fear and pet.status.fear > 0 then
        pet.status.fear = pet.status.fear - 1
        if math.random(1, 2) == 1 then
            return false, "fear"
        end
    end
    
    -- 混乱有33%几率攻击自己
    if pet.status[SeerBattle.STATUS.CONFUSION] and pet.status[SeerBattle.STATUS.CONFUSION] > 0 then
        pet.status[SeerBattle.STATUS.CONFUSION] = pet.status[SeerBattle.STATUS.CONFUSION] - 1
        if math.random(1, 3) == 1 then
            return false, "confusion"
        end
    end
    if pet.status.confusion and pet.status.confusion > 0 then
        pet.status.confusion = pet.status.confusion - 1
        if math.random(1, 3) == 1 then
            return false, "confusion"
        end
    end
    
    -- 畏缩状态无法行动 (只持续一回合)
    if pet.flinched then
        pet.flinched = false
        return false, "flinch"
    end
    
    return true
end

-- ==================== AI 系统 ====================

-- AI选择技能
-- 参考前端 PetSkillPanel.auto() 的逻辑
function SeerBattle.aiSelectSkill(aiPet, playerPet, skills)
    if not skills or #skills == 0 then
        return nil
    end
    
    -- AI策略: 选择最优技能
    local bestSkill = nil
    local bestScore = -1
    
    for _, skillId in ipairs(skills) do
        if skillId and skillId > 0 then
            local skill = SeerSkills.get(skillId)
            if skill then
                local score = 0
                
                if skill.power and skill.power > 0 then
                    -- 攻击技能评分
                    local typeMod = SeerBattle.getTypeMultiplier(skill.type or 8, playerPet.type or 8)
                    score = (skill.power or 0) * typeMod
                    
                    -- 考虑命中率
                    local accuracy = skill.accuracy or 100
                    score = score * (accuracy / 100)
                    
                    -- 如果对方HP低，优先使用高威力技能
                    if playerPet.hp and playerPet.maxHp then
                        local hpRatio = playerPet.hp / playerPet.maxHp
                        if hpRatio < 0.3 then
                            score = score * 1.5  -- 收割加成
                        end
                    end
                else
                    -- 变化技能评分 (较低优先级)
                    score = 10
                    
                    -- 如果自己HP低，考虑使用回复技能
                    if aiPet.hp and aiPet.maxHp then
                        local hpRatio = aiPet.hp / aiPet.maxHp
                        if hpRatio < 0.5 and skill.effect == "heal" then
                            score = 100  -- 回复技能高优先级
                        end
                    end
                end
                
                if score > bestScore then
                    bestScore = score
                    bestSkill = skillId
                end
            end
        end
    end
    
    -- 如果没有找到合适技能，使用第一个有效技能
    if not bestSkill then
        for _, skillId in ipairs(skills) do
            if skillId and skillId > 0 then
                bestSkill = skillId
                break
            end
        end
    end
    
    return bestSkill
end

-- 比较速度决定先后攻
-- 参考前端战斗逻辑
function SeerBattle.compareSpeed(pet1, pet2, skill1, skill2)
    -- 先检查技能优先级
    local priority1 = skill1 and skill1.priority or 0
    local priority2 = skill2 and skill2.priority or 0
    
    if priority1 ~= priority2 then
        return priority1 > priority2
    end
    
    -- 计算实际速度 (考虑能力等级)
    local speed1 = pet1.speed or 39
    local speed2 = pet2.speed or 39
    
    local speedStage1 = (pet1.battleLv and pet1.battleLv[5]) or 0
    local speedStage2 = (pet2.battleLv and pet2.battleLv[5]) or 0
    
    speed1 = math.floor(speed1 * SeerBattle.getStatMultiplier(speedStage1))
    speed2 = math.floor(speed2 * SeerBattle.getStatMultiplier(speedStage2))
    
    -- 麻痹状态速度减半
    if pet1.status and pet1.status[SeerBattle.STATUS.PARALYSIS] and pet1.status[SeerBattle.STATUS.PARALYSIS] > 0 then
        speed1 = math.floor(speed1 / 2)
    end
    if pet2.status and pet2.status[SeerBattle.STATUS.PARALYSIS] and pet2.status[SeerBattle.STATUS.PARALYSIS] > 0 then
        speed2 = math.floor(speed2 / 2)
    end
    
    if speed1 ~= speed2 then
        return speed1 > speed2
    end
    
    -- 速度相同时随机
    return math.random(1, 2) == 1
end

-- ==================== 战斗实例管理 ====================

-- 创建战斗实例
function SeerBattle.createBattle(userId, playerPetData, enemyPetData)
    local battle = {
        battleId = os.time(),
        userId = userId,
        turn = 0,
        maxTurns = 50,  -- 最大回合数
        isOver = false,
        winner = nil,
        reason = 0,  -- 结束原因: 0=正常, 1=对方退出, 2=超时, 3=平局, 4=系统错误, 5=NPC逃跑
        
        -- 战斗开始时间 (用于超时检测)
        startTime = os.time(),
        lastActionTime = os.time(),
        
        -- 玩家精灵
        player = {
            id = playerPetData.id,
            name = playerPetData.name or "",
            level = playerPetData.level or 5,
            hp = playerPetData.hp or 100,
            maxHp = playerPetData.maxHp or 100,
            attack = playerPetData.attack or 39,
            defence = playerPetData.defence or 35,
            spAtk = playerPetData.spAtk or 78,
            spDef = playerPetData.spDef or 36,
            speed = playerPetData.speed or 39,
            type = playerPetData.type or 8,
            skills = playerPetData.skills or {},
            skillPP = {},  -- 技能PP
            catchTime = playerPetData.catchTime or 0,
            battleLv = {0, 0, 0, 0, 0, 0},  -- 能力等级变化
            status = {}  -- 状态效果
        },
        
        -- 敌方精灵
        enemy = {
            id = enemyPetData.id,
            name = enemyPetData.name or "",
            level = enemyPetData.level or 5,
            hp = enemyPetData.hp or 100,
            maxHp = enemyPetData.maxHp or 100,
            attack = enemyPetData.attack or 39,
            defence = enemyPetData.defence or 35,
            spAtk = enemyPetData.spAtk or 78,
            spDef = enemyPetData.spDef or 36,
            speed = enemyPetData.speed or 39,
            type = enemyPetData.type or 8,
            skills = enemyPetData.skills or {},
            skillPP = {},  -- 技能PP
            catchTime = enemyPetData.catchTime or 0,
            battleLv = {0, 0, 0, 0, 0, 0},  -- 能力等级变化
            status = {}  -- 状态效果
        },
        
        -- 战斗日志
        log = {}
    }
    
    -- 初始化技能PP
    for i, skillId in ipairs(battle.player.skills) do
        local skill = SeerSkills.get(skillId)
        battle.player.skillPP[i] = skill and skill.pp or 30
    end
    for i, skillId in ipairs(battle.enemy.skills) do
        local skill = SeerSkills.get(skillId)
        battle.enemy.skillPP[i] = skill and skill.pp or 30
    end
    
    return battle
end

-- ==================== 回合执行 ====================

-- 执行一回合战斗
function SeerBattle.executeTurn(battle, playerSkillId)
    battle.turn = battle.turn + 1
    battle.lastActionTime = os.time()
    
    -- 检查回合数限制
    if battle.turn > battle.maxTurns then
        battle.isOver = true
        battle.reason = 3  -- 平局
        return {
            turn = battle.turn,
            isOver = true,
            winner = nil,
            reason = 3
        }
    end
    
    local playerSkill = SeerSkills.get(playerSkillId) or {power = 40, type = 8, category = 1}
    
    -- 扣除玩家PP
    for i, sid in ipairs(battle.player.skills) do
        if sid == playerSkillId then
            battle.player.skillPP[i] = math.max(0, (battle.player.skillPP[i] or 0) - 1)
            break
        end
    end
    
    -- 使用 BattleAI 模块选择敌人技能
    local enemySkillId
    if battle.aiType then
        local BattleAI = require('./seer_battle_ai')
        enemySkillId = BattleAI.selectSkill(battle.aiType, battle.enemy, battle.player, {turn = battle.turn})
    else
        -- 默认AI
        enemySkillId = SeerBattle.aiSelectSkill(battle.enemy, battle.player, battle.enemy.skills)
    end
    local enemySkill = SeerSkills.get(enemySkillId) or {power = 40, type = 8, category = 1}
    
    -- 扣除敌人PP
    for i, sid in ipairs(battle.enemy.skills) do
        if sid == enemySkillId then
            battle.enemy.skillPP[i] = math.max(0, (battle.enemy.skillPP[i] or 0) - 1)
            break
        end
    end
    
    -- 处理回合开始时的状态效果
    local playerStatusDamage = SeerBattle.processStatusEffects(battle.player)
    local enemyStatusDamage = SeerBattle.processStatusEffects(battle.enemy)
    
    -- 应用状态伤害
    if playerStatusDamage > 0 then
        battle.player.hp = math.max(0, battle.player.hp - playerStatusDamage)
    end
    if enemyStatusDamage > 0 then
        battle.enemy.hp = math.max(0, battle.enemy.hp - enemyStatusDamage)
    end
    
    -- 检查状态伤害是否导致死亡
    if battle.player.hp <= 0 then
        battle.isOver = true
        battle.winner = 0
        return {
            turn = battle.turn,
            isOver = true,
            winner = 0,
            reason = 0
        }
    end
    if battle.enemy.hp <= 0 then
        battle.isOver = true
        battle.winner = battle.userId
        return {
            turn = battle.turn,
            isOver = true,
            winner = battle.userId,
            reason = 0
        }
    end
    
    -- 检查是否可以行动
    local playerCanAct, playerActReason = SeerBattle.canAct(battle.player)
    local enemyCanAct, enemyActReason = SeerBattle.canAct(battle.enemy)
    
    -- 决定先后攻
    local playerFirst = SeerBattle.compareSpeed(battle.player, battle.enemy, playerSkill, enemySkill)
    
    local result = {
        turn = battle.turn,
        playerSkillId = playerSkillId,
        enemySkillId = enemySkillId,
        firstAttack = nil,
        secondAttack = nil,
        isOver = false,
        winner = nil,
        playerStatusDamage = playerStatusDamage,
        enemyStatusDamage = enemyStatusDamage
    }
    
    if playerFirst then
        -- 玩家先攻
        if playerCanAct then
            result.firstAttack = SeerBattle.executeAttack(battle.player, battle.enemy, playerSkill, battle.userId, true)
            battle.enemy.hp = result.firstAttack.targetRemainHp
        else
            -- 玩家无法行动
            result.firstAttack = {
                userId = battle.userId,
                skillId = 0,
                damage = 0,
                isCrit = false,
                typeMod = 1,
                attackerRemainHp = battle.player.hp,
                attackerMaxHp = battle.player.maxHp,
                targetRemainHp = battle.enemy.hp,
                targetMaxHp = battle.enemy.maxHp,
                cannotAct = true,
                reason = playerActReason
            }
        end
        
        if battle.enemy.hp <= 0 then
            battle.isOver = true
            battle.winner = battle.userId
            result.isOver = true
            result.winner = battle.userId
        else
            -- 敌方反击
            if enemyCanAct then
                result.secondAttack = SeerBattle.executeAttack(battle.enemy, battle.player, enemySkill, 0, false)
                battle.player.hp = result.secondAttack.targetRemainHp
            else
                result.secondAttack = {
                    userId = 0,
                    skillId = 0,
                    damage = 0,
                    isCrit = false,
                    typeMod = 1,
                    attackerRemainHp = battle.enemy.hp,
                    attackerMaxHp = battle.enemy.maxHp,
                    targetRemainHp = battle.player.hp,
                    targetMaxHp = battle.player.maxHp,
                    cannotAct = true,
                    reason = enemyActReason
                }
            end
            
            if battle.player.hp <= 0 then
                battle.isOver = true
                battle.winner = 0
                result.isOver = true
                result.winner = 0
            end
        end
    else
        -- 敌方先攻
        if enemyCanAct then
            result.firstAttack = SeerBattle.executeAttack(battle.enemy, battle.player, enemySkill, 0, true)
            battle.player.hp = result.firstAttack.targetRemainHp
        else
            result.firstAttack = {
                userId = 0,
                skillId = 0,
                damage = 0,
                isCrit = false,
                typeMod = 1,
                attackerRemainHp = battle.enemy.hp,
                attackerMaxHp = battle.enemy.maxHp,
                targetRemainHp = battle.player.hp,
                targetMaxHp = battle.player.maxHp,
                cannotAct = true,
                reason = enemyActReason
            }
        end
        
        if battle.player.hp <= 0 then
            battle.isOver = true
            battle.winner = 0
            result.isOver = true
            result.winner = 0
        else
            -- 玩家反击
            if playerCanAct then
                result.secondAttack = SeerBattle.executeAttack(battle.player, battle.enemy, playerSkill, battle.userId, false)
                battle.enemy.hp = result.secondAttack.targetRemainHp
            else
                result.secondAttack = {
                    userId = battle.userId,
                    skillId = 0,
                    damage = 0,
                    isCrit = false,
                    typeMod = 1,
                    attackerRemainHp = battle.player.hp,
                    attackerMaxHp = battle.player.maxHp,
                    targetRemainHp = battle.enemy.hp,
                    targetMaxHp = battle.enemy.maxHp,
                    cannotAct = true,
                    reason = playerActReason
                }
            end
            
            if battle.enemy.hp <= 0 then
                battle.isOver = true
                battle.winner = battle.userId
                result.isOver = true
                result.winner = battle.userId
            end
        end
    end
    
    -- 记录战斗日志
    table.insert(battle.log, result)
    
    return result
end

-- 执行单次攻击
-- isFirst: 是否先手攻击 (用于 CritAtkFirst/CritAtkSecond 判断)
function SeerBattle.executeAttack(attacker, defender, skill, attackerUserId, isFirst)
    local effectId = skill.sideEffect
    local effectArg = skill.sideEffectArg
    local effectResults = {}
    
    -- 检查保护状态
    if defender.protected then
        defender.protected = false
        return {
            userId = attackerUserId,
            skillId = skill.id or 10001,
            damage = 0,
            isCrit = false,
            typeMod = 1,
            attackerRemainHp = attacker.hp,
            attackerMaxHp = attacker.maxHp,
            targetRemainHp = defender.hp,
            targetMaxHp = defender.maxHp,
            blocked = true,
            atkTimes = 0,  -- 0 = MISS/Blocked display on client
            effects = {}
        }
    end
    
    -- 检查命中 (必中技能跳过)
    local hit = skill.mustHit or SeerBattle.checkHit(attacker, defender, skill)
    
    if not hit then
        return {
            userId = attackerUserId,
            skillId = skill.id or 10001,
            damage = 0,
            isCrit = false,
            typeMod = 1,
            attackerRemainHp = attacker.hp,
            attackerMaxHp = attacker.maxHp,
            targetRemainHp = defender.hp,
            targetMaxHp = defender.maxHp,
            missed = true,
            atkTimes = 0,  -- 0 = MISS display on client
            effects = {}
        }
    end
    
    -- 处理连续攻击 (SideEffect=31)
    local hitCount = 1
    if effectId == 31 then
        hitCount = SkillEffects.getMultiHitCount(SkillEffects.parseArgs(effectArg))
    end
    
    local totalDamage = 0
    local isCrit = false
    local typeMod = 1
    local gainHp = 0
    local recoilDamage = 0
    
    for i = 1, hitCount do
        -- 暴击判断，传入 defender 和 isFirst 用于特殊暴击条件
        local thisCrit = SeerBattle.checkCrit(attacker, defender, skill, isFirst)
        if thisCrit then isCrit = true end
        
        local damage
        
        -- 处理特殊伤害计算
        if effectId == 34 then
            -- 克制: 伤害=对方剩余HP的一定比例
            damage = SkillEffects.getSpecialDamage(effectId, skill.power or 0, attacker, defender, effectArg)
            typeMod = 1
        elseif effectId == 35 then
            -- 惩罚: 根据对方强化等级增加威力
            local adjustedPower = SkillEffects.getSpecialDamage(effectId, skill.power or 60, attacker, defender, effectArg)
            local tempSkill = {
                power = adjustedPower,
                type = skill.type,
                category = skill.category,
                accuracy = skill.accuracy
            }
            damage, typeMod, _ = SeerBattle.calculateDamage(attacker, defender, tempSkill, thisCrit)
        elseif effectId == 8 then
            -- 手下留情: 不会使对方HP降到0以下
            damage, typeMod, _ = SeerBattle.calculateDamage(attacker, defender, skill, thisCrit)
            if defender.hp - damage < 1 then
                damage = defender.hp - 1
            end
        else
            -- 普通伤害计算
            damage, typeMod, _ = SeerBattle.calculateDamage(attacker, defender, skill, thisCrit)
        end
        
        totalDamage = totalDamage + damage
    end
    
    -- 应用伤害
    local targetRemainHp = math.max(0, defender.hp - totalDamage)
    defender.hp = targetRemainHp
    
    -- 处理技能附加效果
    if effectId and effectId > 0 then
        -- 吸取效果 (SideEffect=1)
        if effectId == 1 then
            local drainAmount = math.floor(totalDamage / 2)
            local oldHp = attacker.hp
            attacker.hp = math.min(attacker.maxHp, attacker.hp + drainAmount)
            gainHp = attacker.hp - oldHp
            table.insert(effectResults, {type = "drain", healAmount = gainHp})
        end
        
        -- 反伤效果 (SideEffect=6)
        if effectId == 6 then
            local args = SkillEffects.parseArgs(effectArg)
            local divisor = args[1] or 4
            recoilDamage = math.floor(totalDamage / divisor)
            attacker.hp = math.max(0, attacker.hp - recoilDamage)
            table.insert(effectResults, {type = "recoil", damage = recoilDamage})
        end
        
        -- 能力修改效果 (SideEffect=5)
        -- 格式: SideEffectArg="stat chance stages"
        -- stat: 0=攻击, 1=防御, 2=特攻, 3=特防, 4=速度, 5=命中
        -- stages: 负数=降低对手, 正数=提升自己
        if effectId == 5 then
            local args = SkillEffects.parseArgs(effectArg)
            local stat = args[1] or 0
            local chance = args[2] or 100
            local stages = args[3] or -1
            
            if math.random(100) <= chance then
                if stages < 0 then
                    -- 降低对手能力
                    defender.battleLv = defender.battleLv or {0, 0, 0, 0, 0, 0}
                    local statIndex = stat + 1  -- Lua数组从1开始
                    defender.battleLv[statIndex] = math.max(-6, (defender.battleLv[statIndex] or 0) + stages)
                    table.insert(effectResults, {type = "stat_down", target = "defender", stat = stat, stages = -stages})
                    print(string.format("\27[33m[SideEffect=5] 降低对手能力: stat=%d stages=%d, 新等级=%d\27[0m", stat, stages, defender.battleLv[statIndex]))
                else
                    -- 提升自己能力
                    attacker.battleLv = attacker.battleLv or {0, 0, 0, 0, 0, 0}
                    local statIndex = stat + 1
                    attacker.battleLv[statIndex] = math.min(6, (attacker.battleLv[statIndex] or 0) + stages)
                    table.insert(effectResults, {type = "stat_up", target = "attacker", stat = stat, stages = stages})
                    print(string.format("\27[33m[SideEffect=5] 提升自己能力: stat=%d stages=%d, 新等级=%d\27[0m", stat, stages, attacker.battleLv[statIndex]))
                end
            end
        end
        
        -- 能力自提升效果 (SideEffect=4)
        -- 格式: SideEffectArg="stat chance stages"
        if effectId == 4 then
            local args = SkillEffects.parseArgs(effectArg)
            local stat = args[1] or 0
            local chance = args[2] or 100
            local stages = args[3] or 1
            
            if math.random(100) <= chance then
                attacker.battleLv = attacker.battleLv or {0, 0, 0, 0, 0, 0}
                local statIndex = stat + 1
                attacker.battleLv[statIndex] = math.min(6, (attacker.battleLv[statIndex] or 0) + stages)
                table.insert(effectResults, {type = "stat_up", target = "attacker", stat = stat, stages = stages})
                print(string.format("\27[33m[SideEffect=4] 提升自己能力: stat=%d stages=%d, 新等级=%d\27[0m", stat, stages, attacker.battleLv[statIndex]))
            end
        end
        
        -- 其他效果通过 SkillEffects.processEffect 处理
        if effectId ~= 1 and effectId ~= 4 and effectId ~= 5 and effectId ~= 6 and effectId ~= 8 and effectId ~= 31 and effectId ~= 34 and effectId ~= 35 then
            local results = SkillEffects.processEffect(effectId, attacker, defender, totalDamage, effectArg)
            for _, r in ipairs(results) do
                table.insert(effectResults, r)
            end
        end
    end
    
    -- 疲惫效果 (SideEffect=20) - 使用后下回合无法行动
    if effectId == 20 then
        local args = SkillEffects.parseArgs(effectArg)
        local chance = args[1] or 100
        local turns = args[2] or 1
        if math.random(100) <= chance then
            attacker.fatigue = turns
            table.insert(effectResults, {type = "fatigue", turns = turns})
        end
    end
    
    return {
        userId = attackerUserId,
        skillId = skill.id or 10001,
        damage = totalDamage,
        isCrit = isCrit,
        typeMod = typeMod,
        attackerRemainHp = attacker.hp,
        attackerMaxHp = attacker.maxHp,
        targetRemainHp = targetRemainHp,
        targetMaxHp = defender.maxHp,
        gainHp = gainHp,
        recoilDamage = recoilDamage,
        atkTimes = hitCount,
        effects = effectResults,
        -- Snapshot for packet
        attackerBattleLv = {unpack(attacker.battleLv or {0,0,0,0,0,0})},
        targetBattleLv = {unpack(defender.battleLv or {0,0,0,0,0,0})},
        attackerStatus = attacker.status or {},
        targetStatus = defender.status or {}
    }
end

-- ==================== 战斗结束处理 ====================

-- 计算战斗奖励
function SeerBattle.calculateRewards(battle, winnerId)
    local rewards = {
        exp = 0,
        coins = 0,
        items = {}
    }
    
    if winnerId == battle.userId then
        -- 玩家胜利
        local enemyLevel = battle.enemy.level or 1
        local playerLevel = battle.player.level or 5
        
        -- 经验计算: 基础经验 * 等级差修正
        local baseExp = enemyLevel * 5
        local levelDiff = enemyLevel - playerLevel
        local expMod = 1 + (levelDiff * 0.1)
        expMod = math.max(0.5, math.min(2.0, expMod))
        
        rewards.exp = math.floor(baseExp * expMod)
        rewards.coins = enemyLevel * 10
    end
    
    return rewards
end

-- 检查超时
function SeerBattle.checkTimeout(battle)
    local currentTime = os.time()
    local timeSinceLastAction = currentTime - battle.lastActionTime
    
    if timeSinceLastAction > SeerBattle.TURN_TIMEOUT then
        battle.isOver = true
        battle.reason = 2  -- 超时
        return true
    end
    
    return false
end

return SeerBattle
