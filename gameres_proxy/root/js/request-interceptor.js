/**
 * 请求拦截器 - 确保所有资源请求通过本地代理服务器
 * 
 * 工作原理：
 * - 所有游戏资源请求都通过本地代理服务器 (127.0.0.1:32400)
 * - 本地代理服务器根据 reseer.lua 中的配置决定：
 *   * use_official_resources = true: 从官服下载并缓存
 *   * use_official_resources = false: 使用本地缓存
 * - 这样可以避免 CORS 问题，因为本地服务器会添加正确的 CORS 头
 * 
 * 注意：此脚本必须在 server-config.js 之后加载
 */

(function() {
    'use strict';

    // 配置
    const LOCAL_SERVER = 'http://127.0.0.1:32400';
    const OFFICIAL_SERVER = 'http://61.160.213.26:12346';  // 官服资源服务器
    
    let currentMode = null;

    // 从配置文件读取模式（同步）
    function getMode() {
        if (currentMode !== null) {
            return currentMode;
        }

        // 从自动生成的配置文件读取
        if (window.SEER_SERVER_CONFIG) {
            currentMode = window.SEER_SERVER_CONFIG.local_server_mode ? 'local' : 'official';
            console.log(`[RequestInterceptor] 从配置读取模式: ${currentMode}`);
            return currentMode;
        }

        // 如果配置文件还没加载，默认使用本地模式
        console.warn('[RequestInterceptor] 配置文件未加载，使用默认模式: local');
        currentMode = 'local';
        return currentMode;
    }

    // 判断是否需要重定向
    function shouldRedirect(url) {
        // 排除不应该重定向的请求
        const excludePatterns = [
            /ruffle/i,                    // Ruffle 相关
            /\.wasm$/,                    // WASM 文件
            /unpkg\.com/,                 // CDN
            /127\.0\.0\.1:8211/,          // API 服务器
            /localhost:8211/,             // API 服务器
            /45\.125\.46\.70:8211/,       // 官服 API 服务器（需要代理）
            /__log__/,                    // 日志端点
            /server-config\.js/,          // 配置文件本身
        ];

        if (excludePatterns.some(pattern => pattern.test(url))) {
            return false;
        }

        // 只重定向游戏资源请求
        const resourcePatterns = [
            /\/config\//,
            /\/resource\//,
            /\/dll\//,
            /\/login\//,
            /\/json\//,                   // JSON 数据文件
            /\.swf$/,
            /\.xml$/,
            /\/assets\/json\//
        ];

        return resourcePatterns.some(pattern => pattern.test(url));
    }

    // 判断是否应该静默阻止的请求（错误上报、统计等）
    function shouldBlock(url) {
        const blockPatterns = [
            /114\.80\.98\.38/,            // 淘米错误上报服务器
            /seer-err-report\.cgi/,       // 错误上报接口
            /stat\.taomee\.com/,          // 淘米统计服务器
            /log\.taomee\.com/,           // 淘米日志服务器
            /tongji\./,                   // 统计相关
            /analytics\./,                // 分析相关
        ];
        
        return blockPatterns.some(pattern => pattern.test(url));
    }

    // 重定向URL
    function redirectURL(url) {
        // 转换为字符串（可能是 Request 对象）
        const urlString = typeof url === 'string' ? url : url.url || String(url);
        
        console.log('[RequestInterceptor] 检查 URL:', urlString);

        // 特殊处理：将官服 API 请求重定向到本地 API 服务器
        if (urlString.includes('45.125.46.70:8211')) {
            const apiPath = urlString.split('45.125.46.70:8211')[1];
            const newURL = 'http://127.0.0.1:8211' + apiPath;
            console.log(`[RequestInterceptor] API 代理: ${apiPath} -> 本地 API 服务器`);
            return newURL;
        }
        
        // 特殊处理：将 by.ctymc.cn:20672 的请求重定向到本地 API 服务器
        if (urlString.includes('by.ctymc.cn:20672') || urlString.includes('by.ctymc.cn')) {
            const match = urlString.match(/by\.ctymc\.cn(?::\d+)?(.*)$/);
            if (match) {
                const apiPath = match[1];
                const newURL = 'http://127.0.0.1:8211' + apiPath;
                console.log(`[RequestInterceptor] API 代理 (by.ctymc.cn): ${apiPath} -> 本地 API 服务器`);
                return newURL;
            }
        }

        // 获取当前模式
        const mode = getMode();

        // 检查是否需要重定向
        if (!shouldRedirect(urlString)) {
            return url;
        }

        // 本地模式和官服模式都通过本地代理服务器
        // 本地代理会根据 use_official_resources 配置决定是否从官服下载
        // 这样可以避免 CORS 问题，因为本地服务器会添加正确的 CORS 头
        
        // 如果已经是本地服务器地址，不需要修改
        if (urlString.startsWith(LOCAL_SERVER)) {
            return url;
        }

        // 如果是相对路径，保持不变（会自动请求到本地服务器）
        if (urlString.startsWith('/')) {
            return url;
        }

        // 如果是官服地址，转换为本地代理
        if (urlString.startsWith(OFFICIAL_SERVER)) {
            const path = urlString.substring(OFFICIAL_SERVER.length);
            const newURL = LOCAL_SERVER + path;
            console.log(`[RequestInterceptor] 重定向到本地代理: ${path}`);
            return newURL;
        }

        return url;
    }

    // 拦截 fetch
    const originalFetch = window.fetch;
    window.fetch = function(url, options) {
        const urlString = typeof url === 'string' ? url : url.url || String(url);
        
        // 阻止错误上报和统计请求
        if (shouldBlock(urlString)) {
            console.log('[RequestInterceptor] 已阻止统计/错误上报请求:', urlString);
            // 返回一个假的成功响应
            return Promise.resolve(new Response('', { status: 200, statusText: 'OK (blocked)' }));
        }
        
        // 重定向URL（同步操作）
        const redirectedURL = redirectURL(url);
        
        // 调用原始 fetch
        const fetchPromise = originalFetch.call(this, redirectedURL, options);
        
        // 拦截登录响应，保存 session
        if (urlString.includes('/seer/customer/login') || urlString.includes('/seer/login')) {
            return fetchPromise.then(response => {
                // 克隆响应以便读取内容
                const clonedResponse = response.clone();
                clonedResponse.json().then(data => {
                    if (data && data.code === 200 && data.session) {
                        console.log('[RequestInterceptor] 登录成功，保存 session');
                        // 保存 session 供 Flash 使用
                        if (window.saveSessionID) {
                            window.saveSessionID(data.session);
                        } else {
                            localStorage.setItem('seer_session', data.session);
                            sessionStorage.setItem('seer_session', data.session);
                        }
                        console.log('[RequestInterceptor] Session 已保存:', data.session);
                    }
                }).catch(err => {
                    // 忽略 JSON 解析错误
                });
                return response;
            });
        }
        
        return fetchPromise;
    };

    // 拦截 XMLHttpRequest
    const originalOpen = XMLHttpRequest.prototype.open;
    const originalSend = XMLHttpRequest.prototype.send;
    
    XMLHttpRequest.prototype.open = function(method, url, ...args) {
        // 保存原始 URL 用于后续判断
        this._requestURL = url;
        this._shouldBlock = shouldBlock(url);
        
        if (this._shouldBlock) {
            console.log('[RequestInterceptor] 已阻止 XHR 统计/错误上报请求:', url);
            // 不调用原始 open，后续 send 会直接返回
            return;
        }
        
        // 重定向URL（同步操作）
        const redirectedURL = redirectURL(url);
        
        // 调用原始 open
        return originalOpen.call(this, method, redirectedURL, ...args);
    };
    
    XMLHttpRequest.prototype.send = function(body) {
        // 如果是被阻止的请求，直接模拟成功响应
        if (this._shouldBlock) {
            const xhr = this;
            setTimeout(() => {
                Object.defineProperty(xhr, 'readyState', { value: 4, writable: false });
                Object.defineProperty(xhr, 'status', { value: 200, writable: false });
                Object.defineProperty(xhr, 'statusText', { value: 'OK (blocked)', writable: false });
                Object.defineProperty(xhr, 'responseText', { value: '', writable: false });
                if (xhr.onreadystatechange) xhr.onreadystatechange();
                if (xhr.onload) xhr.onload();
            }, 0);
            return;
        }
        
        const xhr = this;
        const url = xhr._requestURL || '';
        
        // 如果是登录请求，添加响应监听
        if (url.includes('/seer/customer/login') || url.includes('/seer/login')) {
            xhr.addEventListener('load', function() {
                try {
                    const data = JSON.parse(xhr.responseText);
                    if (data && data.code === 200 && data.session) {
                        console.log('[RequestInterceptor] XHR 登录成功，保存 session');
                        if (window.saveSessionID) {
                            window.saveSessionID(data.session);
                        } else {
                            localStorage.setItem('seer_session', data.session);
                            sessionStorage.setItem('seer_session', data.session);
                        }
                        console.log('[RequestInterceptor] Session 已保存:', data.session);
                    }
                } catch (e) {
                    // 忽略解析错误
                }
            });
        }
        
        return originalSend.call(this, body);
    };

    console.log('[RequestInterceptor] 请求拦截器已加载');

    // 导出到全局
    window.RequestInterceptor = {
        getCurrentMode: () => getMode(),
        setMode: (mode) => {
            currentMode = mode;
            console.log(`[RequestInterceptor] 手动设置模式: ${mode}`);
        },
        refreshMode: () => {
            currentMode = null;
            return getMode();
        }
    };

})();
