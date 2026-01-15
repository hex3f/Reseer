local http = require "http"
local url = require "url"
local fs = require "fs"
local Response = http.ServerResponse

-- 根据模式选择登录服务器地址
local function getLoginServerAddress()
    if conf.local_server_mode then
        -- 本地模式：返回本地登录服务器地址
        -- 格式: IP:PORT
        return "127.0.0.1:" .. conf.login_port
    else
        -- 官服代理模式：返回本地代理地址
        -- Vue 应用会连接到这个地址，然后代理转发到官服
        return "127.0.0.1:" .. conf.login_port
    end
end

local resp_404 = "404 Not Found"
local ipServer = http.createServer(function(req, res)
    req.uri = url.parse(req.url)
    if req.uri.pathname ~= "/ip.txt" then
        res:writeHead(404, {
            ["Content-Type"] = "text/plain",
            ["Content-Length"] = #resp_404
        })
        res:write(resp_404)
        return
    end
    
    local resp = getLoginServerAddress()
    local modeStr = conf.local_server_mode and "[Local Mode]" or "[Official Mode]"
    
    res:writeHead(200, {
        ["Content-Type"] = "text/plain",
        ["Content-Length"] = #resp
    })
    res:write(resp)
    
    if conf.local_server_mode then
        print(string.format("\27[32m%s ✓ 返回本地登录服务器地址: %s\27[0m", modeStr, resp))
    else
        print(string.format("\27[35m%s ✓ 返回本地代理地址: %s (转发到官服 %s:%d)\27[0m", 
            modeStr, resp, conf.official_login_server or "45.125.46.70", conf.official_login_port or 12345))
    end
end)

ipServer:on('error', function(err)
    print("\27[31m[IP-SERVER] Error: " .. tostring(err) .. "\27[0m")
end)

ipServer:listen(conf.loginip_port, "0.0.0.0", function()
    print("\27[32m[IP-SERVER] ✓ Successfully listening on port " .. conf.loginip_port .. "\27[0m")
end)

print("\27[36mLogin http server started on \27[1mhttp://127.0.0.1:"..conf.loginip_port.."/\27[0m")
