-- 小游戏系统命令处理器
-- 包括: 加入游戏、游戏结束、FB游戏等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local GameHandlers = {}

-- CMD 5001: JOIN_GAME (加入游戏)
local function handleJoinGame(ctx)
    ctx.sendResponse(buildResponse(5001, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → JOIN_GAME response\27[0m")
    return true
end

-- CMD 5002: GAME_OVER (游戏结束)
local function handleGameOver(ctx)
    ctx.sendResponse(buildResponse(5002, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → GAME_OVER response\27[0m")
    return true
end

-- CMD 5003: LEAVE_GAME (离开游戏)
local function handleLeaveGame(ctx)
    ctx.sendResponse(buildResponse(5003, ctx.userId, 0, ""))
    print("\27[32m[Handler] → LEAVE_GAME response\27[0m")
    return true
end

-- CMD 5052: FB_GAME_OVER (FB游戏结束)
-- FBGameOverInfo
local function handleFBGameOver(ctx)
    local body = writeUInt32BE(0) ..      -- ret
                writeUInt32BE(0)          -- count = 0
    ctx.sendResponse(buildResponse(5052, ctx.userId, 0, body))
    print("\27[32m[Handler] → FB_GAME_OVER response\27[0m")
    return true
end

-- CMD 3201: EGG_GAME_PLAY (砸蛋游戏)
local function handleEggGamePlay(ctx)
    ctx.sendResponse(buildResponse(3201, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → EGG_GAME_PLAY response\27[0m")
    return true
end

-- CMD 2442: ML_FIG_BOSS (魔力BOSS战斗)
local function handleMLFigBoss(ctx)
    ctx.sendResponse(buildResponse(2442, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ML_FIG_BOSS response\27[0m")
    return true
end

-- CMD 2444: ML_STATE_BOSS (魔力BOSS状态)
local function handleMLStateBoss(ctx)
    ctx.sendResponse(buildResponse(2444, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ML_STATE_BOSS response\27[0m")
    return true
end

-- CMD 2445: ML_STEP_POS (魔力步骤位置)
local function handleMLStepPos(ctx)
    ctx.sendResponse(buildResponse(2445, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ML_STEP_POS response\27[0m")
    return true
end

-- CMD 2446: ML_GET_PRIZE (魔力获取奖励)
local function handleMLGetPrize(ctx)
    ctx.sendResponse(buildResponse(2446, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ML_GET_PRIZE response\27[0m")
    return true
end

-- 注册所有处理器
function GameHandlers.register(Handlers)
    Handlers.register(5001, handleJoinGame)
    Handlers.register(5002, handleGameOver)
    Handlers.register(5003, handleLeaveGame)
    Handlers.register(5052, handleFBGameOver)
    Handlers.register(3201, handleEggGamePlay)
    Handlers.register(2442, handleMLFigBoss)
    Handlers.register(2444, handleMLStateBoss)
    Handlers.register(2445, handleMLStepPos)
    Handlers.register(2446, handleMLGetPrize)
    print("\27[36m[Handlers] 小游戏命令处理器已注册\27[0m")
end

return GameHandlers
