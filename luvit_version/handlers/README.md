# 命令处理器模块

这个目录包含了所有游戏协议命令的处理器，按功能分类到不同的文件中。

## 目录结构

```
handlers/
├── init.lua                  # 处理器注册中心
├── utils.lua                 # 工具函数 (读写二进制数据)
├── system_handlers.lua       # 系统命令 (登录、时间、购买等)
├── map_handlers.lua          # 地图命令 (进入/离开地图、移动、聊天等)
├── task_handlers.lua         # 任务命令 (接受/完成任务)
├── pet_handlers.lua          # 精灵命令 (获取精灵信息、释放精灵等)
├── pet_advanced_handlers.lua # 精灵高级功能 (进化、孵化、融合等)
├── fight_handlers.lua        # 战斗命令 (挑战BOSS、使用技能等)
├── item_handlers.lua         # 物品命令 (购买物品、物品列表等)
├── mail_handlers.lua         # 邮件/通知命令
├── friend_handlers.lua       # 好友命令 (添加/删除好友、黑名单等)
├── team_handlers.lua         # 战队命令 (创建/加入战队等)
├── teampk_handlers.lua       # 战队PK命令 (报名、射击等)
├── arena_handlers.lua        # 竞技场命令 (挑战、暗黑传送门等)
├── room_handlers.lua         # 房间命令 (家具、装饰等)
├── nono_handlers.lua         # NONO命令 (开启、喂食、治疗等)
├── teacher_handlers.lua      # 师徒命令 (拜师、收徒等)
├── game_handlers.lua         # 小游戏命令 (加入游戏、结束等)
├── special_handlers.lua      # 特殊活动命令 (新年、元宵等)
├── exchange_handlers.lua     # 交换命令 (服装、精灵、矿石交换)
├── work_handlers.lua         # 工作命令 (连接、举报等)
├── xin_handlers.lua          # 新功能命令 (皮肤、成就、签到等)
├── misc_handlers.lua         # 其他命令
└── README.md                 # 本文件
```

## 使用方法

### 1. 在主服务器中初始化

```lua
-- 加载处理器模块
local Handlers = require('./handlers/init')

-- 加载所有处理器
Handlers.loadAll()
```

### 2. 处理命令

```lua
-- 创建上下文
local ctx = {
    userId = header.userId,
    body = body,                    -- 请求体 (不含17字节头部)
    sendResponse = sendResponse,    -- 发送响应的函数
    getOrCreateUser = getOrCreateUser,
    saveUserDB = saveUserDB,
    userDB = userDB,
}

-- 执行处理器
if Handlers.has(cmdId) then
    Handlers.execute(cmdId, ctx)
else
    -- 未实现的命令，返回空响应
    sendResponse(buildResponse(cmdId, userId, 0, ""))
end
```

### 3. 添加新的处理器

在对应的文件中添加处理函数，然后在 `register` 函数中注册：

```lua
-- 在 xxx_handlers.lua 中

-- 定义处理函数
local function handleNewCommand(ctx)
    -- 解析请求
    local param = Utils.readUInt32BE(ctx.body, 1)
    
    -- 处理逻辑
    local user = ctx.getOrCreateUser(ctx.userId)
    -- ...
    
    -- 构建响应
    local body = Utils.writeUInt32BE(result)
    ctx.sendResponse(Utils.buildResponse(CMD_ID, ctx.userId, 0, body))
    
    return true
end

-- 在 register 函数中注册
function XxxHandlers.register(Handlers)
    Handlers.register(CMD_ID, handleNewCommand)
    -- ...
end
```

## 上下文对象 (ctx)

处理器函数接收一个上下文对象，包含以下字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| userId | number | 用户ID |
| body | string | 请求体 (不含17字节头部) |
| sendResponse | function | 发送响应的函数 |
| getOrCreateUser | function | 获取或创建用户数据 |
| saveUserDB | function | 保存用户数据库 |
| userDB | table | 用户数据库引用 |

## 工具函数 (utils.lua)

