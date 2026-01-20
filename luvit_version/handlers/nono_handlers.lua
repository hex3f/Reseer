-- NONO系统命令处理器
-- 包括: NONO开启、信息、治疗、喂食等
-- 基于官服协议分析实现

local BinaryWriter = require('utils/binary_writer')
local BinaryReader = require('utils/binary_reader')
local ResponseBuilder = require('utils/response_builder')
local buildResponse = ResponseBuilder.build

-- 导入 Logger 模块
local Logger = require('core/logger')
local tprint = Logger.tprint

local NonoHandlers = {}

-- 获取或创建用户的NONO数据 (从配置读取默认值)
local function getNonoData(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    if not user.nono then
        -- 从配置读取 NONO 默认值
        local GameConfig = require('config/game_config')
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

-- 辅助函数：保存NONO数据
local function saveNonoData(ctx, nonoData)
    local user = ctx.getOrCreateUser(ctx.userId)
    user.nono = nonoData
    ctx.saveUser(ctx.userId, user)
end

-- CMD 9003: NONO_INFO (获取NONO信息)
-- FIXED per frontend NonoInfo.as - Total bodyLen = 90 bytes
local function handleNonoInfo(ctx)
    local nonoData = getNonoData(ctx)
    local writer = BinaryWriter.new()
    
    -- Per NonoInfo.as constructor (lines 56-98):
    -- 1. userID (u32)
    writer:writeUInt32BE(ctx.userId)
    
    -- 2. flag (u32) - 32-bit bitmask, if 0 frontend returns early
    writer:writeUInt32BE(nonoData.flag or 1)
    
    -- 3. state (u32) - 32-bit bitmask
    writer:writeUInt32BE(nonoData.state or 0)
    
    -- 4. nick (strFixed16)
    writer:writeStringFixed(nonoData.nick or "NONO", 16)
    
    -- 5. superNono (u32) - Boolean as u32
    writer:writeUInt32BE(nonoData.superNono or 0)
    
    -- 6. color (u32)
    writer:writeUInt32BE(nonoData.color or 0xFFFFFF)
    
    -- 7. power (u32) - Backend stores *1000, frontend does /1000
    writer:writeUInt32BE(nonoData.power or 10000)
    
    -- 8. mate (u32) - Backend stores *1000, frontend does /1000
    writer:writeUInt32BE(nonoData.mate or 10000)
    
    -- 9. iq (u32)
    writer:writeUInt32BE(nonoData.iq or 0)
    
    -- 10. ai (u16) - CRITICAL: frontend uses readUnsignedShort!
    writer:writeUInt16BE(nonoData.ai or 0)
    
    -- 11. birth (u32) - Seconds, frontend multiplies by 1000
    writer:writeUInt32BE(nonoData.birth or os.time())
    
    -- 12. chargeTime (u32)
    writer:writeUInt32BE(nonoData.chargeTime or 0)
    
    -- 13. func (20 bytes) - 160-bit feature flags
    for i = 1, 20 do
        writer:writeUInt8(nonoData.func and nonoData.func[i] or 0xFF)
    end
    
    -- 14. superEnergy (u32)
    writer:writeUInt32BE(nonoData.superEnergy or 0)
    
    -- 15. superLevel (u32)
    writer:writeUInt32BE(nonoData.superLevel or 0)
    
    -- 16. superStage (u32) - Clamped 1-5 on frontend
    writer:writeUInt32BE(nonoData.superStage or 1)
    
    ctx.sendResponse(buildResponse(9003, ctx.userId, 0, writer:toString()))
    tprint("[Handler] → NONO_INFO response (90 bytes, fixed)")
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
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)                     -- result
    writer:writeUInt32BE(0)                     -- itemId/flag
    writer:writeUInt32BE(nonoData.power or 0)   -- power
    writer:writeUInt16BE(nonoData.ai or 0)      -- ai
    writer:writeUInt32BE(nonoData.mate or 0)    -- mate
    writer:writeUInt32BE(nonoData.iq or 0)      -- iq
    
    ctx.sendResponse(buildResponse(9013, ctx.userId, 0, writer:toString()))
    tprint("\27[32m[Handler] → NONO_PLAY response\27[0m")
    return true
