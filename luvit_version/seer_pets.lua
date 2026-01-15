-- 赛尔号精灵数据库
-- 包含精灵种族值、属性、进化链等信息
-- 优先从 data/monsters.json 加载，回退到内置数据

local Elements = require('./seer_elements')
local Algorithm = require('./seer_algorithm')
local Natures = require('./seer_natures')

local Pets = {}

-- 尝试加载 monsters.json 数据
local Monsters = nil
pcall(function()
    Monsters = require('./seer_monsters')
    Monsters.load()
end)

-- ==================== 精灵种族值数据 (内置备份) ====================
-- 格式: {hp, atk, def, spa, spd, spe}

Pets.BASE_STATS = {
    -- ========== 草系初始精灵线 ==========
    [1] = {  -- 布布种子
        name = "布布种子",
        element = Elements.TYPE.GRASS,
        stats = {hp=55, atk=69, def=65, spa=45, spd=55, spe=31},
        skills = {10001, 20001, 10002, 10003},
    },
    [2] = {  -- 布布草
        name = "布布草",
        element = Elements.TYPE.GRASS,
        stats = {hp=75, atk=89, def=85, spa=55, spd=65, spe=41},
        skills = {10001, 20001, 10002, 10003},
    },
    [3] = {  -- 布布花
        name = "布布花",
        element = Elements.TYPE.GRASS,
        stats = {hp=95, atk=109, def=105, spa=75, spd=85, spe=56},
        skills = {10001, 20001, 10002, 10003},
    },
    
    -- ========== 水系初始精灵线 ==========
    [4] = {  -- 伊优
        name = "伊优",
        element = Elements.TYPE.WATER,
        stats = {hp=53, atk=51, def=53, spa=61, spd=56, spe=40},
        skills = {10004, 20002, 10005, 20003},
    },
    [5] = {  -- 尤里安
        name = "尤里安",
        element = Elements.TYPE.WATER,
        stats = {hp=64, atk=66, def=68, spa=81, spd=76, spe=50},
        skills = {10004, 20002, 10005, 20003},
    },
    [6] = {  -- 巴鲁斯
        name = "巴鲁斯",
        element = Elements.TYPE.WATER,
        stats = {hp=84, atk=86, def=88, spa=111, spd=101, spe=65},
        skills = {10004, 20002, 10005, 20003},
    },
    
    -- ========== 火系初始精灵线 ==========
    [7] = {  -- 小火猴
        name = "小火猴",
        element = Elements.TYPE.FIRE,
        stats = {hp=44, atk=58, def=44, spa=58, spd=44, spe=61},
        skills = {10006, 20004, 10007, 20005},
    },
    [8] = {  -- 烈火猴
        name = "烈火猴",
        element = Elements.TYPE.FIRE,
        stats = {hp=64, atk=78, def=52, spa=78, spd=52, spe=81},
        skills = {10006, 20004, 10007, 20005},
    },
    [9] = {  -- 烈焰猩猩
        name = "烈焰猩猩",
        element = Elements.TYPE.FIRE,
        stats = {hp=76, atk=104, def=71, spa=104, spd=71, spe=108},
        skills = {10006, 20004, 10007, 20005},
    },
    
    -- ========== 新手BOSS ==========
    [58] = {  -- 艾里逊
        name = "艾里逊",
        element = Elements.TYPE.NORMAL,
        stats = {hp=35, atk=46, def=34, spa=35, spd=45, spe=90},
        skills = {10001},
    },
    
    -- ========== 其他常见精灵 ==========
    [10] = {  -- 皮皮
        name = "皮皮",
        element = Elements.TYPE.FLYING,
        stats = {hp=40, atk=55, def=30, spa=30, spd=30, spe=60},
        skills = {10001, 20002, 10008, 10009},
    },
    [13] = {  -- 比比鼠
        name = "比比鼠",
        element = Elements.TYPE.ELECTRIC,
        stats = {hp=45, atk=65, def=34, spa=40, spd=34, spe=45},
        skills = {10001, 20004, 20006, 10011},
    },
}

-- ==================== 精灵数据获取 ====================

-- 获取精灵基础数据（优先从 monsters.json）
function Pets.getData(petId)
    -- 优先从 monsters.json 获取
    if Monsters then
        local monsterData = Monsters.get(petId)
        if monsterData then
            return {
                name = monsterData.name,
                element = monsterData.type,
                stats = monsterData.baseStats,
                skills = Monsters.getMovesAtLevel(petId, 100),  -- 获取所有可学技能
            }
        end
    end
    -- 回退到内置数据
    return Pets.BASE_STATS[petId]
end