| 函数 | 说明 |
|------|------|
| writeUInt32BE(value) | 写入4字节大端整数 |
| writeUInt16BE(value) | 写入2字节大端整数 |
| readUInt32BE(data, offset) | 读取4字节大端整数 |
| readUInt16BE(data, offset) | 读取2字节大端整数 |
| writeFixedString(str, length) | 写入固定长度字符串 |
| readFixedString(data, offset, length) | 读取固定长度字符串 |
| buildResponse(cmdId, userId, result, body) | 构建响应包 |

## 已实现的命令

### 系统命令 (system_handlers.lua)
- 1002 SYSTEM_TIME - 系统时间
- 1004 MAP_HOT - 地图热度
- 1005 GET_IMAGE_ADDRESS - 获取图片地址
- 1102 MONEY_BUY_PRODUCT - 米币购买
- 1104 GOLD_BUY_PRODUCT - 金币购买
- 1106 GOLD_ONLINE_CHECK_REMAIN - 在线金币余额

### 地图命令 (map_handlers.lua)
- 2001 ENTER_MAP - 进入地图
- 2002 LEAVE_MAP - 离开地图
- 2003 LIST_MAP_PLAYER - 地图玩家列表
- 2004 MAP_OGRE_LIST - 地图怪物列表
- 2051 GET_SIM_USERINFO - 获取简单用户信息
- 2052 GET_MORE_USERINFO - 获取详细用户信息
- 2061 CHANGE_NICK_NAME - 修改昵称
- 2101 PEOPLE_WALK - 玩家移动
- 2102 CHAT - 聊天
- 2103 DANCE_ACTION - 舞蹈动作
- 2104 AIMAT - 瞄准
- 2111 PEOPLE_TRANSFROM - 玩家变身

### 任务命令 (task_handlers.lua)
- 2201 ACCEPT_TASK - 接受任务
- 2202 COMPLETE_TASK - 完成任务
- 2203 GET_TASK_BUF - 获取任务缓存
- 2234 GET_DAILY_TASK_BUF - 获取每日任务缓存

### 精灵命令 (pet_handlers.lua)
- 2301 GET_PET_INFO - 获取精灵信息
- 2303 GET_PET_LIST - 获取精灵列表
- 2304 PET_RELEASE - 释放精灵
- 2305 PET_SHOW - 展示精灵
- 2306 PET_CURE - 治疗精灵
- 2309 PET_BARGE_LIST - 精灵仓库列表
- 2354 GET_SOUL_BEAD_LIST - 获取魂珠列表

### 精灵高级功能 (pet_advanced_handlers.lua)
- 2302 MODIFY_PET_NAME - 修改精灵名字
- 2307 PET_STUDY_SKILL - 学习技能
- 2308 PET_DEFAULT - 设置默认精灵
- 2310 PET_ONE_CURE - 单个治疗
- 2311 PET_COLLECT - 精灵收集
- 2312 PET_SKILL_SWICTH - 技能切换
- 2313 IS_COLLECT - 是否收集
- 2314 PET_EVOLVTION - 精灵进化
- 2315 PET_HATCH - 精灵孵化
- 2316 PET_HATCH_GET - 获取孵化精灵
- 2318 PET_SET_EXP - 设置经验
- 2319 PET_GET_EXP - 获取经验
- 2320 PET_ROWEI_LIST - 入围列表
- 2321 PET_ROWEI - 精灵入围
- 2322 PET_RETRIEVE - 精灵找回
- 2323 PET_ROOM_SHOW - 房间展示
- 2324 PET_ROOM_LIST - 房间列表
- 2325 PET_ROOM_INFO - 房间信息
- 2326 USE_PET_ITEM_OUT_OF_FIGHT - 战斗外使用道具
- 2327 USE_SPEEDUP_ITEM - 使用加速道具
- 2328 Skill_Sort - 技能排序
- 2329 USE_AUTO_FIGHT_ITEM - 自动战斗道具
- 2330 ON_OFF_AUTO_FIGHT - 开关自动战斗
- 2331 USE_ENERGY_XISHOU - 能量吸收
- 2332 USE_STUDY_ITEM - 学习道具
- 2343 PET_RESET_NATURE - 重置性格
- 2351 PET_FUSION - 精灵融合
- 2352 GET_SOUL_BEAD_BUF - 获取魂珠缓存
- 2353 SET_SOUL_BEAD_BUF - 设置魂珠缓存
- 2356 GET_SOULBEAD_STATUS - 魂珠状态
- 2357 TRANSFORM_SOULBEAD - 转化魂珠
- 2358 SOULBEAD_TO_PET - 魂珠转精灵

