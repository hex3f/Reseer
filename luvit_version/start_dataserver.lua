-- 数据管理服务器 (Data Manager Server)
-- 负责：会话管理、用户数据、统计监控
-- 提供 HTTP API 供其他服务器调用

-- 初始化日志系统
local Logger = require("./logger")
Logger.init()

print("\27[36m╔════════════════════════════════════════════════════════════╗\27[0m")
print("\27[36m║              数据管理服务器 - Data Manager                 ║\27[0m")
print("\27[36m╚════════════════════════════════════════════════════════════╝\27[0m")
print("")

-- 加载配置
local conf = _G.conf or {
    dataserver_port = 5200,
    hide_frequent_cmds = true,
    hide_cmd_list = {80008},
}
_G.conf = conf

-- 创建会话管理器
print("\27[36m[数据服务器] 初始化会话管理器...\27[0m")
local SessionManager = require "./session_manager"
local sessionManager = SessionManager:new()

-- 创建用户数据库
print("\27[36m[数据服务器] 初始化用户数据库...\27[0m")
local UserDB = require "./userdb"
local userdb = UserDB

-- 创建 HTTP API 服务器
local http = require('http')
local json = require('json')
local url = require('url')

-- 辅助函数：解析请求体
local function parseBody(req, callback)
    local body = ""
    req:on('data', function(chunk)
        body = body .. chunk
    end)
    req:on('end', function()
        if #body > 0 then
            local ok, parsed = pcall(json.parse, body)
            if ok then
                callback(parsed)
            else
                callback(nil, "Invalid JSON")
            end
        else
            callback({})
        end
    end)
end

-- 辅助函数：发送 JSON 响应
local function sendJSON(res, statusCode, data)
    local body = json.stringify(data)
    res:writeHead(statusCode, {
        ["Content-Type"] = "application/json",
        ["Content-Length"] = #body,
        ["Access-Control-Allow-Origin"] = "*"
    })
    res:finish(body)
end

