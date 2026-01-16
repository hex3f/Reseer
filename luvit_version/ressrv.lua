local http = require "http"
local https = require "https"
local url = require "url"
local fs = require "fs"
local pathlib = require "path"
local Response = http.ServerResponse
local root = conf.res_dir
local proxy_root = conf.res_proxy_dir
local mimes = require "./mimes"
mimes.default = "application/octet-stream"

-- 获取日志模块
local Logger = require("./logger")

-- 确保根目录存在
if not fs.existsSync(root) then
    print("\27[33mCreating root directory: "..root.."\27[0m")
    fs.mkdirSync(root)
end

-- Redirection
local PASSTHROUGH = 0   -- 发送官方原版资源文件
local PROXY = 1         -- 发送修改过的资源文件
local INVISIBLE = 3     -- 404 不存在
local DEFAULT = PASSTHROUGH

local proxy_rules = 
{
    ["/"] = "/index.html",  -- 本地前端页面
    ["/index.html"] = PROXY,  -- 本地前端
    ["/config/ServerR.xml"] = "DYNAMIC_SERVER_CONFIG",  -- 动态选择配置文件
    ["/config/ServerOfficial.xml"] = PROXY,  -- 官服代理模式配置
    ["/config/ServerLocal.xml"] = PROXY,  -- 本地模式配置（备用）
    ["/config/doorConfig.xml"] = PROXY,  -- 开门配置（防沉迷时间）
    ["/crossdomain.xml"] = PROXY,  -- 跨域策略文件
    
    -- JS 文件
    ["/js/swfobject.js"] = PROXY,
    ["/js/server-config.js"] = PROXY,         -- 服务器配置（自动生成）
    ["/js/client-emulator.js"] = PROXY,       -- Flash 辅助脚本
    
    -- 隐藏广告
    ["/resource/login/Advertisement.swf"] = INVISIBLE,
}

local INVISIBLE_REASON = "the file is defined as invisible by proxy_rules"

function getType(path)
    return mimes[path:lower():match("[^.]*$")] or mimes.default
end

