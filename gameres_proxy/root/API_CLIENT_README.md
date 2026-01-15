# 赛尔号 API 客户端文档

## 概述

这个 API 客户端实现了官服的核心网络功能，包括：

- ✅ **服务器轮询** - 自动尝试多个服务器，实现故障转移
- ✅ **请求封装** - 统一的 HTTP 请求接口（GET/POST/PUT/DELETE）
- ✅ **加密支持** - 简单的字符串加密/解密功能
- ✅ **超时控制** - 可配置的请求超时
- ✅ **错误处理** - 完善的错误捕获和处理机制

## 文件结构

```
gameres_proxy/root/js/
├── api-client.js       # API 客户端核心实现
├── api-examples.js     # 使用示例和游戏 API 封装
├── config.js           # 全局配置管理
└── login.js            # 登录逻辑（已集成 API 客户端）

gameres_proxy/root/
├── index.html          # 登录页面（已引入 API 客户端）
└── api-test.html       # API 测试工具页面
```

## 快速开始

### 1. 基础配置

在 HTML 中引入脚本：

```html
<script src="/js/api-client.js"></script>
<script src="/js/config.js"></script>
```

### 2. 配置服务器列表

在 `application-config.js` 或页面中配置：

```javascript
window.applicationConfig = {
    // 单个服务器
    VITE_APP_BASE_API: 'http://127.0.0.1:8211',
    
    // 或多个服务器（支持故障转移）
    VITE_APP_BASE_API: [
        'http://45.125.46.70:8211',
        'http://127.0.0.1:8211',
        'http://localhost:8211'
    ]
};
```

### 3. 使用 API 客户端

```javascript
const api = window.SeerApiClient;

// GET 请求
const response = await api.get('/api/status');

// POST 请求
const result = await api.post('/api/login', {
    username: 'user',
    password: 'pass'
});
```

## API 参考

### 核心方法

#### `get(url, config)`

发送 GET 请求。

```javascript
// 简单请求
await api.get('/api/user/info');

// 带参数
await api.get('/api/user/info', {
    params: {
        userId: 123,
        includeDetails: true
    }
});

// 自定义 headers
await api.get('/api/protected', {
    headers: {
        'Authorization': 'Bearer token'
    }
});
```

#### `post(url, data, config)`

发送 POST 请求。

```javascript
await api.post('/api/login', {
    username: 'user',
    password: 'pass'
});
```

#### `put(url, data, config)` / `delete(url, config)`

发送 PUT/DELETE 请求。

```javascript
await api.put('/api/user/123', { name: 'New Name' });
await api.delete('/api/user/123');
```

#### `requestWithFallback(config)`

使用服务器轮询的请求（自动故障转移）。

```javascript
await api.requestWithFallback({
    method: 'GET',
    url: '/api/test',
    timeout: 5000
});
```

### 配置选项

所有请求方法都支持以下配置：

```javascript
{
    method: 'GET',           // HTTP 方法
    url: '/api/endpoint',    // 请求路径
    baseURL: 'http://...',   // 基础 URL（可选）
    data: {},                // 请求体数据
    params: {},              // URL 查询参数
    headers: {},             // 自定义 headers
    timeout: 120000          // 超时时间（毫秒）
}
```

### 加密功能

```javascript
const encryption = api.encryption;

// 加密
const encrypted = encryption.encrypt('Hello Seer!');

// 解密
const decrypted = encryption.decrypt(encrypted);
```

## 服务器轮询机制

### 工作原理

1. 客户端维护一个服务器列表
2. 发起请求时，按顺序尝试每个服务器
3. 第一个成功响应的服务器会被"锁定"
4. 后续请求优先使用锁定的服务器
5. 如果锁定的服务器失败，重新轮询

### 示例

```javascript
// 配置多个服务器
api.serverList = [
    'http://server1.com',
    'http://server2.com',
    'http://server3.com'
];

// 自动轮询
try {
    const response = await api.get('/api/test');
    console.log('成功连接到:', api.currentBaseURL);
} catch (error) {
    console.error('所有服务器均不可用');
}
```

## 游戏 API 封装

