-- 测试数据系统 - 验证 pets.xml、skills.xml、skill_effects.xml 之间的引用关系

local SeerPets = require "seer_pets"
local SeerSkills = require "seer_skills"
local SeerSkillEffects = require "seer_skill_effects"

print("\27[36m========================================\27[0m")
print("\27[36m   数据系统引用关系测试\27[0m")
print("\27[36m========================================\27[0m")

-- 1. 加载所有数据
print("\n\27[33m========== 步骤1: 加载数据 ==========\27[0m")
SeerPets.load()
SeerSkills.load()
SeerSkillEffects.load()

-- 2. 测试精灵 -> 技能的引用
print("\n\27[33m========== 步骤2: 测试精灵->技能引用 ==========\27[0m")
local testPetId = 1  -- 小火猴
local pet = SeerPets.get(testPetId)
if pet then
    print(string.format("精灵: %s (ID:%d)", pet.defName, pet.id))
    print(string.format("可学习技能数: %d", #pet.learnableMoves))
    
    -- 显示前5个技能
    for i = 1, math.min(5, #pet.learnableMoves) do
        local move = pet.learnableMoves[i]
        local skillData = SeerSkills.get(move.id)
        if skillData then
            print(string.format("  Lv%d: %s (ID:%d, 威力:%d)", 
                move.level, skillData.name, skillData.id, skillData.power))
        else
            print(string.format("  Lv%d: 技能ID:%d (未找到数据)", move.level, move.id))
        end
    end
else
    print("\27[31m精灵数据未找到\27[0m")
end

-- 3. 测试技能 -> 效果的引用
print("\n\27[33m========== 步骤3: 测试技能->效果引用 ==========\27[0m")
local testSkillId = 10002  -- 吸取
local skill = SeerSkills.get(testSkillId)
if skill then
    print(string.format("技能: %s (ID:%d)", skill.name, skill.id))
    print(string.format("威力:%d PP:%d 命中:%d%%", skill.power, skill.pp, skill.accuracy))
    
    if skill.sideEffect and skill.sideEffect > 0 then
        print(string.format("附加效果ID: %d", skill.sideEffect))
        
        local effect = SeerSkillEffects.get(skill.sideEffect)
        if effect then
            print(string.format("  效果类型(Eid): %d", effect.eid))
            print(string.format("  效果描述: %s", effect.desc))
            print(string.format("  效果参数: %s", effect.args))
        else
            print("\27[31m  效果数据未找到\27[0m")
        end
    else
        print("无附加效果")
    end
else
    print("\27[31m技能数据未找到\27[0m")
end

-- 4. 测试精灵进化链
print("\n\27[33m========== 步骤4: 测试精灵进化链 ==========\27[0m")
local chain = SeerPets.getEvolutionChain(testPetId)
print(string.format("精灵 %d 的进化链:", testPetId))
for i, petId in ipairs(chain) do
    local p = SeerPets.get(petId)
    if p then
        print(string.format("  %d. %s (ID:%d, 进化等级:%d)", 
            i, p.defName, p.id, p.evolvingLv))
    end
end

-- 5. 测试技能效果处理
print("\n\27[33m========== 步骤5: 测试技能效果处理 ==========\27[0m")
local attacker = {
    hp = 100,
    maxHp = 150,
    level = 50,
    atk = 80,
    def = 70,
    spAtk = 90,
    spDef = 75,
    spd = 85,
    type = 3,  -- 火系
    battleLv = {[0]=0, [1]=0, [2]=0, [3]=0, [4]=0, [5]=0}
}

local defender = {
    hp = 120,
    maxHp = 120,
    level = 50,
    atk = 75,
    def = 80,
    spAtk = 70,
    spDef = 85,
    spd = 60,
    type = 2,  -- 水系
    battleLv = {[0]=0, [1]=0, [2]=0, [3]=0, [4]=0, [5]=0}
}

-- 测试吸取技能
local damage = 40
local results = SeerSkillEffects.processEffect(1, attacker, defender, damage, "50")
print(string.format("使用吸取技能造成 %d 伤害", damage))
for _, result in ipairs(results) do
    if result.type == "heal" then
        print(string.format("  → 攻击方恢复 %d HP", result.amount))
    end
end

-- 6. 测试属性克制
print("\n\27[33m========== 步骤6: 测试属性克制 ==========\27[0m")
local SeerBattle = require "seer_battle"
local multiplier = SeerBattle.getTypeMultiplier(3, 2)  -- 火克水
print(string.format("火系攻击水系: %.1fx", multiplier))
multiplier = SeerBattle.getTypeMultiplier(2, 3)  -- 水克火
print(string.format("水系攻击火系: %.1fx", multiplier))
multiplier = SeerBattle.getTypeMultiplier(1, 2)  -- 草克水
print(string.format("草系攻击水系: %.1fx", multiplier))

-- 7. 统计数据
print("\n\27[33m========== 步骤7: 数据统计 ==========\27[0m")
local petCount = 0
local skillCount = 0
local effectCount = 0
local linkedSkillCount = 0

for _ in pairs(SeerPets.pets) do petCount = petCount + 1 end
for _, skill in pairs(SeerSkills.skills) do
    skillCount = skillCount + 1
    if skill.effectData then
        linkedSkillCount = linkedSkillCount + 1
    end
end
for _ in pairs(SeerSkillEffects.get(1) and {[1]=true} or {}) do effectCount = effectCount + 1 end

print(string.format("精灵总数: %d", petCount))
print(string.format("技能总数: %d", skillCount))
print(string.format("带效果的技能: %d (%.1f%%)", linkedSkillCount, linkedSkillCount * 100 / skillCount))

-- 8. 验证引用完整性
print("\n\27[33m========== 步骤8: 验证引用完整性 ==========\27[0m")
local brokenLinks = 0
local checkedLinks = 0

-- 检查精灵的技能引用
for petId, pet in pairs(SeerPets.pets) do
    for _, move in ipairs(pet.learnableMoves) do
        checkedLinks = checkedLinks + 1
        if not SeerSkills.get(move.id) then
            brokenLinks = brokenLinks + 1
            if brokenLinks <= 5 then  -- 只显示前5个错误
                print(string.format("\27[31m  ✗ 精灵 %s (ID:%d) 引用了不存在的技能 ID:%d\27[0m", 
                    pet.defName, petId, move.id))
            end
        end
    end
end

-- 检查技能的效果引用
for skillId, skill in pairs(SeerSkills.skills) do
    if skill.sideEffect and skill.sideEffect > 0 then
        checkedLinks = checkedLinks + 1
        if not SeerSkillEffects.get(skill.sideEffect) then
            brokenLinks = brokenLinks + 1
            if brokenLinks <= 5 then
                print(string.format("\27[31m  ✗ 技能 %s (ID:%d) 引用了不存在的效果 ID:%d\27[0m", 
                    skill.name, skillId, skill.sideEffect))
            end
        end
    end
end

if brokenLinks == 0 then
    print(string.format("\27[32m  ✓ 所有引用完整 (检查了 %d 个引用)\27[0m", checkedLinks))
else
    print(string.format("\27[33m  ! 发现 %d 个断开的引用 (共检查 %d 个)\27[0m", brokenLinks, checkedLinks))
end

print("\n\27[32m数据系统测试完成！\27[0m")
print("\27[36m========================================\27[0m")
