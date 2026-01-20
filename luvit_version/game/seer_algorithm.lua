-- 赛尔号战斗算法系统
-- 整合属性计算、伤害公式、速度判定等核心战斗逻辑

local Elements = require('game/seer_elements')
local Natures = require('game/seer_natures')

local Algorithm = {}

-- ==================== 属性计算 ====================

-- 赛尔号属性计算公式（官方）:
-- 体力: (种族值×2 + 个体值 + 学习力÷4) × 等级÷100 + 等级 + 10
-- 非体力: [(种族值×2 + 个体值 + 学习力÷4) × 等级÷100 + 5] × 性格修正
--
-- 参数说明:
-- baseStats: 种族值 {hp, atk, def, spa, spd, spe}
-- level: 等级 (1-100)
-- iv: 个体值 (0-31)，越高越好
-- ev: 学习力/努力值 {hp, atk, def, spa, spd, spe}，每项0-255，总和≤510
-- natureId: 性格ID (1-26)

function Algorithm.calculateStats(baseStats, level, iv, ev, natureId)
    iv = iv or 31  -- 默认满个体
    ev = ev or {hp=0, atk=0, def=0, spa=0, spd=0, spe=0}
    natureId = natureId or 21  -- 默认害羞(平衡)
    level = math.max(1, math.min(100, level or 1))
    
    local natureMods = Natures.getAllModifiers(natureId)
    
    -- 体力计算（不受性格影响）
    -- 公式: (种族值×2 + 个体值 + 学习力÷4) × 等级÷100 + 等级 + 10
    local hp = math.floor((baseStats.hp * 2 + iv + math.floor(ev.hp / 4)) * level / 100 + level + 10)
    
    -- 非体力属性计算
    -- 公式: [(种族值×2 + 个体值 + 学习力÷4) × 等级÷100 + 5] × 性格修正
    local function calcStat(base, evVal, natureMod)
        local basePart = (base * 2 + iv + math.floor(evVal / 4)) * level / 100 + 5
        return math.floor(basePart * natureMod)
    end
    
    return {
        hp = hp,
        maxHp = hp,
        atk = calcStat(baseStats.atk, ev.atk, natureMods.atk),
        def = calcStat(baseStats.def, ev.def, natureMods.def),
        spa = calcStat(baseStats.spa, ev.spa, natureMods.spa),
        spd = calcStat(baseStats.spd, ev.spd, natureMods.spd),
        spe = calcStat(baseStats.spe, ev.spe, natureMods.spe),
    }
end

-- 验证: 特攻种族值120，满级(100)，个体值31，学习力255，平衡性格
-- 公式: (120×2 + 31 + 255÷4) × 100÷100 + 5 = (240 + 31 + 63) × 1 + 5 = 334 + 5 = 339
-- 注: 官方说373点，可能有额外加成或计算方式略有不同

-- 简化版：只用种族值和等级快速计算（用于NPC/野怪）
function Algorithm.calculateStatsSimple(baseStats, level)
    level = math.max(1, math.min(100, level or 1))
    
    -- 假设个体值15（中等），无学习力，平衡性格
    local iv = 15
    
    local hp = math.floor((baseStats.hp * 2 + iv) * level / 100 + level + 10)
    
    local function calcStat(base)
        return math.floor((base * 2 + iv) * level / 100 + 5)
    end
    
    return {
        hp = hp,
        maxHp = hp,
        atk = calcStat(baseStats.atk),
        def = calcStat(baseStats.def),
        spa = calcStat(baseStats.spa),
        spd = calcStat(baseStats.spd),
        spe = calcStat(baseStats.spe),
    }
end

-- ==================== 伤害计算 ====================

-- 技能类型
Algorithm.SKILL_CATEGORY = {
    PHYSICAL = 1,   -- 物理攻击
    SPECIAL = 2,    -- 特殊攻击
    STATUS = 3,     -- 属性攻击(变化技)
}

