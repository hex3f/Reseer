-- 测试 buffer 索引
local buffer = require "buffer"

-- 创建一个 10 字节的 buffer
local buf = buffer.Buffer:new(10)

-- 初始化为全 0 (Lua 索引从 1 开始)
for i = 1, 10 do
    buf:writeUInt8(i, 0)
end

-- 测试写入
print("测试 1: writeUInt8(1, 65) - 写入 'A' 到位置 1")
buf:writeUInt8(1, 65)  -- 'A'
print("位置 1 的值:", buf:readUInt8(1))

print("\n测试 2: writeUInt8(2, 66) - 写入 'B' 到位置 2")
buf:writeUInt8(2, 66)  -- 'B'
print("位置 2 的值:", buf:readUInt8(2))

print("\n测试 3: writeUInt8(6, 67) - 写入 'C' 到位置 6")
buf:writeUInt8(6, 67)  -- 'C'
print("位置 6 的值:", buf:readUInt8(6))

-- 打印整个 buffer
print("\n完整 buffer 内容:")
for i = 1, 10 do
    local val = buf:readUInt8(i)
    print(string.format("  位置 %d: %d (%s)", i, val, val > 0 and string.char(val) or "0"))
end

-- 测试任务状态场景
print("\n\n=== 任务状态场景测试 ===")
local taskBuf = buffer.Buffer:new(100)

-- 初始化为全 0 (Lua 索引从 1 开始)
for i = 1, 100 do
    taskBuf:writeUInt8(i, 0)
end

-- 模拟任务 85 状态为 completed (3)
-- 客户端 ActionScript: TasksManager.taskList[84] 对应任务 85
-- 客户端读取第 85 个字节（索引 84）
-- 服务器 Lua: buffer 索引从 1 开始，第 85 个字节是位置 85
print("写入任务 85 状态 (completed=3) 到位置 85:")
taskBuf:writeUInt8(85, 3)

-- 读取验证
print("读取位置 84:", taskBuf:readUInt8(84))
print("读取位置 85:", taskBuf:readUInt8(85))

print("\n客户端读取逻辑:")
print("  客户端按顺序读取 500 个字节")
print("  第 1 次读取 → TasksManager.taskList[0] → 任务 1")
print("  第 85 次读取 → TasksManager.taskList[84] → 任务 85")
print("  服务器位置 85 对应客户端第 85 次读取")
print("  所以任务 85 应该写入到服务器位置 85")

