# 赛尔号 Ruffle 迁移方案

## 目标
让赛尔号在现代浏览器（通过 Ruffle.js）运行，无需 Flash Player 插件。

## 核心问题
- **问题**：Ruffle 不支持 `Socket` / `XMLSocket`（TCP 连接）
- **原因**：浏览器安全限制，JavaScript 无法直接创建 TCP Socket
- **解决**：使用 WebSocket 替代，通过代理服务器转换为 TCP

## 技术方案

### 架构图
```
┌─────────────┐    WebSocket    ┌──────────────┐    TCP Socket    ┌──────────────┐
│   浏览器    │ ◄─────────────► │ WebSocket    │ ◄──────────────► │  游戏服务器  │
│  (Ruffle)   │                 │    代理      │                  │  (Lua/Luvit) │
└─────────────┘                 └──────────────┘                  └──────────────┘
```

### 实现步骤

## 第一步：修改 Flash 客户端

### 1.1 创建 WebSocket 适配器

在 `front-end scripts/TaomeeLibraryDLL/` 创建 `WebSocketAdapter.as`：

```actionscript
package org.taomee.net {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.external.ExternalInterface;
    
    /**
     * WebSocket 适配器 - 兼容原有 Socket API
     * 通过 ExternalInterface 调用浏览器的 WebSocket
     */
    public class WebSocketAdapter extends EventDispatcher {
        private var _host:String;
        private var _port:int;
        private var _connected:Boolean = false;
        private var _wsId:String;
        
        public function WebSocketAdapter() {
            // 注册 JavaScript 回调
            if (ExternalInterface.available) {
                ExternalInterface.addCallback("onWebSocketOpen", onOpen);
                ExternalInterface.addCallback("onWebSocketMessage", onMessage);
                ExternalInterface.addCallback("onWebSocketClose", onClose);
                ExternalInterface.addCallback("onWebSocketError", onError);
            }
        }
        
        public function connect(host:String, port:int):void {
            _host = host;
            _port = port;
            _wsId = "ws_" + Math.random().toString(36).substr(2, 9);
            
            // 调用 JavaScript 创建 WebSocket
            if (ExternalInterface.available) {
                ExternalInterface.call("createWebSocket", _wsId, host, port);
            }
        }
        
        public function send(data:*):void {
            if (!_connected) return;
            
            // 将数据转换为 Base64 或 ArrayBuffer
            var bytes:Array = [];
            if (data is String) {
                for (var i:int = 0; i < data.length; i++) {
                    bytes.push(data.charCodeAt(i));
                }
            }
            
            if (ExternalInterface.available) {
                ExternalInterface.call("sendWebSocketData", _wsId, bytes);
            }
        }
        
        public function close():void {
            if (ExternalInterface.available) {
                ExternalInterface.call("closeWebSocket", _wsId);
            }
            _connected = false;
        }
        
        // JavaScript 回调
        private function onOpen():void {
            _connected = true;
            dispatchEvent(new Event(Event.CONNECT));
        }
        
        private function onMessage(data:Array):void {
            // 将字节数组转换为 ByteArray
            var bytes:String = "";
            for each (var byte:int in data) {
                bytes += String.fromCharCode(byte);
            }
            dispatchEvent(new DataEvent(bytes));
        }
        
        private function onClose():void {
            _connected = false;
            dispatchEvent(new Event(Event.CLOSE));
        }
        
        private function onError(error:String):void {
            dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, error));
        }
        
        public function get connected():Boolean {
            return _connected;
        }
    }
}
```

### 1.2 修改网络连接代码

找到游戏中使用 `Socket` 或 `XMLSocket` 的地方，替换为 `WebSocketAdapter`。

例如，在 `RobotCoreDLL` 中：

```actionscript
// 原代码
private var _socket:Socket = new Socket();
_socket.connect("127.0.0.1", 5001);

// 修改为
private var _socket:WebSocketAdapter = new WebSocketAdapter();
_socket.connect("127.0.0.1", 5001);
```

### 1.3 重新编译 SWF

使用 Adobe Flex SDK 或 Apache Flex SDK 重新编译所有 DLL：

```bash
# 编译 TaomeeLibraryDLL
mxmlc -output=TaomeeLibraryDLL.swf -library-path+=libs TaomeeLibraryDLL.as

# 编译 RobotCoreDLL
mxmlc -output=RobotCoreDLL.swf -library-path+=libs RobotCoreDLL.as
```

## 第二步：创建 WebSocket 代理服务器

### 2.1 Node.js 版本（推荐）

创建 `websocket_proxy/server.js`：

