-- NONO系统命令处理器
-- 包括: NONO开启、信息、治疗、喂食等
-- 基于官服协议分析实现

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local writeUInt16BE = Utils.writeUInt16BE
local readUInt32BE = Utils.readUInt32BE
local writeFixedString = Utils.writeFixedString
local buildResponse = Utils.buildResponse

local NonoHandlers = {}

-- 获取或创建用户的NONO数据
local function getNonoData(ctx)
    local user = ctx.getOrCreateUser(ctx.userId)
    if not user.nono then
        user.nono = {
            flag = 0x00000001,      -- 基本功能开启
            state = 0x00000001,     -- 状态: 已激活
            nick = "NoNo",          -- 默认名字
            superNono = 1,          -- 超级诺诺
            color = 0x00FBF4E1,     -- 颜色 (官服默认)
            power = 80000,          -- 体力 (实际值*1000 = 80)
            mate = 80000,           -- 心情 (实际值*1000 = 80)
            iq = 100,               -- 智力
            ai = 100,               -- AI
            birth = os.time(),      -- 出生时间
            chargeTime = 0,         -- 充电时间
            superEnergy = 10000,    -- 超能能量
            superLevel = 10,        -- 超能等级
            superStage = 3,         -- 超能阶段 (1-4)
            isFollowing = false     -- 是否跟随
        }
        ctx.saveUser(ctx.userId, user)
    end
    return user.nono
end

-- 保存NONO数据
local function saveNonoData(ctx, nonoData)
    local user = ctx.getOrCreateUser(ctx.userId)
    user.nono = nonoData
    ctx.saveUser(ctx.userId, user)
end

-- 构建完整NONO信息响应体 (用于9003 NONO_INFO)
-- NonoInfo: userID(4) + flag(4) + state(4) + nick(16) + superNono(4) + color(4) + 
--           power(4) + mate(4) + iq(4) + ai(2) + birth(4) + chargeTime(4) + 
--           func(20 bytes) + superEnergy(4) + superLevel(4) + superStage(4)
-- 总长度: 4+4+4+16+4+4+4+4+4+2+4+4+20+4+4+4 = 86 bytes
local function buildNonoInfoBody(userId, nonoData)
    local body = ""
    body = body .. writeUInt32BE(userId)                    -- userID
    body = body .. writeUInt32BE(nonoData.flag or 1)        -- flag (32 bits)
    body = body .. writeUInt32BE(nonoData.state or 1)       -- state (32 bits)
    body = body .. writeFixedString(nonoData.nick or "NoNo", 16)  -- nick
    body = body .. writeUInt32BE(nonoData.superNono or 1)   -- superNono
    body = body .. writeUInt32BE(nonoData.color or 0x00FBF4E1)  -- color
    body = body .. writeUInt32BE(nonoData.power or 80000)   -- power (*1000)
    body = body .. writeUInt32BE(nonoData.mate or 80000)    -- mate (*1000)
    body = body .. writeUInt32BE(nonoData.iq or 100)        -- iq
    body = body .. writeUInt16BE(nonoData.ai or 100)        -- ai
    body = body .. writeUInt32BE(nonoData.birth or os.time())  -- birth
    body = body .. writeUInt32BE(nonoData.chargeTime or 0)  -- chargeTime
    -- func: 20 bytes (160 bits of function flags) - 所有功能开启
    body = body .. string.rep("\xFF", 20)
    body = body .. writeUInt32BE(nonoData.superEnergy or 10000)  -- superEnergy
    body = body .. writeUInt32BE(nonoData.superLevel or 10)      -- superLevel
    body = body .. writeUInt32BE(nonoData.superStage or 3)       -- superStage
    return body
end

-- 构建简化NONO信息 (用于9019 NONO_FOLLOW_OR_HOOM)
-- 官服数据: userID(4) + flag(4) + state(4) + nick(16) + color(4) + ...
local function buildNonoFollowBody(userId, nonoData, isFollowing)
    local body = ""
    body = body .. writeUInt32BE(userId)                    -- userID
    body = body .. writeUInt32BE(isFollowing and 1 or 0)    -- flag/isFollowing
    body = body .. writeUInt32BE(nonoData.state or 1)       -- state
    body = body .. writeFixedString(nonoData.nick or "NoNo", 16)  -- nick
    body = body .. writeUInt32BE(nonoData.color or 0x00FBF4E1)  -- color
    return body
end

-- CMD 9001: NONO_OPEN (开启NONO)
local function handleNonoOpen(ctx)
    local nonoData = getNonoData(ctx)
    local body = buildNonoInfoBody(ctx.userId, nonoData)
    ctx.sendResponse(buildResponse(9001, ctx.userId, 0, body))
    print("\27[32m[Handler] → NONO_OPEN response\27[0m")
    return true
