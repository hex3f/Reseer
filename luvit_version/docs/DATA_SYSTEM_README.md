# 赛尔号数据系统 - 完整引用关系实现

## 概述

本系统实现了 pets.xml、skills.xml、skill_effects.xml 三个数据文件之间的完整引用关系，避免硬编码，支持动态加载和数据验证。

## 核心文件

### 1. seer_pets.lua - 精灵数据加载器
- 从 `data/spt.xml` 加载所有精灵数据
- 解析精灵的基础属性、种族值、进化链
- 解析精灵的可学习技能列表 (LearnableMoves)
- 建立精灵 → 技能的引用关系

**主要功能：**
- `SeerPets.load()` - 加载所有精灵数据
- `SeerPets.get(petId)` - 获取精灵数据
- `SeerPets.getLearnableMoves(petId, level)` - 获取可学习技能
- `SeerPets.canLearnMove(petId, moveId)` - 检查是否可学习某技能
- `SeerPets.getEvolutionChain(petId)` - 获取进化链
- `SeerPets.canEvolve(petId, level, hasItem)` - 检查是否可进化

### 2. seer_skills.lua - 技能数据加载器
- 从 `data/skills.xml` 加载所有技能数据
- 解析技能的威力、PP、命中率、属性等
- 解析技能的附加效果ID (SideEffect)
- 建立技能 → 效果的引用关系

**主要功能：**
- `SeerSkills.load()` - 加载所有技能数据
- `SeerSkills.get(skillId)` - 获取技能数据
- `SeerSkills.getFullInfo(skillId)` - 获取完整信息(含效果)
- `SeerSkills.isExclusiveMove(skillId, petId)` - 检查是否专属技能
- `SeerSkills.calculateBaseDamage(skill, attacker, defender)` - 计算伤害

### 3. seer_skill_effects.lua - 技能效果加载器
- 从 `data/skill_effects.xml` 加载所有效果数据
- 解析效果类型 (Eid)、参数 (Args)、描述
- 实现效果处理逻辑 (吸血、能力变化、异常状态等)

**主要功能：**
- `SeerSkillEffects.load()` - 加载所有效果数据
- `SeerSkillEffects.get(effectId)` - 获取效果数据
- `SeerSkillEffects.parseArgs(argsStr)` - 解析效果参数
- `SeerSkillEffects.processEffect(effectId, attacker, defender, damage, argsStr)` - 处理效果

### 4. game_config.lua - 游戏配置文件
- 集中管理游戏初始数据和参数
- 新玩家初始数据 (赛尔豆、精灵、物品)
- 系统通知配置 (登录通知、全局广播)
- 游戏参数 (战斗、经济、精灵、物品、好友)

## 数据引用关系

### 1. 核心主干关系：精灵 → 技能 → 效果

```
pets.xml (精灵表)
  └─ <LearnableMoves>
      └─ <Move ID="10001" Lv="5" />  ──┐
                                       │
                                       ↓
skills.xml (技能表)                    │
  └─ <Move ID="10001" Name="撞击"      │ (技能ID引用)
           SideEffect="1" />  ─────┐  │
                                   │  │
                                   ↓  │
skill_effects.xml (效果表)          │  │
  └─ <NewSeIdx Idx="1" Eid="1"      │  │
               Args="50" />  ←──────┘  │
                                       │
                            (效果ID引用)
```

### 2. 内部自引用：精灵进化链

```
pets.xml
  ├─ <Monster ID="1" EvolvesTo="2" />  ──→  <Monster ID="2" EvolvesFrom="1" EvolvesTo="3" />
  └─ <Monster ID="2" EvolvesTo="3" />  ──→  <Monster ID="3" EvolvesFrom="2" />
```

### 3. 反向引用：专属技能

```
skills.xml
  └─ <Move ID="50001" MonID="100" />  ──→  pets.xml: <Monster ID="100" />
                                           (验证专属技能归属)
```

### 4. 外部引用：道具系统

```
pets.xml
  └─ <Monster EvolvItem="5001" />  ──→  items.xml: <Item ID="5001" />

skill_effects.xml
  └─ <NewSeIdx ItemId="3001" />  ──→  items.xml: <Item ID="3001" />
```

## 使用示例

### 示例1：获取精灵的可学习技能

```lua
local SeerPets = require("seer_pets")
local SeerSkills = require("seer_skills")

-- 加载数据
SeerPets.load()
SeerSkills.load()

-- 获取小火猴的数据
local pet = SeerPets.get(1)
print("精灵:", pet.defName)

-- 获取可学习技能
for _, move in ipairs(pet.learnableMoves) do
    local skill = SeerSkills.get(move.id)
    print(string.format("Lv%d: %s (威力:%d)", 
        move.level, skill.name, skill.power))
end
```

