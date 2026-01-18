-- 测试协议验证器
local ProtocolValidator = require('./protocol_validator')

print("========== 协议验证器测试 ==========\n")

-- 辅助函数
local function writeUInt32BE(value)
    return string.char(
        bit.rshift(bit.band(value, 0xFF000000), 24),
        bit.rshift(bit.band(value, 0x00FF0000), 16),
        bit.rshift(bit.band(value, 0x0000FF00), 8),
        bit.band(value, 0x000000FF)
    )
end

local function writeUInt16BE(value)
    return string.char(
        bit.rshift(bit.band(value, 0xFF00), 8),
        bit.band(value, 0x00FF)
    )
end

-- 测试1: 固定大小协议 - ACCEPT_TASK (101)
print("测试1: ACCEPT_TASK (CMD 101) - 固定8字节")
local body1 = writeUInt32BE(87) .. writeUInt32BE(1)
local isValid, expected, actual, msg = ProtocolValidator.validate(101, body1)
print(msg)
print(string.format("  期望: %d字节, 实际: %d字节, 验证: %s\n", expected, actual, isValid and "通过" or "失败"))

-- 测试2: 固定大小协议错误 - ACCEPT_TASK 大小错误
print("测试2: ACCEPT_TASK (CMD 101) - 错误大小")
local body2 = writeUInt32BE(87)  -- 只有4字节
isValid, expected, actual, msg = ProtocolValidator.validate(101, body2)
print(msg)
print(string.format("  期望: %d字节, 实际: %d字节, 验证: %s\n", expected, actual, isValid and "通过" or "失败"))

-- 测试3: 动态大小协议 - TASK_LIST (100)
print("测试3: TASK_LIST (CMD 100) - 动态大小，3个任务")
local body3 = writeUInt32BE(3)  -- 3个任务
    .. writeUInt32BE(87) .. writeUInt32BE(0)  -- 任务1
    .. writeUInt32BE(88) .. writeUInt32BE(1)  -- 任务2
    .. writeUInt32BE(89) .. writeUInt32BE(2)  -- 任务3
isValid, expected, actual, msg = ProtocolValidator.validate(100, body3)
print(msg)
print(string.format("  期望: %d字节, 实际: %d字节, 验证: %s\n", expected, actual, isValid and "通过" or "失败"))

-- 测试4: PET_RELEASE (2304) - 有精灵信息
print("测试4: PET_RELEASE (CMD 2304) - 有精灵信息，无effect")
local body4 = writeUInt32BE(0)  -- homeEnergy
    .. writeUInt32BE(12345)  -- catchId
    .. writeUInt32BE(1)  -- flag
    -- PetInfo
    .. writeUInt32BE(1)  -- id
    .. string.rep("\0", 16)  -- name
    .. writeUInt32BE(31)  -- dv
    .. writeUInt32BE(5)  -- nature
    .. writeUInt32BE(5)  -- level
    .. writeUInt32BE(0)  -- exp
    .. writeUInt32BE(0)  -- lvExp
    .. writeUInt32BE(100)  -- nextLvExp
    .. writeUInt32BE(20)  -- hp
    .. writeUInt32BE(20)  -- maxHp
    .. writeUInt32BE(12)  -- attack
    .. writeUInt32BE(12)  -- defence
    .. writeUInt32BE(11)  -- s_a
    .. writeUInt32BE(10)  -- s_d
    .. writeUInt32BE(12)  -- speed
    .. writeUInt32BE(0) .. writeUInt32BE(0) .. writeUInt32BE(0)  -- ev
    .. writeUInt32BE(0) .. writeUInt32BE(0) .. writeUInt32BE(0)
    .. writeUInt32BE(2)  -- skillNum
    .. writeUInt32BE(100) .. writeUInt32BE(35)  -- skill1
    .. writeUInt32BE(101) .. writeUInt32BE(35)  -- skill2
    .. writeUInt32BE(0) .. writeUInt32BE(0)  -- skill3
    .. writeUInt32BE(0) .. writeUInt32BE(0)  -- skill4
    .. writeUInt32BE(12345)  -- catchTime
    .. writeUInt32BE(301)  -- catchMap
    .. writeUInt32BE(0)  -- catchRect
    .. writeUInt32BE(5)  -- catchLevel
    .. writeUInt16BE(0)  -- effectCount
    .. writeUInt32BE(0)  -- skinID
isValid, expected, actual, msg = ProtocolValidator.validate(2304, body4)
print(msg)
print(string.format("  期望: %d字节, 实际: %d字节, 验证: %s\n", expected, actual, isValid and "通过" or "失败"))

-- 测试5: 未定义协议
print("测试5: 未定义协议 (CMD 9999)")
local body5 = "test"
isValid, expected, actual, msg = ProtocolValidator.validate(9999, body5)
print(msg)
print(string.format("  期望: %s, 实际: %d字节, 验证: %s\n", expected or "未知", actual, isValid and "通过" or "失败"))

-- 列出所有已定义的协议
print("\n========== 已定义的协议列表 ==========")
local protocols = ProtocolValidator.listProtocols()
for _, p in ipairs(protocols) do
    local sizeInfo = ""
    if p.isDynamic then
        sizeInfo = string.format("≥%d字节 (动态)", p.minSize)
    elseif p.minSize == p.maxSize then
        sizeInfo = string.format("%d字节 (固定)", p.minSize)
    else
        local maxStr = p.maxSize and tostring(p.maxSize) or "∞"
        sizeInfo = string.format("%d-%s字节", p.minSize, maxStr)
    end
    print(string.format("CMD %4d: %-25s %s", p.cmdId, p.name, sizeInfo))
end

print("\n========== 测试完成 ==========")