end

-- CMD 9002: NONO_CHANGE_NAME (修改NONO名字)
local function handleNonoChangeName(ctx)
    -- 解析新名字 (16 bytes)
    local newNick = "NoNo"
    if #ctx.body >= 16 then
        newNick = ctx.body:sub(1, 16):gsub("%z+$", "")  -- 去除尾部空字符
    end
    
    local nonoData = getNonoData(ctx)
    nonoData.nick = newNick
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9002, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → NONO_CHANGE_NAME '%s' response\27[0m", newNick))
    return true
end

-- CMD 9003: NONO_INFO (获取NONO信息)
local function handleNonoInfo(ctx)
    local nonoData = getNonoData(ctx)
    local body = buildNonoInfoBody(ctx.userId, nonoData)
    ctx.sendResponse(buildResponse(9003, ctx.userId, 0, body))
    print("\27[32m[Handler] → NONO_INFO response\27[0m")
    return true
end

-- CMD 9004: NONO_CHIP_MIXTURE (芯片合成)
local function handleNonoChipMixture(ctx)
    ctx.sendResponse(buildResponse(9004, ctx.userId, 0, writeUInt32BE(0)))
    print("\27[32m[Handler] → NONO_CHIP_MIXTURE response\27[0m")
    return true
end

-- CMD 9007: NONO_CURE (治疗NONO)
local function handleNonoCure(ctx)
    local nonoData = getNonoData(ctx)
    nonoData.power = 100000  -- 恢复满体力
    nonoData.mate = 100000   -- 恢复满心情
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9007, ctx.userId, 0, ""))
    print("\27[32m[Handler] → NONO_CURE response\27[0m")
    return true
end

-- CMD 9008: NONO_EXPADM (NONO经验管理)
local function handleNonoExpadm(ctx)
    ctx.sendResponse(buildResponse(9008, ctx.userId, 0, ""))
    print("\27[32m[Handler] → NONO_EXPADM response\27[0m")
    return true
end

-- CMD 9010: NONO_IMPLEMENT_TOOL (使用NONO道具)
-- 响应: id(4) + itemId(4) + power(4) + ai(2) + mate(4) + iq(4)
local function handleNonoImplementTool(ctx)
    local nonoData = getNonoData(ctx)
    local body = ""
    body = body .. writeUInt32BE(0)                     -- id (ret)
    body = body .. writeUInt32BE(0)                     -- itemId
    body = body .. writeUInt32BE(nonoData.power)        -- power (*1000)
    body = body .. writeUInt16BE(nonoData.ai)           -- ai
    body = body .. writeUInt32BE(nonoData.mate)         -- mate (*1000)
    body = body .. writeUInt32BE(nonoData.iq)           -- iq
    ctx.sendResponse(buildResponse(9010, ctx.userId, 0, body))
    print("\27[32m[Handler] → NONO_IMPLEMENT_TOOL response\27[0m")
    return true
end

-- CMD 9012: NONO_CHANGE_COLOR (改变NONO颜色)
local function handleNonoChangeColor(ctx)
    local newColor = 0x00FBF4E1
    if #ctx.body >= 4 then
        newColor = readUInt32BE(ctx.body, 1)
    end
    
    local nonoData = getNonoData(ctx)
    nonoData.color = newColor
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9012, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → NONO_CHANGE_COLOR 0x%X response\27[0m", newColor))
    return true
end

-- CMD 9013: NONO_PLAY (NONO玩耍)
local function handleNonoPlay(ctx)
    local nonoData = getNonoData(ctx)
    -- 玩耍增加心情
    nonoData.mate = math.min(100000, nonoData.mate + 5000)
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9013, ctx.userId, 0, ""))
    print("\27[32m[Handler] → NONO_PLAY response\27[0m")
    return true
end

