-- 赛尔号登录响应生成器
-- 根据 UserInfo.setForLoginInfo 格式精确实现

local buffer = require "buffer"
require "../easybytewrite"

local SeerLoginResponse = {}

-- 生成登录响应 (CMD 1001)
-- 严格按照 UserInfo.setForLoginInfo 的读取顺序
function SeerLoginResponse.makeLoginResponse(user)
    local parts = {}
    
    -- ========== 基本信息 (UserInfo.as 755 - 827) ==========
    local basic = buffer.Buffer:new(4096) -- Increased buffer size
    local pos = 1
    
    -- userID (4 bytes)
    basic:wuint(pos, user.userid)
    pos = pos + 4
    
    -- regTime (4 bytes)
    basic:wuint(pos, os.time() - 86400*365)
    pos = pos + 4
    
    -- nick (16 bytes)
    basic:write(pos, user.nick or "赛尔", 16)
    pos = pos + 16
    
    -- decorateList[5] (5 * 4 = 20 bytes)
    for i = 0, 4 do
        basic:wuint(pos, 0)  -- decorateList[i].id
        pos = pos + 4
    end
    
    -- 2个保留字段 (8 bytes) - UserInfo 764-765
    basic:wuint(pos, 0)
    pos = pos + 4
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- _loc4_ 保留 (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- coins (4 bytes) - Give player coins
    basic:wuint(pos, user.coins or 99999)
    pos = pos + 4
    
    -- vip flags (4 bytes) - bit0=vip, bit1=viped - Enable VIP by default
    local vipFlags = 3  -- VIP + VIPED
    if user.vip == false then vipFlags = 0 end
    basic:wuint(pos, vipFlags)
    pos = pos + 4
    
    -- isExtremeNono flag (1 byte) - bit1
    basic:wbyte(pos, user.isExtremeNono and 2 or 0)
    pos = pos + 1
    
    -- cuteType (1 byte)
    basic:wbyte(pos, user.cuteType or 0)
    pos = pos + 1
    
    -- dsFlag (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- color (4 bytes) - Blue character
    basic:wuint(pos, user.color or 0x66CCFF)
    pos = pos + 4
    
    -- texture (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- energy (4 bytes)
    -- Battery functional usually powered by nono energy or daily limit?
    -- Official server uses nono energy here if available?
    local energy = 100
    if user.nono and user.nono.energy then energy = user.nono.energy end
    if user.energy then energy = user.energy end
    
    basic:wuint(pos, energy)
    pos = pos + 4
    
    -- fireBuff (1 byte)
    basic:wbyte(pos, 0)
    pos = pos + 1
    
    -- jobTitle (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- isActive (4 bytes)
    basic:wuint(pos, 1)
    pos = pos + 4
    
    -- oldSeerInvateCount (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- blanketInvateCount (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- toDayGetGiftCount (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- totalGiftCount (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- getGiftDate (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- getGiftTime (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- fightBadge (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- fightBadge1 (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- fightPkBadge (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- fightRoyale (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- mapID (4 bytes)
    basic:wuint(pos, user.mapID or 1)
    pos = pos + 4
    
    -- pos.x (4 bytes)
    basic:wuint(pos, user.posX or 300)
    pos = pos + 4
    
    -- pos.y (4 bytes)
    basic:wuint(pos, user.posY or 300)
    pos = pos + 4
    
    -- timeToday (4 bytes) - 今天已使用的游戏时间（秒）
    -- 设为0表示今天尚未使用任何时间
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- lastLoginTime (4 bytes)
    basic:wuint(pos, os.time() - 3600)
    pos = pos + 4
    
    -- timeLimit (4 bytes) - 每日游戏时间限制（秒）
    -- 注意：客户端 leftTime 是 signed int，0xFFFFFFFF 会溢出为 -1！
    -- 使用 0x7FFFFFFF (2147483647秒 ≈ 68年) 作为安全的最大值
    basic:wuint(pos, 0x7FFFFFFF)
    pos = pos + 4
    
    -- logintimeThisTime (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- isClothHalfDay (1 byte)
    basic:wbyte(pos, 0)
    pos = pos + 1
    
    -- isRoomHalfDay (1 byte)
    basic:wbyte(pos, 0)
    pos = pos + 1
    
    -- iFortressHalfDay (1 byte)
    basic:wbyte(pos, 0)
    pos = pos + 1
    
    -- isHQHalfDay (1 byte)
    basic:wbyte(pos, 0)
    pos = pos + 1
    
    -- loginCnt (4 bytes)
    basic:wuint(pos, 100)
    pos = pos + 4
    
    -- inviter (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- newInviteeCnt (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- isFamous (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- vipTitle (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- vipLevel (4 bytes)
    basic:wuint(pos, user.vipLevel or 0)
    pos = pos + 4
    
    -- vipValue (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- vipStage (4 bytes)
    basic:wuint(pos, 1)
    pos = pos + 4
    
    -- autoCharge (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- vipEndTime (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    -- freshManBonus (4 bytes)
    basic:wuint(pos, 0)
    pos = pos + 4
    
    parts[#parts+1] = tostring(basic):sub(1, pos-1)
    
    -- ========== nonoChipList (80 bytes) ==========
    parts[#parts+1] = string.rep("\0", 80)
    
    -- ========== dailyResArr (300 bytes) ==========
    parts[#parts+1] = string.rep("\0", 300)
    
    -- ========== summerHolidaysArr (7 bytes) ==========
    parts[#parts+1] = string.rep("\0", 7)
    
    -- ========== dailyTaskWeekHotArr (23 bytes) ==========
    parts[#parts+1] = string.rep("\0", 23)
    
    -- ========== bufferRecordArr (200 bytes) ==========
    parts[#parts+1] = string.rep("\0", 200)

    -- ========== 更多字段 (UserInfo.as 864-1438) ==========
    local buf = buffer.Buffer:new(4096)
    pos = 1
    
    -- teacherID (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- studentID (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- graduationCount (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- isRecruitor (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- maxPuniLv (4 bytes)
    buf:wuint(pos, 100)
    pos = pos + 4
    
    -- petMaxLev (4 bytes)
    buf:wuint(pos, 100)
    pos = pos + 4
    
    -- petAllNum (4 bytes)
    buf:wuint(pos, user.petAllNum or 10)
    pos = pos + 4
    
    local ach = user.achievements or {total=0, rank=0}
    
    -- totalAchieve (4 bytes)
    buf:wuint(pos, ach.total or 0)
    pos = pos + 4
    
    -- curTitle (4 bytes)
    buf:wuint(pos, user.curTitle or 0)
    pos = pos + 4
    
    -- achieRank (4 bytes)
    buf:wuint(pos, ach.rank or 0)
    pos = pos + 4
    
    -- monKingWin (4 bytes)
    buf:wuint(pos, user.monKingWin or 0)
    pos = pos + 4
    
    -- teamBoss (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- curStage (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- maxStage (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- 2个保留字段 (8 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- curKingStage (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- maxKingStage (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- maxKingHeroStage (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- maxLadderState (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- maxFortuneState (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- maxHigherState (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- extremeLawLevel (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- battleLabInfo (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- zheguangWinTimes (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- dreamMessWins (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- maxArenaWins (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- eFChampion (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- twoTimes (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- threeTimes (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- dragonStatus (1 byte)
    buf:wbyte(pos, 0)
    pos = pos + 1
    
    -- autoFight (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- autoFightTimes (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- energyTimes (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- learnTimes (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- btlDetectTimes (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- mobilizeTime (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- monBtlMedal (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- recordCnt (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- obtainTm (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- soulBeadItemID (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- expireTm (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- fuseTimes (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    -- vipScore (4 bytes)
    buf:wuint(pos, 0)
    pos = pos + 4
    
    parts[#parts+1] = tostring(buf):sub(1, pos-1)
    
    -- ========== 开放功能数组 (UserInfo.as 910-94X) ==========
    local openFlags = buffer.Buffer:new(12)
    openFlags:wuint(1, 2)  -- count = 2
    openFlags:wuint(5, 0xFFFFFFFF)  -- 全部开放 (Tiger/Dragon/etc)
    openFlags:wuint(9, 0xFFFFFFFF)  -- 全部开放
    parts[#parts+1] = tostring(openFlags)
    
    -- ========== mountId (4 bytes) ==========
    local buf1 = buffer.Buffer:new(16)
    buf1:wuint(1, 0) -- mountId
    buf1:wuint(5, 0) -- blackCrystalPos
    buf1:wuint(9, 0) -- luogeTeamId
    buf1:wuint(13, 0) -- crackCupTeamId
    parts[#parts+1] = tostring(buf1)
    
    -- ========== monthLoginDay (4 bytes) ==========
    local buf2 = buffer.Buffer:new(16)
    buf2:wuint(1, 0) -- monthLoginDay
    buf2:wuint(5, 0) -- isBeaten
    buf2:wuint(9, 0) -- isBeaten_1
    buf2:wuint(13, user.hasNono and 1 or 0) -- hasNono
    parts[#parts+1] = tostring(buf2)
    
    -- ========== superNono ~ nonoNick (UserInfo 961-970) ==========
    local nonoBuf = buffer.Buffer:new(28)
    pos = 1
    
    local nono = user.nono or {}
    local isSuper = nono.isSuper or user.superNono
    
    nonoBuf:wuint(pos, isSuper and 1 or 0)
    pos = pos + 4
    
    nonoBuf:wuint(pos, nono.flag or 0) -- nonoState (flags)
    pos = pos + 4
    
    nonoBuf:wuint(pos, nono.color or user.nonoColor or 0)
    pos = pos + 4
    
    nonoBuf:write(pos, nono.nick or user.nonoNick or "NoNo", 16)
    pos = pos + 16
    
    parts[#parts+1] = tostring(nonoBuf)
    
    -- ========== nonoChangeToPet (4 bytes) ==========
    -- UserInfo 971
    local buf3 = buffer.Buffer:new(4)
    buf3:wuint(1, 0)
    parts[#parts+1] = tostring(buf3)

    -- ========== TeamInfo (UserInfo 972) ==========
    -- TeamInfo constructor reads: id(4), priv(4), superCore(4), isShow(4), allContribution(4), canExContribution(4)
    -- Total: 24 bytes
    local teamBuf = buffer.Buffer:new(24)
    teamBuf:wuint(1, 0) -- id
    teamBuf:wuint(5, 0) -- priv
    teamBuf:wuint(9, 0) -- superCore
    teamBuf:wuint(13, 0) -- isShow
    teamBuf:wuint(17, 0) -- allContribution
    teamBuf:wuint(21, 0) -- canExContribution
    parts[#parts+1] = tostring(teamBuf)
    
    -- ========== TeamPKInfo (UserInfo 973) ==========
    -- TeamPKInfo constructor reads: groupID(4), homeTeamID(4)
    -- Total: 8 bytes
    local teamPKBuf = buffer.Buffer:new(8)
    teamPKBuf:wuint(1, 0) -- groupID
    teamPKBuf:wuint(5, 0) -- homeTeamID
    parts[#parts+1] = tostring(teamPKBuf)
    
    -- ========== Balls (12 bytes) ==========
    local balls = buffer.Buffer:new(12)
    balls:wuint(1, 0)  -- redball
    balls:wuint(5, 0)  -- blueball
    balls:wuint(9, 0)  -- yellowball
    parts[#parts+1] = tostring(balls)
    
    -- ========== Reserved (UserInfo 978: 20 bytes) ==========
    parts[#parts+1] = string.rep("\0", 20)
    
    -- ========== TasksManager (UserInfo 980-1003) ==========
    -- Loop 1000 times: readUnsignedByte. Total 1000 bytes.
    local taskBuf = buffer.Buffer:new(1000)
    -- 初始化全0
    for i = 1, 1000 do
        taskBuf:wbyte(i, 0)
    end
    
    -- 从数据库填充任务状态
    if user.tasks then
        for taskIdStr, taskData in pairs(user.tasks) do
            local tid = tonumber(taskIdStr)
            if tid and tid >= 1 and tid <= 1000 then
                local status = 0
                if taskData.status == "accepted" then
                    status = 1 -- ALR_ACCEPT
                elseif taskData.status == "completed" then
                    status = 3 -- COMPLETE
                end
                taskBuf:wbyte(tid, status)
            end
        end
    end
    parts[#parts+1] = tostring(taskBuf)
    
    -- ========== PetManager (UserInfo 1005+) ==========
    local petBuf = buffer.Buffer:new(8)
    petBuf:wuint(1, 0) -- petNum (0) - UserInfo 1005
    -- PetManager.initData(param2, petNum) -> if petNum=0, probably reads nothing or small.
    -- PetManager.initData(param2, readUnsignedInt(), true) -> 2nd init.
    petBuf:wuint(5, 0) -- 2nd count
    parts[#parts+1] = tostring(petBuf)
    
    -- ========== Clothes (UserInfo 1008+) ==========
    local clothBuf = buffer.Buffer:new(4)
    clothBuf:wuint(1, 0) -- clothes count
    parts[#parts+1] = tostring(clothBuf)
    
    -- ========== TopStatus (UserInfo 1018-1028) ==========
    -- 11 ints
    local topStatus = buffer.Buffer:new(44)
    for i = 0, 10 do
        topStatus:wuint(1 + i*4, 0)
    end
    parts[#parts+1] = tostring(topStatus)
    
    -- ========== 其他状态字段 (UserInfo 1029-1038) ==========
    local otherStatus = buffer.Buffer:new(40)
    pos = 1
    otherStatus:wuint(pos, 0)  -- aresUnionTeam
    pos = pos + 4
    otherStatus:wuint(pos, 0)  -- luoboteStatus
    pos = pos + 4
    otherStatus:wuint(pos, 0)  -- aiErFuAndMiYouLaStatus
    pos = pos + 4
    otherStatus:wuint(pos, 0)  -- usersCamp
    pos = pos + 4
    otherStatus:wuint(pos, 0)  -- tangyuan
    pos = pos + 4
    otherStatus:wuint(pos, 0)  -- foolsdayMask
    pos = pos + 4
    otherStatus:wuint(pos, 0)  -- tigerFightTeam
    pos = pos + 4
    otherStatus:wuint(pos, 0)  -- tigerFightScore
    pos = pos + 4
    otherStatus:wuint(pos, 0)  -- lordOfWarTeamId
    pos = pos + 4
    -- Ensure 36 bytes for 9 fields? 
    -- 1029: aresUnionTeam
    -- 1030: luoboteStatus
    -- 1031: aiErFuAndMiYouLaStatus
    -- 1032: usersCamp
    -- 1033: tangyuan
    -- 1034: foolsdayMask
    -- 1035: tigerFightTeam
    -- 1036: tigerFightScore
    -- 1037: lordOfWarTeamId
    -- Total 9 fields * 4 = 36 bytes.
    -- Buffer size 40 is safe but we should only copy what we need. 
    -- Actually let's use exact size to be clean.
    parts[#parts+1] = tostring(otherStatus):sub(1, 36)
    
    -- ========== 最后4字节是密钥种子 ==========
    -- 为了兼容可能的客户端读取差异（是否贪婪读取），我们发送两次KeySeed
    -- 如果UserInfo不多读，MainEntry读取第一个KeySeed，忽略第二个。
    -- 如果UserInfo多读（吞掉第一个），MainEntry读取第二个KeySeed。
    -- 两个KeySeed相同，保证Key一致。
    -- 两个KeySeed相同，保证Key一致。
    local keySeed = buffer.Buffer:new(8)
    local randomNum = 0 -- math.random(1, 0x7FFFFFFF) -- 使用0关闭客户端加密
    keySeed:wuint(1, randomNum)
    keySeed:wuint(5, randomNum)
    parts[#parts+1] = tostring(keySeed)
    
    -- 保存密钥种子供后续使用
    user.keySeed = randomNum
    
    local result = table.concat(parts)
    
    -- 详细字段日志 (便于调试数据准确性)
    print(string.format("\27[33m[LOGIN] ============ 登录响应详细信息 ============\27[0m"))
    print(string.format("\27[33m[LOGIN] userID: %d\27[0m", user.userid or 0))
    print(string.format("\27[33m[LOGIN] nick: %s\27[0m", user.nick or "赛尔"))
    print(string.format("\27[33m[LOGIN] coins: %d\27[0m", user.coins or 99999))
    print(string.format("\27[33m[LOGIN] energy: %d\27[0m", user.energy or (user.nono and user.nono.energy) or 100))
    print(string.format("\27[33m[LOGIN] mapID: %d\27[0m", user.mapID or 1))
    print(string.format("\27[33m[LOGIN] posX: %d, posY: %d\27[0m", user.posX or 300, user.posY or 300))
    print(string.format("\27[33m[LOGIN] timeToday: 0 (无使用时间)\27[0m"))
    print(string.format("\27[33m[LOGIN] timeLimit: 0xFFFFFFFF (无限制)\27[0m"))
    print(string.format("\27[33m[LOGIN] vip: %s\27[0m", user.vip ~= false and "是" or "否"))
    if user.nono then
        print(string.format("\27[33m[LOGIN] NoNo: isSuper=%s, energy=%d\27[0m", 
            user.nono.isSuper and "是" or "否", user.nono.energy or 0))
    end
    if user.achievements then
        print(string.format("\27[33m[LOGIN] 成就: total=%d, rank=%d\27[0m", 
            user.achievements.total or 0, user.achievements.rank or 0))
    end
    print(string.format("\27[33m[LOGIN] 响应包大小: %d bytes, keySeed=%d\27[0m", #result, randomNum))
    print(string.format("\27[33m[LOGIN] ================================================\27[0m"))
    
    return result, randomNum
end

-- 生成精灵背包响应 (CMD 2001)
function SeerLoginResponse.makePetBagResponse(user)
    -- ENTER_MAP 命令的响应
    -- 根据 PetManager 的格式
    local buf = buffer.Buffer:new(8)
    buf:wuint(1, 0)  -- petCount = 0
    buf:wuint(5, 0)  -- 额外数据
    return tostring(buf)
end

-- 生成系统通知 (CMD 8002)
function SeerLoginResponse.makeSystemNotice(user, noticeType, content)
    -- 系统消息格式
    local buf = buffer.Buffer:new(4096)
    local pos = 1
    
    -- 消息类型
    buf:wuint(pos, noticeType or 0)
    pos = pos + 4
    
    -- 消息内容长度
    local msg = content or ""
    buf:wuint(pos, #msg)
    pos = pos + 4
    
    -- 消息内容
    if #msg > 0 then
        buf:write(pos, msg, #msg)
        pos = pos + #msg
    end
    
    return tostring(buf):sub(1, pos-1)
end

return SeerLoginResponse
