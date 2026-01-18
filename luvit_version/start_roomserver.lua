-- 房间服务器 (Room Server)
-- 负责：家园系统、家具系统、房间功能

-- 初始化日志系统
local Logger = require("./logger")
Logger.init()

print("\27[36m╔════════════════════════════════════════════════════════════╗\27[0m")
print("\27[36m║                房间服务器 - Room Server                    ║\27[0m")
print("\27[36m╚════════════════════════════════════════════════════════════╝\27[0m")
print("")

-- 加载配置
local conf = _G.conf or {
    roomserver_port = 5100,
    dataserver_url = "http://127.0.0.1:5200",  -- 数据服务器地址
    local_server_mode = true,
    hide_frequent_cmds = true,
    hide_cmd_list = {80008},
}
_G.conf = conf

-- 加载 buffer 扩展（必须在其他模块之前）
require "./buffer_extension"

-- 创建数据客户端（微服务模式）
print("\27[36m[房间服务器] 连接数据服务器: " .. conf.dataserver_url .. "\27[0m")
local DataClient = require "./data_client"
local dataClient = DataClient:new(conf.dataserver_url)

-- 创建独立的会话管理器和用户数据库
print("\27[36m[房间服务器] 初始化会话管理器...\27[0m")
local SessionManager = require "./session_manager"
local sessionManager = SessionManager:new()

print("\27[36m[房间服务器] 初始化用户数据库...\27[0m")
local UserDB = require "./userdb"
local userdb = UserDB

-- 启动房间服务器
print("\27[36m[房间服务器] 启动房间服务器...\27[0m")
local lrs = require "./roomserver/localroomserver"
local roomServer = lrs.LocalRoomServer:new(userdb, nil, sessionManager, dataClient)

-- 导出到全局
_G.roomServer = roomServer
_G.sessionManager = sessionManager
_G.userdb = userdb
_G.dataClient = dataClient

-- 定时保存数据
local timer = require('timer')
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
            end
        end)
    end
end)

-- 关闭时保存数据
local function saveAllData()
    print("\27[33m[房间服务器] 正在保存数据...\27[0m")
    local db = userdb:new()
    db:save()
    print("\27[32m[房间服务器] ✓ 数据已保存\27[0m")
end

pcall(function()
    process:on("SIGINT", function()
        print("\n\27[33m[房间服务器] 收到退出信号...\27[0m")
        saveAllData()
        os.exit(0)
    end)
end)

print("\27[32m[房间服务器] ========== 服务器就绪 ==========\27[0m")
print(string.format("\27[36m[房间服务器] 监听端口: %d\27[0m", conf.roomserver_port))
print("")