`api-examples.js` 提供了游戏相关的 API 封装：

```javascript
const GameAPI = window.SeerAPIExamples.GameAPI;

// 获取精灵信息
await GameAPI.getPetInfo(petId);

// 获取用户精灵列表
await GameAPI.getUserPets(userId);

// 开始战斗
await GameAPI.startBattle(battleData);

// 获取服务器列表
await GameAPI.getServerList();

// 获取公告
await GameAPI.getNotices();
```

## 错误处理

### 错误类型

1. **超时错误** - 请求超过设定时间
2. **网络错误** - 无法连接到服务器
3. **HTTP 错误** - 服务器返回错误状态码
4. **服务器不可用** - 所有服务器都失败

### 处理示例

```javascript
try {
    const response = await api.get('/api/test');
} catch (error) {
    if (error.message.includes('超时')) {
        console.log('请求超时');
    } else if (error.message.includes('不可用')) {
        console.log('服务器不可用');
    } else {
        console.log('其他错误:', error.message);
    }
}
```

## 测试工具

访问 `/api-test.html` 可以使用可视化测试工具：

- 服务器状态检测
- 基础请求测试
- 服务器轮询测试
- 加密功能测试
- 游戏 API 测试
- 错误处理测试

## 与官服的对应关系

| 官服组件 | 私服实现 | 说明 |
|---------|---------|------|
| `to-DkkR2BwR.js` | `api-client.js` | 核心网络层 |
| `ct` 变量 | `serverList` | 服务器列表 |
| `Qn` 函数 | `requestWithFallback()` | 服务器轮询 |
| `ht` 类 | `SimpleEncryption` | 加密类 |
| `pt` 类 | `GameAPI` | 游戏配置和API |
| `window.applicationConfig` | `window.applicationConfig` | 全局配置 |

## 集成到现有代码

### 在登录页面中使用

```javascript
// login.js 已经集成
const server = window.SeerConfig.getCurrentServer();
const apiServers = server.apiServers;

// API 客户端会自动使用配置的服务器列表
const response = await window.SeerApiClient.get('/api/login');
```

### 在游戏页面中使用

```javascript
// 引入脚本
<script src="/js/api-client.js"></script>

// 使用
const api = window.SeerApiClient;
const petInfo = await api.get('/api/pet/123');
```

## 调试技巧

### 查看当前配置

```javascript
console.log('服务器列表:', api.serverList);
console.log('当前锁定:', api.currentBaseURL);
console.log('超时设置:', api.timeout);
```

### 手动切换服务器

```javascript
// 重置锁定的服务器
api.currentBaseURL = null;

// 修改服务器列表
api.serverList = ['http://new-server.com'];
```

### 监控请求

所有请求都会在控制台输出日志：

```
尝试服务器 [1/3]: http://server1.com
服务器 http://server1.com 请求失败: Network Error
尝试服务器 [2/3]: http://server2.com
已锁定服务器: http://server2.com
```

## 性能优化

1. **服务器锁定** - 成功后锁定服务器，减少轮询
2. **超时控制** - 避免长时间等待
3. **并发请求** - 支持多个请求同时进行
4. **错误缓存** - 可以实现失败服务器的临时屏蔽

## 未来扩展

可以添加的功能：

- [ ] 请求重试机制
- [ ] 请求队列管理
- [ ] 响应缓存
- [ ] WebSocket 支持
- [ ] 请求拦截器
- [ ] 响应拦截器
- [ ] 更复杂的加密算法
- [ ] 请求签名验证

## 常见问题

### Q: 如何添加新的服务器？

```javascript
api.serverList.push('http://new-server.com');
```

### Q: 如何禁用服务器轮询？

```javascript
// 只使用一个服务器
api.serverList = ['http://single-server.com'];
```

### Q: 如何修改超时时间？

```javascript
// 全局修改
api.timeout = 60000; // 60秒

// 单次请求修改
await api.get('/api/test', { timeout: 5000 });
```

### Q: 如何处理跨域问题？

服务器需要设置 CORS headers：

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
```

## 许可证

与主项目相同。

## 贡献

欢迎提交 Issue 和 Pull Request！
