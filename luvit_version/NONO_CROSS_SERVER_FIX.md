# NoNo 跨服务器状态同步修复

## 问题描述

用户报告了"两个NoNo"问题：
1. 用户在房间内让 NoNo 跟随（CMD 9019 action=1）
2. 离开房间进入地图，NoNo 继续跟随 ✓
3. 从地图返回房间，出现两个 NoNo：一个跟随，一个在房间 ✗

## 根本原因

NoNo 的跟随状态是**会话级别**的（不持久化到数据库），但需要在**游戏服务器和房间服务器之间共享**。

之前的实现问题：
1. 游戏服务器将跟随状态存储在 `clientData.nonoFollowing`
2. 房间服务器尝试从游戏服务器的 `clients` 列表中查找该状态
3. **问题**：当用户在房间服务器时，他们已经从游戏服务器断开，所以游戏服务器的 `clients` 列表中没有该用户
4. 结果：房间服务器无法获取跟随状态，总是返回 `state=1`（NoNo在房间），导致两个 NoNo 出现

## 解决方案

创建一个**共享状态表** `gameServer.nonoFollowingStates`，在游戏服务器和房间服务器之间共享：

```lua
-- 游戏服务器初始化
nonoFollowingStates = {}  -- userId -> boolean
```

### 修改的文件

#### 1. `luvit_version/gameserver/localgameserver.lua`

**初始化共享状态表**：
```lua
function LocalGameServer:new()
    local obj = {
        -- ...
        nonoFollowingStates = {},  -- 共享的 NoNo 跟随状态表
    }
end
```

**在 buildHandlerContext 中添加 gameServer 引用**：
```lua
function LocalGameServer:buildHandlerContext(clientData, cmdId, userId, seqId, body)
    local ctx = {
        -- ...
        gameServer = self_ref,  -- 添加游戏服务器引用
    }
end
```

#### 2. `luvit_version/handlers/nono_handlers.lua`

**CMD 9019 处理器更新共享状态**：
```lua
local function handleNonoFollowOrHoom(ctx)
    local action = readUInt32BE(ctx.body, 1)  -- 0=回家, 1=跟随
    
    -- 设置会话级别的跟随状态
    if ctx.clientData then
        ctx.clientData.nonoFollowing = (action == 1)
    end
    
    -- 同时设置到共享状态表（供房间服务器访问）
    if ctx.gameServer and ctx.gameServer.nonoFollowingStates then
        ctx.gameServer.nonoFollowingStates[ctx.userId] = (action == 1)
    end
    
    -- ...
end
```

#### 3. `luvit_version/roomserver/localroomserver.lua`

**初始化时确保共享状态表存在**：
```lua
function LocalRoomServer:new(sharedUserDB, sharedGameServer)
    -- ...
    if not sharedGameServer.nonoFollowingStates then
        sharedGameServer.nonoFollowingStates = {}
    end
end
```

**房间登录时检查共享状态**：
```lua
function LocalRoomServer:handleRoomLogin(clientData, cmdId, userId, seqId, body)
    -- ...
    
    -- 检查游戏服务器的共享 NoNo 跟随状态
    clientData.nonoState = 0  -- 默认不跟随
    if self.gameServer and self.gameServer.nonoFollowingStates and 
       self.gameServer.nonoFollowingStates[userId] then
        clientData.nonoState = 1  -- 跟随中
    end
    
    -- ...
end
```

**CMD 9003 处理器使用共享状态**：
```lua
function LocalRoomServer:handleNonoInfo(clientData, cmdId, userId, seqId, body)
    -- ...
    
    local stateValue = 1  -- 默认在房间
    if self.gameServer and self.gameServer.nonoFollowingStates and 
       self.gameServer.nonoFollowingStates[targetUserId] then
        stateValue = 3  -- 跟随中
    end
    
    -- 返回 state=1 或 state=3
    -- ...
end
```

