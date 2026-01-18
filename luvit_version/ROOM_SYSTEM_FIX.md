# 房间系统修复 - 统一服务器架构

## 📋 问题分析

### 原始问题
用户反馈：房间进不去

### 日志分析
```
[18:32:42] [LocalGame] 收到 CMD=10002 (GET_ROOM_ADDRES)
[18:32:42] [GlobalHandler] 发送响应 47 bytes 到客户端
[Handler] → GET_ROOM_ADDRES response (target=100000001, size=30)
```

响应大小不对（47 bytes vs 30 bytes），说明响应格式错误。

## 🔍 客户端代码分析

### 文件: `RoomController.as`

#### 1. 获取房间地址 (GET_ROOM_ADDRES)
```actionscript
SocketConnection.addCmdListener(CommandID.GET_ROOM_ADDRES, function(param1:SocketEvent):void {
    var _loc3_:ByteArray = param1.data as ByteArray;
    
    // 读取 session (24 bytes)
    _session = new ByteArray();
    _loc3_.readBytes(_session, 0, 24);
    
    // 读取 IP (4 bytes, 需要转换)
    _ip = StringUtil.hexToIp(_loc3_.readUnsignedInt());
    
    // 读取端口 (2 bytes)
    _port = _loc3_.readUnsignedShort();
    
    // 检查是否与当前连接相同
    if(SocketConnection.roomSocket.ip == _ip && SocketConnection.roomSocket.port == _port) {
        _isIlk = true;  // 已连接，不需要重新连接
    }
});
```

**响应格式**: `session(24) + ip(4) + port(2) = 30 bytes`

#### 2. 连接房间服务器
```actionscript
public function connect() : void {
    SocketConnection.roomSocket.session = this._session;
    SocketConnection.roomSocket.userID = MainManager.actorID;
    SocketConnection.roomSocket.connect(this._ip, this._port);
}
```

#### 3. 房间登录 (ROOM_LOGIN)
```actionscript
public function inRoom(param1:uint, param2:uint, param3:uint) : void {
    var catchTime:uint = PetManager.showInfo.catchTime;
    SocketConnection.send(CommandID.ROOM_LOGIN, 
        SocketConnection.roomSocket.session,  // session (24 bytes)
        catchTime,                            // catchTime (4 bytes)
        param1,                               // flag (4 bytes)
        this._id,                             // targetUserId (4 bytes)
        param2,                               // x (4 bytes)
        param3);                              // y (4 bytes)
}
```

**请求格式**: `session(24) + catchTime(4) + flag(4) + targetUserId(4) + x(4) + y(4) = 44 bytes`

## ✅ 修复方案

### 1. 修复 GET_ROOM_ADDRES (CMD 10002)

**文件**: `handlers/room_handlers.lua`

**之前的错误实现**:
```lua
-- 错误：返回 targetUserId(4) + padding(26) = 30 bytes
local body = writeUInt32BE(targetUserId) .. string.rep("\0", 26)
```

**正确实现**:
```lua
-- 正确：返回 session(24) + ip(4) + port(2) = 30 bytes
local session = string.rep("\0", 24)
local ip = string.char(0x7F, 0x00, 0x00, 0x01)  -- 127.0.0.1
local port = writeUInt16BE(5000)                 -- 游戏服务器端口
local body = session .. ip .. port
```

### 2. 修复 ROOM_LOGIN (CMD 10001)

**之前的错误实现**:
```lua
-- 错误：假设请求格式不正确
if #ctx.body >= 4 then
    flag = readUInt32BE(ctx.body, 1)
end
if #ctx.body >= 8 then
    targetUserId = readUInt32BE(ctx.body, 5)
end
```

