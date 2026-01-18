-- 登录IP服务器启动脚本
-- 提供 ip.txt 文件服务

-- 初始化日志系统
local Logger = require("./logger")
Logger.init()

print("\27[36m╔════════════════════════════════════════════════════════════╗\27[0m")
print("\27[36m║            登录IP服务器 - Login IP Server                  ║\27[0m")
print("\27[36m╚════════════════════════════════════════════════════════════╝\27[0m")
print("")

-- 加载配置
local conf = {
    loginip_port = 32401,
    login_server_address = "127.0.0.1:1863",
    login_port = 1863,
    local_server_mode = true,
    
    -- 官服配置（代理模式用）
    official_login_server = "115.238.192.7",
    official_login_port = 9999,
}
_G.conf = conf

print("\27[33m========== 登录IP服务器配置 ==========\27[0m")
print("🔌 端口: " .. conf.loginip_port)
print("🎯 登录服务器地址: " .. conf.login_server_address)
print("")

-- 启动登录IP服务器
require "./loginip"

-- 定时器保持进程活跃
local timer = require("timer")
timer.setInterval(1000 * 60, function() end)

print("\27[32m========== 登录IP服务器已启动 ==========\27[0m")
print("")
print("\27[36mip.txt 地址: http://127.0.0.1:" .. conf.loginip_port .. "/ip.txt\27[0m")
print("")
