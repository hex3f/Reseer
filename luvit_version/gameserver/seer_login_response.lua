-- 赛尔号登录响应生成器
-- 严格按照 UserInfo.setForLoginInfo 的读取顺序 (UserInfo.as 755-1028)

local buffer = require "buffer"
require "../easybytewrite"

local SeerLoginResponse = {}

-- 可选的初始场景列表（非新手玩家随机进入）
local INITIAL_MAPS = {
    1,    -- 赫尔卡星
    4,    -- 克洛斯星
    5,    -- 塞西利亚星
    7,    -- 云霄星
    10,   -- 火山星
    107,  -- 赛尔号飞船
}

-- 检查玩家是否完成新手任务（任务85-88）
local function hasCompletedTutorial(user)
    if not user.tasks then return false end
    
    -- 检查新手任务 85-88 是否都已完成
    for taskId = 85, 88 do
        local task = user.tasks[tostring(taskId)]
        if not task or task.status ~= "completed" then
            return false
        end
    end
    
    return true
end

-- 生成登录响应 (CMD 1001)
function SeerLoginResponse.makeLoginResponse(user)
    local parts = {}
    
    -- 检查是否完成新手任务，如果完成则随机选择场景
    local completedTutorial = hasCompletedTutorial(user)
    if completedTutorial and not user.mapID then
        -- 随机选择一个场景
        local randomIndex = math.random(1, #INITIAL_MAPS)
        user.mapID = INITIAL_MAPS[randomIndex]
        print(string.format("\27[32m[LOGIN] 玩家已完成新手任务，随机进入场景: %d\27[0m", user.mapID))
    elseif not user.mapID then
        -- 新手玩家进入默认场景（新手教程场景）
        user.mapID = 1
        print(string.format("\27[33m[LOGIN] 新手玩家进入默认场景: %d\27[0m", user.mapID))
    end
    
    -- ========== 基本信息 (UserInfo.as 755-826) ==========
    local basic = buffer.Buffer:new(4096)
    local pos = 1
    
    -- userID (4 bytes) - line 757
    basic:wuint(pos, user.userid)
    pos = pos + 4
    
    -- regTime (4 bytes) - line 758
    basic:wuint(pos, os.time() - 86400*365)
    pos = pos + 4
    
    -- nick (16 bytes) - line 759
    basic:write(pos, user.nick or "赛尔", 16)
    pos = pos + 16
    
    -- vip flags (4 bytes) - line 760-762
    local vipFlags = 3  -- VIP + VIPED
    if user.vip == false then vipFlags = 0 end
    basic:wuint(pos, vipFlags)
    pos = pos + 4
    
    -- dsFlag (4 bytes) - line 763
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- color (4 bytes) - line 764
    basic:wuint(pos, user.color or 0x66CCFF)
    pos = pos + 4
    
    -- texture (4 bytes) - line 765
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- energy (4 bytes) - line 766
    local energy = 100
    if user.nono and user.nono.energy then energy = user.nono.energy end
    if user.energy then energy = user.energy end
    basic:wuint(pos, energy)
    pos = pos + 4
    
    -- coins (4 bytes) - line 767
    basic:wuint(pos, user.coins or 99999)
    pos = pos + 4
    
    -- fightBadge (4 bytes) - line 768
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- mapID (4 bytes) - line 769
    basic:wuint(pos, user.mapID or 1)
    pos = pos + 4
    
    -- pos.x, pos.y (8 bytes) - line 770
    basic:wuint(pos, user.posX or 300)
    pos = pos + 4
    basic:wuint(pos, user.posY or 300)
    pos = pos + 4
    
    -- timeToday (4 bytes) - line 771
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- timeLimit (4 bytes) - line 772
    basic:wuint(pos, 0x7FFFFFFF)
    pos = pos + 4
    
    -- 4 boolean bytes (4 bytes) - lines 773-776
    basic:wbyte(pos, 0) -- isClothHalfDay
    pos = pos + 1
    basic:wbyte(pos, 0) -- isRoomHalfDay
    pos = pos + 1
    basic:wbyte(pos, 0) -- iFortressHalfDay
    pos = pos + 1
    basic:wbyte(pos, 0) -- isHQHalfDay
    pos = pos + 1
    
    -- loginCnt (4 bytes) - line 777
    basic:wuint(pos, 100)
    pos = pos + 4
    
    -- inviter (4 bytes) - line 778
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- newInviteeCnt (4 bytes) - line 779
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- vipLevel (4 bytes) - line 780
    basic:wuint(pos, user.vipLevel or 0)
    pos = pos + 4
    
    -- vipValue (4 bytes) - line 781
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- vipStage (4 bytes) - line 782-789
    basic:wuint(pos, 1)
    pos = pos + 4
    
    -- autoCharge (4 bytes) - line 790
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- vipEndTime (4 bytes) - line 791
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- freshManBonus (4 bytes) - line 792
    basic:wuint(pos, 0)
    pos = pos + 4
    
    parts[#parts+1] = tostring(basic):sub(1, pos-1)
    
    -- ========== nonoChipList (80 bytes) - lines 793-797 ==========
    parts[#parts+1] = string.rep("\0", 80)
    
    -- ========== dailyResArr (50 bytes) - lines 798-802 ==========
    parts[#parts+1] = string.rep("\0", 50)
    
    -- ========== teacherID ~ fuseTimes (lines 803-877) ==========
    local buf = buffer.Buffer:new(256)
    pos = 1
    
    -- teacherID (4 bytes) - line 803
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- studentID (4 bytes) - line 804
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- graduationCount (4 bytes) - line 805
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- maxPuniLv (4 bytes) - line 806
    buf:wuint(pos, 100)
    pos = pos + 4
    
    -- petMaxLev (4 bytes) - line 807
    buf:wuint(pos, 100)
    pos = pos + 4
    
    -- petAllNum (4 bytes) - line 808
    buf:wuint(pos, user.petAllNum or 10)
    pos = pos + 4
    
    -- monKingWin (4 bytes) - line 809
    buf:wuint(pos, user.monKingWin or 0)
    pos = pos + 4
    
    -- curStage (4 bytes) - line 810 (client adds +1)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- maxStage (4 bytes) - line 811
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- curFreshStage (4 bytes) - line 812
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- maxFreshStage (4 bytes) - line 813
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- maxArenaWins (4 bytes) - line 814
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- twoTimes (4 bytes) - line 815
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- threeTimes (4 bytes) - line 816
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- autoFight (4 bytes) - line 817
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- autoFightTimes (4 bytes) - line 818
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- energyTimes (4 bytes) - line 819
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- learnTimes (4 bytes) - line 820
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- monBtlMedal (4 bytes) - line 821
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- recordCnt (4 bytes) - line 822
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- obtainTm (4 bytes) - line 823
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- soulBeadItemID (4 bytes) - line 824
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- expireTm (4 bytes) - line 825
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- fuseTimes (4 bytes) - line 826
    buf:wuint(pos, 0)
    pos = pos + 4
    
    parts[#parts+1] = tostring(buf):sub(1, pos-1)
    
    -- ========== hasNono ~ nonoNick (lines 827-883) ==========
    local nonoBuf = buffer.Buffer:new(44)
    pos = 1
    
    local nono = user.nono or {}
    local isSuper = nono.isSuper or user.superNono
    
    -- hasNono (4 bytes) - line 827
    nonoBuf:wuint(pos, user.hasNono and 1 or 0)
    pos = pos + 4
    
    -- superNono (4 bytes) - line 828
    nonoBuf:wuint(pos, isSuper and 1 or 0)
    pos = pos + 4
    
    -- nonoState (4 bytes) - lines 829-834
    nonoBuf:wuint(pos, nono.flag or 0)
    pos = pos + 4
    
    -- nonoColor (4 bytes) - line 835
    nonoBuf:wuint(pos, nono.color or user.nonoColor or 0)
    pos = pos + 4
    
    -- nonoNick (16 bytes) - line 836
    nonoBuf:write(pos, nono.nick or user.nonoNick or "NoNo", 16)
    pos = pos + 16
    
    parts[#parts+1] = tostring(nonoBuf):sub(1, pos-1)

    -- ========== TeamInfo (line 837) ==========
    local teamBuf = buffer.Buffer:new(24)
    teamBuf:wuint(1, 0) -- id
    teamBuf:wuint(5, 0) -- priv
    teamBuf:wuint(9, 0) -- superCore
    teamBuf:wuint(13, 0) -- isShow
    teamBuf:wuint(17, 0) -- allContribution
    teamBuf:wuint(21, 0) -- canExContribution
    parts[#parts+1] = tostring(teamBuf)
    
    -- ========== TeamPKInfo (line 838) ==========
    local teamPKBuf = buffer.Buffer:new(8)
    teamPKBuf:wuint(1, 0) -- groupID
    teamPKBuf:wuint(5, 0) -- homeTeamID
    parts[#parts+1] = tostring(teamPKBuf)
    
    -- ========== 1 byte + badge + reserved (lines 839-841) ==========
    local reservedBuf = buffer.Buffer:new(32)
    reservedBuf:wbyte(1, 0) -- 1 byte (line 839)
    reservedBuf:wuint(2, 0) -- badge (4 bytes, line 840)
    -- reserved (27 bytes, line 841) - all zeros
    parts[#parts+1] = tostring(reservedBuf):sub(1, 32)
    
    -- ========== TasksManager (lines 842-889) ==========
    -- 客户端读取 500 个任务状态
    local taskBuf = buffer.Buffer:new(500)
    for i = 1, 500 do
        taskBuf:wbyte(i, 0)
    end
    
    -- 从数据库填充任务状态
    if user.tasks then
        local taskCount = 0
        for taskIdStr, taskData in pairs(user.tasks) do
            local tid = tonumber(taskIdStr)
            if tid and tid >= 1 and tid <= 500 then
                local status = 0
                if taskData.status == "accepted" then
                    status = 1 -- ALR_ACCEPT
                elseif taskData.status == "completed" then
                    status = 3 -- COMPLETE
                end
                taskBuf:wbyte(tid, status)
                taskCount = taskCount + 1
            end
        end
        if taskCount > 0 then
            print(string.format("\27[32m[LOGIN] 加载了 %d 个任务状态\27[0m", taskCount))
        end
    end
    parts[#parts+1] = tostring(taskBuf)
    
    -- ========== PetManager (lines 891-893) ==========
    -- 客户端只读取 petNum (4 bytes)，然后根据 petNum 读取对应数量的 PetInfo
    -- 当 petNum=0 时，不读取任何额外数据
    local petBuf = buffer.Buffer:new(4)
    petBuf:wuint(1, 0) -- petNum = 0
    parts[#parts+1] = tostring(petBuf):sub(1, 4)
    
    -- ========== Clothes (lines 894-900) ==========
    -- 从用户数据读取服装列表
    local clothes = user.clothes or {}
    local clothBuf = buffer.Buffer:new(4 + #clothes * 8)
    local pos = 1
    
    -- clothes count (4 bytes)
    clothBuf:wuint(pos, #clothes)
    pos = pos + 4
    
    -- 每件服装: id(4) + level(4)
    -- 注意：客户端把第二个字段当作 level 读取，不是 expireTime！
    for _, cloth in ipairs(clothes) do
        local clothId = cloth.id or cloth[1] or 0
        local level = cloth.level or 1  -- 默认等级为 1
        clothBuf:wuint(pos, clothId)
        pos = pos + 4
        clothBuf:wuint(pos, level)
        pos = pos + 4
    end
    
    parts[#parts+1] = tostring(clothBuf):sub(1, pos - 1)
    
    if #clothes > 0 then
        print(string.format("\27[32m[LOGIN] 加载了 %d 件服装\27[0m", #clothes))
    end
    
    -- ========== curTitle (line 901) ==========
    local titleBuf = buffer.Buffer:new(4)
    titleBuf:wuint(1, user.curTitle or 0)
    parts[#parts+1] = tostring(titleBuf):sub(1, 4)
    
    -- ========== bossAchievement (lines 902-906) ==========
    parts[#parts+1] = string.rep("\0", 200)
    
    -- 注意: 客户端 UserInfo.setForLoginInfo 在读取 bossAchievement 后就结束了
    -- 不会读取密钥种子，所以不要发送密钥种子
    
    local result = table.concat(parts)
    
    print(string.format("\27[33m[LOGIN] 响应包大小: %d bytes\27[0m", #result))
    
    return result
end

-- 生成精灵背包响应 (CMD 2001)
function SeerLoginResponse.makePetBagResponse(user)
    local buf = buffer.Buffer:new(8)
    buf:wuint(1, 0)  -- petCount = 0
    buf:wuint(5, 0)  -- 额外数据
    return tostring(buf)
end

-- 生成系统通知 (CMD 8002)
function SeerLoginResponse.makeSystemNotice(user, noticeType, content)
    local buf = buffer.Buffer:new(4096)
    local pos = 1
    
    buf:wuint(pos, noticeType or 0)
    pos = pos + 4
    
    local msg = content or ""
    buf:wuint(pos, #msg)
    pos = pos + 4
    
    if #msg > 0 then
        buf:write(pos, msg, #msg)
        pos = pos + #msg
    end
    
    return tostring(buf):sub(1, pos-1)
end

return SeerLoginResponse
