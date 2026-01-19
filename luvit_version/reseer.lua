-- RecSeer Main (Seer Private Server)
-- 改自 RecMole (摩尔庄园私服)

-- 初始化日志系统
local Logger = require("./logger")
Logger.init()

print("\27[36m╔════════════════════════════════════════════════════════════╗\27[0m")
print("\27[36m║           赛尔号本地服务器 - RecSeer v2.0                 ║\27[0m")
print("\27[36m╚════════════════════════════════════════════════════════════╝\27[0m")
print("")

local conf = {
    -- ============================================================
    -- 目录配置
    -- ============================================================
    res_dir = "../gameres/root",           -- 资源缓存目录（从官服下载的资源保存位置）
    res_proxy_dir = "../gameres_proxy/root", -- 本地代理资源目录（优先使用）
    
    -- ============================================================
    -- 官服地址配置
    -- ============================================================
    -- 资源服务器地址（官服代理模式下使用）
    -- luvit 的 HTTPS 有 SSL 问题，需要通过 nieo 微端代理
    -- 先启动 nieo 微端，它会在 9990 端口提供资源代理
    res_official_address = "http://127.0.0.1:9990",  -- 通过 nieo 微端代理（需要先启动微端）
    official_api_server = "http://115.238.192.7:9999",     -- 官服 API 服务器
    official_login_server = "115.238.192.7",               -- 官服登录服务器 IP（从ip.txt获取）
    official_login_port = 9999,                            -- 官服登录服务器端口（TCP Socket）
    
    -- ============================================================
    -- 本地服务器端口配置
    -- ============================================================
    ressrv_port = 32400,      -- 主资源服务器端口（访问 http://127.0.0.1:32400）
    ressrv_port_80 = 80,      -- 备用资源服务器端口（用于 www.51seer.com 域名）
    loginip_port = 32401,     -- ip.txt 服务端口
    login_port = 1863,        -- 本地登录代理端口（WebSocket）
    gameserver_port = 5000,   -- 本地游戏服务器端口（已包含家园系统）
    
    -- 返回给 Flash 的登录服务器地址（本地代理）
    login_server_address = "127.0.0.1:1863",
    
    -- ============================================================
    -- 运行模式配置
    -- ============================================================
    
    -- [核心开关] 本地模式 vs 官服代理模式
    -- true  = 本地模式：使用本地数据库，不连接官服（开发/测试用）
    -- false = 官服代理模式：所有请求转发到官服，记录流量（抓包分析用）
    local_server_mode = true,
    
    -- [资源模式] 是否从官服下载资源
    -- true  = 从官服下载资源并缓存到 res_dir
    -- false = 仅使用本地资源（需要提前准备好资源文件）
    use_official_resources = true,
    
    -- [流量记录] 是否启用流量记录（仅在官服代理模式下有效）
    -- true  = 记录所有 Flash ↔ 官服 的通信到控制台和文件
    -- false = 不记录流量（使用简单代理）
    trafficlogger = true,
    
    -- [游戏服务器代理] 是否代理游戏服务器连接
    -- true  = 拦截服务器列表，将游戏服务器 IP 替换为本地代理
    -- false = 不修改服务器列表，直接连接官服游戏服务器
    proxy_game_server = true,
    
    -- [纯官服模式] 完全使用官服资源，不做任何修改
    -- true  = 所有资源直接从官服获取，包括 ServerR.xml 和 ip.txt
    -- false = 使用本地代理的配置文件
    pure_official_mode = false,
    
    -- ============================================================
    -- 日志过滤配置
    -- ============================================================
    
    -- [隐藏杂包] 是否隐藏频繁的杂包日志
    -- true  = 隐藏 hide_cmd_list 中的命令日志
    -- false = 显示所有命令日志
    hide_frequent_cmds = true,
    
    -- [隐藏命令列表] 要隐藏的命令ID列表
    hide_cmd_list = {
		80008, --心跳包
    },
}
_G.conf = conf

-- 打印配置信息
print("\27[33m========== 运行模式 ==========\27[0m")
if conf.local_server_mode then
    print("🎮 模式: 本地服务器模式")
    print("📦 资源: " .. (conf.use_official_resources and "从官服下载并缓存" or "仅使用本地资源"))
else
    print("🎮 模式: 官服代理模式 (流量记录" .. (conf.trafficlogger and "已启用" or "已禁用") .. ")")
    print("📦 资源: " .. (conf.use_official_resources and "从官服下载并缓存" or "仅使用本地资源"))
    print("🔄 游戏服务器代理: " .. (conf.proxy_game_server and "已启用" or "已禁用"))
end
print("")

-- 生成前端配置文件
local function generateFrontendConfig()
    local fs = require('fs')
    local json = require('json')
    
    -- 生成 server-config.js
    local config = {
        local_server_mode = conf.local_server_mode,
        use_official_resources = conf.use_official_resources,
        server_info = {
            login_server = "127.0.0.1:" .. conf.login_port,
            game_server = "127.0.0.1:" .. conf.gameserver_port,
            resource_server = "http://127.0.0.1:" .. conf.ressrv_port
        }
    }
    
    local configJs = string.format([[
// 自动生成 - %s
window.SEER_SERVER_CONFIG = %s;
]], os.date("%Y-%m-%d %H:%M:%S"), json.stringify(config))
    
    local configPath = conf.res_proxy_dir .. "/js/server-config.js"
    fs.writeFileSync(configPath, configJs)
    print("\27[36m[CONFIG] 已生成: " .. configPath .. "\27[0m")
