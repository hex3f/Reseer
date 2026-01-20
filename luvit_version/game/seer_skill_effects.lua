-- seer_skill_effects.lua
-- 赛尔号技能效果数据
-- 从 data/skill_effects.xml 加载完整效果信息

local XmlLoader = require("core/xml_loader")

local SeerSkillEffects = {}
local effectsMap = {}
SeerSkillEffects.loaded = false
SeerSkillEffects.count = 0

function SeerSkillEffects.load()
    if SeerSkillEffects.loaded then return end
    
    print("Loading skill effects from data/skill_effects.xml...")
    local tree, err = XmlLoader.load("data/skill_effects.xml")
    
    if not tree then 
        print("Error loading skill effects: " .. (err or "unknown error"))
        return 
    end
    
    local count = 0
    
    -- XML结构: <NewSe><NewSeIdx .../><NewSeIdx .../></NewSe>
    -- 需要遍历到 NewSe 节点下的 NewSeIdx
    local function processNode(node)
        if node.name == "NewSeIdx" and node.attributes then
            local id = tonumber(node.attributes.Idx)
            if id then
                effectsMap[id] = {
                    id = id,
                    eid = tonumber(node.attributes.Eid) or 0,
                    stat = tonumber(node.attributes.Stat) or 0,  -- 0=无效, 1=永久, 2=有限次
                    times = tonumber(node.attributes.Times) or 0, -- 可用次数
                    args = node.attributes.Args or "",
                    desc = node.attributes.Desc or node.attributes.Des or "",
                    desc2 = node.attributes.Desc2 or "",
                    itemId = tonumber(node.attributes.ItemId),
                }
                count = count + 1
            end
        end
        -- 递归处理子节点
        if node.children then
            for _, child in ipairs(node.children) do
                processNode(child)
            end
        end
    end
    
    processNode(tree)
    
    SeerSkillEffects.count = count
    SeerSkillEffects.loaded = true
    print("Loaded " .. count .. " skill effect definitions.")
end

function SeerSkillEffects.get(id)
    return effectsMap[id]
end

-- 解析效果参数字符串 (格式: "arg1 arg2 arg3" 或 "arg1,arg2")
function SeerSkillEffects.parseArgs(argsStr)
    local args = {}
    if not argsStr or argsStr == "" then return args end
    
    -- 支持空格和逗号分隔
    for num in string.gmatch(argsStr, "([%-]?%d+)") do
        table.insert(args, tonumber(num) or 0)
    end
    return args
end

