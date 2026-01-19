-- seer_battle_ai.lua
-- 赛尔号战斗AI系统
-- 用于控制野怪/BOSS的战斗行为

local SeerSkills = require('./seer_skills')
local SeerPets = require('./seer_pets')

local BattleAI = {}

-- ==================== AI 类型定义 ====================

BattleAI.TYPE = {
    RANDOM = 1,           -- 随机选择技能
    AGGRESSIVE = 2,       -- 攻击型 (优先高威力技能)
    DEFENSIVE = 3,        -- 防御型 (优先变化技能/回复)
    SMART = 4,            -- 智能型 (考虑属性克制)
    NOVICE_BOSS = 10,     -- 新手教程BOSS (简单AI)
    WILD_MONSTER = 11,    -- 野生精灵 (基础AI)
}

-- ==================== AI 选择技能 ====================

-- 主入口：根据AI类型选择技能
function BattleAI.selectSkill(aiType, aiPet, playerPet, context)
    context = context or {}
    
    if aiType == BattleAI.TYPE.NOVICE_BOSS then
        return BattleAI.noviceBossAI(aiPet, playerPet, context)
    elseif aiType == BattleAI.TYPE.WILD_MONSTER then
        return BattleAI.wildMonsterAI(aiPet, playerPet, context)
    elseif aiType == BattleAI.TYPE.AGGRESSIVE then
        return BattleAI.aggressiveAI(aiPet, playerPet, context)
    elseif aiType == BattleAI.TYPE.DEFENSIVE then
        return BattleAI.defensiveAI(aiPet, playerPet, context)
    elseif aiType == BattleAI.TYPE.SMART then
        return BattleAI.smartAI(aiPet, playerPet, context)
    else
        return BattleAI.randomAI(aiPet, playerPet, context)
    end
end

-- ==================== 新手BOSS AI ====================

