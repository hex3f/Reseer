-- 游戏配置 (外部可修改)
-- 包含：初始玩家数据、初始精灵、系统公告等

local Config = {}

-- ============================================================
-- 初始玩家数据 (新用户默认值)
-- ============================================================
Config.InitialPlayer = {
    -- 基础属性 (默认配置为普通用户)
    regTime = 1230768000, -- 注册时间戳 (默认2009-01-01)
    
    coins = 2000,         -- 初始赛尔豆 (修改为更合理的数值)
    gold = 0,             -- 初始金豆
    
    -- VIP (超能NoNo) 设置
    -- isVIP = true 会开启 VIP 权限 flag
    -- 如果开启 isVIP，通常建议将 nono.superNono 也设为 1
    isVIP = false,        -- 是否默认开启超能NoNo (VIP) - 默认为false
    vipLevel = 0,         -- 默认VIP等级 (0-5)
    vipStage = 0,         -- VIP阶段 (0-6)
    autoCharge = 0,       -- 自动充值标识
    vipEndTime = 0,       -- VIP过期时间
    
    -- 外观与标识
    color = 0x66CCFF,     -- 默认颜色
    texture = 1,          -- 材质
    dsFlag = 0,           -- 黑暗/特殊标识
    badge = 0,            -- 徽章ID
    curTitle = 0,         -- 当前称号
    
    -- 初始位置
    mapID = 1,            -- 初始地图ID (1=机械室/飞船)
    posX = 300,           -- X坐标
    posY = 270,           -- Y坐标
    
    -- 其他属性
    energy = 100,         -- 初始能量/体力
    fightBadge = 0,       -- 战斗徽章
    
    -- 时间/防沉迷
    timeToday = 0,        -- 今日在线时间
    timeLimit = 86400,    -- 每日时间限制 (秒)
    
    -- 半天/特殊活动标识 (0或1)
    isClothHalfDay = 0,
    isRoomHalfDay = 0,
    iFortressHalfDay = 0,
    isHQHalfDay = 0,
    
    -- 社交计数
    loginCnt = 1,         -- 登录次数
    inviter = 0,          -- 邀请人ID
    newInviteeCnt = 0,    -- 新邀请数量
    
    -- 师徒系统
    teacherID = 0,
    studentID = 0,
    graduationCount = 0,
    maxPuniLv = 100,
    
    -- 关卡与战斗
    curStage = 0,
    maxStage = 0,
    curFreshStage = 0,
    maxFreshStage = 0,
    maxArenaWins = 0,
    monKingWin = 0,       -- 精灵王获胜次数
    monBtlMedal = 0,      -- 战斗奖牌
    
    -- 战斗辅助
    twoTimes = 0,         -- 双倍经验
    threeTimes = 0,       -- 三倍经验
    autoFight = 0,        -- 自动战斗
    autoFightTimes = 0,   -- 自动战斗次数
    energyTimes = 0,
    learnTimes = 0,
    
    -- 精灵限制
    petMaxLev = 100,      -- 精灵最大等级
    petAllNum = 0,        -- 精灵总数记录
    
    -- NoNo 默认配置 (如果没有Nono数据)
    nono = {
        flag = 0,         -- 是否拥有NoNo (1=有, 0=无) - 默认无NoNo
        superNono = 0,    -- 超能NoNo标识 (1=是, 0=否) - 通常与 isVIP 保持一致
        state = 0,        -- NoNo状态 (0=跟随, 1=驻守)
        color = 1,        -- NoNo颜色 (1-14)
        nick = "NoNo"     -- NoNo默认昵称
    }
}

-- ============================================================
-- 初始精灵 (新用户默认获得的精灵)
-- ============================================================
-- 注意：默认情况下，赛尔号是**不**直接送精灵的（需要通过任务或领取）。
-- 如果您希望新注册用户直接获得精灵，请取消下方注释。
Config.InitialPets = {
    -- 格式: { id=精灵ID, level=等级, name="昵称(可选)" }
    -- { id = 3, level = 5, name = "伊优" },  -- 示例：送一只5级伊优
    -- { id = 1, level = 5, name = "布布种子" },
    -- { id = 2, level = 5, name = "小火猴" },
}

-- ============================================================
-- 默认精灵属性 (当系统给予精灵或数据缺失时的默认值)
-- ============================================================
Config.PetDefaults = {
    level = 5,      -- 默认等级
    
    -- 使用函数来实现动态随机 (每次获取时都会随机生成)
    -- 如果想要固定值，可以直接写数字，例如: dv = 31
    dv = function() return math.random(0, 31) end,         -- 随机个体值 (0-31)
    nature = function() return math.random(0, 24) end,     -- 随机性格 (0-24)
}

-- ============================================================
-- 系统公告 (玩家登录后发送)
-- ============================================================
Config.SystemMessage = {
    enabled = true,  -- 是否启用开场公告
    
    -- 公告内容 (支持多行)
    content = [[
欢迎来到赛尔号怀旧服！
这里是您的私人宇宙空间。
祝您游戏愉快！
]]
}

return Config
