# NoNo 颜色修复

## 问题

NoNo 显示为黑色，而不是正常的白色。

## 原因

在 `handlers/nono_handlers.lua` 中，NoNo 的颜色值写错了：

```lua
-- 错误的颜色值
color = 0x00FFFFFF  -- 前缀 0x00 导致颜色解析错误
color = 0x00FBF4E1  -- 错误的颜色值
```

## 修复

将所有 NoNo 颜色值统一为 `0xFFFFFF`（白色）：

```lua
-- 正确的颜色值
color = 0xFFFFFF  -- 白色
```

## 修改的位置

### `handlers/nono_handlers.lua`

1. **buildNonoInfoBody** 函数（CMD 9003）
   ```lua
   body = body .. writeUInt32BE(nonoData.color or 0xFFFFFF)  -- 白色
   ```

2. **buildNonoFollowBody** 函数（CMD 9019）
   ```lua
   body = body .. writeUInt32BE(nonoData.color or 0xFFFFFF)  -- 白色
   ```

3. **handleNonoChangeColor** 函数（CMD 9012）
   ```lua
   local newColor = 0xFFFFFF  -- 默认白色
   ```

## 颜色值说明

NoNo 的颜色是一个 32 位整数，格式为 RGB：

- `0xFFFFFF` = 白色（255, 255, 255）
- `0xFF0000` = 红色（255, 0, 0）
- `0x00FF00` = 绿色（0, 255, 0）
- `0x0000FF` = 蓝色（0, 0, 255）
- `0x000000` = 黑色（0, 0, 0）

**注意**：不要在颜色值前加 `0x00` 前缀，这会导致颜色解析错误！

## 配置文件

在 `game_config.lua` 中，NoNo 的默认颜色已经正确设置为白色：

```lua
Config.InitialPlayer = {
    nono = {
        color = 0xFFFFFF,  -- NoNo颜色 - 白色
        -- ...
    }
}
```

## 测试

重启服务器后，NoNo 应该显示为白色。

如果想要更改 NoNo 的颜色，可以：

1. **修改配置文件** - 在 `game_config.lua` 中修改默认颜色
2. **使用游戏内功能** - 使用 CMD 9012 (NONO_CHANGE_COLOR) 更改颜色
3. **修改数据库** - 在 `users.json` 中修改用户的 `nono.color` 值

## 修复状态

✅ 已修复 - NoNo 现在应该显示为白色
