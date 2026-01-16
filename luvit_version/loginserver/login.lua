-- Login Server

local net = require "net"
local lpp = require "./loginpktprocess"
local ce
local ccc
if conf.passthru then
    ce = net.createConnection(1863, '123.206.131.236', function (err)
    if err then error(err) end

    print("Connected to official login server")

    -- Send the server's response to stdout
    ce:on("data",function(data) -- or 'client:pipe(process.stdout)'
        ccc:write(data)
        --p("srv->cli",data)
    end)

    end)
end
local policy_file = "\
<?xml version=\"1.0\"?><!DOCTYPE cross-domain-policy><cross-domain-policy>\
<allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>\000\
"

-- 策略文件服务器 (端口 843)
local policyServer = net.createServer(function(client)
    print("\27[35m[POLICY:843] 策略文件请求\27[0m")
    client:write(policy_file)
    client:destroy()
end)

policyServer:on('error', function(err)
    -- 端口 843 可能需要管理员权限，忽略错误
    print("\27[33m[POLICY:843] 无法启动策略文件服务器 (可能需要管理员权限): " .. tostring(err) .. "\27[0m")
end)

pcall(function()
    policyServer:listen(843)
    print("\27[35m[POLICY] 策略文件服务器启动在端口 843\27[0m")
end)

local server = net.createServer(function(client)
    local addr = client:address()
    print(string.format("\27[32m[LOGIN] 新客户端连接: %s\27[0m", addr and addr.ip or "unknown"))
    
    -- Add some listenners for incoming connection
    client:on("error",function(err)
        print("\27[31m[LOGIN] Client read error: " .. err .. "\27[0m")
        client:close()
    end)
    
    client:on("end", function()
        print("\27[33m[LOGIN] 客户端断开连接\27[0m")
    end)
    
    client:on("close", function()
        print("\27[33m[LOGIN] 连接关闭\27[0m")
    end)
    local buffer = ""
    local expecting = 1
    client:on("data",function(data)
        print(string.format("\27[36m[LOGIN] 收到数据: %d bytes\27[0m", #data))
        --p("cli->srv",data)
        if data == "<policy-file-request/>\000" then
            print("\27[36m[LOGIN] Flash 策略文件请求\27[0m")
            client:write(policy_file)
            return
        end
        if conf.passthru then
            ce:write(data)
        else
            buffer = buffer .. data
            while #buffer >= expecting do
                expecting = lpp.preparse(buffer)
                if #buffer >= expecting then
                    local packet = buffer:sub(1,expecting)
                    lpp.parse(packet,client)
                    buffer = buffer:sub(expecting+1,-1)
                end
                expecting = 1
            end
        end
    end)
    --[[
    client:on("end",function()
        print("Login server client disconnected")
    end)
    ]]
    ccc = client
end)

-- Add error listenner for server
server:on('error',function(err)
    if err then error(err) end
end)

server:listen(conf.login_port)

print("\27[36mLogin server started on \27[1mtcp://localhost:"..conf.login_port.."/\27[0m")