function Response:notFound(path,reason)
    local resp = self
    local data = ""
    
    -- 如果 use_official_resources = false，直接返回 404，不从官服下载
    if not conf.use_official_resources then
        local errorMsg = "File not found (local mode, official resources disabled): " .. path
        print(string.format("\27[31m[404] %s\27[0m", path))
        resp:writeHead(404, {
            ["Content-Type"] = "text/plain",
            ["Content-Length"] = #errorMsg,
            ["Access-Control-Allow-Origin"] = "*"
        })
        resp:write(errorMsg)
        return
    end
    
    -- 赛尔号官方地址
    local baseUrl = conf.res_official_address:gsub("/$", "")
    local officialUrl = baseUrl .. path
    
    print(string.format("\27[36m[官服下载] 开始下载: %s\27[0m", officialUrl))
    
    local function fetchUrl(urlStr, callback)
        -- 判断使用 http 还是 https
        local protocol = https
        if urlStr:match("^http://") then
            protocol = http
        end
        
        -- 解析 URL
        local parsedUrl = require('url').parse(urlStr)
        local options = {
            host = parsedUrl.hostname,
            port = parsedUrl.port or (parsedUrl.protocol == "https:" and 443 or 80),
            path = parsedUrl.pathname .. (parsedUrl.search or ""),
            method = "GET",
            headers = {
                ["Host"] = parsedUrl.hostname,
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                ["Accept"] = "*/*",
                ["Connection"] = "keep-alive"
            }
        }
        
        print(string.format("\27[36m[官服下载] 请求: %s://%s%s\27[0m", 
            parsedUrl.protocol:gsub(":", ""), options.host, options.path))
        
        local fetchReq = protocol.request(options, function(res)
            local fetchData = ""
            
            -- 处理重定向
            if res.statusCode == 301 or res.statusCode == 302 then
                local location = nil
                for i, header in ipairs(res.headers) do
                    if header[1]:lower() == "location" then
                        location = header[2]
                        break
                    end
                end
                
                if location then
                    print("\27[33mRedirecting to: "..location,"\27[0m")
                    -- 检查是否是相对路径
                    if not location:match("^https?://") then
                        location = baseUrl .. location
                    end
                    -- 避免无限循环
                    if location ~= urlStr then
                        fetchUrl(location, callback)
                        return
                    end
                end
            end
            
            res:on('data', function (chunk)
                fetchData = fetchData .. chunk
            end)
            
            res:on('end', function()
                callback(res.statusCode, fetchData)
            end)
        end)
        
        fetchReq:on('error', function(err)
            print("\27[31m[官服下载] 请求错误: "..tostring(err).."\27[0m")
            print("\27[31m[官服下载] URL: "..urlStr.."\27[0m")
            callback(0, "")
        end)
        
        fetchReq:done()
    end
    
    fetchUrl(officialUrl, function(statusCode, fetchedData)
        print(string.format("\27[36m[官服下载] 响应: status=%d, size=%d bytes\27[0m", statusCode, #fetchedData))
        
        if statusCode == 200 and #fetchedData > 0 then
            print(string.format("\27[90m[下载] %s (%d bytes)\27[0m", path, #fetchedData))
            
            -- 记录到日志
            Logger.logResource("DOWNLOAD", path, 200, #fetchedData)
            
            -- 如果是 SWF 文件，特别标记
            if path:lower():match("%.swf$") then
                print(string.format("\27[35m[SWF下载] %s\27[0m", path))
            end
            
            -- 确定保存路径
            local savePath = path
            if savePath == "/" or savePath == "" then
                savePath = "/index.html"
            end
            
            local fullPath = root .. savePath
            local dirPath = fullPath:match("(.*/)")
            
            if dirPath then
                -- 递归创建所有父目录
                local parts = {}
                for part in dirPath:gmatch("[^/]+") do
                    table.insert(parts, part)
                end
                
                local curr = ""
                for i, part in ipairs(parts) do
                    if i == 1 and part:match("^%.%.") then
                        curr = part
                    else
                        curr = curr == "" and part or (curr .. "/" .. part)
                    end
                    
                    if not fs.existsSync(curr) then
                        local ok, err = pcall(function()
                            fs.mkdirSync(curr)
                        end)
                    end
                end
            end
            
            -- 保存文件
            local success, err = pcall(function()
                fs.writeFileSync(fullPath, fetchedData)
            end)
            
            if success then
                resp:writeHead(200, {
                    ["Content-Type"] = getType(savePath),
                    ["Content-Length"] = #fetchedData,
                    ["Access-Control-Allow-Origin"] = "*",
                    ["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS",
                    ["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With"
                })
                resp:write(fetchedData)
            else
                local errorMsg = "Failed to save file: " .. tostring(err)
                resp:writeHead(500, {
                    ["Content-Type"] = "text/plain",
                    ["Content-Length"] = #errorMsg,
                    ["Access-Control-Allow-Origin"] = "*"
                })
                resp:write(errorMsg)
            end
        else
            local errorMsg = reason or "File not found"
            resp:writeHead(404, {
                ["Content-Type"] = "text/plain",
                ["Content-Length"] = #errorMsg,
                ["Access-Control-Allow-Origin"] = "*"
            })
            resp:write(errorMsg)
        end
    end)
end

function Response:error(reason)
    self:writeHead(500, {
        ["Content-Type"] = "text/plain",
        ["Content-Length"] = #reason
    })
    self:write(reason)
end

local function resolvePathByProxyRules(dest)
    local proxy_rule = proxy_rules[dest] or DEFAULT
    local rootpath = root
    local code = 200
    if proxy_rule == PROXY then
        rootpath = proxy_root
    elseif proxy_rule == PASSTHROUGH then
        -- Do nothing
    elseif proxy_rule == REDIRECT then
        code = 301
    elseif proxy_rule == INVISIBLE then
        code = 404
    elseif type(proxy_rule) == "string" then
        return resolvePathByProxyRules(proxy_rule)
    end
    return (rootpath .. dest),code
end

-- 路由别名 - 这些路由都返回主页面
local spa_routes = {
    ["/game"] = "/index.html",
}

local resServer = http.createServer(function(req, res)
    req.uri = url.parse(req.url)
    local dest = req.uri.pathname
    
    -- ========== 过滤掉不需要的请求 ==========
    if dest:match("favicon%.ico$") or dest:match("logo%.png$") then
        res:writeHead(204, {
            ["Access-Control-Allow-Origin"] = "*"
        })
        res:finish()
        return
    end
    
    -- ========== 动态选择 ServerR.xml ==========
    if dest == "/config/ServerR.xml" then
        if conf.local_server_mode then
            -- 本地模式：使用本地配置文件
            local configFile = proxy_root .. "/config/ServerR.xml"
            print("\27[36m[CONFIG] 本地模式: 使用 ServerR.xml (本地服务器)\27[0m")
            
            fs.stat(configFile, function(err, stat)
                if not err and stat.type == "file" then
                    res:writeHead(200, {
                        ["Content-Type"] = "application/xml",
                        ["Content-Length"] = stat.size,
                        ["Access-Control-Allow-Origin"] = "*"
                    })
                    fs.createReadStream(configFile):pipe(res)
                else
                    local errorMsg = "Config file not found: " .. configFile
                    res:writeHead(404, {
                        ["Content-Type"] = "text/plain",
                        ["Content-Length"] = #errorMsg,
                        ["Access-Control-Allow-Origin"] = "*"
                    })
                    res:write(errorMsg)
                end
            end)
        else
            -- 官服代理模式：优先使用本地缓存 ServerOfficial.xml
            local cachedFile = proxy_root .. "/config/ServerOfficial.xml"
            
            fs.stat(cachedFile, function(cacheErr, cacheStat)
                if not cacheErr and cacheStat.type == "file" and cacheStat.size > 0 then
                    -- 使用本地缓存
                    print("\27[32m[CONFIG] 官服代理模式: 使用本地缓存 ServerOfficial.xml\27[0m")
                    res:writeHead(200, {
                        ["Content-Type"] = "application/xml",
                        ["Content-Length"] = cacheStat.size,
                        ["Access-Control-Allow-Origin"] = "*"
                    })
                    fs.createReadStream(cachedFile):pipe(res)
                else
                    -- 本地缓存不存在，从官服获取
                    print("\27[35m[CONFIG] 官服代理模式: 从官服获取 ServerR.xml\27[0m")
                    
                    local officialUrl = conf.res_official_address:gsub("/$", "") .. "/config/ServerR.xml"
                    local protocol = officialUrl:match("^https://") and https or http
                    
                    protocol.request(officialUrl, function(officialRes)
                        local officialData = ""
                        
                        officialRes:on('data', function(chunk)
                            officialData = officialData .. chunk
                        end)
                        
                        officialRes:on('end', function()
                            if officialRes.statusCode == 200 and #officialData > 0 then
                                print("\27[32m[CONFIG] ✓ 获取官服 ServerR.xml 成功\27[0m")
                                
                                -- 修改 ipConfig，让所有 Socket 连接走本地代理
                                local modifiedData = officialData
                                local proxyPort = tostring(conf.login_port)
                                
                                modifiedData = modifiedData:gsub('(<Email[^>]*ip=")[^"]*(")', '%1127.0.0.1%2')
                                modifiedData = modifiedData:gsub('(<DirSer[^>]*ip=")[^"]*(")', '%1127.0.0.1%2')
                                modifiedData = modifiedData:gsub('(<Visitor[^>]*ip=")[^"]*(")', '%1127.0.0.1%2')
                                modifiedData = modifiedData:gsub('(<SubServer[^>]*ip=")[^"]*(")', '%1127.0.0.1%2')
                                modifiedData = modifiedData:gsub('(<RegistSer[^>]*ip=")[^"]*(")', '%1127.0.0.1%2')
                                modifiedData = modifiedData:gsub('(<Email[^>]*port=")[^"]*(")', '%1' .. proxyPort .. '%2')
                                modifiedData = modifiedData:gsub('(<DirSer[^>]*port=")[^"]*(")', '%1' .. proxyPort .. '%2')
                                modifiedData = modifiedData:gsub('(<Visitor[^>]*port=")[^"]*(")', '%1' .. proxyPort .. '%2')
                                modifiedData = modifiedData:gsub('(<SubServer[^>]*port=")[^"]*(")', '%1' .. proxyPort .. '%2')
                                modifiedData = modifiedData:gsub('(<RegistSer[^>]*port=")[^"]*(")', '%1' .. proxyPort .. '%2')
                                
                                print("\27[35m[CONFIG] 已修改 ipConfig -> 127.0.0.1:" .. proxyPort .. "\27[0m")
                                
                                -- 确保 config 目录存在
                                local configDir = proxy_root .. "/config"
                                if not fs.existsSync(configDir) then
                                    pcall(function() fs.mkdirSync(configDir) end)
                                end
                                
                                -- 保存到本地缓存
                                local saveOk, saveErr = pcall(function()
                                    fs.writeFileSync(cachedFile, modifiedData)
                                end)
                                
                                if saveOk then
                                    print("\27[32m[CONFIG] ✓ 已缓存到 " .. cachedFile .. "\27[0m")
                                else
                                    print("\27[31m[CONFIG] 缓存保存失败: " .. tostring(saveErr) .. "\27[0m")
                                end
                                
                                res:writeHead(200, {
                                    ["Content-Type"] = "application/xml",
                                    ["Content-Length"] = #modifiedData,
                                    ["Access-Control-Allow-Origin"] = "*"
                                })
                                res:write(modifiedData)
                            else
                                local errorMsg = "Failed to fetch ServerR.xml from official (status=" .. tostring(officialRes.statusCode) .. ")"
                                print("\27[31m[CONFIG] " .. errorMsg .. "\27[0m")
                                res:writeHead(500, {
                                    ["Content-Type"] = "text/plain",
                                    ["Content-Length"] = #errorMsg,
                                    ["Access-Control-Allow-Origin"] = "*"
                                })
                                res:write(errorMsg)
                            end
                        end)
                    end):on('error', function(err)
                        local errorMsg = "Failed to fetch ServerR.xml: " .. tostring(err)
                        print("\27[31m[CONFIG] " .. errorMsg .. "\27[0m")
                        res:writeHead(500, {
                            ["Content-Type"] = "text/plain",
                            ["Content-Length"] = #errorMsg,
                            ["Access-Control-Allow-Origin"] = "*"
                        })
                        res:write(errorMsg)
                    end):done()
                end
            end)
        end
        return
    end
    
    -- ========== 处理 JavaScript 日志请求 ==========
    if dest == "/__log__" then
        local query = req.uri.query or ""
        local logType = query:match("type=([^&]+)") or "Unknown"
        local logUrl = query:match("url=([^&]+)") or ""
        logUrl = logUrl:gsub("%%3A", ":"):gsub("%%2F", "/"):gsub("%%3F", "?"):gsub("%%3D", "="):gsub("%%26", "&")
        
        -- 打印 JavaScript 网络日志
        if logType == "Fetch" then
            print(string.format("\27[36m[JS-Fetch] %s\27[0m", logUrl))
        elseif logType == "XHR" then
            print(string.format("\27[33m[JS-XHR] %s\27[0m", logUrl))
        elseif logType == "WebSocket" then
            print(string.format("\27[35m[JS-WebSocket] 连接: %s\27[0m", logUrl))
        elseif logType == "WebSocket-Open" then
            print(string.format("\27[32m[JS-WebSocket] 已连接: %s\27[0m", logUrl))
        end
        
        -- 返回空响应
        res:writeHead(204, {
            ["Access-Control-Allow-Origin"] = "*"
        })
        res:finish()
        return
    end
    
    -- 处理 OPTIONS 预检请求 (CORS preflight)
    if req.method == "OPTIONS" then
        res:writeHead(200, {
            ["Access-Control-Allow-Origin"] = "*",
            ["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS",
            ["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With",
            ["Access-Control-Max-Age"] = "86400",
            ["Content-Length"] = "0"
        })
        res:finish()
        return
    end
    
    -- SPA 路由支持：如果是 Vue Router 的路由，返回对应的 HTML 文件
    local spa_html = spa_routes[dest]
    if spa_html then
        dest = spa_html
    end
    
    -- 拦截外部资源请求（Flash 内部会请求这些）
    -- 在本地服务器模式下，重定向到本地文件
    if conf.local_server_mode then
    end
    
    -- 特殊处理 ip.txt 请求
    if dest:match("^/ip%.txt") or dest:match("^/ip$") then
        -- 本地服务器模式：返回本地登录服务器地址
        if conf.local_server_mode then
            local resp = "127.0.0.1:" .. conf.login_port
            res:writeHead(200, {
                ["Content-Type"] = "text/plain",
                ["Content-Length"] = #resp,
                ["Access-Control-Allow-Origin"] = "*"
            })
            res:write(resp)
            print("\27[32m[Local Mode] ✓ 返回本地登录服务器地址: " .. resp .. "\27[0m")
            return
        end
        
        -- 官服代理模式：返回本地代理地址（会转发到官服）
        if not conf.pure_official_mode then
            local resp = conf.login_server_address  -- 127.0.0.1:1863
            res:writeHead(200, {
                ["Content-Type"] = "text/plain",
                ["Content-Length"] = #resp,
                ["Access-Control-Allow-Origin"] = "*"
            })
            res:write(resp)
            print("\27[35m[官服代理模式] ✓ 返回本地代理地址: " .. resp .. " (转发到 " .. conf.official_login_server .. ":" .. conf.official_login_port .. ")\27[0m")
            
            -- 异步获取官服ip.txt作为参考
            if conf.use_official_resources then
                print("\27[36m[官服代理模式] 获取官服 ip.txt 作为参考...\27[0m")
                local officialUrl = "https://seerlogin.61.com/ip.txt"
                
                https.request(officialUrl, function(officialRes)
                    local officialData = ""
                    
                    officialRes:on('data', function(chunk)
                        officialData = officialData .. chunk
                    end)
                    
                    officialRes:on('end', function()
                        if officialRes.statusCode == 200 and #officialData > 0 then
                            print("\27[36m[官服代理模式] 官服 ip.txt: " .. officialData .. "\27[0m")
                            
                            -- 保存官服的ip.txt到本地（作为参考）
                            local ipFilePath = root .. "/ip.txt.official"
                            pcall(function()
                                fs.writeFileSync(ipFilePath, officialData)
                            end)
                        end
                    end)
                end):on('error', function(err)
                    print("\27[31m[官服代理模式] 获取官服 ip.txt 失败: " .. tostring(err) .. "\27[0m")
                end):done()
            end
            return
        end
        
        -- 如果开启了完全官服模式，返回官服的ip.txt
        if conf.use_official_resources and conf.pure_official_mode then
            print("\27[33m[Pure Official Mode] Fetching and returning official ip.txt\27[0m")
            
            -- 使用游戏资源服务器的 ip.txt（返回多个服务器地址）
            local officialUrl = conf.res_official_address .. "/ip.txt"
            
            http.request(officialUrl, function(officialRes)
                local officialData = ""
                
                officialRes:on('data', function(chunk)
                    officialData = officialData .. chunk
                end)
                
                officialRes:on('end', function()
                    if officialRes.statusCode == 200 and #officialData > 0 then
                        -- 官服可能返回多个服务器地址，用 | 分隔
                        -- Flash 只能处理单个地址，所以取第一个
                        local firstServer = officialData:match("^([^|]+)")
                        if firstServer then
                            officialData = firstServer
                        end
                        
                        print("\27[32m[Pure Official Mode] Got ip.txt from official: "..officialData.."\27[0m")
                        
                        -- 保存官服的ip.txt到本地
                        local ipFilePath = root .. "/ip.txt.official"
                        local success, err = pcall(function()
                            fs.writeFileSync(ipFilePath, officialData)
                        end)
                        
                        if success then
                            print("\27[32m[Pure Official Mode] Saved official ip.txt to: "..ipFilePath.."\27[0m")
                        end
                        
                        -- 返回官服的ip.txt内容（让Flash连接到官服）
                        res:writeHead(200, {
                            ["Content-Type"] = "text/plain",
                            ["Content-Length"] = #officialData,
                            ["Access-Control-Allow-Origin"] = "*"
                        })
                        res:write(officialData)
                        print("\27[33m[Pure Official Mode] Returned official server ip: "..officialData.."\27[0m")
                    else
                        print("\27[31m[Pure Official Mode] Failed to fetch ip.txt, using local config\27[0m")
                        -- 失败时使用本地配置
                        local resp = conf.login_server_address
                        res:writeHead(200, {
                            ["Content-Type"] = "text/plain",
                            ["Content-Length"] = #resp
                        })
                        res:write(resp)
                    end
                end)
            end):on('error', function(err)
                print("\27[31m[Pure Official Mode] Error fetching official ip.txt: "..tostring(err).."\27[0m")
                -- 出错时使用本地配置
                local resp = conf.login_server_address
                res:writeHead(200, {
                    ["Content-Type"] = "text/plain",
                    ["Content-Length"] = #resp
                })
                res:write(resp)
            end):done()
            return
        end
        
        -- 返回本地配置的登录服务器地址（兜底）
        local resp = conf.login_server_address
        res:writeHead(200, {
            ["Content-Type"] = "text/plain",
            ["Content-Length"] = #resp,
            ["Access-Control-Allow-Origin"] = "*"
        })
        res:write(resp)
        print("\27[32mReturned login server ip: "..resp.."\27[0m")
        return
    end
    
    local path,code = resolvePathByProxyRules(dest)
    
    print(string.format("\27[90m[DEBUG] dest=%s, path=%s, code=%d\27[0m", dest, path, code))
    if code == 301 then
        -- TODO: REDIRECT
    elseif code == 404 then
        res:writeHead(404, {
            ["Content-Type"] = "text/plain",
            ["Content-Length"] = #INVISIBLE_REASON
        })
        res:write(INVISIBLE_REASON)
        return
    else
        -- 检查文件是否在 proxy 目录下
        local isProxyFile = path:match("^%.%./gameres_proxy/")
        
        fs.stat(path, function (err, stat)
            -- Proxy 目录的文件：直接使用
            if isProxyFile then
                if not err and stat.type == "file" then
                    Logger.logResource("GET", dest, 200, stat.size)
                    
                    -- 如果是 SWF 文件，在控制台显示
                    if dest:lower():match("%.swf$") then
                        print(string.format("\27[36m[SWF加载] %s (%d bytes)\27[0m", dest, stat.size))
                    end
                    
                    res:writeHead(200, {
                        ["Content-Type"] = getType(path),
                        ["Content-Length"] = stat.size,
                        ["Access-Control-Allow-Origin"] = "*",
                        ["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS",
                        ["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With",
                        ["Permissions-Policy"] = "unload=()"
                    })
                    fs.createReadStream(path):pipe(res)
                else
                    local errorMsg = "File not found in proxy directory: " .. dest
                    res:writeHead(404, {
                        ["Content-Type"] = "text/plain",
                        ["Content-Length"] = #errorMsg,
                        ["Access-Control-Allow-Origin"] = "*"
                    })
                    res:write(errorMsg)
                end
                return
            end
            
            -- 非 Proxy 目录的文件：按照 use_official_resources 模式处理
            local forceOfficialFetch = conf.pure_official_mode and (dest == "/config/ServerR.xml" or dest == "/config/Server.xml")
            
            if forceOfficialFetch then
                return res:notFound(req.uri.pathname, "Force fetch from official\n")
            end
            
            -- 如果开启了官方资源模式，但本地文件已存在且有效，则使用本地文件（静默模式，不打印日志）
            if conf.use_official_resources and not err and stat.type == "file" and stat.size > 0 then
                Logger.logResource("GET", dest, 200, stat.size)
                
                -- 如果是 SWF 文件，在控制台显示
                if dest:lower():match("%.swf$") then
                    print(string.format("\27[36m[SWF加载] %s (%d bytes)\27[0m", dest, stat.size))
                end
                
                res:writeHead(200, {
                    ["Content-Type"] = getType(path),
                    ["Content-Length"] = stat.size,
                    ["Access-Control-Allow-Origin"] = "*",
                    ["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS",
                    ["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With"
                })
                fs.createReadStream(path):pipe(res)
                return
            end
            
            -- 如果开启了官方资源模式且本地文件不存在或无效，从官服获取
            if conf.use_official_resources and (err or stat.type ~= "file" or stat.size == 0) then
                return res:notFound(req.uri.pathname, "Force fetch from official\n")
            end
            
            if err then
                if err.code == "ENOENT" then
                    return res:notFound(req.uri.pathname,err.message .. "\n")
                end
                if err:sub(1,6) == "ENOENT" then
                    return res:notFound(req.uri.pathname,err .. "\n")
                end
                p(err)
                return res:error((err.message or tostring(err)) .. "\n")
            end
            if stat.type ~= "file" then
                return res:notFound(req.uri.pathname,"Requested url is not a file\n")
            end
    
            res:writeHead(200, {
                ["Content-Type"] = getType(path),
                ["Content-Length"] = stat.size,
                ["Access-Control-Allow-Origin"] = "*",
                ["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS",
                ["Access-Control-Allow-Headers"] = "*"
            })
    
            Logger.logResource("GET", dest, 200, stat.size)
            
            -- 如果是 SWF 文件，在控制台显示
            if dest:lower():match("%.swf$") then
                print(string.format("\27[36m[SWF加载] %s (%d bytes)\27[0m", dest, stat.size))
            end
            
            fs.createReadStream(path):pipe(res)
        end)
    end
end)

resServer:on('error', function(err)
    print("\27[31m[RES-SERVER] Error: " .. tostring(err) .. "\27[0m")
end)

resServer:listen(conf.ressrv_port, "0.0.0.0", function()
    print("\27[32m[RES-SERVER] ✓ Successfully listening on port " .. conf.ressrv_port .. "\27[0m")
end)

-- 尝试监听 80 端口（用于 www.51seer.com 的请求）
-- 需要管理员权限运行
if conf.ressrv_port_80 then
    local resServer80 = http.createServer(function(req, res)
        -- 复用主服务器的处理逻辑
        resServer:emit('request', req, res)
    end)
    
    resServer80:on('error', function(err)
        print("\27[33m[RES-SERVER-80] Warning: Cannot listen on port 80 - " .. tostring(err) .. "\27[0m")
        print("\27[33m[RES-SERVER-80] Run as Administrator to enable www.51seer.com support\27[0m")
    end)
    
    resServer80:listen(conf.ressrv_port_80, "0.0.0.0", function()
        print("\27[32m[RES-SERVER-80] ✓ Successfully listening on port 80 (for www.51seer.com)\27[0m")
    end)
end

print("\27[36mResource server started on \27[1mhttp://127.0.0.1:"..conf.ressrv_port.."/\27[0m")

if conf.local_server_mode then
    print("\27[32m✓ LOCAL SERVER MODE: Using local game server\27[0m")
    print("\27[32m  - Login server: 127.0.0.1:"..conf.login_port.."\27[0m")
    print("\27[32m  - No connection to official servers\27[0m")
    if conf.use_official_resources then
        print("\27[33m  - Resources fetched from: "..conf.res_official_address.."\27[0m")
    else
        print("\27[32m  - Resources from: "..conf.res_dir.."\27[0m")
    end
elseif conf.use_official_resources then
    if conf.pure_official_mode then
        print("\27[33m⚠ Pure Official Mode: Playing exactly like on official website\27[0m")
        print("\27[33m  - All resources fetched from: "..conf.res_official_address.."\27[0m")
        print("\27[33m  - Connecting to official servers (no local proxy)\27[0m")
        print("\27[33m  - Resources will be saved to: "..conf.res_dir.."\27[0m")
    else
        print("\27[33m⚠ Official Resources Mode: Downloading resources from official server\27[0m")
        print("\27[33m  - Resources fetched from: "..conf.res_official_address.."\27[0m")
        print("\27[33m  - Connecting to local proxy servers (traffic logging enabled)\27[0m")
        print("\27[33m  - Resources will be saved to: "..conf.res_dir.."\27[0m")
    end
else
    print("\27[32m✓ Local Resources Mode: Using cached resources\27[0m")
    print("\27[32m  - Resources from: "..conf.res_dir.."\27[0m")
    print("\27[32m  - Connecting to local proxy servers\27[0m")
end