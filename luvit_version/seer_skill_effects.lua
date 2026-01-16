-- seer_skill_effects.lua
-- 赛尔号技能附加效果系统
-- 基于 skills.xml 中的 SideEffect 和 SideEffectArg 实现

local SkillEffects = {}

-- ==================== 效果类型定义 ====================
-- 从 skills.xml 注释和实际数据分析得出

SkillEffects.EFFECT = {
    -- 基础效果 (1-20)
    DRAIN = 1,              -- 吸取: 吸收造成伤害的一定比例恢复HP
    FLINCH = 2,             -- 畏缩: 使对方本回合无法行动 (需要先手)
    CLEAR_STATUS = 3,       -- 清除异常状态
    SELF_STAT_CHANGE = 4,   -- 自身能力变化: SideEffectArg="stat chance stages"
    FOE_STAT_CHANGE = 5,    -- 降低对方能力: SideEffectArg="stat chance stages"
    RECOIL = 6,             -- 反伤: 自身受到造成伤害的一定比例
    DESTINY_BOND = 7,       -- 同生共死: 自己倒下时对方也倒下
    FALSE_SWIPE = 8,        -- 手下留情: 不会使对方HP降到0以下
    RAGE = 9,               -- 愤怒: 受到攻击时攻击力上升
    PARALYZE = 10,          -- 麻痹
    TRAP = 11,              -- 束缚: 使对方无法逃跑/换宠
    BURN = 12,              -- 烧伤
    CONFUSE = 13,           -- 混乱
    BIND = 14,              -- 紧勒: 每回合造成伤害
    FEAR = 15,              -- 害怕: 有几率无法行动
    POISON = 16,            -- 中毒
    SLEEP = 17,             -- 睡眠
    FREEZE = 18,            -- 冰冻
    PETRIFY = 19,           -- 石化
    FATIGUE = 20,           -- 疲惫: 下回合无法行动
    
    -- 特殊效果 (21-50)
    MULTI_HIT = 31,         -- 连续攻击: SideEffectArg="min max"
    FIXED_DAMAGE = 32,      -- 固定伤害
    LEVEL_DAMAGE = 33,      -- 伤害等于等级
    COUNTER = 34,           -- 克制: 伤害=对方剩余HP的一半
    PUNISH = 35,            -- 惩罚: 根据对方强化等级增加威力
    PROTECT = 36,           -- 保护: 本回合免疫攻击
    HEAL = 37,              -- 回复HP
    WEATHER = 38,           -- 天气效果
    SWAP_STATS = 39,        -- 交换能力
    COPY_STAT = 40,         -- 复制能力
    
    -- 能力变化效果 (41-50)
    ATK_UP = 41,            -- 攻击+1
    DEF_UP = 42,            -- 防御+1
    SPATK_UP = 43,          -- 特攻+1
    SPDEF_UP = 44,          -- 特防+1
    SPD_UP = 45,            -- 速度+1
    ACC_UP = 46,            -- 命中+1
    ATK_DOWN = 47,          -- 攻击-1
    DEF_DOWN = 48,          -- 防御-1
    SPATK_DOWN = 49,        -- 特攻-1
    SPDEF_DOWN = 50,        -- 特防-1
}

-- 能力索引映射
SkillEffects.STAT_INDEX = {
    [0] = "attack",   -- 攻击
    [1] = "defence",  -- 防御
    [2] = "spAtk",    -- 特攻
    [3] = "spDef",    -- 特防
    [4] = "speed",    -- 速度
    [5] = "accuracy", -- 命中
}

-- ==================== 效果处理函数 ====================

-- 解析 SideEffectArg
function SkillEffects.parseArgs(argStr)
    if not argStr or argStr == "" then return {} end
    local args = {}
    for num in argStr:gmatch("%-?%d+") do
        table.insert(args, tonumber(num))
    end
    return args
end

-- 应用吸取效果 (SideEffect=1)
-- 吸收造成伤害的50%恢复HP
function SkillEffects.applyDrain(attacker, damage, args)
    local drainRatio = 0.5  -- 默认吸取50%
    if args[1] then drainRatio = args[1] / 100 end
    
    local healAmount = math.floor(damage * drainRatio)
    local oldHp = attacker.hp
    attacker.hp = math.min(attacker.maxHp, attacker.hp + healAmount)
    
    return {
        type = "drain",
        healAmount = attacker.hp - oldHp,
        message = string.format("吸取了 %d HP", attacker.hp - oldHp)
    }