local server = http.createServer(function(req, res)
    local parsedUrl = url.parse(req.url, true)
    local path = parsedUrl.pathname
    local method = req.method
    
    -- CORS 预检请求
    if method == "OPTIONS" then
        res:writeHead(200, {
            ["Access-Control-Allow-Origin"] = "*",
            ["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, PATCH, OPTIONS",
            ["Access-Control-Allow-Headers"] = "Content-Type"
        })
        res:finish()
        return
    end
    
    -- ==================== 用户数据 API ====================
    
    -- GET /api/user/:userId - 获取或创建用户
    if method == "GET" and path:match("^/api/user/(%d+)$") then
        local userId = tonumber(path:match("^/api/user/(%d+)$"))
        local db = userdb:new()
        local user = db:getOrCreateUser(userId)
        sendJSON(res, 200, {success = true, data = user})
        return
    end
    
    -- POST /api/user/:userId - 保存用户数据
    if method == "POST" and path:match("^/api/user/(%d+)$") then
        local userId = tonumber(path:match("^/api/user/(%d+)$"))
        parseBody(req, function(userData, err)
            if err then
                sendJSON(res, 400, {success = false, error = err})
                return
            end
            local db = userdb:new()
            db:saveUser(userId, userData)
            sendJSON(res, 200, {success = true})
        end)
        return
    end
    
    -- PATCH /api/user/:userId/:field - 更新用户字段
    if method == "PATCH" and path:match("^/api/user/(%d+)/(.+)$") then
        local userId, field = path:match("^/api/user/(%d+)/(.+)$")
        userId = tonumber(userId)
        parseBody(req, function(data, err)
            if err then
                sendJSON(res, 400, {success = false, error = err})
                return
            end
            local db = userdb:new()
            local user = db:getOrCreateUser(userId)
            user[field] = data.value
            db:saveUser(userId, user)
            sendJSON(res, 200, {success = true})
        end)
        return
    end
    
    -- ==================== 会话管理 API ====================
    
    -- POST /api/session/online - 用户上线
    if method == "POST" and path == "/api/session/online" then
        parseBody(req, function(data, err)
            if err then
                sendJSON(res, 400, {success = false, error = err})
                return
            end
            sessionManager:userOnline(data.userId, data.serverType, data.mapId)
            sendJSON(res, 200, {success = true})
        end)
        return
    end
    
    -- POST /api/session/offline - 用户下线
    if method == "POST" and path == "/api/session/offline" then
        parseBody(req, function(data, err)
            if err then
                sendJSON(res, 400, {success = false, error = err})
                return
            end
            sessionManager:userOffline(data.userId)
            sendJSON(res, 200, {success = true})
        end)
        return
    end
    
    -- GET /api/session/online/:userId - 检查用户是否在线
    if method == "GET" and path:match("^/api/session/online/(%d+)$") then
        local userId = tonumber(path:match("^/api/session/online/(%d+)$"))
        local isOnline = sessionManager:isUserOnline(userId)
        local user = sessionManager:getOnlineUser(userId)
        sendJSON(res, 200, {success = true, online = isOnline, data = user})
        return
    end
    
    -- GET /api/session/online - 获取所有在线用户
    if method == "GET" and path == "/api/session/online" then
        local users = sessionManager:getAllOnlineUsers()
        sendJSON(res, 200, {success = true, data = users})
        return
    end
    
    -- ==================== NoNo 状态 API ====================
    
    -- POST /api/nono/following - 设置 NoNo 跟随状态
    if method == "POST" and path == "/api/nono/following" then
        parseBody(req, function(data, err)
            if err then
                sendJSON(res, 400, {success = false, error = err})
                return
            end
            sessionManager:setNonoFollowing(data.userId, data.isFollowing)
            sendJSON(res, 200, {success = true})
        end)
        return
    end
    
    -- GET /api/nono/following/:userId - 获取 NoNo 跟随状态
    if method == "GET" and path:match("^/api/nono/following/(%d+)$") then
        local userId = tonumber(path:match("^/api/nono/following/(%d+)$"))
        local isFollowing = sessionManager:getNonoFollowing(userId)
        sendJSON(res, 200, {success = true, following = isFollowing})
        return
    end
    
    -- ==================== 统计信息 API ====================
    
    -- GET /api/stats - 获取统计信息
    if method == "GET" and path == "/api/stats" then
        local stats = sessionManager:getStats()
        sendJSON(res, 200, {success = true, data = stats})
        return
    end
    
    -- GET /api/health - 健康检查
    if method == "GET" and path == "/api/health" then
        sendJSON(res, 200, {
            success = true,
            status = "ok",
            timestamp = os.time(),
            uptime = os.time() - (server.startTime or os.time())
        })
        return
    end
    
    -- 404
    sendJSON(res, 404, {success = false, error = "Not Found", path = path})
end)

server.startTime = os.time()

server:listen(conf.dataserver_port, "0.0.0.0", function()
    print(string.format("\27[32m[数据服务器] ✓ HTTP API 启动在端口 %d\27[0m", conf.dataserver_port))
    print(string.format("\27[36m[数据服务器] API 地址: http://127.0.0.1:%d/api/\27[0m", conf.dataserver_port))
    print("\27[36m[数据服务器] 可用端点:\27[0m")
    print("\27[36m  用户数据:\27[0m")
    print("\27[36m    - GET    /api/user/:id          - 获取用户\27[0m")
    print("\27[36m    - POST   /api/user/:id          - 保存用户\27[0m")
    print("\27[36m    - PATCH  /api/user/:id/:field   - 更新字段\27[0m")
    print("\27[36m  会话管理:\27[0m")
    print("\27[36m    - POST   /api/session/online    - 用户上线\27[0m")
    print("\27[36m    - POST   /api/session/offline   - 用户下线\27[0m")
    print("\27[36m    - GET    /api/session/online/:id - 检查在线\27[0m")
    print("\27[36m    - GET    /api/session/online    - 所有在线\27[0m")
    print("\27[36m  NoNo 状态:\27[0m")
    print("\27[36m    - POST   /api/nono/following    - 设置跟随\27[0m")
    print("\27[36m    - GET    /api/nono/following/:id - 获取跟随\27[0m")
    print("\27[36m  统计信息:\27[0m")
    print("\27[36m    - GET    /api/stats             - 统计信息\27[0m")
    print("\27[36m    - GET    /api/health            - 健康检查\27[0m")
    print("")
end)

-- 定时任务
local timer = require('timer')

-- 每 5 分钟清理离线用户
timer.setInterval(5 * 60 * 1000, function()
    sessionManager:cleanupOfflineUsers(300)
end)

-- 每 1 小时清理过期会话
timer.setInterval(60 * 60 * 1000, function()
    sessionManager:cleanupExpiredSessions(3600)
end)

-- 每 10 分钟打印统计信息
timer.setInterval(10 * 60 * 1000, function()
    sessionManager:printStats()
end)

-- 每 30 秒保存用户数据
timer.setInterval(30 * 1000, function()
    local db = userdb:new()
    db:save()
end)

-- 保持进程活跃
timer.setInterval(1000 * 60, function() end)

-- 监听标准输入
pcall(function()
    local uv = require('uv')
    local stdin = uv.new_tty(0, true)
    if stdin then
        stdin:read_start(function(err, data)
            if data and data:match("[\r\n]") then
                Logger.printSeparator()
            elseif data and data:match("stats") then
                sessionManager:printStats()
            end
        end)
    end
end)

-- 关闭时保存数据
local function saveAllData()
    print("\27[33m[数据服务器] 正在保存所有数据...\27[0m")
    local db = userdb:new()
    db:save()
    print("\27[32m[数据服务器] ✓ 数据已保存\27[0m")
end

-- Windows 兼容的自动保存
if package.config:sub(1,1) == '\\' then
    print("\27[33m[数据服务器] Windows 系统检测到，启用自动保存\27[0m")
end

-- 监听退出信号
pcall(function()
    process:on("SIGINT", function()
        print("\n\27[33m[数据服务器] 收到退出信号，正在关闭...\27[0m")
        saveAllData()
        os.exit(0)
    end)
end)

-- 全局错误捕获
process:on("uncaughtException", function(err)
    print("\27[31m[数据服务器] 错误: " .. tostring(err) .. "\27[0m")
    print(debug.traceback())
    saveAllData()
end)

print("\27[32m[数据服务器] ========== 服务器就绪 ==========\27[0m")
print("")
