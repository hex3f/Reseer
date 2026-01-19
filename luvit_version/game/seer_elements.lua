-- 赛尔号属性相克系统
-- 包含所有属性的克制关系和伤害倍率计算

local Elements = {}

-- ==================== 属性ID定义 ====================
Elements.TYPE = {
    GRASS = 1,      -- 草
    WATER = 2,      -- 水
    FIRE = 3,       -- 火
    FLYING = 4,     -- 飞行
    ELECTRIC = 5,   -- 电
    MACHINE = 6,    -- 机械
    GROUND = 7,     -- 地面
    NORMAL = 8,     -- 普通
    ICE = 9,        -- 冰
    PSYCHIC = 10,   -- 超能
    FIGHTING = 11,  -- 战斗
    LIGHT = 12,     -- 光
    DARK = 13,      -- 暗影
    MYSTERY = 14,   -- 神秘
    DRAGON = 15,    -- 龙
    HOLY = 16,      -- 圣灵
    DIMENSION = 17, -- 次元
    ANCIENT = 18,   -- 远古
    EVIL = 19,      -- 邪灵
    NATURE = 20,    -- 自然
    KING = 21,      -- 王
    CHAOS = 22,     -- 混沌
    DIVINE = 23,    -- 神灵
    CYCLE = 24,     -- 轮回
    BUG = 25,       -- 虫
    VOID = 26,      -- 虚空
}

-- 属性名称映射
Elements.NAME = {
    [1] = "草", [2] = "水", [3] = "火", [4] = "飞行", [5] = "电",
    [6] = "机械", [7] = "地面", [8] = "普通", [9] = "冰", [10] = "超能",
    [11] = "战斗", [12] = "光", [13] = "暗影", [14] = "神秘", [15] = "龙",
    [16] = "圣灵", [17] = "次元", [18] = "远古", [19] = "邪灵", [20] = "自然",
    [21] = "王", [22] = "混沌", [23] = "神灵", [24] = "轮回", [25] = "虫",
    [26] = "虚空",
}

-- ==================== 属性相克表 ====================
-- 格式: EFFECTIVENESS[攻击属性][防御属性] = 倍率
-- 2 = 克制, 1 = 普通, 0.5 = 微弱, 0 = 无效

local E = Elements.TYPE
Elements.EFFECTIVENESS = {}

-- 初始化所有为1（普通效果）
for i = 1, 26 do
    Elements.EFFECTIVENESS[i] = {}
    for j = 1, 26 do
        Elements.EFFECTIVENESS[i][j] = 1
    end
end

-- 草系
Elements.EFFECTIVENESS[E.GRASS][E.WATER] = 2
Elements.EFFECTIVENESS[E.GRASS][E.GROUND] = 2
Elements.EFFECTIVENESS[E.GRASS][E.LIGHT] = 2
Elements.EFFECTIVENESS[E.GRASS][E.GRASS] = 0.5
Elements.EFFECTIVENESS[E.GRASS][E.FIRE] = 0.5
Elements.EFFECTIVENESS[E.GRASS][E.FLYING] = 0.5
Elements.EFFECTIVENESS[E.GRASS][E.MACHINE] = 0.5
Elements.EFFECTIVENESS[E.GRASS][E.HOLY] = 0.5
Elements.EFFECTIVENESS[E.GRASS][E.ANCIENT] = 0.5
Elements.EFFECTIVENESS[E.GRASS][E.CHAOS] = 0.5
Elements.EFFECTIVENESS[E.GRASS][E.DIVINE] = 0.5

-- 水系
Elements.EFFECTIVENESS[E.WATER][E.FIRE] = 2
Elements.EFFECTIVENESS[E.WATER][E.GROUND] = 2
Elements.EFFECTIVENESS[E.WATER][E.GRASS] = 0.5
Elements.EFFECTIVENESS[E.WATER][E.WATER] = 0.5
Elements.EFFECTIVENESS[E.WATER][E.HOLY] = 0.5
Elements.EFFECTIVENESS[E.WATER][E.NATURE] = 0.5
Elements.EFFECTIVENESS[E.WATER][E.CHAOS] = 0.5
Elements.EFFECTIVENESS[E.WATER][E.DIVINE] = 0.5