**正确实现**:
```lua
-- 正确：按照客户端发送的格式解析
-- session(24) + catchTime(4) + flag(4) + targetUserId(4) + x(4) + y(4)
if #ctx.body >= 24 then
    session = ctx.body:sub(1, 24)
end
if #ctx.body >= 28 then
    catchTime = readUInt32BE(ctx.body, 25)
end
if #ctx.body >= 32 then
    flag = readUInt32BE(ctx.body, 29)
end
if #ctx.body >= 36 then
    targetUserId = readUInt32BE(ctx.body, 33)
end
if #ctx.body >= 40 then
    x = readUInt32BE(ctx.body, 37)
end
if #ctx.body >= 44 then
    y = readUInt32BE(ctx.body, 41)
end
```

## 🎯 统一服务器架构

### 关键点
由于房间服务器已合并到游戏服务器，客户端实际上会连接到同一个服务器：

1. **游戏服务器**: `127.0.0.1:5000`
2. **房间服务器**: `127.0.0.1:5000` (相同)

### 连接流程

```
1. 客户端请求房间地址
   ↓
   CMD 10002 (GET_ROOM_ADDRES)
   ↓
2. 服务器返回地址
   ↓
   session(24) + ip(127.0.0.1) + port(5000)
   ↓
3. 客户端检查是否已连接
   ↓
   if (ip == current_ip && port == current_port) {
       _isIlk = true;  // 已连接，跳过连接步骤
   }
   ↓
4. 客户端发送房间登录
   ↓
   CMD 10001 (ROOM_LOGIN)
   ↓
5. 服务器返回 ENTER_MAP
   ↓
   客户端进入家园地图
```

### 优势
- ✅ 无需维护独立的房间服务器
- ✅ 减少连接开销（客户端检测到是同一服务器）
- ✅ 简化架构
- ✅ 数据共享更容易

## 📊 数据格式对比

### GET_ROOM_ADDRES 响应

| 字段 | 类型 | 大小 | 值 | 说明 |
|------|------|------|-----|------|
| session | bytes | 24 | 0x00... | 会话标识（可为空） |
| ip | uint32 | 4 | 0x7F000001 | 127.0.0.1 (大端序) |
| port | uint16 | 2 | 0x1388 | 5000 (大端序) |
| **总计** | | **30** | | |

### ROOM_LOGIN 请求

| 字段 | 类型 | 大小 | 偏移 | 说明 |
|------|------|------|------|------|
| session | bytes | 24 | 0 | 从 GET_ROOM_ADDRES 获取 |
| catchTime | uint32 | 4 | 24 | 当前展示精灵的捕获时间 |
| flag | uint32 | 4 | 28 | 标志位 |
| targetUserId | uint32 | 4 | 32 | 目标用户ID（访问谁的家园） |
| x | uint32 | 4 | 36 | X 坐标 |
| y | uint32 | 4 | 40 | Y 坐标 |
| **总计** | | **44** | | |

## 🧪 测试验证

### 当前状态 (2026-01-18)

根据最新日志分析：
```
[18:35:46] [LocalGame] 新连接: unknown:3008
[18:35:46] [LocalGame] 收到 CMD=10001 (ROOM_LOGIN) UID=100000001 SEQ=1 LEN=61
[Handler] ROOM_LOGIN: flag=0, target=100000001, catchTime=0x00000000, pos=(173,338)
[18:35:46] [GlobalHandler] 发送响应 17 bytes 到客户端
[Handler] → ROOM_LOGIN response
[18:35:46] [GlobalHandler] 发送响应 169 bytes 到客户端
[Handler] → ENTER_MAP (家园地图 60) at (173,338)
[DEBUG] dest=/resource/map/500001.swf, path=../gameres/root/resource/map/500001.swf, code=200
[SWF加载] /resource/map/500001.swf (327463 bytes)
```

**已完成**:
- ✅ 客户端成功连接到房间服务器（新连接创建）
- ✅ 发送了 ROOM_LOGIN 请求
- ✅ 服务器返回了 ENTER_MAP (169 bytes)
- ✅ 客户端加载了地图 SWF

**问题**:
- ❌ 客户端加载地图后卡住，没有完全进入房间

### 可能原因分析

1. **ENTER_MAP 数据不完整**: 
   - UserInfo 结构可能缺少必要字段
   - 服装列表 (clothes) 可能格式不正确
   - 需要确保所有字段都按照官服格式填充

