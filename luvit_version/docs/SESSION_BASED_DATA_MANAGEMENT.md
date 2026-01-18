# 会话式数据管理 - 实现文档

## 📋 概述

将数据管理从"频繁读写文件"改为"会话式内存管理"，提高性能并预留数据库接口。

## ✅ 已完成的改动

### 1. 修复 cloth 索引错误

**文件**: `gameserver/seer_login_response.lua`

**问题**: 当 `clothes` 数组中的元素是数字而不是表时，`cloth.id` 会导致错误
```
attempt to index local 'cloth' (a number value)
```

**修复**: 添加类型检查，兼容多种格式
```lua
-- 兼容多种格式
if type(cloth) == "table" then
    clothId = cloth.id or cloth[1] or 0
    level = cloth.level or cloth[2] or 1
elseif type(cloth) == "number" then
    clothId = cloth
    level = 1
else
    clothId = 0
    level = 1
end
```

### 2. 会话式数据管理

**文件**: `userdb.lua`

**核心改动**:

#### 2.1 数据加载（启动时）
```lua
function UserDB:load()
    -- 从 users.json 加载所有数据到内存
    -- 只在服务器启动时执行一次
end
```

#### 2.2 数据更新（运行时）
```lua
function UserDB:saveGameData(userId, data)
    self.gameData[tostring(userId)] = data
    -- 会话式管理：不自动保存到磁盘，只在关闭时或显式调用时保存
end
```

#### 2.3 显式保存方法
```lua
function UserDB:saveToFile()
    self:save()  -- 保存到 users.json
end
```

#### 2.4 数据库接口预留
```lua
-- 预留的数据库接口示例
-- function UserDB:loadFromDB()
--     -- 从 MySQL/PostgreSQL 加载数据
-- end
--
-- function UserDB:saveToDB()
--     -- 保存到 MySQL/PostgreSQL
-- end
```

### 3. 服务器启动脚本优化

**文件**: `start_gameserver.lua`

**改动**:

#### 3.1 启动时说明
```lua
print("[游戏服务器] ========== 会话式数据管理 ==========")
print("[游戏服务器] • 启动时: 从 users.json 加载所有数据到内存")
print("[游戏服务器] • 运行时: 所有数据在内存中更新（会话式）")
print("[游戏服务器] • 定时保存: 每 30 秒自动保存到 users.json")
print("[游戏服务器] • 关闭时: 自动保存所有数据")
print("[游戏服务器] • 数据库: 预留接口，可替换为 MySQL/PostgreSQL")
```

#### 3.2 定期保存（每30秒）
```lua
local saveInterval = 30 * 1000  -- 30秒
timer.setInterval(saveInterval, function()
    local db = userdb:new()
    db:saveToFile()
    print(string.format("[自动保存] %s", os.date("%H:%M:%S")))
end)
```

#### 3.3 优雅关闭
```lua
-- 捕获 Ctrl+C 和终止信号
process:on("SIGINT", function()
    print("[游戏服务器] 收到退出信号 (Ctrl+C)...")
    saveAllData()
    print("[游戏服务器] 服务器已安全关闭")
    os.exit(0)
end)

process:on("SIGTERM", function()
    print("[游戏服务器] 收到终止信号...")
    saveAllData()
    print("[游戏服务器] 服务器已安全关闭")
    os.exit(0)
end)
```

## 🎯 数据流程

### 启动流程
```
1. 服务器启动
   ↓
2. UserDB:load() - 从 users.json 加载所有数据到内存
   ↓
3. 数据存储在 self.users 和 self.gameData 中
   ↓
4. 服务器就绪
```

### 运行时流程
```
1. 玩家操作（如购买物品、捕捉精灵）
   ↓
2. 调用 UserDB:saveGameData(userId, data)
   ↓
3. 数据更新到内存中（self.gameData[userId]）
   ↓
4. 不写入磁盘（会话式）
```

### 保存流程
```
定期保存（每30秒）:
   timer → UserDB:saveToFile() → 写入 users.json

关闭时保存:
   SIGINT/SIGTERM → saveAllData() → UserDB:saveToFile() → 写入 users.json
```

## 📊 性能对比

