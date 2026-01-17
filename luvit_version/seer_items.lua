local fs = require("fs")
local xml_parser = require("./gameserver/xml_parser")

local SeerItems = {}
local itemsMap = {}
SeerItems.loaded = false
SeerItems.count = 0

function SeerItems.load()
    if SeerItems.loaded then return end
    
    print("Loading items from data/items.xml...")
    local data = fs.readFileSync("data/items.xml")
    if not data then 
        print("Error: data/items.xml not found")
        return 
    end
    
    local parser = xml_parser:new()
    local tree = parser:parse(data)
    
    if not tree or tree.name ~= "Items" then
        print("Error: Invalid items.xml format")
        return
    end
    
    local count = 0
    -- <Items><Cat ...><Item .../><Item .../></Cat>...</Items>
    
    for _, catNode in ipairs(tree.children) do
        if catNode.name == "Cat" then
            local catId = tonumber(catNode.attributes.ID)
            
            for _, itemNode in ipairs(catNode.children) do
                if itemNode.name == "Item" and itemNode.attributes then
                    local id = tonumber(itemNode.attributes.ID)
                    if id then
                        itemsMap[id] = {
                            id = id,
                            catId = catId,
                            name = itemNode.attributes.Name,
                            price = tonumber(itemNode.attributes.Price) or 0,
                            sellPrice = tonumber(itemNode.attributes.SellPrice) or 0,
                            max = tonumber(itemNode.attributes.Max) or 0,
                            isVipOnly = (tonumber(itemNode.attributes.VipOnly) or 0) == 1,
                            tradability = tonumber(itemNode.attributes.Tradability) or 3,
                            vipTradability = tonumber(itemNode.attributes.VipTradability) or 3,
                            type = itemNode.attributes.type, -- head, foot, etc.
                            speed = tonumber(itemNode.attributes.speed),
                            fun = tonumber(itemNode.attributes.Fun), -- functional item?
                            
                            -- Stat bonuses (for Equipment)
                            pkHp = tonumber(itemNode.attributes.PkHp) or 0,
                            pkAtk = tonumber(itemNode.attributes.PkAtk) or 0,
                            pkDef = tonumber(itemNode.attributes.PkDef) or 0,
                            
                            -- Effects
                            newSeIdx = tonumber(itemNode.attributes.NewSeIdx),
                            itemSeId = tonumber(itemNode.attributes.ItemSeId)
                        }
                        count = count + 1
                    end
                end
            end
        end
    end
    
    SeerItems.count = count
    SeerItems.loaded = true
    print("Loaded " .. count .. " items from XML.")
end

function SeerItems.get(id)
    return itemsMap[id]
end

function SeerItems.getPrice(id)
    local item = itemsMap[id]
    return item and item.price or 0
end

function SeerItems.getMax(id)
    local item = itemsMap[id]
    if not item then return 99999 end
    -- 如果 max 为 0 或 nil，返回默认值 99999
    if not item.max or item.max == 0 then return 99999 end
    return item.max
end

function SeerItems.getName(id)
    local item = itemsMap[id]
    return item and item.name or ("Item" .. id)
end

function SeerItems.exists(id)
    return itemsMap[id] ~= nil
end

return SeerItems
