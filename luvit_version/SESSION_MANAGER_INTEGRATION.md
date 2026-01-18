# 会话管理器集成指南

## 概述

会话管理器（Session Manager）是一个**中央化的状态管理系统**，负责管理所有服务器的会话状态和临时数据，实现**数据与逻辑分离**。

## 架构优势

### 之前的架构
```
游戏服务器 ──┐
            ├─→ 各自维护状态 → 状态不同步
房间服务器 ──┘
```

### 新架构
```
        ┌─────────────────────┐
        │  Session Manager    │
        │  (统一状态管理)      │
        └─────────────────────┘
               ↑         ↑
               │         │
        ┌──────┴───┐  ┌──┴──────┐
        │游戏服务器│  │房间服务器│
        │ (逻辑)  │  │ (逻辑)  │
        └──────────┘  └──────────┘
```

## 功能特性

### 1. 会话管理
- 创建/销毁用户会话
- 会话数据存储
- 会话活跃时间追踪
- 过期会话自动清理

### 2. 在线状态管理
- 用户上线/下线
- 当前服务器类型追踪
- 当前地图追踪
- 心跳监控
- 离线用户自动清理

### 3. NoNo 状态管理
- NoNo 跟随状态
- 跨服务器状态同步

### 4. 战斗状态管理
- 战斗创建/结束
- 战斗状态更新
- 战斗中检测

### 5. 交易状态管理
- 交易创建/结束
- 交易状态查询

### 6. 组队状态管理
- 队伍创建/解散
- 队伍成员管理

### 7. 邀请状态管理
- 好友邀请
- 组队邀请
- 交易邀请
- 战斗邀请

### 8. 统计信息
- 实时统计
- 状态监控

## 集成步骤

### 步骤 1: 在 reseer.lua 中初始化

```lua
-- 加载会话管理器
local SessionManager = require('./session_manager')

-- 创建会话管理器实例
local sessionManager = SessionManager:new()

-- 创建游戏服务器时传入会话管理器
local gameServer = LocalGameServer:new(userdb, sessionManager)

-- 创建房间服务器时传入会话管理器
local roomServer = LocalRoomServer:new(userdb, gameServer, sessionManager)
```

### 步骤 2: 修改游戏服务器

```lua
-- gameserver/localgameserver.lua

function LocalGameServer:new(userdb, sessionManager)
    local obj = {
        port = conf.gameserver_port or 5000,
        clients = {},
        userdb = userdb,
        sessionManager = sessionManager,  -- 保存会话管理器引用
        -- 移除 nonoFollowingStates，改用 sessionManager
    }
    -- ...
end

-- 用户登录时
function LocalGameServer:handleLoginIn(clientData, cmdId, userId, seqId, body)
    -- ...
    
    -- 创建会话
    self.sessionManager:createSession(userId, 'game')
    self.sessionManager:userOnline(userId, 'game', mapId)
    
    -- ...
end

-- 用户断开时
function LocalGameServer:removeClient(clientData)
    if clientData.userId then
        self.sessionManager:userOffline(clientData.userId)
        self.sessionManager:destroySession(clientData.userId)
    end
    -- ...
end

-- 构建处理器上下文
function LocalGameServer:buildHandlerContext(clientData, cmdId, userId, seqId, body)
    local ctx = {
        -- ...
        sessionManager = self.sessionManager,  -- 添加会话管理器引用
    }
    return ctx
end
```

### 步骤 3: 修改房间服务器

```lua
-- roomserver/localroomserver.lua

function LocalRoomServer:new(sharedUserDB, sharedGameServer, sessionManager)
    local obj = {
        port = conf.roomserver_port or 5100,
        clients = {},
        userdb = sharedUserDB,
        gameServer = sharedGameServer,
        sessionManager = sessionManager,  -- 保存会话管理器引用
    }
    -- ...
end

-- 房间登录时
function LocalRoomServer:handleRoomLogin(clientData, cmdId, userId, seqId, body)
    -- ...
    
    -- 更新用户服务器类型
    self.sessionManager:updateUserServer(userId, 'room')
    self.sessionManager:updateUserMap(userId, mapId)
    
    -- 检查 NoNo 跟随状态
    if self.sessionManager:getNonoFollowing(userId) then
        clientData.nonoState = 1  -- 跟随中
    else
        clientData.nonoState = 0  -- 不跟随
    end
    
    -- ...
end
```

### 步骤 4: 修改 NoNo 处理器

```lua
-- handlers/nono_handlers.lua

local function handleNonoFollowOrHoom(ctx)
    local action = readUInt32BE(ctx.body, 1)
    
    -- 使用会话管理器设置 NoNo 跟随状态
    ctx.sessionManager:setNonoFollowing(ctx.userId, action == 1)
    
    -- ...
end

local function handleNonoInfo(ctx)
    -- 使用会话管理器获取 NoNo 跟随状态
    local isFollowing = ctx.sessionManager:getNonoFollowing(ctx.userId)
    local stateValue = isFollowing and 3 or 1
    
    -- ...
end
```

## 使用示例

### 示例 1: NoNo 跟随状态

