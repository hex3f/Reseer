-- 资源服务器启动脚本
-- 提供 HTTP 资源服务（网页入口）

-- 初始化日志系统
local Logger = require("./logger")
Logger.init()

print("\27[36m╔════════════════════════════════════════════════════════════╗\27[0m")
print("\27[36m║              资源服务器 - Resource Server                  ║\27[0m")
print("\27[36m╚════════════════════════════════════════════════════════════╝\27[0m")
print("")

-- 加载配置
local conf = {
    res_dir = "../gameres/root",
    res_proxy_dir = "../gameres_proxy/root",
    res_official_address = "http://127.0.0.1:9990",
    ressrv_port = 32400,
    ressrv_port_80 = 80,
    use_official_resources = true,
    pure_official_mode = false,
    
    -- 本地服务器模式配置
    local_server_mode = true,
    login_port = 1863,
    login_server_address = "127.0.0.1:1863",
    
    -- 官服配置（代理模式用）
    official_login_server = "115.238.192.7",
    official_login_port = 9999,
}
_G.conf = conf

print("\27[33m========== 资源服务器配置 ==========\27[0m")
print("📦 本地资源目录: " .. conf.res_proxy_dir)
print("🌐 官服资源地址: " .. conf.res_official_address)
print("🔌 主端口: " .. conf.ressrv_port)
print("🔌 备用端口: " .. conf.ressrv_port_80)
print("")

-- 加载 buffer 扩展
require "./buffer_extension"

-- 启动资源服务器
require "./ressrv"

-- 定时器保持进程活跃
local timer = require("timer")
timer.setInterval(1000 * 60, function() end)

print("\27[32m========== 资源服务器已启动 ==========\27[0m")
print("")
print("\27[36m访问地址: http://127.0.0.1:" .. conf.ressrv_port .. "/\27[0m")
print("")