end

generateFrontendConfig()

require "./buffer_extension"
require "./ressrv"
require "./loginip"
require "./oauthserver"
require "./apiserver"  -- API 服务器（提供配置管理和模式切换）

-- ============================================================
-- 数据预加载（在服务器启动前加载所有数据文件）
-- ============================================================
print("\27[36m========== 数据预加载 ==========\27[0m")

local dataLoadSuccess = true

-- 1. 加载精灵数据
print("\27[36m[数据加载] 正在加载精灵数据...\27[0m")
local Pets = require("./seer_pets")
Pets.load()

-- 统计加载的精灵数量
local petCount = 0
for _ in pairs(Pets.pets) do
    petCount = petCount + 1
end

if not Pets.loaded or petCount == 0 then
    print("\27[31m[错误] 精灵数据加载失败！\27[0m")
    print("\27[33m[提示] 请检查 data/spt.xml 文件是否存在且格式正确\27[0m")
    print("\27[33m[提示] 服务器将使用默认精灵数据运行\27[0m")
    dataLoadSuccess = false
else
    print(string.format("\27[32m[数据加载] ✓ 精灵数据加载成功 (%d 个精灵)\27[0m", petCount))
end

-- 2. 加载物品数据
print("\27[36m[数据加载] 正在加载物品数据...\27[0m")
local Items = require("./seer_items")
Items.load()
if not Items.loaded then
    print("\27[31m[错误] 物品数据加载失败！\27[0m")
    print("\27[33m[提示] 请检查 data/items.xml 文件是否存在\27[0m")
    dataLoadSuccess = false
else
    print(string.format("\27[32m[数据加载] ✓ 物品数据加载成功 (%d 个物品)\27[0m", Items.count))
end

-- 3. 加载技能数据
print("\27[36m[数据加载] 正在加载技能数据...\27[0m")
local Skills = require("./seer_skills")
Skills.load()
if not Skills.loaded then
    print("\27[31m[错误] 技能数据加载失败！\27[0m")
    print("\27[33m[提示] 请检查 data/skill.xml 文件是否存在\27[0m")
    dataLoadSuccess = false
else
    local skillCount = 0
    for _ in pairs(Skills.skills) do
        skillCount = skillCount + 1
    end
    print(string.format("\27[32m[数据加载] ✓ 技能数据加载成功 (%d 个技能)\27[0m", skillCount))
end

-- 4. 加载技能效果数据
print("\27[36m[数据加载] 正在加载技能效果数据...\27[0m")
local SkillEffects = require("./seer_skill_effects")
SkillEffects.load()
if not SkillEffects.loaded then
    print("\27[31m[错误] 技能效果数据加载失败！\27[0m")
    print("\27[33m[提示] 请检查 data/skill_effects.xml 文件是否存在\27[0m")
    dataLoadSuccess = false
else
    print(string.format("\27[32m[数据加载] ✓ 技能效果数据加载成功 (%d 个效果)\27[0m", SkillEffects.count))
end

-- 检查数据加载状态
if not dataLoadSuccess then
    print("")
    print("\27[31m╔════════════════════════════════════════════════════════════╗\27[0m")
    print("\27[31m║  ⚠️  警告：部分数据文件加载失败！                          ║\27[0m")
    print("\27[31m║  服务器将使用默认数据运行，可能导致功能异常               ║\27[0m")
    print("\27[31m║  建议：检查 data/ 目录下的 XML 文件是否完整               ║\27[0m")
    print("\27[31m╚════════════════════════════════════════════════════════════╝\27[0m")
    print("")
else
    print("\27[32m[数据加载] ✓ 所有数据加载完成\27[0m")
end
print("")

-- 根据模式选择登录服务器
if conf.local_server_mode then
    -- 本地模式：使用 TCP 登录服务器（Flash Socket 连接）
    print("\27[33m========== LOCAL SERVER MODE (TCP Socket) ==========\27[0m")
    
    -- 创建会话管理器（统一状态管理）
    print("\27[36m[初始化] 创建会话管理器...\27[0m")
    local SessionManager = require "./session_manager"
    local sessionManager = SessionManager:new()
    
    -- 启动游戏服务器（已包含家园系统）
    local lgs = require "./gameserver/localgameserver"
    local gameServer = lgs.LocalGameServer:new(nil, sessionManager)
    
    -- 启动登录服务器
    require "./loginserver/login"
    
    -- 添加定时清理任务
    local timer = require('timer')
    
    -- 每 5 分钟清理离线用户
    timer.setInterval(5 * 60 * 1000, function()
        sessionManager:cleanupOfflineUsers(300)  -- 5 分钟未心跳
    end)
    
    -- 每 1 小时清理过期会话
    timer.setInterval(60 * 60 * 1000, function()
        sessionManager:cleanupExpiredSessions(3600)  -- 1 小时未活跃
    end)
    
    -- 每 10 分钟打印统计信息
    timer.setInterval(10 * 60 * 1000, function()
        sessionManager:printStats()
    end)
    
    print("\27[32m[初始化] ✓ 会话管理器已启动\27[0m")
