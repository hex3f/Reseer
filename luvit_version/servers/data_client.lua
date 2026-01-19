-- 数据服务器 HTTP 客户端
-- 用于游戏服务器和房间服务器访问数据服务器

local http = require('http')
local json = require('json')

local DataClient = {}
DataClient.__index = DataClient

-- 创建数据客户端
function DataClient:new(baseUrl)
    local obj = {
        baseUrl = baseUrl or "http://127.0.0.1:5200",
    }
    setmetatable(obj, DataClient)
    return obj
end

-- 内部方法：发送 HTTP 请求
function DataClient:_request(method, path, data, callback)
    local url = self.baseUrl .. path
    local options = {
        method = method,
        headers = {
            ["Content-Type"] = "application/json",
        }
    }
    
    local body = data and json.stringify(data) or nil
    if body then
        options.headers["Content-Length"] = #body
    end
    
    http.request(url, options, function(res)
        local responseData = ""
        
        res:on('data', function(chunk)
            responseData = responseData .. chunk
        end)
        
        res:on('end', function()
            local success = res.statusCode >= 200 and res.statusCode < 300
            local result = nil
            
            if #responseData > 0 then
                local ok, parsed = pcall(json.parse, responseData)
                if ok then
                    result = parsed
                else
                    result = {error = "JSON parse error", raw = responseData}
                end
            end
            
            if callback then
                callback(success, result, res.statusCode)
            end
        end)
    end):on('error', function(err)
        if callback then
            callback(false, {error = tostring(err)}, 0)
        end
    end):done(body)
end

-- ==================== 用户数据 API ====================

-- 获取或创建用户
function DataClient:getOrCreateUser(userId, callback)
    self:_request('GET', '/api/user/' .. userId, nil, callback)
end

-- 保存用户数据
function DataClient:saveUser(userId, userData, callback)
    self:_request('POST', '/api/user/' .. userId, userData, callback)
end

-- 更新用户字段
function DataClient:updateUserField(userId, field, value, callback)
    self:_request('PATCH', '/api/user/' .. userId .. '/' .. field, {value = value}, callback)
end

-- ==================== 会话管理 API ====================

-- 用户上线
function DataClient:userOnline(userId, serverType, mapId, callback)
    self:_request('POST', '/api/session/online', {
        userId = userId,
        serverType = serverType,
        mapId = mapId
    }, callback)
end

-- 用户下线
function DataClient:userOffline(userId, callback)
    self:_request('POST', '/api/session/offline', {userId = userId}, callback)
end

-- 检查用户是否在线
function DataClient:isUserOnline(userId, callback)
    self:_request('GET', '/api/session/online/' .. userId, nil, callback)
end

-- 获取所有在线用户
function DataClient:getAllOnlineUsers(callback)
    self:_request('GET', '/api/session/online', nil, callback)
end

-- ==================== NoNo 状态 API ====================

-- 设置 NoNo 跟随状态
function DataClient:setNonoFollowing(userId, isFollowing, callback)
    self:_request('POST', '/api/nono/following', {
        userId = userId,
        isFollowing = isFollowing
    }, callback)
end

-- 获取 NoNo 跟随状态
function DataClient:getNonoFollowing(userId, callback)
    self:_request('GET', '/api/nono/following/' .. userId, nil, callback)
end

-- ==================== 统计信息 API ====================

-- 获取统计信息
function DataClient:getStats(callback)
    self:_request('GET', '/api/stats', nil, callback)
end

-- 健康检查
function DataClient:healthCheck(callback)
    self:_request('GET', '/api/health', nil, callback)
end

-- ==================== 同步方法（使用协程）====================

-- 同步获取用户（阻塞直到完成）
function DataClient:getUserSync(userId)
    local co = coroutine.running()
    local result, success, statusCode
    
    self:getOrCreateUser(userId, function(s, r, code)
        success = s
        result = r
        statusCode = code
        if co then
            coroutine.resume(co)
        end
    end)
    
    if co then
        coroutine.yield()
    end
    
    return success, result, statusCode
end

return DataClient
