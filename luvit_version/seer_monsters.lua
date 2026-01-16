-- 精灵数据模块 - 从 XML 读取精灵信息
-- 数据来源: data/spt.xml (客户端解包)

local fs = require('fs')

local SeerMonsters = {}
SeerMonsters.monsters = {}  -- id -> monster data
SeerMonsters.loaded = false

-- 简单的 XML 属性解析
local function parseAttributes(tag)
    local attrs = {}
    for key, value in tag:gmatch('(%w+)="([^"]*)"') do
        attrs[key] = value
    end
    return attrs
end

-- 解析 LearnableMoves
local function parseMoves(content)
    local moves = {}
    for moveTag in content:gmatch('<Move[^/]*/[^>]*>') do
        local attrs = parseAttributes(moveTag)
        if attrs.ID and attrs.LearningLv then
            table.insert(moves, {
                id = tonumber(attrs.ID),
                level = tonumber(attrs.LearningLv)
            })
        end
    end
    -- 按等级排序
    table.sort(moves, function(a, b) return a.level < b.level end)
    return moves
end

-- 加载精灵数据
function SeerMonsters.load()
    if SeerMonsters.loaded then
        return true
    end
    
    local xmlPath = "../data/spt.xml"
    local content, err = fs.readFileSync(xmlPath)
    
    if not content then
        print("[SeerMonsters] 无法读取精灵数据: " .. tostring(err))
        return false
    end
    
    -- 解析每个 Monster 标签
    local count = 0
    for monsterBlock in content:gmatch('<Monster[^>]*>.-</Monster>') do
        -- 提取属性部分
        local tagStart = monsterBlock:match('<Monster[^>]*>')
        local attrs = parseAttributes(tagStart)
        
        if attrs.ID then
            local id = tonumber(attrs.ID)
            local monster = {
                id = id,
                name = attrs.DefName or "",
                type = tonumber(attrs.Type) or 0,
                growthType = tonumber(attrs.GrowthType) or 0,
                hp = tonumber(attrs.HP) or 0,
                atk = tonumber(attrs.Atk) or 0,
                def = tonumber(attrs.Def) or 0,
                spAtk = tonumber(attrs.SpAtk) or 0,
                spDef = tonumber(attrs.SpDef) or 0,
                spd = tonumber(attrs.Spd) or 0,
                yieldingExp = tonumber(attrs.YieldingExp) or 0,
                catchRate = tonumber(attrs.CatchRate) or 0,
                evolvesFrom = tonumber(attrs.EvolvesFrom) or 0,
                evolvesTo = tonumber(attrs.EvolvesTo) or 0,
                evolvingLv = tonumber(attrs.EvolvingLv) or 0,
                freeForbidden = tonumber(attrs.FreeForbidden) or 0,
                gender = tonumber(attrs.Gender) or 0,
                petClass = tonumber(attrs.PetClass) or 0,
                moves = parseMoves(monsterBlock)
            }
            SeerMonsters.monsters[id] = monster
            count = count + 1
        end
    end
    
    SeerMonsters.loaded = true
    print(string.format("[SeerMonsters] 加载了 %d 个精灵数据", count))
    return true
end

-- 获取精灵数据
function SeerMonsters.get(id)
    if not SeerMonsters.loaded then
        SeerMonsters.load()
    end
    return SeerMonsters.monsters[id]
end

-- 获取精灵名称
function SeerMonsters.getName(id)
    local monster = SeerMonsters.get(id)
    return monster and monster.name or ""
end

-- 获取精灵在指定等级可学习的技能
function SeerMonsters.getSkillsForLevel(id, level)
    local monster = SeerMonsters.get(id)
    if not monster then return {} end
    
    local skills = {}
    for _, move in ipairs(monster.moves) do
        if move.level <= level then
            table.insert(skills, move.id)
        end
    end
    return skills
end

-- 获取精灵在指定等级的前4个技能 (战斗用)
function SeerMonsters.getBattleSkills(id, level)
    local allSkills = SeerMonsters.getSkillsForLevel(id, level)
    local skills = {0, 0, 0, 0}
    
    -- 取最后学会的4个技能
    local start = math.max(1, #allSkills - 3)
    for i = start, #allSkills do
        skills[i - start + 1] = allSkills[i]
    end
    
    return skills
end

-- 计算精灵在指定等级的属性
-- 使用简化公式: stat = base * level / 50 + 5
function SeerMonsters.calculateStats(id, level, dv)
    local monster = SeerMonsters.get(id)
    if not monster then return nil end
    
    dv = dv or 15  -- 默认个体值
    level = level or 5
    
    -- 简化的属性计算公式
    local function calcStat(base)
        return math.floor((base * 2 + dv) * level / 100 + 5)
    end
    
    local function calcHP(base)
        return math.floor((base * 2 + dv) * level / 100 + level + 10)
    end
    
    return {
        hp = calcHP(monster.hp),
        maxHp = calcHP(monster.hp),
        attack = calcStat(monster.atk),
        defence = calcStat(monster.def),
        spAtk = calcStat(monster.spAtk),
        spDef = calcStat(monster.spDef),
        speed = calcStat(monster.spd)
    }
end

-- 获取所有精灵ID列表
function SeerMonsters.getAllIds()
    if not SeerMonsters.loaded then
        SeerMonsters.load()
    end
    
    local ids = {}
    for id, _ in pairs(SeerMonsters.monsters) do
        table.insert(ids, id)
    end
    table.sort(ids)
    return ids
end

-- 按类型获取精灵
function SeerMonsters.getByType(typeId)
    if not SeerMonsters.loaded then
        SeerMonsters.load()
    end
    
    local result = {}
    for id, monster in pairs(SeerMonsters.monsters) do
        if monster.type == typeId then
            table.insert(result, monster)
        end
    end
    return result
end

return SeerMonsters
