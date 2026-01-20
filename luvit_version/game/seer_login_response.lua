-- 赛尔号登录响应生成器
-- 严格按照 UserInfo.setForLoginInfo 的读取顺序 (UserInfo.as)
-- Protocol Version: 2026-01-20 (Refactored using BinaryWriter)

local BinaryWriter = require("../../utils/binary_writer")
local Config = require("../../config/game_config")
local PacketUtils = require("../../core/packet_utils")
local PetHandlers = require("../../handlers/pet_handlers") -- Share pet serialization

local SeerLoginResponse = {}

-- 检查玩家是否完成新手任务（任务85-88）
local function hasCompletedTutorial(user)
    if not user.taskList then return false end
    for taskId = 85, 88 do
        local status = user.taskList[tostring(taskId)]
        if not status or status ~= 3 then
            return false
        end
    end
    return true
end

-- 生成登录响应 (CMD 1001)
function SeerLoginResponse.makeLoginResponse(user)
    -- 地图/重生逻辑
    local completedTutorial = hasCompletedTutorial(user)
    local spawnConfig = Config.InitialPlayer.Spawn or { DefaultMap = 1, PostTutorialMap = 1 }
    
    if completedTutorial then
        user.mapID = spawnConfig.PostTutorialMap
        print(string.format("\27[32m[LOGIN] 玩家已完成新手任务，强制进入配置场景: %d\27[0m", user.mapID))
    elseif not user.mapID then
        user.mapID = spawnConfig.DefaultMap
        print(string.format("\27[33m[LOGIN] 新手玩家进入默认场景: %d\27[0m", user.mapID))
    end
    
    local writer = BinaryWriter.new()
    
    -- 确保 nono 数据存在
    local nono = user.nono or {}
    
    -- ========== UserInfo.setForLoginInfo 开始 ==========
    
    -- 1. 账号基本信息
    writer:writeUInt32BE(user.userid)                    -- userID (4)
    writer:writeUInt32BE(user.regTime or (os.time() - 86400*365)) -- regTime (4)
    writer:writeStringFixed(user.nick or "赛尔", 16)      -- nick (16)
    
    -- 2. VIP Flags (4 bytes, bitwise)
    local vipFlags = 0
    -- bit 0: vip, bit 1: viped
    if nono.superNono and nono.superNono > 0 then
        vipFlags = 3 -- 1 | 2
    end
    writer:writeUInt32BE(vipFlags)
    
    -- 3. 基础属性
    writer:writeUInt32BE(user.dsFlag or 0)               -- dsFlag (4)
    writer:writeUInt32BE(user.color or 0x66CCFF)         -- color (4)
    writer:writeUInt32BE(user.texture or 1)              -- texture (4)
    writer:writeUInt32BE(user.energy or nono.energy or 100) -- energy (4)
    writer:writeUInt32BE(user.coins or 2000)             -- coins (4)
    writer:writeUInt32BE(user.fightBadge or 0)           -- fightBadge (4)
    writer:writeUInt32BE(user.mapID or 1)                -- mapID (4)
    writer:writeUInt32BE(user.posX or 300)               -- pos.x (4)
    writer:writeUInt32BE(user.posY or 270)               -- pos.y (4)
    writer:writeUInt32BE(user.timeToday or 0)            -- timeToday (4)
    writer:writeUInt32BE(user.timeLimit or 86400)        -- timeLimit (4)
    
    -- 4. Flags (4 bytes)
    writer:writeUInt8(user.isClothHalfDay or 0)          -- Byte
    writer:writeUInt8(user.isRoomHalfDay or 0)           -- Byte
    writer:writeUInt8(user.iFortressHalfDay or 0)        -- Byte
    writer:writeUInt8(user.isHQHalfDay or 0)             -- Byte
    
    -- 5. Statistics
    writer:writeUInt32BE(user.loginCnt or 1)             -- loginCnt (4)
    writer:writeUInt32BE(user.inviter or 0)              -- inviter (4)
    writer:writeUInt32BE(user.newInviteeCnt or 0)        -- newInviteeCnt (4)
    writer:writeUInt32BE(nono.vipLevel or 0)             -- vipLevel (4)
    writer:writeUInt32BE(nono.vipValue or 0)             -- vipValue (4)
    writer:writeUInt32BE(nono.vipStage or 0)             -- vipStage (4)
    writer:writeUInt32BE(nono.autoCharge or 0)           -- autoCharge (4)
    
    -- vipEndTime
    local endTime = nono.vipEndTime or 0
    local isSuper = (nono.superNono or 0) > 0
    if isSuper and endTime == 0 then endTime = 0x7FFFFFFF end
    writer:writeUInt32BE(endTime)                        -- vipEndTime (4)
    
    writer:writeUInt32BE(nono.freshManBonus or 0)        -- freshManBonus (4)
    
    -- 6. Lists (Fixed Size)
    writer:writeStringFixed("", 80)                      -- nonoChipList (80 bytes)
    writer:writeStringFixed("", 50)                      -- dailyResArr (50 bytes)
    
    -- 7. More Stats
    writer:writeUInt32BE(user.teacherID or 0)
    writer:writeUInt32BE(user.studentID or 0)
    writer:writeUInt32BE(user.graduationCount or 0)
    writer:writeUInt32BE(user.maxPuniLv or 100)
    writer:writeUInt32BE(user.petMaxLev or 100)
    writer:writeUInt32BE(user.petAllNum or 0)
    writer:writeUInt32BE(user.monKingWin or 0)
    writer:writeUInt32BE((user.curStage or 0))           -- Note: client adds 1
    writer:writeUInt32BE(user.maxStage or 0)
    writer:writeUInt32BE(user.curFreshStage or 0)
    writer:writeUInt32BE(user.maxFreshStage or 0)
    writer:writeUInt32BE(user.maxArenaWins or 0)
    writer:writeUInt32BE(user.twoTimes or 0)
    writer:writeUInt32BE(user.threeTimes or 0)
    writer:writeUInt32BE(user.autoFight or 0)
    writer:writeUInt32BE(user.autoFightTimes or 0)
    writer:writeUInt32BE(user.energyTimes or 0)
    writer:writeUInt32BE(user.learnTimes or 0)
    writer:writeUInt32BE(user.monBtlMedal or 0)
    writer:writeUInt32BE(user.recordCnt or 0)
    writer:writeUInt32BE(user.obtainTm or 0)
    writer:writeUInt32BE(user.soulBeadItemID or 0)
    writer:writeUInt32BE(user.expireTm or 0)
    writer:writeUInt32BE(user.fuseTimes or 0)
    
    -- 8. NoNo Details
    local hasNono = (user.hasNono and user.hasNono > 0) or (nono.hasNono and nono.hasNono > 0)
    local superNono = nono.superNono or user.superNono or 0
    
    writer:writeUInt32BE(hasNono and 1 or 0)             -- hasNono (4)
    writer:writeUInt32BE(superNono > 0 and 1 or 0)       -- superNono (4)
    writer:writeUInt32BE(nono.flag or 0xFFFFFFFF)        -- nonoState (32 bits -> 4 bytes)
    writer:writeUInt32BE(nono.color or user.nonoColor or 0xFFFFFF) -- nonoColor (4) - 默认白色
    writer:writeStringFixed(nono.nick or user.nonoNick or "NoNo", 16) -- nonoNick (16)
    
    -- 9. TeamInfo (24 bytes) - 使用用户实际的战队信息
    local team = user.teamInfo or {}
    writer:writeUInt32BE(team.id or 0)           -- id
    writer:writeUInt32BE(team.priv or 0)         -- priv
    writer:writeUInt32BE(team.superCore or 0)    -- superCore
    writer:writeUInt32BE(team.isShow and 1 or 0) -- isShow
    writer:writeUInt32BE(team.allContribution or 0) -- allContribution
    writer:writeUInt32BE(team.canExContribution or 0) -- canExContribution
    
    -- 10. TeamPKInfo (8 bytes)
    writer:writeUInt32BE(0) -- groupID
    writer:writeUInt32BE(0) -- homeTeamID
    
    -- 11. Badge & Reserved
    writer:writeInt8(0)     -- 1 byte padding/flag (line 346 in UserInfo.as)
    writer:writeUInt32BE(0) -- badge (4)
    writer:writeStringFixed("", 27) -- reserved (27 bytes)
    
    -- 12. Task List (500 bytes)
    local taskCount = 0
    local taskStatusMap = user.taskList or {}
    for i = 1, 500 do
        local status = 0
        local sid = tostring(i)
        if taskStatusMap[sid] then
            -- Handle legacy string/enum formats if any
            local val = taskStatusMap[sid]
            if type(val) == "number" then status = val
            elseif val == "accepted" then status = 1
            elseif val == "completed" then status = 3
            end
            taskCount = taskCount + 1
        end
        writer:writeUInt8(status)
    end
    print(string.format("\27[32m[LOGIN] 加载了 %d 个任务状态\27[0m", taskCount))
    
    -- 13. Pet List
    local pets = user.pets or {}
    local petCount = #pets
    writer:writeUInt32BE(petCount) -- petNum (4)
    
    if petCount > 0 then
        for _, pet in ipairs(pets) do
            -- Use buildFullPetInfo from PetHandlers (which matches PetInfo spec)
            -- Note: PetHandlers might expect specific args, let's adapt
            local petId = pet.id or pet[1] or 0
            local catchTime = pet.catchTime or pet[2] or 0
            local level = pet.level or pet[3] or 100
            
            local petData = PetHandlers.buildFullPetInfo(petId, catchTime, level)
            writer:writeBytes(petData)
        end
        print(string.format("\27[32m[LOGIN] 加载了 %d 个精灵\27[0m", petCount))
    end
    
    -- 14. Clothes
    local clothes = user.clothes or {}
    writer:writeUInt32BE(#clothes)
    for _, cloth in ipairs(clothes) do
        local clothId = 0
        local level = 0
        if type(cloth) == "table" then
            clothId = cloth.id or cloth[1] or 0
            level = cloth.level or cloth[2] or 1
        elseif type(cloth) == "number" then
            clothId = cloth
            level = 1
        end
        writer:writeUInt32BE(clothId)
        writer:writeUInt32BE(level)
    end
    if #clothes > 0 then
        print(string.format("\27[32m[LOGIN] 加载了 %d 件服装\27[0m", #clothes))
    end
    
    -- 15. Title & Achievements
    writer:writeUInt32BE(user.curTitle or 0)             -- curTitle (4)
    writer:writeStringFixed("", 200)                     -- bossAchievement (200 bytes)
    
    local result = writer:toString()
    print(string.format("\27[33m[LOGIN] 响应包大小: %d bytes\27[0m", #result))
    
    -- Return body and keySeed (we don't write keySeed to body, but server uses it)
    -- UserInfo.as doesn't read keySeed at the end of setForLoginInfo.
    -- But the caller (LoginCmdListener?) might need it or it's handled via crypto.
    -- We'll return 0 as keySeed if not needed in body.
    return result, 12345 -- 12345 is dummy keySeed
end

function SeerLoginResponse.makePetBagResponse(user)
    local writer = BinaryWriter.new()
    writer:writeUInt32BE(0) -- count
    writer:writeUInt32BE(0) -- extra
    return writer:toString()
end

function SeerLoginResponse.makeSystemNotice(user, noticeType, content)
    local writer = BinaryWriter.new()
    local msg = content or ""
    writer:writeUInt32BE(noticeType or 0)
    writer:writeUInt32BE(#msg)
    writer:writeStringFixed(msg, #msg) -- Write raw bytes essentially
    return writer:toString()
end

return SeerLoginResponse
