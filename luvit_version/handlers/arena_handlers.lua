-- 竞技场系统命令处理器
-- 包括: 竞技场信息、挑战、暗黑传送门等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local ArenaHandlers = {}

-- CMD 2414: CHOICE_FIGHT_LEVEL (选择战斗关卡)
-- ChoiceLevelRequestInfo: 简单响应
local function handleChoiceFightLevel(ctx)
    ctx.sendResponse(buildResponse(2414, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → CHOICE_FIGHT_LEVEL response\27[0m")
    return true
end

-- CMD 2415: START_FIGHT_LEVEL (开始战斗关卡)
-- SuccessFightRequestInfo: 简单响应
local function handleStartFightLevel(ctx)
    ctx.sendResponse(buildResponse(2415, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → START_FIGHT_LEVEL response\27[0m")
    return true
end

-- CMD 2416: LEAVE_FIGHT_LEVEL (离开战斗关卡)
local function handleLeaveFightLevel(ctx)
    ctx.sendResponse(buildResponse(2416, ctx.userId, 0, ""))
    print("\27[32m[Handler] → LEAVE_FIGHT_LEVEL response\27[0m")
    return true
end

-- CMD 2417: ARENA_SET_OWENR (设置竞技场主人)
local function handleArenaSetOwner(ctx)
    ctx.sendResponse(buildResponse(2417, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ARENA_SET_OWENR response\27[0m")
    return true
end

-- CMD 2418: ARENA_FIGHT_OWENR (挑战竞技场主人)
local function handleArenaFightOwner(ctx)
    ctx.sendResponse(buildResponse(2418, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ARENA_FIGHT_OWENR response\27[0m")
    return true
end

-- CMD 2419: ARENA_GET_INFO (获取竞技场信息)
-- ArenaInfo: flag(4) + hostID(4) + hostNick(16) + hostWins(4) + challengerID(4)
local function handleArenaGetInfo(ctx)
    local body = ""
    body = body .. writeUInt32BE(0)                     -- flag (0=无人占领)
    body = body .. writeUInt32BE(0)                     -- hostID
    body = body .. writeFixedString("", 16)             -- hostNick
    body = body .. writeUInt32BE(0)                     -- hostWins
    body = body .. writeUInt32BE(0)                     -- challengerID
    ctx.sendResponse(buildResponse(2419, ctx.userId, 0, body))
    print("\27[32m[Handler] → ARENA_GET_INFO response\27[0m")
    return true
end

-- CMD 2420: ARENA_UPFIGHT (竞技场升级战斗)
local function handleArenaUpfight(ctx)
    ctx.sendResponse(buildResponse(2420, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ARENA_UPFIGHT response\27[0m")
    return true
end

-- CMD 2421: FIGHT_SPECIAL_PET (特殊精灵战斗)
local function handleFightSpecialPet(ctx)
    ctx.sendResponse(buildResponse(2421, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → FIGHT_SPECIAL_PET response\27[0m")
    return true
end

-- CMD 2422: ARENA_OWENR_ACCE (竞技场主人接受)
local function handleArenaOwnerAcce(ctx)
    ctx.sendResponse(buildResponse(2422, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ARENA_OWENR_ACCE response\27[0m")
    return true
end

-- CMD 2423: ARENA_OWENR_OUT (竞技场主人退出)
local function handleArenaOwnerOut(ctx)
    ctx.sendResponse(buildResponse(2423, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ARENA_OWENR_OUT response\27[0m")
    return true
end

-- CMD 2424: OPEN_DARKPORTAL (打开暗黑传送门)
local function handleOpenDarkportal(ctx)
    ctx.sendResponse(buildResponse(2424, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → OPEN_DARKPORTAL response\27[0m")
    return true
end

-- CMD 2425: FIGHT_DARKPORTAL (暗黑传送门战斗)
local function handleFightDarkportal(ctx)
    ctx.sendResponse(buildResponse(2425, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → FIGHT_DARKPORTAL response\27[0m")
    return true
end

-- CMD 2426: LEAVE_DARKPORTAL (离开暗黑传送门)
local function handleLeaveDarkportal(ctx)
    ctx.sendResponse(buildResponse(2426, ctx.userId, 0, ""))
    print("\27[32m[Handler] → LEAVE_DARKPORTAL response\27[0m")
    return true
end

-- CMD 2428: FRESH_CHOICE_FIGHT_LEVEL (新手选择战斗关卡)
local function handleFreshChoiceFightLevel(ctx)
    ctx.sendResponse(buildResponse(2428, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → FRESH_CHOICE_FIGHT_LEVEL response\27[0m")
    return true
end

-- CMD 2429: FRESH_START_FIGHT_LEVEL (新手开始战斗关卡)
local function handleFreshStartFightLevel(ctx)
    ctx.sendResponse(buildResponse(2429, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → FRESH_START_FIGHT_LEVEL response\27[0m")
    return true
end

-- CMD 2430: FRESH_LEAVE_FIGHT_LEVEL (新手离开战斗关卡)
local function handleFreshLeaveFightLevel(ctx)
    ctx.sendResponse(buildResponse(2430, ctx.userId, 0, ""))
    print("\27[32m[Handler] → FRESH_LEAVE_FIGHT_LEVEL response\27[0m")
    return true
end

-- 注册所有处理器
function ArenaHandlers.register(Handlers)
    Handlers.register(2414, handleChoiceFightLevel)
    Handlers.register(2415, handleStartFightLevel)
    Handlers.register(2416, handleLeaveFightLevel)
    Handlers.register(2417, handleArenaSetOwner)
    Handlers.register(2418, handleArenaFightOwner)
    Handlers.register(2419, handleArenaGetInfo)
    Handlers.register(2420, handleArenaUpfight)
    Handlers.register(2421, handleFightSpecialPet)
    Handlers.register(2422, handleArenaOwnerAcce)
    Handlers.register(2423, handleArenaOwnerOut)
    Handlers.register(2424, handleOpenDarkportal)
    Handlers.register(2425, handleFightDarkportal)
    Handlers.register(2426, handleLeaveDarkportal)
    Handlers.register(2428, handleFreshChoiceFightLevel)
    Handlers.register(2429, handleFreshStartFightLevel)
    Handlers.register(2430, handleFreshLeaveFightLevel)
    print("\27[36m[Handlers] 竞技场命令处理器已注册\27[0m")
end

return ArenaHandlers
