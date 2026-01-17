-- seer_skills.lua
-- 赛尔号技能数据
-- 从 data/skills.xml 加载完整技能信息

local fs = require("fs")
local xml_parser = require("./gameserver/xml_parser")

local SeerSkills = {}
SeerSkills.skills = {}
SeerSkills.loaded = false

-- 加载技能数据
function SeerSkills.load()
    if SeerSkills.loaded then return end
    
    print("Loading skills from data/skills.xml...")
    local content = fs.readFileSync("data/skills.xml")
    
    if not content then
        print("\27[31m[SeerSkills] 无法读取技能数据文件\27[0m")
        return
    end
    
    local parser = xml_parser:new()
    local tree = parser:parse(content)
    
    if not tree or (tree.name ~= "MovesTbl" and tree.name ~= "Moves") then
        -- Handle case where root is MovesTbl or just Moves
    end
    
    -- Find the list of moves
    local movesList = {}
    if tree.name == "Moves" then
        movesList = tree.children
    else
        for _, child in ipairs(tree.children) do
            if child.name == "Moves" then
                movesList = child.children
                break
            end
        end
    end
    
    local count = 0
    for _, node in ipairs(movesList) do
        if node.name == "Move" and node.attributes then
            local attrs = node.attributes
            local id = tonumber(attrs.ID)
            
            if id then
                SeerSkills.skills[id] = {
                    id = id,
                    name = attrs.Name or "未知技能",
                    category = tonumber(attrs.Category) or 1,
                    type = tonumber(attrs.Type) or 8,
                    power = tonumber(attrs.Power) or 0,
                    pp = tonumber(attrs.MaxPP) or 35,
                    maxPP = tonumber(attrs.MaxPP) or 35,
                    accuracy = tonumber(attrs.Accuracy) or 100,
                    critRate = tonumber(attrs.CritRate) or 1,
                    priority = tonumber(attrs.Priority) or 0,
                    mustHit = (tonumber(attrs.MustHit) or 0) == 1,
                    sideEffect = tonumber(attrs.SideEffect),
                    sideEffectArg = attrs.SideEffectArg,
                    monId = tonumber(attrs.MonID),
                    -- Parsed flags
                    critAtkFirst = (tonumber(attrs.CritAtkFirst) or 0) == 1,
                    critAtkSecond = (tonumber(attrs.CritAtkSecond) or 0) == 1,
                    critSelfHalfHp = (tonumber(attrs.CritSelfHalfHp) or 0) == 1,
                    critFoeHalfHp = (tonumber(attrs.CritFoeHalfHp) or 0) == 1,
                    dmgBindLv = (tonumber(attrs.DmgBindLv) or 0) == 1,
                    pwrBindDv = tonumber(attrs.PwrBindDv),
                    pwrDouble = (tonumber(attrs.PwrDouble) or 0) == 1
                }
                count = count + 1
            end
        end
    end
    
    print(string.format("\27[32m[SeerSkills] 加载了 %d 个技能数据\27[0m", count))
    
    -- Inject Official Skill IDs for Compatibility
    SeerSkills.injectOfficialSkills()
    
    SeerSkills.loaded = true
end

-- 注入官服技能ID 并链接技能效果数据
function SeerSkills.injectOfficialSkills()
    local SeerSkillEffects = require('./seer_skill_effects')
    
    -- 确保效果数据已加载
    SeerSkillEffects.load()
    
    -- 遍历所有技能，链接效果数据
    local linkedCount = 0
    for id, skill in pairs(SeerSkills.skills) do
        if skill.sideEffect and skill.sideEffect > 0 then
            -- 获取效果定义
            local effectData = SeerSkillEffects.get(skill.sideEffect)
            if effectData then
                -- 将效果数据链接到技能
                skill.effectData = effectData
                linkedCount = linkedCount + 1
            else
                print(string.format("\27[33m[SeerSkills] 警告: 技能 %s (ID:%d) 的效果 ID:%d 未找到\27[0m", 
                    skill.name, skill.id, skill.sideEffect))
            end
        end
    end
    
    print(string.format("\27[32m[SeerSkills] 链接了 %d 个技能效果\27[0m", linkedCount))
