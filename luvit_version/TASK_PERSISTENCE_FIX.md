# 任务状态持久化修复

## 问题描述

用户报告："第二次进入游戏又触发了新手任务" - 第一次登录完成的任务（85, 86, 87, 88）在第二次登录时又被触发。

## 根本原因

### 问题 1: 任务状态索引错误

**登录响应中的任务状态数组索引不匹配**：

- **服务器端**：使用 `taskBuf:wbyte(tid, status)` 写入任务状态，例如任务 85 写入到字节位置 85
- **客户端端**：ActionScript 数组索引从 0 开始，`TasksManager.taskList[84]` 对应任务 85
- **结果**：任务状态错位，客户端读取到错误的任务状态

**正确的映射关系**：
- 任务 ID 1 → 字节位置 0 → `TasksManager.taskList[0]`
- 任务 ID 85 → 字节位置 84 → `TasksManager.taskList[84]`
- 任务 ID 1000 → 字节位置 999 → `TasksManager.taskList[999]`

### 问题 2: 已完成任务可被重新接受

`handleAcceptTask` 函数（CMD 2201）没有检查任务是否已经完成，导致：

1. 第一次登录：任务 85, 86, 87, 88 正常完成并保存为 `"status": "completed"`
2. 第二次登录：由于索引错误，客户端读取到错误的任务状态
3. 客户端再次尝试接受任务 85
4. 服务端直接覆盖任务状态，将 `"completed"` 改为 `"accepted"`
5. 任务状态丢失，用户需要重新完成

## 修复内容

### 1. 修复任务状态数组索引

**文件**: `luvit_version/gameserver/seer_login_response.lua`

将任务状态写入位置从 `tid` 改为 `tid - 1`：

```lua
-- 客户端数组索引从0开始，所以任务ID=1对应索引0
-- 但 buffer 的 writeUInt8 索引也是从0开始，所以需要 tid-1
taskBuf:writeUInt8(tid - 1, status)
```

**修复前**：
```lua
taskBuf:wbyte(tid, status)  -- 任务85写入位置85
```

**修复后**：
```lua
taskBuf:writeUInt8(tid - 1, status)  -- 任务85写入位置84
```

### 2. 防止已完成任务被重新接受

**文件**: `luvit_version/gameserver/localgameserver.lua`

在 `handleAcceptTask` 函数中添加检查：

```lua
-- 检查任务是否已经完成，如果已完成则不允许重新接受
local existingTask = gameData.tasks[tostring(taskId)]
if existingTask and existingTask.status == "completed" then
    tprint(string.format("\27[33m[LocalGame] 任务 %d 已完成，拒绝重新接受\27[0m", taskId))
    -- 仍然返回成功响应，但不修改数据库
    local responseBody = writeUInt32BE(taskId)
    self:sendResponse(clientData, cmdId, userId, 0, responseBody)
    return
end
```

### 3. 增强调试日志

**文件**: `luvit_version/gameserver/seer_login_response.lua`

添加详细的任务加载日志，包括写入位置：

```lua
print(string.format("\27[36m[LOGIN]   任务 %d: %s (status=%d, 写入位置=%d)\27[0m", 
    tid, taskData.status, status, tid - 1))
```

**文件**: `luvit_version/gameserver/localgameserver.lua`

在 `handleLoginIn` 中添加任务数量日志：

```lua
if gameData.tasks then
    local taskCount = 0
    for _ in pairs(gameData.tasks) do taskCount = taskCount + 1 end
    print(string.format("\27[35m[LOGIN] 从数据库加载了 %d 个任务\27[0m", taskCount))
end
```

### 4. 修复损坏的用户数据

**文件**: `luvit_version/users.json`

将任务 85 的状态从 `"accepted"` 恢复为 `"completed"`：

```json
"85": {
  "status": "completed",
  "acceptTime": 1768642260,
  "completeTime": 1768642265,
  "param": 0
}
```

## 技术细节

### 客户端任务状态读取逻辑

**文件**: `front-end scripts/NieoCore scripts/com/robot/core/info/UserInfo.as`

```actionscript
var _loc11_:int = 0;
while(_loc11_ < 500)
{
    TasksManager.taskList.push(param2.readUnsignedByte());
    _loc11_++;
}
```

- 客户端读取 500 个字节（任务 1-500）
- 数组索引从 0 开始：`TasksManager.taskList[0]` = 任务 1
- 获取任务状态：`TasksManager.getTaskStatus(taskId)` 返回 `taskList[taskId - 1]`

### 服务器任务状态写入逻辑

**文件**: `luvit_version/gameserver/seer_login_response.lua`

```lua
local taskBuf = buffer.Buffer:new(1000)
-- 初始化全0
for i = 1, 1000 do
    taskBuf:wbyte(i, 0)
end

-- 填充任务状态（修复后）
taskBuf:writeUInt8(tid - 1, status)  -- tid=85 → 位置84
```

## 测试验证

1. 启动服务器
2. 使用已完成任务 85-88 的账号登录
3. 观察日志输出：
   ```
   [LOGIN] 从数据库加载了 4 个任务
   [LOGIN] 开始加载任务状态...
   [LOGIN]   任务 85: completed (status=3, 写入位置=84)
   [LOGIN]   任务 86: completed (status=3, 写入位置=85)
   [LOGIN]   任务 87: completed (status=3, 写入位置=86)
   [LOGIN]   任务 88: completed (status=3, 写入位置=87)
   [LOGIN] 加载了 4 个任务状态
   ```
4. 客户端应该不再显示新手教程
5. 如果客户端尝试重新接受任务 85，服务器应输出：
   ```
   [LocalGame] 任务 85 已完成，拒绝重新接受
   ```

## 影响范围

- 所有任务系统（任务 ID 1-1000）
- 登录响应中的任务状态数组
- 防止任何已完成任务被重新接受
- 保护任务完成状态不被意外覆盖

## 备注

- 已创建备份文件：`luvit_version/users.json.backup`
- 此修复确保任务状态的完整性和持久化
- 客户端仍会收到成功响应，但服务端不会修改数据库
- 修复了服务器和客户端之间的索引不匹配问题
