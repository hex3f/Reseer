@echo off
chcp 65001 >nul
title 赛尔号服务器启动器

echo ╔════════════════════════════════════════════════════════════╗
echo ║          赛尔号本地服务器 - 多窗口启动模式                 ║
echo ║          (游戏服务器和房间服务器已合并)                    ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: 检查 luvit 是否存在
if not exist "luvit.exe" (
    echo [错误] 未找到 luvit.exe
    echo 请确保 luvit.exe 在当前目录下
    pause
    exit /b 1
)

echo [启动] 正在启动所有服务器窗口...
echo 注意: 游戏服务器已包含家园系统功能
echo.

:: 1. 启动资源服务器（提供网页入口）
echo [1/4] 启动资源服务器 (端口 32400)...
start "资源服务器 - Resource Server" cmd /k "luvit start_ressrv.lua"
timeout /t 2 /nobreak >nul

:: 2. 启动登录IP服务器（提供 ip.txt）
echo [2/4] 启动登录IP服务器 (端口 32401)...
start "登录IP服务器 - Login IP Server" cmd /k "luvit start_loginip.lua"
timeout /t 2 /nobreak >nul

:: 3. 启动登录服务器（处理登录认证）
echo [3/4] 启动登录服务器 (端口 1863)...
start "登录服务器 - Login Server" cmd /k "luvit start_loginserver.lua"
timeout /t 2 /nobreak >nul

:: 4. 启动游戏服务器（已包含家园系统）
echo [4/4] 启动游戏服务器 (端口 5000 - 包含家园系统)...
start "游戏服务器 - Game Server (含家园)" cmd /k "luvit start_gameserver.lua"
timeout /t 2 /nobreak >nul

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║                    所有服务器已启动                         ║
echo ╠════════════════════════════════════════════════════════════╣
echo ║  🎮 游戏入口:       http://127.0.0.1:32400/                ║
echo ║  📦 资源服务器:     127.0.0.1:32400                        ║
echo ║  📝 登录IP服务:     127.0.0.1:32401                        ║
echo ║  🔐 登录服务器:     127.0.0.1:1863                         ║
echo ║  🎯 游戏服务器:     127.0.0.1:5000 (含家园系统)            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo ✅ 所有服务器已在独立窗口中启动
echo 💡 游戏服务器和房间服务器已合并为统一服务
echo 🎮 现在可以访问: http://127.0.0.1:32400/
echo.
echo ⚠️  注意事项:
echo    - 游戏服务器现在处理所有游戏和家园功能
echo    - 数据会自动保存到 users.json
echo    - 关闭任一窗口不会影响其他服务器
echo    - 建议按顺序关闭（先关游戏，再关登录/资源）
echo.
echo 提示: 关闭此窗口不会停止服务器
echo       要停止服务器，请关闭各个服务器窗口
echo.
pause
