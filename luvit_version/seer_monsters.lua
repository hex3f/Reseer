-- 精灵数据库加载器
-- 从 data/monsters.json 加载精灵基础数据

local fs = require "fs"
local json = require "json"

local SeerMonsters = {}

-- 精灵数据缓存
local monstersCache = nil
local monsterById = {}

-- 加载精灵数据
function SeerMonsters.load()
    if monstersCache then
        return monstersCache
    end
    
    local dataPath = "../data/monsters.json"
    
    if not fs.existsSync(dataPath) then
        print("\27[31m[SeerMonsters] 精灵数据文件不存在: " .. dataPath .. "\27[0m")
        return {}
    end
    
    local data = fs.readFileSync(dataPath)
    local success, result = pcall(function()
        return json.parse(data)
    end)
    
    if not success or not result then
        print("\27[31m[SeerMonsters] 精灵数据解析失败\27[0m")
        return {}
    end
    
    -- 解析数据结构
    local monsters = {}
    if result.Monsters and result.Monsters.Monster then
        for _, monster in ipairs(result.Monsters.Monster) do
            local id = monster.ID
            monsters[id] = {
                id = id,
                name = monster.DefName or ("精灵" .. id),
                type = monster.Type or 8,  -- 默认普通属性
                -- 种族值
                baseStats = {
                    hp = monster.HP or 50,
                    atk = monster.Atk or 50,
                    def = monster.Def or 50,
                    spa = monster.SpAtk or 50,
                    spd = monster.SpDef or 50,
                    spe = monster.Spd or 50
                },
                -- 进化信息
                evolvesFrom = monster.EvolvesFrom or 0,
                evolvesTo = monster.EvolvesTo or 0,
                evolvingLv = monster.EvolvingLv or 0,
                -- 捕获信息
                catchRate = monster.CatchRate or 45,
                yieldingExp = monster.YieldingExp or 50,
                yieldingEV = monster.YieldingEV or "0 0 0 0 0 0",
                -- 其他
                gender = monster.Gender or 0,
                petClass = monster.PetClass or 0,
                isRare = monster.IsRareMon == 1,
                -- 可学技能
                learnableMoves = {}
            }
            
            -- 解析可学技能
            if monster.LearnableMoves and monster.LearnableMoves.Move then
                for _, move in ipairs(monster.LearnableMoves.Move) do
                    table.insert(monsters[id].learnableMoves, {
                        id = move.ID,
                        level = move.LearningLv
                    })
                end
            end
            
            monsterById[id] = monsters[id]
        end
    end
    
    monstersCache = monsters
    
    local count = 0
    for _ in pairs(monsters) do count = count + 1 end
    print(string.format("\27[32m[SeerMonsters] 加载了 %d 只精灵数据\27[0m", count))
    
    return monsters
end

-- 获取精灵数据
function SeerMonsters.get(petId)
    if not monstersCache then
        SeerMonsters.load()
    end
    return monsterById[petId]
end

-- 获取所有精灵ID列表
function SeerMonsters.getAllIds()
    if not monstersCache then
        SeerMonsters.load()
    end
    
    local ids = {}
    for id, _ in pairs(monsterById) do
        table.insert(ids, id)
    end
    table.sort(ids)
    return ids
end

-- 获取精灵总数
function SeerMonsters.getCount()
    if not monstersCache then
        SeerMonsters.load()
    end
    
    local count = 0
    for _ in pairs(monsterById) do count = count + 1 end
    return count
end

-- 检查精灵是否存在
function SeerMonsters.exists(petId)
    if not monstersCache then
        SeerMonsters.load()
    end
    return monsterById[petId] ~= nil
end

-- 获取精灵名称
function SeerMonsters.getName(petId)
    local monster = SeerMonsters.get(petId)
    if monster then
        return monster.name
    end
    return "未知精灵"
end

-- 获取精灵种族值
function SeerMonsters.getBaseStats(petId)
    local monster = SeerMonsters.get(petId)
    if monster then
        return monster.baseStats
    end
    return { hp = 50, atk = 50, def = 50, spa = 50, spd = 50, spe = 50 }
end

-- 获取精灵属性类型
function SeerMonsters.getType(petId)
    local monster = SeerMonsters.get(petId)
    if monster then
        return monster.type
    end
    return 8  -- 默认普通属性
end

-- 获取精灵可学技能（按等级）
function SeerMonsters.getMovesAtLevel(petId, level)
    local monster = SeerMonsters.get(petId)
    if not monster then
        return {}
    end
    
    local moves = {}
    for _, move in ipairs(monster.learnableMoves) do
        if move.level <= level then
            table.insert(moves, move.id)
        end
    end
    
    -- 只返回最后4个技能
    while #moves > 4 do
        table.remove(moves, 1)
    end
    
    return moves
end

return SeerMonsters
