-- 物品相关命令处理器
-- 包括: 购买物品、物品列表、更换服装等

local Utils = require('./utils')
local writeUInt32BE = Utils.writeUInt32BE
local readUInt32BE = Utils.readUInt32BE
local buildResponse = Utils.buildResponse

local ItemHandlers = {}

-- 物品类型常量
local ITEM_TYPE = {
    CLOTH_START = 100001,      -- 服装起始ID
    CLOTH_END = 191001,        -- 服装结束ID
    PET_ITEM_START = 300001,   -- 精灵道具起始
    PET_ITEM_END = 500001,     -- 精灵道具结束
    NONO_ITEM_START = 200001,  -- NONO道具起始
    NONO_ITEM_END = 299999,    -- NONO道具结束
}

-- CMD 2601: ITEM_BUY (购买物品)
-- 前端 BuyItemInfo 解析顺序: cash(4) + itemID(4) + itemNum(4) + itemLevel(4)
local function handleItemBuy(ctx)
    local itemId = 0
    local count = 1
    if #ctx.body >= 4 then
        itemId = readUInt32BE(ctx.body, 1)
    end
    if #ctx.body >= 8 then
        count = readUInt32BE(ctx.body, 5)
    end
    
    -- 获取用户数据并添加物品
    local user = ctx.getOrCreateUser(ctx.userId)
    user.items = user.items or {}
    user.coins = user.coins or 100000
    
    -- TODO: 扣除金币 (需要物品价格表)
    -- local price = getItemPrice(itemId) * count
    -- user.coins = user.coins - price
    
    local itemKey = tostring(itemId)
    if user.items[itemKey] then
        user.items[itemKey].count = (user.items[itemKey].count or 1) + count
    else
        user.items[itemKey] = {
            count = count,
            expireTime = 0x057E40  -- 永久
        }
    end
    ctx.saveUser(ctx.userId, user)
    
    -- 返回成功 (匹配前端 BuyItemInfo 解析格式)
    local body = writeUInt32BE(user.coins) ..     -- cash (剩余金币)
                writeUInt32BE(itemId) ..          -- itemID
                writeUInt32BE(count) ..           -- itemNum
                writeUInt32BE(0)                  -- itemLevel
    ctx.sendResponse(buildResponse(2601, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → ITEM_BUY %d x%d response (coins=%d)\27[0m", itemId, count, user.coins))
    return true
end

-- CMD 2602: ITEM_SALE (出售物品)
local function handleItemSale(ctx)
    local itemId = 0
    local count = 1
    if #ctx.body >= 4 then
        itemId = readUInt32BE(ctx.body, 1)
    end
    if #ctx.body >= 8 then
        count = readUInt32BE(ctx.body, 5)
    end
    
    -- 获取用户数据并移除物品
    local user = ctx.getOrCreateUser(ctx.userId)
    user.items = user.items or {}
    
    local itemKey = tostring(itemId)
    if user.items[itemKey] then
        user.items[itemKey].count = (user.items[itemKey].count or 1) - count
        if user.items[itemKey].count <= 0 then
            user.items[itemKey] = nil
        end
        ctx.saveUser(ctx.userId, user)
    end
    
    ctx.sendResponse(buildResponse(2602, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → ITEM_SALE %d x%d response\27[0m", itemId, count))
    return true
end

-- CMD 2604: CHANGE_CLOTH (更换服装)
-- 请求: clothCount(4) + [clothId(4)]...
-- 响应: userID(4) + clothCount(4) + [clothId(4) + clothType(4)]...
-- 需要广播给同地图其他玩家
local function handleChangeCloth(ctx)
    -- 解析请求
    local clothCount = 0
    local clothIds = {}
    
    if #ctx.body >= 4 then
        clothCount = readUInt32BE(ctx.body, 1)
        for i = 1, clothCount do
            local offset = 5 + (i - 1) * 4
            if #ctx.body >= offset + 3 then
                local clothId = readUInt32BE(ctx.body, offset)
                table.insert(clothIds, clothId)
            end
        end
    end
    
    -- 保存到用户数据
    local user = ctx.getOrCreateUser(ctx.userId)
    user.clothes = clothIds
    ctx.saveUser(ctx.userId, user)
    
    -- 构建响应体
    local body = writeUInt32BE(ctx.userId) .. writeUInt32BE(#clothIds)
    for _, clothId in ipairs(clothIds) do
        body = body .. writeUInt32BE(clothId)
        body = body .. writeUInt32BE(0)  -- clothType (从XML获取，这里简化为0)
    end
    
    -- 发送响应给请求者
    ctx.sendResponse(buildResponse(2604, ctx.userId, 0, body))
    
    -- 广播给同地图其他玩家
    if ctx.broadcastToMap then
        ctx.broadcastToMap(buildResponse(2604, ctx.userId, 0, body), ctx.userId)
    end
    
    print(string.format("\27[32m[Handler] → CHANGE_CLOTH response (%d clothes, broadcast)\27[0m", #clothIds))
    return true
end

-- CMD 2607: ITEM_EXPEND (消耗物品)
local function handleItemExpend(ctx)
    local itemId = 0
    local count = 1
    if #ctx.body >= 4 then
        itemId = readUInt32BE(ctx.body, 1)
    end
    if #ctx.body >= 8 then
        count = readUInt32BE(ctx.body, 5)
    end
    
    -- 获取用户数据并消耗物品
    local user = ctx.getOrCreateUser(ctx.userId)
    user.items = user.items or {}
    
    local itemKey = tostring(itemId)
    if user.items[itemKey] then
        user.items[itemKey].count = (user.items[itemKey].count or 1) - count
        if user.items[itemKey].count <= 0 then
            user.items[itemKey] = nil
        end
        ctx.saveUser(ctx.userId, user)
    end
    
    ctx.sendResponse(buildResponse(2607, ctx.userId, 0, ""))
    print(string.format("\27[32m[Handler] → ITEM_EXPEND %d x%d response\27[0m", itemId, count))
    return true
end

-- CMD 2605: ITEM_LIST (物品列表)
-- 请求: itemType1(4) + itemType2(4) + itemType3(4)
-- 响应: itemCount(4) + [itemId(4) + count(4) + expireTime(4) + unknown(4)]...
local function handleItemList(ctx)
    -- 解析请求的物品类型范围
    local itemType1, itemType2, itemType3 = 0, 0, 0
    if #ctx.body >= 12 then
        itemType1 = readUInt32BE(ctx.body, 1)
        itemType2 = readUInt32BE(ctx.body, 5)
        itemType3 = readUInt32BE(ctx.body, 9)
    end
    
    print(string.format("\27[36m[Handler] ITEM_LIST 查询范围: %d-%d, %d\27[0m", itemType1, itemType2, itemType3))
    
    -- 获取用户数据
    local user = ctx.getOrCreateUser(ctx.userId)
    local userItems = user.items or {}
    
    -- 构建物品列表响应
    local itemCount = 0
    local itemData = ""
    local addedItems = {}  -- 防止重复添加
    
    -- 辅助函数: 添加物品
    local function addItem(itemId, count, expireTime)
        if addedItems[itemId] then return end
        addedItems[itemId] = true
        itemData = itemData ..
            writeUInt32BE(itemId) ..
            writeUInt32BE(count) ..
            writeUInt32BE(expireTime or 0x057E40) ..
            writeUInt32BE(0)
        itemCount = itemCount + 1
    end
    
    -- 检查物品是否在请求范围内
    local function isInRange(id)
        return (id >= itemType1 and id <= itemType2) or id == itemType3
    end
    
    -- 从用户数据库加载物品
    for itemId, itemInfo in pairs(userItems) do
        local id = tonumber(itemId)
        if id and isInRange(id) then
            addItem(id, itemInfo.count or 1, itemInfo.expireTime)
        end
    end
    
    -- 注意: 不再自动添加默认服装，只返回用户实际拥有的物品

    local body = writeUInt32BE(itemCount) .. itemData
    ctx.sendResponse(buildResponse(2605, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → ITEM_LIST response (%d items)\27[0m", itemCount))
    return true
end

-- CMD 2606: MULTI_ITEM_BUY (批量购买物品)
-- 请求格式: itemCount(4) + [itemId(4)]...
-- 官服响应格式: result(4) + remainCoins(4)
local function handleMultiItemBuy(ctx)
    local itemCount = 0
    local itemIds = {}
    
    if #ctx.body >= 4 then
        itemCount = readUInt32BE(ctx.body, 1)
    end
    
    -- 解析所有物品ID
    for i = 1, itemCount do
        local offset = 5 + (i - 1) * 4
        if #ctx.body >= offset + 3 then
            local itemId = readUInt32BE(ctx.body, offset)
            table.insert(itemIds, itemId)
        end
    end
    
    -- 获取用户数据并添加物品
    local user = ctx.getOrCreateUser(ctx.userId)
    user.items = user.items or {}
    user.coins = user.coins or 100000
    
    -- 添加所有物品
    for _, itemId in ipairs(itemIds) do
        local itemKey = tostring(itemId)
        if user.items[itemKey] then
            user.items[itemKey].count = (user.items[itemKey].count or 1) + 1
        else
            user.items[itemKey] = {
                count = 1,
                expireTime = 0x057E40  -- 永久
            }
        end
    end
    ctx.saveUser(ctx.userId, user)
    
    -- 返回成功 (匹配官服格式: result + remainCoins)
    local body = writeUInt32BE(0) ..              -- result (0=成功)
                writeUInt32BE(user.coins)         -- 剩余金币
    ctx.sendResponse(buildResponse(2606, ctx.userId, 0, body))
    
    local itemIdsStr = table.concat(itemIds, ",")
    print(string.format("\27[32m[Handler] → MULTI_ITEM_BUY %d items [%s] response (coins=%d)\27[0m", 
        itemCount, itemIdsStr, user.coins))
    return true
end

-- CMD 2609: EQUIP_UPDATA (装备升级)
local function handleEquipUpdate(ctx)
    ctx.sendResponse(buildResponse(2609, ctx.userId, 0, ""))
    print("\27[32m[Handler] → EQUIP_UPDATA response\27[0m")
    return true
end

-- CMD 2901: EXCHANGE_CLOTH_COMPLETE (兑换服装完成)
local function handleExchangeClothComplete(ctx)
    local exchangeId = 0
    if #ctx.body >= 4 then
        exchangeId = readUInt32BE(ctx.body, 1)
    end
    
    -- 返回成功 (实际应该根据exchangeId给予对应物品)
    local body = writeUInt32BE(0) ..      -- ret
                writeUInt32BE(0) ..       -- itemId (获得的物品)
                writeUInt32BE(1)          -- count
    ctx.sendResponse(buildResponse(2901, ctx.userId, 0, body))
    print(string.format("\27[32m[Handler] → EXCHANGE_CLOTH_COMPLETE %d response\27[0m", exchangeId))
    return true
end

-- 注册所有处理器
function ItemHandlers.register(Handlers)
    Handlers.register(2601, handleItemBuy)
    Handlers.register(2602, handleItemSale)
    Handlers.register(2604, handleChangeCloth)
    Handlers.register(2605, handleItemList)
    Handlers.register(2606, handleMultiItemBuy)
    Handlers.register(2607, handleItemExpend)
    Handlers.register(2609, handleEquipUpdate)
    Handlers.register(2901, handleExchangeClothComplete)
    print("\27[36m[Handlers] 物品命令处理器已注册\27[0m")
end

return ItemHandlers
