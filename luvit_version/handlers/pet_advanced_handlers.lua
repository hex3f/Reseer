-- 精灵高级功能命令处理器
-- 包括: 精灵进化、孵化、技能学习、融合等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local PetAdvancedHandlers = {}

-- CMD 2302: MODIFY_PET_NAME (修改精灵名字)
local function handleModifyPetName(ctx)
    ctx.sendResponse(buildResponse(2302, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → MODIFY_PET_NAME response\27[0m")
    return true
end

-- CMD 2307: PET_STUDY_SKILL (精灵学习技能)
local function handlePetStudySkill(ctx)
    ctx.sendResponse(buildResponse(2307, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_STUDY_SKILL response\27[0m")
    return true
end

-- CMD 2308: PET_DEFAULT (设置默认精灵)
local function handlePetDefault(ctx)
    ctx.sendResponse(buildResponse(2308, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_DEFAULT response\27[0m")
    return true
end

-- CMD 2310: PET_ONE_CURE (单个精灵治疗)
local function handlePetOneCure(ctx)
    ctx.sendResponse(buildResponse(2310, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_ONE_CURE response\27[0m")
    return true
end

-- CMD 2311: PET_COLLECT (精灵收集)
local function handlePetCollect(ctx)
    ctx.sendResponse(buildResponse(2311, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_COLLECT response\27[0m")
    return true
end

-- CMD 2312: PET_SKILL_SWICTH (精灵技能切换)
local function handlePetSkillSwitch(ctx)
    ctx.sendResponse(buildResponse(2312, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_SKILL_SWICTH response\27[0m")
    return true
end

-- CMD 2313: IS_COLLECT (是否收集)
local function handleIsCollect(ctx)
    local body = writeUInt32BE(1)  -- 已收集
    ctx.sendResponse(buildResponse(2313, ctx.userId, 0, body))
    print("\27[32m[Handler] → IS_COLLECT response\27[0m")
    return true
end

-- CMD 2314: PET_EVOLVTION (精灵进化)
local function handlePetEvolution(ctx)
    ctx.sendResponse(buildResponse(2314, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_EVOLVTION response\27[0m")
    return true
end

-- CMD 2315: PET_HATCH (精灵孵化)
local function handlePetHatch(ctx)
    ctx.sendResponse(buildResponse(2315, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_HATCH response\27[0m")
    return true
end

-- CMD 2316: PET_HATCH_GET (获取孵化精灵)
local function handlePetHatchGet(ctx)
    ctx.sendResponse(buildResponse(2316, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_HATCH_GET response\27[0m")
    return true
end

-- CMD 2318: PET_SET_EXP (设置精灵经验)
local function handlePetSetExp(ctx)
    ctx.sendResponse(buildResponse(2318, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_SET_EXP response\27[0m")
    return true
end

-- CMD 2319: PET_GET_EXP (获取精灵经验)
local function handlePetGetExp(ctx)
    local body = writeUInt32BE(0)  -- exp
    ctx.sendResponse(buildResponse(2319, ctx.userId, 0, body))
    print("\27[32m[Handler] → PET_GET_EXP response\27[0m")
    return true
end

-- CMD 2320: PET_ROWEI_LIST (精灵入围列表)
local function handlePetRoweiList(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(2320, ctx.userId, 0, body))
    print("\27[32m[Handler] → PET_ROWEI_LIST response\27[0m")
    return true
end

-- CMD 2321: PET_ROWEI (精灵入围)
local function handlePetRowei(ctx)
    ctx.sendResponse(buildResponse(2321, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_ROWEI response\27[0m")
    return true
end

-- CMD 2322: PET_RETRIEVE (精灵找回)
local function handlePetRetrieve(ctx)
    ctx.sendResponse(buildResponse(2322, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_RETRIEVE response\27[0m")
    return true
end

-- CMD 2323: PET_ROOM_SHOW (精灵房间展示)
local function handlePetRoomShow(ctx)
    ctx.sendResponse(buildResponse(2323, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_ROOM_SHOW response\27[0m")
    return true
end

-- CMD 2324: PET_ROOM_LIST (精灵房间列表)
local function handlePetRoomList(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(2324, ctx.userId, 0, body))
    print("\27[32m[Handler] → PET_ROOM_LIST response\27[0m")
    return true
end

-- CMD 2325: PET_ROOM_INFO (精灵房间信息)
-- RoomPetInfo
local function handlePetRoomInfo(ctx)
    -- 返回空的精灵房间信息
    local body = writeUInt32BE(0)  -- ownerId = 0 表示没有
    ctx.sendResponse(buildResponse(2325, ctx.userId, 0, body))
    print("\27[32m[Handler] → PET_ROOM_INFO response\27[0m")
    return true
end

-- CMD 2326: USE_PET_ITEM_OUT_OF_FIGHT (战斗外使用精灵道具)
-- UsePetItemOutOfFightInfo
local function handleUsePetItemOutOfFight(ctx)
    ctx.sendResponse(buildResponse(2326, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → USE_PET_ITEM_OUT_OF_FIGHT response\27[0m")
    return true
end

-- CMD 2327: USE_SPEEDUP_ITEM (使用加速道具)
local function handleUseSpeedupItem(ctx)
    ctx.sendResponse(buildResponse(2327, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → USE_SPEEDUP_ITEM response\27[0m")
    return true
end

-- CMD 2328: Skill_Sort (技能排序)
local function handleSkillSort(ctx)
    ctx.sendResponse(buildResponse(2328, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → Skill_Sort response\27[0m")
    return true
end

-- CMD 2329: USE_AUTO_FIGHT_ITEM (使用自动战斗道具)
local function handleUseAutoFightItem(ctx)
    ctx.sendResponse(buildResponse(2329, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → USE_AUTO_FIGHT_ITEM response\27[0m")
    return true
end

-- CMD 2330: ON_OFF_AUTO_FIGHT (开关自动战斗)
local function handleOnOffAutoFight(ctx)
    ctx.sendResponse(buildResponse(2330, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ON_OFF_AUTO_FIGHT response\27[0m")
    return true
end

-- CMD 2331: USE_ENERGY_XISHOU (使用能量吸收)
local function handleUseEnergyXishou(ctx)
    ctx.sendResponse(buildResponse(2331, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → USE_ENERGY_XISHOU response\27[0m")
    return true
end

-- CMD 2332: USE_STUDY_ITEM (使用学习道具)
local function handleUseStudyItem(ctx)
    ctx.sendResponse(buildResponse(2332, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → USE_STUDY_ITEM response\27[0m")
    return true
end

-- CMD 2343: PET_RESET_NATURE (重置精灵性格)
local function handlePetResetNature(ctx)
    ctx.sendResponse(buildResponse(2343, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_RESET_NATURE response\27[0m")
    return true
end

-- CMD 2351: PET_FUSION (精灵融合)
-- PetFusionInfo
local function handlePetFusion(ctx)
    ctx.sendResponse(buildResponse(2351, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → PET_FUSION response\27[0m")
    return true
end

-- CMD 2352: GET_SOUL_BEAD_BUF (获取魂珠缓存)
-- HatchTaskBufInfo
local function handleGetSoulBeadBuf(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(2352, ctx.userId, 0, body))
    print("\27[32m[Handler] → GET_SOUL_BEAD_BUF response\27[0m")
    return true
end

-- CMD 2353: SET_SOUL_BEAD_BUF (设置魂珠缓存)
local function handleSetSoulBeadBuf(ctx)
    ctx.sendResponse(buildResponse(2353, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → SET_SOUL_BEAD_BUF response\27[0m")
    return true
end

-- CMD 2356: GET_SOULBEAD_STATUS (获取魂珠状态)
local function handleGetSoulBeadStatus(ctx)
    local body = writeUInt32BE(0)  -- status
    ctx.sendResponse(buildResponse(2356, ctx.userId, 0, body))
    print("\27[32m[Handler] → GET_SOULBEAD_STATUS response\27[0m")
    return true
end

-- CMD 2357: TRANSFORM_SOULBEAD (转化魂珠)
local function handleTransformSoulBead(ctx)
    ctx.sendResponse(buildResponse(2357, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → TRANSFORM_SOULBEAD response\27[0m")
    return true
end

-- CMD 2358: SOULBEAD_TO_PET (魂珠转精灵)
local function handleSoulBeadToPet(ctx)
    ctx.sendResponse(buildResponse(2358, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → SOULBEAD_TO_PET response\27[0m")
    return true
end

-- 注册所有处理器
function PetAdvancedHandlers.register(Handlers)
    Handlers.register(2302, handleModifyPetName)
    Handlers.register(2307, handlePetStudySkill)
    Handlers.register(2308, handlePetDefault)
    Handlers.register(2310, handlePetOneCure)
    Handlers.register(2311, handlePetCollect)
    Handlers.register(2312, handlePetSkillSwitch)
    Handlers.register(2313, handleIsCollect)
    Handlers.register(2314, handlePetEvolution)
    Handlers.register(2315, handlePetHatch)
    Handlers.register(2316, handlePetHatchGet)
    Handlers.register(2318, handlePetSetExp)
    Handlers.register(2319, handlePetGetExp)
    Handlers.register(2320, handlePetRoweiList)
    Handlers.register(2321, handlePetRowei)
    Handlers.register(2322, handlePetRetrieve)
    Handlers.register(2323, handlePetRoomShow)
    Handlers.register(2324, handlePetRoomList)
    Handlers.register(2325, handlePetRoomInfo)
    Handlers.register(2326, handleUsePetItemOutOfFight)
    Handlers.register(2327, handleUseSpeedupItem)
    Handlers.register(2328, handleSkillSort)
    Handlers.register(2329, handleUseAutoFightItem)
    Handlers.register(2330, handleOnOffAutoFight)
    Handlers.register(2331, handleUseEnergyXishou)
    Handlers.register(2332, handleUseStudyItem)
    Handlers.register(2343, handlePetResetNature)
    Handlers.register(2351, handlePetFusion)
    Handlers.register(2352, handleGetSoulBeadBuf)
    Handlers.register(2353, handleSetSoulBeadBuf)
    Handlers.register(2356, handleGetSoulBeadStatus)
    Handlers.register(2357, handleTransformSoulBead)
    Handlers.register(2358, handleSoulBeadToPet)
    print("\27[36m[Handlers] 精灵高级功能命令处理器已注册\27[0m")
end

return PetAdvancedHandlers
