-- seer_pets.lua
-- 赛尔号精灵数据加载器
-- 从 data/spt.xml 加载完整精灵信息，建立与技能的引用关系

local XmlLoader = require("../core/xml_loader")

local SeerPets = {}
SeerPets.pets = {}
SeerPets.loaded = false

-- 加载精灵数据
function SeerPets.load()
    if SeerPets.loaded then return end
    
    print("\27[36m[SeerPets] 正在加载精灵数据...\27[0m")
    
    local tree, err = XmlLoader.load("data/spt.xml")
    
    if not tree then
        print("\27[31m[SeerPets] XML解析失败: " .. (err or "unknown") .. "\27[0m")
        return
    end
    
    -- 调试：打印根节点信息
    print(string.format("\27[33m[SeerPets] 根节点: name=%s, children=%s\27[0m", 
        tostring(tree.name), tree.children and #tree.children or "nil"))
    
    -- 查找 Monsters 节点
    local monstersNode = nil
    if tree.name == "Monsters" then
        monstersNode = tree
    elseif tree.children then
        for _, child in ipairs(tree.children) do
            print(string.format("\27[33m[SeerPets] 子节点: %s\27[0m", tostring(child.name)))
            if child.name == "Monsters" then
                monstersNode = child
                break
            end
        end
    end
    
    if not monstersNode then
        print("\27[31m[SeerPets] 未找到 Monsters 节点\27[0m")
        print("\27[33m[SeerPets] 提示: 请检查 data/spt.xml 文件是否存在且格式正确\27[0m")
        -- 创建空数据以避免后续错误
        SeerPets.loaded = true
        return
    end
    
    local count = 0
    for _, node in ipairs(monstersNode.children or {}) do
        if node.name == "Monster" and node.attributes then
            local attrs = node.attributes
            local id = tonumber(attrs.ID)
            
            if id then
                -- 基础属性
                local pet = {
                    id = id,
                    defName = attrs.DefName or "未知精灵",
                    type = tonumber(attrs.Type) or 8,
                    type2 = tonumber(attrs.Type2) or 0,  -- 第二属性
                    
                    -- 种族值
                    hp = tonumber(attrs.Hp) or 100,
                    atk = tonumber(attrs.Atk) or 50,
                    def = tonumber(attrs.Def) or 50,
                    spAtk = tonumber(attrs.SpAtk) or 50,
                    spDef = tonumber(attrs.SpDef) or 50,
                    spd = tonumber(attrs.Spd) or 50,
                    
                    -- 进化相关
                    evolvesFrom = tonumber(attrs.EvolvesFrom) or 0,
                    evolvesTo = tonumber(attrs.EvolvesTo) or 0,
                    evolvingLv = tonumber(attrs.EvolvingLv) or 0,
                    evolvFlag = tonumber(attrs.EvolvFlag) or 0,
                    evolvItem = tonumber(attrs.EvolvItem) or 0,
                    evolvItemCount = tonumber(attrs.EvolvItemCount) or 1,
                    evolveBabin = tonumber(attrs.EvolveBabin) or 0,
                    
                    -- 捕获相关
                    catchRate = tonumber(attrs.CatchRate) or 255,
                    freeForbidden = tonumber(attrs.FreeForbidden) or 0,
                    
                    -- 经验和努力值
                    yieldingExp = tonumber(attrs.YieldingExp) or 100,
                    yieldingEV = attrs.YieldingEV or "0,0,0,0,0,0",
                    growthType = tonumber(attrs.GrowthType) or 0,
                    
                    -- 特殊标记
                    isRareMon = tonumber(attrs.IsRareMon) or 0,
                    isDark = tonumber(attrs.IsDark) or 0,
                    isAbilityMon = tonumber(attrs.IsAbilityMon) or 0,
                    variationID = tonumber(attrs.VariationID) or 0,
                    breedingmon = tonumber(attrs.breedingmon) or 0,
                    supermon = tonumber(attrs.supermon) or 0,
                    
                    -- 形态相关
                    realId = tonumber(attrs.RealId) or 0,
                    transform = attrs.Transform,
                    
                    -- 战斗力系数
                    formParam = tonumber(attrs.FormParam) or 1.0,
                    gradeParam = tonumber(attrs.GradeParam) or 1.0,
                    addSeParam = tonumber(attrs.AddSeParam) or 0,
                    modifyPower = tonumber(attrs.ModifyPower) or 0,
                    
                    -- 坐骑相关
                    isRidePet = tonumber(attrs.isRidePet) or 0,
                    isFlyPet = tonumber(attrs.isFlyPet) or 0,
                    scale = tonumber(attrs.scale),
                    nameY = tonumber(attrs.nameY),
                    speed = tonumber(attrs.speed),
                    
                    -- 其他
                    gender = tonumber(attrs.Gender) or 0,
                    petClass = tonumber(attrs.PetClass) or id,
                    vipBtlAdj = tonumber(attrs.VipBtlAdj) or 0,
                    resist = tonumber(attrs.Resist) or 0,
                    combo = attrs.Combo,
                    
                    -- 技能列表 (稍后解析)
                    learnableMoves = {},
                    extraMoves = {},
                    recMoves = {},
                    othMoves = {},
                    advMove = {},
                    
                    -- 天敌列表
                    naturalEnemy = {}
                }
                
                -- 解析子节点
                for _, childNode in ipairs(node.children or {}) do
                    if childNode.name == "LearnableMoves" then
                        -- 解析可学习技能
                        for _, moveNode in ipairs(childNode.children or {}) do
                            if moveNode.name == "Move" and moveNode.attributes then
                                local moveId = tonumber(moveNode.attributes.ID)
                                local moveLv = tonumber(moveNode.attributes.LearningLv) or 0
                                if moveId then
                                    table.insert(pet.learnableMoves, {
                                        id = moveId,
                                        level = moveLv
                                    })
                                end
                            end
                        end
                    elseif childNode.name == "ExtraMoves" then
                        -- 解析额外技能
                        for _, moveNode in ipairs(childNode.children or {}) do
                            if moveNode.name == "Move" and moveNode.attributes then
                                local moveId = tonumber(moveNode.attributes.ID)
                                if moveId then
                                    table.insert(pet.extraMoves, moveId)
                                end
                            end
                        end
                    elseif childNode.name == "Rec" then
                        -- 解析推荐技能
                        for _, moveNode in ipairs(childNode.children or {}) do
                            if moveNode.name == "Move" and moveNode.attributes then
                                local moveId = tonumber(moveNode.attributes.ID)
                                local tag = tonumber(moveNode.attributes.Tag) or 0
                                if moveId then
                                    table.insert(pet.recMoves, {id = moveId, tag = tag})
                                end
                            end
                        end
                    elseif childNode.name == "Oth" then
                        -- 解析其他推荐技能
                        for _, moveNode in ipairs(childNode.children or {}) do
                            if moveNode.name == "Move" and moveNode.attributes then
                                local moveId = tonumber(moveNode.attributes.ID)
                                if moveId then
                                    table.insert(pet.othMoves, moveId)
                                end
                            end
                        end
                    elseif childNode.name == "AdvMove" then
                        -- 解析神谕进阶技能
                        for _, moveNode in ipairs(childNode.children or {}) do
                            if moveNode.name == "Move" and moveNode.attributes then
                                local moveId = tonumber(moveNode.attributes.ID)
                                if moveId then
                                    table.insert(pet.advMove, moveId)
                                end
                            end
                        end
                    elseif childNode.name == "NaturalEnemy" then
                        -- 解析天敌
                        for _, enemyNode in ipairs(childNode.children or {}) do
                            if enemyNode.name == "Enemy" and enemyNode.attributes then
                                local enemyId = tonumber(enemyNode.attributes.ID)
                                if enemyId then
                                    table.insert(pet.naturalEnemy, enemyId)
                                end
                            end
                        end
                    end
                end
                
                SeerPets.pets[id] = pet
                count = count + 1
            end
        end
    end
    
    print(string.format("\27[32m[SeerPets] 加载了 %d 个精灵数据\27[0m", count))
    SeerPets.loaded = true
end

-- 获取精灵数据
function SeerPets.get(petId)
    if not SeerPets.loaded then
        SeerPets.load()
    end
    return SeerPets.pets[petId]
end

-- 获取精灵的所有可学习技能
function SeerPets.getLearnableMoves(petId, level)
    local pet = SeerPets.get(petId)
    if not pet then return {} end
    
    local moves = {}
    for _, move in ipairs(pet.learnableMoves) do
        if not level or move.level <= level then
            table.insert(moves, move)
        end
    end
    return moves
end

-- 检查精灵是否可以学习某个技能
function SeerPets.canLearnMove(petId, moveId)
    local pet = SeerPets.get(petId)
    if not pet then return false end
    
    -- 检查可学习技能
    for _, move in ipairs(pet.learnableMoves) do
        if move.id == moveId then
            return true
        end
    end
    
    -- 检查额外技能
    for _, id in ipairs(pet.extraMoves) do
        if id == moveId then
            return true
        end
    end
    
    return false
end

-- 获取精灵的进化链
function SeerPets.getEvolutionChain(petId)
    local chain = {}
    local current = petId
    
    -- 向前追溯到最初形态
    while current do
        local pet = SeerPets.get(current)
        if not pet or pet.evolvesFrom == 0 then
            break
        end
        current = pet.evolvesFrom
    end
    
    -- 从最初形态开始构建进化链
    while current do
        table.insert(chain, current)
        local pet = SeerPets.get(current)
        if not pet or pet.evolvesTo == 0 then
            break
        end
        current = pet.evolvesTo
    end
    
    return chain
end

-- 检查精灵是否可以进化
function SeerPets.canEvolve(petId, level, hasItem)
    local pet = SeerPets.get(petId)
    if not pet or pet.evolvesTo == 0 then
        return false, "无法进化"
    end
    
    -- 检查等级
    if pet.evolvingLv > 0 and level < pet.evolvingLv then
        return false, string.format("需要等级 %d", pet.evolvingLv)
    end
    
    -- 检查道具
    if pet.evolvItem > 0 and not hasItem then
        return false, string.format("需要道具 ID:%d", pet.evolvItem)
    end
    
    -- 检查进化舱
    if pet.evolveBabin == 1 then
        return false, "需要在进化舱进化"
    end
    
    return true, pet.evolvesTo
end

-- 获取精灵的真实ID (用于资源加载)
function SeerPets.getRealId(petId)
    local pet = SeerPets.get(petId)
    if not pet then return petId end
    return pet.realId > 0 and pet.realId or petId
end

-- 解析努力值字符串
function SeerPets.parseYieldingEV(evString)
    local ev = {hp = 0, atk = 0, def = 0, spAtk = 0, spDef = 0, spd = 0}
    local values = {}
    for num in string.gmatch(evString, "([^,]+)") do
        table.insert(values, tonumber(num) or 0)
    end
    if #values >= 6 then
        ev.hp, ev.atk, ev.def, ev.spAtk, ev.spDef, ev.spd = 
            values[1], values[2], values[3], values[4], values[5], values[6]
    end
    return ev
end

-- 打印精灵信息 (调试用)
function SeerPets.printInfo(petId)
    local pet = SeerPets.get(petId)
    if not pet then
        print(string.format("\27[31m精灵 ID:%d 不存在\27[0m", petId))
        return
    end
    
    print(string.format("\27[36m========== 精灵信息: %s (ID:%d) ==========\27[0m", pet.defName, pet.id))
    print(string.format("属性: %d%s", pet.type, pet.type2 > 0 and ("/" .. pet.type2) or ""))
    print(string.format("种族值: HP:%d 攻:%d 防:%d 特攻:%d 特防:%d 速度:%d", 
        pet.hp, pet.atk, pet.def, pet.spAtk, pet.spDef, pet.spd))
    print(string.format("进化: 来自:%d 进化为:%d (Lv%d)", 
        pet.evolvesFrom, pet.evolvesTo, pet.evolvingLv))
    print(string.format("捕获率: %d", pet.catchRate))
    print(string.format("可学习技能数: %d", #pet.learnableMoves))
    print("\27[36m" .. string.rep("=", 50) .. "\27[0m")
end

-- 获取精灵名称
function SeerPets.getName(petId)
    if not SeerPets.loaded then
        SeerPets.load()
    end
    local pet = SeerPets.get(petId)
    if pet then
        return pet.defName
    end
    -- 返回默认名称
    return string.format("精灵#%d", petId or 0)
end

-- 获取精灵数据 (别名，兼容旧代码)
function SeerPets.getData(petId)
    return SeerPets.get(petId)
end

-- 计算精灵属性值
-- 公式: HP = floor((种族值*2 + 个体值 + 努力值/4) * 等级/100) + 等级 + 10
--      其他 = floor((种族值*2 + 个体值 + 努力值/4) * 等级/100) + 5
function SeerPets.getStats(petId, level, dv, ev)
    local pet = SeerPets.get(petId)
    if not pet then
        return {hp = 20, maxHp = 20, attack = 10, defence = 10, spAtk = 10, spDef = 10, speed = 10}
    end
    
    level = level or 1
    
    -- 安全处理 DV (如果传入的是函数或非法值)
    if type(dv) == "function" then dv = dv() end
    dv = tonumber(dv) or 31
    
    ev = ev or {hp = 0, atk = 0, def = 0, spAtk = 0, spDef = 0, spd = 0}
    
    -- 如果ev是数字，转换为表
    if type(ev) == "number" then
        local evValue = ev
        ev = {hp = evValue, atk = evValue, def = evValue, spAtk = evValue, spDef = evValue, spd = evValue}
    end
    
    -- 计算各项属性
    local hp = math.floor((pet.hp * 2 + dv + (ev.hp or 0) / 4) * level / 100) + level + 10
    local attack = math.floor((pet.atk * 2 + dv + (ev.atk or 0) / 4) * level / 100) + 5
    local defence = math.floor((pet.def * 2 + dv + (ev.def or 0) / 4) * level / 100) + 5
    local spAtk = math.floor((pet.spAtk * 2 + dv + (ev.spAtk or 0) / 4) * level / 100) + 5
    local spDef = math.floor((pet.spDef * 2 + dv + (ev.spDef or 0) / 4) * level / 100) + 5
    local speed = math.floor((pet.spd * 2 + dv + (ev.spd or 0) / 4) * level / 100) + 5
    
    return {
        hp = hp,
        maxHp = hp,
        attack = attack,
        defence = defence,
        spAtk = spAtk,
        spDef = spDef,
        speed = speed
    }
end

-- 获取精灵在指定等级可以学会的技能
function SeerPets.getSkillsForLevel(petId, level)
    local pet = SeerPets.get(petId)
    if not pet then return {} end
    
    local skills = {}
    for _, move in ipairs(pet.learnableMoves) do
        if move.level <= level then
            table.insert(skills, move.id)
        end
    end
    
    -- 最多返回4个技能（最新学会的4个）
    local result = {}
    local startIdx = math.max(1, #skills - 3)
    for i = startIdx, #skills do
        table.insert(result, skills[i])
    end
    
    -- 补齐到4个
    while #result < 4 do
        table.insert(result, 0)
    end
    
    return result
end

-- 获取经验信息
-- 返回: {currentLevelExp, nextLevelExp, totalExp}
function SeerPets.getExpInfo(petId, level, currentLevelExp)
    local pet = SeerPets.get(petId)
    if not pet then
        return {currentLevelExp = 0, nextLevelExp = 100, totalExp = 0}
    end
    
    -- 经验计算公式（简化版）
    -- 不同成长类型有不同的经验曲线
    local growthType = pet.growthType or 0
    
    -- 计算升到下一级所需经验
    local nextLevelExp = 0
    if growthType == 0 then
        -- 快速成长
        nextLevelExp = math.floor(level * level * level * 0.8)
    elseif growthType == 1 then
        -- 中速成长
        nextLevelExp = math.floor(level * level * level)
    elseif growthType == 2 then
        -- 慢速成长
        nextLevelExp = math.floor(level * level * level * 1.2)
    elseif growthType == 3 then
        -- 极慢成长
        nextLevelExp = math.floor(level * level * level * 1.5)
    else
        -- 默认
        nextLevelExp = math.floor(level * level * level)
    end
    
    -- 计算总经验
    local totalExp = 0
    for lv = 1, level - 1 do
        if growthType == 0 then
            totalExp = totalExp + math.floor(lv * lv * lv * 0.8)
        elseif growthType == 1 then
            totalExp = totalExp + math.floor(lv * lv * lv)
        elseif growthType == 2 then
            totalExp = totalExp + math.floor(lv * lv * lv * 1.2)
        elseif growthType == 3 then
            totalExp = totalExp + math.floor(lv * lv * lv * 1.5)
        else
            totalExp = totalExp + math.floor(lv * lv * lv)
        end
    end
    totalExp = totalExp + (currentLevelExp or 0)
    
    return {
        currentLevelExp = currentLevelExp or 0,
        nextLevelExp = nextLevelExp,
        totalExp = totalExp
    }
end

--- 创建新手精灵实例
--- 返回一个包含完整属性的精灵对象
function SeerPets.createStarterPet(petId, level)
    level = level or 5
    local pet = SeerPets.get(petId)
    
    -- 如果数据库加载失败，返回默认值
    if not pet then
        print(string.format("\27[31m[SeerPets] 警告: 精灵 %d 数据不存在，使用默认值\27[0m", petId))
        return {
            name = "",  -- 空名字（野生精灵）
            iv = 31,
            nature = math.random(0, 24),
            exp = 0,
            hp = 100,
            maxHp = 100,
            attack = 20,
            defence = 20,
            s_a = 20,
            s_d = 20,
            speed = 20,
            ev = {hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0},
            skills = {10001, 0, 0, 0},  -- 默认技能：撞击
            catchMap = 301,
            catchLevel = level
        }
    end
    
    -- 生成随机个体值和性格
    local iv = math.random(0, 31)
    local nature = math.random(0, 24)
    
    -- 计算属性
    local stats = SeerPets.getStats(petId, level, iv, {hp=0, atk=0, def=0, spAtk=0, spDef=0, spd=0})
    
    -- 获取技能
    local skills = SeerPets.getSkillsForLevel(petId, level)
    
    return {
        name = "",  -- 野生精灵名字为空
        iv = iv,
        nature = nature,
        exp = 0,
        hp = stats.hp,
        maxHp = stats.hp,
        attack = stats.atk,
        defence = stats.def,
        s_a = stats.spAtk,
        s_d = stats.spDef,
        speed = stats.spd,
        ev = {hp = 0, atk = 0, def = 0, spa = 0, spd = 0, spe = 0},
        skills = skills,
        catchMap = 301,
        catchLevel = level
    }
end

--- 检查精灵是否存在
function SeerPets.exists(petId)
    return SeerPets.pets[petId] ~= nil
end

return SeerPets
