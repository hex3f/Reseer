/**
 * Flash 客户端辅助脚本
 * 提供 Flash 需要的 JavaScript 接口
 */

(function() {
    'use strict';
    
    console.log('[FlashHelper] 初始化...');
    
    // ========== getSessionID 函数 ==========
    // Flash 客户端通过 ExternalInterface.call("getSessionID") 获取 session
    // 返回空字符串表示需要显示登录界面
    
    let _session = '';
    
    window.getSessionID = function() {
        // 从存储中获取 session
        if (!_session) {
            _session = localStorage.getItem('seer_session') || 
                       sessionStorage.getItem('seer_session') || '';
        }
        
        if (_session) {
            console.log('[FlashHelper] getSessionID:', _session.substring(0, 20) + '...');
        } else {
            console.log('[FlashHelper] getSessionID: 无 session，显示登录界面');
        }
        
        return _session;
    };
    
    // 保存 session
    window.saveSessionID = function(session) {
        if (session) {
            _session = session;
            localStorage.setItem('seer_session', session);
            sessionStorage.setItem('seer_session', session);
            console.log('[FlashHelper] Session 已保存');
        }
    };
    
    // 清除 session
    window.clearSessionID = function() {
        _session = '';
        localStorage.removeItem('seer_session');
        sessionStorage.removeItem('seer_session');
        console.log('[FlashHelper] Session 已清除');
    };
    
    // ========== 调试工具 ==========
    window.debugFlash = function() {
        console.log('=== Flash Helper Debug ===');
        console.log('Session:', _session ? _session.substring(0, 20) + '...' : '(无)');
        console.log('localStorage.seer_session:', localStorage.getItem('seer_session') ? '有' : '无');
    };
    
    console.log('[FlashHelper] 已就绪');
})();
