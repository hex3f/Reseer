// 赛尔号 WebSocket 监控器 - 控制台版本
// 直接复制到浏览器控制台运行即可

(function() {
    'use strict';

    // 赛尔号命令列表
    const CMD_NAMES = {
        105: '获取服务器列表',
        106: '获取指定范围服务器',
        109: '登录验证',
        111: '初始化连接',
        112: '心跳',
        1001: '进入地图',
        1002: '离开地图',
        1003: '移动',
        1004: '聊天',
        1005: '获取地图用户',
        1006: '获取用户信息',
        2001: '获取精灵信息',
        2002: '获取背包',
        2003: '使用物品',
        2004: '获取任务',
        2005: '完成任务',
        2401: '战斗开始',
        2402: '战斗回合',
        2403: '战斗结束',
        2404: '战斗逃跑',
        3001: '获取好友列表',
        3002: '添加好友',
        3003: '删除好友',
        9999: '心跳'
    };

    // ArrayBuffer 转十六进制
    function toHex(buffer, max = 80) {
        const bytes = new Uint8Array(buffer);
        let hex = [];
        for (let i = 0; i < Math.min(bytes.length, max); i++) {
            hex.push(bytes[i].toString(16).padStart(2, '0').toUpperCase());
        }
        return hex.join(' ') + (bytes.length > max ? '...' : '');
    }

    // 解析数据包头部
    function parseHeader(buffer) {
        if (buffer.byteLength < 17) return null;
        const view = new DataView(buffer);
        return {
            length: view.getUint32(0, false),
            version: view.getUint8(4),
            cmdId: view.getUint32(5, false),
            userId: view.getUint32(9, false),
            result: view.getInt32(13, false)
        };
    }

    // 存储所有日志
    window.wsLogs = [];

    // Hook WebSocket
    const OrigWS = window.WebSocket;
    window.WebSocket = function(url, protocols) {
        console.log('%c🔌 WebSocket 连接: ' + url, 'color: #00ff00; font-weight: bold; font-size: 14px;');

        const ws = protocols ? new OrigWS(url, protocols) : new OrigWS(url);
        ws._url = url;

        ws.addEventListener('open', () => {
            console.log('%c✅ WebSocket 已连接: ' + url, 'color: #00ff00;');
        });

        ws.addEventListener('close', (e) => {
            console.log('%c❌ WebSocket 已关闭: ' + url + ' (code=' + e.code + ')', 'color: #ff0000;');
        });

        ws.addEventListener('error', () => {
            console.log('%c⚠️ WebSocket 错误: ' + url, 'color: #ff0000;');
        });

        ws.addEventListener('message', (e) => {
            const time = new Date().toTimeString().split(' ')[0];
            if (e.data instanceof ArrayBuffer) {
                const header = parseHeader(e.data);
                const cmdName = header ? (CMD_NAMES[header.cmdId] || '未知') : '?';

                console.log('%c📥 [' + time + '] 接收', 'color: #0096ff; font-weight: bold;',
                    header ? `CMD=${header.cmdId} (${cmdName}) UID=${header.userId} LEN=${header.length} RES=${header.result}` : '');
                console.log('   HEX:', toHex(e.data));

                window.wsLogs.push({ time, dir: 'recv', header, hex: toHex(e.data, 200) });
            } else if (e.data instanceof Blob) {
                e.data.arrayBuffer().then(buf => {
                    const header = parseHeader(buf);
                    const cmdName = header ? (CMD_NAMES[header.cmdId] || '未知') : '?';
                    console.log('%c📥 [' + time + '] 接收 (Blob)', 'color: #0096ff; font-weight: bold;',
                        header ? `CMD=${header.cmdId} (${cmdName})` : '');
                    console.log('   HEX:', toHex(buf));
                    window.wsLogs.push({ time, dir: 'recv', header, hex: toHex(buf, 200) });
                });
            } else {
                console.log('%c📥 [' + time + '] 接收 (文本)', 'color: #0096ff;', e.data);
            }
        });

        const origSend = ws.send.bind(ws);
        ws.send = function(data) {
            const time = new Date().toTimeString().split(' ')[0];
            if (data instanceof ArrayBuffer) {
                const header = parseHeader(data);
                const cmdName = header ? (CMD_NAMES[header.cmdId] || '未知') : '?';

                console.log('%c📤 [' + time + '] 发送', 'color: #ff6400; font-weight: bold;',
                    header ? `CMD=${header.cmdId} (${cmdName}) UID=${header.userId} LEN=${header.length}` : '');
                console.log('   HEX:', toHex(data));

                window.wsLogs.push({ time, dir: 'send', header, hex: toHex(data, 200) });
            } else if (data instanceof Uint8Array) {
                const header = parseHeader(data.buffer);
                const cmdName = header ? (CMD_NAMES[header.cmdId] || '未知') : '?';
                console.log('%c📤 [' + time + '] 发送', 'color: #ff6400; font-weight: bold;',
                    header ? `CMD=${header.cmdId} (${cmdName})` : '');
                console.log('   HEX:', toHex(data.buffer));
                window.wsLogs.push({ time, dir: 'send', header, hex: toHex(data.buffer, 200) });
            } else {
                console.log('%c📤 [' + time + '] 发送 (文本)', 'color: #ff6400;', data);
            }
            return origSend(data);
        };

        return ws;
    };
    window.WebSocket.prototype = OrigWS.prototype;
    window.WebSocket.CONNECTING = OrigWS.CONNECTING;
    window.WebSocket.OPEN = OrigWS.OPEN;
    window.WebSocket.CLOSING = OrigWS.CLOSING;
    window.WebSocket.CLOSED = OrigWS.CLOSED;

    // 导出日志函数
    window.exportWsLogs = function() {
        const blob = new Blob([JSON.stringify(window.wsLogs, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'seer_ws_logs_' + Date.now() + '.json';
        a.click();
    };

    console.log('%c🔌 赛尔号 WebSocket 监控器已启动!', 'color: #00ff00; font-weight: bold; font-size: 16px;');
    console.log('%c输入 window.wsLogs 查看所有日志', 'color: #888;');
    console.log('%c输入 window.exportWsLogs() 导出日志', 'color: #888;');
})();