end

-- 应用畏缩效果 (SideEffect=2)
function SkillEffects.applyFlinch(defender, args)
    defender.flinched = true
    return {
        type = "flinch",
        message = "对方畏缩了!"
    }
end

-- 清除异常状态 (SideEffect=3)
function SkillEffects.clearStatus(target, args)
    target.status = {}
    return {
        type = "clear_status",
        message = "异常状态被清除了!"
    }
end

-- 自身能力变化 (SideEffect=4)
-- SideEffectArg="stat chance stages" 例如 "2 100 -1" = 特攻100%几率-1级
function SkillEffects.applySelfStatChange(attacker, args)
    if #args < 3 then return nil end
    
    local statIndex = args[1]
    local chance = args[2]
    local stages = args[3]
    
    if math.random(100) > chance then return nil end
    
    attacker.battleLv = attacker.battleLv or {0, 0, 0, 0, 0, 0}
    local index = statIndex + 1  -- Lua索引从1开始
    local oldStage = attacker.battleLv[index] or 0
    local newStage = math.max(-6, math.min(6, oldStage + stages))
    attacker.battleLv[index] = newStage
    
    local statName = SkillEffects.STAT_INDEX[statIndex] or "能力"
    local direction = stages > 0 and "提升" or "下降"
    
    return {
        type = "self_stat_change",
        stat = statIndex,
        stages = stages,
        message = string.format("自身%s%s了%d级", statName, direction, math.abs(stages))
    }
end

-- 降低对方能力 (SideEffect=5)
-- SideEffectArg="stat chance stages" 例如 "1 15 -1" = 防御15%几率-1级
function SkillEffects.applyFoeStatChange(defender, args)
    if #args < 3 then return nil end
    
    local statIndex = args[1]
    local chance = args[2]
    local stages = args[3]
    
    if math.random(100) > chance then return nil end
    
    defender.battleLv = defender.battleLv or {0, 0, 0, 0, 0, 0}
    local index = statIndex + 1
    local oldStage = defender.battleLv[index] or 0
    local newStage = math.max(-6, math.min(6, oldStage + stages))
    defender.battleLv[index] = newStage
    
    local statName = SkillEffects.STAT_INDEX[statIndex] or "能力"
    local direction = stages > 0 and "提升" or "下降"
    
    return {
        type = "foe_stat_change",
        stat = statIndex,
        stages = stages,
        message = string.format("对方%s%s了%d级", statName, direction, math.abs(stages))
    }
end

-- 反伤效果 (SideEffect=6)
-- SideEffectArg="divisor" 例如 "4" = 受到1/4伤害
function SkillEffects.applyRecoil(attacker, damage, args)
    local divisor = args[1] or 4
    local recoilDamage = math.floor(damage / divisor)
    attacker.hp = math.max(0, attacker.hp - recoilDamage)
    
    return {
        type = "recoil",
        damage = recoilDamage,
        message = string.format("受到了 %d 点反伤", recoilDamage)
    }
end

-- 同生共死 (SideEffect=7)
function SkillEffects.applyDestinyBond(attacker, args)
    attacker.destinyBond = true
    return {
        type = "destiny_bond",
        message = "使用了同生共死!"
    }
end

-- 手下留情 (SideEffect=8)
-- 不会使对方HP降到0以下
function SkillEffects.applyFalseSwipe(defender, damage, args)
    if defender.hp - damage < 1 then
        local actualDamage = defender.hp - 1
        defender.hp = 1
        return {
            type = "false_swipe",
            adjustedDamage = actualDamage,
            message = "手下留情! 对方保留了1点HP"
        }
    end
    return nil
end

-- 愤怒 (SideEffect=9)
-- SideEffectArg="chance maxStages" 受到攻击时攻击力上升
function SkillEffects.applyRage(attacker, args)
    attacker.rageActive = true
    attacker.rageChance = args[1] or 20
    attacker.rageMaxStages = args[2] or 80
    return {
        type = "rage",
        message = "进入愤怒状态!"
    }
