-- Session file analyzer for Seer
-- 分析 sessionlog 中的 .bin 文件

local bit = require "../bitop_compat"

-- 读取文件
local function readFile(path)
    local f = io.open(path, "rb")
    if not f then return nil end
    local data = f:read("*all")
    f:close()
    return data
end

-- 解析数据包头
local function parsePacketHeader(data, offset)
    if #data < offset + 16 then return nil end
    
    local length = (data:byte(offset) * 16777216) + 
                   (data:byte(offset+1) * 65536) + 
                   (data:byte(offset+2) * 256) + 
                   data:byte(offset+3)
    local version = data:byte(offset+4)
    local cmdId = (data:byte(offset+5) * 16777216) + 
                  (data:byte(offset+6) * 65536) + 
                  (data:byte(offset+7) * 256) + 
                  data:byte(offset+8)
    local userId = (data:byte(offset+9) * 16777216) + 
                   (data:byte(offset+10) * 65536) + 
                   (data:byte(offset+11) * 256) + 
                   data:byte(offset+12)
    local result = (data:byte(offset+13) * 16777216) + 
                   (data:byte(offset+14) * 65536) + 
                   (data:byte(offset+15) * 256) + 
                   data:byte(offset+16)
    
    return {
        length = length,
        version = version,
        cmdId = cmdId,
        userId = userId,
        result = result
    }
end

-- 加载赛尔号命令列表
local seerCmdList = nil
pcall(function()
    seerCmdList = require('./seer_cmdlist')
end)

-- 获取命令名称
local function getCmdName(cmdId)
    if seerCmdList and seerCmdList[cmdId] then
        return seerCmdList[cmdId].note
    end
    -- 备用映射
    local cmdNames = {
        [1001] = "登录游戏服务器",
        [1002] = "心跳包",
        [401] = "进入地图",
        [402] = "离开地图",
        [405] = "场景用户信息",
        [406] = "获取地图信息",
        [303] = "走路",
        [302] = "聊天",
        [305] = "动作",
    }
    return cmdNames[cmdId] or "未知命令"
end

-- 分析会话文件
local function analyzeSession(path)
    local data = readFile(path)
    if not data then
        print("无法读取文件: " .. path)
        return
    end
    
    print(string.format("文件大小: %d 字节", #data))
    print("=" .. string.rep("=", 70))
    
    local pos = 1
    local packetNum = 0
    
    while pos < #data do
        -- 查找标记
        local cliMarker = "\x0D\x0A\xDE\xAD\x43\x4C\x49\xBE\xEF\x0D\x0A"  -- CLI marker
        local srvMarker = "\x0D\x0A\xDE\xAD\x53\x52\x56\xBE\xEF\x0D\x0A"  -- SRV marker
        
        local cliPos = data:find(cliMarker, pos, true)
        local srvPos = data:find(srvMarker, pos, true)
        
        local nextPos, direction
        if cliPos and srvPos then
            if cliPos < srvPos then
                nextPos = cliPos
                direction = "CLIENT→SERVER"
            else
                nextPos = srvPos
                direction = "SERVER→CLIENT"
            end
        elseif cliPos then
            nextPos = cliPos
            direction = "CLIENT→SERVER"
        elseif srvPos then
            nextPos = srvPos
            direction = "SERVER→CLIENT"
        else
            break
        end
        
        -- 跳过标记和时间戳
        local markerEnd = nextPos + 11
        local timestampEnd = data:find("\x0D\x0A", markerEnd, true)
        if not timestampEnd then break end
        
        local timestamp = data:sub(markerEnd, timestampEnd - 1)
        local packetStart = timestampEnd + 2
        
        -- 解析数据包
        local header = parsePacketHeader(data, packetStart)
        if header and header.cmdId < 100000 and header.length < 100000 then
            -- 合理的命令号和长度，说明数据可能是明文
            packetNum = packetNum + 1
            local cmdName = getCmdName(header.cmdId)
            
            print(string.format("[%d] %s @ %.3f", packetNum, direction, tonumber(timestamp) or 0))
            print(string.format("    CMD=%d (%s), UID=%d, LEN=%d, VER=0x%02X, RESULT=%d",
                header.cmdId, cmdName, header.userId, header.length, header.version, header.result))
            
            -- 显示前32字节的hex
            local hexStr = ""
            for i = 0, math.min(31, header.length - 1) do
                if packetStart + i <= #data then
                    hexStr = hexStr .. string.format("%02X ", data:byte(packetStart + i))
                end
            end
            print("    HEX: " .. hexStr)
            print("")
            
            pos = packetStart + header.length
        else
            -- 数据可能是加密的，跳过
            print(string.format("[?] %s @ %.3f - 数据可能是加密的", direction, tonumber(timestamp) or 0))
            -- 尝试找下一个标记
            local nextCli = data:find(cliMarker, packetStart + 1, true)
            local nextSrv = data:find(srvMarker, packetStart + 1, true)
            if nextCli or nextSrv then
                pos = math.min(nextCli or #data, nextSrv or #data)
            else
                break
            end
        end
    end
    
    print("=" .. string.rep("=", 70))
    print(string.format("共解析 %d 个数据包", packetNum))
end

-- 主程序
local filename = "sessionlog/1768251623-34.927-472.bin"
-- 尝试获取命令行参数
pcall(function()
    local proc = require("process")
    if proc and proc.argv and proc.argv[2] then
        filename = proc.argv[2]
    end
end)
print("分析会话文件: " .. filename)
print("")
analyzeSession(filename)