```lua
-- 设置 NoNo 跟随
sessionManager:setNonoFollowing(userId, true)

-- 获取 NoNo 跟随状态
local isFollowing = sessionManager:getNonoFollowing(userId)

-- 清除 NoNo 跟随状态
sessionManager:clearNonoFollowing(userId)
```

### 示例 2: 战斗状态

```lua
-- 创建战斗
sessionManager:createBattle(userId, {
    battleType = 'wild',
    monsterId = 123,
    round = 1,
})

-- 检查是否在战斗中
if sessionManager:isInBattle(userId) then
    -- 战斗中，不能执行其他操作
end

-- 更新战斗状态
sessionManager:updateBattle(userId, {
    round = 2,
})

-- 结束战斗
sessionManager:endBattle(userId)
```

### 示例 3: 在线状态

```lua
-- 用户上线
sessionManager:userOnline(userId, 'game', mapId)

-- 检查是否在线
if sessionManager:isUserOnline(userId) then
    -- 用户在线
end

-- 更新用户地图
sessionManager:updateUserMap(userId, newMapId)

-- 获取地图内的所有用户
local users = sessionManager:getUsersInMap(mapId)

-- 用户下线
sessionManager:userOffline(userId)
```

### 示例 4: 会话数据

```lua
-- 设置会话数据
sessionManager:setSessionData(userId, 'lastShopVisit', os.time())

-- 获取会话数据
local lastVisit = sessionManager:getSessionData(userId, 'lastShopVisit')
```

### 示例 5: 统计信息

```lua
-- 获取统计信息
local stats = sessionManager:getStats()
print(string.format("在线用户: %d", stats.onlineUsers))

-- 打印统计信息
sessionManager:printStats()
```

## 定时清理

建议在 reseer.lua 中添加定时清理任务：

```lua
local timer = require('timer')

-- 每 5 分钟清理一次离线用户
timer.setInterval(5 * 60 * 1000, function()
    sessionManager:cleanupOfflineUsers(300)  -- 5 分钟未心跳
end)

-- 每 1 小时清理一次过期会话
timer.setInterval(60 * 60 * 1000, function()
    sessionManager:cleanupExpiredSessions(3600)  -- 1 小时未活跃
end)

-- 每 10 分钟打印一次统计信息
timer.setInterval(10 * 60 * 1000, function()
    sessionManager:printStats()
end)
```

## 扩展建议

### 1. 持久化支持
可以添加定期保存到 Redis 或文件的功能：

```lua
function SessionManager:saveToRedis()
    -- 保存到 Redis
end

function SessionManager:loadFromRedis()
    -- 从 Redis 加载
end
```

### 2. 分布式支持
如果需要多进程/多机器部署，可以使用 Redis 作为共享存储：

```lua
-- 使用 Redis 替代内存表
self.sessions = RedisTable:new('sessions')
self.onlineUsers = RedisTable:new('online_users')
```

### 3. 事件通知
添加事件监听机制：

```lua
function SessionManager:on(event, callback)
    -- 注册事件监听器
end

function SessionManager:emit(event, data)
    -- 触发事件
end

-- 使用示例
sessionManager:on('userOnline', function(userId)
    print('用户上线:', userId)
end)
```

## 性能优化

### 1. 索引优化
为常用查询添加索引：

```lua
-- 地图索引
self.mapIndex = {}  -- mapId -> [userId1, userId2, ...]

-- 服务器类型索引
self.serverTypeIndex = {}  -- serverType -> [userId1, userId2, ...]
```

### 2. 缓存优化
对频繁访问的数据添加缓存：

```lua
self.cache = {
    onlineCount = 0,
    lastUpdate = 0,
}
```

### 3. 批量操作
添加批量操作接口：

```lua
function SessionManager:batchUserOnline(users)
    for _, user in ipairs(users) do
        self:userOnline(user.userId, user.serverType, user.mapId)
    end
end
```

## 迁移指南

### 从旧架构迁移

1. **替换 nonoFollowingStates**
   ```lua
   -- 旧代码
   gameServer.nonoFollowingStates[userId] = true
   
   -- 新代码
   sessionManager:setNonoFollowing(userId, true)
   ```

2. **替换 OnlineTracker**
   ```lua
   -- 旧代码
   OnlineTracker.playerLogin(userId, mapId)
   
   -- 新代码
   sessionManager:userOnline(userId, 'game', mapId)
   ```

3. **替换战斗状态**
   ```lua
   -- 旧代码
   clientData.battleState = {...}
   
   -- 新代码
   sessionManager:createBattle(userId, {...})
   ```

## 总结

会话管理器提供了一个**统一的、中央化的状态管理系统**，具有以下优势：

1. **数据与逻辑分离** - 服务器只负责业务逻辑，状态由会话管理器统一管理
2. **跨服务器共享** - 所有服务器访问同一个会话管理器，状态自动同步
3. **易于扩展** - 新增状态类型只需在会话管理器中添加，不影响服务器代码
4. **易于维护** - 状态管理逻辑集中，便于调试和优化
5. **易于测试** - 可以独立测试会话管理器，不依赖服务器
6. **易于监控** - 统一的统计接口，便于监控系统状态

这是一个**生产级别**的架构设计，适合长期维护和扩展。
