// ==UserScript==
// @name         赛尔号 WebSocket 监控器
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  监控赛尔号官服的所有 WebSocket 数据交互
// @author       You
// @match        *://seer.61.com/*
// @match        *://seerh5.61.com/*
// @match        *://*.61.com/*
// @match        *://127.0.0.1:*/*
// @match        *://localhost:*/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function() {
    'use strict';

    // 配置
    const CONFIG = {
        logToConsole: true,      // 是否输出到控制台
        logToPanel: true,        // 是否显示悬浮面板
        maxLogEntries: 500,      // 最大日志条数
        showHex: true,           // 是否显示十六进制
        showParsed: true,        // 是否解析数据包
        autoScroll: true         // 自动滚动
    };

    // 赛尔号命令列表（常用）
    const CMD_NAMES = {
        105: '获取服务器列表 (COMMEND_ONLINE)',
        109: '登录验证',
        111: '初始化连接',
        1001: '进入地图',
        1002: '离开地图',
        1003: '移动',
        1004: '聊天',
        2001: '获取精灵信息',
        2002: '获取背包',
        2401: '战斗开始',
        2402: '战斗回合',
        2403: '战斗结束',
        9999: '心跳'
    };

    // 日志存储
    let logEntries = [];
    let logPanel = null;
    let logContent = null;
    let wsConnections = [];

    // 工具函数：ArrayBuffer 转十六进制
    function arrayBufferToHex(buffer, maxBytes = 100) {
        const bytes = new Uint8Array(buffer);
        let hex = [];
        for (let i = 0; i < Math.min(bytes.length, maxBytes); i++) {
            hex.push(bytes[i].toString(16).padStart(2, '0').toUpperCase());
        }
        return hex.join(' ') + (bytes.length > maxBytes ? '...' : '');
    }

    // 工具函数：解析数据包头部（赛尔号协议）
    function parsePacketHeader(buffer) {
        if (buffer.byteLength < 17) return null;
        const view = new DataView(buffer);
        return {
            length: view.getUint32(0, false),      // 大端
            version: view.getUint8(4),
            cmdId: view.getUint32(5, false),       // 大端
            userId: view.getUint32(9, false),      // 大端
            result: view.getInt32(13, false)       // 大端
        };
    }

    // 工具函数：获取命令名称
    function getCmdName(cmdId) {
        return CMD_NAMES[cmdId] || `未知命令(${cmdId})`;
    }

    // 创建日志面板
    function createLogPanel() {
        if (!CONFIG.logToPanel) return;

        logPanel = document.createElement('div');
        logPanel.id = 'ws-monitor-panel';
        logPanel.innerHTML = `
            <style>
                #ws-monitor-panel {
                    position: fixed;
                    top: 10px;
                    right: 10px;
                    width: 500px;
                    height: 400px;
                    background: rgba(0, 0, 0, 0.9);
                    border: 2px solid #00ff00;
                    border-radius: 8px;
                    z-index: 999999;
                    font-family: 'Consolas', 'Monaco', monospace;
                    font-size: 11px;
                    color: #00ff00;
                    display: flex;
                    flex-direction: column;
                    resize: both;
                    overflow: hidden;
                }
                #ws-monitor-header {
                    padding: 8px 12px;
                    background: #003300;
                    border-bottom: 1px solid #00ff00;
                    cursor: move;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    user-select: none;
                }
                #ws-monitor-title {
                    font-weight: bold;
                    font-size: 13px;
                }
                #ws-monitor-controls button {
                    background: #004400;
                    border: 1px solid #00ff00;
                    color: #00ff00;
                    padding: 3px 8px;
                    margin-left: 5px;
                    cursor: pointer;
                    border-radius: 3px;
                    font-size: 10px;
                }
                #ws-monitor-controls button:hover {
                    background: #006600;
                }
                #ws-monitor-content {
                    flex: 1;
                    overflow-y: auto;
                    padding: 8px;
                }
                .ws-log-entry {
                    margin-bottom: 8px;
                    padding: 6px;
                    border-radius: 4px;
                    word-break: break-all;
                }
                .ws-log-send {
                    background: rgba(255, 100, 0, 0.2);
                    border-left: 3px solid #ff6400;
                }
                .ws-log-recv {
                    background: rgba(0, 150, 255, 0.2);
                    border-left: 3px solid #0096ff;
                }
                .ws-log-info {
                    background: rgba(100, 100, 100, 0.2);
                    border-left: 3px solid #888;
                }
                .ws-log-time {
                    color: #888;
                    font-size: 10px;
                }
                .ws-log-direction {
                    font-weight: bold;
                    margin: 0 5px;
                }
                .ws-log-cmd {
                    color: #ffff00;
                }
                .ws-log-hex {
                    color: #aaa;
                    font-size: 10px;
                    margin-top: 4px;
                    word-break: break-all;
                }
                #ws-monitor-stats {
                    padding: 5px 12px;
                    background: #002200;
                    border-top: 1px solid #00ff00;
                    font-size: 10px;
                    display: flex;
                    justify-content: space-between;
                }
            </style>
            <div id="ws-monitor-header">
                <span id="ws-monitor-title">🔌 WebSocket 监控器</span>
                <div id="ws-monitor-controls">
                    <button id="ws-clear-btn">清空</button>
                    <button id="ws-export-btn">导出</button>
                    <button id="ws-minimize-btn">最小化</button>
                    <button id="ws-close-btn">×</button>
                </div>
            </div>
            <div id="ws-monitor-content"></div>
            <div id="ws-monitor-stats">
                <span id="ws-stats-count">日志: 0</span>
                <span id="ws-stats-conn">连接: 0</span>
            </div>
        `;

        document.body.appendChild(logPanel);
        logContent = document.getElementById('ws-monitor-content');

        // 绑定按钮事件
        document.getElementById('ws-clear-btn').onclick = clearLogs;
        document.getElementById('ws-export-btn').onclick = exportLogs;
        document.getElementById('ws-minimize-btn').onclick = toggleMinimize;
        document.getElementById('ws-close-btn').onclick = () => logPanel.style.display = 'none';

        // 拖拽功能
        makeDraggable(logPanel, document.getElementById('ws-monitor-header'));
    }

    // 拖拽功能
    function makeDraggable(element, handle) {
        let pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
        handle.onmousedown = dragMouseDown;

        function dragMouseDown(e) {
            e.preventDefault();
            pos3 = e.clientX;
            pos4 = e.clientY;
            document.onmouseup = closeDragElement;
            document.onmousemove = elementDrag;
        }

        function elementDrag(e) {
            e.preventDefault();
            pos1 = pos3 - e.clientX;
            pos2 = pos4 - e.clientY;
            pos3 = e.clientX;
            pos4 = e.clientY;
            element.style.top = (element.offsetTop - pos2) + "px";
            element.style.left = (element.offsetLeft - pos1) + "px";
            element.style.right = 'auto';
        }

        function closeDragElement() {
            document.onmouseup = null;
            document.onmousemove = null;
        }
    }

    // 最小化切换
    let isMinimized = false;
    function toggleMinimize() {
        isMinimized = !isMinimized;
        logContent.style.display = isMinimized ? 'none' : 'block';
        document.getElementById('ws-monitor-stats').style.display = isMinimized ? 'none' : 'flex';
        logPanel.style.height = isMinimized ? 'auto' : '400px';
        document.getElementById('ws-minimize-btn').textContent = isMinimized ? '展开' : '最小化';
    }

    // 添加日志
    function addLog(type, direction, data, url) {
        const now = new Date();
        const timeStr = now.toTimeString().split(' ')[0] + '.' + now.getMilliseconds().toString().padStart(3, '0');

        let entry = {
            time: timeStr,
            type: type,
            direction: direction,
            url: url,
            rawData: data,
            parsed: null,
            hex: ''
        };

        // 解析数据
        if (data instanceof ArrayBuffer) {
            entry.hex = arrayBufferToHex(data);
            entry.parsed = parsePacketHeader(data);
        } else if (typeof data === 'string') {
            entry.hex = data.substring(0, 200);
        }

        logEntries.push(entry);
        if (logEntries.length > CONFIG.maxLogEntries) {
            logEntries.shift();
        }

        // 控制台输出
        if (CONFIG.logToConsole) {
            const dirSymbol = direction === 'send' ? '📤' : '📥';
            const cmdInfo = entry.parsed ? `CMD=${entry.parsed.cmdId} (${getCmdName(entry.parsed.cmdId)})` : '';
            console.log(
                `%c${dirSymbol} [${timeStr}] ${direction.toUpperCase()} ${cmdInfo}`,
                direction === 'send' ? 'color: #ff6400; font-weight: bold;' : 'color: #0096ff; font-weight: bold;'
            );
            if (entry.parsed) {
                console.log('  解析:', entry.parsed);
            }
            if (CONFIG.showHex) {
                console.log('  HEX:', entry.hex);
            }
        }

        // 面板输出
        if (CONFIG.logToPanel && logContent) {
            const div = document.createElement('div');
            div.className = `ws-log-entry ws-log-${direction}`;

            let html = `<span class="ws-log-time">[${timeStr}]</span>`;
            html += `<span class="ws-log-direction">${direction === 'send' ? '📤 发送' : '📥 接收'}</span>`;

            if (entry.parsed) {
                html += `<span class="ws-log-cmd">CMD=${entry.parsed.cmdId} (${getCmdName(entry.parsed.cmdId)})</span>`;
                html += `<br>UID=${entry.parsed.userId}, 长度=${entry.parsed.length}, 结果=${entry.parsed.result}`;
            }

            if (CONFIG.showHex && entry.hex) {
                html += `<div class="ws-log-hex">HEX: ${entry.hex}</div>`;
            }

            div.innerHTML = html;
            logContent.appendChild(div);

            // 自动滚动
            if (CONFIG.autoScroll) {
                logContent.scrollTop = logContent.scrollHeight;
            }

            // 更新统计
            document.getElementById('ws-stats-count').textContent = `日志: ${logEntries.length}`;
        }
    }

    // 添加连接日志
    function addConnectionLog(type, url) {
        const now = new Date();
        const timeStr = now.toTimeString().split(' ')[0];

        if (CONFIG.logToConsole) {
            console.log(`%c🔌 [${timeStr}] WebSocket ${type}: ${url}`, 'color: #00ff00; font-weight: bold;');
        }

        if (CONFIG.logToPanel && logContent) {
            const div = document.createElement('div');
            div.className = 'ws-log-entry ws-log-info';
            div.innerHTML = `<span class="ws-log-time">[${timeStr}]</span> 🔌 <b>${type}</b>: ${url}`;
            logContent.appendChild(div);

            document.getElementById('ws-stats-conn').textContent = `连接: ${wsConnections.length}`;
        }
    }

    // 清空日志
    function clearLogs() {
        logEntries = [];
        if (logContent) {
            logContent.innerHTML = '';
            document.getElementById('ws-stats-count').textContent = '日志: 0';
        }
        console.clear();
        console.log('%c🔌 WebSocket 监控器 - 日志已清空', 'color: #00ff00; font-weight: bold;');
    }

    // 导出日志
    function exportLogs() {
        const exportData = {
            exportTime: new Date().toISOString(),
            totalEntries: logEntries.length,
            connections: wsConnections.map(ws => ws._monitorUrl),
            logs: logEntries.map(entry => ({
                time: entry.time,
                direction: entry.direction,
                url: entry.url,
                parsed: entry.parsed,
                hex: entry.hex
            }))
        };

        const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `seer_ws_log_${Date.now()}.json`;
        a.click();
        URL.revokeObjectURL(url);
    }

    // Hook WebSocket
    const OriginalWebSocket = window.WebSocket;

    window.WebSocket = function(url, protocols) {
        console.log('%c🔌 WebSocket 创建: ' + url, 'color: #00ff00; font-weight: bold; font-size: 14px;');

        const ws = protocols ? new OriginalWebSocket(url, protocols) : new OriginalWebSocket(url);
        ws._monitorUrl = url;
        wsConnections.push(ws);

        // 监听 open
        ws.addEventListener('open', function(event) {
            addConnectionLog('已连接', url);
        });

        // 监听 close
        ws.addEventListener('close', function(event) {
            addConnectionLog(`已关闭 (code=${event.code}, reason=${event.reason || '无'})`, url);
            const idx = wsConnections.indexOf(ws);
            if (idx > -1) wsConnections.splice(idx, 1);
        });

        // 监听 error
        ws.addEventListener('error', function(event) {
            addConnectionLog('错误', url);
        });

        // 监听 message
        ws.addEventListener('message', function(event) {
            if (event.data instanceof ArrayBuffer) {
                addLog('binary', 'recv', event.data, url);
            } else if (event.data instanceof Blob) {
                event.data.arrayBuffer().then(buffer => {
                    addLog('binary', 'recv', buffer, url);
                });
            } else {
                addLog('text', 'recv', event.data, url);
            }
        });

        // Hook send 方法
        const originalSend = ws.send.bind(ws);
        ws.send = function(data) {
            if (data instanceof ArrayBuffer) {
                addLog('binary', 'send', data, url);
            } else if (data instanceof Blob) {
                data.arrayBuffer().then(buffer => {
                    addLog('binary', 'send', buffer, url);
                });
            } else if (typeof data === 'string') {
                addLog('text', 'send', data, url);
            } else if (data instanceof Uint8Array) {
                addLog('binary', 'send', data.buffer, url);
            }
            return originalSend(data);
        };

        return ws;
    };

    // 复制原型
    window.WebSocket.prototype = OriginalWebSocket.prototype;
    window.WebSocket.CONNECTING = OriginalWebSocket.CONNECTING;
    window.WebSocket.OPEN = OriginalWebSocket.OPEN;
    window.WebSocket.CLOSING = OriginalWebSocket.CLOSING;
    window.WebSocket.CLOSED = OriginalWebSocket.CLOSED;

    // 同时 Hook XMLHttpRequest 以监控 API 请求
    const OriginalXHR = window.XMLHttpRequest;

    window.XMLHttpRequest = function() {
        const xhr = new OriginalXHR();
        const originalOpen = xhr.open.bind(xhr);
        const originalSend = xhr.send.bind(xhr);

        let method = '';
        let url = '';

        xhr.open = function(m, u, ...args) {
            method = m;
            url = u;
            return originalOpen(m, u, ...args);
        };

        xhr.send = function(body) {
            // 只记录 API 请求
            if (url.includes('/seer/') || url.includes('/api/')) {
                const now = new Date();
                const timeStr = now.toTimeString().split(' ')[0];

                if (CONFIG.logToConsole) {
                    console.log(`%c🌐 [${timeStr}] ${method} ${url}`, 'color: #ff00ff; font-weight: bold;');
                    if (body) console.log('  请求体:', body);
                }

                xhr.addEventListener('load', function() {
                    if (CONFIG.logToConsole) {
                        console.log(`%c🌐 [${timeStr}] 响应 ${xhr.status}: ${url}`, 'color: #ff00ff;');
                        try {
                            console.log('  响应体:', JSON.parse(xhr.responseText));
                        } catch (e) {
                            console.log('  响应体:', xhr.responseText.substring(0, 500));
                        }
                    }
                });
            }

            return originalSend(body);
        };

        return xhr;
    };

    // 同时 Hook fetch
    const originalFetch = window.fetch;
    window.fetch = function(input, init) {
        const url = typeof input === 'string' ? input : input.url;

        if (url.includes('/seer/') || url.includes('/api/') || url.includes('ip.txt')) {
            const now = new Date();
            const timeStr = now.toTimeString().split(' ')[0];
            const method = init?.method || 'GET';

            if (CONFIG.logToConsole) {
                console.log(`%c🌐 [${timeStr}] FETCH ${method} ${url}`, 'color: #ff00ff; font-weight: bold;');
                if (init?.body) console.log('  请求体:', init.body);
            }

            return originalFetch(input, init).then(response => {
                const clonedResponse = response.clone();
                clonedResponse.text().then(text => {
                    if (CONFIG.logToConsole) {
                        console.log(`%c🌐 [${timeStr}] FETCH 响应 ${response.status}: ${url}`, 'color: #ff00ff;');
                        try {
                            console.log('  响应体:', JSON.parse(text));
                        } catch (e) {
                            console.log('  响应体:', text.substring(0, 500));
                        }
                    }
                });
                return response;
            });
        }

        return originalFetch(input, init);
    };

    // 页面加载完成后创建面板
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', createLogPanel);
    } else {
        createLogPanel();
    }

    // 全局快捷键
    document.addEventListener('keydown', function(e) {
        // Ctrl+Shift+W 显示/隐藏面板
        if (e.ctrlKey && e.shiftKey && e.key === 'W') {
            if (logPanel) {
                logPanel.style.display = logPanel.style.display === 'none' ? 'flex' : 'none';
            }
        }
        // Ctrl+Shift+C 清空日志
        if (e.ctrlKey && e.shiftKey && e.key === 'C') {
            clearLogs();
        }
    });

    console.log('%c🔌 赛尔号 WebSocket 监控器已启动!', 'color: #00ff00; font-weight: bold; font-size: 16px;');
    console.log('%c快捷键: Ctrl+Shift+W 显示/隐藏面板, Ctrl+Shift+C 清空日志', 'color: #888;');

})();
