/**
 * 微端模拟器 - 让 Vue 应用认为是通过客户端访问
 * 必须在 Vue 应用加载之前执行
 * 
 * 关键逻辑分析（来自 index-Brf6Pl7P.js）：
 * M1.beforeEach((o,t,e)=>{
 *   const l=o.query;
 *   l.mobile&&(I.set("mobile",!0),I.set("version",l.mobile)),
 *   l.version&&(I.set("mobile",!1),I.set("version",l.version));
 *   const r=I.get("mobile");
 *   !We()||!Ke()&&!r?o.path!=="/dowload"?e({path:"/dowload"})...
 * 
 * 条件：!We() || (!Ke() && !r)
 * - We() 检查版本
 * - Ke() 检查客户端环境
 * - r 是 I.get("mobile") 的值
 * 
 * 要避免跳转，需要让条件为 false：
 * - 让 We() 返回 true，或者
 * - 让 Ke() 返回 true，或者
 * - 让 r 为 true
 */

(function() {
    'use strict';
    
    console.log('[ClientEmulator] 初始化微端模拟...');
    
    const version = '1.0.6.8';
    
    // ========== 方法1：设置 localStorage ==========
    if (typeof localStorage !== 'undefined') {
        localStorage.setItem('version', version);
        localStorage.setItem('mobile', 'true');
        console.log('[ClientEmulator] localStorage.version =', version);
        console.log('[ClientEmulator] localStorage.mobile = true');
    }
    
    // ========== 方法2：模拟 Electron 环境 ==========
    window.__IS_CLIENT__ = true;
    window.__CLIENT_VERSION__ = version;
    window.__IS_ELECTRON__ = true;
    window.isElectron = true;
    window.isClient = true;
    
    if (!window.electron) {
        window.electron = {
            isElectron: true,
            version: version,
            platform: 'win32'
        };
    }
    
    if (!window.process) {
        window.process = {
            type: 'renderer',
            versions: {
                electron: version,
                chrome: '143.0.0.0',
                node: '20.0.0'
            },
            platform: 'win32'
        };
    }
    
    // ========== 方法3：在 URL 添加 mobile 参数 ==========
    // 如果 URL 没有 mobile 参数，自动添加
    if (!window.location.search.includes('mobile=')) {
        const url = new URL(window.location.href);
        url.searchParams.set('mobile', version);
        // 使用 replaceState 避免产生历史记录
        history.replaceState(null, '', url.toString());
        console.log('[ClientEmulator] 已添加 URL 参数 mobile=' + version);
    }
    
    // ========== 方法4：拦截 History API ==========
    const originalPushState = history.pushState.bind(history);
    const originalReplaceState = history.replaceState.bind(history);
    
    history.pushState = function(state, title, url) {
        if (url && String(url).includes('/dowload')) {
            console.log('[ClientEmulator] 阻止 pushState 到 /dowload');
            return;
        }
        return originalPushState(state, title, url);
    };
    
    history.replaceState = function(state, title, url) {
        if (url && String(url).includes('/dowload')) {
            console.log('[ClientEmulator] 阻止 replaceState 到 /dowload');
            return;
        }
        return originalReplaceState(state, title, url);
    };
    
    // ========== 方法5：定时检查并跳回 ==========
    let checkCount = 0;
    const maxChecks = 50;  // 5秒内检查50次
    
    const checkInterval = setInterval(function() {
        checkCount++;
        if (checkCount > maxChecks) {
            clearInterval(checkInterval);
            return;
        }
        
        const currentPath = window.location.pathname;
        if (currentPath === '/dowload' || currentPath.includes('/dowload')) {
            console.log('[ClientEmulator] 检测到在下载页，跳转到 /game');
            clearInterval(checkInterval);
            window.location.href = '/game';
        }
    }, 100);
    
    // ========== 方法6：监听 popstate ==========
    window.addEventListener('popstate', function() {
        setTimeout(function() {
            if (window.location.pathname.includes('/dowload')) {
                console.log('[ClientEmulator] popstate 检测到下载页');
                window.location.href = '/game';
            }
        }, 10);
    });
    
    console.log('[ClientEmulator] 微端模拟已启用');
    console.log('[ClientEmulator] 当前 URL:', window.location.href);
    
    // ========== 方法7：提供 getSessionID 函数给 Flash ==========
    // Flash 客户端通过 ExternalInterface.call("getSessionID") 获取 session
    // session 格式: userId(4字节大端hex) + sessionToken(16字节hex)
    
    // 内部 session 存储
    let _internalSession = '';
    
    // 定义 getSessionID 函数
    function defineGetSessionID() {
        const getSessionIDFunc = function() {
            // 优先使用内部存储的 session
            if (_internalSession) {
                console.log('[ClientEmulator] getSessionID 返回内部 session:', _internalSession);
                return _internalSession;
            }
            
            // 从 localStorage 或 sessionStorage 获取登录后保存的 session
            let session = localStorage.getItem('seer_session') || sessionStorage.getItem('seer_session');
            
            if (session) {
                console.log('[ClientEmulator] getSessionID 返回存储的 session:', session);
                return session;
            }
            
            // 如果没有 session，返回空字符串（Flash 会显示登录界面）
            console.log('[ClientEmulator] getSessionID: 没有找到 session');
            return '';
        };
        
        window.getSessionID = getSessionIDFunc;
    }
    
    defineGetSessionID();
    
    // 定期检查并恢复 getSessionID（防止被 Vue 应用覆盖）
    let sessionCheckCount = 0;
    const sessionCheckInterval = setInterval(function() {
        sessionCheckCount++;
        if (sessionCheckCount > 100) {  // 10秒后停止检查
            clearInterval(sessionCheckInterval);
            return;
        }
        
        // 检查 getSessionID 是否被覆盖
        const currentFunc = window.getSessionID;
        if (currentFunc && currentFunc.toString().indexOf('_internalSession') === -1) {
            console.log('[ClientEmulator] 检测到 getSessionID 被覆盖，尝试恢复...');
            
            // 如果 Vue 应用设置了 session，保存它
            try {
                const vueSession = currentFunc();
                if (vueSession && vueSession.length > 0) {
                    console.log('[ClientEmulator] 从 Vue 应用获取 session:', vueSession);
                    _internalSession = vueSession;
                    localStorage.setItem('seer_session', vueSession);
                    sessionStorage.setItem('seer_session', vueSession);
                }
            } catch (e) {
                // 忽略错误
            }
            
            // 重新定义我们的函数
            defineGetSessionID();
        }
    }, 100);
    
    // 保存 session 的辅助函数（登录成功后调用）
    window.saveSessionID = function(session) {
        if (session) {
            _internalSession = session;
            localStorage.setItem('seer_session', session);
            sessionStorage.setItem('seer_session', session);
            console.log('[ClientEmulator] 已保存 session:', session);
        }
    };
    
    // 清除 session（登出时调用）
    window.clearSessionID = function() {
        localStorage.removeItem('seer_session');
        sessionStorage.removeItem('seer_session');
        console.log('[ClientEmulator] 已清除 session');
    };
    
    // 调试函数
    window.debugClientEmulator = function() {
        console.log('=== Client Emulator Debug ===');
        console.log('localStorage.version:', localStorage.getItem('version'));
        console.log('localStorage.mobile:', localStorage.getItem('mobile'));
        console.log('localStorage.seer_session:', localStorage.getItem('seer_session'));
        console.log('window.electron:', window.electron);
        console.log('current URL:', window.location.href);
        console.log('current path:', window.location.pathname);
    };
    
    window.forceGame = function() {
        window.location.href = '/game';
    };
    
    // ========== WebSocket 调试 ==========
    // 拦截 WebSocket 构造函数来追踪连接
    const OriginalWebSocket = window.WebSocket;
    window.WebSocket = function(url, protocols) {
        console.log('[WS-DEBUG] 创建 WebSocket:', url);
        const ws = protocols ? new OriginalWebSocket(url, protocols) : new OriginalWebSocket(url);
        
        ws.addEventListener('open', function() {
            console.log('[WS-DEBUG] ✓ WebSocket 已连接:', url);
        });
        
        ws.addEventListener('close', function(e) {
            console.log('[WS-DEBUG] WebSocket 关闭:', url);
            console.log('[WS-DEBUG]   code:', e.code);
            console.log('[WS-DEBUG]   reason:', e.reason || '(无)');
            console.log('[WS-DEBUG]   wasClean:', e.wasClean);
        });
        
        ws.addEventListener('error', function(e) {
            console.log('[WS-DEBUG] WebSocket 错误:', url);
            console.log('[WS-DEBUG]   error:', e);
            console.log('[WS-DEBUG]   readyState:', ws.readyState);
        });
        
        ws.addEventListener('message', function(e) {
            const size = e.data instanceof ArrayBuffer ? e.data.byteLength : e.data.length;
            console.log('[WS-DEBUG] 收到消息:', size, 'bytes');
        });
        
        // 拦截 send 方法
        const originalSend = ws.send.bind(ws);
        ws.send = function(data) {
            const size = data instanceof ArrayBuffer ? data.byteLength : 
                        (data instanceof Blob ? data.size : data.length);
            console.log('[WS-DEBUG] 发送消息:', size, 'bytes');
            return originalSend(data);
        };
        
        return ws;
    };
    window.WebSocket.prototype = OriginalWebSocket.prototype;
    window.WebSocket.CONNECTING = OriginalWebSocket.CONNECTING;
    window.WebSocket.OPEN = OriginalWebSocket.OPEN;
    window.WebSocket.CLOSING = OriginalWebSocket.CLOSING;
    window.WebSocket.CLOSED = OriginalWebSocket.CLOSED;
    
})();
