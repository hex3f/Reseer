# 官服行为分析：房间 vs 地图

## 场景1：在房间内（家园）

### 打开背包
```
[→官服房间] CMD 2605 (ITEM_LIST) UID=516982 LEN=29
[←官服房间] CMD 2605 (ITEM_LIST) UID=516982 LEN=53
  返回2件衣服: 100027, 100028
```

### 查看精灵信息
```
[→官服房间] CMD 2301 (GET_PET_INFO) UID=516982 LEN=21
[←官服房间] CMD 2301 (GET_PET_INFO) UID=516982 LEN=171
  返回精灵详细信息
```

### 离开房间
```
[→官服房间] CMD 2002 (LEAVE_MAP) UID=516982 LEN=17
[←官服房间] CMD 2002 (LEAVE_MAP) UID=516982 LEN=21

[→官服] CMD 10003 (LEAVE_ROOM) UID=516982 LEN=37
[←官服] CMD 10003 (LEAVE_ROOM) UID=516982 LEN=17
```

**关键点**：
- 在房间内，CMD 2605 (ITEM_LIST) 和 CMD 2301 (GET_PET_INFO) 由**房间服务器**处理
- 房间服务器转发这些命令到官服房间服务器

---

## 场景2：在地图内（如地图101）

### 进入地图
```
[→官服] CMD 1004 (MAP_HOT) UID=516982 LEN=17
[←官服] CMD 1004 (MAP_HOT) UID=516982 LEN=253
  返回热门地图列表

[←官服] CMD 2001 (ENTER_MAP) UID=516982 LEN=177
  clothCount=2, 包含2件衣服数据
```

### 查看地图玩家列表
```
[→官服] CMD 2003 (LIST_MAP_PLAYER) UID=516982 LEN=17
[←官服] CMD 2003 (LIST_MAP_PLAYER) UID=516982 LEN=677
  返回4个玩家:
  - 玩家1 (516982): 2件衣服
  - 玩家2 (513813): 5件衣服
  - 玩家3 (501541): 1件衣服
  - 玩家4 (516861): 2件衣服
```

**关键点**：
- 在地图内，所有命令由**游戏服务器**处理
- 游戏服务器直接连接到官服游戏服务器

---

## 核心区别

### 1. 命令路由

| 场景 | 客户端连接 | 命令处理 | 官服连接 |
|------|-----------|---------|---------|
| 房间内 | RoomServer (5100) | RoomServer | 官服房间服务器 (27777) |
| 地图内 | GameServer (5003) | GameServer | 官服游戏服务器 (15001) |

### 2. 支持的命令

**房间服务器处理**：
- CMD 10001 (ROOM_LOGIN) - 房间登录
- CMD 10003 (LEAVE_ROOM) - 离开房间
- CMD 10006 (FITMENT_USERING) - 正在使用的家具
- CMD 10007 (FITMENT_ALL) - 所有家具
- CMD 2001 (ENTER_MAP) - 进入地图（房间内）
- CMD 2002 (LEAVE_MAP) - 离开地图
- CMD 2003 (LIST_MAP_PLAYER) - 地图玩家列表
- CMD 2605 (ITEM_LIST) - 物品列表 ⭐
- CMD 2301 (GET_PET_INFO) - 精灵信息 ⭐
- CMD 1106 (GOLD_ONLINE_CHECK_REMAIN) - 金币检查 ⭐
- CMD 9003 (NONO_INFO) - NONO信息
- CMD 2157 (SEE_ONLINE) - 查看在线
- CMD 2201 (ACCEPT_TASK) - 接受任务
- CMD 2324 (PET_ROOM_LIST) - 房间精灵列表

**游戏服务器处理**：
- CMD 1001 (LOGIN_IN) - 登录
- CMD 1004 (MAP_HOT) - 热门地图
- CMD 2001 (ENTER_MAP) - 进入地图（游戏内）
- CMD 2003 (LIST_MAP_PLAYER) - 地图玩家列表
- CMD 2605 (ITEM_LIST) - 物品列表
- CMD 2301 (GET_PET_INFO) - 精灵信息
- ... 以及所有其他游戏命令

### 3. 数据格式差异

**ENTER_MAP (CMD 2001)**：
- 房间服务器：144 + clothCount * 8 bytes
- 游戏服务器：144 + clothCount * 8 bytes
- **格式相同**，但数据来源不同

**LIST_MAP_PLAYER (CMD 2003)**：
- 房间服务器：通常只返回自己（1个玩家）
- 游戏服务器：返回地图内所有玩家（可能多个）

---

## 重要发现 ⭐

### 房间服务器需要处理的命令比预期多

之前我们只实现了房间相关的命令（10001-10008），但实际上房间服务器还需要处理：

1. **CMD 2605 (ITEM_LIST)** - 在房间内打开背包
2. **CMD 2301 (GET_PET_INFO)** - 在房间内查看精灵
3. **CMD 1106 (GOLD_ONLINE_CHECK_REMAIN)** - 金币检查

这些命令在房间内由 RoomServer 转发到官服房间服务器处理。

### 本地服务器的实现策略

我们已经通过 `handleCommandDirect` 机制实现了命令共享：
- RoomServer 收到命令后，先尝试本地处理器
- 如果没有，调用 GameServer 的 `handleCommandDirect`
- 这样 CMD 2605, 2301, 1106 等命令可以在房间内正常工作

**这个机制已经正确实现了！** ✓

---

## 测试建议

1. **在房间内打开背包** → 应该能看到物品列表
2. **在房间内查看精灵** → 应该能看到精灵信息
3. **在地图内打开背包** → 应该能看到物品列表
4. **在地图内查看精灵** → 应该能看到精灵信息

所有场景都应该正常工作，因为命令共享机制已经实现。
