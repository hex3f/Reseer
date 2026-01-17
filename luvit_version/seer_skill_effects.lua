local fs = require("fs")
local xml_parser = require("./gameserver/xml_parser")

local SeerSkillEffects = {}
local effectsMap = {}

function SeerSkillEffects.load()
    print("Loading skill effects from data/skill_effects.xml...")
    local data = fs.readFileSync("data/skill_effects.xml")
    if not data then 
        print("Error: data/skill_effects.xml not found")
        return 
    end
    
    local parser = xml_parser:new()
    local tree = parser:parse(data)
    
    -- Root usually <SkillEffects>
    
    local count = 0
    -- <SkillEffects><NewSeIdx .../><NewSeIdx .../></SkillEffects>
    
    local children = tree.children
    if not children and tree.name == "NewSeIdx" then
        -- Handle case where parser returns single node if root? Unlikely with xml_parser logic.
        children = {tree}
    end
    
    if children then
        for _, node in ipairs(children) do
            if node.name == "NewSeIdx" and node.attributes then
                local id = tonumber(node.attributes.Idx)
                if id then
                    effectsMap[id] = {
                        id = id,
                        eid = tonumber(node.attributes.Eid),
                        args = node.attributes.Args or "",
                        des = node.attributes.Des 
                    }
                    count = count + 1
                end
            end
        end
    end
    print("Loaded " .. count .. " skill effect definitions.")
end

function SeerSkillEffects.get(id)
    return effectsMap[id]
end

-- 解析效果参数字符串 (格式: "arg1,arg2,arg3" 或 "arg1")
function SeerSkillEffects.parseArgs(argsStr)
    local args = {}
    if not argsStr or argsStr == "" then return args end
    
    for num in string.gmatch(argsStr, "([^,]+)") do
        table.insert(args, tonumber(num) or 0)
    end
    return args
end

-- 处理技能效果 (占位实现 - 可根据需要扩展)
-- 返回: 效果结果数组
function SeerSkillEffects.processEffect(effectId, attacker, defender, damage, argsStr)
    local results = {}
    local args = SeerSkillEffects.parseArgs(argsStr)
    
    -- 效果ID参考 skill_effects.xml 的 Eid 字段
    -- 这里提供常见效果的基础实现
    
    if effectId == 2 then
        -- 降低对方防御 (Eid=2)
        if defender.battleLv then
            local stages = args[1] or 1
            defender.battleLv[2] = math.max(-6, (defender.battleLv[2] or 0) - stages)
            table.insert(results, {type = "stat_down", stat = "defence", stages = stages})
        end
    elseif effectId == 3 then
        -- 提高自身攻击 (Eid=3)
        if attacker.battleLv then
            local stages = args[1] or 1
            attacker.battleLv[1] = math.min(6, (attacker.battleLv[1] or 0) + stages)
            table.insert(results, {type = "stat_up", stat = "attack", stages = stages})
        end
    elseif effectId == 4 then
        -- 提高自身防御 (Eid=4)
        if attacker.battleLv then
            local stages = args[1] or 1
            attacker.battleLv[2] = math.min(6, (attacker.battleLv[2] or 0) + stages)
            table.insert(results, {type = "stat_up", stat = "defence", stages = stages})
        end
    elseif effectId == 5 then
        -- 降低对方速度 (Eid=5)
        if defender.battleLv then
            local stages = args[1] or 1
            defender.battleLv[5] = math.max(-6, (defender.battleLv[5] or 0) - stages)
            table.insert(results, {type = "stat_down", stat = "speed", stages = stages})
        end
    elseif effectId == 7 then
        -- 恢复HP (Eid=7)
        local healPercent = args[1] or 50
        local healAmount = math.floor(attacker.maxHp * healPercent / 100)
        attacker.hp = math.min(attacker.maxHp, attacker.hp + healAmount)
        table.insert(results, {type = "heal", amount = healAmount})
    elseif effectId == 10 then
        -- 中毒 (Eid=10)
        local chance = args[1] or 30
        if math.random(100) <= chance then
            defender.status = defender.status or {}
            defender.status.poison = args[2] or 3
            table.insert(results, {type = "status", status = "poison", turns = args[2] or 3})
        end
    elseif effectId == 11 then
        -- 烧伤 (Eid=11)
        local chance = args[1] or 30
        if math.random(100) <= chance then
            defender.status = defender.status or {}
            defender.status.burn = args[2] or 3
            table.insert(results, {type = "status", status = "burn", turns = args[2] or 3})
        end
    elseif effectId == 12 then
        -- 麻痹 (Eid=12)
        local chance = args[1] or 30
        if math.random(100) <= chance then
            defender.status = defender.status or {}
            defender.status.paralysis = args[2] or 3
            table.insert(results, {type = "status", status = "paralysis", turns = args[2] or 3})
        end
    elseif effectId == 13 then
        -- 冰冻 (Eid=13)
        local chance = args[1] or 30
        if math.random(100) <= chance then
            defender.status = defender.status or {}
            defender.status.freeze = args[2] or 1
            table.insert(results, {type = "status", status = "freeze", turns = args[2] or 1})
        end
    elseif effectId == 14 then
        -- 睡眠 (Eid=14)
        local chance = args[1] or 30
        if math.random(100) <= chance then
            defender.status = defender.status or {}
            defender.status.sleep = args[2] or 2
            table.insert(results, {type = "status", status = "sleep", turns = args[2] or 2})
        end
    elseif effectId == 15 then
        -- 混乱 (Eid=15)
        local chance = args[1] or 30
        if math.random(100) <= chance then
            defender.status = defender.status or {}
            defender.status.confusion = args[2] or 3
            table.insert(results, {type = "status", status = "confusion", turns = args[2] or 3})
        end
    elseif effectId == 16 then
        -- 畏缩 (Eid=16)
        local chance = args[1] or 30
        if math.random(100) <= chance then
            defender.flinched = true
            table.insert(results, {type = "flinch"})
        end
    else
        -- 未实现的效果 - 静默忽略
        -- print(string.format("[SkillEffects] Unhandled effect ID: %d", effectId or 0))
    end
    
    return results
end

return SeerSkillEffects
