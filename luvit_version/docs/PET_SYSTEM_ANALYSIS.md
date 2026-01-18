# 精灵系统工作原理分析

## 问题回顾
最初认为精灵数据应该在LOGIN_IN响应中发送（因为UserInfo.as中有`PetManager.initData()`调用），但实际测试发现发送精灵数据会导致客户端无法进入游戏。

## 官服工作流程

### 1. 登录阶段 (CMD 1001 - LOGIN_IN)
```lua
-- 登录响应中 petNum = 0
petNum (4 bytes) = 0
-- 不发送任何精灵数据
```

**原因**：
- 精灵数据量大（每个精灵154字节），登录时发送会增加响应包大小
- 客户端采用按需加载策略，只在需要时才请求精灵数据

### 2. 打开精灵背包 (CMD 2303 - GET_PET_LIST)
客户端发送请求：
```
CMD: 2303
Body: (空)
```

服务器响应：
```lua
petCount (4 bytes)
for each pet:
    id (4 bytes)
    catchTime (4 bytes)  -- 精灵唯一标识
    skinID (4 bytes)
-- 每个精灵 12 bytes
```

**实现位置**：`localgameserver.lua:handleGetPetList()`

### 3. 查看精灵详情 (CMD 2301 - GET_PET_INFO)
客户端发送请求：
```
CMD: 2301
Body: catchTime (4 bytes)  -- 要查询的精灵ID
```

服务器响应完整的PetInfo结构（154字节）：
```lua
id(4) + name(16) + dv(4) + nature(4) + level(4) + exp(4) + lvExp(4) + nextLvExp(4)
+ hp(4) + maxHp(4) + attack(4) + defence(4) + s_a(4) + s_d(4) + speed(4)
+ ev_hp(4) + ev_attack(4) + ev_defence(4) + ev_sa(4) + ev_sd(4) + ev_sp(4)
+ skillNum(4) + skills[4]*(id(4)+pp(4)) + catchTime(4) + catchMap(4) + catchRect(4) + catchLevel(4)
+ effectCount(2) + skinID(4)
```

**实现位置**：`localgameserver.lua:handleGetPetInfo()`

## 关键发现

### PetSkillInfo结构
客户端`PetSkillInfo.as`只读取2个字段：
```actionscript
this._id = param1.readUnsignedInt();      // id (4 bytes)
this.pp = param1.readUnsignedInt();       // pp (4 bytes)
```

**重要**：`maxPP`不是从服务器读取的，而是通过`SkillXMLInfo.getPP(this.id)`从本地配置文件获取！

### 为什么LOGIN_IN中发送精灵数据会失败？
之前的实现错误地在技能序列化中包含了`maxPP`字段：
```lua
-- ❌ 错误的实现（每个技能12字节）
skillId (4) + skillPP (4) + skillMaxPP (4)
```

正确的实现应该是：
```lua
-- ✓ 正确的实现（每个技能8字节）
skillId (4) + skillPP (4)
```

多出的4字节 × 4个技能槽 = 16字节，导致后续所有数据错位，客户端解析失败。

## 当前实现状态

### ✅ 已实现并工作正常
1. **CMD 1001 (LOGIN_IN)**：`petNum = 0`，不发送精灵数据
2. **CMD 2303 (GET_PET_LIST)**：返回精灵列表（id + catchTime + skinID）
3. **CMD 2301 (GET_PET_INFO)**：返回单个精灵的完整信息

### ✅ 精灵序列化模块
- `seer_pet_calculator.lua`：精灵属性计算（HP、攻击、防御等）
- `seer_pet_serializer.lua`：精灵数据序列化（已修复技能字段问题）

### 📝 备注
虽然精灵序列化模块已经完善，但由于官服采用按需加载策略，LOGIN_IN响应中不需要发送精灵数据。这些模块可以用于：
- CMD 2301 (GET_PET_INFO) 的实现优化
- 未来可能的批量精灵数据传输需求
- 其他需要精灵数据序列化的场景

## 相关文件
- `luvit_version/gameserver/localgameserver.lua` - 精灵命令处理器
- `luvit_version/gameserver/seer_login_response.lua` - 登录响应生成
- `luvit_version/seer_pet_calculator.lua` - 精灵属性计算
- `luvit_version/seer_pet_serializer.lua` - 精灵数据序列化
- `front-end scripts/NieoCore scripts/com/robot/core/info/pet/PetInfo.as` - 客户端精灵信息类
- `front-end scripts/NieoCore scripts/com/robot/core/info/pet/PetSkillInfo.as` - 客户端技能信息类
- `front-end scripts/NieoCore scripts/com/robot/core/manager/PetManager.as` - 客户端精灵管理器

## 经验教训
1. **不要假设协议格式**：必须仔细阅读客户端源码，了解实际的数据读取方式
2. **按需加载是常见策略**：大量数据通常不在登录时一次性发送，而是按需请求
3. **字段对齐很重要**：多一个或少一个字段都会导致后续数据错位
4. **区分网络数据和本地数据**：某些字段（如maxPP）可能是客户端从配置文件计算的