-- 火系
Elements.EFFECTIVENESS[E.FIRE][E.GRASS] = 2
Elements.EFFECTIVENESS[E.FIRE][E.MACHINE] = 2
Elements.EFFECTIVENESS[E.FIRE][E.ICE] = 2
Elements.EFFECTIVENESS[E.FIRE][E.WATER] = 0.5
Elements.EFFECTIVENESS[E.FIRE][E.FIRE] = 0.5
Elements.EFFECTIVENESS[E.FIRE][E.HOLY] = 0.5
Elements.EFFECTIVENESS[E.FIRE][E.NATURE] = 0.5
Elements.EFFECTIVENESS[E.FIRE][E.CHAOS] = 0.5
Elements.EFFECTIVENESS[E.FIRE][E.DIVINE] = 0.5

-- 飞行系
Elements.EFFECTIVENESS[E.FLYING][E.GRASS] = 2
Elements.EFFECTIVENESS[E.FLYING][E.FIGHTING] = 2
Elements.EFFECTIVENESS[E.FLYING][E.BUG] = 2
Elements.EFFECTIVENESS[E.FLYING][E.ELECTRIC] = 0.5
Elements.EFFECTIVENESS[E.FLYING][E.MACHINE] = 0.5
Elements.EFFECTIVENESS[E.FLYING][E.DIMENSION] = 0.5
Elements.EFFECTIVENESS[E.FLYING][E.EVIL] = 0.5
Elements.EFFECTIVENESS[E.FLYING][E.NATURE] = 0.5
Elements.EFFECTIVENESS[E.FLYING][E.CHAOS] = 0.5

-- 电系
Elements.EFFECTIVENESS[E.ELECTRIC][E.WATER] = 2
Elements.EFFECTIVENESS[E.ELECTRIC][E.FLYING] = 2
Elements.EFFECTIVENESS[E.ELECTRIC][E.DARK] = 2
Elements.EFFECTIVENESS[E.ELECTRIC][E.DIMENSION] = 2
Elements.EFFECTIVENESS[E.ELECTRIC][E.CHAOS] = 2
Elements.EFFECTIVENESS[E.ELECTRIC][E.VOID] = 2
Elements.EFFECTIVENESS[E.ELECTRIC][E.GRASS] = 0.5
Elements.EFFECTIVENESS[E.ELECTRIC][E.ELECTRIC] = 0.5
Elements.EFFECTIVENESS[E.ELECTRIC][E.MYSTERY] = 0.5
Elements.EFFECTIVENESS[E.ELECTRIC][E.HOLY] = 0.5
Elements.EFFECTIVENESS[E.ELECTRIC][E.NATURE] = 0.5
Elements.EFFECTIVENESS[E.ELECTRIC][E.DIVINE] = 0.5
Elements.EFFECTIVENESS[E.ELECTRIC][E.GROUND] = 0

-- 机械系
Elements.EFFECTIVENESS[E.MACHINE][E.ICE] = 2
Elements.EFFECTIVENESS[E.MACHINE][E.FIGHTING] = 2
Elements.EFFECTIVENESS[E.MACHINE][E.ANCIENT] = 2
Elements.EFFECTIVENESS[E.MACHINE][E.EVIL] = 2
Elements.EFFECTIVENESS[E.MACHINE][E.DIVINE] = 2
Elements.EFFECTIVENESS[E.MACHINE][E.WATER] = 0.5
Elements.EFFECTIVENESS[E.MACHINE][E.FIRE] = 0.5
Elements.EFFECTIVENESS[E.MACHINE][E.ELECTRIC] = 0.5
Elements.EFFECTIVENESS[E.MACHINE][E.MACHINE] = 0.5
Elements.EFFECTIVENESS[E.MACHINE][E.DIMENSION] = 0.5