-- CMD 9014: NONO_CLOSE_OPEN (NONO开关)
-- 官服响应: userID(4) + flag(4)
local function handleNonoCloseOpen(ctx)
    local action = 0
    if #ctx.body >= 4 then
        action = readUInt32BE(ctx.body, 1)
    end
    
    local nonoData = getNonoData(ctx)
    nonoData.state = action  -- 0=关闭, 1=开启
    saveNonoData(ctx, nonoData)
    
    local body = writeUInt32BE(ctx.userId) .. writeUInt32BE(action)
    ctx.sendResponse(buildResponse(9014, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → NONO_CLOSE_OPEN %d response\27[0m", action))
    return true
end

-- CMD 9015: NONO_EXE_LIST (NONO执行列表)
local function handleNonoExeList(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(9015, ctx.userId, 0, body))
    print("\27[32m[Handler] → NONO_EXE_LIST response\27[0m")
    return true
end

-- CMD 9016: NONO_CHARGE (NONO充电)
local function handleNonoCharge(ctx)
    local nonoData = getNonoData(ctx)
    nonoData.superEnergy = math.min(99999, nonoData.superEnergy + 1000)
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9016, ctx.userId, 0, ""))
    print("\27[32m[Handler] → NONO_CHARGE response\27[0m")
    return true
end

-- CMD 9017: NONO_START_EXE (开始执行)
local function handleNonoStartExe(ctx)
    ctx.sendResponse(buildResponse(9017, ctx.userId, 0, ""))
    print("\27[32m[Handler] → NONO_START_EXE response\27[0m")
    return true
end

-- CMD 9018: NONO_END_EXE (结束执行)
local function handleNonoEndExe(ctx)
    ctx.sendResponse(buildResponse(9018, ctx.userId, 0, ""))
    print("\27[32m[Handler] → NONO_END_EXE response\27[0m")
    return true
end

-- CMD 9019: NONO_FOLLOW_OR_HOOM (跟随或回家)
-- 官服响应 (53 bytes): userID(4) + flag(4) + state(4) + nick(16) + color(4) + ...
local function handleNonoFollowOrHoom(ctx)
    local action = 0  -- 0=回家, 1=跟随
    if #ctx.body >= 4 then
        action = readUInt32BE(ctx.body, 1)
    end
    
    local nonoData = getNonoData(ctx)
    nonoData.isFollowing = (action == 1)
    saveNonoData(ctx, nonoData)
    
    local body = buildNonoFollowBody(ctx.userId, nonoData, nonoData.isFollowing)
    ctx.sendResponse(buildResponse(9019, ctx.userId, 0, body))
    
    -- 广播给同地图其他玩家
    if ctx.broadcastToMap then
        ctx.broadcastToMap(buildResponse(9019, ctx.userId, 0, body), ctx.userId)
    end
    
    print(string.format("\27[32m[Handler] → NONO_FOLLOW_OR_HOOM %s response\27[0m", 
        action == 1 and "跟随" or "回家"))
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
    print("\27[32m[Handler] → NONO_OPEN_SUPER response\27[0m")
    return true
end

-- CMD 9021: NONO_HELP_EXP (NONO帮助经验)
local function handleNonoHelpExp(ctx)
    ctx.sendResponse(buildResponse(9021, ctx.userId, 0, ""))
    print("\27[32m[Handler] → NONO_HELP_EXP response\27[0m")
    return true
end

-- CMD 9022: NONO_MATE_CHANGE (NONO心情变化)
local function handleNonoMateChange(ctx)
    ctx.sendResponse(buildResponse(9022, ctx.userId, 0, ""))
    print("\27[32m[Handler] → NONO_MATE_CHANGE response\27[0m")
    return true
end

-- CMD 9023: NONO_GET_CHIP (获取芯片)
local function handleNonoGetChip(ctx)
    local body = writeUInt32BE(0)  -- count = 0
    ctx.sendResponse(buildResponse(9023, ctx.userId, 0, body))
    print("\27[32m[Handler] → NONO_GET_CHIP response\27[0m")
    return true
end

-- CMD 9024: NONO_ADD_ENERGY_MATE (增加能量心情)
local function handleNonoAddEnergyMate(ctx)
    local nonoData = getNonoData(ctx)
    nonoData.power = math.min(100000, nonoData.power + 10000)
    nonoData.mate = math.min(100000, nonoData.mate + 10000)
    saveNonoData(ctx, nonoData)
    
    ctx.sendResponse(buildResponse(9024, ctx.userId, 0, ""))
    print("\27[32m[Handler] → NONO_ADD_ENERGY_MATE response\27[0m")
    return true
end

-- CMD 9025: GET_DIAMOND (获取钻石)
local function handleGetDiamond(ctx)
    local body = writeUInt32BE(9999)  -- 钻石数量
    ctx.sendResponse(buildResponse(9025, ctx.userId, 0, body))
    print("\27[32m[Handler] → GET_DIAMOND response\27[0m")
    return true
end

-- CMD 9026: NONO_ADD_EXP (增加NONO经验)
local function handleNonoAddExp(ctx)
    ctx.sendResponse(buildResponse(9026, ctx.userId, 0, ""))
    print("\27[32m[Handler] → NONO_ADD_EXP response\27[0m")
    return true
end

-- CMD 9027: NONO_IS_INFO (NONO是否有信息)
local function handleNonoIsInfo(ctx)
    local body = writeUInt32BE(1)  -- 有NONO
    ctx.sendResponse(buildResponse(9027, ctx.userId, 0, body))
    print("\27[32m[Handler] → NONO_IS_INFO response\27[0m")
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
    print("\27[36m[Handlers] NONO命令处理器已注册\27[0m")
end

return NonoHandlers
