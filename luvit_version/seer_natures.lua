-- 赛尔号性格系统
-- 26种性格，影响精灵属性成长

local Natures = {}

-- 属性索引
local STAT = {
    ATK = 1,    -- 攻击
    DEF = 2,    -- 防御
    SPA = 3,    -- 特攻
    SPD = 4,    -- 特防
    SPE = 5,    -- 速度
}

Natures.STAT = STAT

-- 性格定义: {id, 名称, 增益属性, 减益属性}
-- 增益+10%, 减益-10%, nil表示无变化
Natures.DATA = {
    -- ==================== 攻击强化类 (1-4) ====================
    [1]  = {name = "孤独", up = STAT.ATK, down = STAT.DEF},
    [2]  = {name = "勇敢", up = STAT.ATK, down = STAT.SPE},
    [3]  = {name = "固执", up = STAT.ATK, down = STAT.SPA},
    [4]  = {name = "调皮", up = STAT.ATK, down = STAT.SPD},
    
    -- ==================== 速度强化类 (5-8) ====================
    [5]  = {name = "胆小", up = STAT.SPE, down = STAT.ATK},
    [6]  = {name = "急躁", up = STAT.SPE, down = STAT.DEF},
    [7]  = {name = "开朗", up = STAT.SPE, down = STAT.SPA},
    [8]  = {name = "天真", up = STAT.SPE, down = STAT.SPD},
    
    -- ==================== 防御强化类 (9-12) ====================
    [9]  = {name = "大胆", up = STAT.DEF, down = STAT.ATK},
    [10] = {name = "悠闲", up = STAT.DEF, down = STAT.SPE},
    [11] = {name = "顽皮", up = STAT.DEF, down = STAT.SPA},
    [12] = {name = "无虑", up = STAT.DEF, down = STAT.SPD},
    
    -- ==================== 特攻强化类 (13-16) ====================
    [13] = {name = "保守", up = STAT.SPA, down = STAT.ATK},
    [14] = {name = "稳重", up = STAT.SPA, down = STAT.DEF},
    [15] = {name = "冷静", up = STAT.SPA, down = STAT.SPE},
    [16] = {name = "马虎", up = STAT.SPA, down = STAT.SPD},
    
    -- ==================== 特防强化类 (17-20) ====================
    [17] = {name = "沉着", up = STAT.SPD, down = STAT.ATK},
    [18] = {name = "温顺", up = STAT.SPD, down = STAT.DEF},
    [19] = {name = "狂妄", up = STAT.SPD, down = STAT.SPE},
    [20] = {name = "慎重", up = STAT.SPD, down = STAT.SPA},
    
    -- ==================== 平衡型 (21-25) ====================
    [21] = {name = "害羞", up = nil, down = nil},
    [22] = {name = "浮躁", up = nil, down = nil},
    [23] = {name = "坦率", up = nil, down = nil},
    [24] = {name = "实干", up = nil, down = nil},
    [25] = {name = "认真", up = nil, down = nil},
    
    -- 额外一个（凑26种）
    [26] = {name = "随和", up = nil, down = nil},
}

-- 属性名称
local STAT_NAMES = {
    [STAT.ATK] = "攻击",
    [STAT.DEF] = "防御",
    [STAT.SPA] = "特攻",
    [STAT.SPD] = "特防",
    [STAT.SPE] = "速度",
}

Natures.STAT_NAMES = STAT_NAMES

-- ==================== 核心函数 ====================

-- 获取性格名称
function Natures.getName(natureId)
    local nature = Natures.DATA[natureId]
    return nature and nature.name or "未知"
end

-- 获取性格对某属性的修正倍率
-- 返回: 1.1 (增益), 0.9 (减益), 1.0 (无变化)
function Natures.getStatModifier(natureId, statType)
    local nature = Natures.DATA[natureId]
    if not nature then return 1.0 end
    
    if nature.up == statType then
        return 1.1  -- +10%
    elseif nature.down == statType then
        return 0.9  -- -10%
    else
        return 1.0  -- 无变化
    end
end

-- 获取性格的所有修正
-- 返回: {atk=1.0, def=1.0, spa=1.0, spd=1.0, spe=1.0}
function Natures.getAllModifiers(natureId)
    return {
        atk = Natures.getStatModifier(natureId, STAT.ATK),
        def = Natures.getStatModifier(natureId, STAT.DEF),
        spa = Natures.getStatModifier(natureId, STAT.SPA),
        spd = Natures.getStatModifier(natureId, STAT.SPD),
        spe = Natures.getStatModifier(natureId, STAT.SPE),
    }
end

-- 应用性格修正到属性值
function Natures.applyToStats(natureId, stats)
    local mods = Natures.getAllModifiers(natureId)
    return {
        hp = stats.hp,  -- 体力不受性格影响
        atk = math.floor(stats.atk * mods.atk),
        def = math.floor(stats.def * mods.def),
        spa = math.floor(stats.spa * mods.spa),
        spd = math.floor(stats.spd * mods.spd),
        spe = math.floor(stats.spe * mods.spe),
    }
end

-- 获取性格描述
function Natures.getDescription(natureId)
    local nature = Natures.DATA[natureId]
    if not nature then return "未知性格" end
    
    if nature.up and nature.down then
        return string.format("%s: %s+10%%, %s-10%%",
            nature.name,
            STAT_NAMES[nature.up],
            STAT_NAMES[nature.down])
    else
        return string.format("%s: 平衡型（无属性变化）", nature.name)
    end
end

-- 随机获取一个性格ID
function Natures.random()
    return math.random(1, 26)
end

-- 根据名称获取性格ID
function Natures.getIdByName(name)
    for id, data in pairs(Natures.DATA) do
        if data.name == name then
            return id
        end
    end
    return nil
end

-- 获取推荐性格（根据精灵定位）
-- role: "physical"(物攻), "special"(特攻), "tank"(肉盾), "speed"(速度)
function Natures.getRecommended(role)
    local recommendations = {
        physical = {3, 1, 2, 4},      -- 固执、孤独、勇敢、调皮
        special = {15, 13, 14, 16},   -- 冷静、保守、稳重、马虎
        tank_def = {10, 9, 11, 12},   -- 悠闲、大胆、顽皮、无虑
        tank_spd = {19, 17, 18, 20},  -- 狂妄、沉着、温顺、慎重
        speed = {5, 6, 7, 8},         -- 胆小、急躁、开朗、天真
    }
    return recommendations[role] or {21, 22, 23, 24, 25}  -- 默认平衡型
end

-- ==================== 调试函数 ====================

-- 打印所有性格
function Natures.printAll()
    print("========== 赛尔号性格系统 ==========")
    for id = 1, 26 do
        print(string.format("[%2d] %s", id, Natures.getDescription(id)))
    end
    print("====================================")
end

-- 测试性格修正
function Natures.test(natureId)
    local testStats = {hp = 100, atk = 100, def = 100, spa = 100, spd = 100, spe = 100}
    local result = Natures.applyToStats(natureId, testStats)
    print(string.format("[性格测试] %s", Natures.getDescription(natureId)))
    print(string.format("  基础: HP=%d ATK=%d DEF=%d SPA=%d SPD=%d SPE=%d",
        testStats.hp, testStats.atk, testStats.def, testStats.spa, testStats.spd, testStats.spe))
    print(string.format("  修正: HP=%d ATK=%d DEF=%d SPA=%d SPD=%d SPE=%d",
        result.hp, result.atk, result.def, result.spa, result.spd, result.spe))
end

return Natures
