-- Module for processing packets

local lpp = {}
lpp.handler = {}
local buffer = require "buffer"
local srv = require "./server"
local UserDB = require "../userdb"
local md5 = require "../md5"
local offset = 17

-- 用户数据库实例
local userDB = UserDB:new()

function lpp.makeHead(cmdId,userId,errorId,bodylen)
    local head = buffer.Buffer:new(offset)
    head:writeUInt32BE(1,offset+bodylen) --PkgLen
    head:writeUInt8(5,0) --Version (赛尔号登录前是0)
    head:writeUInt32BE(6,cmdId) --Command
    head:writeUInt32BE(10,userId) --UserID
    head:writeUInt32BE(14,errorId) --Result
    return tostring(head)
end

function lpp.makeLoginBody(session, roleCreate)
    -- session: 16字节
    -- roleCreate: 4字节 (1=已创建角色, 0=未创建)
    local body = buffer.Buffer:new(20)
    -- 写入session (16字节)
    for i = 1, 16 do
        if i <= #session then
            body:writeUInt8(i, session:byte(i))
        else
            body:writeUInt8(i, 0)
        end
    end
    -- 写入roleCreate (4字节)
    body:writeUInt32BE(17, roleCreate or 1)
    return tostring(body)
end

-- 辅助函数：从buffer读取字符串（去除尾部的\0）
local function readString(buf, start, length)
    local str = buf:toString(start, start + length - 1)
    -- 去除尾部的\0
    local nullPos = str:find("\0")
    if nullPos then
        str = str:sub(1, nullPos - 1)
    end
    return str
end

