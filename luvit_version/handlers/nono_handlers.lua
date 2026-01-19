-- NONO系统命令处理器
-- 包括: NONO开启、信息、治疗、喂食等
-- 基于官服协议分析实现

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

-- 导入 Logger 模块
local Logger = require('../core/logger')
local tprint = Logger.tprint

local NonoHandlers = {}

-- 获取或创建用户的NONO数据 (从配置读取默认值)
local function getNonoData(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    if not user.nono then
        -- 从配置读取 NONO 默认值
        local GameConfig = require('../config/game_config')
        local nonoDefaults = GameConfig.InitialPlayer.nono or {}
        
        user.nono = {
            hasNono = nonoDefaults.hasNono or 1,
            flag = nonoDefaults.flag or 1,
            nick = nonoDefaults.nick or "NoNo",
            color = nonoDefaults.color or 0xFFFFFF,
            superNono = nonoDefaults.superNono or 0,
            vipLevel = nonoDefaults.vipLevel or 0,
            vipStage = nonoDefaults.vipStage or 0,
            vipValue = nonoDefaults.vipValue or 0,
            autoCharge = nonoDefaults.autoCharge or 0,
            vipEndTime = nonoDefaults.vipEndTime or 0,
            freshManBonus = nonoDefaults.freshManBonus or 0,
            superEnergy = nonoDefaults.superEnergy or 0,
            superLevel = nonoDefaults.superLevel or 0,
            superStage = nonoDefaults.superStage or 0,
            power = nonoDefaults.power or 10000,
            mate = nonoDefaults.mate or 10000,
            iq = nonoDefaults.iq or 0,
            ai = nonoDefaults.ai or 0,
            hp = nonoDefaults.hp or 10000,
            maxHp = nonoDefaults.maxHp or 10000,
            energy = nonoDefaults.energy or 100,
            birth = (nonoDefaults.birth == 0) and os.time() or (nonoDefaults.birth or os.time()),
            chargeTime = nonoDefaults.chargeTime or 0,
            expire = nonoDefaults.expire or 0,
            chip = nonoDefaults.chip or 0,
            grow = nonoDefaults.grow or 0,
        }
        ctx.saveUser(ctx.userId, user)
    end
    return user.nono
end

-- ... (skipping unchanged lines)

-- CMD 9003: NONO_INFO (获取NONO信息)
local function handleNonoInfo(ctx)
    local nonoData = getNonoData(ctx)
    local body = ""
    
    -- 构建 NonoInfo 结构
    body = body .. writeUInt32BE(0)                     -- result
    body = body .. writeUInt32BE(ctx.userId)            -- userId
    body = body .. writeUInt32BE(0)                     -- nonoKey (占位)
    body = body .. writeUInt32BE(nonoData.flag or 1)    -- flag
    body = body .. writeUInt32BE(nonoData.state or 0)   -- state
    body = body .. writeFixedString(nonoData.nick or "NONO", 16) -- nick (16 bytes)
    body = body .. writeUInt32BE(nonoData.color or 0xFFFFFF)    -- color
    body = body .. writeUInt32BE(nonoData.power or 10000)       -- power
    body = body .. writeUInt32BE(nonoData.mate or 10000)        -- mate
    body = body .. writeUInt32BE(nonoData.iq or 0)      -- iq
    body = body .. writeUInt32BE(nonoData.ai or 0)      -- ai (通常是4字节)
    body = body .. writeUInt32BE(nonoData.superLevel or 0) -- level
    body = body .. writeUInt32BE(0)                     -- bio (占位)
    
    -- birth: 必须是秒级时间戳 (前端会 *1000)
    -- 如果这里发送毫秒，前端显示会变成巨大数字
    local birth = nonoData.birth or os.time()
    body = body .. writeUInt32BE(birth)                 -- birth
    
    body = body .. writeUInt32BE(nonoData.chargeTime or 0) -- chargeTime
    body = body .. writeUInt32BE(nonoData.expire or 0)  -- expire
    body = body .. writeUInt32BE(nonoData.chip or 0)    -- chip
    body = body .. writeUInt32BE(nonoData.grow or 0)    -- grow
    
    ctx.sendResponse(buildResponse(9003, ctx.userId, 0, body))
    tprint(string.format("\27[32m[Handler] → NONO_INFO response (birth=%d)\27[0m", birth))
    return true
end

-- CMD 9013: NONO_PLAY (NONO玩耍)
local function handleNonoPlay(ctx)
    local nonoData = getNonoData(ctx)
    -- 玩耍增加心情
    nonoData.mate = math.min(100000, nonoData.mate + 5000)
    saveNonoData(ctx, nonoData)
    
    -- 补齐 6 个字段回包
    -- 字段猜测: result(4) + itemId(4, 占位) + power(4) + ai(2) + mate(4) + iq(4)
    local body = ""
    body = body .. writeUInt32BE(0)                     -- result
    body = body .. writeUInt32BE(0)                     -- itemId/flag
    body = body .. writeUInt32BE(nonoData.power or 0)   -- power
    body = body .. writeUInt16BE(nonoData.ai or 0)      -- ai
    body = body .. writeUInt32BE(nonoData.mate or 0)    -- mate
    body = body .. writeUInt32BE(nonoData.iq or 0)      -- iq
    
    ctx.sendResponse(buildResponse(9013, ctx.userId, 0, body))
    tprint("\27[32m[Handler] → NONO_PLAY response\27[0m")
    return true
end

-- CMD 9014: NONO_CLOSE_OPEN (NONO开??
-- 官服响应: 17 bytes (只有头部，body为空)
local function handleNonoCloseOpen(ctx)
    local action = 0
    if #ctx.body >= 4 then
        action = readUInt32BE(ctx.body, 1)
    end
    
    local nonoData = getNonoData(ctx)
    nonoData.state = action  -- 0=关闭, 1=开??
    saveNonoData(ctx, nonoData)
    
    -- 官服返回??body
    ctx.sendResponse(buildResponse(9014, ctx.userId, 0, ""))
    tprint(string.format("\27[32m[Handler] ??NONO_CLOSE_OPEN action=%d response\27[0m", action))
    return true
end

-- CMD 9015: NONO_EXE_LIST (NONO执行列表)
local function handleNonoExeList(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(9015, ctx.userId, 0, body))
    tprint("\27[32m[Handler] ??NONO_EXE_LIST response\27[0m")
    return true
end

-- CMD 9016: NONO_CHARGE (NONO充电)
local function handleNonoCharge(ctx)
    local nonoData = getNonoData(ctx)
    nonoData.superEnergy = math.min(99999, nonoData.superEnergy + 1000)
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9016, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] ??NONO_CHARGE response\27[0m")
    return true
end

-- CMD 9017: NONO_START_EXE (开始执??
local function handleNonoStartExe(ctx)
    ctx.sendResponse(buildResponse(9017, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] ??NONO_START_EXE response\27[0m")
    return true
end

-- CMD 9018: NONO_END_EXE (结束执行)
local function handleNonoEndExe(ctx)
    ctx.sendResponse(buildResponse(9018, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] ??NONO_END_EXE response\27[0m")
    return true
end

-- CMD 9019: NONO_FOLLOW_OR_HOOM (跟随或回??
-- 官服响应根据 action 不同返回不同长度:
--   action=1 (跟随): 36 bytes = userID(4) + flag(4) + state(4) + nick(16) + color(4) + chargeTime(4)
--   action=0 (回家): 12 bytes = userID(4) + flag(4) + state(4)
-- 注意: 跟随状态是会话级别的，不持久化到数据库
local function handleNonoFollowOrHoom(ctx)
    local action = 0  -- 0=回家, 1=跟随
    if #ctx.body >= 4 then
        action = readUInt32BE(ctx.body, 1)
    end
    
    local nonoData = getNonoData(ctx)
    
    -- 设置会话级别的跟随状态（用于跨服务器状态同步）
    if ctx.clientData then
        ctx.clientData.nonoFollowing = (action == 1)
    end
    
    -- 使用会话管理器设??NoNo 跟随状??
    if ctx.sessionManager then
        ctx.sessionManager:setNonoFollowing(ctx.userId, action == 1)
    end
    
    -- 注意: 不保存跟随状态到数据??
    -- 跟随状态是会话级别的，重新登录后会重置
    -- 这样可以确保每次登录??NoNo 都在房间
    
    local body = ""
    if action == 1 then
        -- 跟随: 返回完整 NONO 信息 (36 bytes)
        -- 官服格式: flag=0, state=1
        body = body .. writeUInt32BE(ctx.userId)                    -- userID (4)
        body = body .. writeUInt32BE(0)                             -- flag=0 (官服始终??) (4)
        body = body .. writeUInt32BE(1)                             -- state=1 跟随??(4)
        body = body .. writeFixedString(nonoData.nick or "NONO", 16) -- nick (16)
        body = body .. writeUInt32BE(nonoData.color or 0xFFFFFF)    -- color (4)
        body = body .. writeUInt32BE(nonoData.power or 10000)       -- power (4) (官服值为10000，此前误写为chargeTime)
    else
        -- 回家: 只返??12 bytes (官服协议)
        -- 官服格式: flag=0, state=0
        body = body .. writeUInt32BE(ctx.userId)                    -- userID (4)
        body = body .. writeUInt32BE(0)                             -- flag=0 (官服始终??) (4)
        body = body .. writeUInt32BE(0)                             -- state=0 已回??(4)
    end
    
    ctx.sendResponse(buildResponse(9019, ctx.userId, 0, body))
    
    -- 广播给同地图其他玩家
    if ctx.broadcastToMap then
        ctx.broadcastToMap(buildResponse(9019, ctx.userId, 0, body), ctx.userId)
    end
    
    tprint(string.format("\27[32m[Handler] ??NONO_FOLLOW_OR_HOOM %s response (%d bytes)\27[0m", 
        action == 1 and "跟随" or "回家", #body))
    return true
end

-- CMD 9020: NONO_OPEN_SUPER (开启超级NONO)
local function handleNonoOpenSuper(ctx)
    local nonoData = getNonoData(ctx)
    nonoData.superNono = 1
    nonoData.superLevel = math.max(1, nonoData.superLevel)
    nonoData.superStage = math.max(1, nonoData.superStage)
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9020, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] ??NONO_OPEN_SUPER response\27[0m")
    return true
end

-- CMD 9021: NONO_HELP_EXP (NONO帮助经验)
local function handleNonoHelpExp(ctx)
    ctx.sendResponse(buildResponse(9021, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] ??NONO_HELP_EXP response\27[0m")
    return true
end

-- CMD 9022: NONO_MATE_CHANGE (NONO心情变化)
local function handleNonoMateChange(ctx)
    ctx.sendResponse(buildResponse(9022, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] ??NONO_MATE_CHANGE response\27[0m")
    return true
end

-- CMD 9023: NONO_GET_CHIP (获取芯片)
-- 请求: chipType(4)
-- 响应: 0(4) + 0(4) + 0(4) + count(4) + [id(4) + count(4)]...
local function handleNonoGetChip(ctx)
    local chipType = 0
    if #ctx.body >= 4 then
        chipType = readUInt32BE(ctx.body, 1)
    end
    
    -- 给用户添加芯片物品
    local user = ctx.getOrCreateUser(ctx.userId)
    if not user.nonoChips then user.nonoChips = {} end
    
    local chipId = chipType
    local chipCount = 1
    
    -- 保存芯片到用户数据
    local chipKey = tostring(chipId)
    if not user.nonoChips[chipKey] then
        user.nonoChips[chipKey] = { count = 0 }
    end
    user.nonoChips[chipKey].count = user.nonoChips[chipKey].count + chipCount
    ctx.saveUser(ctx.userId, user)
    
    -- 构建响应: 3个padding(0) + count + [id + count]
    local body = writeUInt32BE(0) ..
                 writeUInt32BE(0) ..
                 writeUInt32BE(0) ..
                 writeUInt32BE(1) ..
                 writeUInt32BE(chipId) ..
                 writeUInt32BE(chipCount)
    
    ctx.sendResponse(buildResponse(9023, ctx.userId, 0, body))
    tprint(string.format("\27[32m[Handler] -> NONO_GET_CHIP chipId=%d\27[0m", chipId))
    return true
end

-- CMD 9024: NONO_ADD_ENERGY_MATE (增加能量心情)
local function handleNonoAddEnergyMate(ctx)
    local nonoData = getNonoData(ctx)
    nonoData.power = math.min(100000, nonoData.power + 10000)
    nonoData.mate = math.min(100000, nonoData.mate + 10000)
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9024, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] ??NONO_ADD_ENERGY_MATE response\27[0m")
    return true
end

-- CMD 9025: GET_DIAMOND (获取钻石)
local function handleGetDiamond(ctx)
    local body = writeUInt32BE(9999)  -- 钻石数量
    ctx.sendResponse(buildResponse(9025, ctx.userId, 0, body))
    tprint("\27[32m[Handler] ??GET_DIAMOND response\27[0m")
    return true
end

-- CMD 9026: NONO_ADD_EXP (增加NONO经验)
local function handleNonoAddExp(ctx)
    ctx.sendResponse(buildResponse(9026, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] ??NONO_ADD_EXP response\27[0m")
    return true
end

-- CMD 9027: NONO_IS_INFO (NONO是否有信??
local function handleNonoIsInfo(ctx)
    local body = writeUInt32BE(1)  -- 有NONO
    ctx.sendResponse(buildResponse(9027, ctx.userId, 0, body))
    tprint("\27[32m[Handler] ??NONO_IS_INFO response\27[0m")
    return true
end

-- CMD 80001: NIEO_LOGIN (超能NONO登录/状态检??
-- 请求: 无参??
-- 响应: status(4) - 0=正常/已激??
-- 如果新激活，会先发??80002 通知消息
local function handleNieoLogin(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local nonoData = user.nono or {}
    
    -- 从配置读取默认开通天??
    local GameConfig = require('../config/game_config')
    local nonoConfig = GameConfig.InitialPlayer.nono or {}
    local durationDays = nonoConfig.superNonoDurationDays or 30
    
    local currentTime = os.time()
    local needActivate = false
    
    -- 检查是否需要激??续费
    if not nonoData.superNono or nonoData.superNono == 0 then
        needActivate = true
    elseif nonoData.vipEndTime and nonoData.vipEndTime > 0 and nonoData.vipEndTime < currentTime then
        needActivate = true  -- 已过期，需要续??
    end
    
    if needActivate then
        -- 激活超能NONO
        local endTime = currentTime + (durationDays * 24 * 60 * 60)
        nonoData.superNono = 1
        nonoData.vipEndTime = endTime
        nonoData.superLevel = math.max(1, nonoData.superLevel or 0)
        nonoData.superStage = math.max(1, nonoData.superStage or 0)
        
        user.nono = nonoData
        ctx.saveUser(ctx.userId, user)
        
        -- 格式化到期时间
        local endTimeStr = os.date("%Y-%m-%d", endTime)
        local message = string.format("成功激活超能NONO！\n到期时间:%s", endTimeStr)
        
        -- 先发送 80002 激活成功通知
        local msgLen = #message
        local notifyBody = writeUInt32BE(msgLen) .. message
        ctx.sendResponse(buildResponse(80002, ctx.userId, 0, notifyBody))
        
        -- 发送 VIP_CO (8006) 命令来更新客户端的 MainManager.actorInfo.superNono
        -- 格式: userId(4) + vipFlag(4) + autoCharge(4) + vipEndTime(4)
        -- vipFlag=2 表示激活超能 NONO
        local vipBody = ""
        vipBody = vipBody .. writeUInt32BE(ctx.userId)       -- userId
        vipBody = vipBody .. writeUInt32BE(2)                -- vipFlag=2 (激活超能NONO)
        vipBody = vipBody .. writeUInt32BE(nonoData.autoCharge or 0)  -- autoCharge
        vipBody = vipBody .. writeUInt32BE(endTime)          -- vipEndTime
        ctx.sendResponse(buildResponse(8006, ctx.userId, 0, vipBody))
        
        tprint(string.format("\27[32m[Handler] → NIEO_REGISTER 激活成功 到期: %s (已发送 VIP_CO 更新)\27[0m", endTimeStr))
    end
    
    -- 发送 80001 状态响应
    ctx.sendResponse(buildResponse(80001, ctx.userId, 0, writeUInt32BE(0)))
    tprint("\27[32m[Handler] ?NIEO_LOGIN status=0\27[0m")
    return true
end

-- 注册所有处理器
function NonoHandlers.register(Handlers)
    Handlers.register(9001, handleNonoOpen)
    Handlers.register(9002, handleNonoChangeName)
    Handlers.register(9003, handleNonoInfo)
    Handlers.register(9004, handleNonoChipMixture)
    Handlers.register(9007, handleNonoCure)
    Handlers.register(9008, handleNonoExpadm)
    Handlers.register(9010, handleNonoImplementTool)
    Handlers.register(9012, handleNonoChangeColor)
    Handlers.register(9013, handleNonoPlay)
    Handlers.register(9014, handleNonoCloseOpen)
    Handlers.register(9015, handleNonoExeList)
    Handlers.register(9016, handleNonoCharge)
    Handlers.register(9017, handleNonoStartExe)
    Handlers.register(9018, handleNonoEndExe)
    Handlers.register(9019, handleNonoFollowOrHoom)
    Handlers.register(9020, handleNonoOpenSuper)
    Handlers.register(9021, handleNonoHelpExp)
    Handlers.register(9022, handleNonoMateChange)
    Handlers.register(9023, handleNonoGetChip)
    Handlers.register(9024, handleNonoAddEnergyMate)
    Handlers.register(9025, handleGetDiamond)
    Handlers.register(9026, handleNonoAddExp)
    Handlers.register(9027, handleNonoIsInfo)
    Handlers.register(80001, handleNieoLogin)
    tprint("\27[36m[Handlers] NONO命令处理器已注册\27[0m")
end

return NonoHandlers
