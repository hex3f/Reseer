-- 战队系统命令处理器
-- 包括: 创建战队、加入战队、战队信息等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local TeamHandlers = {}

-- CMD 2910: TEAM_CREATE (创建战队)
local function handleTeamCreate(ctx)
    local body = writeUInt32BE(0) ..  -- ret (0=成功)
                writeUInt32BE(1)      -- teamID
    ctx.sendResponse(buildResponse(2910, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEAM_CREATE response\27[0m")
    return true
end

-- CMD 2911: TEAM_ADD (申请加入战队)
-- TeamAddInfo: ret(4) + teamID(4)
local function handleTeamAdd(ctx)
    local teamId = 0
    if #ctx.body >= 4 then
        teamId = readUInt32BE(ctx.body, 1)
    end
    local body = writeUInt32BE(0) ..      -- ret (0=成功)
                writeUInt32BE(teamId)     -- teamID
    ctx.sendResponse(buildResponse(2911, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → TEAM_ADD %d response\27[0m", teamId))
    return true
end

-- CMD 2912: TEAM_ANSWER (回复战队申请)
local function handleTeamAnswer(ctx)
    ctx.sendResponse(buildResponse(2912, ctx.userId, 0, ""))
    print("\27[32m[Handler] → TEAM_ANSWER response\27[0m")
    return true
end

-- CMD 2913: TEAM_INFORM (战队通知)
-- TeamInformInfo: 简单响应
local function handleTeamInform(ctx)
    ctx.sendResponse(buildResponse(2913, ctx.userId, 0, ""))
    print("\27[32m[Handler] → TEAM_INFORM response\27[0m")
    return true
end

-- CMD 2914: TEAM_QUIT (退出战队)
local function handleTeamQuit(ctx)
    ctx.sendResponse(buildResponse(2914, ctx.userId, 0, ""))
    print("\27[32m[Handler] → TEAM_QUIT response\27[0m")
    return true
end

-- CMD 2917: TEAM_GET_INFO (获取战队信息)
-- SimpleTeamInfo: teamID(4) + leader(4) + superCoreNum(4) + memberCount(4) + interest(4) + joinFlag(4) + visitFlag(4) + exp(4) + score(4) + name(16) + slogan(60) + notice(60) + logoBg(2) + logoIcon(2) + logoColor(2) + txtColor(2) + logoWord(4)
local function handleTeamGetInfo(ctx)
    local body = ""
    body = body .. writeUInt32BE(0)              -- teamID (0=无战队)
    body = body .. writeUInt32BE(0)              -- leader
    body = body .. writeUInt32BE(0)              -- superCoreNum
    body = body .. writeUInt32BE(0)              -- memberCount
    body = body .. writeUInt32BE(0)              -- interest
    body = body .. writeUInt32BE(0)              -- joinFlag
    body = body .. writeUInt32BE(0)              -- visitFlag
    body = body .. writeUInt32BE(0)              -- exp
    body = body .. writeUInt32BE(0)              -- score
    body = body .. writeFixedString("", 16)      -- name
    body = body .. writeFixedString("", 60)      -- slogan
    body = body .. writeFixedString("", 60)      -- notice
    body = body .. writeUInt16BE(0)              -- logoBg
    body = body .. writeUInt16BE(0)              -- logoIcon
    body = body .. writeUInt16BE(0)              -- logoColor
    body = body .. writeUInt16BE(0)              -- txtColor
    body = body .. writeFixedString("", 4)       -- logoWord
    ctx.sendResponse(buildResponse(2917, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEAM_GET_INFO response\27[0m")
    return true
end

-- CMD 2918: TEAM_GET_MEMBER_LIST (获取战队成员列表)
-- TeamMemberListInfo: teamID(4) + superCoreNum(4) + count(4) + [TeamMemberInfo]...
local function handleTeamGetMemberList(ctx)
    local body = writeUInt32BE(0) ..  -- teamID
                writeUInt32BE(0) ..   -- superCoreNum
                writeUInt32BE(0)      -- count = 0
    ctx.sendResponse(buildResponse(2918, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEAM_GET_MEMBER_LIST response\27[0m")
    return true
end

-- CMD 2928: TEAM_GET_LOGO_INFO (获取战队徽章信息)
-- TeamLogoInfo: logoBg(2) + logoIcon(2) + logoColor(2) + txtColor(2) + logoWord(4)
local function handleTeamGetLogoInfo(ctx)
    local body = writeUInt16BE(0) ..      -- logoBg
                writeUInt16BE(0) ..       -- logoIcon
                writeUInt16BE(0) ..       -- logoColor
                writeUInt16BE(0) ..       -- txtColor
                writeFixedString("", 4)   -- logoWord
    ctx.sendResponse(buildResponse(2928, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEAM_GET_LOGO_INFO response\27[0m")
    return true
end

-- CMD 2929: TEAM_CHAT (战队聊天)
-- TeamChatInfo: 简单响应
local function handleTeamChat(ctx)
    ctx.sendResponse(buildResponse(2929, ctx.userId, 0, ""))
    print("\27[32m[Handler] → TEAM_CHAT response\27[0m")
    return true
end

-- CMD 2962: ARM_UP_WORK (军团工作)
-- WorkInfo: 简单响应
local function handleArmUpWork(ctx)
    ctx.sendResponse(buildResponse(2962, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ARM_UP_WORK response\27[0m")
    return true
end

-- CMD 2963: ARM_UP_DONATE (军团捐献)
-- DonateInfo: 简单响应
local function handleArmUpDonate(ctx)
    ctx.sendResponse(buildResponse(2963, ctx.userId, 0, writeUInt32BE(0)))
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