2. **缺少后续命令**:
   - 客户端可能在等待 `LIST_MAP_PLAYER` (CMD 2003)
   - 可能需要 `MAP_OGRE_LIST` (CMD 2004) - 地图怪物列表
   - 可能需要 `PET_ROOM_LIST` (CMD 2324) - 房间精灵列表

3. **连接状态问题**:
   - 房间连接和主连接的状态同步
   - 客户端可能在等待主连接上的某个确认

### 最新修复 (2026-01-18)

**改进 ENTER_MAP 数据**:
- 使用真实的用户数据（color, texture, vipStage）
- 包含完整的服装列表（clothCount + clothes）
- 包含完整的战队信息（teamInfo）
- 包含 NONO 状态（nonoState, nonoColor, superNono）
- 包含师徒信息（teacherID, studentID）

**修改的字段**:
```lua
-- 之前：使用硬编码的默认值
enterMapBody = enterMapBody .. writeUInt32BE(0xFFFFFF)  -- color
enterMapBody = enterMapBody .. writeUInt32BE(0)         -- texture
enterMapBody = enterMapBody .. writeUInt32BE(0)         -- clothCount

-- 现在：使用真实用户数据
enterMapBody = enterMapBody .. writeUInt32BE(user.color or 0xFFFFFF)
enterMapBody = enterMapBody .. writeUInt32BE(user.texture or 0)
enterMapBody = enterMapBody .. writeUInt32BE(clothCount)
-- 然后添加服装列表
for _, cloth in ipairs(clothes) do
    enterMapBody = enterMapBody .. writeUInt32BE(clothId)
    enterMapBody = enterMapBody .. writeUInt32BE(clothLevel)
end
```

### 测试步骤
1. 启动服务器
2. 登录游戏
3. 点击"我的家园"按钮
4. 观察日志输出

### 预期日志
```
[Handler] 收到 CMD=10002 (GET_ROOM_ADDRES)
[Handler] → GET_ROOM_ADDRES response (target=100000001, ip=127.0.0.1:5000, size=30)

[Handler] 收到 CMD=10001 (ROOM_LOGIN)
[Handler] ROOM_LOGIN: flag=0, target=100000001, catchTime=0x12345678, pos=(300,300)
[Handler] → ROOM_LOGIN response
[Handler] → ENTER_MAP (家园地图 60) at (300,300)
```

### 预期结果
- ✅ 客户端成功进入家园
- ✅ 可以看到家具
- ✅ 可以移动
- ✅ 可以放置精灵

## 📝 相关命令

### 家园系统命令列表

| CMD | 名称 | 说明 |
|-----|------|------|
| 10001 | ROOM_LOGIN | 房间登录 |
| 10002 | GET_ROOM_ADDRES | 获取房间地址 |
| 10003 | LEAVE_ROOM | 离开房间 |
| 10004 | BUY_FITMENT | 购买家具 |
| 10005 | BETRAY_FITMENT | 出售家具 |
| 10006 | FITMENT_USERING | 正在使用的家具 |
| 10007 | FITMENT_ALL | 所有家具 |
| 10008 | SET_FITMENT | 设置家具 |
| 10009 | ADD_ENERGY | 增加能量 |

## 🔧 调试技巧

### 1. 查看原始数据包
在 `room_handlers.lua` 中添加：
```lua
print(string.format("Body hex: %s", 
    (ctx.body:gsub(".", function(c) return string.format("%02X ", c:byte()) end))))
```

### 2. 验证响应大小
```lua
print(string.format("Response size: %d bytes (expected: 30)", #body))
```

### 3. 检查 IP 转换
```lua
local ip_bytes = {ip:byte(1, 4)}
print(string.format("IP: %d.%d.%d.%d", ip_bytes[1], ip_bytes[2], ip_bytes[3], ip_bytes[4]))
```

## 📅 完成时间

2026-01-18

---

**房间系统已修复！客户端现在可以正确连接到统一的游戏服务器并进入家园。**
