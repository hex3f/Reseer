# 登录包大小修复 + 装备自动穿戴问题

## 问题
1. 登录包大小 1146 字节，期望 1142 字节 (多了 4 字节)
2. 初始赛尔豆 1049999，期望 2000
3. **装备自动穿戴：任务奖励的装备（100027, 100028）自动穿在身上，而不是在背包里**

## 修复

### 1. PetManager 多发 4 字节
客户端只读取 petNum (4字节)，服务端需要确保只发送 4 字节

**修复:** `seer_login_response.lua` 使用 `:sub(1, 4)` 确保只发送 4 字节
```lua
local petBuf = buffer.Buffer:new(4)
petBuf:wuint(1, 0) -- petNum = 0
parts[#parts+1] = tostring(petBuf):sub(1, 4)
```

### 2. 初始赛尔豆硬编码
`userdb.lua` 硬编码 coins=999999

**修复:** 从 game_config.lua 读取
```lua
local GameConfig = require("./game_config")
coins = GameConfig.InitialPlayer.coins or 2000
```

### 3. 装备自动穿戴问题 ⚠️
**问题根源:** `localgameserver.lua` 的 `getOrCreateUser()` 函数会自动把所有 100000-199999 范围的物品从 `items` 移到 `clothes` 数组并自动穿上。

**原代码 (错误):**
```lua
-- 从 items 中提取服装 (100xxx) - 只在 clothes 为空时
if gameData.items and clothesCount == 0 then
    self.users[userId].clothes = {}
    for itemIdStr, itemData in pairs(gameData.items) do
        local itemId = tonumber(itemIdStr)
        if itemId and itemId >= 100000 and itemId < 200000 then
            table.insert(self.users[userId].clothes, {id = itemId, level = 1})
        end
    end
end
```

**修复后:**
```lua
-- 检查服装数量（不再自动从 items 提取服装）
-- 服装应该由玩家手动穿戴，而不是自动穿上
if not self.users[userId].clothes then
    self.users[userId].clothes = {}
end
```

**说明:**
- 装备（100027, 100028）现在会留在 `items` 背包里
- 玩家需要手动穿戴装备（通过客户端操作）
- 服装只有在玩家主动穿戴时才会添加到 `clothes` 数组

## 登录包结构 (1142 字节)
- 基本信息: 108
- nonoChipList: 80
- dailyResArr: 50
- teacherID~fuseTimes: 96
- hasNono~nonoNick: 32
- TeamInfo: 24
- TeamPKInfo: 8
- reserved: 32
- TasksManager: 500
- petNum: 4
- clothes count: 4
- curTitle: 4
- bossAchievement: 200

**动态大小:** 当玩家穿戴装备时，总大小 = 1142 + (clothes数量 × 8)

## 修改文件
- `luvit_version/gameserver/seer_login_response.lua` - 修复 buffer 大小
- `luvit_version/userdb.lua` - 使用 game_config 初始值
- `luvit_version/gameserver/localgameserver.lua` - 移除自动穿装备逻辑
- `luvit_version/protocol_validator.lua` - 更新期望大小

## 注意事项
⚠️ **已有用户数据:** 如果数据库中已有用户的 `clothes` 数组包含装备，需要手动清理或重新创建角色。新用户不会受影响。