```javascript
const WebSocket = require('ws');
const net = require('net');

const WS_PORT = 8765;
const GAME_SERVER_HOST = '127.0.0.1';
const GAME_SERVER_PORT = 5001;

const wss = new WebSocket.Server({ port: WS_PORT });

console.log(`WebSocket Proxy listening on port ${WS_PORT}`);
console.log(`Forwarding to ${GAME_SERVER_HOST}:${GAME_SERVER_PORT}`);

wss.on('connection', (ws) => {
    console.log('[WS] Client connected');
    
    // 创建到游戏服务器的 TCP 连接
    const tcpSocket = net.createConnection({
        host: GAME_SERVER_HOST,
        port: GAME_SERVER_PORT
    });
    
    tcpSocket.on('connect', () => {
        console.log('[TCP] Connected to game server');
    });
    
    // WebSocket -> TCP
    ws.on('message', (data) => {
        console.log(`[WS->TCP] ${data.length} bytes`);
        tcpSocket.write(Buffer.from(data));
    });
    
    // TCP -> WebSocket
    tcpSocket.on('data', (data) => {
        console.log(`[TCP->WS] ${data.length} bytes`);
        ws.send(data);
    });
    
    // 错误处理
    ws.on('close', () => {
        console.log('[WS] Client disconnected');
        tcpSocket.end();
    });
    
    tcpSocket.on('close', () => {
        console.log('[TCP] Connection closed');
        ws.close();
    });
    
    ws.on('error', (err) => console.error('[WS] Error:', err));
    tcpSocket.on('error', (err) => console.error('[TCP] Error:', err));
});
```

安装依赖并运行：

```bash
npm install ws
node server.js
```

### 2.2 Lua 版本（集成到现有服务器）

创建 `luvit_version/websocket_proxy.lua`：

```lua
local WebSocket = require('websocket')
local net = require('net')

local WS_PORT = 8765
local GAME_SERVER_HOST = '127.0.0.1'
local GAME_SERVER_PORT = 5001

-- WebSocket 服务器
local wsServer = WebSocket.createServer(function(ws)
    print('[WS] Client connected')
    
    -- 创建到游戏服务器的 TCP 连接
    local tcpSocket = net.createConnection(GAME_SERVER_PORT, GAME_SERVER_HOST, function()
        print('[TCP] Connected to game server')
    end)
    
    -- WebSocket -> TCP
    ws:on('message', function(data)
        print(string.format('[WS->TCP] %d bytes', #data))
        tcpSocket:write(data)
    end)
    
    -- TCP -> WebSocket
    tcpSocket:on('data', function(data)
        print(string.format('[TCP->WS] %d bytes', #data))
        ws:send(data)
    end)
    
    -- 错误处理
    ws:on('close', function()
        print('[WS] Client disconnected')
        tcpSocket:destroy()
    end)
    
    tcpSocket:on('close', function()
        print('[TCP] Connection closed')
        ws:close()
    end)
end)

wsServer:listen(WS_PORT)
print(string.format('WebSocket Proxy listening on port %d', WS_PORT))
```

## 第三步：修改 HTML 页面

创建 JavaScript WebSocket 桥接：

```html
<script>
// WebSocket 管理器
const webSockets = {};

function createWebSocket(id, host, port) {
    const ws = new WebSocket(`ws://127.0.0.1:8765`);
    
    ws.binaryType = 'arraybuffer';
    
    ws.onopen = () => {
        console.log(`[WS:${id}] Connected`);
        // 通知 Flash
        document.getElementById('seer-game').onWebSocketOpen();
    };
    
    ws.onmessage = (event) => {
        const data = new Uint8Array(event.data);
        const bytes = Array.from(data);
        // 通知 Flash
        document.getElementById('seer-game').onWebSocketMessage(bytes);
    };
    
    ws.onclose = () => {
        console.log(`[WS:${id}] Closed`);
        document.getElementById('seer-game').onWebSocketClose();
    };
    
    ws.onerror = (error) => {
        console.error(`[WS:${id}] Error:`, error);
        document.getElementById('seer-game').onWebSocketError(error.toString());
    };
    
    webSockets[id] = ws;
}

function sendWebSocketData(id, bytes) {
    const ws = webSockets[id];
    if (ws && ws.readyState === WebSocket.OPEN) {
        const buffer = new Uint8Array(bytes);
        ws.send(buffer);
    }
}

function closeWebSocket(id) {
    const ws = webSockets[id];
    if (ws) {
        ws.close();
        delete webSockets[id];
    }
}
</script>
```

## 测试流程

1. **启动游戏服务器**
   ```bash
   cd luvit_version
   .\luvit.exe .\reseer.lua
   ```

2. **启动 WebSocket 代理**
   ```bash
   cd websocket_proxy
   node server.js
   ```

3. **打开浏览器**
   访问 `http://127.0.0.1:32400/index_ruffle.html`

## 预期结果

- ✅ 游戏在 Ruffle 中加载
- ✅ 通过 WebSocket 连接到代理
- ✅ 代理转发到游戏服务器
- ✅ 游戏正常运行

## 注意事项

1. **性能**：WebSocket 代理会增加一点延迟，但对回合制游戏影响不大
2. **安全**：WebSocket 代理应该只监听 localhost，不要暴露到公网
3. **兼容性**：需要测试所有游戏功能，确保 Ruffle 支持
4. **调试**：使用浏览器开发者工具查看 WebSocket 通信

## 替代方案

如果修改 Flash 源码太复杂，可以考虑：

1. **Electron + Flash PPAPI**：打包成桌面应用
2. **HTML5 重写**：用 Phaser.js 或 PixiJS 重写客户端
3. **Flash Player Projector**：独立 Flash 播放器（最简单）