-- 地面系
Elements.EFFECTIVENESS[E.GROUND][E.FIRE] = 2
Elements.EFFECTIVENESS[E.GROUND][E.ELECTRIC] = 2
Elements.EFFECTIVENESS[E.GROUND][E.MACHINE] = 2
Elements.EFFECTIVENESS[E.GROUND][E.KING] = 2
Elements.EFFECTIVENESS[E.GROUND][E.CYCLE] = 2
Elements.EFFECTIVENESS[E.GROUND][E.GRASS] = 0.5
Elements.EFFECTIVENESS[E.GROUND][E.PSYCHIC] = 0.5
Elements.EFFECTIVENESS[E.GROUND][E.DARK] = 0.5
Elements.EFFECTIVENESS[E.GROUND][E.DRAGON] = 0.5
Elements.EFFECTIVENESS[E.GROUND][E.HOLY] = 0.5
Elements.EFFECTIVENESS[E.GROUND][E.NATURE] = 0.5
Elements.EFFECTIVENESS[E.GROUND][E.DIVINE] = 0.5
Elements.EFFECTIVENESS[E.GROUND][E.BUG] = 0.5
Elements.EFFECTIVENESS[E.GROUND][E.FLYING] = 0

-- 普通系 - 全部为1，已初始化

-- 冰系
Elements.EFFECTIVENESS[E.ICE][E.GRASS] = 2
Elements.EFFECTIVENESS[E.ICE][E.FLYING] = 2
Elements.EFFECTIVENESS[E.ICE][E.GROUND] = 2
Elements.EFFECTIVENESS[E.ICE][E.DIMENSION] = 2
Elements.EFFECTIVENESS[E.ICE][E.ANCIENT] = 2
Elements.EFFECTIVENESS[E.ICE][E.CYCLE] = 2
Elements.EFFECTIVENESS[E.ICE][E.BUG] = 2
Elements.EFFECTIVENESS[E.ICE][E.WATER] = 0.5
Elements.EFFECTIVENESS[E.ICE][E.FIRE] = 0.5
Elements.EFFECTIVENESS[E.ICE][E.MACHINE] = 0.5
Elements.EFFECTIVENESS[E.ICE][E.ICE] = 0.5
Elements.EFFECTIVENESS[E.ICE][E.HOLY] = 0.5
Elements.EFFECTIVENESS[E.ICE][E.CHAOS] = 0.5
Elements.EFFECTIVENESS[E.ICE][E.DIVINE] = 0.5

-- 超能系
Elements.EFFECTIVENESS[E.PSYCHIC][E.FIGHTING] = 2
Elements.EFFECTIVENESS[E.PSYCHIC][E.MYSTERY] = 2
Elements.EFFECTIVENESS[E.PSYCHIC][E.NATURE] = 2
Elements.EFFECTIVENESS[E.PSYCHIC][E.MACHINE] = 0.5
Elements.EFFECTIVENESS[E.PSYCHIC][E.PSYCHIC] = 0.5
Elements.EFFECTIVENESS[E.PSYCHIC][E.BUG] = 0.5
Elements.EFFECTIVENESS[E.PSYCHIC][E.LIGHT] = 0

-- 战斗系
Elements.EFFECTIVENESS[E.FIGHTING][E.MACHINE] = 2
Elements.EFFECTIVENESS[E.FIGHTING][E.ICE] = 2
Elements.EFFECTIVENESS[E.FIGHTING][E.DRAGON] = 2
Elements.EFFECTIVENESS[E.FIGHTING][E.HOLY] = 2
Elements.EFFECTIVENESS[E.FIGHTING][E.PSYCHIC] = 0.5
Elements.EFFECTIVENESS[E.FIGHTING][E.FIGHTING] = 0.5
Elements.EFFECTIVENESS[E.FIGHTING][E.DARK] = 0.5
Elements.EFFECTIVENESS[E.FIGHTING][E.EVIL] = 0.5
Elements.EFFECTIVENESS[E.FIGHTING][E.KING] = 0.5

