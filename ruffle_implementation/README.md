# Ruffle.js 实现方案（未完成）

这个文件夹包含了让赛尔号在现代浏览器（通过 Ruffle.js）运行的所有相关文件。

## 📁 文件结构

```
ruffle_implementation/
├── README.md                    # 本文件
├── RUFFLE_MIGRATION.md          # 完整的技术方案文档
├── index_ruffle.html            # Ruffle 测试页面
└── websocket_proxy/             # WebSocket 代理服务器
    ├── server.js                # Node.js 代理服务器
    ├── package.json             # NPM 依赖配置
    └── README.md                # 代理服务器说明
```

## 🎯 目标

让赛尔号 Flash 游戏在现代浏览器运行，无需 Flash Player 插件。

## ⚠️ 当前状态

**未实现** - 这是一个未来的功能计划。

## 🔧 核心问题

1. **Ruffle 不支持 Socket**：赛尔号使用 TCP Socket 连接游戏服务器，但 Ruffle.js 不支持
2. **需要修改源码**：必须修改 Flash 客户端源码，将 Socket 改为 WebSocket
3. **需要重新编译**：修改后需要重新编译所有 SWF 文件

## 📋 实现步骤（未来）

### 第一步：修改 Flash 客户端
- [ ] 创建 `WebSocketAdapter.as` 类
- [ ] 替换所有 `Socket` / `XMLSocket` 为 `WebSocketAdapter`
- [ ] 添加 JavaScript 桥接代码
- [ ] 重新编译所有 DLL（TaomeeLibraryDLL, RobotCoreDLL 等）

### 第二步：部署 WebSocket 代理
- [x] 创建 Node.js WebSocket 代理服务器（已完成）
- [ ] 测试代理转发功能
- [ ] 优化性能和错误处理

### 第三步：集成测试
- [ ] 在 Ruffle 中加载修改后的 SWF
- [ ] 测试登录流程
- [ ] 测试游戏功能
- [ ] 修复兼容性问题

## 🚀 快速开始（当实现时）

### 1. 启动游戏服务器
```bash
cd luvit_version
.\luvit.exe .\reseer.lua
```

### 2. 启动 WebSocket 代理
```bash
cd ruffle_implementation/websocket_proxy
npm install
npm start
```

### 3. 打开浏览器
访问 `http://127.0.0.1:32400/` 并加载修改后的游戏。

## 📚 文档

详细的技术方案请查看：
- **RUFFLE_MIGRATION.md** - 完整的迁移方案和代码示例

## 🔄 替代方案

如果 Ruffle 方案太复杂，可以考虑：

1. **Flash Player Projector**（推荐）
   - 下载独立 Flash 播放器
   - 无需修改代码
   - 完全兼容

2. **Electron + Flash PPAPI**
   - 打包成桌面应用
   - 内嵌 Flash 插件
   - 跨平台

3. **HTML5 重写**（长期方案）
   - 用 Phaser.js 或 PixiJS 重写客户端
   - 完全现代化
   - 工作量巨大

## 📝 注意事项

- 这个方案需要 ActionScript 3 开发经验
- 需要 Adobe Flex SDK 或 Apache Flex SDK
- WebSocket 代理会增加一点延迟（但对回合制游戏影响不大）
- Ruffle 仍在开发中，可能有兼容性问题

## 🔗 相关链接

- [Ruffle 官网](https://ruffle.rs/)
- [Ruffle GitHub](https://github.com/ruffle-rs/ruffle)
- [Adobe Flex SDK](https://www.adobe.com/devnet/flex/flex-sdk-download.html)
- [Apache Flex SDK](https://flex.apache.org/)

---

**状态**：未实现 | **优先级**：低 | **难度**：高
