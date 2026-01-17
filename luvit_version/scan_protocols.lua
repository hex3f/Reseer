-- 扫描客户端协议定义
-- 这个脚本用于从客户端源码中提取所有协议的数据结构信息

print("========== 客户端协议扫描 ==========\n")

-- 已知的协议映射（从ClassRegister.as和CommandID.as提取）
local protocols = {
    -- 登录相关
    {cmd = 1001, name = "LOGIN_IN", class = "未知"},
    {cmd = 1002, name = "SYSTEM_TIME", class = "SystemTimeInfo"},
    {cmd = 1004, name = "MAP_HOT", class = "MapHotInfo"},
    {cmd = 1005, name = "GET_IMAGE_ADDRES", class = "GetImgAddrInfo"},
    
    -- 任务相关
    {cmd = 2201, name = "ACCEPT_TASK", class = "未知"},
    {cmd = 2202, name = "COMPLETE_TASK", class = "NoviceFinishInfo"},
    {cmd = 2203, name = "GET_TASK_BUF", class = "TaskBufInfo"},
    {cmd = 2204, name = "ADD_TASK_BUF", class = "未知"},
    {cmd = 2231, name = "ACCEPT_DAILY_TASK", class = "未知"},
    {cmd = 2233, name = "COMPLETE_DAILY_TASK", class = "NoviceFinishInfo"},
    {cmd = 2234, name = "GET_DAILY_TASK_BUF", class = "TaskBufInfo"},
    
    -- 精灵相关
    {cmd = 2301, name = "GET_PET_INFO", class = "PetInfo"},
    {cmd = 2302, name = "MODIFY_PET_NAME", class = "未知"},
    {cmd = 2303, name = "GET_PET_LIST", class = "未知"},
    {cmd = 2304, name = "PET_RELEASE", class = "PetTakeOutInfo"},
    {cmd = 2305, name = "PET_SHOW", class = "PetShowInfo"},
    {cmd = 2306, name = "PET_CURE", class = "未知"},
    {cmd = 2307, name = "PET_STUDY_SKILL", class = "未知"},
    {cmd = 2308, name = "PET_DEFAULT", class = "未知"},
    {cmd = 2309, name = "PET_BARGE_LIST", class = "PetBargeListInfo"},
    {cmd = 2310, name = "PET_ONE_CURE", class = "未知"},
    {cmd = 2311, name = "PET_COLLECT", class = "未知"},
    {cmd = 2312, name = "PET_SKILL_SWICTH", class = "未知"},
    {cmd = 2314, name = "PET_EVOLVTION", class = "未知"},
    {cmd = 2315, name = "PET_HATCH", class = "未知"},
    {cmd = 2316, name = "PET_HATCH_GET", class = "未知"},
    {cmd = 2318, name = "PET_SET_EXP", class = "未知"},
    {cmd = 2319, name = "PET_GET_EXP", class = "未知"},
    {cmd = 2326, name = "USE_PET_ITEM_OUT_OF_FIGHT", class = "UsePetItemOutOfFightInfo"},
    {cmd = 2351, name = "PET_FUSION", class = "PetFusionInfo"},
    
    -- 战斗相关
    {cmd = 2401, name = "INVITE_TO_FIGHT", class = "未知"},
    {cmd = 2403, name = "HANDLE_FIGHT_INVITE", class = "未知"},
    {cmd = 2404, name = "READY_TO_FIGHT", class = "未知"},
    {cmd = 2405, name = "USE_SKILL", class = "未知"},
    {cmd = 2406, name = "USE_PET_ITEM", class = "UsePetItemInfo"},
    {cmd = 2407, name = "CHANGE_PET", class = "ChangePetInfo"},
    {cmd = 2408, name = "FIGHT_NPC_MONSTER", class = "未知"},
    {cmd = 2409, name = "CATCH_MONSTER", class = "CatchPetInfo"},
    {cmd = 2410, name = "ESCAPE_FIGHT", class = "未知"},
    {cmd = 2411, name = "CHALLENGE_BOSS", class = "未知"},
    {cmd = 2412, name = "ATTACK_BOSS", class = "未知"},
    {cmd = 2414, name = "CHOICE_FIGHT_LEVEL", class = "ChoiceLevelRequestInfo"},
    {cmd = 2415, name = "START_FIGHT_LEVEL", class = "SuccessFightRequestInfo"},
    {cmd = 2441, name = "LOAD_PERCENT", class = "FightLoadPercentInfo"},
    
    -- 战斗通知（服务器推送）
    {cmd = 2501, name = "NOTE_INVITE_TO_FIGHT", class = "InviteNoteInfo"},
    {cmd = 2502, name = "NOTE_HANDLE_FIGHT_INVITE", class = "InviteHandleInfo"},
    {cmd = 2503, name = "NOTE_READY_TO_FIGHT", class = "NoteReadyToFightInfo"},
    {cmd = 2504, name = "NOTE_START_FIGHT", class = "FightStartInfo"},
    {cmd = 2505, name = "NOTE_USE_SKILL", class = "UseSkillInfo"},
    {cmd = 2506, name = "FIGHT_OVER", class = "FightOverInfo"},
    {cmd = 2507, name = "NOTE_UPDATE_SKILL", class = "PetUpdateSkillInfo"},
    {cmd = 2508, name = "NOTE_UPDATE_PROP", class = "PetUpdatePropInfo"},
    
    -- 物品相关
    {cmd = 2601, name = "ITEM_BUY", class = "BuyItemInfo"},
    {cmd = 2602, name = "ITEM_SALE", class = "未知"},
    {cmd = 2603, name = "ITEM_REPAIR", class = "未知"},
    {cmd = 2604, name = "CHANGE_CLOTH", class = "ChangeClothInfo"},
    {cmd = 2605, name = "ITEM_LIST", class = "未知"},
    {cmd = 2606, name = "MULTI_ITEM_BUY", class = "BuyMultiItemInfo"},
    {cmd = 2610, name = "EAT_SPECIAL_MEDICINE", class = "EatSpecialMedicineInfo"},
    
    -- 聊天相关
    {cmd = 2102, name = "CHAT", class = "ChatInfo"},
    {cmd = 2929, name = "TEAM_CHAT", class = "TeamChatInfo"},
    
    -- 其他
    {cmd = 2061, name = "CHANG_NICK_NAME", class = "ChangeUserNameInfo"},
    {cmd = 2111, name = "PEOPLE_TRANSFROM", class = "TransformInfo"},
    {cmd = 8001, name = "INFORM", class = "InformInfo"},
    {cmd = 8002, name = "SYSTEM_MESSAGE", class = "SystemMsgInfo"},
    {cmd = 8004, name = "GET_BOSS_MONSTER", class = "BossMonsterInfo"},
}

