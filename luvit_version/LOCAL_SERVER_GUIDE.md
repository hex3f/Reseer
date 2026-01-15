# 赛尔号本地服务器实现指南

## 概述

本项目实现了赛尔号的本地服务器，支持两种运行模式：

1. **官服代理模式** (`local_server_mode = false`) - 所有请求转发到官服，同时记录流量
2. **本地服务器模式** (`local_server_mode = true`) - 完全本地运行，不依赖官服

## 架构

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Vue 前端      │────▶│   本地代理      │────▶│   官服          │
│   (浏览器)      │◀────│   (Luvit)       │◀────│   (45.125.46.70)│
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │
        │                       ▼
        │               ┌─────────────────┐
        │               │   流量日志      │
        │               │   (sessionlog/) │
        │               └─────────────────┘
        │
        ▼
┌─────────────────┐
│   Flash 客户端  │
│   (Ruffle)      │
└─────────────────┘
```

## 已实现的命令

### 登录服务器 (trafficloggerlogin.lua / websocket_login.lua)

| CMD | 名称 | 说明 |
|-----|------|------|
| 105 | COMMEND_ONLINE | 获取服务器列表 |
| 106 | RANGE_ONLINE | 获取指定范围服务器 |
| 109 | SYS_ROLE | 角色验证 |
| 111 | FENGHAO_TIME | 封号时间 |
| 1001 | LOGIN_IN | 登录游戏服务器 |
| 1002 | SYSTEM_TIME | 获取系统时间 |

### 游戏服务器 (localgameserver.lua)

| CMD | 名称 | 说明 |
|-----|------|------|
| 2001 | ENTER_MAP | 进入地图 |
| 2002 | LEAVE_MAP | 离开地图 |
| 2051 | GET_SIM_USERINFO | 获取简单用户信息 |
| 2052 | GET_MORE_USERINFO | 获取详细用户信息 |
| 2101 | PEOPLE_WALK | 人物移动 |
| 2102 | CHAT | 聊天 |
| 2201 | ACCEPT_TASK | 接受任务 |
| 2202 | COMPLETE_TASK | 完成任务 |
| 2203 | GET_TASK_BUF | 获取任务缓存 |
| 2301 | GET_PET_INFO | 获取精灵信息 |
| 2303 | GET_PET_LIST | 获取精灵列表 |
| 2354 | GET_SOUL_BEAD_LIST | 获取灵魂珠列表 |
| 2401 | INVITE_TO_FIGHT | 邀请战斗 |
| 2405 | USE_SKILL | 使用技能 |
| 2408 | FIGHT_NPC_MONSTER | 战斗NPC怪物 |
| 2410 | ESCAPE_FIGHT | 逃跑 |
| 2757 | MAIL_GET_UNREAD | 获取未读邮件 |
| 9003 | NONO_INFO | 获取NONO信息 |
| 50004 | CLIENT_INFO | 客户端信息上报 |
| 50008 | UNKNOWN | 未知命令 |

## 数据包格式

### 请求/响应头部 (17 字节)

```
┌────────┬─────────┬────────┬────────┬────────┐
│ length │ version │ cmdId  │ userId │ result │
│ 4字节  │ 1字节   │ 4字节  │ 4字节  │ 4字节  │
└────────┴─────────┴────────┴────────┴────────┘
```

- **length**: 整个数据包长度（包括头部）
- **version**: 协议版本 (0x31 请求, 0x37 响应)
- **cmdId**: 命令ID
- **userId**: 用户ID
- **result**: 结果码 (0=成功)

### 服务器列表 (CMD 105 响应)

```
┌──────────────┬────────┬────────────┬─────────────────────────────┐
│ maxOnlineID  │ isVIP  │ onlineCnt  │ ServerInfo[] (30字节 × N)   │
│ 4字节        │ 4字节  │ 4字节      │                             │
└──────────────┴────────┴────────────┴─────────────────────────────┘

ServerInfo (30 字节):
┌──────────┬─────────┬────────────┬────────┬─────────┐
│ onlineID │ userCnt │ ip         │ port   │ friends │
│ 4字节    │ 4字节   │ 16字节     │ 2字节  │ 4字节   │
└──────────┴─────────┴────────────┴────────┴─────────┘
```

## 流量日志

流量日志保存在 `sessionlog/` 目录：

- `login_YYYYMMDD_HHMMSS.json` - 登录服务器流量 (JSON 格式)
- `*.bin` - 游戏服务器原始流量
- `*-decrypted.bin` - 游戏服务器解密后流量

### 分析流量

```bash
cd luvit_version
./luvit session_analyze/traffic_analyzer.lua
```

## 配置

编辑 `reseer.lua` 中的 `conf` 表：

```lua
conf = {
    -- 运行模式
    local_server_mode = false,  -- true=本地模式, false=官服代理模式
    
    -- 官服地址
    official_login_server = "45.125.46.70",
    official_login_ws_port = 12345,
    
    -- 本地端口
    login_port = 1863,
    gameserver_port = 5000,
    ressrv_port = 32400,
}
```

## 启动服务器

```bash
cd luvit_version
./luvit reseer.lua
```

## 访问游戏

打开浏览器访问: http://127.0.0.1:32400/

## 待实现功能

- [ ] 精灵系统 (捕捉、进化、战斗)
- [ ] 背包系统
- [ ] 任务系统
- [ ] 好友系统
- [ ] 邮件系统
- [ ] 商城系统
- [ ] 地图系统
- [ ] NPC 交互
- [ ] 战斗系统完整实现