-- 光系
Elements.EFFECTIVENESS[E.LIGHT][E.PSYCHIC] = 2
Elements.EFFECTIVENESS[E.LIGHT][E.DARK] = 2
Elements.EFFECTIVENESS[E.LIGHT][E.BUG] = 2
Elements.EFFECTIVENESS[E.LIGHT][E.MACHINE] = 0.5
Elements.EFFECTIVENESS[E.LIGHT][E.ICE] = 0.5
Elements.EFFECTIVENESS[E.LIGHT][E.LIGHT] = 0.5
Elements.EFFECTIVENESS[E.LIGHT][E.HOLY] = 0.5
Elements.EFFECTIVENESS[E.LIGHT][E.EVIL] = 0.5
Elements.EFFECTIVENESS[E.LIGHT][E.NATURE] = 0.5
Elements.EFFECTIVENESS[E.LIGHT][E.DIVINE] = 0.5
Elements.EFFECTIVENESS[E.LIGHT][E.CYCLE] = 0.5
Elements.EFFECTIVENESS[E.LIGHT][E.VOID] = 0.5
Elements.EFFECTIVENESS[E.LIGHT][E.GRASS] = 0

-- 暗影系
Elements.EFFECTIVENESS[E.DARK][E.PSYCHIC] = 2
Elements.EFFECTIVENESS[E.DARK][E.DARK] = 2
Elements.EFFECTIVENESS[E.DARK][E.DIMENSION] = 2
Elements.EFFECTIVENESS[E.DARK][E.MACHINE] = 0.5
Elements.EFFECTIVENESS[E.DARK][E.ICE] = 0.5
Elements.EFFECTIVENESS[E.DARK][E.LIGHT] = 0.5
Elements.EFFECTIVENESS[E.DARK][E.HOLY] = 0.5
Elements.EFFECTIVENESS[E.DARK][E.EVIL] = 0.5
Elements.EFFECTIVENESS[E.DARK][E.DIVINE] = 0.5

-- 神秘系
Elements.EFFECTIVENESS[E.MYSTERY][E.ELECTRIC] = 2
Elements.EFFECTIVENESS[E.MYSTERY][E.MYSTERY] = 2
Elements.EFFECTIVENESS[E.MYSTERY][E.HOLY] = 2
Elements.EFFECTIVENESS[E.MYSTERY][E.NATURE] = 2
Elements.EFFECTIVENESS[E.MYSTERY][E.KING] = 2
Elements.EFFECTIVENESS[E.MYSTERY][E.DIVINE] = 2
Elements.EFFECTIVENESS[E.MYSTERY][E.CYCLE] = 2
Elements.EFFECTIVENESS[E.MYSTERY][E.GROUND] = 0.5
Elements.EFFECTIVENESS[E.MYSTERY][E.FIGHTING] = 0.5
Elements.EFFECTIVENESS[E.MYSTERY][E.EVIL] = 0.5
Elements.EFFECTIVENESS[E.MYSTERY][E.CHAOS] = 0.5
Elements.EFFECTIVENESS[E.MYSTERY][E.BUG] = 0.5

-- 龙系
Elements.EFFECTIVENESS[E.DRAGON][E.ICE] = 2
Elements.EFFECTIVENESS[E.DRAGON][E.DRAGON] = 2
Elements.EFFECTIVENESS[E.DRAGON][E.HOLY] = 2
Elements.EFFECTIVENESS[E.DRAGON][E.EVIL] = 2
Elements.EFFECTIVENESS[E.DRAGON][E.GRASS] = 0.5
Elements.EFFECTIVENESS[E.DRAGON][E.WATER] = 0.5
Elements.EFFECTIVENESS[E.DRAGON][E.FIRE] = 0.5
Elements.EFFECTIVENESS[E.DRAGON][E.ELECTRIC] = 0.5
Elements.EFFECTIVENESS[E.DRAGON][E.ANCIENT] = 0.5
Elements.EFFECTIVENESS[E.DRAGON][E.BUG] = 0.5

-- 圣灵系
Elements.EFFECTIVENESS[E.HOLY][E.GRASS] = 2
Elements.EFFECTIVENESS[E.HOLY][E.WATER] = 2
Elements.EFFECTIVENESS[E.HOLY][E.FIRE] = 2
Elements.EFFECTIVENESS[E.HOLY][E.ELECTRIC] = 2
Elements.EFFECTIVENESS[E.HOLY][E.ICE] = 2
Elements.EFFECTIVENESS[E.HOLY][E.ANCIENT] = 2
Elements.EFFECTIVENESS[E.HOLY][E.VOID] = 2
Elements.EFFECTIVENESS[E.HOLY][E.FIGHTING] = 0.5
Elements.EFFECTIVENESS[E.HOLY][E.MYSTERY] = 0.5
Elements.EFFECTIVENESS[E.HOLY][E.DRAGON] = 0.5
Elements.EFFECTIVENESS[E.HOLY][E.CYCLE] = 0.5

