// ==UserScript==
// @name         赛尔号 Socket 完整拦截器
// @namespace    http://seer.local/
// @version      3.0
// @description  拦截赛尔号所有网络通信（Fetch/XHR/WebSocket），解析协议命令
// @author       You
// @match        http://61.160.213.26:*/*
// @match        http://45.125.46.70:*/*
// @match        http://127.0.0.1:*/*
// @match        http://localhost:*/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function() {
    'use strict';
    
    console.log('%c[SEER] 🎮 网络拦截器 v3.0 已启动', 'color: #0f0; font-size: 16px; font-weight: bold');

    // ========== 已知命令 ID ==========
    const CMD_NAMES = {
        // 登录相关
        101: 'LOGIN_CHECK',           // 登录验证
        102: 'LOGIN_RESULT',          // 登录结果
        103: 'LOGOUT',                // 登出
        104: 'HEARTBEAT',             // 心跳
        105: 'COMMEND_ONLINE',        // 获取推荐服务器列表
        106: 'RANGE_ONLINE',          // 获取范围服务器列表
        107: 'MAIN_LOGIN_IN',         // 主登录
        
        // 角色相关
        1001: 'GET_USER_INFO',        // 获取用户信息
        1002: 'CREATE_ROLE',          // 创建角色
        1003: 'ENTER_MAP',            // 进入地图
        1004: 'LEAVE_MAP',            // 离开地图
        1005: 'MOVE',                 // 移动
        
        // 精灵相关
        2001: 'GET_PET_INFO',         // 获取精灵信息
        2002: 'GET_PET_BAG',          // 获取精灵背包
        2003: 'CATCH_PET',            // 捕捉精灵
        2004: 'RELEASE_PET',          // 放生精灵
        
        // 战斗相关
        3001: 'START_BATTLE',         // 开始战斗
        3002: 'BATTLE_ACTION',        // 战斗行动
        3003: 'BATTLE_RESULT',        // 战斗结果
        3004: 'ESCAPE_BATTLE',        // 逃跑
        
        // 物品相关
        4001: 'GET_ITEM_BAG',         // 获取物品背包
        4002: 'USE_ITEM',             // 使用物品
        4003: 'DROP_ITEM',            // 丢弃物品
        
        // 任务相关
        5001: 'GET_TASK_LIST',        // 获取任务列表
        5002: 'ACCEPT_TASK',          // 接受任务
        5003: 'COMPLETE_TASK',        // 完成任务
    };

    // ========== 数据存储 ==========
    const wsConnections = [];  // 所有WebSocket连接
    const messageLog = [];     // 所有消息
    const fetchLog = [];       // Fetch请求日志
    const xhrLog = [];         // XHR请求日志
    let messageCount = 0;

    // ========== 工具函数 ==========
    function formatHex(buffer, maxLen = 64) {
        const arr = new Uint8Array(buffer);
        let hex = Array.from(arr.slice(0, maxLen))
            .map(b => b.toString(16).padStart(2, '0'))
            .join(' ');
        if (arr.length > maxLen) {
            hex += ` ... (${arr.length} bytes total)`;
        }
        return hex;
    }

    function parsePacket(buffer) {
        const arr = new Uint8Array(buffer);
        if (arr.length < 8) return null;
        
        // 赛尔号协议: [4字节长度][4字节命令ID][数据...]
        const view = new DataView(buffer);
        const len = view.getUint32(0, false);  // Big Endian
        const cmd = view.getUint32(4, false);  // Big Endian
        
        return {
            length: len,
            cmd: cmd,
            cmdName: CMD_NAMES[cmd] || `UNKNOWN_${cmd}`,
            data: arr.slice(8),
            raw: arr
        };
    }

    function parsePacketData(packet) {
        // 尝试解析常见命令的数据
        const result = { cmd: packet.cmd, cmdName: packet.cmdName };
        
        if (packet.data.length === 0) {
            return result;
        }

        try {
            const view = new DataView(packet.data.buffer, packet.data.byteOffset, packet.data.byteLength);
            
            switch (packet.cmd) {
                case 105: // COMMEND_ONLINE - 服务器列表
                    if (packet.data.length >= 12) {
                        result.maxOnlineID = view.getUint32(0, false);
                        result.isVIP = view.getUint32(4, false);
                        result.serverCount = view.getUint32(8, false);
                        result.servers = [];
                        // 解析服务器列表...
                    }
                    break;
                    
                case 1001: // GET_USER_INFO
                    // 解析用户信息...
                    break;
            }
        } catch (e) {
            result.parseError = e.message;
        }
        
        return result;
    }

    // ========== Fetch 拦截 ==========
    const originalFetch = window.fetch;
    window.fetch = async function(...args) {
        const [resource, config] = args;
        const url = resource instanceof Request ? resource.url : resource;
        const startTime = Date.now();
        
        try {
            const response = await originalFetch.apply(this, args);
            const clone = response.clone();
            
            clone.text().then(text => {
                const logEntry = {
                    time: Date.now(),
                    type: 'fetch',
                    url: url,
                    method: config?.method || 'GET',
                    duration: Date.now() - startTime,
                    status: response.status,
                    data: text
                };
                
                fetchLog.push(logEntry);
                
                // 只打印关键请求
                if (url.includes('Server') || url.includes('json') || url.includes('xml') || url.includes('/seer/')) {
                    console.groupCollapsed(`%c[SEER] 📡 FETCH: ${url}`, 'color: #00aaff; font-weight: bold');
                    console.log('Method:', config?.method || 'GET');
                    console.log('Status:', response.status);
                    console.log('Duration:', logEntry.duration + 'ms');
                    try {
                        console.log('Response (JSON):', JSON.parse(text));
                    } catch (e) {
                        console.log('Response (Text):', text.substring(0, 200));
                    }
                    console.groupEnd();
                }
            }).catch(() => {});
            
            return response;
        } catch (error) {
            console.error(`%c[SEER] ❌ FETCH ERROR: ${url}`, 'color: #f44', error);
            throw error;
        }
    };

    // ========== XHR 拦截 ==========
    const originalOpen = XMLHttpRequest.prototype.open;
    const originalSend = XMLHttpRequest.prototype.send;
    
    XMLHttpRequest.prototype.open = function(method, url) {
        this._seerUrl = url;
        this._seerMethod = method;
        this._seerStartTime = Date.now();
        return originalOpen.apply(this, arguments);
    };
    
    XMLHttpRequest.prototype.send = function(body) {
        this.addEventListener('load', function() {
            const logEntry = {
                time: Date.now(),
                type: 'xhr',
                url: this._seerUrl,
                method: this._seerMethod,
                duration: Date.now() - this._seerStartTime,
                status: this.status,
                requestBody: body,
                responseText: this.responseText
            };
            
            xhrLog.push(logEntry);
            
            if (this._seerUrl && (this._seerUrl.includes('Server') || this._seerUrl.includes('json') || 
                this._seerUrl.includes('xml') || this._seerUrl.includes('/seer/'))) {
                console.groupCollapsed(`%c[SEER] 📨 XHR: ${this._seerUrl}`, 'color: #ffaa00; font-weight: bold');
                console.log('Method:', this._seerMethod);
                console.log('Status:', this.status);
                console.log('Duration:', logEntry.duration + 'ms');
                if (body) console.log('Request Body:', body);
                try {
                    console.log('Response (JSON):', JSON.parse(this.responseText));
                } catch (e) {
                    console.log('Response (Text):', this.responseText.substring(0, 200));
                }
                console.groupEnd();
            }
        });
        return originalSend.apply(this, arguments);
    };

    // ========== WebSocket 拦截 ==========
    const OriginalWebSocket = window.WebSocket;

    window.WebSocket = function(url, protocols) {
        console.log('%c[SEER] 🔌 新连接: ' + url, 'color: #0ff; font-weight: bold; font-size: 14px');
        
        const ws = protocols ? new OriginalWebSocket(url, protocols) : new OriginalWebSocket(url);
        
        const connInfo = {
            id: wsConnections.length,
            url: url,
            createdAt: Date.now(),
            status: 'connecting',
            messages: []
        };
        wsConnections.push(connInfo);

        // 监听连接打开
        ws.addEventListener('open', function() {
            connInfo.status = 'open';
            console.log('%c[SEER] ✅ 连接成功 #' + connInfo.id + ': ' + url, 'color: #0f0; font-weight: bold');
            messageLog.push({
                time: Date.now(),
                connId: connInfo.id,
                type: 'open',
                url: url
            });
        });

        // 监听消息接收
        ws.addEventListener('message', function(e) {
            messageCount++;
            
            if (e.data instanceof ArrayBuffer) {
                const packet = parsePacket(e.data);
                const hex = formatHex(e.data, 32);
                
                if (packet) {
                    console.log(
                        '%c[SEER] ← RECV #' + messageCount + ' [' + packet.cmdName + ' cmd=' + packet.cmd + ']: ' + hex,
                        'color: #0f0'
                    );
                    
                    const parsed = parsePacketData(packet);
                    const logEntry = {
                        time: Date.now(),
                        connId: connInfo.id,
                        type: 'recv',
                        msgId: messageCount,
                        cmd: packet.cmd,
                        cmdName: packet.cmdName,
                        length: packet.length,
                        data: Array.from(packet.raw),
                        parsed: parsed,
                        hex: hex
                    };
                    messageLog.push(logEntry);
                    connInfo.messages.push(logEntry);
                } else {
                    console.log('%c[SEER] ← RECV #' + messageCount + ': ' + hex, 'color: #0f0');
                }
            } else {
                console.log('%c[SEER] ← RECV #' + messageCount + ' (text): ' + String(e.data).substring(0, 100), 'color: #0f0');
            }
        });

        // 监听连接关闭
        ws.addEventListener('close', function(e) {
            connInfo.status = 'closed';
            connInfo.closeCode = e.code;
            console.log('%c[SEER] 🔌 连接关闭 #' + connInfo.id + ' (code=' + e.code + ')', 'color: #fa0; font-weight: bold');
            messageLog.push({
                time: Date.now(),
                connId: connInfo.id,
                type: 'close',
                code: e.code
            });
        });

        // 监听错误
        ws.addEventListener('error', function() {
            connInfo.status = 'error';
            console.log('%c[SEER] ❌ 连接错误 #' + connInfo.id, 'color: #f44; font-weight: bold');
            messageLog.push({
                time: Date.now(),
                connId: connInfo.id,
                type: 'error'
            });
        });

        // 拦截发送
        const origSend = ws.send.bind(ws);
        ws.send = function(data) {
            messageCount++;
            
            if (data instanceof ArrayBuffer) {
                const packet = parsePacket(data);
                const hex = formatHex(data, 32);
                
                if (packet) {
                    console.log(
                        '%c[SEER] → SEND #' + messageCount + ' [' + packet.cmdName + ' cmd=' + packet.cmd + ']: ' + hex,
                        'color: #ff0'
                    );
                    
                    const logEntry = {
                        time: Date.now(),
                        connId: connInfo.id,
                        type: 'send',
                        msgId: messageCount,
                        cmd: packet.cmd,
                        cmdName: packet.cmdName,
                        length: packet.length,
                        data: Array.from(new Uint8Array(data)),
                        hex: hex
                    };
                    messageLog.push(logEntry);
                    connInfo.messages.push(logEntry);
                } else {
                    console.log('%c[SEER] → SEND #' + messageCount + ': ' + hex, 'color: #ff0');
                }
            } else {
                console.log('%c[SEER] → SEND #' + messageCount + ' (text): ' + String(data).substring(0, 100), 'color: #ff0');
            }
            
            return origSend(data);
        };

        return ws;
    };

    // 复制静态属性
    window.WebSocket.CONNECTING = OriginalWebSocket.CONNECTING;
    window.WebSocket.OPEN = OriginalWebSocket.OPEN;
    window.WebSocket.CLOSING = OriginalWebSocket.CLOSING;
    window.WebSocket.CLOSED = OriginalWebSocket.CLOSED;
    window.WebSocket.prototype = OriginalWebSocket.prototype;

    // ========== 全局 API ==========
    window.seerSocket = {
        // 获取所有连接
        connections: function() {
            return wsConnections;
        },
        
        // 获取所有WebSocket消息日志
        log: function() {
            return messageLog;
        },
        
        // 获取所有Fetch日志
        fetchLog: function() {
            return fetchLog;
        },
        
        // 获取所有XHR日志
        xhrLog: function() {
            return xhrLog;
        },
        
        // 获取所有网络日志
        allLogs: function() {
            return {
                websocket: messageLog,
                fetch: fetchLog,
                xhr: xhrLog
            };
        },
        
        // 按命令过滤WebSocket消息
        filterByCmd: function(cmd) {
            return messageLog.filter(m => m.cmd === cmd);
        },
        
        // 按命令名过滤
        filterByName: function(name) {
            return messageLog.filter(m => m.cmdName && m.cmdName.includes(name));
        },
        
        // 按URL过滤Fetch/XHR
        filterByUrl: function(keyword) {
            return {
                fetch: fetchLog.filter(f => f.url.includes(keyword)),
                xhr: xhrLog.filter(x => x.url.includes(keyword))
            };
        },
        
        // 获取活跃连接
        activeConnections: function() {
            return wsConnections.filter(c => c.status === 'open');
        },
        
        // 清空日志
        clear: function() {
            messageLog.length = 0;
            fetchLog.length = 0;
            xhrLog.length = 0;
            messageCount = 0;
            console.clear();
            console.log('%c[SEER] 日志已清空', 'color: #0ff');
        },
        
        // 导出日志
        export: function() {
            const blob = new Blob([JSON.stringify({
                connections: wsConnections,
                websocket: messageLog,
                fetch: fetchLog,
                xhr: xhrLog,
                exportTime: Date.now()
            }, null, 2)], { type: 'application/json' });
            const a = document.createElement('a');
            a.href = URL.createObjectURL(blob);
            a.download = 'seer_network_' + Date.now() + '.json';
            a.click();
            console.log('%c[SEER] 日志已导出', 'color: #0ff');
        },
        
        // 统计
        stats: function() {
            const wsSent = messageLog.filter(m => m.type === 'send').length;
            const wsRecv = messageLog.filter(m => m.type === 'recv').length;
            const cmds = {};
            messageLog.forEach(m => {
                if (m.cmdName) {
                    cmds[m.cmdName] = (cmds[m.cmdName] || 0) + 1;
                }
            });
            console.log('%c[SEER] 📊 统计', 'color: #0ff; font-weight: bold');
            console.log('  WebSocket连接数:', wsConnections.length);
            console.log('  WebSocket发送:', wsSent, '条');
            console.log('  WebSocket接收:', wsRecv, '条');
            console.log('  Fetch请求:', fetchLog.length, '次');
            console.log('  XHR请求:', xhrLog.length, '次');
            console.log('  命令分布:', cmds);
        },
        
        // 命令列表
        commands: function() {
            console.log('%c[SEER] 已知命令列表', 'color: #0ff; font-weight: bold');
            Object.entries(CMD_NAMES).forEach(([id, name]) => {
                console.log('  ' + id + ': ' + name);
            });
        },
        
        // 帮助
        help: function() {
            console.log('%c赛尔号网络拦截器 v3.0', 'color: #0ff; font-size: 16px; font-weight: bold');
            console.log('');
            console.log('=== WebSocket 相关 ===');
            console.log('seerSocket.connections()     - 获取所有WebSocket连接');
            console.log('seerSocket.log()             - 获取WebSocket消息');
            console.log('seerSocket.filterByCmd(105)  - 按命令ID过滤');
            console.log('seerSocket.filterByName("LOGIN") - 按命令名过滤');
            console.log('');
            console.log('=== HTTP 相关 ===');
            console.log('seerSocket.fetchLog()        - 获取所有Fetch请求');
            console.log('seerSocket.xhrLog()          - 获取所有XHR请求');
            console.log('seerSocket.filterByUrl("json") - 按URL过滤');
            console.log('');
            console.log('=== 通用功能 ===');
            console.log('seerSocket.allLogs()         - 获取所有日志');
            console.log('seerSocket.stats()           - 显示统计');
            console.log('seerSocket.commands()        - 显示已知命令');
            console.log('seerSocket.export()          - 导出日志');
            console.log('seerSocket.clear()           - 清空日志');
        }
    };

    console.log('%c🎮 赛尔号网络拦截器 v3.0 已加载', 'color: #0f0; font-size: 16px; font-weight: bold');
    console.log('%c输入 seerSocket.help() 查看帮助', 'color: #0ff');
    console.log('%c现在可以拦截: WebSocket + Fetch + XHR', 'color: #0ff');
})();