### 战斗命令 (fight_handlers.lua)
- 2404 READY_TO_FIGHT - 准备战斗
- 2405 USE_SKILL - 使用技能
- 2406 USE_PET_ITEM - 使用精灵道具
- 2407 CHANGE_PET - 更换精灵
- 2409 CATCH_MONSTER - 捕捉怪物
- 2410 ESCAPE_FIGHT - 逃跑
- 2411 CHALLENGE_BOSS - 挑战BOSS

### 物品命令 (item_handlers.lua)
- 2601 ITEM_BUY - 购买物品
- 2604 CHANGE_CLOTH - 更换服装
- 2605 ITEM_LIST - 物品列表

### 邮件/通知命令 (mail_handlers.lua)
- 2751 MAIL_GET_LIST - 获取邮件列表
- 2757 MAIL_GET_UNREAD - 获取未读邮件
- 8001 INFORM - 通知
- 8004 GET_BOSS_MONSTER - 获取BOSS怪物

### 好友命令 (friend_handlers.lua)
- 2151 FRIEND_ADD - 添加好友
- 2152 FRIEND_ANSWER - 回复好友请求
- 2153 FRIEND_REMOVE - 删除好友
- 2154 BLACK_ADD - 添加黑名单
- 2155 BLACK_REMOVE - 移除黑名单
- 2157 SEE_ONLINE - 查看在线
- 2158 REQUEST_OUT - 请求外出
- 2159 REQUEST_ANSWER - 回复请求

### 战队命令 (team_handlers.lua)
- 2910 TEAM_CREATE - 创建战队
- 2911 TEAM_ADD - 申请加入
- 2912 TEAM_ANSWER - 回复申请
- 2913 TEAM_INFORM - 战队通知
- 2914 TEAM_QUIT - 退出战队
- 2917 TEAM_GET_INFO - 获取战队信息
- 2918 TEAM_GET_MEMBER_LIST - 成员列表
- 2928 TEAM_GET_LOGO_INFO - 徽章信息
- 2929 TEAM_CHAT - 战队聊天
- 2962 ARM_UP_WORK - 军团工作
- 2963 ARM_UP_DONATE - 军团捐献

### 战队PK命令 (teampk_handlers.lua)
- 4001 TEAM_PK_SIGN - 报名
- 4002 TEAM_PK_REGISTER - 注册
- 4003 TEAM_PK_JOIN - 加入
- 4004 TEAM_PK_SHOT - 射击
- 4005 TEAM_PK_REFRESH_DISTANCE - 刷新距离
- 4006 TEAM_PK_WIN - 胜利
- 4007 TEAM_PK_NOTE - 通知
- 4008 TEAM_PK_FREEZE - 冻结
- 4009 TEAM_PK_UNFREEZE - 解冻
- 4010 TEAM_PK_BE_SHOT - 被射击
- 4011 TEAM_PK_GET_BUILDING_INFO - 建筑信息
- 4012 TEAM_PK_SITUATION - 战况
- 4013 TEAM_PK_RESULT - 结果
- 4014 TEAM_PK_USE_SHIELD - 使用护盾
- 4017 TEAM_PK_WEEKY_SCORE - 周积分
- 4018 TEAM_PK_HISTORY - 历史记录
- 4019 TEAM_PK_SOMEONE_JOIN_INFO - 有人加入
- 4020 TEAM_PK_NO_PET - 无精灵
- 4022 TEAM_PK_ACTIVE - 活动
- 4023 TEAM_PK_ACTIVE_NOTE_GET_ITEM - 活动获取物品
- 4024 TEAM_PK_ACTIVE_GET_ATTACK - 活动获取攻击
- 4025 TEAM_PK_ACTIVE_GET_STONE - 活动获取石头
- 4101 TEAM_PK_TEAM_CHARTS - 战队排行榜
- 4102 TEAM_PK_SEER_CHARTS - 赛尔排行榜
- 2481 TEAM_PK_PET_FIGHT - 精灵战斗