-- 次元系
Elements.EFFECTIVENESS[E.DIMENSION][E.FLYING] = 2
Elements.EFFECTIVENESS[E.DIMENSION][E.MACHINE] = 2
Elements.EFFECTIVENESS[E.DIMENSION][E.PSYCHIC] = 2
Elements.EFFECTIVENESS[E.DIMENSION][E.EVIL] = 2
Elements.EFFECTIVENESS[E.DIMENSION][E.NATURE] = 2
Elements.EFFECTIVENESS[E.DIMENSION][E.BUG] = 2
Elements.EFFECTIVENESS[E.DIMENSION][E.VOID] = 2
Elements.EFFECTIVENESS[E.DIMENSION][E.ICE] = 0.5
Elements.EFFECTIVENESS[E.DIMENSION][E.KING] = 0.5
Elements.EFFECTIVENESS[E.DIMENSION][E.CHAOS] = 0.5
Elements.EFFECTIVENESS[E.DIMENSION][E.DIVINE] = 0.5
Elements.EFFECTIVENESS[E.DIMENSION][E.CYCLE] = 0.5
Elements.EFFECTIVENESS[E.DIMENSION][E.DARK] = 0

-- 远古系
Elements.EFFECTIVENESS[E.ANCIENT][E.GRASS] = 2
Elements.EFFECTIVENESS[E.ANCIENT][E.FLYING] = 2
Elements.EFFECTIVENESS[E.ANCIENT][E.MYSTERY] = 2
Elements.EFFECTIVENESS[E.ANCIENT][E.DRAGON] = 2
Elements.EFFECTIVENESS[E.ANCIENT][E.VOID] = 2
Elements.EFFECTIVENESS[E.ANCIENT][E.MACHINE] = 0.5
Elements.EFFECTIVENESS[E.ANCIENT][E.ICE] = 0.5
Elements.EFFECTIVENESS[E.ANCIENT][E.KING] = 0.5
Elements.EFFECTIVENESS[E.ANCIENT][E.CYCLE] = 0.5

-- 邪灵系
Elements.EFFECTIVENESS[E.EVIL][E.LIGHT] = 2
Elements.EFFECTIVENESS[E.EVIL][E.DARK] = 2
Elements.EFFECTIVENESS[E.EVIL][E.MYSTERY] = 2
Elements.EFFECTIVENESS[E.EVIL][E.DIMENSION] = 2
Elements.EFFECTIVENESS[E.EVIL][E.NATURE] = 2
Elements.EFFECTIVENESS[E.EVIL][E.MACHINE] = 0.5
Elements.EFFECTIVENESS[E.EVIL][E.ICE] = 0.5
Elements.EFFECTIVENESS[E.EVIL][E.PSYCHIC] = 0.5
Elements.EFFECTIVENESS[E.EVIL][E.HOLY] = 0.5
Elements.EFFECTIVENESS[E.EVIL][E.KING] = 0.5
Elements.EFFECTIVENESS[E.EVIL][E.CHAOS] = 0.5
Elements.EFFECTIVENESS[E.EVIL][E.CYCLE] = 0.5
Elements.EFFECTIVENESS[E.EVIL][E.DIVINE] = 0

