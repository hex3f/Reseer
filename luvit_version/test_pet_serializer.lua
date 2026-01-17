-- 测试精灵序列化器

local PetSerializer = require('./seer_pet_serializer')

-- 创建测试精灵
local testPet = {
    id = 7,
    name = "",
    dv = 31,
    nature = 24,
    level = 5,
    exp = 0,
    catchTime = 1768539136,
    catchMap = 0,
    catchLevel = 5,
    skinID = 0
}

print("测试精灵序列化...")
print("精灵数据:", require('pretty-print').dump(testPet))

local data = PetSerializer.serializePetInfo(testPet, true)
print(string.format("序列化后大小: %d bytes", #data))
print("期望大小: 170 bytes")

-- 打印前64字节的hex
print("\n前64字节 (hex):")
for i = 1, math.min(64, #data) do
    io.write(string.format("%02X ", string.byte(data, i)))
    if i % 16 == 0 then
        io.write("\n")
    end
end
print("\n")

-- 验证关键字段
local function readUInt32LE(data, pos)
    local b1 = string.byte(data, pos)
    local b2 = string.byte(data, pos + 1)
    local b3 = string.byte(data, pos + 2)
    local b4 = string.byte(data, pos + 3)
    return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

local function readUInt16LE(data, pos)
    local b1 = string.byte(data, pos)
    local b2 = string.byte(data, pos + 1)
    return b1 + b2 * 256
end

print("验证字段:")
print(string.format("  id (offset 1): %d (期望: 7)", readUInt32LE(data, 1)))
print(string.format("  dv (offset 21): %d (期望: 31)", readUInt32LE(data, 21)))
print(string.format("  nature (offset 25): %d (期望: 24)", readUInt32LE(data, 25)))
print(string.format("  level (offset 29): %d (期望: 5)", readUInt32LE(data, 29)))

-- 计算skillNum的位置
local skillNumOffset = 1 + 4 + 16 + 19*4  -- id + name + 19个4字节字段
print(string.format("  skillNum (offset %d): %d", skillNumOffset, readUInt32LE(data, skillNumOffset)))

-- 计算catchTime的位置
local catchTimeOffset = skillNumOffset + 4 + 4*8  -- skillNum + 4个技能槽(每个8字节: id+pp)
print(string.format("  catchTime (offset %d): %d (期望: 1768539136)", catchTimeOffset, readUInt32LE(data, catchTimeOffset)))

-- 计算effectCount的位置
local effectCountOffset = catchTimeOffset + 4*4  -- catchTime + catchMap + catchRect + catchLevel
print(string.format("  effectCount (offset %d): %d (期望: 0)", effectCountOffset, readUInt16LE(data, effectCountOffset)))

-- 计算skinID的位置
local skinIDOffset = effectCountOffset + 2
print(string.format("  skinID (offset %d): %d (期望: 0)", skinIDOffset, readUInt32LE(data, skinIDOffset)))

print(string.format("\n总大小: %d bytes", #data))
print(string.format("最后一个字段结束位置: %d", skinIDOffset + 4))
