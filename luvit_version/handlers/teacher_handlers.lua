-- 师徒系统命令处理器
-- 包括: 拜师、收徒、经验分享等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local TeacherHandlers = {}

-- CMD 3001: REQUEST_ADD_TEACHER (请求拜师)
local function handleRequestAddTeacher(ctx)
    ctx.sendResponse(buildResponse(3001, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → REQUEST_ADD_TEACHER response\27[0m")
    return true
end

-- CMD 3002: ANSWER_ADD_TEACHER (回复拜师请求)
local function handleAnswerAddTeacher(ctx)
    ctx.sendResponse(buildResponse(3002, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ANSWER_ADD_TEACHER response\27[0m")
    return true
end

-- CMD 3003: REQUEST_ADD_STUDENT (请求收徒)
local function handleRequestAddStudent(ctx)
    ctx.sendResponse(buildResponse(3003, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → REQUEST_ADD_STUDENT response\27[0m")
    return true
end

-- CMD 3004: ANSWER_ADD_STUDENT (回复收徒请求)
local function handleAnswerAddStudent(ctx)
    ctx.sendResponse(buildResponse(3004, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → ANSWER_ADD_STUDENT response\27[0m")
    return true
end

-- CMD 3005: DELETE_TEACHER (删除师傅)
local function handleDeleteTeacher(ctx)
    ctx.sendResponse(buildResponse(3005, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → DELETE_TEACHER response\27[0m")
    return true
end

-- CMD 3006: DELETE_STUDENT (删除徒弟)
local function handleDeleteStudent(ctx)
    ctx.sendResponse(buildResponse(3006, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → DELETE_STUDENT response\27[0m")
    return true
end

-- CMD 3007: EXPERIENCESHARED_COMPLETE (经验分享完成)
-- ExperienceSharedInfo
local function handleExperienceSharedComplete(ctx)
    local body = writeUInt32BE(0) ..      -- ret
                writeUInt32BE(0)          -- exp
    ctx.sendResponse(buildResponse(3007, ctx.userId, 0, body))
    print("\27[32m[Handler] → EXPERIENCESHARED_COMPLETE response\27[0m")
    return true
end

-- CMD 3008: TEACHERREWARD_COMPLETE (师傅奖励完成)
-- TeacherAwardInfo
local function handleTeacherRewardComplete(ctx)
    local body = writeUInt32BE(0)  -- ret
    ctx.sendResponse(buildResponse(3008, ctx.userId, 0, body))
    print("\27[32m[Handler] → TEACHERREWARD_COMPLETE response\27[0m")
    return true
end

-- CMD 3009: MYEXPERIENCEPOND_COMPLETE (我的经验池完成)
-- MyExperiencePondInfo
local function handleMyExperiencePondComplete(ctx)
    local body = writeUInt32BE(0) ..      -- ret
                writeUInt32BE(0)          -- exp
    ctx.sendResponse(buildResponse(3009, ctx.userId, 0, body))
    print("\27[32m[Handler] → MYEXPERIENCEPOND_COMPLETE response\27[0m")
    return true
end

-- CMD 3010: SEVENNOLOGIN_COMPLETE (七天未登录完成)
-- SevenNoLoginInfo
local function handleSevenNoLoginComplete(ctx)
    local body = writeUInt32BE(0)  -- ret
    ctx.sendResponse(buildResponse(3010, ctx.userId, 0, body))
    print("\27[32m[Handler] → SEVENNOLOGIN_COMPLETE response\27[0m")
    return true
end

-- CMD 3011: GETMYEXPERIENCE_COMPLETE (获取我的经验完成)
-- GetExperienceInfo
local function handleGetMyExperienceComplete(ctx)
    local body = writeUInt32BE(0) ..      -- ret
                writeUInt32BE(0)          -- exp
    ctx.sendResponse(buildResponse(3011, ctx.userId, 0, body))
    print("\27[32m[Handler] → GETMYEXPERIENCE_COMPLETE response\27[0m")
    return true
end

-- 注册所有处理器
function TeacherHandlers.register(Handlers)
    Handlers.register(3001, handleRequestAddTeacher)
    Handlers.register(3002, handleAnswerAddTeacher)
    Handlers.register(3003, handleRequestAddStudent)
    Handlers.register(3004, handleAnswerAddStudent)
    Handlers.register(3005, handleDeleteTeacher)
    Handlers.register(3006, handleDeleteStudent)
    Handlers.register(3007, handleExperienceSharedComplete)
    Handlers.register(3008, handleTeacherRewardComplete)
    Handlers.register(3009, handleMyExperiencePondComplete)
    Handlers.register(3010, handleSevenNoLoginComplete)
    Handlers.register(3011, handleGetMyExperienceComplete)
    print("\27[36m[Handlers] 师徒命令处理器已注册\27[0m")
end

return TeacherHandlers