**CMD 9019 在房间服务器中也更新共享状态**：
```lua
function LocalRoomServer:handleCommand(clientData, cmdId, userId, seqId, body)
    -- ...
    
    if cmdId == 9019 and #body >= 4 then
        local action = readUInt32BE(body, 1)
        clientData.nonoState = action
        
        -- 同时更新共享状态表
        if self.gameServer and self.gameServer.nonoFollowingStates then
            self.gameServer.nonoFollowingStates[userId] = (action == 1)
        end
    end
    
    -- ...
end
```

## 工作流程

### 场景1：在房间内让 NoNo 跟随

1. 用户在房间内点击"跟随"
2. 客户端发送 CMD 9019 (action=1) 到房间服务器
3. 房间服务器：
   - 设置 `clientData.nonoState = 1`
   - 设置 `gameServer.nonoFollowingStates[userId] = true`
   - 转发命令到游戏服务器的处理器
4. 游戏服务器处理器：
   - 设置 `ctx.clientData.nonoFollowing = true`
   - 设置 `gameServer.nonoFollowingStates[userId] = true`
   - 返回响应
5. NoNo 开始跟随 ✓

### 场景2：从房间进入地图

1. 用户离开房间，进入地图
2. 客户端断开房间服务器，连接游戏服务器
3. 游戏服务器的 CMD 2001 (ENTER_MAP) 返回 `nonoState=1`（从共享状态读取）
4. NoNo 继续跟随 ✓

### 场景3：从地图返回房间

1. 用户从地图返回房间
2. 客户端断开游戏服务器，连接房间服务器
3. 房间服务器的 CMD 10001 (ROOM_LOGIN)：
   - 检查 `gameServer.nonoFollowingStates[userId]`
   - 如果为 `true`，设置 `clientData.nonoState = 1`
   - CMD 2001 (ENTER_MAP) 返回 `nonoState=1`
4. 客户端请求 CMD 9003 (NONO_INFO)
5. 房间服务器：
   - 检查 `gameServer.nonoFollowingStates[userId]`
   - 如果为 `true`，返回 `state=3`（跟随中）
   - 如果为 `false`，返回 `state=1`（在房间）
6. 前端根据 `state=3` 判断 NoNo 正在跟随，不在房间显示 ✓
7. **只有一个 NoNo（跟随）** ✓

### 场景4：让 NoNo 回家

1. 用户点击"回家"
2. 客户端发送 CMD 9019 (action=0)
3. 服务器：
   - 设置 `clientData.nonoState = 0`
   - 设置 `gameServer.nonoFollowingStates[userId] = false`
4. 客户端请求 CMD 9003
5. 服务器返回 `state=1`（在房间）
6. NoNo 出现在房间 ✓

## 状态值说明

### CMD 9003 (NONO_INFO) 的 state 字段

- `state=1` (二进制: `0000 0001`)
  - `state[0]=true, state[1]=false`
  - 前端判断：`!state[1]` → **显示 NoNo**（在房间）

- `state=3` (二进制: `0000 0011`)
  - `state[0]=true, state[1]=true`
  - 前端判断：`!state[1]` → **不显示 NoNo**（正在跟随）

### CMD 2001 (ENTER_MAP) 的 nonoState 字段

- `nonoState=0`：NoNo 不跟随
- `nonoState=1`：NoNo 跟随

## 关键设计原则

1. **会话级别**：NoNo 跟随状态不持久化到数据库，重新登录后重置
2. **跨服务器共享**：使用共享状态表在游戏服务器和房间服务器之间同步
3. **双向更新**：无论在哪个服务器执行 CMD 9019，都更新共享状态
4. **一致性**：所有服务器都从同一个共享状态表读取

## 测试步骤

1. 启动服务器
2. 登录游戏，进入房间
3. 验证 NoNo 显示在房间 ✓
4. 点击"跟随"，验证 NoNo 开始跟随 ✓
5. 离开房间进入地图，验证 NoNo 继续跟随 ✓
6. 返回房间，验证只有一个 NoNo（跟随），房间内没有 NoNo ✓
7. 点击"回家"，验证 NoNo 出现在房间 ✓

## 修复状态

✅ **已修复** - NoNo 跨服务器状态同步问题已解决
