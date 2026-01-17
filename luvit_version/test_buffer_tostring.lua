-- 测试 buffer tostring 行为
local buffer = require "buffer"

-- 创建一个 100 字节的 buffer
local buf = buffer.Buffer:new(100)

-- 初始化为全 0
for i = 1, 100 do
    buf:writeUInt8(i, 0)
end

-- 写入任务 85-88 的状态
buf:writeUInt8(85, 3)
buf:writeUInt8(86, 3)
buf:writeUInt8(87, 3)
buf:writeUInt8(88, 3)

-- 转换为字符串
local str = tostring(buf)

print("Buffer 长度:", #str)
print("Buffer 前 20 字节:")
for i = 1, 20 do
    print(string.format("  位置 %d: 0x%02X (%d)", i, string.byte(str, i), string.byte(str, i)))
end

print("\nBuffer 位置 85-88:")
for i = 85, 88 do
    print(string.format("  位置 %d: 0x%02X (%d)", i, string.byte(str, i), string.byte(str, i)))
end

-- 验证：读取字符串的第 85 个字节
print("\n字符串第 85 个字节:", string.byte(str, 85))
