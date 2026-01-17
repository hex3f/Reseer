# 协议修复总结

## 修复的问题

### 1. CMD 2505 (NOTE_USE_SKILL) - 技能使用通知
**问题**: 期望16字节，实际180字节
**原因**: 错误理解了客户端数据结构
**修复**: 
- 客户端定义: `UseSkillInfo` 包含两个 `AttackValue`
- 每个 `AttackValue` 包含约90字节数据
- 正确大小: 180字节（动态，取决于技能数量）

**AttackValue结构** (约90字节):
```
userID(4) + skillID(4) + atkTimes(4) + lostHP(4) + gainHP(4) + remainHp(4) + maxHp(4) + state(4)
+ skillCount(4) + skills[动态] + isCrit(4) + status[20] + battleLv[6] + maxShield(4) + curShield(4) + petType(4)
```

### 2. CMD 2506 (FIGHT_OVER) - 战斗结束
**问题**: 期望12字节，实际28字节
**原因**: 遗漏了额外的统计字段
**修复**:
```
reason(4) + winnerID(4) + twoTimes(4) + threeTimes(4) + autoFightTimes(4) + energyTimes(4) + learnTimes(4)
= 28字节
```

### 3. CMD 2507/2508 映射错误
**问题**: CMD编号映射混乱
**修复**:
- CMD 2507: NOTE_UPDATE_SKILL (技能更新通知)
- CMD 2508: NOTE_UPDATE_PROP (属性更新通知，80字节)

### 4. 添加缺失的协议定义

新增以下协议：

#### 地图相关
- CMD 2001: ENTER_MAP (160字节)
- CMD 2002: LEAVE_MAP (4字节)
- CMD 2003: LIST_MAP_PLAYER (动态)
- CMD 2101: PEOPLE_WALK (0字节)

#### 任务相关
- CMD 2201: ACCEPT_TASK (4字节)
- CMD 2202: COMPLETE_TASK (动态)

#### 物品相关
- CMD 2601: ITEM_BUY (0字节)

#### 其他
- CMD 8004: GET_BOSS_MONSTER (24字节)

## 验证结果

修复后的验证输出示例：
```
✓ [ITEM_LIST] 包体大小正确: 52字节
✓ [USE_SKILL] 包体大小正确: 0字节
✓ [GET_PET_INFO] 包体大小正确: 154字节
✓ [ACCEPT_TASK] 包体大小正确: 4字节
✓ [NOTE_USE_SKILL] 包体大小正确: 180字节
✓ [FIGHT_OVER] 包体大小正确: 28字节
✓ [NOTE_UPDATE_PROP] 包体大小正确: 80字节
✓ [GET_BOSS_MONSTER] 包体大小正确: 24字节
```

## 当前协议覆盖率

已定义协议: **24个**

### 按类别统计:
- 任务相关: 5个 (100, 101, 102, 2201, 2202)
- 地图相关: 4个 (2001, 2002, 2003, 2101)
- 精灵相关: 3个 (2301, 2303, 2304)
- 战斗相关: 3个 (2404, 2405, 2411)
- 战斗通知: 5个 (2503, 2504, 2505, 2506, 2507, 2508)
- 物品相关: 2个 (2601, 2605)
- 其他: 2个 (8004)

## 待补充的协议

根据客户端扫描，还有约**42个**常用协议需要定义：

### 高优先级（核心功能）:
- CMD 2302: MODIFY_PET_NAME (修改精灵名字)
- CMD 2306: PET_CURE (治疗精灵)
- CMD 2307: PET_STUDY_SKILL (学习技能)
- CMD 2308: PET_DEFAULT (设置默认精灵)
- CMD 2406: USE_PET_ITEM (战斗中使用道具)
- CMD 2407: CHANGE_PET (切换精灵)
- CMD 2409: CATCH_MONSTER (捕捉精灵)
- CMD 2410: ESCAPE_FIGHT (逃跑)

### 中优先级（扩展功能）:
- CMD 2102: CHAT (聊天)
- CMD 2602: ITEM_SALE (出售物品)
- CMD 2603: ITEM_REPAIR (修理物品)
- CMD 2604: CHANGE_CLOTH (更换服装)
- CMD 2061: CHANG_NICK_NAME (修改昵称)

### 低优先级（高级功能）:
- CMD 2314: PET_EVOLVTION (精灵进化)
- CMD 2315: PET_HATCH (孵化精灵)
- CMD 2351: PET_FUSION (精灵融合)
- 各种NONO相关协议 (9xxx系列)
- 战队相关协议 (29xx系列)

## 如何添加新协议

1. **查找客户端Info类**:
   ```
   front-end scripts/NieoCore scripts/com/robot/core/info/
   ```

2. **分析数据结构**:
   - 查看构造函数中的 `readUnsignedInt()`, `readUTFBytes()` 等调用
   - 计算总字节数

3. **添加到protocol_validator.lua**:
   ```lua
   [cmdId] = {
       name = "PROTOCOL_NAME",
       minSize = 固定大小或最小大小,
       maxSize = 固定大小或nil（动态）,
       description = "字段说明"
   }
   ```

4. **测试验证**:
   ```bash
   .\luvit.exe test_protocol_validator.lua
   ```

## 注意事项

1. **动态大小协议**: 对于包含数组或列表的协议，使用 `calculateSize` 函数
2. **字节对齐**: 确保所有字段按正确顺序计算
3. **客户端源码**: 始终以客户端Info类为准，不要猜测
4. **测试验证**: 每次添加新协议后运行测试脚本

## 相关文件

- `protocol_validator.lua` - 协议验证器主文件
- `test_protocol_validator.lua` - 测试脚本
- `scan_protocols.lua` - 协议扫描脚本
- `PROTOCOL_VALIDATOR_README.md` - 详细使用文档
- `front-end scripts/NieoCore scripts/com/robot/core/info/` - 客户端Info类源码
