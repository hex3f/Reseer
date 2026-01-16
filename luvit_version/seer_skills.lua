-- seer_skills.lua
-- 赛尔号技能数据

local SeerSkills = {}
SeerSkills.skills = {}
SeerSkills.loaded = false

-- 加载技能数据
function SeerSkills.load()
    if SeerSkills.loaded then return end
    
    local fs = require('fs')
    local path = require('path')
    
    local skillsPath = path.join(path.dirname(module.path), '..', 'data', 'skills.xml')
    local content = fs.readFileSync(skillsPath)
    
    if not content then
        print("\27[31m[SeerSkills] 无法读取技能数据文件\27[0m")
        return
    end
    
    -- 解析XML中的技能数据
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
        
        if id then
            SeerSkills.skills[id] = {
                id = id,
                name = name or "未知技能",
                category = category,  -- 1=物理, 2=特殊, 4=状态
                type = type,          -- 属性类型
                power = power,
                maxPP = maxPP,
                accuracy = accuracy,
                critRate = critRate,
                priority = priority
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

return SeerSkills
