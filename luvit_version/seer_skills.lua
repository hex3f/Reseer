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
    local path = require('path')
    
    local skillsPath = path.join(path.dirname(module.path), 'data', 'skills.xml')
    local content = fs.readFileSync(skillsPath)
    
    if not content then
        print("\27[31m[SeerSkills] 无法读取技能数据文件\27[0m")
        return
    end
    
    -- 解析XML中的技能数据
    -- move_flag 说明:
    -- 1. MustHit: 是否必中
    -- 4. CritAtkFirst: 先出手时必定致命一击
    -- 5. CritAtkSecond: 后出手时必定致命一击
    -- 6. CritSelfHalfHp: 自身体力低于一半时必定致命一击
    -- 7. CritFoeHalfHp: 对方体力低于一半时必定致命一击
    -- 8. DmgBindLv: 伤害等于自身等级
    -- 9. PwrBindDv: 威力=个体值*5
    -- 10. PwrDouble: 对方异常状态时威力翻倍
    for move in content:gmatch('<Move[^>]+/>') do
        local id = tonumber(move:match('ID="(%d+)"'))
        local name = move:match('Name="([^"]*)"')
        local category = tonumber(move:match('Category="(%d+)"')) or 1
        local type = tonumber(move:match('Type="(%d+)"')) or 8
        local power = tonumber(move:match('Power="(%d+)"')) or 0
        local maxPP = tonumber(move:match('MaxPP="(%d+)"')) or 35
        local accuracy = tonumber(move:match('Accuracy="(%d+)"')) or 100
        local critRate = tonumber(move:match('CritRate="(%d+)"')) or 1
        local priority = tonumber(move:match('Priority="([%-]?%d+)"')) or 0
        local mustHit = tonumber(move:match('MustHit="(%d+)"')) or 0
        local sideEffect = tonumber(move:match('SideEffect="(%d+)"'))
        local sideEffectArg = move:match('SideEffectArg="([^"]*)"')
        
        -- 解析额外的 move_flag
        local critAtkFirst = tonumber(move:match('CritAtkFirst="(%d+)"')) or 0
        local critAtkSecond = tonumber(move:match('CritAtkSecond="(%d+)"')) or 0
        local critSelfHalfHp = tonumber(move:match('CritSelfHalfHp="(%d+)"')) or 0
        local critFoeHalfHp = tonumber(move:match('CritFoeHalfHp="(%d+)"')) or 0
        local dmgBindLv = tonumber(move:match('DmgBindLv="(%d+)"')) or 0
        local pwrBindDv = tonumber(move:match('PwrBindDv="(%d+)"'))  -- 可能是1或2
        local pwrDouble = tonumber(move:match('PwrDouble="(%d+)"')) or 0
        
        if id then
            SeerSkills.skills[id] = {
                id = id,
                name = name or "未知技能",
                category = category,  -- 1=物理, 2=特殊, 4=状态
                type = type,          -- 属性类型: 1草,2水,3火,4飞行,5电,6机械,7地面,8普通,9冰,10超能,11战斗,12光,13暗影,14神秘,15龙,16圣灵
                power = power,
                pp = maxPP,
                maxPP = maxPP,
                accuracy = accuracy,
                critRate = critRate,  -- 暴击率 x/16
                priority = priority,
                mustHit = mustHit == 1,
                sideEffect = sideEffect,
                sideEffectArg = sideEffectArg,
                -- move_flag 特殊效果
                critAtkFirst = critAtkFirst == 1,    -- 先出手必暴击
                critAtkSecond = critAtkSecond == 1,  -- 后出手必暴击
                critSelfHalfHp = critSelfHalfHp == 1, -- 自身HP<50%必暴击
                critFoeHalfHp = critFoeHalfHp == 1,   -- 对方HP<50%必暴击
                dmgBindLv = dmgBindLv == 1,          -- 伤害=等级
                pwrBindDv = pwrBindDv,               -- 威力=个体值*倍率 (1或2)
                pwrDouble = pwrDouble == 1           -- 对方异常时威力翻倍
            }
        end
    end
    
    local count = 0
    for _ in pairs(SeerSkills.skills) do count = count + 1 end
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