### 竞技场命令 (arena_handlers.lua)
- 2414 CHOICE_FIGHT_LEVEL - 选择关卡
- 2415 START_FIGHT_LEVEL - 开始关卡
- 2416 LEAVE_FIGHT_LEVEL - 离开关卡
- 2417 ARENA_SET_OWENR - 设置主人
- 2418 ARENA_FIGHT_OWENR - 挑战主人
- 2419 ARENA_GET_INFO - 获取信息
- 2420 ARENA_UPFIGHT - 升级战斗
- 2421 FIGHT_SPECIAL_PET - 特殊精灵战斗
- 2422 ARENA_OWENR_ACCE - 主人接受
- 2423 ARENA_OWENR_OUT - 主人退出
- 2424 OPEN_DARKPORTAL - 打开暗黑传送门
- 2425 FIGHT_DARKPORTAL - 暗黑传送门战斗
- 2426 LEAVE_DARKPORTAL - 离开暗黑传送门
- 2428 FRESH_CHOICE_FIGHT_LEVEL - 新手选择关卡
- 2429 FRESH_START_FIGHT_LEVEL - 新手开始关卡
- 2430 FRESH_LEAVE_FIGHT_LEVEL - 新手离开关卡

### 房间命令 (room_handlers.lua)
- 10001 ROOM_LOGIN - 房间登录
- 10002 GET_ROOM_ADDRES - 获取房间地址
- 10003 LEAVE_ROOM - 离开房间
- 10004 BUY_FITMENT - 购买家具
- 10005 BETRAY_FITMENT - 出售家具
- 10006 FITMENT_USERING - 正在使用的家具
- 10007 FITMENT_ALL - 所有家具
- 10008 SET_FITMENT - 设置家具
- 10009 ADD_ENERGY - 增加能量

### NONO命令 (nono_handlers.lua)
- 9001 NONO_OPEN - 开启NONO
- 9002 NONO_CHANGE_NAME - 修改名字
- 9003 NONO_INFO - 获取信息
- 9004 NONO_CHIP_MIXTURE - 芯片合成
- 9007 NONO_CURE - 治疗
- 9008 NONO_EXPADM - 经验管理
- 9010 NONO_IMPLEMENT_TOOL - 使用道具
- 9012 NONO_CHANGE_COLOR - 改变颜色
- 9013 NONO_PLAY - 玩耍
- 9014 NONO_CLOSE_OPEN - 开关
- 9015 NONO_EXE_LIST - 执行列表
- 9016 NONO_CHARGE - 充电
- 9017 NONO_START_EXE - 开始执行
- 9018 NONO_END_EXE - 结束执行
- 9019 NONO_FOLLOW_OR_HOOM - 跟随或回家
- 9020 NONO_OPEN_SUPER - 开启超级NONO
- 9021 NONO_HELP_EXP - 帮助经验
- 9022 NONO_MATE_CHANGE - 心情变化
- 9023 NONO_GET_CHIP - 获取芯片
- 9024 NONO_ADD_ENERGY_MATE - 增加能量心情
- 9025 GET_DIAMOND - 获取钻石
- 9026 NONO_ADD_EXP - 增加经验
- 9027 NONO_IS_INFO - 是否有信息

### 师徒命令 (teacher_handlers.lua)
- 3001 REQUEST_ADD_TEACHER - 请求拜师
- 3002 ANSWER_ADD_TEACHER - 回复拜师
- 3003 REQUEST_ADD_STUDENT - 请求收徒
- 3004 ANSWER_ADD_STUDENT - 回复收徒
- 3005 DELETE_TEACHER - 删除师傅
- 3006 DELETE_STUDENT - 删除徒弟
- 3007 EXPERIENCESHARED_COMPLETE - 经验分享完成
- 3008 TEACHERREWARD_COMPLETE - 师傅奖励完成
- 3009 MYEXPERIENCEPOND_COMPLETE - 经验池完成
- 3010 SEVENNOLOGIN_COMPLETE - 七天未登录完成
- 3011 GETMYEXPERIENCE_COMPLETE - 获取经验完成

