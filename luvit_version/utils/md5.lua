-- MD5 implementation in pure Lua
-- Based on RFC 1321

local bit = require('./bitop_compat')

local md5 = {}

-- Helper functions
local function bxor(a, b) return bit.bxor(a, b) end
local function band(a, b) return bit.band(a, b) end
local function bor(a, b) return bit.bor(a, b) end
local function bnot(a) return bit.bnot(a) end
local function lshift(a, n) return bit.lshift(a, n) end
local function rshift(a, n) return bit.rshift(a, n) end

local function lrotate(x, n)
    return bor(lshift(band(x, 0xFFFFFFFF), n), rshift(band(x, 0xFFFFFFFF), 32 - n))
end

-- MD5 constants
local K = {
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
}

local S = {
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
    5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
}

local function F(x, y, z) return bor(band(x, y), band(bnot(x), z)) end
local function G(x, y, z) return bor(band(x, z), band(y, bnot(z))) end
local function H(x, y, z) return bxor(x, bxor(y, z)) end
local function I(x, y, z) return bxor(y, bor(x, bnot(z))) end

local function add32(...)
    local sum = 0
    for _, v in ipairs({...}) do
        sum = sum + v
    end
    return band(sum, 0xFFFFFFFF)
end

local function str2word(s, i)
    return s:byte(i) + s:byte(i+1) * 256 + s:byte(i+2) * 65536 + s:byte(i+3) * 16777216
end

local function word2str(w)
    return string.char(
        band(w, 0xFF),
        band(rshift(w, 8), 0xFF),
        band(rshift(w, 16), 0xFF),
        band(rshift(w, 24), 0xFF)
    )
end

function md5.sum(s)
    local msgLen = #s
    local padLen = (55 - msgLen) % 64
    
    -- Padding
    s = s .. "\128" .. string.rep("\0", padLen)
    
    -- Append length (in bits)
    local lenBits = msgLen * 8
    s = s .. word2str(band(lenBits, 0xFFFFFFFF))
    s = s .. word2str(0)  -- High 32 bits (assuming message < 2^32 bits)
    
    -- Initialize
    local a0, b0, c0, d0 = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
    
    -- Process each 64-byte chunk
    for chunk = 1, #s, 64 do
        local M = {}
        for i = 0, 15 do
            M[i] = str2word(s, chunk + i * 4)
        end
        
        local A, B, C, D = a0, b0, c0, d0
        
        for i = 0, 63 do
            local f, g
            if i < 16 then
                f = F(B, C, D)
                g = i
            elseif i < 32 then
                f = G(B, C, D)
                g = (5 * i + 1) % 16
            elseif i < 48 then
                f = H(B, C, D)
                g = (3 * i + 5) % 16
            else
                f = I(B, C, D)
                g = (7 * i) % 16
            end
            
            local temp = D
            D = C
            C = B
            B = add32(B, lrotate(add32(A, f, K[i+1], M[g]), S[i+1]))
            A = temp
        end
        
        a0 = add32(a0, A)
        b0 = add32(b0, B)
        c0 = add32(c0, C)
        d0 = add32(d0, D)
    end
    
    return word2str(a0) .. word2str(b0) .. word2str(c0) .. word2str(d0)
end

function md5.sumhexa(s)
    local digest = md5.sum(s)
    local hex = ""
    for i = 1, #digest do
        hex = hex .. string.format("%02x", digest:byte(i))
    end
    return hex
end

return md5
