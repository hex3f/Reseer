-- seer_skills.lua
-- 赛尔号技能数据
-- 从 data/skills.xml 加载完整技能信息

local SeerSkills = {}
SeerSkills.skills = {}
SeerSkills.loaded = false

-- 加载技能数据
function SeerSkills.load()
    if SeerSkills.loaded then return end
    
    local fs = require('fs')
    local xml_parser = require('./gameserver/xml_parser')
    
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
    SeerSkills.loaded = true
end

-- 获取技能数据
function SeerSkills.get(id)
    if not SeerSkills.loaded then
        SeerSkills.load()
    end
    return SeerSkills.skills[id]
end

-- 获取技能名称
function SeerSkills.getName(id)
    local skill = SeerSkills.get(id)
    return skill and skill.name or "未知技能"
end

-- 获取技能威力
function SeerSkills.getPower(id)
    local skill = SeerSkills.get(id)
    return skill and skill.power or 0
end

-- 获取技能PP
function SeerSkills.getPP(id)
    local skill = SeerSkills.get(id)
    return skill and skill.maxPP or 35
end

-- 获取技能类型
function SeerSkills.getType(id)
    local skill = SeerSkills.get(id)
    return skill and skill.type or 8
end

-- 获取技能分类
function SeerSkills.getCategory(id)
    local skill = SeerSkills.get(id)
    return skill and skill.category or 1
end

-- 检查技能是否有附加效果
function SeerSkills.hasEffect(id)
    local skill = SeerSkills.get(id)
    return skill and skill.sideEffect ~= nil
end

-- 获取技能附加效果
function SeerSkills.getEffect(id)
    local skill = SeerSkills.get(id)
    if skill then
        return skill.sideEffect, skill.sideEffectArg
    end
    return nil, nil
end

return SeerSkills