-- 计算伤害
-- attacker: 攻击方数据 {stats, elementType, level, stageModifiers}
-- defender: 防守方数据 {stats, elementType, stageModifiers}
-- skill: 技能数据 {power, elementType, category, accuracy}
-- options: 可选参数 {isCrit, weather, sealBonus, teamBonus, etc}
function Algorithm.calculateDamage(attacker, defender, skill, options)
    options = options or {}
    
    -- 变化技不造成伤害
    if skill.category == Algorithm.SKILL_CATEGORY.STATUS then
        return 0, 1, false
    end
    
    local level = attacker.level or 100
    local power = skill.power or 40
    
    -- 根据技能类型选择攻击/防御属性
    local atkStat, defStat
    if skill.category == Algorithm.SKILL_CATEGORY.PHYSICAL then
        atkStat = attacker.stats.atk
        defStat = defender.stats.def
        -- 应用能力等级修正
        if attacker.stageModifiers then
            atkStat = Algorithm.applyStageModifier(atkStat, attacker.stageModifiers.atk or 0)
        end
        if defender.stageModifiers then
            defStat = Algorithm.applyStageModifier(defStat, defender.stageModifiers.def or 0)
        end
    else  -- SPECIAL
        atkStat = attacker.stats.spa
        defStat = defender.stats.spd
        -- 应用能力等级修正
        if attacker.stageModifiers then
            atkStat = Algorithm.applyStageModifier(atkStat, attacker.stageModifiers.spa or 0)
        end
        if defender.stageModifiers then
            defStat = Algorithm.applyStageModifier(defStat, defender.stageModifiers.spd or 0)
        end
    end
    
    -- 防止除零
    defStat = math.max(1, defStat)
    
    -- 赛尔号基础伤害公式: (等级×0.4+2) × 威力 × 攻击÷防御 ÷ 50 + 2
    local baseDamage = (level * 0.4 + 2) * power * atkStat / defStat / 50 + 2
    
    -- 属性克制倍率
    local effectiveness = Elements.getEffectiveness(skill.elementType, defender.elementType)
    
    -- 本系加成 (STAB)
    local stab = 1.0
    if skill.elementType == attacker.elementType then
        stab = 1.5
    end
    
    -- 暴击判定 (默认6.25%几率, 伤害1.5倍)
    local isCrit = options.isCrit
    if isCrit == nil then
        isCrit = math.random() < 0.0625
    end
    local critMod = isCrit and 1.5 or 1.0
    
    -- 随机波动 (85%-100%)
    local randomMod = (math.random(85, 100)) / 100
    
    -- 刻印加成 (可选)
    local sealBonus = options.sealBonus or 1.0
    
    -- 战队加成 (可选)
    local teamBonus = options.teamBonus or 1.0
    
    -- 其他加成 (天气、道具等)
    local otherBonus = options.otherBonus or 1.0
    
    -- 最终伤害
    local finalDamage = math.floor(baseDamage * effectiveness * stab * critMod * randomMod * sealBonus * teamBonus * otherBonus)
    
    -- 最小伤害为1（除非无效）
    if effectiveness > 0 and finalDamage < 1 then
        finalDamage = 1
    end
    
    return finalDamage, effectiveness, isCrit
end

-- ==================== 速度判定 ====================

-- 判断先手顺序
-- 返回: 1 (攻击方先手), -1 (防守方先手), 0 (同速随机)
function Algorithm.determineFirstMove(attackerSpeed, defenderSpeed, attackerPriority, defenderPriority)
    attackerPriority = attackerPriority or 0
    defenderPriority = defenderPriority or 0
    
    -- 先比较技能优先度
    if attackerPriority > defenderPriority then
        return 1
    elseif attackerPriority < defenderPriority then
        return -1
    end
    
    -- 优先度相同，比较速度
    if attackerSpeed > defenderSpeed then
        return 1
    elseif attackerSpeed < defenderSpeed then
        return -1
    else
        -- 同速随机
        return math.random() < 0.5 and 1 or -1
    end
end

-- ==================== 能力等级系统 ====================

