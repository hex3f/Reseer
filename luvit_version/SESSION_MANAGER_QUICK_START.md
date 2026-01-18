# 会话管理器快速开始

## 5 分钟快速集成

### 1. 修改 reseer.lua (主入口)

```lua
-- 在文件开头添加
local SessionManager = require('./session_manager')

-- 在创建服务器之前创建会话管理器
local sessionManager = SessionManager:new()

-- 修改游戏服务器创建
local gameServer = LocalGameServer:new(userdb, sessionManager)

-- 修改房间服务器创建
local roomServer = LocalRoomServer:new(userdb, gameServer, sessionManager)

-- 添加定时清理任务（可选）
local timer = require('timer')
timer.setInterval(5 * 60 * 1000, function()
    sessionManager:cleanupOfflineUsers(300)
end)
```

### 2. 修改游戏服务器构造函数

```lua
-- gameserver/localgameserver.lua

-- 修改 new 函数签名
function LocalGameServer:new(userdb, sessionManager)
    local obj = {
        port = conf.gameserver_port or 5000,
        clients = {},
        userdb = userdb,
        sessionManager = sessionManager,  -- 添加这行
        -- 删除 nonoFollowingStates = {}  -- 不再需要
    }
    -- ...
end

-- 修改 buildHandlerContext
function LocalGameServer:buildHandlerContext(clientData, cmdId, userId, seqId, body)
    local ctx = {
        -- ... 其他字段
        sessionManager = self.sessionManager,  -- 添加这行
    }
    return ctx
end
```

### 3. 修改房间服务器构造函数

```lua
-- roomserver/localroomserver.lua

-- 修改 new 函数签名
function LocalRoomServer:new(sharedUserDB, sharedGameServer, sessionManager)
    local obj = {
        port = conf.roomserver_port or 5100,
        clients = {},
        userdb = sharedUserDB,
        gameServer = sharedGameServer,
        sessionManager = sessionManager,  -- 添加这行
    }
    -- 删除初始化 nonoFollowingStates 的代码
    -- ...
end

-- 修改 handleRoomLogin
function LocalRoomServer:handleRoomLogin(clientData, cmdId, userId, seqId, body)
    -- ... 解析参数
    
    -- 替换原来的代码
    -- 旧代码:
    -- if self.gameServer.nonoFollowingStates[userId] then
    --     clientData.nonoState = 1
    -- end
    
    -- 新代码:
    if self.sessionManager:getNonoFollowing(userId) then
        clientData.nonoState = 1
    else
        clientData.nonoState = 0
    end
    
    -- ...
end

-- 修改 handleNonoInfo
function LocalRoomServer:handleNonoInfo(clientData, cmdId, userId, seqId, body)
    -- ... 解析参数
    
    local stateValue = 1
    
    -- 替换原来的代码
    -- 旧代码:
    -- if self.gameServer.nonoFollowingStates[targetUserId] then
    --     stateValue = 3
    -- end
    
    -- 新代码:
    if self.sessionManager:getNonoFollowing(targetUserId) then
        stateValue = 3
    end
    
    -- ...
end

-- 修改 handleCommand 中的 CMD 9019 特殊处理
function LocalRoomServer:handleCommand(clientData, cmdId, userId, seqId, body)
    -- ...
    
    if cmdId == 9019 and #body >= 4 then
        local action = readUInt32BE(body, 1)
        clientData.nonoState = action
        
        -- 替换原来的代码
        -- 旧代码:
        -- if self.gameServer.nonoFollowingStates then
        --     self.gameServer.nonoFollowingStates[userId] = (action == 1)
        -- end
        
        -- 新代码:
        self.sessionManager:setNonoFollowing(userId, action == 1)
    end
    
    -- ...
end
```

### 4. 修改 NoNo 处理器

```lua
-- handlers/nono_handlers.lua

local function handleNonoFollowOrHoom(ctx)
    local action = readUInt32BE(ctx.body, 1)
    local nonoData = getNonoData(ctx)
    
    -- 替换原来的代码
    -- 旧代码:
    -- if ctx.clientData then
    --     ctx.clientData.nonoFollowing = (action == 1)
    -- end
    -- if ctx.gameServer and ctx.gameServer.nonoFollowingStates then
    --     ctx.gameServer.nonoFollowingStates[ctx.userId] = (action == 1)
    -- end
    
    -- 新代码:
    if ctx.clientData then
        ctx.clientData.nonoFollowing = (action == 1)
    end
    ctx.sessionManager:setNonoFollowing(ctx.userId, action == 1)
    
    -- ... 其余代码不变
end
```

## 完成！

现在你的服务器已经使用会话管理器来管理所有状态了。

## 验证集成

启动服务器后，你应该看到：

```
[SessionManager] 会话管理器已初始化
[SessionManager] 创建会话: userId=100000001, server=game
[SessionManager] 用户上线: userId=100000001, server=game, map=1
[SessionManager] NoNo 跟随状态: userId=100000001, following=true
```

## 下一步

1. **添加更多状态管理**
   - 战斗状态
   - 交易状态
   - 组队状态

2. **添加监控**
   ```lua
   -- 每 10 分钟打印统计信息
   timer.setInterval(10 * 60 * 1000, function()
       sessionManager:printStats()
   end)
   ```

3. **扩展功能**
   - 参考 SESSION_MANAGER_INTEGRATION.md 了解更多功能

## 对比

### 之前的代码
```lua
-- 分散在各个地方
gameServer.nonoFollowingStates[userId] = true
clientData.battleState = {...}
clientData.tradeState = {...}
```

### 现在的代码
```lua
-- 统一管理
sessionManager:setNonoFollowing(userId, true)
sessionManager:createBattle(userId, {...})
sessionManager:createTrade(userId1, userId2, {...})
```

**更清晰、更易维护、更易扩展！**
