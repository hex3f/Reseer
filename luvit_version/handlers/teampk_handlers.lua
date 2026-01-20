-- 战队PK系统命令处理器
-- 包括: 战队PK报名、加入、射击等

local BinaryWriter = require('utils/binary_writer')
local ResponseBuilder = require('utils/response_builder')

local TeamPKHandlers = {}

-- CMD 4001: TEAM_PK_SIGN (战队PK报名)
local function handleTeamPKSign(ctx)
    local writer = BinaryWriter.new()
    writer:writeBytes(string.rep("\x00", 24))       -- sign (24 bytes)
    writer:writeUInt32BE(0x7F000001)    -- ip (127.0.0.1 in hex)
    writer:writeUInt16BE(5100)          -- port
    ctx.sendResponse(ResponseBuilder.build(4001, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_SIGN response\27[0m")
    return true
end

-- CMD 4002: TEAM_PK_REGISTER (战队PK注册)
local function handleTeamPKRegister(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4002, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_REGISTER response\27[0m")
    return true
end

-- CMD 4003: TEAM_PK_JOIN (加入战队PK)
local function handleTeamPKJoin(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)     -- homeId
    writer:writeUInt32BE(0)     -- homeCount = 0
    writer:writeUInt32BE(0)     -- awayId
    writer:writeUInt32BE(0)     -- awayCount = 0
    ctx.sendResponse(ResponseBuilder.build(4003, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_JOIN response\27[0m")
    return true
end

-- CMD 4004: TEAM_PK_SHOT (战队PK射击)
local function handleTeamPKShot(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4004, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_SHOT response\27[0m")
    return true
end

-- CMD 4005: TEAM_PK_REFRESH_DISTANCE (刷新距离)
local function handleTeamPKRefreshDistance(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4005, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_REFRESH_DISTANCE response\27[0m")
    return true
end

-- CMD 4006: TEAM_PK_WIN (战队PK胜利)
local function handleTeamPKWin(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4006, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_WIN response\27[0m")
    return true
end

-- CMD 4007: TEAM_PK_NOTE (战队PK通知)
local function handleTeamPKNote(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)     -- selfTeamID
    writer:writeUInt32BE(0)     -- homeTeamID
    writer:writeUInt32BE(0)     -- awayTeamID
    writer:writeUInt32BE(0)     -- event
    writer:writeUInt32BE(0)     -- time
    ctx.sendResponse(ResponseBuilder.build(4007, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_NOTE response\27[0m")
    return true
end

-- CMD 4008: TEAM_PK_FREEZE (冻结)
local function handleTeamPKFreeze(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4008, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_FREEZE response\27[0m")
    return true
end

-- CMD 4009: TEAM_PK_UNFREEZE (解冻)
local function handleTeamPKUnfreeze(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4009, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_UNFREEZE response\27[0m")
    return true
end

-- CMD 4010: TEAM_PK_BE_SHOT (被射击)
local function handleTeamPKBeShot(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4010, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_BE_SHOT response\27[0m")
    return true
end

-- CMD 4011: TEAM_PK_GET_BUILDING_INFO (获取建筑信息)
local function handleTeamPKGetBuildingInfo(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)     -- homeCount = 0
    writer:writeUInt32BE(0)     -- homeHeadId
    writer:writeUInt32BE(0)     -- awayCount = 0
    writer:writeUInt32BE(0)     -- awayHeadId
    ctx.sendResponse(ResponseBuilder.build(4011, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_GET_BUILDING_INFO response\27[0m")
    return true
end

-- CMD 4012: TEAM_PK_SITUATION (战况)
local function handleTeamPKSituation(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4012, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_SITUATION response\27[0m")
    return true
end

-- CMD 4013: TEAM_PK_RESULT (结果)
local function handleTeamPKResult(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4013, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_RESULT response\27[0m")
    return true
end

-- CMD 4014: TEAM_PK_USE_SHIELD (使用护盾)
local function handleTeamPKUseShield(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4014, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_USE_SHIELD response\27[0m")
    return true
end

-- CMD 4017: TEAM_PK_WEEKY_SCORE (周积分)
local function handleTeamPKWeekyScore(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(ResponseBuilder.build(4017, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_WEEKY_SCORE response\27[0m")
    return true
end

-- CMD 4018: TEAM_PK_HISTORY (历史记录)
local function handleTeamPKHistory(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(ResponseBuilder.build(4018, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_HISTORY response\27[0m")
    return true
end

-- CMD 4019: TEAM_PK_SOMEONE_JOIN_INFO (有人加入信息)
local function handleTeamPKSomeoneJoinInfo(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4019, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_SOMEONE_JOIN_INFO response\27[0m")
    return true
end

-- CMD 4020: TEAM_PK_NO_PET (无精灵)
local function handleTeamPKNoPet(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4020, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_NO_PET response\27[0m")
    return true
end

-- CMD 4022: TEAM_PK_ACTIVE (活动)
local function handleTeamPKActive(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4022, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_ACTIVE response\27[0m")
    return true
end

-- CMD 4023: TEAM_PK_ACTIVE_NOTE_GET_ITEM (活动获取物品通知)
local function handleTeamPKActiveNoteGetItem(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4023, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_ACTIVE_NOTE_GET_ITEM response\27[0m")
    return true
end

-- CMD 4024: TEAM_PK_ACTIVE_GET_ATTACK (活动获取攻击)
local function handleTeamPKActiveGetAttack(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4024, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_ACTIVE_GET_ATTACK response\27[0m")
    return true
end

-- CMD 4025: TEAM_PK_ACTIVE_GET_STONE (活动获取石头)
local function handleTeamPKActiveGetStone(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(4025, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_ACTIVE_GET_STONE response\27[0m")
    return true
end

-- CMD 4101: TEAM_PK_TEAM_CHARTS (战队排行榜)
local function handleTeamPKTeamCharts(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(ResponseBuilder.build(4101, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_TEAM_CHARTS response\27[0m")
    return true
end

-- CMD 4102: TEAM_PK_SEER_CHARTS (赛尔排行榜)
local function handleTeamPKSeerCharts(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(ResponseBuilder.build(4102, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_SEER_CHARTS response\27[0m")
    return true
end

-- CMD 2481: TEAM_PK_PET_FIGHT (战队PK精灵战斗)
local function handleTeamPKPetFight(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2481, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_PK_PET_FIGHT response\27[0m")
    return true
end

-- 注册所有处理器
function TeamPKHandlers.register(Handlers)
    Handlers.register(4001, handleTeamPKSign)
    Handlers.register(4002, handleTeamPKRegister)
    Handlers.register(4003, handleTeamPKJoin)
    Handlers.register(4004, handleTeamPKShot)
    Handlers.register(4005, handleTeamPKRefreshDistance)
    Handlers.register(4006, handleTeamPKWin)
    Handlers.register(4007, handleTeamPKNote)
    Handlers.register(4008, handleTeamPKFreeze)
    Handlers.register(4009, handleTeamPKUnfreeze)
    Handlers.register(4010, handleTeamPKBeShot)
    Handlers.register(4011, handleTeamPKGetBuildingInfo)
    Handlers.register(4012, handleTeamPKSituation)
    Handlers.register(4013, handleTeamPKResult)
    Handlers.register(4014, handleTeamPKUseShield)
    Handlers.register(4017, handleTeamPKWeekyScore)
    Handlers.register(4018, handleTeamPKHistory)
    Handlers.register(4019, handleTeamPKSomeoneJoinInfo)
    Handlers.register(4020, handleTeamPKNoPet)
    Handlers.register(4022, handleTeamPKActive)
    Handlers.register(4023, handleTeamPKActiveNoteGetItem)
    Handlers.register(4024, handleTeamPKActiveGetAttack)
    Handlers.register(4025, handleTeamPKActiveGetStone)
    Handlers.register(4101, handleTeamPKTeamCharts)
    Handlers.register(4102, handleTeamPKSeerCharts)
    Handlers.register(2481, handleTeamPKPetFight)
    print("\27[36m[Handlers] 战队PK命令处理器已注册\27[0m")
end

return TeamPKHandlers
