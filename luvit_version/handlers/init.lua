-- 命令处理器注册中心
-- 所有命令处理器在这里注册，主服务器通过这里调用

local Handlers = {}

-- 处理器表: cmdId -> handler function
local handlers = {}

-- 注册处理器
function Handlers.register(cmdId, handler)
    handlers[cmdId] = handler
end

-- 批量注册
function Handlers.registerAll(handlerTable)
    for cmdId, handler in pairs(handlerTable) do
        handlers[cmdId] = handler
    end
end

-- 获取处理器
function Handlers.get(cmdId)
    return handlers[cmdId]
end

-- 检查是否有处理器
function Handlers.has(cmdId)
    return handlers[cmdId] ~= nil
end

-- 执行处理器
-- ctx: { userId, data, sendResponse, userDB, saveUserDB, getOrCreateUser }
function Handlers.execute(cmdId, ctx)
    local handler = handlers[cmdId]
    if handler then
        return handler(ctx)
    end
    return false
end

-- 加载所有处理器模块
function Handlers.loadAll()
    -- 系统命令
    require('handlers/system_handlers').register(Handlers)
    -- 地图命令
    require('handlers/map_handlers').register(Handlers)
    -- 任务命令
    require('handlers/task_handlers').register(Handlers)
    -- 精灵命令
    require('handlers/pet_handlers').register(Handlers)
    -- 精灵高级功能
    require('handlers/pet_advanced_handlers').register(Handlers)
    -- 战斗命令
    require('handlers/fight_handlers').register(Handlers)
    -- 物品命令
    require('handlers/item_handlers').register(Handlers)
    -- 邮件/通知命令
    require('handlers/mail_handlers').register(Handlers)
    -- 好友命令
    require('handlers/friend_handlers').register(Handlers)
    -- 战队命令
    require('handlers/team_handlers').register(Handlers)
    -- 战队PK命令
    require('handlers/teampk_handlers').register(Handlers)
    -- 竞技场命令
    require('handlers/arena_handlers').register(Handlers)
    -- 房间命令
    require('handlers/room_handlers').register(Handlers)
    -- NONO命令
    require('handlers/nono_handlers').register(Handlers)
    -- 师徒命令
    require('handlers/teacher_handlers').register(Handlers)
    -- 小游戏命令
    require('handlers/game_handlers').register(Handlers)
    -- 特殊活动命令
    require('handlers/special_handlers').register(Handlers)
    -- 交换命令
    require('handlers/exchange_handlers').register(Handlers)
    -- 其他命令
    require('handlers/misc_handlers').register(Handlers)
    
    print(string.format("\27[32m[Handlers] 已加载 %d 个命令处理器\27[0m", Handlers.count()))
end

-- 获取已注册处理器数量
function Handlers.count()
    local count = 0
    for _ in pairs(handlers) do
        count = count + 1
    end
    return count
end

return Handlers