-- 自然系
Elements.EFFECTIVENESS[E.NATURE][E.GRASS] = 2
Elements.EFFECTIVENESS[E.NATURE][E.WATER] = 2
Elements.EFFECTIVENESS[E.NATURE][E.FIRE] = 2
Elements.EFFECTIVENESS[E.NATURE][E.FLYING] = 2
Elements.EFFECTIVENESS[E.NATURE][E.ELECTRIC] = 2
Elements.EFFECTIVENESS[E.NATURE][E.GROUND] = 2
Elements.EFFECTIVENESS[E.NATURE][E.LIGHT] = 2
Elements.EFFECTIVENESS[E.NATURE][E.KING] = 2
Elements.EFFECTIVENESS[E.NATURE][E.CYCLE] = 2
Elements.EFFECTIVENESS[E.NATURE][E.MACHINE] = 0.5
Elements.EFFECTIVENESS[E.NATURE][E.PSYCHIC] = 0.5
Elements.EFFECTIVENESS[E.NATURE][E.FIGHTING] = 0.5
Elements.EFFECTIVENESS[E.NATURE][E.DARK] = 0.5
Elements.EFFECTIVENESS[E.NATURE][E.MYSTERY] = 0.5
Elements.EFFECTIVENESS[E.NATURE][E.DIMENSION] = 0.5
Elements.EFFECTIVENESS[E.NATURE][E.EVIL] = 0.5
Elements.EFFECTIVENESS[E.NATURE][E.CHAOS] = 0.5
Elements.EFFECTIVENESS[E.NATURE][E.VOID] = 0.5

-- 王系
Elements.EFFECTIVENESS[E.KING][E.FIGHTING] = 2
Elements.EFFECTIVENESS[E.KING][E.DARK] = 2
Elements.EFFECTIVENESS[E.KING][E.DIMENSION] = 2
Elements.EFFECTIVENESS[E.KING][E.EVIL] = 2
Elements.EFFECTIVENESS[E.KING][E.PSYCHIC] = 0.5
Elements.EFFECTIVENESS[E.KING][E.NATURE] = 0.5
Elements.EFFECTIVENESS[E.KING][E.BUG] = 0.5

-- 混沌系
Elements.EFFECTIVENESS[E.CHAOS][E.FLYING] = 2
Elements.EFFECTIVENESS[E.CHAOS][E.ICE] = 2
Elements.EFFECTIVENESS[E.CHAOS][E.MYSTERY] = 2
Elements.EFFECTIVENESS[E.CHAOS][E.DIMENSION] = 2
Elements.EFFECTIVENESS[E.CHAOS][E.EVIL] = 2
Elements.EFFECTIVENESS[E.CHAOS][E.NATURE] = 2
Elements.EFFECTIVENESS[E.CHAOS][E.DIVINE] = 2
Elements.EFFECTIVENESS[E.CHAOS][E.ELECTRIC] = 0.5
Elements.EFFECTIVENESS[E.CHAOS][E.MACHINE] = 0.5
Elements.EFFECTIVENESS[E.CHAOS][E.FIGHTING] = 0.5
Elements.EFFECTIVENESS[E.CHAOS][E.CYCLE] = 0.5
Elements.EFFECTIVENESS[E.CHAOS][E.VOID] = 0

-- 神灵系
Elements.EFFECTIVENESS[E.DIVINE][E.GRASS] = 2
Elements.EFFECTIVENESS[E.DIVINE][E.WATER] = 2
Elements.EFFECTIVENESS[E.DIVINE][E.FIRE] = 2
Elements.EFFECTIVENESS[E.DIVINE][E.ELECTRIC] = 2
Elements.EFFECTIVENESS[E.DIVINE][E.ICE] = 2
Elements.EFFECTIVENESS[E.DIVINE][E.ANCIENT] = 2
Elements.EFFECTIVENESS[E.DIVINE][E.EVIL] = 2
Elements.EFFECTIVENESS[E.DIVINE][E.CHAOS] = 2
Elements.EFFECTIVENESS[E.DIVINE][E.MACHINE] = 0.5
Elements.EFFECTIVENESS[E.DIVINE][E.FIGHTING] = 0.5
Elements.EFFECTIVENESS[E.DIVINE][E.DRAGON] = 0.5

-- 轮回系
Elements.EFFECTIVENESS[E.CYCLE][E.LIGHT] = 2
Elements.EFFECTIVENESS[E.CYCLE][E.DARK] = 2
Elements.EFFECTIVENESS[E.CYCLE][E.HOLY] = 2
Elements.EFFECTIVENESS[E.CYCLE][E.DIMENSION] = 2
Elements.EFFECTIVENESS[E.CYCLE][E.EVIL] = 2
Elements.EFFECTIVENESS[E.CYCLE][E.CHAOS] = 2
Elements.EFFECTIVENESS[E.CYCLE][E.ICE] = 0.5
Elements.EFFECTIVENESS[E.CYCLE][E.PSYCHIC] = 0.5
Elements.EFFECTIVENESS[E.CYCLE][E.NATURE] = 0.5
Elements.EFFECTIVENESS[E.CYCLE][E.VOID] = 0.5

