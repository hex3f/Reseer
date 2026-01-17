# 任务奖励防重复发放修复

## 问题描述

新手任务的奖励可以重复领取。即使玩家已经完成过任务，再次完成时仍然会发放奖励（物品、金币、精灵等），导致玩家可以无限刷取奖励。

## 问题原因

在 `handleCompleteTask` 函数中，每次收到完成任务的请求时，都会无条件发放奖励，没有检查任务是否已经完成过。

### 原来的逻辑流程

```
1. 收到完成任务请求 (CMD 2202)
2. 读取任务配置
3. 发放所有奖励（物品、金币、精灵）
4. 保存任务状态为 "completed"
5. 返回响应
```

**问题：** 步骤 3 没有检查任务是否已完成，导致重复发放奖励。

## 修复方案

在发放奖励之前，先检查任务是否已经完成过。如果已完成，则跳过奖励发放，只返回空的奖励列表。

### 修复后的逻辑流程

```
1. 收到完成任务请求 (CMD 2202)
2. 从数据库检查任务状态
3. 如果任务已完成：
   - 设置 shouldGiveRewards = false
   - 记录日志：任务已完成过，不再发放奖励
4. 如果任务未完成：
   - 设置 shouldGiveRewards = true
   - 发放所有奖励（物品、金币、精灵）
5. 保存任务状态为 "completed"
6. 返回响应（包含或不包含奖励）
```

## 代码修改

### 修改文件
`luvit_version/gameserver/localgameserver.lua` - `handleCompleteTask` 函数

### 关键代码

```lua
-- 检查任务是否已经完成过
local shouldGiveRewards = true

if db then
    local gameData = db:getOrCreateGameData(userId)
    gameData.tasks = gameData.tasks or {}
    local existingTask = gameData.tasks[tostring(taskId)]
    
    if existingTask and existingTask.status == "completed" then
        tprint(string.format("\27[33m[LocalGame] 任务 %d 已完成过，不再发放奖励\27[0m", taskId))
        shouldGiveRewards = false
    end
end

-- 只有首次完成才发放奖励
if shouldGiveRewards and taskConfig then
    -- 发放精灵奖励
    -- 发放物品奖励
    -- 发放金币奖励
    -- 发放特殊奖励
end
```

## 测试场景

### 场景 1：首次完成任务
```
1. 玩家接受任务 85
2. 玩家完成任务 85
3. 服务器检查：任务未完成过
4. 服务器发放奖励：物品 x3
5. 服务器保存任务状态：completed
6. 玩家收到奖励
```

**期望结果：** ✓ 正常发放奖励

### 场景 2：重复完成任务
```
1. 玩家已完成任务 85（状态：completed）
2. 玩家再次触发完成任务 85
3. 服务器检查：任务已完成过
4. 服务器跳过奖励发放
5. 服务器返回空奖励列表
6. 玩家不会收到重复奖励
```

**期望结果：** ✓ 不发放重复奖励

### 场景 3：新手任务流程（85-88）
```
任务 85: 首次完成 → 发放奖励 ✓
任务 86: 首次完成 → 发放精灵 ✓
任务 87: 首次完成 → 发放奖励 ✓
任务 88: 首次完成 → 发放奖励 ✓

重新登录后：
任务 85: 再次完成 → 不发放奖励 ✓
任务 86: 再次完成 → 不发放精灵 ✓
任务 87: 再次完成 → 不发放奖励 ✓
任务 88: 再次完成 → 不发放奖励 ✓
```

## 日志输出

### 首次完成任务
```
[LocalGame] 处理 CMD 2202: 完成任务
[LocalGame] 用户 100000001 完成任务 85 (param=0)
[LocalGame] 发放物品奖励: itemId=300001, count=3
[LocalGame] 任务 85 状态已保存: completed
```

### 重复完成任务
```
[LocalGame] 处理 CMD 2202: 完成任务
[LocalGame] 用户 100000001 完成任务 85 (param=0)
[LocalGame] 任务 85 已完成过，不再发放奖励
[LocalGame] 任务 85 状态已保存: completed
```

## 响应包结构

### 有奖励的响应
```
taskId(4) + rewardPetId(4) + rewardCaptureTm(4) + itemCount(4) + [items...]
例如：任务 85 首次完成
  taskId: 85
  rewardPetId: 0
  rewardCaptureTm: 0
  itemCount: 1
  items: [id=300001, count=3]
```

### 无奖励的响应
```
taskId(4) + rewardPetId(4) + rewardCaptureTm(4) + itemCount(4)
例如：任务 85 重复完成
  taskId: 85
  rewardPetId: 0
  rewardCaptureTm: 0
  itemCount: 0
  items: []
```

## 相关功能

### 任务接受 (CMD 2201)
已有防重复接受机制：
```lua
if existingTask and existingTask.status == "completed" then
    tprint("任务已完成，拒绝重新接受")
    return
end
```

### 任务完成 (CMD 2202)
新增防重复奖励机制：
```lua
if existingTask and existingTask.status == "completed" then
    shouldGiveRewards = false
end
```

## 注意事项

1. **任务状态持久化**
   - 任务完成状态保存在 `users.json` 的 `gameData.tasks` 中
   - 格式：`{status: "completed", acceptTime: timestamp, completeTime: timestamp, param: value}`

2. **客户端行为**
   - 客户端可能会多次发送完成任务请求
   - 服务器必须保证幂等性（多次请求结果相同）

3. **奖励类型**
   - 物品奖励：通过 `db:addItem()` 添加到背包
   - 金币奖励：直接修改 `gameData.coins`
   - 精灵奖励：设置 `userData.currentPetId` 和 `userData.catchId`
   - 特殊奖励：根据类型处理

4. **响应格式**
   - 即使不发放奖励，也要返回正确格式的响应
   - `itemCount = 0` 表示没有奖励物品

## 测试建议

1. 完成新手任务 85-88
2. 重新登录
3. 尝试再次完成相同任务
4. 检查背包物品数量是否增加
5. 检查服务器日志是否显示"不再发放奖励"

## 相关文件

- `luvit_version/gameserver/localgameserver.lua` - 任务处理逻辑
- `luvit_version/data/seer_task_config.lua` - 任务配置
- `luvit_version/users.json` - 用户数据（包含任务状态）
- `luvit_version/TASK_PERSISTENCE_FIX.md` - 任务持久化修复文档