print("需要实现的协议总数: " .. #protocols)
print("\n按类别分组:\n")

local categories = {
    ["登录"] = {},
    ["任务"] = {},
    ["精灵"] = {},
    ["战斗"] = {},
    ["战斗通知"] = {},
    ["物品"] = {},
    ["聊天"] = {},
    ["其他"] = {}
}

for _, p in ipairs(protocols) do
    local cat = "其他"
    if p.cmd >= 1001 and p.cmd <= 1010 then
        cat = "登录"
    elseif (p.cmd >= 2201 and p.cmd <= 2240) then
        cat = "任务"
    elseif (p.cmd >= 2301 and p.cmd <= 2399) then
        cat = "精灵"
    elseif (p.cmd >= 2401 and p.cmd <= 2450) then
        cat = "战斗"
    elseif (p.cmd >= 2501 and p.cmd <= 2510) then
        cat = "战斗通知"
    elseif (p.cmd >= 2601 and p.cmd <= 2650) then
        cat = "物品"
    elseif p.cmd == 2102 or p.cmd == 2929 then
        cat = "聊天"
    end
    table.insert(categories[cat], p)
end

for catName, prots in pairs(categories) do
    if #prots > 0 then
        print(string.format("【%s】 (%d个)", catName, #prots))
        for _, p in ipairs(prots) do
            local status = p.class ~= "未知" and "✓" or "✗"
            print(string.format("  %s CMD %4d: %-30s -> %s", status, p.cmd, p.name, p.class))
        end
        print("")
    end
end

print("\n========== 扫描完成 ==========")
print("提示: 需要阅读客户端Info类源码来确定每个协议的包体结构")