end

-- 获取技能数据
function SeerSkills.get(skillId)
    if not SeerSkills.loaded then
        SeerSkills.load()
    end
    return SeerSkills.skills[skillId]
end

-- 获取技能的完整信息 (包括效果)
function SeerSkills.getFullInfo(skillId)
    local skill = SeerSkills.get(skillId)
    if not skill then return nil end
    
    local info = {}
    for k, v in pairs(skill) do
        info[k] = v
    end
    
    -- 如果有效果数据，添加效果详情
    if skill.effectData then
        info.effectDesc = skill.effectData.desc
        info.effectEid = skill.effectData.eid
        info.effectArgs = skill.effectData.args
    end
    
    return info
end

-- 检查技能是否为专属技能
function SeerSkills.isExclusiveMove(skillId, petId)
    local skill = SeerSkills.get(skillId)
    if not skill then return false end
    
    -- 如果技能有 MonID 字段，则为专属技能
    if skill.monId and skill.monId > 0 then
        return skill.monId == petId
    end
    
    return true  -- 非专属技能，所有精灵都可以使用
end

-- 计算技能伤害 (基础计算，不含效果)
function SeerSkills.calculateBaseDamage(skill, attacker, defender)
    if not skill or skill.power == 0 then
        return 0
    end
    
    -- 基础伤害公式
    local level = attacker.level or 50
    local attack = skill.category == 1 and (attacker.atk or 100) or (attacker.spAtk or 100)
    local defense = skill.category == 1 and (defender.def or 100) or (defender.spDef or 100)
    
    -- 基础伤害 = ((等级*2/5+2) * 威力 * 攻击/防御 / 50) + 2
    local baseDamage = ((level * 2 / 5 + 2) * skill.power * attack / defense / 50) + 2
    
    -- 属性一致加成 (STAB)
    if attacker.type == skill.type or attacker.type2 == skill.type then
        baseDamage = baseDamage * 1.5
    end
    
    -- 属性克制
    local SeerBattle = require('./seer_battle')
    local typeMultiplier = SeerBattle.getTypeMultiplier(skill.type, defender.type or 8)
    if defender.type2 and defender.type2 > 0 then
        typeMultiplier = typeMultiplier * SeerBattle.getTypeMultiplier(skill.type, defender.type2)
    end
    baseDamage = baseDamage * typeMultiplier
    
    -- 随机因子 (85%-100%)
    local randomFactor = (math.random(85, 100) / 100)
    baseDamage = math.floor(baseDamage * randomFactor)
    
    return baseDamage
end

-- 打印技能信息 (调试用)
function SeerSkills.printInfo(skillId)
    local skill = SeerSkills.get(skillId)
    if not skill then
        print(string.format("\27[31m技能 ID:%d 不存在\27[0m", skillId))
        return
    end
    
    print(string.format("\27[36m========== 技能信息: %s (ID:%d) ==========\27[0m", skill.name, skill.id))
    print(string.format("类型: %s | 属性: %d", 
        skill.category == 1 and "物理" or (skill.category == 2 and "特殊" or "变化"), 
        skill.type))
    print(string.format("威力: %d | PP: %d | 命中: %d%%", skill.power, skill.pp, skill.accuracy))
    if skill.priority ~= 0 then
        print(string.format("优先度: %+d", skill.priority))
    end
    if skill.sideEffect and skill.sideEffect > 0 then
        print(string.format("附加效果 ID: %d", skill.sideEffect))
        if skill.effectData then
            print(string.format("  效果类型: %d | 描述: %s", 
                skill.effectData.eid, skill.effectData.desc))
        end
    end
    print("\27[36m" .. string.rep("=", 50) .. "\27[0m")
end

return SeerSkills