### 示例2：处理技能效果

```lua
local SeerSkills = require("seer_skills")
local SeerSkillEffects = require("seer_skill_effects")

-- 加载数据
SeerSkills.load()
SeerSkillEffects.load()

-- 获取技能
local skill = SeerSkills.get(10002)  -- 吸取
print("技能:", skill.name)

-- 获取效果
if skill.effectData then
    print("效果:", skill.effectData.desc)
    
    -- 处理效果
    local results = SeerSkillEffects.processEffect(
        skill.sideEffect, 
        attacker, 
        defender, 
        damage, 
        skill.sideEffectArg
    )
    
    for _, result in ipairs(results) do
        if result.type == "heal" then
            print("恢复HP:", result.amount)
        end
    end
end
```

### 示例3：检查精灵进化

```lua
local SeerPets = require("seer_pets")

SeerPets.load()

-- 获取进化链
local chain = SeerPets.getEvolutionChain(1)
for i, petId in ipairs(chain) do
    local pet = SeerPets.get(petId)
    print(string.format("%d. %s (Lv%d进化)", 
        i, pet.defName, pet.evolvingLv))
end

-- 检查是否可以进化
local canEvolve, info = SeerPets.canEvolve(1, 16, false)
if canEvolve then
    print("可以进化为:", info)
else
    print("无法进化:", info)
end
```

## 效果类型 (Eid) 说明

| Eid | 效果类型 | 说明 |
|-----|---------|------|
| 1 | 吸血 | 恢复造成伤害的一定比例HP |
| 2 | 降低能力 | 降低对方能力等级 |
| 3 | 提升能力 | 提升自身能力等级 |
| 6 | 反伤 | 自身受到一定比例伤害 |
| 7 | 同生共死 | 使对方HP变为与自己相同 |
| 8 | 手下留情 | 对方HP至少保留1 |
| 10 | 麻痹 | 使对方陷入麻痹状态 |
| 11 | 束缚 | 持续伤害 |
| 12 | 烧伤 | 使对方陷入烧伤状态 |
| 13 | 中毒 | 使对方陷入中毒状态 |
| 15 | 畏缩 | 使对方畏缩 |
| 20 | 疲惫 | 下回合无法行动 |
| 31 | 连续攻击 | 连续攻击2-5次 |
| 34 | 克制 | 强制对方使用上次的技能 |
| 35 | 惩罚 | 对方能力提升越多，伤害越高 |

## 配置文件说明

### game_config.lua

**新玩家初始数据：**
- `GameConfig.newPlayer` - 初始属性、货币、VIP等
- `GameConfig.starterPets` - 初始赠送的精灵
- `GameConfig.starterItems` - 初始赠送的物品

**系统通知：**
- `GameConfig.loginNotices` - 登录时发送的通知
- `GameConfig.globalNotices` - 全局广播通知

**游戏参数：**
- `GameConfig.battle` - 战斗相关参数
- `GameConfig.economy` - 经济系统参数
- `GameConfig.pet` - 精灵系统参数
- `GameConfig.item` - 物品系统参数
- `GameConfig.friend` - 好友系统参数

## 数据完整性验证

系统提供了完整的数据验证功能：

1. **引用完整性检查** - 验证所有ID引用是否有效
2. **技能效果链接** - 自动链接技能与效果数据
3. **进化链验证** - 检查进化链的完整性
4. **专属技能验证** - 验证专属技能的归属

## 优势

1. **无硬编码** - 所有数据从XML文件动态加载
2. **自动引用** - 系统自动建立数据之间的引用关系
3. **易于维护** - 修改XML文件即可更新游戏数据
4. **类型安全** - 提供完整的数据验证和错误检查
5. **高性能** - 数据加载后缓存，避免重复解析
6. **可扩展** - 易于添加新的数据类型和引用关系

## 注意事项

1. 数据文件必须放在 `data/` 目录下
2. 首次使用前必须调用 `.load()` 方法
3. 修改XML文件后需要重启服务器
4. 确保所有ID引用的完整性
5. 效果参数格式：空格或逗号分隔的数字

## 测试

运行测试脚本验证数据系统：

```bash
cd luvit_version
./luvit.exe test_data_system.lua
```

测试内容包括：
- 数据加载
- 精灵→技能引用
- 技能→效果引用
- 进化链
- 效果处理
- 属性克制
- 引用完整性验证
