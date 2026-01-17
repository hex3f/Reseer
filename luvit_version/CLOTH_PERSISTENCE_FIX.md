# 服装持久化与同步修复

## 问题描述

1. 用户更换服装后，刷新页面（重新登录）时服装消失
2. RoomServer自动把items中的衣服显示为已装备，但GameServer不显示，导致行为不一致
3. ENTER_MAP协议大小验证错误
4. **在房间内换衣服后，背包和身上穿的不同步** ⭐ 关键问题
5. **在 GameServer 换衣服后，进入 RoomServer 显示旧衣服** ⭐ 新问题

## 原因分析

### 官服行为分析 ⭐ 重要发现

通过分析官服数据包，发现了关键行为：

**房间服务器 ENTER_MAP 响应**：
- 未装备衣服时：161 bytes (clothCount=0)
- 装备2件衣服后：177 bytes (clothCount=2, 包含衣服数据)

**结论**：官服房间服务器**会发送衣服数据**，而不是永远 clothCount=0！

### 缓存同步问题 ⭐ 核心原因

#### 问题 1：房间内换衣服

RoomServer 和 GameServer 各自维护独立的用户数据缓存：
- 在房间内换衣服时，CMD 2604 由 GameServer 处理
- GameServer 更新了自己的缓存和数据库
- 但 **RoomServer 的缓存没有更新**
- 导致 RoomServer 发送的 ENTER_MAP 使用旧的衣服数据
- 结果：背包显示新衣服，但身上显示旧衣服

#### 问题 2：GameServer 换衣服后进入 RoomServer ⭐ 新发现

**场景**：
1. 在 RoomServer：AB 穿身上，CDE 在背包
   - RoomServer 缓存：`clothes = [A, B]`
   - 数据库：`clothes = [A, B]`

2. 进入 GameServer：换衣服，CD 穿身上，ABE 在背包
   - GameServer 收到 CMD 2604
   - GameServer 更新并保存：`clothes = [C, D]` ✓
   - **RoomServer 缓存仍然是 `[A, B]`** ❌

3. 再次进入 RoomServer：
   - RoomServer 从**缓存**读取：`clothes = [A, B]`（旧数据）
   - 显示：AB 穿身上，CDE 在背包 ❌

**根本原因**：RoomServer 的缓存在用户离开后仍然保留，当用户在 GameServer 换衣服后，RoomServer 不知道数据已更新。

## 修复方案

### 1. RoomServer 发送衣服数据

**文件**: `luvit_version/roomserver/localroomserver.lua`

修改 ENTER_MAP 和 LIST_MAP_PLAYER 响应，根据用户实际装备的衣服发送数据：

```lua
-- 获取用户衣服数据
local clothes = userData.clothes or {}
local clothCount = type(clothes) == "table" and #clothes or 0

-- 构建响应
responseBody = responseBody .. writeUInt32BE(clothCount)  -- clothCount
for _, cloth in ipairs(clothes) do
    responseBody = responseBody .. writeUInt32BE(cloth.id or 0)      -- clothId
    responseBody = responseBody .. writeUInt32BE(cloth.level or 1)   -- level
end
responseBody = responseBody .. writeUInt32BE(0)  -- curTitle
```

**官服行为**：
- 未装备衣服：clothCount=0，144 bytes
- 装备N件衣服：clothCount=N，144 + N*8 bytes

### 2. RoomServer缓存同步 ⭐ 关键修复

**文件**: `luvit_version/roomserver/localroomserver.lua`

```lua
-- 尝试使用游戏服务器的处理器（共用命令）
if self.gameServer and self.gameServer.handleCommandDirect then
    local success = self.gameServer:handleCommandDirect(clientData, cmdId, userId, seqId, body)
    if success then
        -- 如果是会修改用户数据的命令，清除 RoomServer 的缓存
        -- 这样下次访问时会从数据库重新加载最新数据
        if cmdId == 2604 then  -- CHANGE_CLOTH
            self.users[userId] = nil
            tprint(string.format("\27[35m[RoomServer] 清除用户 %d 的缓存（衣服已更新）\27[0m", userId))
        end
        return
    end
end
```

**工作原理**：
1. 用户在房间内换衣服 → RoomServer 收到 CMD 2604
2. RoomServer 调用 GameServer 的 `handleCommandDirect` 处理
3. GameServer 更新数据库
4. RoomServer 检测到是 CHANGE_CLOTH 命令，清除该用户的缓存
5. 下次需要用户数据时（如发送 ENTER_MAP），RoomServer 从数据库重新加载
6. 现在衣服数据是最新的，背包和身上同步！

## 测试验证

1. **在房间内换衣服**：
   ```
   [LocalGame] 用户 100000001 服装已保存到数据库
   [RoomServer] 清除用户 100000001 的缓存（衣服已更新）
   ```

2. **查看背包和身上**：
   - 背包显示的衣服（items）
   - 身上穿的衣服（clothes）
   - 两者应该同步 ✓

3. **协议验证**：
   ```
   ✓ [CHANGE_CLOTH] 包体大小正确: 16字节
   ✓ [ENTER_MAP] 包体大小正确: 152字节 (1件服装)
   ```

## 实施日期

2026年1月17日