-- 处理技能效果 (完整实现)
-- 返回: 效果结果数组
function SeerSkillEffects.processEffect(effectId, attacker, defender, damage, argsStr)
    local effectData = SeerSkillEffects.get(effectId)
    if not effectData then
        return {}
    end
    
    local results = {}
    local args = SeerSkillEffects.parseArgs(argsStr or effectData.args)
    local eid = effectData.eid
    
    -- 根据效果类型 (Eid) 处理不同的效果
    -- 参考 skill_effects.xml 中的 Eid 定义
    
    if eid == 1 then
        -- 吸血效果 - 恢复造成伤害的一定比例HP
        local healPercent = args[1] or 50
        local healAmount = math.floor(damage * healPercent / 100)
        if attacker.hp then
            attacker.hp = math.min(attacker.maxHp or attacker.hp, attacker.hp + healAmount)
            table.insert(results, {type = "heal", target = "attacker", amount = healAmount})
        end
        
    elseif eid == 2 then
        -- 降低对方能力等级
        local stat = args[1] or 1  -- 0=攻击, 1=防御, 2=特攻, 3=特防, 4=速度, 5=命中
        local stages = args[2] or 1
        if defender.battleLv then
            defender.battleLv[stat] = math.max(-6, (defender.battleLv[stat] or 0) - stages)
            table.insert(results, {type = "stat_down", target = "defender", stat = stat, stages = stages})
        end
        
    elseif eid == 3 then
        -- 提高自身能力等级
        local stat = args[1] or 0
        local stages = args[2] or 1
        if attacker.battleLv then
            attacker.battleLv[stat] = math.min(6, (attacker.battleLv[stat] or 0) + stages)
            table.insert(results, {type = "stat_up", target = "attacker", stat = stat, stages = stages})
        end
        
    elseif eid == 4 then
        -- 提高自身能力等级 (同eid=3，但可能有不同参数)
        local stat = args[1] or 1
        local stages = args[2] or 1
        if attacker.battleLv then
            attacker.battleLv[stat] = math.min(6, (attacker.battleLv[stat] or 0) + stages)
            table.insert(results, {type = "stat_up", target = "attacker", stat = stat, stages = stages})
        end
        
    elseif eid == 5 then
        -- 降低对方能力等级 (同eid=2，但可能有不同参数)
        local stat = args[1] or 4  -- 速度
        local chance = args[2] or 100
        local stages = args[3] or 1
        if math.random(100) <= chance then
            if defender.battleLv then
                defender.battleLv[stat] = math.max(-6, (defender.battleLv[stat] or 0) - stages)
                table.insert(results, {type = "stat_down", target = "defender", stat = stat, stages = stages})
            end
        end
        
    elseif eid == 6 then
        -- 反伤效果 - 自身受到一定比例伤害
        local recoilPercent = args[1] or 25
        local recoilDamage = math.floor(damage * recoilPercent / 100)
        if attacker.hp then
            attacker.hp = math.max(0, attacker.hp - recoilDamage)
            table.insert(results, {type = "recoil", target = "attacker", amount = recoilDamage})
        end
        
    elseif eid == 7 then
        -- 同生共死 - 使对方HP变为与自己相同
        if attacker.hp and defender.hp then
            defender.hp = attacker.hp
            table.insert(results, {type = "hp_equal", target = "defender"})
        end
        
    elseif eid == 8 then
        -- 手下留情 - 对方HP至少保留1
        if defender.hp and defender.hp <= 0 then
            defender.hp = 1
            table.insert(results, {type = "mercy", target = "defender"})
        end
        
    elseif eid == 9 then
        -- 愤怒 - 受到攻击后提升攻击力
        local minDamage = args[1] or 20
        local maxDamage = args[2] or 80
        if damage >= minDamage and damage <= maxDamage then
            if attacker.battleLv then
                attacker.battleLv[0] = math.min(6, (attacker.battleLv[0] or 0) + 1)
                table.insert(results, {type = "rage", target = "attacker"})
            end
        end
        
    elseif eid == 10 then
        -- 麻痹效果
        local chance = args[1] or 10
        if math.random(100) <= chance then
            if not defender.status or defender.status == 0 then
                defender.status = 0  -- 麻痹
                table.insert(results, {type = "status", target = "defender", status = "paralysis"})
            end
        end
        
    elseif eid == 11 then
        -- 束缚效果 - 持续伤害
        local chance = args[1] or 100
        if math.random(100) <= chance then
            defender.bound = true
            defender.boundTurns = 4
            table.insert(results, {type = "bound", target = "defender"})
        end
        
    elseif eid == 12 then
        -- 烧伤效果
        local chance = args[1] or 10
        if math.random(100) <= chance then
            if not defender.status or defender.status == 0 then
                defender.status = 2  -- 烧伤
                table.insert(results, {type = "status", target = "defender", status = "burn"})
            end
        end
        
    elseif eid == 13 then
        -- 中毒效果
        local chance = args[1] or 10
        if math.random(100) <= chance then
            if not defender.status or defender.status == 0 then
                defender.status = 1  -- 中毒
                table.insert(results, {type = "status", target = "defender", status = "poison"})
            end
        end
        
    elseif eid == 14 then
        -- 束缚效果 (同eid=11)
        local chance = args[1] or 100
        if math.random(100) <= chance then
            defender.bound = true
            defender.boundTurns = 4
            table.insert(results, {type = "bound", target = "defender"})
        end
        
    elseif eid == 15 then
        -- 畏缩效果
        local chance = args[1] or 10
        if math.random(100) <= chance then
            defender.flinch = true
            table.insert(results, {type = "flinch", target = "defender"})
        end
        
    elseif eid == 20 then
        -- 疲惫效果 - 下回合无法行动
        local chance = args[1] or 100
        local turns = args[2] or 1
        if math.random(100) <= chance then
            attacker.fatigue = true
            attacker.fatigueTurns = turns
            table.insert(results, {type = "fatigue", target = "attacker", turns = turns})
        end
        
    elseif eid == 29 then
        -- 畏缩效果 (同eid=15)
        local chance = args[1] or 30
        if math.random(100) <= chance then
            defender.flinch = true
            table.insert(results, {type = "flinch", target = "defender"})
        end
        
    elseif eid == 31 then
        -- 连续攻击
        local minHits = args[1] or 2
        local maxHits = args[2] or 5
        local hits = math.random(minHits, maxHits)
        table.insert(results, {type = "multi_hit", hits = hits})
        
    elseif eid == 33 then
        -- 消化不良 - 将对方最后使用的技能PP减少
        if defender.lastMove then
            table.insert(results, {type = "pp_reduce", target = "defender", moveId = defender.lastMove})
        end
        
    elseif eid == 34 then
        -- 克制 - 强制对方使用上次的技能
        local turns = args[1] or 2
        defender.encore = true
        defender.encoreTurns = turns
        table.insert(results, {type = "encore", target = "defender", turns = turns})
        
    elseif eid == 35 then
        -- 惩罚 - 对方能力提升越多，伤害越高
        local bonusDamage = 0
        if defender.battleLv then
            for _, lv in pairs(defender.battleLv) do
                if lv > 0 then
                    bonusDamage = bonusDamage + lv * 20
                end
            end
        end
        table.insert(results, {type = "punishment", bonusDamage = bonusDamage})
    end
    
    return results
end

-- 获取效果描述
function SeerSkillEffects.getDescription(effectId)
    local effectData = SeerSkillEffects.get(effectId)
    if not effectData then return "无效果" end
    return effectData.desc or "未知效果"
end

-- 打印效果信息 (调试用)
function SeerSkillEffects.printInfo(effectId)
    local effect = SeerSkillEffects.get(effectId)
    if not effect then
        print(string.format("\27[31m效果 ID:%d 不存在\27[0m", effectId))
        return
    end
    
    print(string.format("\27[36m========== 效果信息 (ID:%d) ==========\27[0m", effect.id))
    print(string.format("效果类型 (Eid): %d", effect.eid))
    print(string.format("状态: %d (0=无效, 1=永久, 2=有限次)", effect.stat))
    print(string.format("次数: %d", effect.times))
    print(string.format("参数: %s", effect.args))
    print(string.format("描述: %s", effect.desc))
    if effect.desc2 and effect.desc2 ~= "" then
        print(string.format("描述2: %s", effect.desc2))
    end
    if effect.itemId then
        print(string.format("关联道具: %d", effect.itemId))
    end
    print("\27[36m" .. string.rep("=", 50) .. "\27[0m")
end

return SeerSkillEffects
