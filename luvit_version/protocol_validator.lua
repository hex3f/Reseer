-- 协议验证器
-- 用于验证每个CMD的包体大小是否符合客户端期望

local ProtocolValidator = {}

-- 协议定义表
-- 格式: [cmdId] = {name, minSize, maxSize, calculateSize}
-- minSize/maxSize: 固定大小协议两者相等，动态大小协议设置范围
-- calculateSize: 可选的函数，用于动态计算期望大小
ProtocolValidator.protocols = {
    -- ========== 任务相关 ==========
    [100] = {
        name = "TASK_LIST",
        minSize = 4,  -- 至少包含任务数量(4字节)
        maxSize = nil,  -- 动态大小
        calculateSize = function(body)
            if #body < 4 then return 4 end
            local taskCount = string.byte(body, 1) * 0x1000000 + 
                            string.byte(body, 2) * 0x10000 + 
                            string.byte(body, 3) * 0x100 + 
                            string.byte(body, 4)
            -- 每个任务: id(4) + status(4) = 8字节
            return 4 + taskCount * 8
        end
    },
    
    [101] = {
        name = "ACCEPT_TASK",
        minSize = 8,
        maxSize = 8,
        description = "taskId(4) + status(4)"
    },
    
    [102] = {
        name = "COMPLETE_TASK",
        minSize = 4,
        maxSize = nil,  -- 动态大小
        description = "taskId(4) + 奖励信息（动态）"
    },
    
    -- ========== 地图相关 ==========
    [2001] = {
        name = "ENTER_MAP",
        minSize = 144,  -- 基础大小(clothes=0时)
        maxSize = nil,  -- 动态大小
        calculateSize = function(body)
            -- 基础部分: 136 bytes (到clothCount之前)
            -- clothCount: 4 bytes
            -- curTitle: 4 bytes
            if #body < 140 then return 144 end
            
            -- 读取clothes count (在第137-140字节位置)
            local clothesCount = string.byte(body, 137) * 0x1000000 + 
                               string.byte(body, 138) * 0x10000 + 
                               string.byte(body, 139) * 0x100 + 
                               string.byte(body, 140)
            
            -- 每件服装: clothId(4) + level(4) = 8 bytes
            return 144 + clothesCount * 8
        end,
        description = "玩家信息 + 地图信息 (动态大小，取决于服装数量)"
    },
    
    [2002] = {
        name = "LEAVE_MAP",
        minSize = 4,
        maxSize = 4,
        description = "userId(4)"
    },
    
    [2003] = {
        name = "LIST_MAP_PLAYER",
        minSize = 4,
        maxSize = nil,
        calculateSize = function(body)
            if #body < 4 then return 4 end
            local playerCount = string.byte(body, 1) * 0x1000000 + 
                              string.byte(body, 2) * 0x10000 + 
                              string.byte(body, 3) * 0x100 + 
                              string.byte(body, 4)
            -- 每个玩家的PeopleInfo是动态大小的(取决于服装数量)
            -- 基础: 140 bytes + clothCount(4) + clothes数据 + curTitle(4)
            -- 为简化，假设每个玩家平均0件服装 = 144 bytes
            -- TODO: 需要逐个解析每个玩家的clothCount来精确计算
            return 4 + playerCount * 144
        end,
        description = "playerCount(4) + 玩家列表（动态，每个玩家144+字节）"
    },
    
    [2101] = {
        name = "PEOPLE_WALK",
        minSize = 16,  -- walkType(4) + userId(4) + x(4) + y(4)
        maxSize = nil, -- 可变大小，后面可能跟随路径数据
        description = "人物移动（可变大小：基础16字节 + 路径数据）"
    },
    
    -- ========== 任务相关 ==========
    [2201] = {
        name = "ACCEPT_TASK",
        minSize = 4,
        maxSize = 4,
        description = "taskId(4)"
    },
    
    [2202] = {
        name = "COMPLETE_TASK",
        minSize = 4,
        maxSize = nil,
        description = "taskId(4) + 奖励信息（动态）"
    },
    
    -- ========== 精灵相关 ==========
    [2301] = {
        name = "GET_PET_INFO",
        minSize = 154,  -- PetInfo完整结构(param2=true)
        maxSize = nil,  -- 动态(因为effectList)
        calculateSize = function(body)
            -- 基础PetInfo: 154字节(不含effectList)
            -- id(4) + name(16) + dv(4) + nature(4) + level(4) + exp(4) + lvExp(4) + nextLvExp(4)
            -- + hp(4) + maxHp(4) + attack(4) + defence(4) + s_a(4) + s_d(4) + speed(4)
            -- + ev_hp(4) + ev_attack(4) + ev_defence(4) + ev_sa(4) + ev_sd(4) + ev_sp(4)
            -- + skillNum(4) + skills[4]*(id(4)+pp(4)) + catchTime(4) + catchMap(4) + catchRect(4) + catchLevel(4)
            -- + effectCount(2) + skinID(4)
            if #body < 138 then return 154 end
            -- 读取effectCount (在第137-138字节位置)
            local effectCount = string.byte(body, 137) * 0x100 + string.byte(body, 138)
            -- 每个PetEffectInfo: 24字节
            return 154 + effectCount * 24
        end
    },
    
    [2303] = {
        name = "GET_PET_LIST",
        minSize = 4,  -- petCount(4)
        maxSize = nil,
        calculateSize = function(body)
            if #body < 4 then return 4 end
            local petCount = string.byte(body, 1) * 0x1000000 + 
                           string.byte(body, 2) * 0x10000 + 
                           string.byte(body, 3) * 0x100 + 
                           string.byte(body, 4)
            -- 每个精灵: id(4) + catchTime(4) + skinID(4) = 12字节
            return 4 + petCount * 12
        end,
        description = "获取精灵列表（每只精灵12字节）"
    },
    
    [2304] = {
        name = "PET_RELEASE",
        minSize = 12,  -- homeEnergy(4) + firstPetTime(4) + flag(4)
        maxSize = nil,
        calculateSize = function(body)
            if #body < 12 then return 12 end
            local flag = string.byte(body, 9) * 0x1000000 + 
                        string.byte(body, 10) * 0x10000 + 
                        string.byte(body, 11) * 0x100 + 
                        string.byte(body, 12)
            if flag == 0 then
                return 12  -- 没有精灵信息
            else
                -- PetInfo完整结构: 154字节
                if #body < 150 then return 166 end
                -- 读取effectCount (在第149-150字节位置，相对body起始)
                local effectCount = string.byte(body, 149) * 0x100 + string.byte(body, 150)
                return 12 + 154 + effectCount * 24
            end
        end
    },
    
    -- ========== 战斗相关 ==========
    [2404] = {
        name = "READY_TO_FIGHT",
        minSize = 0,
        maxSize = 0,
        description = "空包体"
    },
    
    [2405] = {
        name = "USE_SKILL",
        minSize = 0,
        maxSize = 0,
        description = "空包体(确认)"
    },
    
    [2411] = {
        name = "CHALLENGE_BOSS",
        minSize = 0,
        maxSize = 0,
        description = "空包体"
    },
    
    [2504] = {
        name = "NOTE_START_FIGHT",
        minSize = 104,
        maxSize = 104,
        description = "战斗开始通知: 玩家FightPetInfo(52) + 敌人FightPetInfo(52)"
    },
    
    [2505] = {
        name = "NOTE_USE_SKILL",
        minSize = 180,
        maxSize = nil,  -- 动态大小（技能数量可变）
        description = "firstAttackInfo(AttackValue) + secondAttackInfo(AttackValue), 每个AttackValue约90字节"
    },
    
    [2506] = {
        name = "FIGHT_OVER",
        minSize = 28,
        maxSize = 28,
        description = "reason(4) + winnerID(4) + twoTimes(4) + threeTimes(4) + autoFightTimes(4) + energyTimes(4) + learnTimes(4)"
    },
    
    [2507] = {
        name = "NOTE_UPDATE_SKILL",
        minSize = 16,
        maxSize = 16,
        description = "userID(4) + skillID(4) + skillPP(4) + skillMaxPP(4)"
    },
    
    [2508] = {
        name = "NOTE_UPDATE_PROP",
        minSize = 80,
        maxSize = 80,
        description = "catchTime(4) + petID(4) + level(4) + exp(4) + maxExp(4) + hp(4) + maxHp(4) + attack(4) + defence(4) + s_a(4) + s_d(4) + speed(4) + ev_hp(4) + ev_attack(4) + ev_defence(4) + ev_sa(4) + ev_sd(4) + ev_sp(4) + 其他字段"
    },
    
    -- ========== 其他 ==========
    [1001] = {
        name = "LOGIN_IN",
        minSize = 1146,  -- 基础大小(clothes=0时)
        maxSize = nil,   -- 动态大小(取决于clothes数量)
        description = "登录响应完整信息",
        calculateSize = function(body)
            -- 基础大小: 1146 bytes (clothes=0时)
            -- clothes数据从偏移 938 开始 (0-based), Lua索引 939 (1-based)
            if #body < 942 then return 1146 end
            
            -- 读取clothes count (在第939-942字节位置，Lua索引从1开始)
            local clothesCount = string.byte(body, 939) * 0x1000000 + 
                               string.byte(body, 940) * 0x10000 + 
                               string.byte(body, 941) * 0x100 + 
                               string.byte(body, 942)
            
            -- 每个cloth: id(4) + level(4) = 8 bytes
            -- 注意：客户端把第二个字段当作 level 读取，不是 expireTime
            -- 总大小 = 1146 (基础) + clothCount * 8 (clothes数据)
            local expectedSize = 1146 + clothesCount * 8
            return expectedSize
        end
    },
    
    [1002] = {
        name = "SYSTEM_TIME",
        minSize = 4,
        maxSize = 4,
        description = "timestamp(4)"
    },
    
    [1106] = {
        name = "GOLD_ONLINE_CHECK_REMAIN",
        minSize = 4,
        maxSize = 4,
        description = "goldAmount(4)"
    },
    
    [2150] = {
        name = "GET_RELATION_LIST",
        minSize = 8,
        maxSize = nil,
        description = "friendCount(4) + blackCount(4) + 好友列表 + 黑名单列表（动态）"
    },
    
    [2354] = {
        name = "GET_SOUL_BEAD_List",
        minSize = 4,
        maxSize = nil,
        description = "count(4) + 灵魂珠列表（动态）"
    },
    
    [2503] = {
        name = "NOTE_READY_TO_FIGHT",
        minSize = 196,
        maxSize = nil,
        description = "战斗准备通知: userCount(4) + 玩家信息 + 精灵列表（动态）"
    },
    
    [2757] = {
        name = "MAIL_GET_UNREAD",
        minSize = 4,
        maxSize = 4,
        description = "unreadCount(4)"
    },
    
    [8004] = {
        name = "GET_BOSS_MONSTER",
        minSize = 24,
        maxSize = 24,
        description = "BOSS战斗奖励信息"
    },
    
    [9003] = {
        name = "NONO_INFO",
        minSize = 90,
        maxSize = 90,
        description = "NoNo信息: userID(4) + flag(4) + state(4) + nick(16) + superNono(4) + color(4) + power(4) + mate(4) + iq(4) + ai(2) + birth(4) + chargeTime(4) + func(20) + superEnergy(4) + superLevel(4) + superStage(4) = 90字节"
    },
    
    [70001] = {
        name = "GET_EXCHANGE_INFO",
        minSize = 4,
        maxSize = 4,
        description = "荣誉值(4)"
    },
    
    -- ========== 物品相关 ==========
    [2601] = {
        name = "ITEM_BUY",
        minSize = 16,
        maxSize = 16,
        description = "购买响应: Coins(4) + ItemID(4) + Count(4) + Padding(4)"
    },
    
    [2604] = {
        name = "CHANGE_CLOTH",
        minSize = 8,  -- userID(4) + clothCount(4)
        maxSize = nil,
        calculateSize = function(body)
            if #body < 8 then return 8 end
            local clothCount = string.byte(body, 5) * 0x1000000 + 
                             string.byte(body, 6) * 0x10000 + 
                             string.byte(body, 7) * 0x100 + 
                             string.byte(body, 8)
            -- 每件服装: clothId(4) + clothType(4) = 8字节
            return 8 + clothCount * 8
        end,
        description = "更换服装: userID(4) + clothCount(4) + [clothId(4) + clothType(4)]..."
    },
    
    [2605] = {
        name = "ITEM_LIST",
        minSize = 4,
        maxSize = nil,
        calculateSize = function(body)
            if #body < 4 then return 4 end
            local itemCount = string.byte(body, 1) * 0x1000000 + 
                            string.byte(body, 2) * 0x10000 + 
                            string.byte(body, 3) * 0x100 + 
                            string.byte(body, 4)
            -- 每个物品: itemID(4) + count(4) + obtainTime(8) = 16字节
            return 4 + itemCount * 16
        end
    },
}

