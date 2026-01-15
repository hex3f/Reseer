# 赛尔号本地服务器 - RecSeer v2.0

## 🎯 系统架构

```
┌─────────────┐
│   浏览器    │ http://127.0.0.1:32400/
└──────┬──────┘
       │
       ├─ HTTP 请求 (资源)
       │  └─> 本地资源服务器 (ressrv.lua)
       │      ├─ 本地缓存存在 → 直接返回
       │      └─ 本地缓存不存在 → 从官服下载并保存
       │
       └─ WebSocket 连接 (游戏通信)
          └─> ws://127.0.0.1:7788
              └─> WebSocket桥接服务器 (ws_tcp_bridge.js)
                  └─> TCP连接到官服 (101.43.19.60:1863)
```

## 📦 核心组件

### 1. 资源服务器 (ressrv.lua)
- **端口**: 32400 (主) + 80 (备用)
- **功能**: 
  - 提供 Vue 前端应用
  - 代理并缓存官服资源
  - 自动保存资源到 `../gameres/root`
  - 提供本地 `ServerR.xml` (指向本地桥接服务器)

### 2. WebSocket 桥接服务器 (ws_tcp_bridge.js)
- **端口**: 7788
- **功能**: 
  - 接收浏览器的 WebSocket 连接
  - 转发到官服 TCP Socket (101.43.19.60:1863)
  - 双向数据转发

### 3. 登录服务器代理 (loginserver/trafficloggerlogin.lua)
- **端口**: 1863
- **功能**: 
  - 记录登录流量
  - 转发到官服登录服务器

## 🚀 启动步骤

### 方式一：使用启动脚本 (推荐)
```bash
cd luvit_version
start.bat
```

### 方式二：手动启动
```bash
# 1. 启动 WebSocket 桥接服务器
node ws_tcp_bridge.js

# 2. 启动主服务器
luvit reseer.lua
```

## 🌐 访问地址

启动成功后，在浏览器访问：
```
http://127.0.0.1:32400/
```

## 📊 交互流程

1. **浏览器访问** `http://127.0.0.1:32400/`
2. **加载 Vue 应用** + Ruffle 模拟器
3. **Ruffle 加载** `Client1.swf` (从官服下载并缓存)
4. **Flash 读取** `ServerR.xml` (本地配置，指向 `127.0.0.1:7788`)
5. **JavaScript 创建** `WebSocket` → `ws://127.0.0.1:7788`
6. **桥接服务器转发** 到官服 TCP (`101.43.19.60:1863`)
7. **发送命令 105** 获取服务器列表
8. **选择服务器** 后连接游戏服务器

## 📁 目录结构

```
luvit_version/
├── reseer.lua              # 主启动文件
├── ressrv.lua              # 资源服务器
├── ws_tcp_bridge.js        # WebSocket桥接服务器
├── loginserver/            # 登录服务器
├── gameserver/             # 游戏服务器
└── logs/                   # 日志目录

gameres/
└── root/                   # 官服资源缓存目录
    ├── Client1.swf
    ├── static/
    ├── assets/
    └── ...

gameres_proxy/
└── root/                   # 本地修改的资源
    ├── index.html          # 主页面
    └── config/
        └── ServerR.xml     # 本地配置 (指向127.0.0.1:7788)
```

## 🔧 配置说明

### reseer.lua 配置项

```lua
-- 资源模式
use_official_resources = true    -- 从官服下载资源
res_dir = "../gameres/root"      -- 资源保存目录

-- 服务器端口
ressrv_port = 32400              -- 资源服务器端口
login_port = 1863                -- 登录服务器端口

-- 流量记录
trafficlogger = true             -- 启用流量记录
```

### ServerR.xml 配置

```xml
<SubServer ip="127.0.0.1" port="7788"/>
```
- 指向本地 WebSocket 桥接服务器
- 桥接服务器会转发到官服 TCP

## 📝 日志说明

### 控制台日志
- 🌐 资源请求: 显示请求的 URL 和状态
- 💾 资源保存: 显示保存的文件路径和大小
- 🔌 WebSocket: 显示连接状态和数据转发

### 文件日志
- `logs/server.log` - 服务器运行日志
- `sessionlog/*.bin` - 会话数据记录

## 🐛 调试工具

### 浏览器控制台
打开浏览器开发者工具，可以看到：
- 资源加载情况
- WebSocket 连接状态
- 网络请求详情

### 油猴脚本
使用 `seer_socket_interceptor.user.js` 可以拦截和分析：
- WebSocket 消息
- Fetch 请求
- XHR 请求

## ❓ 常见问题

### Q: 服务器列表加载不出来？
A: 检查以下几点：
1. WebSocket 桥接服务器是否启动 (端口 7788)
2. `ServerR.xml` 是否指向 `127.0.0.1:7788`
3. 浏览器控制台是否有 WebSocket 连接错误

### Q: 资源加载失败？
A: 检查：
1. 网络连接是否正常
2. 官服地址是否可访问 (`61.160.213.26:12346`)
3. 本地磁盘空间是否充足

### Q: 如何清除缓存？
A: 删除 `gameres/root` 目录下的文件，重新启动服务器会自动下载

## 📚 技术栈

- **后端**: Luvit (Lua) + Node.js
- **前端**: Vue 3 + Ruffle (Flash 模拟器)
- **协议**: HTTP + WebSocket + TCP Socket

## 🔗 相关链接

- 官服地址: `http://61.160.213.26:12346/`
- 官服 API: `http://45.125.46.70:8211/`
- 官服登录服务器: `101.43.19.60:1863` (TCP)

## 📄 许可证

本项目仅供学习和研究使用。