### 小游戏命令 (game_handlers.lua)
- 5001 JOIN_GAME - 加入游戏
- 5002 GAME_OVER - 游戏结束
- 5003 LEAVE_GAME - 离开游戏
- 5052 FB_GAME_OVER - FB游戏结束
- 3201 EGG_GAME_PLAY - 砸蛋游戏
- 2442 ML_FIG_BOSS - 魔力BOSS战斗
- 2444 ML_STATE_BOSS - 魔力BOSS状态
- 2445 ML_STEP_POS - 魔力步骤位置
- 2446 ML_GET_PRIZE - 魔力获取奖励

### 特殊活动命令 (special_handlers.lua)
- 1108 NEWYEAR_REDPACKETS - 新年红包
- 1110 GET_YUANXIAO_GIFT - 元宵礼物
- 1111 NAMEPLATE_EXC_PET - 铭牌交换精灵
- 1112 GET_NAMEPLATE - 获取铭牌
- 2022 SPECIAL_PET_NOTE - 特殊精灵通知
- 2023 OFF_LINE_EXP - 离线经验
- 2064 GET_REQUEST_AWARD - 获取请求奖励
- 2106 PRIZE_OF_ATRESIASPACE - 阿特雷西亚空间奖励
- 2317 PRIZE_OF_PETKING - 精灵王奖励
- 2801 GET_GIFT_COMPLETE - 获取礼物完成
- 2821 USER_TIME_PASSWORD - 用户时间密码
- 2851 SET_DS_STATUS - 设置DS状态
- 2852 PRICE_OF_DS - DS价格
- 2935 NEW_YEAR_NOTE - 新年通知
- 2936 NEW_YEAR_NPC_NOTE - 新年NPC通知
- 3301 AWARD_CODE - 奖励码
- 8009 MEDAL_GET_COUNT - 勋章计数
- 8010 SPRINT_GIFT_NOTICE - 冲刺礼物通知

### 交换命令 (exchange_handlers.lua)
- 2901 EXCHANGE_CLOTH_COMPLETE - 服装交换完成
- 2902 EXCHANGE_PET_COMPLETE - 精灵交换完成
- 2251 EXCHANGE_ORE - 矿石交换
- 2065 EXCHANGE_NEXYEAR - 新年交换
- 2701 TALK_COUNT - 对话计数
- 2702 TALK_CATE - 对话分类

### 工作命令 (work_handlers.lua)
- 6001 WORK_CONNECTION - 工作连接
- 6003 ALL_CONNECTION - 全部连接
- 1007 READ_COUNT - 阅读计数
- 7001 USER_REPORT - 用户举报
- 7002 USER_CONTRIBUTE - 用户贡献
- 7003 USER_INDAGATE - 用户调查
- 7501 INVITE_JOIN_GROUP - 邀请加入群组
- 7502 REPLY_JOIN_GROUP - 回复加入群组

### 新功能命令 (xin_handlers.lua)
- 50001 XIN_SETSKIN - 设置皮肤
- 50003 GET_ONE_PET_SKIN_INFO - 获取精灵皮肤信息
- 50005 XIN_MATERIALS - 材料
- 50006 XIN_FUSION - 融合
- 50007 XIN_SET_QUADRUPLE_EXE_TIME - 设置四倍执行时间
- 50009 XIN_SIGN - 签到
- 50010 XIN_GET_ACHIEVEMENTS - 获取成就
- 50011 XIN_SET_ACHIEVEMENT - 设置成就
- 50012 XIN_BATCH - 批量操作
- 50013 XIN_FISH - 钓鱼
- 50014 XIN_USE - 使用
- 50015 XIN_PETBAG - 精灵背包
- 52102 XIN_CHAT - 聊天
- 2393 LEIYI_TRAIN_GET_STATUS - 雷伊训练状态

### 其他命令 (misc_handlers.lua)
- 50004 XIN_CHECK - 检查
- 50008 XIN_GET_QUADRUPLE_EXE_TIME - 获取四倍执行时间

## 命令总数

目前已实现约 **200+** 个命令处理器，覆盖了游戏的主要功能系统。
