-- 新功能/扩展系统命令处理器
-- 包括: 皮肤、成就、签到、钓鱼等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local XinHandlers = {}

-- CMD 50001: XIN_SETSKIN (设置皮肤)
local function handleXinSetSkin(ctx)
    ctx.sendResponse(buildResponse(50001, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → XIN_SETSKIN response\27[0m")
    return true
end

-- CMD 50003: GET_ONE_PET_SKIN_INFO (获取单个精灵皮肤信息)
local function handleGetOnePetSkinInfo(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(50003, ctx.userId, 0, body))
    print("\27[32m[Handler] → GET_ONE_PET_SKIN_INFO response\27[0m")
    return true
end

-- CMD 50005: XIN_MATERIALS (材料)
local function handleXinMaterials(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(50005, ctx.userId, 0, body))
    print("\27[32m[Handler] → XIN_MATERIALS response\27[0m")
    return true
end

-- CMD 50006: XIN_FUSION (融合)
-- PetFusionInfo
local function handleXinFusion(ctx)
    ctx.sendResponse(buildResponse(50006, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → XIN_FUSION response\27[0m")
    return true
end

-- CMD 50007: XIN_SET_QUADRUPLE_EXE_TIME (设置四倍执行时间)
local function handleXinSetQuadrupleExeTime(ctx)
    ctx.sendResponse(buildResponse(50007, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → XIN_SET_QUADRUPLE_EXE_TIME response\27[0m")
    return true
end

-- CMD 50009: XIN_SIGN (签到)
local function handleXinSign(ctx)
    ctx.sendResponse(buildResponse(50009, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → XIN_SIGN response\27[0m")
    return true
end

-- CMD 50010: XIN_GET_ACHIEVEMENTS (获取成就)
local function handleXinGetAchievements(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(50010, ctx.userId, 0, body))
    print("\27[32m[Handler] → XIN_GET_ACHIEVEMENTS response\27[0m")
    return true
end

-- CMD 50011: XIN_SET_ACHIEVEMENT (设置成就)
local function handleXinSetAchievement(ctx)
    ctx.sendResponse(buildResponse(50011, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → XIN_SET_ACHIEVEMENT response\27[0m")
    return true
end

-- CMD 50012: XIN_BATCH (批量操作)
local function handleXinBatch(ctx)
    ctx.sendResponse(buildResponse(50012, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → XIN_BATCH response\27[0m")
    return true
end

-- CMD 50013: XIN_FISH (钓鱼)
local function handleXinFish(ctx)
    ctx.sendResponse(buildResponse(50013, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → XIN_FISH response\27[0m")
    return true
end

-- CMD 50014: XIN_USE (使用)
local function handleXinUse(ctx)
    ctx.sendResponse(buildResponse(50014, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → XIN_USE response\27[0m")
    return true
end

-- CMD 50015: XIN_PETBAG (精灵背包)
local function handleXinPetBag(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(50015, ctx.userId, 0, body))
    print("\27[32m[Handler] → XIN_PETBAG response\27[0m")
    return true
end

-- CMD 52102: XIN_CHAT (聊天)
-- ChatInfo
local function handleXinChat(ctx)
    ctx.sendResponse(buildResponse(52102, ctx.userId, 0, ""))
    print("\27[32m[Handler] → XIN_CHAT response\27[0m")
    return true
end

-- CMD 2393: LEIYI_TRAIN_GET_STATUS (雷伊训练获取状态)
local function handleLeiyiTrainGetStatus(ctx)
    local body = writeUInt32BE(0)  -- status
    ctx.sendResponse(buildResponse(2393, ctx.userId, 0, body))
    print("\27[32m[Handler] → LEIYI_TRAIN_GET_STATUS response\27[0m")
    return true
end

-- 注册所有处理器
function XinHandlers.register(Handlers)
    Handlers.register(50001, handleXinSetSkin)
    Handlers.register(50003, handleGetOnePetSkinInfo)
    Handlers.register(50005, handleXinMaterials)
    Handlers.register(50006, handleXinFusion)
    Handlers.register(50007, handleXinSetQuadrupleExeTime)
    Handlers.register(50009, handleXinSign)
    Handlers.register(50010, handleXinGetAchievements)
    Handlers.register(50011, handleXinSetAchievement)
    Handlers.register(50012, handleXinBatch)
    Handlers.register(50013, handleXinFish)
    Handlers.register(50014, handleXinUse)
    Handlers.register(50015, handleXinPetBag)
    Handlers.register(52102, handleXinChat)
    Handlers.register(2393, handleLeiyiTrainGetStatus)
    print("\27[36m[Handlers] 新功能命令处理器已注册\27[0m")
end

return XinHandlers
