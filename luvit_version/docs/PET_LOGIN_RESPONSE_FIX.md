# 登录响应中的精灵数据修复

## 问题描述

用户打开精灵背包时没有数据，客户端也没有发送 GET_PET_LIST 请求。

**原因**：登录响应中 `petNum = 0`，客户端认为没有精灵，所以不显示精灵背包。

## 根本原因分析

### 1. 客户端行为
客户端在登录时就初始化精灵数据（`PetManager.initData()`），**不会**在打开精灵背包时再发送请求。

```actionscript
// UserInfo.as line 894-900
param1.petNum = param2.readUnsignedInt();  // 读取 petNum
PetManager.initData(param2, param1.petNum);  // 初始化精灵数据
```

### 2. 服务器问题
- 服务器发送 `petNum = 0`，导致客户端认为没有精灵
- 用户数据库中有精灵数据，但缺少 `skills` 数组

### 3. PetInfo 结构（完整模式，170字节）
```
- id (4 bytes)
- name (16 bytes)
- dv, nature, level, exp (4*4 bytes)
- lvExp, nextLvExp (2*4 bytes)
- hp, maxHp, attack, defence, s_a, s_d, speed (7*4 bytes)
- ev_hp, ev_attack, ev_defence, ev_sa, ev_sd, ev_sp (6*4 bytes)
- skillNum (4 bytes)
- 4 skill slots: id, pp, maxPP (4*3*4 bytes)
- catchTime, catchMap, catchRect, catchLevel (4*4 bytes)
- effectCount (2 bytes)
- skinID (4 bytes)
```

## 解决方案

### 1. 创建精灵属性计算模块 (`seer_pet_calculator.lua`)

计算精灵的各项属性值，基于：
- 种族值（从 `seer_pets.lua` 获取）
- 个体值（DV，0-31）
- 努力值（EV）
- 等级

**公式**：
- HP = floor((种族值 * 2 + 个体值 + 努力值 / 4) * 等级 / 100) + 等级 + 10
- 其他属性 = floor((种族值 * 2 + 个体值 + 努力值 / 4) * 等级 / 100) + 5

**修复**：
- 统一属性名称映射：`attack`→`atk`, `defence`→`def`, `s_a`→`spAtk`, `s_d`→`spDef`, `speed`→`spd`

### 2. 创建精灵序列化模块 (`seer_pet_serializer.lua`)

将精灵数据序列化为客户端期望的二进制格式。

**功能**：
- `serializePetInfo(pet, fullInfo)` - 序列化单个精灵
- `serializePets(pets, fullInfo)` - 序列化多个精灵
- `getDefaultSkills(petId, level)` - 自动生成默认技能

**自动生成技能**：
- 从 `SeerPets.getLearnableMoves()` 获取可学习技能
- 取最后学会的4个技能（最新技能）
- 从技能数据库获取 PP 值
- 创建技能对象：`{id, pp, maxPP}`

### 3. 更新登录响应 (`seer_login_response.lua`)

```lua
local pets = user.pets or {}
local PetSerializer = require('./seer_pet_serializer')

-- petNum (4 bytes)
local petBuf = buffer.Buffer:new(4)
petBuf:wuint(1, #pets)
parts[#parts+1] = tostring(petBuf):sub(1, 4)

-- 序列化每个精灵的完整信息
if #pets > 0 then
    local petData = PetSerializer.serializePets(pets, true) -- true = 完整信息
    parts[#parts+1] = petData
    print(string.format("\27[32m[LOGIN] 加载了 %d 个精灵\27[0m", #pets))
end
```

### 4. 禁用协议大小验证

由于精灵数据是动态的，禁用了 LOGIN_IN 的大小验证：

```lua
-- protocol_validator.lua
if cmdId == 1001 then
    -- LOGIN_IN 响应大小是动态的（取决于精灵数量、任务数量等）
    -- 不进行大小验证
    return true
end
```

## 实施状态

- ✅ 创建了 `seer_pet_calculator.lua`
- ✅ 创建了 `seer_pet_serializer.lua`
- ✅ 更新了 `seer_login_response.lua` 使用 PetSerializer
- ✅ 修复了属性名称映射问题
- ✅ 实现了自动生成默认技能
- ✅ 禁用了 LOGIN_IN 大小验证
- ✅ 服务器启动成功，所有模块加载正常
- ⏳ 待测试：使用客户端登录，验证精灵背包显示

## 测试结果

### 服务器启动
```
[数据加载] ✓ 精灵数据加载成功 (2176 个精灵)
[数据加载] ✓ 物品数据加载成功 (4329 个物品)
[数据加载] ✓ 技能数据加载成功 (5612 个技能)
[数据加载] ✓ 技能效果数据加载成功 (148 个效果)
[22:49:01] [LocalGame] ✓ 本地游戏服务器启动在端口 5000
```

### 用户精灵数据示例
```json
"pets":[{
  "exp":0,
  "level":5,
  "name":"",
  "nature":24,
  "dv":31,
  "catchTime":1768539136,
  "id":7
}]
```

**注意**：精灵数据缺少 `skills` 数组，序列化器会自动生成默认技能。

## 相关文件

- `luvit_version/seer_pet_calculator.lua` - 精灵属性计算
- `luvit_version/seer_pet_serializer.lua` - 精灵数据序列化
- `luvit_version/gameserver/seer_login_response.lua` - 登录响应生成
- `luvit_version/protocol_validator.lua` - 协议验证
- `luvit_version/seer_pets.lua` - 精灵数据库
- `luvit_version/seer_skills.lua` - 技能数据库
- `front-end scripts/NieoCore scripts/com/robot/core/info/pet/PetInfo.as` - 客户端 PetInfo 类

## 实施日期

2026年1月17日