end

-- CMD 9014: NONO_CLOSE_OPEN (NONO开启/关闭)
-- 官服响应: 17 bytes (只有头部，body为空)
local function handleNonoCloseOpen(ctx)
    local reader = BinaryReader.new(ctx.body)
    local action = 0
    if reader:getRemaining() ~= "" then
        action = reader:readUInt32BE()
    end
    
    local nonoData = getNonoData(ctx)
    nonoData.state = action  -- 0=关闭, 1=开启
    saveNonoData(ctx, nonoData)
    
    -- 官服返回空body
    ctx.sendResponse(buildResponse(9014, ctx.userId, 0, ""))
    tprint(string.format("\27[32m[Handler] → NONO_CLOSE_OPEN action=%d response\27[0m", action))
    return true
end

-- CMD 9015: NONO_EXE_LIST (NONO执行列表)
local function handleNonoExeList(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(9015, ctx.userId, 0, writer:toString()))
    tprint("\27[32m[Handler] → NONO_EXE_LIST response\27[0m")
    return true
end

-- CMD 9016: NONO_CHARGE (NONO充电)
local function handleNonoCharge(ctx)
    local nonoData = getNonoData(ctx)
    nonoData.superEnergy = math.min(99999, nonoData.superEnergy + 1000)
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9016, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] → NONO_CHARGE response\27[0m")
    return true
end

-- CMD 9017: NONO_START_EXE (开始执行)
local function handleNonoStartExe(ctx)
    ctx.sendResponse(buildResponse(9017, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] → NONO_START_EXE response\27[0m")
    return true
end

-- CMD 9018: NONO_END_EXE (结束执行)
local function handleNonoEndExe(ctx)
    ctx.sendResponse(buildResponse(9018, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] → NONO_END_EXE response\27[0m")
    return true
end

-- CMD 9019: NONO_FOLLOW_OR_HOOM (跟随或回家)
-- FIXED per FollowCmdListener.as lines 38-55:
--   Response: userId(4) + superStage(4) + isFollow(4) [+ nick(16) + color(4) + power(4) if following]
--   isFollow=1 (跟随): 36 bytes
--   isFollow=0 (回家): 12 bytes
local function handleNonoFollowOrHoom(ctx)
    local reader = BinaryReader.new(ctx.body)
    local action = 0  -- 0=回家, 1=跟随
    if reader:getRemaining() ~= "" then
        action = reader:readUInt32BE()
    end
    
    local nonoData = getNonoData(ctx)
    
    -- 设置会话级别的跟随状态
    if ctx.clientData then
        ctx.clientData.nonoFollowing = (action == 1)
    end
    if ctx.sessionManager then
        ctx.sessionManager:setNonoFollowing(ctx.userId, action == 1)
    end
    
    local writer = BinaryWriter.new()
    -- Per FollowCmdListener.as:
    -- _loc5_ = readUnsignedInt() = userId
    -- _loc6_ = readUnsignedInt() = superStage
    -- _loc7_ = Boolean(readUnsignedInt()) = isFollow
    writer:writeUInt32BE(ctx.userId)                        -- userId
    writer:writeUInt32BE(nonoData.superStage or 1)          -- superStage
    writer:writeUInt32BE(action)                            -- isFollow (0 or 1)
    
    if action == 1 then
        -- Following: additional fields per lines 53-55
        writer:writeStringFixed(nonoData.nick or "NONO", 16) -- nick
        writer:writeUInt32BE(nonoData.color or 0xFFFFFF)    -- color  
        writer:writeUInt32BE(nonoData.power or 10000)       -- power (frontend divides by 1000)
    end
    
    local body = writer:toString()
    ctx.sendResponse(buildResponse(9019, ctx.userId, 0, body))
    
    -- 广播给同地图其他玩家
    if ctx.broadcastToMap then
        ctx.broadcastToMap(buildResponse(9019, ctx.userId, 0, body), ctx.userId)
    end
    
    tprint(string.format("[Handler] → NONO_FOLLOW_OR_HOOM %s (%d bytes, fixed)", 
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
    tprint("\27[32m[Handler] → NONO_OPEN_SUPER response\27[0m")
    return true
end

-- CMD 9021: NONO_HELP_EXP (NONO帮助经验)
local function handleNonoHelpExp(ctx)
    ctx.sendResponse(buildResponse(9021, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] → NONO_HELP_EXP response\27[0m")
    return true
end

-- CMD 9022: NONO_MATE_CHANGE (NONO心情变化)
local function handleNonoMateChange(ctx)
    ctx.sendResponse(buildResponse(9022, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] → NONO_MATE_CHANGE response\27[0m")
    return true
end

-- CMD 9023: NONO_GET_CHIP (获取芯片)
-- 请求: chipType(4)
-- 响应: 0(4) + 0(4) + 0(4) + count(4) + [id(4) + count(4)]...
local function handleNonoGetChip(ctx)
    local reader = BinaryReader.new(ctx.body)
    local chipType = 0
    if reader:getRemaining() ~= "" then
        chipType = reader:readUInt32BE()
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
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(0)
    writer:writeUInt32BE(1)
    writer:writeUInt32BE(chipId)
    writer:writeUInt32BE(chipCount)
    
    ctx.sendResponse(buildResponse(9023, ctx.userId, 0, writer:toString()))
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
    tprint("\27[32m[Handler] → NONO_ADD_ENERGY_MATE response\27[0m")
    return true
end

-- CMD 9025: GET_DIAMOND (获取钻石)
local function handleGetDiamond(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(9999)  -- 钻石数量
    ctx.sendResponse(buildResponse(9025, ctx.userId, 0, writer:toString()))
    tprint("\27[32m[Handler] → GET_DIAMOND response\27[0m")
    return true
end

-- CMD 9026: NONO_ADD_EXP (增加NONO经验)
local function handleNonoAddExp(ctx)
    ctx.sendResponse(buildResponse(9026, ctx.userId, 0, ""))
    tprint("\27[32m[Handler] → NONO_ADD_EXP response\27[0m")
    return true
end

-- CMD 9027: NONO_IS_INFO (NONO是否有信息)
local function handleNonoIsInfo(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(1)  -- 有NONO
    ctx.sendResponse(buildResponse(9027, ctx.userId, 0, writer:toString()))
    tprint("\27[32m[Handler] → NONO_IS_INFO response\27[0m")
    return true
end

-- CMD 80001: NIEO_LOGIN (超能NONO登录/状态检查)
-- 请求: 无参数
-- 响应: status(4) - 0=正常/已激活
-- 如果新激活，会先发送 80002 通知消息
local function handleNieoLogin(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    local nonoData = user.nono or {}
    
    -- 从配置读取默认开通天数
    local GameConfig = require('config/game_config')
    local nonoConfig = GameConfig.InitialPlayer.nono or {}
    local durationDays = nonoConfig.superNonoDurationDays or 30
    
    local currentTime = os.time()
    local needActivate = false
    
    -- 检查是否需要激活/续费
    if not nonoData.superNono or nonoData.superNono == 0 then
        needActivate = true
    elseif nonoData.vipEndTime and nonoData.vipEndTime > 0 and nonoData.vipEndTime < currentTime then
        needActivate = true  -- 已过期，需要续费
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
        local writer = BinaryWriter.new()
        writer:writeUInt32BE(msgLen)
        writer:writeStringBytes(message)
        local notifyBody = writer:toString()
        ctx.sendResponse(buildResponse(80002, ctx.userId, 0, notifyBody))
        
        -- 发送 VIP_CO (8006) 命令来更新客户端的 MainManager.actorInfo.superNono
        -- 格式: userId(4) + vipFlag(4) + autoCharge(4) + vipEndTime(4)
        -- vipFlag=2 表示激活超能 NONO
        local vipWriter = BinaryWriter.new()
        vipWriter:writeUInt32BE(ctx.userId)       -- userId
        vipWriter:writeUInt32BE(2)                -- vipFlag=2 (激活超能NONO)
        vipWriter:writeUInt32BE(nonoData.autoCharge or 0)  -- autoCharge
        vipWriter:writeUInt32BE(endTime)          -- vipEndTime
        ctx.sendResponse(buildResponse(8006, ctx.userId, 0, vipWriter:toString()))
        
        tprint(string.format("\27[32m[Handler] → NIEO_REGISTER 激活成功 到期: %s (已发送 VIP_CO 更新)\27[0m", endTimeStr))
    end
    
    -- 发送 80001 状态响应
    local statusWriter = BinaryWriter.new()
    statusWriter:writeUInt32BE(0)
    ctx.sendResponse(buildResponse(80001, ctx.userId, 0, statusWriter:toString()))
    tprint("\27[32m[Handler] → NIEO_LOGIN status=0\27[0m")
    return true
end

-- ==================== 缺失的处理器 ====================

-- CMD 9001: NONO_OPEN (开启NONO)
local function handleNonoOpen(ctx)
    local nonoData = getNonoData(ctx)
    nonoData.hasNono = 1
    nonoData.flag = 1
    saveNonoData(ctx, nonoData)
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- success
    ctx.sendResponse(buildResponse(9001, ctx.userId, 0, writer:toString()))
    tprint("\27[32m[Handler] → NONO_OPEN response\27[0m")
    return true
end

-- CMD 9002: NONO_CHANGE_NAME (修改NONO名字)
-- 请求: newName(16)
local function handleNonoChangeName(ctx)
    local newName = "NONO"
    if #ctx.body >= 16 then
        newName = string.sub(ctx.body, 1, 16):gsub("%z+$", "")
    end
    
    local nonoData = getNonoData(ctx)
    nonoData.nick = newName
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9002, ctx.userId, 0, ""))
    tprint(string.format("\27[32m[Handler] → NONO_CHANGE_NAME '%s'\27[0m", newName))
    return true
end

-- CMD 9004: NONO_CHIP_MIXTURE (NONO芯片合成)
local function handleNonoChipMixture(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- result
    ctx.sendResponse(buildResponse(9004, ctx.userId, 0, writer:toString()))
    tprint("\27[32m[Handler] → NONO_CHIP_MIXTURE response\27[0m")
    return true
end

-- CMD 9007: NONO_CURE (NONO治疗)
local function handleNonoCure(ctx)
    local nonoData = getNonoData(ctx)
    nonoData.hp = nonoData.maxHp or 10000
    saveNonoData(ctx, nonoData)
    
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- result
    ctx.sendResponse(buildResponse(9007, ctx.userId, 0, writer:toString()))
    tprint("\27[32m[Handler] → NONO_CURE response\27[0m")
    return true
end

-- CMD 9008: NONO_EXPADM (NONO经验管理)
local function handleNonoExpadm(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- result
    ctx.sendResponse(buildResponse(9008, ctx.userId, 0, writer:toString()))
    tprint("\27[32m[Handler] → NONO_EXPADM response\27[0m")
    return true
end

-- CMD 9010: NONO_IMPLEMENT_TOOL (NONO使用工具)
local function handleNonoImplementTool(ctx)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0)  -- result
    ctx.sendResponse(buildResponse(9010, ctx.userId, 0, writer:toString()))
    tprint("\27[32m[Handler] → NONO_IMPLEMENT_TOOL response\27[0m")
    return true
end

-- CMD 9012: NONO_CHANGE_COLOR (修改NONO颜色)
-- 请求: color(4)
local function handleNonoChangeColor(ctx)
    local reader = BinaryReader.new(ctx.body)
    local color = 0xFFFFFF
    if reader:getRemaining() ~= "" then
        color = reader:readUInt32BE()
    end
    
    local nonoData = getNonoData(ctx)
    nonoData.color = color
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9012, ctx.userId, 0, ""))
    tprint(string.format("\27[32m[Handler] → NONO_CHANGE_COLOR 0x%06X\27[0m", color))
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