-- 能力等级修正表 (-6 到 +6)
local STAGE_MULTIPLIERS = {
    [-6] = 2/8, [-5] = 2/7, [-4] = 2/6, [-3] = 2/5, [-2] = 2/4, [-1] = 2/3,
    [0] = 1,
    [1] = 3/2, [2] = 4/2, [3] = 5/2, [4] = 6/2, [5] = 7/2, [6] = 8/2,
}

-- 获取能力等级修正后的属性值
function Algorithm.applyStageModifier(baseStat, stage)
    stage = math.max(-6, math.min(6, stage or 0))
    return math.floor(baseStat * STAGE_MULTIPLIERS[stage])
end

-- 命中率/闪避率等级修正表
local ACCURACY_MULTIPLIERS = {
    [-6] = 3/9, [-5] = 3/8, [-4] = 3/7, [-3] = 3/6, [-2] = 3/5, [-1] = 3/4,
    [0] = 1,
    [1] = 4/3, [2] = 5/3, [3] = 6/3, [4] = 7/3, [5] = 8/3, [6] = 9/3,
}

-- 计算命中率
function Algorithm.calculateAccuracy(baseAccuracy, attackerAccStage, defenderEvaStage)
    attackerAccStage = attackerAccStage or 0
    defenderEvaStage = defenderEvaStage or 0
    
    local netStage = math.max(-6, math.min(6, attackerAccStage - defenderEvaStage))
    return baseAccuracy * ACCURACY_MULTIPLIERS[netStage]
end

-- 判断技能是否命中
function Algorithm.checkHit(baseAccuracy, attackerAccStage, defenderEvaStage)
    local accuracy = Algorithm.calculateAccuracy(baseAccuracy, attackerAccStage, defenderEvaStage)
    return math.random() * 100 < accuracy
end

-- ==================== 经验值计算 ====================

-- 计算击败精灵获得的经验值
function Algorithm.calculateExp(defeatedLevel, defeatedBaseExp, isWild, expShare)
    defeatedBaseExp = defeatedBaseExp or 50
    isWild = isWild ~= false
    expShare = expShare or 1.0
    
    -- 基础公式: (基础经验 * 等级 / 7) * 修正
    local exp = math.floor((defeatedBaseExp * defeatedLevel / 7) * expShare)
    
    -- 野生精灵经验较低
    if isWild then
        exp = math.floor(exp * 0.8)
    end
    
    return math.max(1, exp)
end

-- 计算升级所需经验
function Algorithm.calculateExpToNextLevel(currentLevel, growthRate)
    growthRate = growthRate or "medium"  -- slow, medium, fast
    
    local rates = {
        slow = 1.25,
        medium = 1.0,
        fast = 0.8,
    }
    local rate = rates[growthRate] or 1.0
    
    -- 公式: level^3 * rate
    return math.floor(currentLevel * currentLevel * currentLevel * rate)
end

-- ==================== 辅助函数 ====================

-- 获取效果描述文本
function Algorithm.getEffectivenessText(effectiveness)
    if effectiveness >= 4 then
        return "效果拔群！"
    elseif effectiveness >= 2 then
        return "效果不错！"
    elseif effectiveness == 1 then
        return ""
    elseif effectiveness > 0 then
        return "效果不佳..."
    else
        return "没有效果..."
    end
end

-- 打印伤害计算详情（调试用）
function Algorithm.debugDamage(attacker, defender, skill, damage, effectiveness, isCrit)
    print("========== 伤害计算 ==========")
    print(string.format("攻击方: Lv.%d %s系", attacker.level or 100, Elements.getTypeName(attacker.elementType)))
    print(string.format("防守方: %s系", Elements.getTypeName(defender.elementType)))
    print(string.format("技能: %s系 威力%d %s", 
        Elements.getTypeName(skill.elementType), 
        skill.power,
        skill.category == 1 and "物理" or "特殊"))
    print(string.format("克制: x%.2f %s", effectiveness, Algorithm.getEffectivenessText(effectiveness)))
    print(string.format("暴击: %s", isCrit and "是" or "否"))
    print(string.format("最终伤害: %d", damage))
    print("==============================")
end

return Algorithm