local function createSrvList(buf,srvs)
    buf:writeUInt32BE(1,#srvs)
    local offset = 4
    for i=1,#srvs do
        buf:writeUInt32BE(offset+1,srvs[i].id)
        buf:writeUInt32BE(offset+5,srvs[i].userCount)
        local ip = srvs[i].ip
        for j=1,16 do
            if j <= #ip then
                buf:writeUInt8(offset+8+j,ip:byte(j))
            else
                buf:writeUInt8(offset+8+j,0)
            end
        end
        buf:writeUInt16BE(offset+25,srvs[i].port)
        buf:writeUInt32BE(offset+27,srvs[i].friends)
        offset = offset + 30
    end
end

function lpp.sendTextInfoBroadcast(socket,userid,msg) -- not used
    socket:write(lpp.makeHead(1414,userid,0,8+#msg))
    socket:wuint(0)
    socket:wuint(#msg)
    socket:wstr(msg,#msg)
end

function lpp.sendAuthCode(socket,userid,flag,codeid,codedata)
    socket:write(lpp.makeHead(101,userid,0,24+#codedata))
    socket:wuint(flag)
    socket:wstr(codeid,16)
    socket:wuint(#codedata)
    socket:wstr(codedata,#codedata)
end

--local aut = require("fs").readFileSync("upper.gif")

function lpp.makeSrvList(servers)
    local list = buffer.Buffer:new(#servers * 30 + 4)
    createSrvList(list,servers)
    return tostring(list)
end

function lpp.makeGoodSrvList(servers)
    local meta = buffer.Buffer:new(12)
    meta:writeUInt32BE(1,srv.getMaxServerID())
    meta:writeUInt32BE(5,0)-- isVip，TODO: 实现用户系统
    meta:writeUInt32BE(9,0)-- 好友列表userCount，暂未实现，填0
    return lpp.makeSrvList(servers) .. tostring(meta)
end

function lpp.preparse(data)
    local buf = buffer.Buffer:new(data)
    return buf:readUInt32BE(1)
end

function lpp.parse(data,socket)
    local buf = buffer.Buffer:new(data)
    local length = math.min(buf:readUInt32BE(1),buf.length)
    if length < 17 then return end
    -- 赛尔号：版本号可能是 0x31 ('1'), 0x1F, 或 0
    local version = buf:readUInt8(5)
    -- 打印调试信息
    local cmdId = buf:readUInt32BE(6)
    local userId = buf:readUInt32BE(10)
    local result = buf:readUInt32BE(14)
    
    print(string.format("\27[36m[LOGIN-PARSE] 解析数据包: len=%d, ver=0x%02X, cmd=%d, uid=%d, result=%d\27[0m", 
        length, version, cmdId, userId, result))
    
    -- 放宽版本号检查
    if version ~= 0x31 and version ~= 0x1F and version ~= 0 and version ~= 0x37 then 
        print(string.format("\27[31m[LOGIN-PARSE] 未知版本号: 0x%02X\27[0m", version))
        return 
    end
    
    if result ~= 0 then 
        print(string.format("\27[31m[LOGIN-PARSE] result 不为 0: %d\27[0m", result))
        return 
    end
    
    local handler = lpp.handler[cmdId]
    if handler then 
        handler(socket,userId,buf,length)
    else
        print("\27[31m[LOGIN-PARSE] Unhandled login packet: CMD=" .. cmdId .. "\27[0m")
    end
end

local fs = require("fs")
local aut = fs.existsSync("upper.gif") and fs.readFileSync("upper.gif") or ""

-- CMD_GET_AUTHCODE
lpp.handler[101] = function()
    p"getauth"
end

-- CMD_REGISTER (注册)
lpp.handler[2] = function(socket, userId, buf, length)
    -- 解析注册数据
    -- password: 32字节
    -- email: 64字节
    -- emailCode: 32字节 (验证码)
    -- emailCodeRes: 32字节 (验证码响应)
    
    local password = readString(buf, offset + 1, 32)
    local email = readString(buf, offset + 33, 64)
    
    print(string.format("\27[33m[REGISTER] 注册请求: email=%s\27[0m", email))
    
    -- 创建用户
    local user, err = userDB:createUser(email, password)
    
    if user then
        -- 注册成功
        print(string.format("\27[32m╔══════════════════════════════════════════════════════════════╗\27[0m"))
        print(string.format("\27[32m║ ✅ 注册成功！米米号: %d\27[0m", user.userId))
        print(string.format("\27[32m║ 📧 邮箱: %s\27[0m", email))
        print(string.format("\27[32m╚══════════════════════════════════════════════════════════════╝\27[0m"))
        socket:write(lpp.makeHead(2, user.userId, 0, 0))
    else
        -- 注册失败
        print(string.format("\27[31m╔══════════════════════════════════════════════════════════════╗\27[0m"))
        print(string.format("\27[31m║ ❌ 注册失败: %s\27[0m", err or "未知错误"))
        print(string.format("\27[31m╚══════════════════════════════════════════════════════════════╝\27[0m"))
        socket:write(lpp.makeHead(2, 0, 1, 0))  -- errorId=1 表示失败
    end
end

-- CMD_SEND_EMAIL_CODE (发送邮箱验证码)
lpp.handler[3] = function(socket, userId, buf, length)
    local email = readString(buf, offset + 1, 64)
    print(string.format("\27[33m[EMAIL_CODE] 发送验证码请求: email=%s\27[0m", email))
    
    -- 生成一个32字节的假验证码（本地服务器不需要真正发邮件）
    -- 官服返回格式: 32字节的hex字符串
    local codeRes = string.format("%032x", math.random(0, 0xFFFFFFFF)) .. string.format("%032x", math.random(0, 0xFFFFFFFF))
    codeRes = codeRes:sub(1, 32)  -- 取前32字节
    
    local body = buffer.Buffer:new(32)
    for i = 1, 32 do
        if i <= #codeRes then
            body:writeUInt8(i, codeRes:byte(i))
        else
            body:writeUInt8(i, 0)
        end
    end
    
    socket:write(lpp.makeHead(3, userId, 0, 32))
    socket:write(tostring(body))
    
    -- 在控制台显示验证码
    print(string.format("\27[32m╔══════════════════════════════════════════════════════════════╗\27[0m"))
    print(string.format("\27[32m║ 📧 邮箱验证码: %s\27[0m", codeRes))
    print(string.format("\27[32m╚══════════════════════════════════════════════════════════════╝\27[0m"))
end

-- CMD_LOGIN (旧的米米号登录，保留兼容)
lpp.handler[103] = function(socket,userId,buf,length)
    if length < 147 then return end
    local password = buf:toString(offset+1,offset+32)
    local session = "0000000000000000"
    local body = lpp.makeLoginBody(session, 1)
    socket:write(lpp.makeHead(103,userId,0,#body))
    socket:write(body)
    print("\27[1m[LOGIN-103] 米米号登录: userId="..userId.."\27[0m")
end

-- CMD_MAIN_LOGIN_IN (邮箱登录 - 主要登录方式)
lpp.handler[104] = function(socket, userId, buf, length)
    -- 邮箱登录数据格式:
    -- email: 64字节
    -- password: 32字节 (MD5)
    -- 后面还有一些其他数据
    
    local email = readString(buf, offset + 1, 64)
    local passwordMD5 = readString(buf, offset + 65, 32)
    
    print(string.format("\27[33m[LOGIN-104] 邮箱登录请求: email=%s\27[0m", email))
    
    -- 查找用户
    local user = userDB:findByEmail(email)
    local loginUserId = 0
    local errorCode = 0
    local isNewUser = false
    
    if user then
        -- 验证密码 (客户端发送的是MD5后的密码)
        local storedPasswordMD5 = md5.sumhexa(user.password)
        if passwordMD5 == storedPasswordMD5 or passwordMD5 == user.password then
            -- 登录成功
            loginUserId = user.userId
            print(string.format("\27[32m[LOGIN-104] 登录成功: userId=%d, email=%s\27[0m", loginUserId, email))
        else
            -- 密码错误
            errorCode = 5003
            print(string.format("\27[31m[LOGIN-104] 密码错误: email=%s\27[0m", email))
        end
    else
        -- 用户不存在 - 自动注册
        print(string.format("\27[33m[LOGIN-104] 用户不存在，自动注册: email=%s\27[0m", email))
        user = userDB:createUser(email, passwordMD5)
        if user then
            loginUserId = user.userId
            isNewUser = true
            print(string.format("\27[32m[LOGIN-104] 自动注册成功: userId=%d\27[0m", loginUserId))
        else
            errorCode = 1
            print("\27[31m[LOGIN-104] 自动注册失败\27[0m")
        end
    end
    
    -- 生成session (16字节随机数据，类似官服格式)
    local session = ""
    for i = 1, 16 do
        session = session .. string.char(math.random(0, 255))
    end
    
    -- 保存session到用户数据
    if user then
        user.session = session
        user.sessionHex = ""
        for i = 1, #session do
            user.sessionHex = user.sessionHex .. string.format("%02X", session:byte(i))
        end
        userDB:saveUser(user)
    end
    
    -- roleCreate: 0=未创建角色(新用户), 1=已创建角色
    local roleCreate = 0
    if user and user.roleCreated then
        roleCreate = 1
    end
    
    local body = lpp.makeLoginBody(session, roleCreate)
    socket:write(lpp.makeHead(104, loginUserId, errorCode, #body))
    socket:write(body)
    
    if errorCode == 0 then
        print(string.format("\27[32m╔══════════════════════════════════════════════════════════════╗\27[0m"))
        print(string.format("\27[32m║ ✅ 登录成功！米米号: %d\27[0m", loginUserId))
        print(string.format("\27[32m║ 👤 角色状态: %s\27[0m", roleCreate == 1 and "已创建" or "未创建"))
        print(string.format("\27[32m╚══════════════════════════════════════════════════════════════╝\27[0m"))
    end
end

-- CMD_CREATE_ROLE (创建角色)
lpp.handler[108] = function(socket, userId, buf, length)
    -- 创建角色请求
    -- session: 16字节
    -- nickname: 后面的数据
    
    print(string.format("\27[33m[CREATE_ROLE] 创建角色请求: userId=%d\27[0m", userId))
    
    -- 查找用户
    local user = userDB:findByUserId(userId)
    
    if user then
        -- 标记角色已创建
        user.roleCreated = true
        userDB:saveUser(user)
        
        -- 生成新的session
        local newSession = ""
        for i = 1, 16 do
            newSession = newSession .. string.char(math.random(0, 255))
        end
        
        -- 保存新session
        user.session = newSession
        user.sessionHex = ""
        for i = 1, #newSession do
            user.sessionHex = user.sessionHex .. string.format("%02X", newSession:byte(i))
        end
        userDB:saveUser(user)
        
        -- 返回新session (16字节)
        local body = buffer.Buffer:new(16)
        for i = 1, 16 do
            body:writeUInt8(i, newSession:byte(i))
        end
        
        socket:write(lpp.makeHead(108, userId, 0, 16))
        socket:write(tostring(body))
        
        print(string.format("\27[32m╔══════════════════════════════════════════════════════════════╗\27[0m"))
        print(string.format("\27[32m║ ✅ 角色创建成功！米米号: %d\27[0m", userId))
        print(string.format("\27[32m╚══════════════════════════════════════════════════════════════╝\27[0m"))
    else
        -- 用户不存在
        socket:write(lpp.makeHead(108, userId, 1, 0))
        print(string.format("\27[31m[CREATE_ROLE] 用户不存在: userId=%d\27[0m", userId))
    end
end

-- CMD_SYS_ROLE (109) - 角色验证
lpp.handler[109] = function(socket, userId, buf, length)
    print(string.format("\27[33m[SYS_ROLE] 角色验证: userId=%d\27[0m", userId))
    socket:write(lpp.makeHead(109, userId, 0, 0))
end

-- CMD_FENGHAO_TIME (111) - 封号时间查询
lpp.handler[111] = function(socket, userId, buf, length)
    print(string.format("\27[33m[FENGHAO_TIME] 封号时间查询: userId=%d\27[0m", userId))
    -- 返回0表示没有被封号
    local body = buffer.Buffer:new(4)
    body:writeUInt32BE(1, 0)
    socket:write(lpp.makeHead(111, userId, 0, 4))
    socket:write(tostring(body))
end

-- CMD_GET_GOOD_SERVER_LIST
lpp.handler[105] = function(socket,userId,buf,length)
    local session = buf:toString(offset+1,offset+16)
    local body = lpp.makeGoodSrvList(srv.getGoodSrvList())
    socket:write(lpp.makeHead(105,userId,0,#body))
    socket:write(body)
end

-- CMD_GET_SERVER_LIST
lpp.handler[106] = function(socket,userId,buf,length)
    local session = buf:toString(offset+1,offset+16)
    local body = lpp.makeSrvList(srv.getServerList())
    socket:write(lpp.makeHead(106,userId,0,#body))
    socket:write(body)
end



return lpp