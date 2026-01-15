# 登录实现说明

## 文件结构

```
gameres_proxy/root/
├── js/
│   ├── official-api-adapter.js  # 官服API适配器（模拟to-DkkR2BwR.js）
│   ├── api-client.js            # 通用API客户端
│   └── config.js                # 全局配置
├── login-official.html          # Vue登录页面（使用官服API）
├── login-vue.html               # 简化Vue登录页面
└── test-login.html              # 登录功能测试页面
```

## 测试步骤

1. **启动服务器**
   ```bash
   cd luvit_version
   luvit reseer.lua
   ```

2. **访问测试页面**
   - 登录测试: http://127.0.0.1:32400/test-login.html
   - Vue登录: http://127.0.0.1:32400/login-official.html

3. **测试登录**
   - 用户名: test@qq.com
   - 密码: 123456
   - 点击"测试登录"按钮

## API 接口

### POST /seer/login
登录接口（已在 apiserver.lua 实现）

**请求:**
```json
{
  "username": "test@qq.com",
  "password": "123456"
}
```

**响应:**
```json
{
  "code": 200,
  "message": "success",
  "session": "local_1234567890",
  "username": "test@qq.com"
}
```

## 官服API映射

| 官服函数 | 适配器函数 | 说明 |
|---------|-----------|------|
| Se/Er | OfficialAPI.Se() | 登录 |
| Ce/br | OfficialAPI.Ce() | 获取会话 |
| X | OfficialAPI.X | 加密工具 |
| f | OfficialAPI.f | 配置对象 |
| E | OfficialAPI.E() | Promise包装 |
| l | OfficialAPI.l | 本地存储 |
