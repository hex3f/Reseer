-- 师徒系统命令处理器
-- 包括: 拜师、收徒、经验分享等

local BinaryWriter = require('utils/binary_writer')
local BinaryReader = require('utils/binary_reader')
local ResponseBuilder = require('utils/response_builder')

local TeacherHandlers = {}

-- CMD 3001: REQUEST_ADD_TEACHER (请求拜师)
-- 向目标用户发送拜师请求
local function handleRequestAddTeacher(ctx)
    local targetId = 0
    if #ctx.body >= 4 then
        local reader = BinaryReader.new(ctx.body)
        targetId = reader:readUInt32BE()
    end
    
    -- 保存待处理的请求（可选，用于跨会话）
    local user = ctx.getOrCreateUser(ctx.userId)
    user.pendingTeacherRequest = targetId
    ctx.saveUserDB()
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- 0=请求成功
    ctx.sendResponse(ResponseBuilder.build(3001, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → REQUEST_ADD_TEACHER to %d\27[0m", targetId))
    return true
end

-- CMD 3002: ANSWER_ADD_TEACHER (回复拜师请求)
-- accept=1时建立师徒关系
local function handleAnswerAddTeacher(ctx)
    local studentId = 0
    local accept = 0
    if #ctx.body >= 8 then
        local reader = BinaryReader.new(ctx.body)
        studentId = reader:readUInt32BE()
        accept = reader:readUInt32BE()
    end
    
    if accept == 1 and studentId > 0 then
        -- 保存师徒关系 - 当前用户成为teacher
        local user = ctx.getOrCreateUser(ctx.userId)
        user.studentIDs = user.studentIDs or {}
        
        -- 检查是否已是徒弟
        local found = false
        for _, id in ipairs(user.studentIDs) do
            if id == studentId then found = true break end
        end
        if not found then
            table.insert(user.studentIDs, studentId)
        end
        ctx.saveUserDB()
        
        -- 更新学生的teacherID
        local studentUser = ctx.getOrCreateUser(studentId)
        studentUser.teacherID = ctx.userId
        ctx.saveUser(studentId, studentUser)
        
        print(string.format("\27[32m[Handler] 师徒关系建立: 师傅=%d 徒弟=%d\27[0m", ctx.userId, studentId))
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(accept)
    ctx.sendResponse(ResponseBuilder.build(3002, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → ANSWER_ADD_TEACHER student=%d accept=%d\27[0m", studentId, accept))
    return true
end

-- CMD 3003: REQUEST_ADD_STUDENT (请求收徒)
local function handleRequestAddStudent(ctx)
    local targetId = 0
    if #ctx.body >= 4 then
        local reader = BinaryReader.new(ctx.body)
        targetId = reader:readUInt32BE()
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(3003, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → REQUEST_ADD_STUDENT to %d\27[0m", targetId))
    return true
end

-- CMD 3004: ANSWER_ADD_STUDENT (回复收徒请求)
local function handleAnswerAddStudent(ctx)
    local teacherId = 0
    local accept = 0
    if #ctx.body >= 8 then
        local reader = BinaryReader.new(ctx.body)
        teacherId = reader:readUInt32BE()
        accept = reader:readUInt32BE()
    end
    
    if accept == 1 and teacherId > 0 then
        -- 保存师徒关系 - 当前用户成为student
        local user = ctx.getOrCreateUser(ctx.userId)
        user.teacherID = teacherId
        ctx.saveUserDB()
        
        -- 更新师傅的studentIDs
        local teacherUser = ctx.getOrCreateUser(teacherId)
        teacherUser.studentIDs = teacherUser.studentIDs or {}
        local found = false
        for _, id in ipairs(teacherUser.studentIDs) do
            if id == ctx.userId then found = true break end
        end
        if not found then
            table.insert(teacherUser.studentIDs, ctx.userId)
            ctx.saveUser(teacherId, teacherUser)
        end
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(accept)
    ctx.sendResponse(ResponseBuilder.build(3004, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → ANSWER_ADD_STUDENT teacher=%d accept=%d\27[0m", teacherId, accept))
    return true
end

-- CMD 3005: DELETE_TEACHER (删除师傅)
local function handleDeleteTeacher(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local teacherId = user.teacherID or 0
    
    if teacherId > 0 then
        -- 从师傅的徒弟列表中移除自己
        local teacherUser = ctx.getOrCreateUser(teacherId)
        if teacherUser.studentIDs then
            for i, id in ipairs(teacherUser.studentIDs) do
                if id == ctx.userId then
                    table.remove(teacherUser.studentIDs, i)
                    ctx.saveUser(teacherId, teacherUser)
                    break
                end
            end
        end
        
        -- 清除自己的teacherID
        user.teacherID = nil
        ctx.saveUserDB()
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(3005, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → DELETE_TEACHER (removed %d)\27[0m", teacherId))
    return true
end

-- CMD 3006: DELETE_STUDENT (删除徒弟)
local function handleDeleteStudent(ctx)
    local targetId = 0
    if #ctx.body >= 4 then
        local reader = BinaryReader.new(ctx.body)
        targetId = reader:readUInt32BE()
    end
    
    if targetId > 0 then
        local user = ctx.getOrCreateUser(ctx.userId)
        user.studentIDs = user.studentIDs or {}
        
        -- 从徒弟列表移除
        for i, id in ipairs(user.studentIDs) do
            if id == targetId then
                table.remove(user.studentIDs, i)
                ctx.saveUserDB()
                break
            end
        end
        
        -- 清除徒弟的teacherID
        local studentUser = ctx.getOrCreateUser(targetId)
        if studentUser.teacherID == ctx.userId then
            studentUser.teacherID = nil
            ctx.saveUser(targetId, studentUser)
        end
    end
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    ctx.sendResponse(ResponseBuilder.build(3006, ctx.userId, 0, writer:toString()))
    print(string.format("\27[32m[Handler] → DELETE_STUDENT %d\27[0m", targetId))
    return true
end

-- CMD 3007: EXPERIENCESHARED_COMPLETE (经验分享完成)
local function handleExperienceSharedComplete(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local expPool = user.expPool or 0
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- ret
    writer:writeUInt32BE(expPool) -- exp
    ctx.sendResponse(ResponseBuilder.build(3007, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → EXPERIENCESHARED_COMPLETE\27[0m")
    return true
end

-- CMD 3008: TEACHERREWARD_COMPLETE (师傅奖励完成)
local function handleTeacherRewardComplete(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- ret
    ctx.sendResponse(ResponseBuilder.build(3008, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → TEACHERREWARD_COMPLETE\27[0m")
    return true
end

-- CMD 3009: MYEXPERIENCEPOND_COMPLETE (我的经验池完成)
local function handleMyExperiencePondComplete(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local expPool = user.expPool or 0
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- ret
    writer:writeUInt32BE(expPool) -- exp
    ctx.sendResponse(ResponseBuilder.build(3009, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → MYEXPERIENCEPOND_COMPLETE\27[0m")
    return true
end

-- CMD 3010: SEVENNOLOGIN_COMPLETE (七天未登录完成)
local function handleSevenNoLoginComplete(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- ret
    ctx.sendResponse(ResponseBuilder.build(3010, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → SEVENNOLOGIN_COMPLETE\27[0m")
    return true
end

-- CMD 3011: GETMYEXPERIENCE_COMPLETE (获取我的经验完成)
local function handleGetMyExperienceComplete(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local expPool = user.expPool or 0
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- ret
    writer:writeUInt32BE(expPool) -- exp
    ctx.sendResponse(ResponseBuilder.build(3011, ctx.userId, 0, writer:toString()))
    print("\27[32m[Handler] → GETMYEXPERIENCE_COMPLETE\27[0m")
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
