-- 精灵信息序列化模块
-- 用于将精灵数据序列化为客户端期望的格式

local PetCalculator = require('game/seer_pet_calculator')
local SeerSkills = require('game/seer_skills')
local SeerPets = require('game/seer_pets')

local PetSerializer = {}

-- 写入32位无符号整数（大端序 Big-Endian）
local function writeUInt32BE(value)
    local b4 = bit.band(value, 0xFF)
    local b3 = bit.band(bit.rshift(value, 8), 0xFF)
    local b2 = bit.band(bit.rshift(value, 16), 0xFF)
    local b1 = bit.band(bit.rshift(value, 24), 0xFF)
    return string.char(b1, b2, b3, b4)
end

-- 写入16位无符号整数（大端序 Big-Endian）
local function writeUInt16BE(value)
    local b2 = bit.band(value, 0xFF)
    local b1 = bit.band(bit.rshift(value, 8), 0xFF)
    return string.char(b1, b2)
end

-- 获取精灵的默认技能
local function getDefaultSkills(petId, level)
    local SeerPets = require('./seer_pets')
    local moves = SeerPets.getLearnableMoves(petId, level)
    
    -- 获取最后学会的4个技能
    local skills = {}
    local startIdx = math.max(1, #moves - 3)
    for i = startIdx, #moves do
        local moveId = moves[i].id
        local skillData = SeerSkills.get(moveId)
        table.insert(skills, {
            id = moveId,
            pp = skillData and skillData.maxPP or 20,
            maxPP = skillData and skillData.maxPP or 20
        })
    end
    
    return skills
end

-- 序列化单个精灵的完整信息
-- 返回字符串
function PetSerializer.serializePetInfo(pet, fullInfo)
    fullInfo = fullInfo == nil and true or fullInfo
    
    local petId = pet.id or 0
    local name = pet.name or ""
    
    -- 如果name为空，使用精灵的默认名字
    if name == "" then
        local SeerPets = require('./seer_pets')
        local petData = SeerPets.get(petId)
        if petData and petData.defName then
            name = petData.defName
        end
    end
    
    local dv = pet.dv or 31
    local nature = pet.nature or 0
    local level = pet.level or 1
    local exp = pet.exp or 0
    local catchTime = pet.catchTime or os.time()
    local catchMap = pet.catchMap or 0
    local catchLevel = pet.catchLevel or level  -- 默认使用当前等级
    local skinID = pet.skinID or 0
    
    -- 计算属性
    local stats = PetCalculator.calculateAllStats(pet)
    
    -- 努力值
    local ev_hp = pet.ev_hp or 0
    local ev_attack = pet.ev_attack or 0
    local ev_defence = pet.ev_defence or 0
    local ev_sa = pet.ev_sa or 0
    local ev_sd = pet.ev_sd or 0
    local ev_sp = pet.ev_sp or 0
    
    -- 技能数据 - 如果没有技能，自动添加默认技能
    local skills = pet.skills or {}
    if #skills == 0 then
        skills = getDefaultSkills(petId, level)
        print(string.format("\27[33m[PetSerializer] 精灵 %d 没有技能，自动添加 %d 个默认技能\27[0m", petId, #skills))
    end
    
    local skillNum = #skills
    if skillNum > 4 then skillNum = 4 end
    
    -- 使用字符串拼接构建数据
    local parts = {}
    
    -- id (4 bytes)
    table.insert(parts, writeUInt32BE(petId))
    
    if fullInfo then
        -- name (16 bytes)
        local nameBytes = name:sub(1, 16)
        while #nameBytes < 16 do
            nameBytes = nameBytes .. "\0"
        end
        table.insert(parts, nameBytes)
        
        -- dv (4 bytes)
        table.insert(parts, writeUInt32BE(dv))
        
        -- nature (4 bytes)
        table.insert(parts, writeUInt32BE(nature))
        
        -- level (4 bytes)
        table.insert(parts, writeUInt32BE(level))
        
        -- exp (4 bytes)
        table.insert(parts, writeUInt32BE(exp))
        
        -- lvExp (4 bytes)
        table.insert(parts, writeUInt32BE(stats.lvExp))
        
        -- nextLvExp (4 bytes)
        table.insert(parts, writeUInt32BE(stats.nextLvExp))
        
        -- hp (4 bytes)
        table.insert(parts, writeUInt32BE(stats.hp))
        
        -- maxHp (4 bytes)
        table.insert(parts, writeUInt32BE(stats.maxHp))
        
        -- attack (4 bytes)
        table.insert(parts, writeUInt32BE(stats.attack))
        
        -- defence (4 bytes)
        table.insert(parts, writeUInt32BE(stats.defence))
        
        -- s_a (4 bytes)
        table.insert(parts, writeUInt32BE(stats.s_a))
        
        -- s_d (4 bytes)
        table.insert(parts, writeUInt32BE(stats.s_d))
        
        -- speed (4 bytes)
        table.insert(parts, writeUInt32BE(stats.speed))
        
        -- ev_hp (4 bytes)
        table.insert(parts, writeUInt32BE(ev_hp))
        
        -- ev_attack (4 bytes)
        table.insert(parts, writeUInt32BE(ev_attack))
        
        -- ev_defence (4 bytes)
        table.insert(parts, writeUInt32BE(ev_defence))
        
        -- ev_sa (4 bytes)
        table.insert(parts, writeUInt32BE(ev_sa))
        
        -- ev_sd (4 bytes)
        table.insert(parts, writeUInt32BE(ev_sd))
        
        -- ev_sp (4 bytes)
        table.insert(parts, writeUInt32BE(ev_sp))
    else
        -- 简化模式：只发送 level, hp, maxHp
        table.insert(parts, writeUInt32BE(level))
        table.insert(parts, writeUInt32BE(stats.hp))
        table.insert(parts, writeUInt32BE(stats.maxHp))
    end
    
    -- skillNum (4 bytes)
    table.insert(parts, writeUInt32BE(skillNum))
    
    -- 4个技能槽（即使 skillNum < 4）
    -- 注意：客户端 PetSkillInfo 只读取 id 和 pp，不读取 maxPP！
    for i = 1, 4 do
        local skill = skills[i]
        if skill then
            local skillId = skill.id or 0
            local skillPP = skill.pp
            
            -- 如果没有 PP 信息，从技能数据库获取
            if not skillPP then
                local skillData = SeerSkills.get(skillId)
                if skillData then
                    skillPP = skillData.pp or 20
                else
                    skillPP = 20
                end
            end
            
            table.insert(parts, writeUInt32BE(skillId))
            table.insert(parts, writeUInt32BE(skillPP))
        else
            -- 空技能槽
            table.insert(parts, writeUInt32BE(0))
            table.insert(parts, writeUInt32BE(0))
        end
    end
    
    -- catchTime (4 bytes)
    table.insert(parts, writeUInt32BE(catchTime))
    
    -- catchMap (4 bytes)
    table.insert(parts, writeUInt32BE(catchMap))
    
    -- catchRect (4 bytes)
    table.insert(parts, writeUInt32BE(0)) -- 默认为0
    
    -- catchLevel (4 bytes)
    table.insert(parts, writeUInt32BE(catchLevel))
    
    if fullInfo then
        -- effectCount (2 bytes)
        table.insert(parts, writeUInt16BE(0)) -- 暂时不支持效果
    end
    
    -- skinID (4 bytes)
    table.insert(parts, writeUInt32BE(skinID))
    
    return table.concat(parts)
end

-- 序列化多个精灵
function PetSerializer.serializePets(pets, fullInfo)
    local parts = {}
    for _, pet in ipairs(pets) do
        table.insert(parts, PetSerializer.serializePetInfo(pet, fullInfo))
    end
    return table.concat(parts)
end

return PetSerializer