-- 虫系
Elements.EFFECTIVENESS[E.BUG][E.GRASS] = 2
Elements.EFFECTIVENESS[E.BUG][E.GROUND] = 2
Elements.EFFECTIVENESS[E.BUG][E.FIGHTING] = 2
Elements.EFFECTIVENESS[E.BUG][E.CHAOS] = 2
Elements.EFFECTIVENESS[E.BUG][E.BUG] = 2
Elements.EFFECTIVENESS[E.BUG][E.WATER] = 0.5
Elements.EFFECTIVENESS[E.BUG][E.FIRE] = 0.5
Elements.EFFECTIVENESS[E.BUG][E.ICE] = 0.5
Elements.EFFECTIVENESS[E.BUG][E.LIGHT] = 0.5

-- 虚空系
Elements.EFFECTIVENESS[E.VOID][E.PSYCHIC] = 2
Elements.EFFECTIVENESS[E.VOID][E.FIGHTING] = 2
Elements.EFFECTIVENESS[E.VOID][E.LIGHT] = 2
Elements.EFFECTIVENESS[E.VOID][E.MYSTERY] = 2
Elements.EFFECTIVENESS[E.VOID][E.NATURE] = 2
Elements.EFFECTIVENESS[E.VOID][E.CYCLE] = 2
Elements.EFFECTIVENESS[E.VOID][E.FLYING] = 0.5
Elements.EFFECTIVENESS[E.VOID][E.DARK] = 0.5
Elements.EFFECTIVENESS[E.VOID][E.HOLY] = 0.5
Elements.EFFECTIVENESS[E.VOID][E.DIMENSION] = 0.5


-- ==================== 计算函数 ====================

-- 获取单属性对单属性的克制倍率
function Elements.getEffectiveness(atkType, defType)
    if not atkType or not defType then return 1 end
    if atkType < 1 or atkType > 26 or defType < 1 or defType > 26 then return 1 end
    return Elements.EFFECTIVENESS[atkType][defType] or 1
end

-- 单属性攻击双属性
-- 规则：将双属性防守方的属性拆分，各自计算单属性攻击方对两者的克制系数
-- 若两者均为2，则最终克制系数为4
-- 若其中一项为0，则最终克制系数为两者之和÷4
-- 若为其他情况，则最终克制系数为两者之和÷2
function Elements.calcSingleVsDual(atkType, defType1, defType2)
    if not defType2 or defType1 == defType2 then
        return Elements.getEffectiveness(atkType, defType1)
    end
    
    local eff1 = Elements.getEffectiveness(atkType, defType1)
    local eff2 = Elements.getEffectiveness(atkType, defType2)
    
    if eff1 == 2 and eff2 == 2 then
        return 4
    elseif eff1 == 0 or eff2 == 0 then
        return (eff1 + eff2) / 4
    else
        return (eff1 + eff2) / 2
    end
end

-- 双属性攻击单属性
-- 规则：将双属性攻击方的属性拆分，各自计算两者对单属性防守方的克制系数
-- 若两者均为2，则最终克制系数为4
-- 若其中一项为0，则最终克制系数为两者之和÷4
-- 若为其他情况，则最终克制系数为两者之和÷2
function Elements.calcDualVsSingle(atkType1, atkType2, defType)
    if not atkType2 or atkType1 == atkType2 then
        return Elements.getEffectiveness(atkType1, defType)
    end
    
    local eff1 = Elements.getEffectiveness(atkType1, defType)
    local eff2 = Elements.getEffectiveness(atkType2, defType)
    
    if eff1 == 2 and eff2 == 2 then
        return 4
    elseif eff1 == 0 or eff2 == 0 then
        return (eff1 + eff2) / 4
    else
        return (eff1 + eff2) / 2
    end
end

