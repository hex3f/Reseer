# 房间离开功能调试记录

## 问题描述
在本地服务器模式下，用户可以进入房间，但无法离开房间。离开房间时客户端会断开连接。

## 已完成的修改

### 1. RoomController.as 修改

#### getRoomAddres() 方法
- 强制设置 `_isIlk = true`，确保使用本地模式

#### connect() 方法
- 当 `_isIlk=true` 时：
  - 设置 `_isConnect = true`
  - 设置 `roomSocket.ip` 和 `roomSocket.port`
  - 使用 `setTimeout` 异步触发 `Event.CONNECT` 事件
  - 返回，不创建新的socket连接

#### outRoom() 方法
- 当 `_isIlk=true` 时：
  - 不调用 `close()`
  - 直接设置 `_isConnect = false`
  - 触发 `LEAVE_ROOM` 事件

#### close() 方法
- 当 `_isIlk=true` 时，不关闭socket

#### onClose() 方法
- 当 `_isIlk=true` 时，直接返回，不处理断开逻辑

### 2. MapController.as 修改

#### comeInMap() 方法
- 修改了从房间切换到另一个房间的逻辑
- 当 `_isIlk=true` 时，也调用 `connect()` 方法，而不是直接发送 `ENTER_MAP` 命令

## 当前问题

### 症状
从日志看，客户端执行流程：
1. 发送 `FITMENT_USERING` 命令（获取家具信息）
2. 发送 `GET_ROOM_ADDRES` 命令（获取房间地址）
3. 发送 `LEAVE_MAP` 命令（离开当前地图）
4. 收到 `LEAVE_MAP` 响应后停止，没有继续执行

### 预期行为
收到 `LEAVE_MAP` 响应后，应该：
1. `onLeaveMap()` 被调用
2. 检查 `_isChange` 标志
3. 调用 `comeInMap()`
4. 调用 `connect()`
5. 触发 `Event.CONNECT` 事件
6. 调用 `onRoomConnect()`
7. 发送 `ROOM_LOGIN` 命令

### 可能的原因
1. `_isChange` 标志没有被正确设置
2. `onLeaveMap()` 中的条件检查失败
3. `comeInMap()` 没有被调用
4. 客户端在某个地方卡住了

## 下一步调试建议

1. 检查 `_isChange` 标志是否在 `startSwitch()` 中被正确设置
2. 检查 `onLeaveMap()` 方法中的条件判断
3. 检查是否有其他地方在拦截 `LEAVE_MAP` 响应
4. 添加客户端日志来追踪执行流程

## 相关文件
- `front-end scripts/NieoCore scripts/com/robot/core/controller/RoomController.as`
- `front-end scripts/NieoCore scripts/com/robot/core/controller/MapController.as`
- `luvit_version/handlers/room_handlers.lua`
- `luvit_version/handlers/map_handlers.lua`