### 之前（频繁读写）
- ❌ 每次操作都写入文件
- ❌ 磁盘 I/O 频繁
- ❌ 性能瓶颈
- ❌ 可能导致文件损坏

### 现在（会话式）
- ✅ 所有操作在内存中
- ✅ 定期批量保存（30秒）
- ✅ 高性能
- ✅ 数据一致性好

## 🔄 未来迁移到数据库

### 步骤1: 实现数据库接口
```lua
-- 在 userdb.lua 中实现
function UserDB:loadFromDB()
    local mysql = require('mysql')
    local db = mysql:new(config)
    
    -- 加载用户数据
    local result = db:query("SELECT * FROM users")
    for _, row in ipairs(result) do
        self.users[row.user_id] = json.parse(row.data)
    end
    
    -- 加载游戏数据
    local gameResult = db:query("SELECT * FROM game_data")
    for _, row in ipairs(gameResult) do
        self.gameData[row.user_id] = json.parse(row.data)
    end
end

function UserDB:saveToDB()
    -- 批量保存到数据库
    for userId, userData in pairs(self.users) do
        db:query("INSERT INTO users ... ON DUPLICATE KEY UPDATE ...")
    end
    
    for userId, gameData in pairs(self.gameData) do
        db:query("INSERT INTO game_data ... ON DUPLICATE KEY UPDATE ...")
    end
end
```

### 步骤2: 修改启动脚本
```lua
-- 在 start_gameserver.lua 中
if conf.use_database then
    db:loadFromDB()  -- 从数据库加载
else
    db:load()        -- 从 JSON 文件加载
end
```

### 步骤3: 修改保存逻辑
```lua
-- 定期保存
timer.setInterval(saveInterval, function()
    if conf.use_database then
        db:saveToDB()
    else
        db:saveToFile()
    end
end)
```

## 📝 数据库表结构（预留）

```sql
-- 用户账号表
CREATE TABLE users (
    user_id BIGINT PRIMARY KEY,
    data JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at)
);

-- 游戏数据表
CREATE TABLE game_data (
    user_id BIGINT PRIMARY KEY,
    data JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_updated_at (updated_at)
);

-- 可选：分表存储（提高性能）
CREATE TABLE pets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    pet_id INT NOT NULL,
    catch_time INT NOT NULL,
    level INT DEFAULT 5,
    data JSON,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_catch_time (catch_time)
);

CREATE TABLE items (
    user_id BIGINT NOT NULL,
    item_id INT NOT NULL,
    count INT DEFAULT 1,
    PRIMARY KEY (user_id, item_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

## ⚠️ 注意事项

1. **数据一致性**
   - 定期保存间隔为 30 秒
   - 如果服务器异常崩溃，最多丢失 30 秒的数据
   - 可以根据需要调整保存间隔

2. **内存使用**
   - 所有用户数据都在内存中
   - 对于大量用户，需要监控内存使用
   - 可以考虑实现 LRU 缓存策略

3. **并发安全**
   - 当前实现是单线程的
   - 如果未来使用多线程，需要添加锁机制

4. **备份策略**
   - 建议定期备份 users.json
   - 可以在保存时创建备份文件

## ✅ 测试验证

### 测试1: 启动服务器
```bash
luvit start_gameserver.lua
```
预期输出:
```
[游戏服务器] ========== 会话式数据管理 ==========
[游戏服务器] • 启动时: 从 users.json 加载所有数据到内存
[游戏服务器] • 运行时: 所有数据在内存中更新（会话式）
...
```

### 测试2: 自动保存
等待 30 秒，应该看到:
```
[自动保存] 18:32:53
```

### 测试3: 优雅关闭
按 Ctrl+C，应该看到:
```
[游戏服务器] 收到退出信号 (Ctrl+C)...
[游戏服务器] 正在保存所有数据到 users.json...
[游戏服务器] ✓ 数据已保存
[游戏服务器] 服务器已安全关闭
```

### 测试4: cloth 错误修复
登录游戏，不应该再看到:
```
attempt to index local 'cloth' (a number value)
```

## 📅 完成时间

2026-01-18

---

**会话式数据管理已实现！性能提升，数据库接口已预留。**