-- 获取精灵名称
function Pets.getName(petId)
    if Monsters then
        local name = Monsters.getName(petId)
        if name ~= "未知精灵" then
            return name
        end
    end
    local data = Pets.BASE_STATS[petId]
    return data and data.name or ("精灵#" .. petId)
end

-- 获取精灵属性类型
function Pets.getElement(petId)
    if Monsters then
        local monsterData = Monsters.get(petId)
        if monsterData then
            return monsterData.type
        end
    end
    local data = Pets.BASE_STATS[petId]
    return data and data.element or Elements.TYPE.NORMAL
end

-- 获取精灵种族值
function Pets.getBaseStats(petId)
    if Monsters then
        local stats = Monsters.getBaseStats(petId)
        if stats then
            return stats
        end
    end
    local data = Pets.BASE_STATS[petId]
    if data then
        return data.stats
    end
    -- 默认种族值
    return {hp=50, atk=50, def=50, spa=50, spd=50, spe=50}
end

-- 获取精灵默认技能（根据等级）
function Pets.getDefaultSkills(petId, level)
    level = level or 100
    if Monsters then
        local moves = Monsters.getMovesAtLevel(petId, level)
        if #moves > 0 then
            return moves
        end
    end
    local data = Pets.BASE_STATS[petId]
    if data and data.skills then
        return data.skills
    end
    return {10001, 0, 0, 0}  -- 默认只有撞击
end

-- 检查精灵是否存在
function Pets.exists(petId)
    if Monsters and Monsters.exists(petId) then
        return true
    end
    return Pets.BASE_STATS[petId] ~= nil
end

-- ==================== 精灵实例创建 ====================

-- 创建一个精灵实例（用于新手宠物、野生精灵等）
-- petId: 精灵ID
-- level: 等级
-- iv: 个体值 (0-31)，nil则随机
-- ev: 学习力，nil则为0
-- natureId: 性格ID，nil则随机
function Pets.createInstance(petId, level, iv, ev, natureId)
    local baseStats = Pets.getBaseStats(petId)
    local name = Pets.getName(petId)
    local element = Pets.getElement(petId)
    local skills = Pets.getDefaultSkills(petId, level)
    
    -- 随机个体值 (0-31)
    if iv == nil then
        iv = math.random(0, 31)
    end
    
    -- 默认无学习力
    if ev == nil then
        ev = {hp=0, atk=0, def=0, spa=0, spd=0, spe=0}
    end
    
    -- 随机性格
    if natureId == nil then
        natureId = Natures.random()
    end
    
    -- 计算实际属性
    local stats = Algorithm.calculateStats(baseStats, level, iv, ev, natureId)
    
    return {
        id = petId,
        name = name,
        element = element,
        level = level,
        iv = iv,  -- 个体值
        nature = natureId,
        ev = ev,
        -- 六维属性
        hp = stats.hp,
        maxHp = stats.hp,
        attack = stats.atk,
        defence = stats.def,
        s_a = stats.spa,
        s_d = stats.spd,
        speed = stats.spe,
        -- 技能
        skills = skills,
        -- 经验
        exp = 0,
        -- 捕获信息
        catchTime = os.time(),
        catchMap = 301,
        catchLevel = level,
    }
end

-- 创建新手精灵（满个体值31，平衡性格）
function Pets.createStarterPet(petId, level)
    level = level or 5
    return Pets.createInstance(petId, level, 31, nil, 21)  -- 31个体，害羞性格
end

-- 创建野生精灵（随机个体值和性格）
function Pets.createWildPet(petId, level)
    return Pets.createInstance(petId, level, nil, nil, nil)
end

-- ==================== 调试函数 ====================

-- 打印精灵信息
function Pets.printInfo(pet)
    print(string.format("========== %s (ID:%d) ==========", pet.name, pet.id))
    print(string.format("等级: %d  属性: %s", pet.level, Elements.getTypeName(pet.element)))
    print(string.format("个体值: %d  性格: %s", pet.iv, Natures.getName(pet.nature)))
    print(string.format("HP: %d/%d", pet.hp, pet.maxHp))
    print(string.format("攻击: %d  防御: %d", pet.attack, pet.defence))
    print(string.format("特攻: %d  特防: %d", pet.s_a, pet.s_d))
    print(string.format("速度: %d", pet.speed))
    print("================================")
end

-- 测试三只新手精灵
function Pets.testStarters()
    print("\n===== 新手精灵属性测试 (Lv5, 满个体31, 平衡性格) =====\n")
    
    local starters = {1, 7, 4}  -- 布布种子, 小火猴, 伊优
    for _, petId in ipairs(starters) do
        local pet = Pets.createStarterPet(petId, 5)
        Pets.printInfo(pet)
        print()
    end
end

return Pets