else
    -- 官服模式：使用流量记录代理
    print("\27[35m╔════════════════════════════════════════════════════════════╗\27[0m")
    print("\27[35m║           官服代理模式 - 所有请求将被记录                  ║\27[0m")
    print("\27[35m╠════════════════════════════════════════════════════════════╣\27[0m")
    print("\27[35m║  📡 登录服务器: " .. (conf.official_login_server or "101.43.19.60") .. ":" .. (conf.official_login_port or 1863) .. "                    ║\27[0m")
    print("\27[35m║  🎮 游戏服务器: 动态分配（根据服务器列表）                 ║\27[0m")
    print("\27[35m║  📝 流量记录: " .. (conf.trafficlogger and "已启用" or "已禁用") .. "                                       ║\27[0m")
    print("\27[35m╚════════════════════════════════════════════════════════════╝\27[0m")
    print("")
    print("\27[36m[提示] 所有 Flash ↔ 官服 的通信都会在控制台显示\27[0m")
    print("\27[36m[提示] 日志格式: [Flash→官服] 发送 / [官服→Flash] 接收\27[0m")
    print("")
    
    -- 启动游戏服务器代理
    local gs = conf.trafficlogger and require "./gameserver/trafficlogger" or require "./gameserver/gameserver"
    gs.GameServer:new()
    
    -- 启动房间代理服务器（用于官服房间转发）
    print("\27[36m[官服代理] 启动房间代理服务器 (端口 5100)...\27[0m")
    local ok, result = pcall(function()
        local RoomProxy = require "./room_proxy"
        return RoomProxy:new(5100)
    end)
    if ok then
        _G.roomProxy = result
        print("\27[32m[官服代理] ✓ 房间代理服务器已启动\27[0m")
    else
        print("\27[31m[官服代理] ✗ 房间代理服务器启动失败: " .. tostring(result) .. "\27[0m")
    end
    
    -- 启动登录服务器代理
    local _ = conf.trafficlogger and require "./loginserver/trafficloggerlogin" or require "./loginserver/login"
end

-- 定时器保持进程活跃
local timer = require("timer")
timer.setInterval(1000 * 60, function() end)

-- 监听标准输入，按 Enter 键打印分割线
-- 使用 pcall 防止在某些环境下 stdin 不可用
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

-- ============================================================
-- 关闭时保存数据
-- ============================================================
local function saveAllData()
    -- 只在本地模式下保存数据
    if not conf.local_server_mode then
        print("\27[36m[SHUTDOWN] 官服模式：跳过数据保存\27[0m")
        return
    end
    
    print("\27[33m[SHUTDOWN] 正在保存所有用户数据...\27[0m")
    local success, UserDB = pcall(require, "./userdb")
    if success then
        local db = UserDB:new(conf)
        db:save()
        print("\27[32m[SHUTDOWN] ✓ 用户数据已保存\27[0m")
    else
        print("\27[31m[SHUTDOWN] 保存用户数据失败: " .. tostring(UserDB) .. "\27[0m")
    end
-- Windows 兼容的 Ctrl+C 处理
-- 在 Windows 上，使用定时器定期保存数据 (仅本地模式)
if package.config:sub(1,1) == '\\' and conf.local_server_mode then
    -- Windows 系统
    print("\27[33m[INFO] Windows 系统检测到，启用自动保存 (每30秒)\27[0m")
    local timer = require('timer')
    timer.setInterval(30000, function()
        saveAllData()
    end)
end

-- 监听进程退出信号 (仅 Unix/Linux 支持，Windows 会静默失败)
pcall(function()
    process:on("SIGINT", function()
        print("\n\27[33m[SHUTDOWN] 收到 SIGINT 信号 (Ctrl+C)，正在关闭...\27[0m")
        saveAllData()
        os.exit(0)
    end)
end)

pcall(function()
    process:on("SIGTERM", function()
        print("\n\27[33m[SHUTDOWN] 收到 SIGTERM 信号，正在关闭...\27[0m")
        saveAllData()
        os.exit(0)
    end)
end)

-- 全局错误捕获
process:on("uncaughtException", function(err)
    print("\27[31m[CRITICAL] Uncaught Exception: " .. tostring(err) .. "\27[0m")
    print(debug.traceback())
    saveAllData()  -- 出错时也尝试保存数据
end)

print("\27[32m========== SERVER READY ==========\27[0m")
print("")
print("\27[36m访问地址: http://127.0.0.1:" .. conf.ressrv_port .. "/\27[0m")
print("\27[36m当前模式: " .. (conf.local_server_mode and "本地服务器" or "官服代理") .. "\27[0m")
if conf.local_server_mode then
    print("\27[36m游戏服务器: 127.0.0.1:" .. conf.gameserver_port .. " (含家园系统)\27[0m")
end
print("")
