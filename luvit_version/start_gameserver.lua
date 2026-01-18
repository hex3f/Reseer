-- 游戏服务器 (Game Server)
-- 负责：游戏逻辑、地图系统、战斗系统

-- 初始化日志系统
local Logger = require("./logger")
Logger.init()

print("\27[36m╔════════════════════════════════════════════════════════════╗\27[0m")
print("\27[36m║                游戏服务器 - Game Server                    ║\27[0m")
print("\27[36m╚════════════════════════════════════════════════════════════╝\27[0m")
print("")

-- 加载配置
local conf = _G.conf or {
    gameserver_port = 5000,
    dataserver_url = "http://127.0.0.1:5200",  -- 数据服务器地址
    local_server_mode = true,
    hide_frequent_cmds = true,
    hide_cmd_list = {80008},
}
_G.conf = conf

-- 加载 buffer 扩展（必须在其他模块之前）
require "./buffer_extension"

-- 创建数据客户端（微服务模式）
print("\27[36m[游戏服务器] 连接数据服务器: " .. conf.dataserver_url .. "\27[0m")
local DataClient = require "./data_client"
local dataClient = DataClient:new(conf.dataserver_url)

-- 数据预加载
print("\27[36m[游戏服务器] ========== 数据预加载 ==========\27[0m")

-- 1. 加载精灵数据
print("\27[36m[游戏服务器] 正在加载精灵数据...\27[0m")
local Pets = require("./seer_pets")
Pets.load()
local petCount = 0
for _ in pairs(Pets.pets) do petCount = petCount + 1 end
print(string.format("\27[32m[游戏服务器] ✓ 精灵数据加载成功 (%d 个精灵)\27[0m", petCount))

-- 2. 加载物品数据
print("\27[36m[游戏服务器] 正在加载物品数据...\27[0m")
local Items = require("./seer_items")
Items.load()
print(string.format("\27[32m[游戏服务器] ✓ 物品数据加载成功 (%d 个物品)\27[0m", Items.count))

-- 3. 加载技能数据
print("\27[36m[游戏服务器] 正在加载技能数据...\27[0m")
local Skills = require("./seer_skills")
Skills.load()
local skillCount = 0
for _ in pairs(Skills.skills) do skillCount = skillCount + 1 end
print(string.format("\27[32m[游戏服务器] ✓ 技能数据加载成功 (%d 个技能)\27[0m", skillCount))

-- 4. 加载技能效果数据
print("\27[36m[游戏服务器] 正在加载技能效果数据...\27[0m")
local SkillEffects = require("./seer_skill_effects")
SkillEffects.load()
print(string.format("\27[32m[游戏服务器] ✓ 技能效果数据加载成功 (%d 个效果)\27[0m", SkillEffects.count))

print("")

-- 创建独立的会话管理器和用户数据库
print("\27[36m[游戏服务器] 初始化会话管理器...\27[0m")
local SessionManager = require "./session_manager"
local sessionManager = SessionManager:new()

print("\27[36m[游戏服务器] 初始化用户数据库...\27[0m")
local UserDB = require "./userdb"
local userdb = UserDB

-- 启动游戏服务器
print("\27[36m[游戏服务器] 启动游戏服务器...\27[0m")
local lgs = require "./gameserver/localgameserver"
local gameServer = lgs.LocalGameServer:new(userdb, sessionManager, dataClient)

-- 导出到全局（供其他模块使用）
_G.gameServer = gameServer
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
    print("\27[33m[游戏服务器] 正在保存数据...\27[0m")
    local db = userdb:new()
    db:save()
    print("\27[32m[游戏服务器] ✓ 数据已保存\27[0m")
end

pcall(function()
    process:on("SIGINT", function()
        print("\n\27[33m[游戏服务器] 收到退出信号...\27[0m")
        saveAllData()
        os.exit(0)
    end)
end)

print("\27[32m[游戏服务器] ========== 服务器就绪 ==========\27[0m")
print(string.format("\27[36m[游戏服务器] 监听端口: %d\27[0m", conf.gameserver_port))
print("")
