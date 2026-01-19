-- OAuth Server for Seer Login
-- 本地模式：生成本地session token
-- 官服模式：代理官方token交换API

local http = require('http')
local JSON = require('json')

-- 获取日志模块
local Logger = require('../core/logger')

-- 生成随机hex token
local function generateToken()
    local chars = 'abcdef0123456789'
    local token = ''
    for i = 1, 32 do
        local rand = math.random(1, #chars)
        token = token .. chars:sub(rand, rand)
    end
    return token
end

-- Handle server mode detection
local function handleServerMode(req, res)
    local response = JSON.stringify({
        local_server_mode = conf.local_server_mode or false,
        use_official_resources = conf.use_official_resources or false
    })
    
    res:writeHead(200, {
        ['Content-Type'] = 'application/json',
        ['Access-Control-Allow-Origin'] = '*'
    })
    res:finish(response)
end

-- Handle local login (no OAuth, auto login)
local function handleLocalLogin(req, res)
    print('\27[32m[OAuth] ========================================\27[0m')
    print('\27[32m[OAuth] LOCAL AUTO LOGIN\27[0m')
    print('\27[32m[OAuth] ========================================\27[0m')
    
    local localToken = generateToken()
    local localUid = 100000001  -- 默认本地用户ID
    
    print(string.format('\27[32m[OAuth] Generated token: %s\27[0m', localToken))
    print(string.format('\27[32m[OAuth] User ID: %d\27[0m', localUid))
    
    Logger.logLogin("LOCAL_AUTO_LOGIN", localUid, "Token: " .. localToken)
    
    local response = JSON.stringify({
        result = 0,
        sid = localToken,
        uid = localUid,
        login_type = 'local'
    })
    
    res:writeHead(200, {
        ['Content-Type'] = 'application/json',
        ['Access-Control-Allow-Origin'] = '*'
    })
    res:finish(response)
end

-- Handle token exchange
local function handleTokenExchange(req, res)
    local url = req.url
    local code = url:match('code=([^&]+)')
    local duid = url:match('duid=([^&]+)') or ('duid_' .. os.time())
    
    if not code then
        print('\27[31m[OAuth] Token exchange: missing code parameter\27[0m')
        res:writeHead(400, {
            ['Content-Type'] = 'application/json',
            ['Access-Control-Allow-Origin'] = '*'
        })
        res:finish(JSON.stringify({result = -1, error = 'missing code'}))
        return
    end
    
    print(string.format('\27[36m[OAuth] ========================================\27[0m'))
    print(string.format('\27[36m[OAuth] Token exchange request\27[0m'))
    print(string.format('\27[36m[OAuth] code: %s\27[0m', code))
    print(string.format('\27[36m[OAuth] duid: %s\27[0m', duid))
    print(string.format('\27[36m[OAuth] ========================================\27[0m'))
    
    -- 检查是否是本地模式
    if conf.local_server_mode then
        -- 本地模式：生成本地session token
        local localToken = generateToken()
        local localUid = 100000001  -- 默认本地用户ID
        
        print('\27[32m[OAuth] LOCAL MODE: Generating local token\27[0m')
        print(string.format('\27[32m[OAuth] token: %s\27[0m', localToken))
        print(string.format('\27[32m[OAuth] uid: %d\27[0m', localUid))
        
        local response = JSON.stringify({
            result = 0,
            sid = localToken,
            uid = localUid,
            login_type = 'local'
        })
        
        res:writeHead(200, {
            ['Content-Type'] = 'application/json',
            ['Access-Control-Allow-Origin'] = '*'
        })
        res:finish(response)
        return
    end
    
    -- 官服模式：调用官方API
    local curlCmd = string.format(
        'curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "appid=20230714002&duid=%s&code=%s" "https://account-co.61.com/v3//token/trans"',
        duid, code
    )
    
    print('\27[36m[OAuth] Running curl...\27[0m')
    
    local handle = io.popen(curlCmd)
    local responseData = handle:read('*all')
    handle:close()
    
    print('\27[32m[OAuth] ========================================\27[0m')
    print('\27[32m[OAuth] Official API response:\27[0m')
    print('\27[32m[OAuth] ' .. responseData .. '\27[0m')
    print('\27[32m[OAuth] ========================================\27[0m')
    
    if responseData and responseData ~= '' then
        local success, result = pcall(function()
            return JSON.parse(responseData)
        end)
        
        if success and result and result.result == 0 and result.data then
            print('\27[32m[OAuth] ✓ Token exchange SUCCESS\27[0m')
            
            local simplifiedResponse = JSON.stringify({
                result = 0,
                sid = result.data.token,
                uid = result.data.uid,
                login_type = result.data.login_type
            })
            
            res:writeHead(200, {
                ['Content-Type'] = 'application/json',
                ['Access-Control-Allow-Origin'] = '*'
            })
            res:finish(simplifiedResponse)
        else
            print('\27[31m[OAuth] ✗ Token exchange FAILED\27[0m')
            res:writeHead(200, {
                ['Content-Type'] = 'application/json',
                ['Access-Control-Allow-Origin'] = '*'
            })
            res:finish(responseData)
        end
    else
        print('\27[31m[OAuth] ✗ curl returned empty response\27[0m')
        res:writeHead(500, {
            ['Content-Type'] = 'application/json',
            ['Access-Control-Allow-Origin'] = '*'
        })
        res:finish(JSON.stringify({result = -1, error = 'curl failed'}))
    end
end

-- Handle OPTIONS preflight
local function handleOptions(req, res)
    res:writeHead(200, {
        ['Access-Control-Allow-Origin'] = '*',
        ['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS',
        ['Access-Control-Allow-Headers'] = 'Content-Type'
    })
    res:finish()
end

-- Main request handler
local function handleRequest(req, res)
    print('OAuth request:', req.method, req.url)
    
    if req.method == 'OPTIONS' then
        return handleOptions(req, res)
    end
    
    if req.url:match('/server_mode') then
        return handleServerMode(req, res)
    end
    
    if req.url:match('/local_login') then
        return handleLocalLogin(req, res)
    end
    
    if req.url:match('/token_exchange') then
        return handleTokenExchange(req, res)
    end
    
    res:writeHead(404, {['Content-Type'] = 'text/plain'})
    res:finish('Not Found')
end

-- Start server
local oauthServer = http.createServer(function(req, res)
    handleRequest(req, res)
end)

oauthServer:on('error', function(err)
    print("\27[31m[OAUTH-SERVER] Error: " .. tostring(err) .. "\27[0m")
end)

oauthServer:listen(8080, "0.0.0.0", function()
    print("\27[32m[OAUTH-SERVER] ✓ Successfully listening on port 8080\27[0m")
end)

print('OAuth mock server started on http://127.0.0.1:8080/')
