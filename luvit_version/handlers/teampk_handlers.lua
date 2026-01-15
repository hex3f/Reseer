-- 战队PK系统命令处理器
-- 包括: 战队PK报名、加入、射击等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local TeamPKHandlers = {}

-- CMD 4001: TEAM_PK_SIGN (战队PK报名)
-- TeamPKSignInfo: sign(24 bytes) + ip(4) + port(2)
local function handleTeamPKSign(ctx)
    local body = ""
    body = body .. string.rep("\x00", 24)       -- sign (24 bytes)
    body = body .. writeUInt32BE(0x7F000001)    -- ip (127.0.0.1 in hex)
    body = body .. writeUInt16BE(8080)          -- port
    ctx.sendResponse(buildResponse(4001, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEAM_PK_SIGN response\27[0m")
    return true
end

-- CMD 4002: TEAM_PK_REGISTER (战队PK注册)
local function handleTeamPKRegister(ctx)
    ctx.sendResponse(buildResponse(4002, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_REGISTER response\27[0m")
    return true
end

-- CMD 4003: TEAM_PK_JOIN (加入战队PK)
-- TeamPKJoinInfo: homeId(4) + homeCount(4) + [TeamPkUserInfo]... + awayId(4) + awayCount(4) + [TeamPkUserInfo]...
-- TeamPkUserInfo: uid(4) + hp(4) + maxHp(4) + where(4) + reserved(4) + reserved(4)
local function handleTeamPKJoin(ctx)
    local body = ""
    body = body .. writeUInt32BE(0)     -- homeId
    body = body .. writeUInt32BE(0)     -- homeCount = 0
    body = body .. writeUInt32BE(0)     -- awayId
    body = body .. writeUInt32BE(0)     -- awayCount = 0
    ctx.sendResponse(buildResponse(4003, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEAM_PK_JOIN response\27[0m")
    return true
end

-- CMD 4004: TEAM_PK_SHOT (战队PK射击)
local function handleTeamPKShot(ctx)
    ctx.sendResponse(buildResponse(4004, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_SHOT response\27[0m")
    return true
end

-- CMD 4005: TEAM_PK_REFRESH_DISTANCE (刷新距离)
local function handleTeamPKRefreshDistance(ctx)
    ctx.sendResponse(buildResponse(4005, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_REFRESH_DISTANCE response\27[0m")
    return true
end

-- CMD 4006: TEAM_PK_WIN (战队PK胜利)
local function handleTeamPKWin(ctx)
    ctx.sendResponse(buildResponse(4006, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_WIN response\27[0m")
    return true
end

-- CMD 4007: TEAM_PK_NOTE (战队PK通知)
-- TeamPKNoteInfo: selfTeamID(4) + homeTeamID(4) + awayTeamID(4) + event(4) + time(4)
local function handleTeamPKNote(ctx)
    local body = ""
    body = body .. writeUInt32BE(0)     -- selfTeamID
    body = body .. writeUInt32BE(0)     -- homeTeamID
    body = body .. writeUInt32BE(0)     -- awayTeamID
    body = body .. writeUInt32BE(0)     -- event
    body = body .. writeUInt32BE(0)     -- time
    ctx.sendResponse(buildResponse(4007, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEAM_PK_NOTE response\27[0m")
    return true
end

-- CMD 4008: TEAM_PK_FREEZE (冻结)
-- TeamPKFreezeInfo
local function handleTeamPKFreeze(ctx)
    ctx.sendResponse(buildResponse(4008, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_FREEZE response\27[0m")
    return true
end

-- CMD 4009: TEAM_PK_UNFREEZE (解冻)
local function handleTeamPKUnfreeze(ctx)
    ctx.sendResponse(buildResponse(4009, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_UNFREEZE response\27[0m")
    return true
end

-- CMD 4010: TEAM_PK_BE_SHOT (被射击)
-- TeamPKBeShotInfo
local function handleTeamPKBeShot(ctx)
    ctx.sendResponse(buildResponse(4010, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_BE_SHOT response\27[0m")
    return true
end

-- CMD 4011: TEAM_PK_GET_BUILDING_INFO (获取建筑信息)
-- TeamPKBuildingListInfo: homeCount(4) + homeHeadId(4) + [buildings]... + awayCount(4) + awayHeadId(4) + [buildings]...
local function handleTeamPKGetBuildingInfo(ctx)
    local body = ""
    body = body .. writeUInt32BE(0)     -- homeCount = 0
    body = body .. writeUInt32BE(0)     -- homeHeadId
    body = body .. writeUInt32BE(0)     -- awayCount = 0
    body = body .. writeUInt32BE(0)     -- awayHeadId
    ctx.sendResponse(buildResponse(4011, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEAM_PK_GET_BUILDING_INFO response\27[0m")
    return true
end

-- CMD 4012: TEAM_PK_SITUATION (战况)
-- TeamPkStInfo
local function handleTeamPKSituation(ctx)
    ctx.sendResponse(buildResponse(4012, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_SITUATION response\27[0m")
    return true
end

-- CMD 4013: TEAM_PK_RESULT (结果)
-- TeamPKResultInfo
local function handleTeamPKResult(ctx)
    ctx.sendResponse(buildResponse(4013, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_RESULT response\27[0m")
    return true
end

-- CMD 4014: TEAM_PK_USE_SHIELD (使用护盾)
-- SuperNonoShieldInfo
local function handleTeamPKUseShield(ctx)
    ctx.sendResponse(buildResponse(4014, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_USE_SHIELD response\27[0m")
    return true
end

-- CMD 4017: TEAM_PK_WEEKY_SCORE (周积分)
-- TeamPkWeekyHistoryInfo
local function handleTeamPKWeekyScore(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(4017, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEAM_PK_WEEKY_SCORE response\27[0m")
    return true
end

-- CMD 4018: TEAM_PK_HISTORY (历史记录)
-- TeamPkHistoryInfo
local function handleTeamPKHistory(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(4018, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEAM_PK_HISTORY response\27[0m")
    return true
end

-- CMD 4019: TEAM_PK_SOMEONE_JOIN_INFO (有人加入信息)
-- SomeoneJoinInfo
local function handleTeamPKSomeoneJoinInfo(ctx)
    ctx.sendResponse(buildResponse(4019, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_SOMEONE_JOIN_INFO response\27[0m")
    return true
end

-- CMD 4020: TEAM_PK_NO_PET (无精灵)
local function handleTeamPKNoPet(ctx)
    ctx.sendResponse(buildResponse(4020, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_NO_PET response\27[0m")
    return true
end

-- CMD 4022: TEAM_PK_ACTIVE (活动)
local function handleTeamPKActive(ctx)
    ctx.sendResponse(buildResponse(4022, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_ACTIVE response\27[0m")
    return true
end

-- CMD 4023: TEAM_PK_ACTIVE_NOTE_GET_ITEM (活动获取物品通知)
local function handleTeamPKActiveNoteGetItem(ctx)
    ctx.sendResponse(buildResponse(4023, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_ACTIVE_NOTE_GET_ITEM response\27[0m")
    return true
end

-- CMD 4024: TEAM_PK_ACTIVE_GET_ATTACK (活动获取攻击)
local function handleTeamPKActiveGetAttack(ctx)
    ctx.sendResponse(buildResponse(4024, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_ACTIVE_GET_ATTACK response\27[0m")
    return true
end

-- CMD 4025: TEAM_PK_ACTIVE_GET_STONE (活动获取石头)
local function handleTeamPKActiveGetStone(ctx)
    ctx.sendResponse(buildResponse(4025, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TEAM_PK_ACTIVE_GET_STONE response\27[0m")
    return true
end

-- CMD 4101: TEAM_PK_TEAM_CHARTS (战队排行榜)
-- TeamChartsInfo
local function handleTeamPKTeamCharts(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(4101, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEAM_PK_TEAM_CHARTS response\27[0m")
    return true
end

-- CMD 4102: TEAM_PK_SEER_CHARTS (赛尔排行榜)
-- SeerChartsInfo
local function handleTeamPKSeerCharts(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(4102, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEAM_PK_SEER_CHARTS response\27[0m")
    return true
end

-- CMD 2481: TEAM_PK_PET_FIGHT (战队PK精灵战斗)
local function handleTeamPKPetFight(ctx)
    ctx.sendResponse(buildResponse(2481, ctx.userId, 0, writeUInt32BE(0)))
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
