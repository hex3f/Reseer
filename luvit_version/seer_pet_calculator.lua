-- 精灵属性计算模块
-- 用于计算精灵的各项属性值

local SeerPets = require('./seer_pets')

local PetCalculator = {}

-- 计算精灵的 HP
-- 公式: HP = floor((种族值 * 2 + 个体值 + 努力值 / 4) * 等级 / 100) + 等级 + 10
function PetCalculator.calculateHP(petId, level, dv, ev_hp)
    local baseStats = SeerPets.get(petId)
    if not baseStats then
        return 100 -- 默认值
    end
    
    local raceValue = baseStats.hp or 50
    dv = dv or 31
    ev_hp = ev_hp or 0
    
    local hp = math.floor((raceValue * 2 + dv + ev_hp / 4) * level / 100) + level + 10
    return hp
end

-- 计算精灵的其他属性（攻击、防御、特攻、特防、速度）
-- 公式: 属性 = floor((种族值 * 2 + 个体值 + 努力值 / 4) * 等级 / 100) + 5
function PetCalculator.calculateStat(petId, statName, level, dv, ev)
    local baseStats = SeerPets.get(petId)
    if not baseStats then
        return 50 -- 默认值
    end
    
    -- 统一属性名称映射
    local statMap = {
        attack = 'atk',
        defence = 'def',
        s_a = 'spAtk',
        s_d = 'spDef',
        speed = 'spd'
    }
    
    local actualStatName = statMap[statName] or statName
    local raceValue = baseStats[actualStatName] or 50
    dv = dv or 31
    ev = ev or 0
    
    local stat = math.floor((raceValue * 2 + dv + ev / 4) * level / 100) + 5
    return stat
end

-- 计算精灵的当前等级经验值
function PetCalculator.calculateLevelExp(petId, level, exp)
    -- 简化实现：使用固定的经验曲线
    -- 等级 N 所需总经验 = N^3
    local totalExpForLevel = level * level * level
    local totalExpForNextLevel = (level + 1) * (level + 1) * (level + 1)
    
    -- 当前等级已获得的经验
    local lvExp = exp - totalExpForLevel
    if lvExp < 0 then lvExp = 0 end
    
    -- 升级所需经验
    local nextLvExp = totalExpForNextLevel - totalExpForLevel
    
    return lvExp, nextLvExp
end

-- 计算精灵的所有属性
function PetCalculator.calculateAllStats(pet)
    local petId = pet.id or 0
    local level = pet.level or 1
    local dv = pet.dv or 31
    local nature = pet.nature or 0
    local exp = pet.exp or 0
    
    -- 努力值（默认为0）
    local ev_hp = pet.ev_hp or 0
    local ev_attack = pet.ev_attack or 0
    local ev_defence = pet.ev_defence or 0
    local ev_sa = pet.ev_sa or 0
    local ev_sd = pet.ev_sd or 0
    local ev_sp = pet.ev_sp or 0
    
    -- 计算各项属性
    local maxHp = PetCalculator.calculateHP(petId, level, dv, ev_hp)
    local attack = PetCalculator.calculateStat(petId, 'attack', level, dv, ev_attack)
    local defence = PetCalculator.calculateStat(petId, 'defence', level, dv, ev_defence)
    local s_a = PetCalculator.calculateStat(petId, 's_a', level, dv, ev_sa)
    local s_d = PetCalculator.calculateStat(petId, 's_d', level, dv, ev_sd)
    local speed = PetCalculator.calculateStat(petId, 'speed', level, dv, ev_sp)
    
    -- 当前 HP（默认为满血）
    local hp = pet.hp or maxHp
    if hp > maxHp then hp = maxHp end
    
    -- 计算经验值
    local lvExp, nextLvExp = PetCalculator.calculateLevelExp(petId, level, exp)
    
    return {
        hp = hp,
        maxHp = maxHp,
        attack = attack,
        defence = defence,
        s_a = s_a,
        s_d = s_d,
        speed = speed,
        lvExp = lvExp,
        nextLvExp = nextLvExp
    }
end

return PetCalculator
