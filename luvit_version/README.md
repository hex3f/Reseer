# 赛尔号私服 - 统一服务器架构

## 🚀 快速启动

```bash
cd luvit_version
start.bat
```

然后访问：**http://127.0.0.1:32400/**

## 📦 服务器架构

```
统一游戏服务器 (5000)
    ├─ 游戏逻辑
    ├─ 地图系统
    ├─ 战斗系统
    └─ 家园系统 (已合并)
```

### 启动的服务

1. **资源服务器** (32400) - 提供网页和资源
2. **登录IP服务器** (32401) - 提供 ip.txt
3. **登录服务器** (1863) - 处理登录
4. **游戏服务器** (5000) - 所有游戏功能（包含家园系统）

## 🎯 核心特性

### 统一服务器架构
- ✅ 游戏和家园功能合并到单一服务器
- ✅ 简化部署和维护
- ✅ 统一数据管理
- ✅ 更好的性能和稳定性

### 统一命令处理器
- ✅ 处理器只写一次（`handlers/` 目录）
- ✅ 自动支持所有游戏功能
- ✅ 易于扩展和维护

## 📁 目录结构

```
luvit_version/
├── start.bat              # 启动脚本
├── start_gameserver.lua   # 游戏服务器（含家园系统）
├── handlers/              # 统一命令处理器
│   ├── nono_handlers.lua
│   ├── pet_handlers.lua
│   ├── room_handlers.lua  # 家园系统处理器
│   └── ...
├── gameserver/            # 游戏服务器逻辑
│   └── localgameserver.lua # 包含家园系统
└── docs/                  # 文档和分析文件
```

## 🔧 配置

编辑启动脚本中的配置：

```lua
local conf = {
    gameserver_port = 5000,  -- 游戏服务器端口（包含家园系统）
}
```

## 📖 架构变更

### 之前的架构（已废弃）
- 游戏服务器 (5000) - 游戏逻辑
- 房间服务器 (5100) - 家园系统
- 数据服务器 (5200) - 数据管理

### 现在的架构
- 游戏服务器 (5000) - 所有功能（游戏 + 家园）
- 简化的单一服务器设计
- 更好的性能和可维护性

## 💡 开发指南

### 添加新命令

1. 在 `handlers/` 创建或编辑处理器
2. 使用 `ctx.getOrCreateUser()` 访问用户数据
3. 游戏服务器自动处理所有命令

### 示例

```lua
-- handlers/my_handler.lua
local function handleMyCommand(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    -- 处理逻辑
    ctx.sendResponse(...)
end

return {
    register = function(registry)
        registry.register(12345, handleMyCommand)
    end
}
```

## 🎮 游戏功能

- ✅ 用户登录和注册
- ✅ 地图系统
- ✅ 精灵系统
- ✅ 战斗系统
- ✅ NoNo 系统
- ✅ 家园系统（已合并）
- ✅ 任务系统
- ✅ 好友系统

## 🐛 故障排除

### 服务器无法启动
- 检查端口是否被占用
- 确保 `luvit.exe` 存在

### 无法访问网页
- 确认资源服务器已启动（端口 32400）
- 检查防火墙设置

### 家园系统无法使用
- 确认游戏服务器已启动（端口 5000）
- 家园功能已集成到游戏服务器中

## 📝 许可

本项目仅供学习和研究使用。