end

-- 麻痹 (SideEffect=10)
function SkillEffects.applyParalyze(defender, args)
    local chance = args[1] or 30
    if math.random(100) > chance then return nil end
    
    defender.status = defender.status or {}
    defender.status.paralysis = 5  -- 持续5回合
    
    return {
        type = "paralyze",
        message = "对方陷入了麻痹状态!"
    }
end

-- 束缚 (SideEffect=11)
function SkillEffects.applyTrap(defender, args)
    local chance = args[1] or 100
    if math.random(100) > chance then return nil end
    
    defender.trapped = true
    defender.trapTurns = 4 + math.random(0, 1)
    
    return {
        type = "trap",
        message = "对方被束缚住了!"
    }
end

-- 烧伤 (SideEffect=12)
function SkillEffects.applyBurn(defender, args)
    local chance = args[1] or 10
    if math.random(100) > chance then return nil end
    
    defender.status = defender.status or {}
    defender.status.burn = 5
    
    return {
        type = "burn",
        message = "对方被烧伤了!"
    }
end

-- 混乱 (SideEffect=13)
function SkillEffects.applyConfuse(defender, args)
    local chance = args[1] or 30
    if math.random(100) > chance then return nil end
    
    defender.status = defender.status or {}
    defender.status.confusion = 2 + math.random(0, 3)
    
    return {
        type = "confuse",
        message = "对方陷入了混乱!"
    }
end

-- 紧勒 (SideEffect=14)
function SkillEffects.applyBind(defender, args)
    local chance = args[1] or 100
    if math.random(100) > chance then return nil end
    
    defender.bound = true
    defender.boundTurns = 4 + math.random(0, 1)
    
    return {
        type = "bind",
        message = "对方被紧紧缠住了!"
    }
end

-- 害怕 (SideEffect=15)
function SkillEffects.applyFear(defender, args)
    local chance = args[1] or 10
    if math.random(100) > chance then return nil end
    
    defender.status = defender.status or {}
    defender.status.fear = 1
    
    return {
        type = "fear",
        message = "对方害怕了!"
    }
end

-- 中毒 (SideEffect=16)
function SkillEffects.applyPoison(defender, args)
    local chance = args[1] or 30
    if math.random(100) > chance then return nil end
    
    defender.status = defender.status or {}
    defender.status.poison = 5
    
    return {
        type = "poison",
        message = "对方中毒了!"
    }
end

-- 睡眠 (SideEffect=17)
function SkillEffects.applySleep(defender, args)
    local chance = args[1] or 30
    if math.random(100) > chance then return nil end
    
    defender.status = defender.status or {}
    defender.status.sleep = 2 + math.random(0, 2)
    
    return {
        type = "sleep",
        message = "对方睡着了!"
    }
end

-- 冰冻 (SideEffect=18)
function SkillEffects.applyFreeze(defender, args)
    local chance = args[1] or 10
    if math.random(100) > chance then return nil end
    
    defender.status = defender.status or {}
    defender.status.freeze = 3
    
    return {
        type = "freeze",
        message = "对方被冻住了!"
    }
end

-- 石化 (SideEffect=19)
function SkillEffects.applyPetrify(defender, args)
    local chance = args[1] or 10
    if math.random(100) > chance then return nil end
    
    defender.status = defender.status or {}
    defender.status.petrify = 3
    
    return {
        type = "petrify",
        message = "对方石化了!"
    }
end

-- 疲惫 (SideEffect=20)
-- SideEffectArg="chance turns" 例如 "100 1" = 100%几率疲惫1回合
function SkillEffects.applyFatigue(attacker, args)
    local chance = args[1] or 100
    local turns = args[2] or 1
    if math.random(100) > chance then return nil end
    
    attacker.fatigue = turns
    
    return {
        type = "fatigue",
        turns = turns,
        message = "感到很疲惫，需要休息!"
    }
end

-- 连续攻击 (SideEffect=31)
-- SideEffectArg="min max" 例如 "2 5" = 攻击2-5次
function SkillEffects.getMultiHitCount(args)
    local minHits = args[1] or 2
    local maxHits = args[2] or 5
    return math.random(minHits, maxHits)
end

