-- 战队系统命令处理器
-- 包括: 创建战队、加入战队、战队信息等

local BinaryWriter = require('utils/binary_writer')
local BinaryReader = require('utils/binary_reader')
local ResponseBuilder = require('utils/response_builder')

local TeamHandlers = {}

-- CMD 2910: TEAM_CREATE (创建战队)
-- 创建战队并保存到用户数据
local function handleTeamCreate(ctx)
    local reader = BinaryReader.new(ctx.body)
    local teamName = ""
    local interest = 0
    
    -- TODO: parse team name and settings from body
    
    local user = ctx.getOrCreateUser(ctx.userId)
    local teamId = 10000 + ctx.userId -- 简化: 使用userId生成teamId
    
    user.teamInfo = {
        id = teamId,
        priv = 4,  -- creator privilege
        isShow = 1,
        logoBg = 1,
        logoIcon = 1,
        logoColor = 0xFFFF00,
        txtColor = 0xFFFFFF,
        logoWord = "",
        allContribution = 0,
        canExContribution = 0,
        coreCount = 0
    }
    ctx.saveUserDB()
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- ret (0=成功)
    writer:writeUInt32BE(teamId)
    ctx.sendResponse(ResponseBuilder.build(2910, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → TEAM_CREATE id=%d (saved)\27[0m", teamId))
    return true
end

-- CMD 2911: TEAM_ADD (申请加入战队)
local function handleTeamAdd(ctx)
    local teamId = 0
    if #ctx.body >= 4 then
        local reader = BinaryReader.new(ctx.body)
        teamId = reader:readUInt32BE()
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- ret (0=成功)
    writer:writeUInt32BE(teamId) -- teamID
    
    ctx.sendResponse(ResponseBuilder.build(2911, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → TEAM_ADD %d response\27[0m", teamId))
    return true
end

-- CMD 2912: TEAM_ANSWER (回复战队申请)
local function handleTeamAnswer(ctx)
    ctx.sendResponse(ResponseBuilder.build(2912, ctx.userId, 0, ""))
    print("\27[32m[Handler] → TEAM_ANSWER response\27[0m")
    return true
end

-- CMD 2913: TEAM_INFORM (战队通知)
local function handleTeamInform(ctx)
    ctx.sendResponse(ResponseBuilder.build(2913, ctx.userId, 0, ""))
    print("\27[32m[Handler] → TEAM_INFORM response\27[0m")
    return true
end

-- CMD 2914: TEAM_QUIT (退出战队)
-- 清除用户的战队信息
local function handleTeamQuit(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    user.teamInfo = nil
    ctx.saveUserDB()
    
    ctx.sendResponse(ResponseBuilder.build(2914, ctx.userId, 0, ""))
    print("\27[32m[Handler] → TEAM_QUIT (saved)\27[0m")
    return true
end

-- CMD 2917: TEAM_GET_INFO (获取战队信息)
-- 返回用户保存的战队信息
local function handleTeamGetInfo(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local team = user.teamInfo or {}
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(team.id or 0)            -- teamID
    writer:writeUInt32BE(0)                       -- leader
    writer:writeUInt32BE(0)                       -- superCoreNum
    writer:writeUInt32BE(team.memberCount or 1)   -- memberCount
    writer:writeUInt32BE(0)                       -- interest
    writer:writeUInt32BE(0)                       -- joinFlag
    writer:writeUInt32BE(team.isShow or 0)        -- visitFlag
    writer:writeUInt32BE(team.exp or 0)           -- exp
    writer:writeUInt32BE(team.score or 0)         -- score
    writer:writeStringFixed(team.name or "", 16)  -- name
    writer:writeStringFixed("", 60)               -- slogan
    writer:writeStringFixed("", 60)               -- notice
    writer:writeUInt16BE(team.logoBg or 0)        -- logoBg
    writer:writeUInt16BE(team.logoIcon or 0)      -- logoIcon
    writer:writeUInt16BE(team.logoColor or 0)     -- logoColor
    writer:writeUInt16BE(team.txtColor or 0)      -- txtColor
    writer:writeStringFixed(team.logoWord or "", 4) -- logoWord
    
    ctx.sendResponse(ResponseBuilder.build(2917, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → TEAM_GET_INFO id=%d\27[0m", team.id or 0))
    return true
end

-- CMD 2918: TEAM_GET_MEMBER_LIST (获取战队成员列表)
local function handleTeamGetMemberList(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- teamID
    writer:writeUInt32BE(0)   -- superCoreNum
    writer:writeUInt32BE(0)      -- count = 0
    
    ctx.sendResponse(ResponseBuilder.build(2918, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_GET_MEMBER_LIST response\27[0m")
    return true
end

-- CMD 2928: TEAM_GET_LOGO_INFO (获取战队徽章信息)
local function handleTeamGetLogoInfo(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt16BE(0)      -- logoBg
    writer:writeUInt16BE(0)       -- logoIcon
    writer:writeUInt16BE(0)       -- logoColor
    writer:writeUInt16BE(0)       -- txtColor
    writer:writeStringFixed("", 4)   -- logoWord
    
    ctx.sendResponse(ResponseBuilder.build(2928, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEAM_GET_LOGO_INFO response\27[0m")
    return true
end

-- CMD 2929: TEAM_CHAT (战队聊天)
local function handleTeamChat(ctx)
    ctx.sendResponse(ResponseBuilder.build(2929, ctx.userId, 0, ""))
    print("\27[32m[Handler] → TEAM_CHAT response\27[0m")
    return true
end

-- CMD 2962: ARM_UP_WORK (军团工作)
local function handleArmUpWork(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2962, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → ARM_UP_WORK response\27[0m")
    return true
end

-- CMD 2963: ARM_UP_DONATE (军团捐献)
local function handleArmUpDonate(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(2963, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → ARM_UP_DONATE response\27[0m")
    return true
end

-- 注册所有处理器
function TeamHandlers.register(Handlers)
    Handlers.register(2910, handleTeamCreate)
    Handlers.register(2911, handleTeamAdd)
    Handlers.register(2912, handleTeamAnswer)
    Handlers.register(2913, handleTeamInform)
    Handlers.register(2914, handleTeamQuit)
    Handlers.register(2917, handleTeamGetInfo)
    Handlers.register(2918, handleTeamGetMemberList)
    Handlers.register(2928, handleTeamGetLogoInfo)
    Handlers.register(2929, handleTeamChat)
    Handlers.register(2962, handleArmUpWork)
    Handlers.register(2963, handleArmUpDonate)
    print("\27[36m[Handlers] 战队命令处理器已注册\27[0m")
end

return TeamHandlers
