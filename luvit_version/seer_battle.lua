-- seer_battle.lua
-- 赛尔号战斗系统

local SeerMonsters = require('./seer_monsters')
local SeerSkills = require('./seer_skills')

local SeerBattle = {}

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

-- 计算伤害
-- 公式: ((2*Lv/5+2)*Power*Atk/Def/50+2)*STAB*TypeMod*Crit*Random
function SeerBattle.calculateDamage(attacker, defender, skill, isCrit)
    local level = attacker.level or 5
    local power = skill.power or 40
    
    -- 物理/特殊攻击
    local atk, def
    if skill.category == 1 then  -- 物理
        atk = attacker.attack or 39
        def = defender.defence or 35
    else  -- 特殊
        atk = attacker.spAtk or 78
        def = defender.spDef or 36
    end
    
    -- 基础伤害
    local baseDamage = math.floor((2 * level / 5 + 2) * power * atk / def / 50 + 2)
    
    -- STAB (同属性加成)
    local stab = 1.0
    if skill.type == attacker.type then
        stab = 1.5
    end
    
    -- 属性克制
    local typeMod = SeerBattle.getTypeMultiplier(skill.type, defender.type)
    
    -- 暴击
    local critMod = isCrit and 1.5 or 1.0
    
    -- 随机波动 (85%-100%)
    local randomMod = (85 + math.random(0, 15)) / 100
    
    local damage = math.floor(baseDamage * stab * typeMod * critMod * randomMod)
    
    -- 最小伤害为1
    return math.max(1, damage), typeMod, isCrit
end

-- 判断是否暴击
function SeerBattle.checkCrit(skill)
    local critRate = skill.critRate or 1
    -- 暴击率 = critRate / 16
    return math.random(1, 16) <= critRate
end

-- AI选择技能
function SeerBattle.aiSelectSkill(aiPet, playerPet, skills)
    if not skills or #skills == 0 then
        return nil
    end
    
    -- 简单AI: 选择威力最高且有PP的技能
    local bestSkill = nil
    local bestScore = -1
    
    for _, skillId in ipairs(skills) do
        if skillId and skillId > 0 then
            local skill = SeerSkills.get(skillId)
            if skill and skill.power and skill.power > 0 then
                -- 计算技能评分 (威力 * 属性克制)
                local typeMod = SeerBattle.getTypeMultiplier(skill.type or 8, playerPet.type or 8)
                local score = (skill.power or 0) * typeMod
                
                if score > bestScore then
                    bestScore = score
                    bestSkill = skillId
                end
            end
        end
    end
    
    -- 如果没有攻击技能，随机选一个
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
function SeerBattle.compareSpeed(pet1, pet2, skill1, skill2)
    -- 先检查技能优先级
    local priority1 = skill1 and skill1.priority or 0
    local priority2 = skill2 and skill2.priority or 0
    
    if priority1 ~= priority2 then
        return priority1 > priority2
    end
    
    -- 速度相同时随机
    local speed1 = pet1.speed or 39
    local speed2 = pet2.speed or 39
    
    if speed1 ~= speed2 then
        return speed1 > speed2
    end
    
    return math.random(1, 2) == 1
end

-- 创建战斗实例
function SeerBattle.createBattle(userId, playerPetData, enemyPetData)
    local battle = {
        battleId = os.time(),
        userId = userId,
        turn = 0,
        isOver = false,
        winner = nil,
        
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
            catchTime = playerPetData.catchTime or 0
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
            catchTime = enemyPetData.catchTime or 0
        }
    }
    
    return battle
end

-- 执行一回合战斗
function SeerBattle.executeTurn(battle, playerSkillId)
    battle.turn = battle.turn + 1
    
    local playerSkill = SeerSkills.get(playerSkillId) or {power = 40, type = 8, category = 1}
    local enemySkillId = SeerBattle.aiSelectSkill(battle.enemy, battle.player, battle.enemy.skills)
    local enemySkill = SeerSkills.get(enemySkillId) or {power = 40, type = 8, category = 1}
    
    -- 决定先后攻
    local playerFirst = SeerBattle.compareSpeed(battle.player, battle.enemy, playerSkill, enemySkill)
    
    local result = {
        turn = battle.turn,
        playerSkillId = playerSkillId,
        enemySkillId = enemySkillId,
        firstAttack = nil,
        secondAttack = nil,
        isOver = false,
        winner = nil
    }
    
    if playerFirst then
        -- 玩家先攻
        result.firstAttack = SeerBattle.executeAttack(battle.player, battle.enemy, playerSkill, battle.userId)
        battle.enemy.hp = result.firstAttack.targetRemainHp
        
        if battle.enemy.hp <= 0 then
            battle.isOver = true
            battle.winner = battle.userId
            result.isOver = true
            result.winner = battle.userId
        else
            -- 敌方反击
            result.secondAttack = SeerBattle.executeAttack(battle.enemy, battle.player, enemySkill, 0)
            battle.player.hp = result.secondAttack.targetRemainHp
            
            if battle.player.hp <= 0 then
                battle.isOver = true
                battle.winner = 0
                result.isOver = true
                result.winner = 0
            end
        end
    else
        -- 敌方先攻
        result.firstAttack = SeerBattle.executeAttack(battle.enemy, battle.player, enemySkill, 0)
        battle.player.hp = result.firstAttack.targetRemainHp
        
        if battle.player.hp <= 0 then
            battle.isOver = true
            battle.winner = 0
            result.isOver = true
            result.winner = 0
        else
            -- 玩家反击
            result.secondAttack = SeerBattle.executeAttack(battle.player, battle.enemy, playerSkill, battle.userId)
            battle.enemy.hp = result.secondAttack.targetRemainHp
            
            if battle.enemy.hp <= 0 then
                battle.isOver = true
                battle.winner = battle.userId
                result.isOver = true
                result.winner = battle.userId
            end
        end
    end
    
    return result
end

-- 执行单次攻击
function SeerBattle.executeAttack(attacker, defender, skill, attackerUserId)
    local isCrit = SeerBattle.checkCrit(skill)
    local damage, typeMod, _ = SeerBattle.calculateDamage(attacker, defender, skill, isCrit)
    
    local targetRemainHp = math.max(0, defender.hp - damage)
    
    return {
        userId = attackerUserId,
        skillId = skill.id or 10001,
        damage = damage,
        isCrit = isCrit,
        typeMod = typeMod,
        attackerRemainHp = attacker.hp,
        attackerMaxHp = attacker.maxHp,
        targetRemainHp = targetRemainHp,
        targetMaxHp = defender.maxHp
    }
end

return SeerBattle