-- 克制 (SideEffect=34)
-- 伤害=对方剩余HP的一半
function SkillEffects.calculateCounterDamage(defender, args)
    local divisor = args[1] or 2
    return math.floor(defender.hp / divisor)
end

-- 惩罚 (SideEffect=35)
-- 根据对方强化等级增加威力
function SkillEffects.calculatePunishPower(basePower, defender)
    local totalBoosts = 0
    if defender.battleLv then
        for i = 1, 6 do
            local stage = defender.battleLv[i] or 0
            if stage > 0 then
                totalBoosts = totalBoosts + stage
            end
        end
    end
    return basePower + totalBoosts * 20
end

-- 保护 (SideEffect=36)
function SkillEffects.applyProtect(attacker, args)
    attacker.protected = true
    return {
        type = "protect",
        message = "进入保护状态!"
    }
end

-- 回复HP (SideEffect=37)
-- SideEffectArg="percent" 例如 "50" = 回复50%HP
function SkillEffects.applyHeal(target, args)
    local percent = args[1] or 50
    local healAmount = math.floor(target.maxHp * percent / 100)
    local oldHp = target.hp
    target.hp = math.min(target.maxHp, target.hp + healAmount)
    
    return {
        type = "heal",
        healAmount = target.hp - oldHp,
        message = string.format("回复了 %d HP", target.hp - oldHp)
    }
end

-- ==================== 主处理函数 ====================

