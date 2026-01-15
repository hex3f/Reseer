-- Bit operations compatibility for Lua 5.1
-- Luvit uses LuaJIT which has bit library

local bit = require('bit')

local bitop = {}

-- 按位与
function bitop.band(a, b)
    return bit.band(a, b)
end

-- 按位或
function bitop.bor(...)
    local args = {...}
    local result = args[1] or 0
    for i = 2, #args do
        result = bit.bor(result, args[i])
    end
    return result
end

-- 按位异或（支持多参数）
function bitop.bxor(...)
    local args = {...}
    local result = args[1] or 0
    for i = 2, #args do
        result = bit.bxor(result, args[i])
    end
    return result
end

-- 按位取反
function bitop.bnot(a)
    return bit.bnot(a)
end

-- 左移
function bitop.lshift(a, b)
    return bit.lshift(a, b)
end

-- 右移
function bitop.rshift(a, b)
    return bit.rshift(a, b)
end

-- 算术右移
function bitop.arshift(a, b)
    return bit.arshift(a, b)
end

return bitop