-- 双属性攻击双属性
-- 规则：将防守方的属性拆分，计算双属性攻击方对两者的克制系数，直接加总÷2
function Elements.calcDualVsDual(atkType1, atkType2, defType1, defType2)
    -- 如果攻击方是单属性
    if not atkType2 or atkType1 == atkType2 then
        return Elements.calcSingleVsDual(atkType1, defType1, defType2)
    end
    -- 如果防守方是单属性
    if not defType2 or defType1 == defType2 then
        return Elements.calcDualVsSingle(atkType1, atkType2, defType1)
    end
    
    -- 双属性攻击双属性：计算双属性攻击方对两个防守属性的克制系数，加总÷2
    local effVsDef1 = Elements.calcDualVsSingle(atkType1, atkType2, defType1)
    local effVsDef2 = Elements.calcDualVsSingle(atkType1, atkType2, defType2)
    
    return (effVsDef1 + effVsDef2) / 2
end

-- 通用计算函数（自动判断单/双属性）
function Elements.calculateEffectiveness(atkType1, atkType2, defType1, defType2)
    return Elements.calcDualVsDual(atkType1, atkType2, defType1, defType2)
end

-- ==================== 本系加成 (STAB) ====================
-- 单属性精灵使用与其属性一致的技能会获得50%的威力加成
-- 双属性精灵除了本系技能外，使用其属性拆分后的单属性技能亦能获得同等效果

-- 检查是否获得本系加成
-- petType1, petType2: 精灵的属性（双属性精灵有两个）
-- skillType1, skillType2: 技能的属性（双属性技能有两个）
function Elements.hasSTAB(petType1, petType2, skillType1, skillType2)
    -- 精灵属性列表
    local petTypes = {petType1}
    if petType2 and petType2 ~= petType1 then
        table.insert(petTypes, petType2)
    end
    
    -- 技能属性列表
    local skillTypes = {skillType1}
    if skillType2 and skillType2 ~= skillType1 then
        table.insert(skillTypes, skillType2)
    end
    
    -- 检查是否有任意匹配
    for _, pt in ipairs(petTypes) do
        for _, st in ipairs(skillTypes) do
            if pt == st then
                return true
            end
        end
    end
    
    return false
end

-- 获取STAB倍率（1.5或1.0）
function Elements.getSTABMultiplier(petType1, petType2, skillType1, skillType2)
    if Elements.hasSTAB(petType1, petType2, skillType1, skillType2) then
        return 1.5
    end
    return 1.0
end

-- ==================== 完整伤害倍率计算 ====================
-- 计算包含属性克制和本系加成的总倍率
function Elements.calculateDamageMultiplier(petType1, petType2, skillType1, skillType2, defType1, defType2)
    -- 属性克制倍率（使用技能属性攻击防守方属性）
    local effectiveness = Elements.calculateEffectiveness(skillType1, skillType2, defType1, defType2)
    
    -- 本系加成倍率
    local stab = Elements.getSTABMultiplier(petType1, petType2, skillType1, skillType2)
    
    return effectiveness * stab
end

-- ==================== 辅助函数 ====================

-- 根据属性名获取属性ID
function Elements.getTypeByName(name)
    for id, n in pairs(Elements.NAME) do
        if n == name then
            return id
        end
    end
    return nil
end

-- 获取属性名称
function Elements.getTypeName(typeId)
    return Elements.NAME[typeId] or "未知"
end

-- 获取克制效果描述
function Elements.getEffectivenessText(multiplier)
    if multiplier >= 4 then
        return "超级克制"
    elseif multiplier >= 2 then
        return "克制"
    elseif multiplier >= 1 then
        return "普通"
    elseif multiplier > 0 then
        return "微弱"
    else
        return "无效"
    end
end

-- 调试：打印属性克制信息
function Elements.debugEffectiveness(atkType, defType)
    local eff = Elements.getEffectiveness(atkType, defType)
    local atkName = Elements.getTypeName(atkType)
    local defName = Elements.getTypeName(defType)
    print(string.format("[属性] %s → %s: x%.2f (%s)", 
        atkName, defName, eff, Elements.getEffectivenessText(eff)))
    return eff
end

return Elements