-- 处理技能的附加效果
-- 返回效果结果列表
function SkillEffects.processEffect(effectId, attacker, defender, damage, argStr)
    local args = SkillEffects.parseArgs(argStr)
    local results = {}
    
    -- 根据效果ID调用对应处理函数
    if effectId == 1 then
        -- 吸取
        local result = SkillEffects.applyDrain(attacker, damage, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 2 then
        -- 畏缩
        local result = SkillEffects.applyFlinch(defender, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 3 then
        -- 清除状态
        local result = SkillEffects.clearStatus(attacker, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 4 then
        -- 自身能力变化
        local result = SkillEffects.applySelfStatChange(attacker, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 5 then
        -- 降低对方能力
        local result = SkillEffects.applyFoeStatChange(defender, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 6 then
        -- 反伤
        local result = SkillEffects.applyRecoil(attacker, damage, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 7 then
        -- 同生共死
        local result = SkillEffects.applyDestinyBond(attacker, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 8 then
        -- 手下留情 (在伤害计算时处理)
        
    elseif effectId == 9 then
        -- 愤怒
        local result = SkillEffects.applyRage(attacker, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 10 then
        -- 麻痹
        local result = SkillEffects.applyParalyze(defender, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 11 then
        -- 束缚
        local result = SkillEffects.applyTrap(defender, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 12 then
        -- 烧伤
        local result = SkillEffects.applyBurn(defender, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 13 then
        -- 混乱
        local result = SkillEffects.applyConfuse(defender, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 14 then
        -- 紧勒/冰冻
        local result = SkillEffects.applyBind(defender, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 15 then
        -- 害怕
        local result = SkillEffects.applyFear(defender, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 16 then
        -- 中毒
        local result = SkillEffects.applyPoison(defender, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 17 then
        -- 睡眠
        local result = SkillEffects.applySleep(defender, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 18 then
        -- 冰冻
        local result = SkillEffects.applyFreeze(defender, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 19 then
        -- 石化
        local result = SkillEffects.applyPetrify(defender, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 20 then
        -- 疲惫
        local result = SkillEffects.applyFatigue(attacker, args)
        if result then table.insert(results, result) end
        
    elseif effectId == 21 then
        -- 提升自身攻击 (SideEffectArg="chance stages")
        local chance = args[1] or 100
        local stages = args[2] or 1
        if math.random(100) <= chance then
            local result = SkillEffects.applySelfStatChange(attacker, {0, 100, stages})
            if result then table.insert(results, result) end
        end
        
    elseif effectId == 22 then
        -- 虚弱效果 (SideEffectArg="chance turns")
        local chance = args[1] or 30
        local turns = args[2] or 1
        if math.random(100) <= chance then
            defender.weakness = turns
            table.insert(results, {type = "weakness", turns = turns, message = "对方感到虚弱!"})
        end
        
    elseif effectId == 28 then
        -- 提升自身速度
        local chance = args[1] or 100
        local stages = args[2] or 1
        if math.random(100) <= chance then
            local result = SkillEffects.applySelfStatChange(attacker, {4, 100, stages})
            if result then table.insert(results, result) end
        end
        
    elseif effectId == 29 then
        -- 畏缩 (带几率)
        local chance = args[1] or 30
        if math.random(100) <= chance then
            local result = SkillEffects.applyFlinch(defender, args)
            if result then table.insert(results, result) end
        end
        
    elseif effectId == 30 then
        -- 提升自身防御
        local chance = args[1] or 100
        local stages = args[2] or 1
        if math.random(100) <= chance then
            local result = SkillEffects.applySelfStatChange(attacker, {1, 100, stages})
            if result then table.insert(results, result) end
        end
        
    elseif effectId == 31 then
        -- 连续攻击 (在伤害计算时处理)
        
    elseif effectId == 32 then
        -- 固定伤害 (在伤害计算时处理)
        
    elseif effectId == 33 then
        -- 降低对方速度
        local chance = args[1] or 100
        local stages = args[2] or -1
        if math.random(100) <= chance then
            local result = SkillEffects.applyFoeStatChange(defender, {4, 100, stages})
            if result then table.insert(results, result) end
        end
        
    elseif effectId == 34 then
        -- 克制 (在伤害计算时处理)
        
    elseif effectId == 35 then
        -- 惩罚 (在伤害计算时处理)
        
    elseif effectId == 36 then
        -- 一击必杀 (SideEffectArg="chance")
        local chance = args[1] or 30
        if math.random(100) <= chance then
            defender.hp = 0
            table.insert(results, {type = "ohko", message = "一击必杀!"})
        end
        
    elseif effectId == 37 then
        -- 回复HP (SideEffectArg="percent divisor" 或 "divisor percent")
        local divisor = args[1] or 2
        local percent = args[2] or 50
        local healAmount = math.floor(damage / divisor)
        local oldHp = attacker.hp
        attacker.hp = math.min(attacker.maxHp, attacker.hp + healAmount)
        table.insert(results, {type = "heal", healAmount = attacker.hp - oldHp, message = string.format("回复了 %d HP", attacker.hp - oldHp)})
        
    elseif effectId == 38 then
        -- 虚弱效果
        local chance = args[1] or 30
        if math.random(100) <= chance then
            defender.weakness = 2
            table.insert(results, {type = "weakness", message = "对方感到虚弱!"})
        end
        
    elseif effectId == 39 then
        -- 不适效果 (SideEffectArg="chance turns")
        local chance = args[1] or 30
        local turns = args[2] or 1
        if math.random(100) <= chance then
            defender.discomfort = turns
            table.insert(results, {type = "discomfort", turns = turns, message = "对方感到不适!"})
        end
        
    elseif effectId == 40 then
        -- 追击效果 (对方换宠时伤害翻倍)
        attacker.pursuit = true
        table.insert(results, {type = "pursuit", message = "准备追击!"})
        
    elseif effectId == 54 then
        -- 降低对方双防 (SideEffectArg="def_stages spdef_stages")
        local defStages = args[1] or -1
        local spdefStages = args[2] or -1
        local result1 = SkillEffects.applyFoeStatChange(defender, {1, 100, defStages})
        local result2 = SkillEffects.applyFoeStatChange(defender, {3, 100, spdefStages})
        if result1 then table.insert(results, result1) end
        if result2 then table.insert(results, result2) end
    end
    
    return results
end

-- 检查是否为特殊伤害计算技能
function SkillEffects.isSpecialDamageSkill(effectId)
    return effectId == 8 or effectId == 31 or effectId == 34 or effectId == 35
end

-- 获取特殊伤害
function SkillEffects.getSpecialDamage(effectId, basePower, attacker, defender, argStr)
    local args = SkillEffects.parseArgs(argStr)
    
    if effectId == 34 then
        -- 克制: 伤害=对方剩余HP的一半
        return SkillEffects.calculateCounterDamage(defender, args)
    elseif effectId == 35 then
        -- 惩罚: 根据对方强化等级增加威力
        return SkillEffects.calculatePunishPower(basePower, defender)
    end
    
    return nil
end

return SkillEffects