-- 验证包体大小
-- @param cmdId 命令ID
-- @param body 包体数据
-- @return isValid, expectedSize, actualSize, message
function ProtocolValidator.validate(cmdId, body)
    local protocol = ProtocolValidator.protocols[cmdId]
    
    if not protocol then
        -- 未定义的协议，只记录警告
        return true, nil, #body, string.format("⚠️  未定义协议 CMD %d", cmdId)
    end
    
    local actualSize = #body
    local expectedSize = nil
    
    -- 计算期望大小
    if protocol.calculateSize then
        expectedSize = protocol.calculateSize(body)
    elseif protocol.maxSize then
        expectedSize = protocol.maxSize
    else
        expectedSize = protocol.minSize
    end
    
    -- 验证大小
    local isValid = true
    local message = ""
    
    if protocol.maxSize == nil and protocol.calculateSize then
        -- 动态大小协议
        if actualSize < protocol.minSize then
            isValid = false
            message = string.format("❌ [%s] 包体过小: 期望≥%d字节, 实际%d字节", 
                protocol.name, protocol.minSize, actualSize)
        elseif actualSize ~= expectedSize then
            isValid = false
            message = string.format("❌ [%s] 包体大小不匹配: 期望%d字节, 实际%d字节", 
                protocol.name, expectedSize, actualSize)
        else
            message = string.format("✓ [%s] 包体大小正确: %d字节", 
                protocol.name, actualSize)
        end
    elseif protocol.minSize == protocol.maxSize then
        -- 固定大小协议
        if actualSize ~= expectedSize then
            isValid = false
            message = string.format("❌ [%s] 包体大小错误: 期望%d字节, 实际%d字节 (%s)", 
                protocol.name, expectedSize, actualSize, protocol.description or "")
        else
            message = string.format("✓ [%s] 包体大小正确: %d字节", 
                protocol.name, actualSize)
        end
    else
        -- 范围大小协议
        if actualSize < protocol.minSize or (protocol.maxSize and actualSize > protocol.maxSize) then
            isValid = false
            message = string.format("❌ [%s] 包体大小超出范围: 期望%d-%d字节, 实际%d字节", 
                protocol.name, protocol.minSize, protocol.maxSize or "∞", actualSize)
        else
            message = string.format("✓ [%s] 包体大小正确: %d字节", 
                protocol.name, actualSize)
        end
    end
    
    return isValid, expectedSize, actualSize, message
end

-- 获取协议信息
function ProtocolValidator.getProtocolInfo(cmdId)
    return ProtocolValidator.protocols[cmdId]
end

-- 列出所有已定义的协议
function ProtocolValidator.listProtocols()
    local list = {}
    for cmdId, protocol in pairs(ProtocolValidator.protocols) do
        table.insert(list, {
            cmdId = cmdId,
            name = protocol.name,
            minSize = protocol.minSize,
            maxSize = protocol.maxSize,
            isDynamic = protocol.calculateSize ~= nil
        })
    end
    table.sort(list, function(a, b) return a.cmdId < b.cmdId end)
    return list
end

return ProtocolValidator
