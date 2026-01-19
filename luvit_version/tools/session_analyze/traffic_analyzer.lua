-- 流量分析工具
-- 分析捕获的官服通信数据

local fs = require('fs')
local json = require('json')

-- 加载命令列表
local seerCmdList = require('./seer_cmdlist')

local function getCmdName(cmdId)
    if seerCmdList and seerCmdList[cmdId] then 
        return seerCmdList[cmdId].note 
    end
    return "未知命令"
end

-- 解析 hex 字符串为字节数组
local function hexToBytes(hexStr)
    local bytes = {}
    for hex in hexStr:gmatch("%x%x") do
        table.insert(bytes, tonumber(hex, 16))
    end
    return bytes
end

-- 读取 4 字节大端整数
local function readUInt32BE(bytes, offset)
    offset = offset or 1
    return bytes[offset] * 16777216 + 
           bytes[offset + 1] * 65536 + 
           bytes[offset + 2] * 256 + 
           bytes[offset + 3]
end

-- 读取 2 字节大端整数
local function readUInt16BE(bytes, offset)
    offset = offset or 1
    return bytes[offset] * 256 + bytes[offset + 1]
end

-- 读取固定长度字符串
local function readString(bytes, offset, length)
    local str = ""
    for i = offset, offset + length - 1 do
        if bytes[i] and bytes[i] > 0 then
            str = str .. string.char(bytes[i])
        end
    end
    return str
end

-- 分析数据包
local function analyzePacket(entry)
    local bytes = hexToBytes(entry.hex)
    if #bytes < 17 then return end
    
    local length = readUInt32BE(bytes, 1)
    local version = bytes[5]
    local cmdId = readUInt32BE(bytes, 6)
    local userId = readUInt32BE(bytes, 10)
    local result = readUInt32BE(bytes, 14)
    
    print(string.format("\n=== %s ===", entry.time))
    print(string.format("方向: %s", entry.direction == "client_to_server" and "客户端→服务器" or "服务器→客户端"))
    print(string.format("命令: %d (%s)", cmdId, getCmdName(cmdId)))
    print(string.format("用户ID: %d", userId))
    print(string.format("长度: %d", length))
    print(string.format("结果: %d", result))
    
    -- 根据命令类型解析数据体
    if cmdId == 105 and entry.direction == "server_to_client" then
        -- 服务器列表响应
        if #bytes > 17 then
            local maxOnlineID = readUInt32BE(bytes, 18)
            local isVIP = readUInt32BE(bytes, 22)
            local serverCount = readUInt32BE(bytes, 26)
            print(string.format("最大服务器ID: %d", maxOnlineID))
            print(string.format("VIP: %d", isVIP))
            print(string.format("服务器数量: %d", serverCount))
            
            -- 解析服务器列表
            local offset = 30
            for i = 1, math.min(serverCount, 5) do
                if offset + 30 <= #bytes then
                    local serverId = readUInt32BE(bytes, offset)
                    local userCnt = readUInt32BE(bytes, offset + 4)
                    local ip = readString(bytes, offset + 8, 16)
                    local port = readUInt16BE(bytes, offset + 24)
                    print(string.format("  服务器 #%d: ID=%d, 人数=%d, %s:%d", i, serverId, userCnt, ip, port))
                    offset = offset + 30
                end
            end
            if serverCount > 5 then
                print(string.format("  ... 还有 %d 个服务器", serverCount - 5))
            end
        end
    elseif cmdId == 1001 and entry.direction == "server_to_client" then
        -- 登录响应
        if #bytes > 17 then
            local loginUserId = readUInt32BE(bytes, 18)
            local nickname = readString(bytes, 30, 20)
            print(string.format("登录用户ID: %d", loginUserId))
            print(string.format("昵称: %s", nickname))
        end
    elseif cmdId == 9003 and entry.direction == "server_to_client" then
        -- NONO 信息
        if #bytes > 17 then
            local nonoUserId = readUInt32BE(bytes, 18)
            local nonoCount = readUInt32BE(bytes, 22)
            print(string.format("NONO 用户ID: %d", nonoUserId))
            print(string.format("NONO 数量: %d", nonoCount))
        end
    end
    
    -- 打印原始数据
    print(string.format("HEX: %s", entry.hex:sub(1, 100)))
end

-- 主函数
local function main()
    local logDir = "sessionlog"
    
    -- 查找最新的日志文件
    local files = {}
    pcall(function()
        local entries = fs.readdirSync(logDir)
        for _, entry in ipairs(entries) do
            if entry:match("^login_.*%.json$") then
                table.insert(files, entry)
            end
        end
    end)
    
    if #files == 0 then
        print("没有找到日志文件")
        print("请先运行官服代理模式捕获流量")
        return
    end
    
    table.sort(files)
    local latestFile = files[#files]
    print(string.format("分析文件: %s/%s", logDir, latestFile))
    
    local content = fs.readFileSync(logDir .. "/" .. latestFile)
    local logs = json.parse(content)
    
    print(string.format("\n共 %d 条记录\n", #logs))
    
    -- 统计命令
    local cmdStats = {}
    for _, entry in ipairs(logs) do
        local cmdId = entry.cmdId
        if not cmdStats[cmdId] then
            cmdStats[cmdId] = { count = 0, name = getCmdName(cmdId) }
        end
        cmdStats[cmdId].count = cmdStats[cmdId].count + 1
    end
    
    print("=== 命令统计 ===")
    for cmdId, stat in pairs(cmdStats) do
        print(string.format("CMD %d (%s): %d 次", cmdId, stat.name, stat.count))
    end
    
    -- 分析每条记录
    print("\n=== 详细分析 ===")
    for i, entry in ipairs(logs) do
        if i <= 20 then  -- 只分析前 20 条
            analyzePacket(entry)
        end
    end
    
    if #logs > 20 then
        print(string.format("\n... 还有 %d 条记录未显示", #logs - 20))
    end
end

-- 如果直接运行此脚本
if arg and arg[0] and arg[0]:match("traffic_analyzer") then
    main()
end

return {
    analyzePacket = analyzePacket,
    hexToBytes = hexToBytes,
    readUInt32BE = readUInt32BE,
    readUInt16BE = readUInt16BE,
    readString = readString
}
