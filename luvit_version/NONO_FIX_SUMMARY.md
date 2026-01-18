# NoNo 显示和跟随状态修复总结

## 修复历史

### 第一阶段：基础显示修复
**问题**: NoNo 不显示在房间
**原因**: CMD 9003 返回 `state=0` 而不是 `state=1` 或 `state=3`
**修复**: 修改游戏服务器和房间服务器的 `handleNonoInfo` 返回正确的 state 值

### 第二阶段：跨服务器状态同步修复 ✅
**问题**: "两个 NoNo" - 用户让 NoNo 跟随后，从地图返回房间时出现两个 NoNo（一个跟随，一个在房间）
**原因**: NoNo 跟随状态无法在游戏服务器和房间服务器之间正确同步
**修复**: 创建共享状态表 `gameServer.nonoFollowingStates` 在两个服务器之间共享跟随状态

详细说明请参考：[NONO_CROSS_SERVER_FIX.md](./NONO_CROSS_SERVER_FIX.md)

## 当前实现

### 状态管理架构

```
┌─────────────────────────────────────────────────────────────┐
│                    共享状态表                                 │
│         gameServer.nonoFollowingStates                       │
│              userId -> boolean                               │
└─────────────────────────────────────────────────────────────┘
                    ↑                    ↑
                    │                    │
        ┌───────────┴──────────┐  ┌─────┴──────────────┐
        │   游戏服务器          │  │   房间服务器        │
        │  (地图场景)           │  │  (家园场景)         │
        │                      │  │                    │
        │  CMD 9019 (跟随)     │  │  CMD 9019 (跟随)   │
        │  → 更新共享状态       │  │  → 更新共享状态     │
        │                      │  │                    │
        │  CMD 9003 (信息)     │  │  CMD 9003 (信息)   │
        │  → 读取共享状态       │  │  → 读取共享状态     │
        └──────────────────────┘  └────────────────────┘
```

### 关键修改

#### 1. `gameserver/localgameserver.lua`
- 初始化共享状态表 `nonoFollowingStates = {}`
- 在 `buildHandlerContext` 中添加 `gameServer` 引用
- `handleNonoInfo` 返回 `state=1`（在房间）

#### 2. `handlers/nono_handlers.lua`
- CMD 9019 处理器同时更新：
  - `ctx.clientData.nonoFollowing`（本地会话）
  - `ctx.gameServer.nonoFollowingStates[userId]`（共享状态）

#### 3. `roomserver/localroomserver.lua`
- 初始化时确保共享状态表存在
- `handleRoomLogin` 从共享状态读取 NoNo 跟随状态
- `handleNonoInfo` 根据共享状态返回 `state=1` 或 `state=3`
- CMD 9019 特殊处理同时更新共享状态

## 状态值说明

### CMD 9003 (NONO_INFO) 的 state 字段

| state 值 | 二进制 | state[0] | state[1] | 前端行为 | 说明 |
|---------|--------|----------|----------|---------|------|
| 1 | 0000 0001 | true | false | 显示 NoNo | NoNo 在房间 |
| 3 | 0000 0011 | true | true | 不显示 NoNo | NoNo 跟随中 |

前端代码（`RoomMachShow.as`）：
```actionscript
if(!this._info.state[1])  // 如果 state[1] == false
{
   this.showNono(this._info);  // 显示 NoNo
}
```

### CMD 2001 (ENTER_MAP) 的 nonoState 字段

- `nonoState=0`：NoNo 不跟随
- `nonoState=1`：NoNo 跟随

## 完整工作流程

### 场景1：初次登录
1. 用户登录 → 进入房间
2. CMD 9003 返回 `state=1`
3. 前端：`state[1]=false` → 显示 NoNo ✓

### 场景2：让 NoNo 跟随
1. 用户点击"跟随"
2. CMD 9019 (action=1)
3. 服务器更新：
   - `clientData.nonoState = 1`
   - `gameServer.nonoFollowingStates[userId] = true`
4. CMD 9003 返回 `state=3`
5. 前端：`state[1]=true` → 不显示 NoNo（跟随中）✓

### 场景3：从房间到地图
1. 用户离开房间 → 进入地图
2. 断开房间服务器 → 连接游戏服务器
3. CMD 2001 返回 `nonoState=1`（从共享状态读取）
4. NoNo 继续跟随 ✓

### 场景4：从地图返回房间 ⭐
1. 用户从地图 → 返回房间
2. 断开游戏服务器 → 连接房间服务器
3. CMD 10001 (ROOM_LOGIN)：
   - 检查 `gameServer.nonoFollowingStates[userId] == true`
   - 设置 `clientData.nonoState = 1`
4. CMD 9003 返回 `state=3`（跟随中）
5. 前端：`state[1]=true` → 不显示 NoNo
6. **只有一个 NoNo（跟随）** ✓

### 场景5：让 NoNo 回家
1. 用户点击"回家"
2. CMD 9019 (action=0)
3. 服务器更新：
   - `clientData.nonoState = 0`
   - `gameServer.nonoFollowingStates[userId] = false`
4. CMD 9003 返回 `state=1`
5. 前端：`state[1]=false` → 显示 NoNo ✓

## 关键设计原则

1. **会话级别**：NoNo 跟随状态不持久化到数据库，重新登录后重置
2. **跨服务器共享**：使用共享状态表在游戏服务器和房间服务器之间同步
3. **双向更新**：无论在哪个服务器执行 CMD 9019，都更新共享状态
4. **一致性**：所有服务器都从同一个共享状态表读取

## 测试步骤

1. ✅ 启动服务器，登录游戏，进入房间
2. ✅ 验证 NoNo 显示在房间
3. ✅ 点击"跟随"，验证 NoNo 开始跟随
4. ✅ 离开房间进入地图，验证 NoNo 继续跟随
5. ✅ 返回房间，验证只有一个 NoNo（跟随），房间内没有 NoNo
6. ✅ 点击"回家"，验证 NoNo 出现在房间
7. ✅ 重新登录，验证 NoNo 在房间（跟随状态已重置）

## 修改的文件

1. `gameserver/localgameserver.lua` - 共享状态表初始化、buildHandlerContext
2. `handlers/nono_handlers.lua` - CMD 9019 更新共享状态
3. `roomserver/localroomserver.lua` - 共享状态表初始化、读取共享状态
4. `users.json` - 清理错误的持久化状态（已完成）

## 修复状态

✅ **已完全修复** - NoNo 显示和跨服务器状态同步问题已解决

## 参考文档

- [NONO_CROSS_SERVER_FIX.md](./NONO_CROSS_SERVER_FIX.md) - 跨服务器状态同步详细说明
- [official_server_behavior_analysis.md](./official_server_behavior_analysis.md) - 官服行为分析