-- 新手教程BOSS专用AI
-- 特点：简单、让玩家容易获胜，偶尔使用弱技能
function BattleAI.noviceBossAI(aiPet, playerPet, context)
    local skills = aiPet.skills or {}
    local validSkills = {}
    
    -- 过滤有效技能
    for i, skillId in ipairs(skills) do
        if skillId and skillId > 0 then
            local skill = SeerSkills.get(skillId)
            if skill then
                table.insert(validSkills, {
                    id = skillId,
                    power = skill.power or 0,
                    pp = aiPet.skillPP and aiPet.skillPP[i] or 99
                })
            end
        end
    end
    
    -- 如果没有有效技能，使用撞击
    if #validSkills == 0 then
        return 10001  -- 撞击
    end
    
    -- 新手BOSS策略：70%几率选择最弱技能，30%随机
    if math.random(100) <= 70 then
        -- 选择威力最低的技能
        local weakestSkill = validSkills[1]
        for _, skill in ipairs(validSkills) do
            if skill.power < weakestSkill.power then
                weakestSkill = skill
            end
        end
        return weakestSkill.id
    else
        -- 随机选择
        return validSkills[math.random(#validSkills)].id
    end
end

-- ==================== 野生精灵 AI ====================

-- 野生精灵AI
-- 特点：基础AI，随机选择但会避免无PP的技能
function BattleAI.wildMonsterAI(aiPet, playerPet, context)
    local skills = aiPet.skills or {}
    local validSkills = {}
    
    -- 过滤有PP的技能
    for i, skillId in ipairs(skills) do
        if skillId and skillId > 0 then
            local pp = aiPet.skillPP and aiPet.skillPP[i] or 99
            if pp > 0 then
                table.insert(validSkills, skillId)
            end
        end
    end
    
    -- 如果没有PP，使用挣扎
    if #validSkills == 0 then
        return 10000  -- 挣扎 (或撞击)
    end
    
    -- 随机选择
    return validSkills[math.random(#validSkills)]
end

-- ==================== 随机 AI ====================

function BattleAI.randomAI(aiPet, playerPet, context)
    local skills = aiPet.skills or {}
    
    for _, skillId in ipairs(skills) do
        if skillId and skillId > 0 then
            return skillId
        end
    end
    
    return 10001  -- 撞击
end

-- ==================== 攻击型 AI ====================

-- 优先选择高威力技能
function BattleAI.aggressiveAI(aiPet, playerPet, context)
    local skills = aiPet.skills or {}
    local bestSkill = nil
    local bestPower = -1
    
    for i, skillId in ipairs(skills) do
        if skillId and skillId > 0 then
            local skill = SeerSkills.get(skillId)
            local pp = aiPet.skillPP and aiPet.skillPP[i] or 99
            
            if skill and pp > 0 and (skill.power or 0) > bestPower then
                bestPower = skill.power or 0
                bestSkill = skillId
            end
        end
    end
    
    return bestSkill or 10001
end

-- ==================== 防御型 AI ====================

-- 优先使用变化技能和回复
function BattleAI.defensiveAI(aiPet, playerPet, context)
    local skills = aiPet.skills or {}
    local statusSkills = {}
    local attackSkills = {}
    
    for i, skillId in ipairs(skills) do
        if skillId and skillId > 0 then
            local skill = SeerSkills.get(skillId)
            local pp = aiPet.skillPP and aiPet.skillPP[i] or 99
            
            if skill and pp > 0 then
                -- category: 1=物理, 2=特殊, 4=变化
                if skill.category == 4 then
                    table.insert(statusSkills, skillId)
                else
                    table.insert(attackSkills, skillId)
                end
            end
        end
    end
    
    -- 如果HP低于50%，优先使用回复/变化技能
    local hpRatio = (aiPet.hp or 100) / (aiPet.maxHp or 100)
    
    if hpRatio < 0.5 and #statusSkills > 0 then
        return statusSkills[math.random(#statusSkills)]
    end
    
    -- 否则随机攻击
    if #attackSkills > 0 then
        return attackSkills[math.random(#attackSkills)]
    end
    
    return 10001
end

-- ==================== 智能型 AI ====================

-- 考虑属性克制的智能AI
function BattleAI.smartAI(aiPet, playerPet, context)
    local skills = aiPet.skills or {}
    local bestSkill = nil
    local bestScore = -1
    
    -- 获取玩家精灵属性
    local playerType = playerPet.type or 8
    
    for i, skillId in ipairs(skills) do
        if skillId and skillId > 0 then
            local skill = SeerSkills.get(skillId)
            local pp = aiPet.skillPP and aiPet.skillPP[i] or 99
            
            if skill and pp > 0 then
                local score = 0
                local power = skill.power or 0
                
                if power > 0 then
                    -- 基础分数 = 威力
                    score = power
                    
                    -- 属性克制加成
                    local skillType = skill.type or 8
                    local typeMultiplier = BattleAI.getTypeMultiplier(skillType, playerType)
                    score = score * typeMultiplier
                    
                    -- 命中率修正
                    local accuracy = skill.accuracy or 100
                    score = score * (accuracy / 100)
                    
                    -- 收割加成：对方HP低时优先高威力
                    if playerPet.hp and playerPet.maxHp then
                        local enemyHpRatio = playerPet.hp / playerPet.maxHp
                        if enemyHpRatio < 0.3 then
                            score = score * 1.5
                        end
                    end
                else
                    -- 变化技能基础分
                    score = 20
                end
                
                if score > bestScore then
                    bestScore = score
                    bestSkill = skillId
                end
            end
        end
    end
    
    return bestSkill or 10001
end

-- ==================== 辅助函数 ====================

-- 属性克制表 (简化版)
local typeChart = {
    [1] = {2, 7},           -- 草克水、地面
    [2] = {3, 7},           -- 水克火、地面
    [3] = {1, 6, 9},        -- 火克草、机械、冰
    [4] = {1, 11},          -- 飞行克草、战斗
    [5] = {2, 4},           -- 电克水、飞行
    [7] = {3, 5, 6},        -- 地面克火、电、机械
    [9] = {1, 4, 7, 15},    -- 冰克草、飞行、地面、龙
    [10] = {11},            -- 超能克战斗
    [11] = {8, 9},          -- 战斗克普通、冰
    [12] = {13},            -- 光克暗影
    [13] = {10, 12},        -- 暗影克超能、光
    [15] = {15},            -- 龙克龙
    [16] = {13, 15}         -- 圣灵克暗影、龙
}

function BattleAI.getTypeMultiplier(atkType, defType)
    local dominated = typeChart[atkType] or {}
    for _, t in ipairs(dominated) do
        if t == defType then
            return 2.0
        end
    end
    return 1.0
end

-- 获取BOSS的AI类型
function BattleAI.getBossAIType(bossId)
    -- 新手教程BOSS (ID 58 = 塔奇拉顿, ID 13 = 比比鼠)
    if bossId == 58 or bossId == 13 then
        return BattleAI.TYPE.NOVICE_BOSS
    end
    
    -- 默认野生精灵AI
    return BattleAI.TYPE.WILD_MONSTER
end

return BattleAI
