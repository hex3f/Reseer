-- API 服务器 - 提供配置管理、用户登录、注册等接口
local http = require "http"
local json = require "json"
local fs = require "fs"

local API_PORT = 8211

-- ========== 用户数据库 ==========
local UserDB = {
    dbPath = "./users.json",
    users = {},
    sessions = {},  -- session -> userId 映射
    nextUserId = 100000001
}

-- 生成随机 token
local function generateToken(length)
    length = length or 32
    local chars = 'abcdef0123456789'
    local token = ''
    for i = 1, length do
        local rand = math.random(1, #chars)
        token = token .. chars:sub(rand, rand)
    end
    return token
end

-- 生成 Flash 客户端需要的 session 格式
-- Flash 客户端解析: 前4字节=userId, 后16字节=sessionToken
-- 官服格式: 0af782700af7827000000000696851ab2014c63bfb855bb0 (48字符=24字节)
-- 但 Flash 只读取前 20 字节 (4+16)
-- 为了兼容，我们生成 24 字节的 session
local function generateFlashSession(userId)
    -- 将 userId 转换为4字节大端十六进制
    local userIdHex = string.format("%08x", userId)
    -- 生成20字节随机 session token (40个十六进制字符)
    -- 结构: userId(4字节) + userId(4字节) + 填充(4字节) + token(12字节) = 24字节
    local sessionToken = generateToken(24)
    -- 组合: userId(8字符) + userId(8字符) + 填充(8字符) + sessionToken(24字符) = 48字符
    return userIdHex .. userIdHex .. "00000000" .. sessionToken
end

-- 加载用户数据
function UserDB:load()
    if fs.existsSync(self.dbPath) then
        local data = fs.readFileSync(self.dbPath)
        local success, result = pcall(function()
            return json.parse(data)
        end)
        if success and result then
            self.users = result.users or {}
            self.nextUserId = result.nextUserId or 100000001
            local count = 0
            for _ in pairs(self.users) do count = count + 1 end
            print("\27[32m[UserDB] 加载了 " .. count .. " 个用户\27[0m")
        else
            print("\27[33m[UserDB] 用户数据解析失败，使用空数据库\27[0m")
            self.users = {}
        end
    else
        print("\27[33m[UserDB] 用户数据库不存在，创建新数据库\27[0m")
        self.users = {}
        self:save()
    end
end

-- 保存用户数据
function UserDB:save()
    local data = json.stringify({
        users = self.users,
        nextUserId = self.nextUserId
    })
    fs.writeFileSync(self.dbPath, data)
end

-- 查找用户（通过用户名或邮箱）
function UserDB:findUser(identifier)
    -- 先按用户名查找
    for uid, user in pairs(self.users) do
        if user.username == identifier or user.email == identifier then
            return user
        end
    end
    return nil
end

-- 通过 userId 查找
function UserDB:findByUserId(userId)
    return self.users[tostring(userId)]
end

-- 通过 session 查找
function UserDB:findBySession(session)
    local userId = self.sessions[session]
    if userId then
        return self:findByUserId(userId)
    end
    return nil
end

-- 创建用户
function UserDB:createUser(username, password, email)
    -- 检查用户名是否已存在
    if self:findUser(username) then
        return nil, "用户名已被使用"
    end
    
    local userId = self.nextUserId
    self.nextUserId = self.nextUserId + 1
    
    local user = {
        userId = userId,
        username = username,
        password = password,  -- 实际应该加密存储
        email = email or (username .. "@local.seer"),
        nickname = username,
        registerTime = os.time(),
        lastLoginTime = os.time(),
        vipLevel = 0,
        coins = 100000,
        diamonds = 1000,
        level = 1,
        exp = 0,
        session = nil,
        token = nil
    }
    
    self.users[tostring(userId)] = user
    self:save()
    
    print(string.format("\27[32m[UserDB] 创建新用户: %s (ID: %d)\27[0m", username, userId))
    return user
end

-- 验证登录
function UserDB:verifyLogin(username, password)
    local user = self:findUser(username)
    if not user then
        return nil, "用户不存在"
    end
    
    if user.password ~= password then
        return nil, "密码错误"
    end
    
    -- 生成 Flash 客户端需要的 session 格式
    -- 官服格式: userId(4字节) + userId(4字节) + 填充(4字节) + sessionToken(12字节) = 48字符hex
    local session = generateFlashSession(user.userId)
    local token = generateToken(32)
    
    user.session = session
    user.token = token
    user.lastLoginTime = os.time()
    
    -- 记录 session 映射 (使用完整session作为key)
    self.sessions[session] = user.userId
    
    self:save()
    
    print(string.format("\27[36m[UserDB] 生成 session: %s (userId=%d)\27[0m", session, user.userId))
    
    return user
end

-- 初始化数据库
UserDB:load()

-- 如果没有用户，创建默认测试用户 (可选，注释掉则不自动创建)
-- if next(UserDB.users) == nil then
--     UserDB:createUser("test", "123456", "test@local.seer")
--     UserDB:createUser("admin", "admin", "admin@local.seer")
--     print("\27[33m[UserDB] 已创建默认测试用户: test/123456, admin/admin\27[0m")
-- end

print("\27[36m[API-SERVER] Starting API server...\27[0m")

local apiServer = http.createServer(function(req, res)
    -- CORS 头
    local corsHeaders = {
        ["Access-Control-Allow-Origin"] = "*",
        ["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS",
        ["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With",
        ["Content-Type"] = "application/json"
    }
    
    -- 辅助函数：发送 JSON 响应
    local function sendJson(statusCode, data)
        local body = json.stringify(data)
        corsHeaders["Content-Length"] = #body
        res:writeHead(statusCode, corsHeaders)
        res:write(body)
        res:finish()
    end
    
    -- 处理 OPTIONS 预检请求
    if req.method == "OPTIONS" then
        res:writeHead(200, corsHeaders)
        res:finish()
        return
    end
    
    local url = require("url")
    req.uri = url.parse(req.url)
    local path = req.uri.pathname
    
    -- ========== GET /api/mode - 获取当前模式 ==========
    if path == "/api/mode" and req.method == "GET" then
        sendJson(200, {
            local_server_mode = conf.local_server_mode,
            use_official_resources = conf.use_official_resources,
            pure_official_mode = conf.pure_official_mode,
            server_info = {
                login_server = conf.local_server_mode and "127.0.0.1:" .. conf.login_port or conf.login_server_address,
                game_server = conf.local_server_mode and "127.0.0.1:" .. conf.gameserver_port or conf.login_server_address,
                api_server = "http://127.0.0.1:" .. API_PORT
            }
        })
        print("\27[36m[API-SERVER] GET /api/mode - Mode: " .. (conf.local_server_mode and "LOCAL" or "OFFICIAL") .. "\27[0m")
        return
    end
    
    -- ========== POST /api/mode - 切换模式 ==========
    if path == "/api/mode" and req.method == "POST" then
        local body = ""
        req:on('data', function(chunk) body = body .. chunk end)
        req:on('end', function()
            local success, data = pcall(json.parse, body)
            if not success or not data then
                sendJson(400, { code = 400, error = "Invalid JSON" })
                return
            end
            
            if data.local_server_mode ~= nil then
                local oldMode = conf.local_server_mode
                conf.local_server_mode = data.local_server_mode
                print("\27[33m[API-SERVER] Mode: " .. (oldMode and "LOCAL" or "OFFICIAL") .. " -> " .. (conf.local_server_mode and "LOCAL" or "OFFICIAL") .. "\27[0m")
            end
            
            sendJson(200, {
                code = 200,
                local_server_mode = conf.local_server_mode,
                message = "Mode updated (restart may be required)"
            })
        end)
        return
    end
    
    -- ========== GET /api/config - 获取完整配置 ==========
    if path == "/api/config" and req.method == "GET" then
        sendJson(200, {
            local_server_mode = conf.local_server_mode,
            use_official_resources = conf.use_official_resources,
            pure_official_mode = conf.pure_official_mode,
            trafficlogger = conf.trafficlogger,
            servers = {
                ressrv_port = conf.ressrv_port,
                login_port = conf.login_port,
                gameserver_port = conf.gameserver_port
            }
        })
        return
    end

    -- ========== POST /seer/customer/login - 用户登录 ==========
    if path == "/seer/customer/login" and req.method == "POST" then
        local body = ""
        req:on('data', function(chunk) body = body .. chunk end)
        req:on('end', function()
            -- 本地模式：本地处理登录
            if conf.local_server_mode then
                print("\27[32m[API-SERVER] [LOCAL] POST /seer/customer/login\27[0m")
                
                local success, data = pcall(json.parse, body)
                if not success or not data then
                    sendJson(400, { code = 400, message = "Invalid request data" })
                    return
                end
                
                local username = data.username or data.account or data.email
                local password = data.password or data.pwd or ""
                
                if not username then
                    sendJson(400, { code = 400, message = "用户名不能为空" })
                    return
                end
                
                -- 尝试登录
                local user, err = UserDB:verifyLogin(username, password)
                
                if not user then
                    -- 如果用户不存在，自动注册
                    print("\27[33m[API-SERVER] 用户不存在，自动注册: " .. username .. "\27[0m")
                    user, err = UserDB:createUser(username, password)
                    if not user then
                        sendJson(400, { code = 400, message = err or "注册失败" })
                        return
                    end
                    -- 注册后自动登录
                    user, err = UserDB:verifyLogin(username, password)
                end
                
                if user then
                    -- 使用官服相同的响应格式
                    sendJson(200, {
                        msg = "success",
                        code = 200,
                        permissions = {},
                        session = user.session,
                        token = user.token,
                        -- 额外信息（可选）
                        userId = user.userId,
                        username = user.username,
                        nickname = user.nickname or user.username
                    })
                    print("\27[32m[API-SERVER] 登录成功: " .. username .. " (ID: " .. user.userId .. ")\27[0m")
                else
                    sendJson(401, { code = 401, msg = err or "登录失败" })
                end
                return
            end
            
            -- 官服模式：转发到官服
            print("\27[33m[API-SERVER] Proxying /seer/customer/login to official...\27[0m")
            proxyToOfficial(req, res, path, body, corsHeaders)
        end)
        return
    end
    
    -- ========== POST /seer/customer/register - 用户注册 ==========
    if path == "/seer/customer/register" and req.method == "POST" then
        local body = ""
        req:on('data', function(chunk) body = body .. chunk end)
        req:on('end', function()
            if conf.local_server_mode then
                print("\27[32m[API-SERVER] [LOCAL] POST /seer/customer/register\27[0m")
                
                local success, data = pcall(json.parse, body)
                if not success or not data then
                    sendJson(400, { code = 400, message = "Invalid request data" })
                    return
                end
                
                local username = data.username or data.account
                local password = data.password or data.pwd
                local email = data.email
                
                if not username or not password then
                    sendJson(400, { code = 400, message = "用户名和密码不能为空" })
                    return
                end
                
                local user, err = UserDB:createUser(username, password, email)
                if user then
                    sendJson(200, {
                        code = 200,
                        message = "注册成功",
                        data = {
                            userId = user.userId,
                            username = user.username
                        }
                    })
                    print("\27[32m[API-SERVER] 注册成功: " .. username .. "\27[0m")
                else
                    sendJson(400, { code = 400, message = err or "注册失败" })
                end
                return
            end
            
            proxyToOfficial(req, res, path, body, corsHeaders)
        end)
        return
    end
    
    -- ========== GET /seer/customer/info - 获取用户信息 ==========
    if path == "/seer/customer/info" and req.method == "GET" then
        if conf.local_server_mode then
            -- 从 query 或 header 获取 session
            local query = req.uri.query or ""
            local session = query:match("session=([^&]+)") or query:match("token=([^&]+)")
            
            local user = nil
            if session then
                user = UserDB:findBySession(session)
            end
            
            if user then
                sendJson(200, {
                    code = 200,
                    message = "success",
                    data = {
                        userId = user.userId,
                        username = user.username,
                        nickname = user.nickname or user.username,
                        vipLevel = user.vipLevel or 0,
                        coins = user.coins or 0,
                        diamonds = user.diamonds or 0,
                        level = user.level or 1,
                        exp = user.exp or 0
                    }
                })
            else
                -- 返回默认用户信息
                sendJson(200, {
                    code = 200,
                    message = "success",
                    data = {
                        userId = 100000001,
                        username = "local_player",
                        nickname = "本地玩家",
                        vipLevel = 1,
                        coins = 100000,
                        diamonds = 1000,
                        level = 100,
                        exp = 0
                    }
                })
            end
            return
        end
        
        proxyToOfficial(req, res, path, "", corsHeaders)
        return
    end
    
    -- ========== POST /seer/login - 简化登录接口 ==========
    if path == "/seer/login" and req.method == "POST" then
        local body = ""
        req:on('data', function(chunk) body = body .. chunk end)
        req:on('end', function()
            if conf.local_server_mode then
                local success, data = pcall(json.parse, body)
                local username = "guest"
                if success and data then
                    username = data.username or data.account or "guest"
                end
                
                -- 自动登录/注册
                local user = UserDB:findUser(username)
                if not user then
                    user = UserDB:createUser(username, "123456")
                end
                
                if user then
                    user, _ = UserDB:verifyLogin(username, user.password)
                end
                
                sendJson(200, {
                    code = 200,
                    message = "success",
                    session = user and user.session or generateToken(32),
                    token = user and user.token or generateToken(32),
                    userId = user and user.userId or 100000001,
                    username = username
                })
                print("\27[32m[API-SERVER] [LOCAL] 快速登录: " .. username .. "\27[0m")
                return
            end
            
            proxyToOfficial(req, res, path, body, corsHeaders)
        end)
        return
    end

    -- ========== GET /seer/server/list - 服务器列表 ==========
    if path == "/seer/server/list" and req.method == "GET" then
        if conf.local_server_mode then
            sendJson(200, {
                code = 200,
                message = "success",
                data = {
                    servers = {
                        {
                            id = 1,
                            name = "本地服务器",
                            host = "127.0.0.1",
                            port = conf.gameserver_port or 5000,
                            status = 1,
                            online = 1,
                            maxOnline = 9999
                        }
                    }
                }
            })
            return
        end
        
        proxyToOfficial(req, res, path, "", corsHeaders)
        return
    end
    
    -- ========== GET /seer/game/getSessionByAuth - Flash 客户端邮箱登录 ==========
    -- Flash 客户端通过这个 API 进行邮箱登录
    -- 请求格式: /seer/game/getSessionByAuth?email=xxx&password=xxx&t=随机数
    -- 返回格式: IP:PORT (登录服务器地址)
    if path:match("^/seer/game/getSessionByAuth") and req.method == "GET" then
        local query = req.uri.query or ""
        local email = query:match("email=([^&]+)")
        local password = query:match("password=([^&]+)")
        
        print("\27[32m[API-SERVER] GET /seer/game/getSessionByAuth\27[0m")
        print("\27[36m[API-SERVER] Email: " .. (email or "nil") .. "\27[0m")
        
        if conf.local_server_mode then
            -- 本地模式：验证用户并返回登录服务器地址
            if email and password then
                -- URL 解码
                email = email:gsub("%%40", "@"):gsub("%%2E", "."):gsub("%%2B", "+")
                password = password:gsub("%%([0-9A-Fa-f][0-9A-Fa-f])", function(h)
                    return string.char(tonumber(h, 16))
                end)
                
                -- 尝试登录或自动注册
                local user, err = UserDB:verifyLogin(email, password)
                if not user then
                    -- 自动注册
                    user, err = UserDB:createUser(email, password, email)
                    if user then
                        user, err = UserDB:verifyLogin(email, password)
                    end
                end
                
                if user then
                    print("\27[32m[API-SERVER] 邮箱登录成功: " .. email .. " (ID: " .. user.userId .. ")\27[0m")
                    print("\27[32m[API-SERVER] Session: " .. user.session .. "\27[0m")
                end
            end
            
            -- 返回登录服务器地址 (Flash 客户端期望的格式是 IP:PORT)
            local loginServer = "127.0.0.1:" .. (conf.login_port or 1863)
            res:writeHead(200, {
                ["Content-Type"] = "text/plain",
                ["Content-Length"] = #loginServer,
                ["Access-Control-Allow-Origin"] = "*"
            })
            res:write(loginServer)
            res:finish()
            print("\27[32m[API-SERVER] 返回登录服务器: " .. loginServer .. "\27[0m")
            return
        end
        
        -- 官服模式：代理到官服
        proxyToOfficial(req, res, path .. "?" .. query, "", corsHeaders)
        return
    end
    
    -- ========== GET /seer/game/getSession - 获取游戏 Session ==========
    -- 这是 Vue 应用用来获取 Flash 游戏 session 的关键 API
    -- 官服请求格式: /seer/game/getSession?t=加密时间戳&d=加密token
    -- 官服返回格式: {code: 200, session: "48字符hex"}
    if path:match("^/seer/game/getSession") and req.method == "GET" then
        if conf.local_server_mode then
            print("\27[32m[API-SERVER] [LOCAL] GET /seer/game/getSession\27[0m")
            
            -- 从 query 参数获取加密的 session 信息
            local query = req.uri.query or ""
            print("\27[36m[API-SERVER] Query: " .. query .. "\27[0m")
            
            -- 查找当前登录的用户
            local lastUser = nil
            local lastSession = nil
            for session, userId in pairs(UserDB.sessions) do
                lastUser = UserDB:findByUserId(userId)
                lastSession = session
                if lastUser then break end
            end
            
            if lastUser and lastSession then
                -- 返回游戏 session 信息 - 格式与官服一致
                sendJson(200, {
                    code = 200,
                    session = lastSession  -- 直接返回 session，不嵌套在 data 中
                })
                print("\27[32m[API-SERVER] 返回游戏 session: " .. lastSession .. "\27[0m")
            else
                -- 没有登录用户，返回默认 session
                local defaultSession = generateFlashSession(100000001)
                sendJson(200, {
                    code = 200,
                    session = defaultSession
                })
                print("\27[33m[API-SERVER] 返回默认游戏 session: " .. defaultSession .. "\27[0m")
            end
            return
        end
        
        proxyToOfficial(req, res, path .. "?" .. (req.uri.query or ""), "", corsHeaders)
        return
    end
    
    -- ========== GET /seer/game/config - 游戏配置 ==========
    if path == "/seer/game/config" and req.method == "GET" then
        if conf.local_server_mode then
            sendJson(200, {
                code = 200,
                message = "success",
                data = {
                    version = "1.0.6.8",
                    maintenance = false,
                    announcement = "欢迎来到本地服务器！",
                    loginServer = "127.0.0.1:" .. (conf.login_port or 1863),
                    gameServer = "127.0.0.1:" .. (conf.gameserver_port or 5000),
                    resourceServer = "http://127.0.0.1:" .. (conf.ressrv_port or 32400)
                }
            })
            return
        end
        
        proxyToOfficial(req, res, path, "", corsHeaders)
        return
    end
    
    -- ========== POST /seer/customer/logout - 登出 ==========
    if path == "/seer/customer/logout" and req.method == "POST" then
        if conf.local_server_mode then
            sendJson(200, { code = 200, message = "登出成功" })
            return
        end
        
        local body = ""
        req:on('data', function(chunk) body = body .. chunk end)
        req:on('end', function()
            proxyToOfficial(req, res, path, body, corsHeaders)
        end)
        return
    end
    
    -- ========== GET /seer/customer/check - 检查登录状态 ==========
    if (path == "/seer/customer/check" or path == "/seer/customer/session") and req.method == "GET" then
        if conf.local_server_mode then
            sendJson(200, {
                code = 200,
                message = "success",
                data = { valid = true, loggedIn = true }
            })
            return
        end
        
        proxyToOfficial(req, res, path, "", corsHeaders)
        return
    end
    
    -- ========== 通用 /seer/* 代理 ==========
    if path:match("^/seer/") then
        local body = ""
        req:on('data', function(chunk) body = body .. chunk end)
        req:on('end', function()
            if conf.local_server_mode then
                print("\27[32m[API-SERVER] [LOCAL] " .. req.method .. " " .. path .. " (返回默认响应)\27[0m")
                sendJson(200, {
                    code = 200,
                    message = "success",
                    data = {},
                    local_mode = true
                })
                return
            end
            
            proxyToOfficial(req, res, path, body, corsHeaders)
        end)
        return
    end
    
    -- ========== 404 Not Found ==========
    sendJson(404, { code = 404, error = "Not Found", path = path })
end)

-- ========== 代理到官服的辅助函数 ==========
function proxyToOfficial(req, res, path, body, corsHeaders)
    -- 官服模式下详细记录请求
    print("\27[35m╔══════════════════════════════════════════════════════════════╗\27[0m")
    print("\27[35m║ [API→官服] " .. req.method .. " " .. path .. "\27[0m")
    print("\27[35m╚══════════════════════════════════════════════════════════════╝\27[0m")
    print("\27[36m[API→官服] 目标: " .. conf.official_api_server .. path .. "\27[0m")
    
    if body and #body > 0 then
        print("\27[36m[API→官服] 请求体: " .. body:sub(1, 200) .. (body:len() > 200 and "..." or "") .. "\27[0m")
    end
    
    local url = require("url")
    local officialUrl = url.parse(conf.official_api_server .. path)
    local httpModule = officialUrl.protocol == "https:" and require("https") or require("http")
    
    local headers = {
        ["Content-Type"] = "application/json",
        ["User-Agent"] = "Mozilla/5.0"
    }
    
    if body and #body > 0 then
        headers["Content-Length"] = #body
    end
    
    local startTime = os.clock()
    
    local officialReq = httpModule.request({
        host = officialUrl.hostname,
        port = officialUrl.port or (officialUrl.protocol == "https:" and 443 or 80),
        path = officialUrl.path,
        method = req.method,
        headers = headers
    }, function(officialRes)
        local officialBody = ""
        
        officialRes:on('data', function(chunk)
            officialBody = officialBody .. chunk
        end)
        
        officialRes:on('end', function()
            local elapsed = math.floor((os.clock() - startTime) * 1000)
            print("\27[32m[API←官服] 状态: " .. officialRes.statusCode .. " (" .. elapsed .. "ms)\27[0m")
            print("\27[32m[API←官服] 响应: " .. officialBody:sub(1, 300) .. (officialBody:len() > 300 and "..." or "") .. "\27[0m")
            print("\27[90m────────────────────────────────────────────────────────────────\27[0m")
            corsHeaders["Content-Length"] = #officialBody
            res:writeHead(officialRes.statusCode, corsHeaders)
            res:write(officialBody)
            res:finish()
        end)
    end)
    
    officialReq:on('error', function(err)
        print("\27[31m[API←官服] 错误: " .. tostring(err) .. "\27[0m")
        print("\27[90m────────────────────────────────────────────────────────────────\27[0m")
        local errorBody = json.stringify({ 
            code = 500,
            error = "Official server unavailable",
            message = tostring(err)
        })
        corsHeaders["Content-Length"] = #errorBody
        res:writeHead(500, corsHeaders)
        res:write(errorBody)
        res:finish()
    end)
    
    if body and #body > 0 then
        officialReq:write(body)
    end
    officialReq:done()
end

apiServer:on('error', function(err)
    print("\27[31m[API-SERVER] Error: " .. tostring(err) .. "\27[0m")
end)

apiServer:listen(API_PORT, "0.0.0.0", function()
    print("\27[32m[API-SERVER] ✓ Listening on port " .. API_PORT .. "\27[0m")
    print("\27[36m[API-SERVER] API endpoints:\27[0m")
    print("\27[36m  GET  /api/mode              - 获取当前模式\27[0m")
    print("\27[36m  POST /api/mode              - 切换模式\27[0m")
    print("\27[36m  GET  /api/config            - 获取配置\27[0m")
    print("\27[36m  POST /seer/customer/login   - 用户登录\27[0m")
    print("\27[36m  POST /seer/customer/register- 用户注册\27[0m")
    print("\27[36m  GET  /seer/customer/info    - 用户信息\27[0m")
    print("\27[36m  GET  /seer/server/list      - 服务器列表\27[0m")
    print("\27[36m  GET  /seer/game/config      - 游戏配置\27[0m")
    if conf.local_server_mode then
        print("\27[32m[API-SERVER] ✓ LOCAL MODE: All requests handled locally\27[0m")
    else
        print("\27[33m[API-SERVER] ⚠ OFFICIAL MODE: Requests proxied to " .. conf.official_api_server .. "\27[0m")
    end
end)
