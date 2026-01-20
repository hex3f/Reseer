-- 精灵高级功能命令处理器
-- 包括: 精灵进化、孵化、技能学习、融合等

local BinaryWriter = require('utils/binary_writer')
local BinaryReader = require('utils/binary_reader')
local ResponseBuilder = require('utils/response_builder')

local PetAdvancedHandlers = {}

-- CMD 2302: MODIFY_PET_NAME (修改精灵名字)
-- 请求: catchTime(4) + newName(16)
local function handleModifyPetName(ctx)
    local reader = BinaryReader.new(ctx.body)
    local catchTime = 0
    local newName = ""
    
    if reader:getRemaining() ~= "" then
        catchTime = reader:readUInt32BE()
    end
    if #ctx.body >= 20 then
        newName = string.sub(ctx.body, 5, 20)
        -- 去除尾部空字符
        newName = newName:gsub("%z+$", "")
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    if user.pets and catchTime > 0 then
        for _, pet in ipairs(user.pets) do
            if pet.catchTime == catchTime then
                pet.name = newName
                ctx.saveUserDB()
                print(string.format("\27[32m[Handler] PET_NAME changed to '%s'\27[0m", newName))
                break
            end
        end
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2302, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → MODIFY_PET_NAME response\27[0m")
    return true
end

-- CMD 2307: PET_STUDY_SKILL (精灵学习技能)
-- 请求: catchTime(4) + skillId(4)
local function handlePetStudySkill(ctx)
    local reader = BinaryReader.new(ctx.body)
    local catchTime = 0
    local skillId = 0
    
    if reader:getRemaining() ~= "" then
        catchTime = reader:readUInt32BE()
    end
    if reader:getRemaining() ~= "" then
        skillId = reader:readUInt32BE()
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    if user.pets and catchTime > 0 and skillId > 0 then
        for _, pet in ipairs(user.pets) do
            if pet.catchTime == catchTime then
                pet.skills = pet.skills or {}
                -- 检查是否已学习
                local found = false
                for _, sk in ipairs(pet.skills) do
                    if sk.id == skillId then found = true break end
                end
                if not found then
                    table.insert(pet.skills, {id = skillId, pp = 20})
                    ctx.saveUserDB()
                    print(string.format("\27[32m[Handler] Pet learned skill %d\27[0m", skillId))
                end
                break
            end
        end
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2307, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_STUDY_SKILL response\27[0m")
    return true
end

-- CMD 2308: PET_DEFAULT (设置默认精灵)
-- 请求: catchTime(4)
local function handlePetDefault(ctx)
    local reader = BinaryReader.new(ctx.body)
    local catchTime = 0
    
    if reader:getRemaining() ~= "" then
        catchTime = reader:readUInt32BE()
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    if user.pets and catchTime > 0 then
        for _, pet in ipairs(user.pets) do
            if pet.catchTime == catchTime then
                user.currentPetId = pet.id
                user.catchId = catchTime
                ctx.saveUserDB()
                print(string.format("\27[32m[Handler] Default pet set to %d\27[0m", pet.id))
                break
            end
        end
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2308, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_DEFAULT response\27[0m")
    return true
end

-- CMD 2310: PET_ONE_CURE (单个精灵治疗)
-- 请求: catchTime(4)
-- 恢复精灵HP到最大值
local function handlePetOneCure(ctx)
    local reader = BinaryReader.new(ctx.body)
    local catchTime = 0
    
    if reader:getRemaining() ~= "" then
        catchTime = reader:readUInt32BE()
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    if user.pets and catchTime > 0 then
        for _, pet in ipairs(user.pets) do
            if pet.catchTime == catchTime then
                pet.hp = pet.maxHp or pet.hp or 100
                ctx.saveUserDB()
                print(string.format("\27[32m[Handler] Pet cured to HP=%d\27[0m", pet.hp))
                break
            end
        end
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2310, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_ONE_CURE response\27[0m")
    return true
end

-- CMD 2311: PET_COLLECT (精灵收集)
local function handlePetCollect(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2311, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_COLLECT response\27[0m")
    return true
end

-- CMD 2312: PET_SKILL_SWICTH (精灵技能切换)
local function handlePetSkillSwitch(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2312, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_SKILL_SWICTH response\27[0m")
    return true
end

-- CMD 2313: IS_COLLECT (是否收集)
local function handleIsCollect(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(1)  -- 已收集
    ctx.sendResponse(ResponseBuilder.build(2313, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → IS_COLLECT response\27[0m")
    return true
end

-- CMD 2314: PET_EVOLVTION (精灵进化)
local function handlePetEvolution(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2314, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_EVOLVTION response\27[0m")
    return true
end

-- CMD 2315: PET_HATCH (精灵孵化)
local function handlePetHatch(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2315, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_HATCH response\27[0m")
    return true
end

-- CMD 2316: PET_HATCH_GET (获取孵化精灵)
-- 官服响应: 16 bytes 全0 (无孵化中的精灵)
local function handlePetHatchGet(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- 状态/数量
    writer:writeUInt32BE(0)  -- 精灵ID
    writer:writeUInt32BE(0)  -- 孵化时间
    writer:writeUInt32BE(0)  -- 剩余时间
    ctx.sendResponse(ResponseBuilder.build(2316, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_HATCH_GET response (16 bytes)\27[0m")
    return true
end

-- CMD 2318: PET_SET_EXP (从经验池分配经验给宠物)
-- 请求: catchTime(4) + expAmount(4) - 要分配给宠物的经验值
-- 响应: newPoolExp(4) - 返回经验池剩余经验
local function handlePetSetExp(ctx)
    local reader = BinaryReader.new(ctx.body)
    local catchTime = 0
    local expAmount = 0
    
    if reader:getRemaining() ~= "" then
        catchTime = reader:readUInt32BE()
    end
    if reader:getRemaining() ~= "" then
        expAmount = reader:readUInt32BE()
    end
    
    local user = ctx.getOrCreateUser(ctx.userId)
    
    -- 获取当前经验池
    local currentPool = user.expPool or 0
    
    -- 从经验池扣除经验
    local newPoolExp = currentPool - expAmount
    if newPoolExp < 0 then newPoolExp = 0 end
    user.expPool = newPoolExp
    
    -- 同时给对应宠物增加经验 (如果找到的话)
    if user.pets and catchTime > 0 then
        for petIdStr, petData in pairs(user.pets) do
            if petData.catchTime == catchTime then
                petData.exp = (petData.exp or 0) + expAmount
                break
            end
        end
    end
    
    ctx.saveUser(ctx.userId, user)
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(newPoolExp)
    ctx.sendResponse(ResponseBuilder.build(2318, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → PET_SET_EXP 分配 %d 经验给宠物, 经验池剩余 %d\27[0m", expAmount, newPoolExp))
    return true
end

-- CMD 2319: PET_GET_EXP (获取经验池经验)
-- 官服响应: exp(4) - 经验池的总经验值
local function handlePetGetExp(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local expPool = user.expPool or 0
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(expPool)
    ctx.sendResponse(ResponseBuilder.build(2319, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → PET_GET_EXP 经验池=%d\27[0m", expPool))
    return true
end

-- CMD 2320: PET_ROWEI_LIST (精灵入围列表)
local function handlePetRoweiList(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(ResponseBuilder.build(2320, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_ROWEI_LIST response\27[0m")
    return true
end

-- CMD 2321: PET_ROWEI (精灵入围)
local function handlePetRowei(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2321, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_ROWEI response\27[0m")
    return true
end

-- CMD 2322: PET_RETRIEVE (精灵找回)
local function handlePetRetrieve(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2322, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_RETRIEVE response\27[0m")
    return true
end

-- CMD 2323: PET_ROOM_SHOW (精灵房间展示)
local function handlePetRoomShow(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2323, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_ROOM_SHOW response\27[0m")
    return true
end

-- CMD 2324: PET_ROOM_LIST (精灵房间列表)
local function handlePetRoomList(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(ResponseBuilder.build(2324, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_ROOM_LIST response\27[0m")
    return true
end

-- CMD 2325: PET_ROOM_INFO (精灵房间信息)
local function handlePetRoomInfo(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- ownerId = 0 表示没有
    ctx.sendResponse(ResponseBuilder.build(2325, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_ROOM_INFO response\27[0m")
    return true
end

-- CMD 2326: USE_PET_ITEM_OUT_OF_FIGHT (战斗外使用精灵道具)
local function handleUsePetItemOutOfFight(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2326, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → USE_PET_ITEM_OUT_OF_FIGHT response\27[0m")
    return true
end

-- CMD 2327: USE_SPEEDUP_ITEM (使用加速道具)
local function handleUseSpeedupItem(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2327, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → USE_SPEEDUP_ITEM response\27[0m")
    return true
end

-- CMD 2328: Skill_Sort (技能排序)
local function handleSkillSort(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2328, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → Skill_Sort response\27[0m")
    return true
end

-- CMD 2329: USE_AUTO_FIGHT_ITEM (使用自动战斗道具)
local function handleUseAutoFightItem(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2329, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → USE_AUTO_FIGHT_ITEM response\27[0m")
    return true
end

-- CMD 2330: ON_OFF_AUTO_FIGHT (开关自动战斗)
local function handleOnOffAutoFight(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2330, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → ON_OFF_AUTO_FIGHT response\27[0m")
    return true
end

-- CMD 2331: USE_ENERGY_XISHOU (使用能量吸收)
local function handleUseEnergyXishou(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2331, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → USE_ENERGY_XISHOU response\27[0m")
    return true
end

-- CMD 2332: USE_STUDY_ITEM (使用学习道具)
local function handleUseStudyItem(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2332, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → USE_STUDY_ITEM response\27[0m")
    return true
end

-- CMD 2343: PET_RESET_NATURE (重置精灵性格)
local function handlePetResetNature(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2343, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_RESET_NATURE response\27[0m")
    return true
end

-- CMD 2351: PET_FUSION (精灵融合)
local function handlePetFusion(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2351, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → PET_FUSION response\27[0m")
    return true
end

-- CMD 2352: GET_SOUL_BEAD_BUF (获取魂珠缓存)
local function handleGetSoulBeadBuf(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(ResponseBuilder.build(2352, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → GET_SOUL_BEAD_BUF response\27[0m")
    return true
end

-- CMD 2353: SET_SOUL_BEAD_BUF (设置魂珠缓存)
local function handleSetSoulBeadBuf(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2353, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → SET_SOUL_BEAD_BUF response\27[0m")
    return true
end

-- CMD 2356: GET_SOULBEAD_STATUS (获取魂珠状态)
local function handleGetSoulBeadStatus(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- status
    ctx.sendResponse(ResponseBuilder.build(2356, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → GET_SOULBEAD_STATUS response\27[0m")
    return true
end

-- CMD 2357: TRANSFORM_SOULBEAD (转化魂珠)
local function handleTransformSoulBead(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2357, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TRANSFORM_SOULBEAD response\27[0m")
    return true
end

-- CMD 2358: SOULBEAD_TO_PET (魂珠转精灵)
local function handleSoulBeadToPet(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2358, ctx.userId, 0, writer:toString()))
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
