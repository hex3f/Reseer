local fs = require('fs')

local SeerItems = {}
SeerItems.items = {}  -- id -> item data {price, sellPrice, name}
SeerItems.loaded = false

-- XML Attribute Parser (Simple Regex)
local function parseAttributes(tag)
    local attrs = {}
    for key, value in tag:gmatch('(%w+)="([^"]*)"') do
        attrs[key] = value
    end
    return attrs
end

function SeerItems.load()
    if SeerItems.loaded then return true end

    -- Try multiple paths for data/items.xml
    local possiblePaths = {
        "./data/items.xml",
        "../data/items.xml",
        "luvit_version/data/items.xml"
    }
    
    local content = nil
    local loadPath = nil
    
    for _, path in ipairs(possiblePaths) do
        local data, err = fs.readFileSync(path)
        if data then
            content = data
            loadPath = path
            break
        end
    end
    
    if not content then
        print("[SeerItems] Failed to load items.xml from any candidate path.")
        return false
    end
    
    print("[SeerItems] Loading items from: " .. loadPath)
    
    -- Parse <Cat> blocks to handle Category defaults (like Max)
    local count = 0
    -- Lua pattern note: (.-) is non-greedy match
    for catAttrsStr, catBody in content:gmatch('<Cat([^>]+)>(.-)</Cat>') do
        local catAttrs = parseAttributes(catAttrsStr)
        local catMax = tonumber(catAttrs.Max) or 4000000000 -- Default huge if missing
        
        for itemTag in catBody:gmatch("<Item(.-)/>") do
            local attrs = parseAttributes(itemTag)
            if attrs.ID then
                local id = tonumber(attrs.ID)
                SeerItems.items[id] = {
                    price = tonumber(attrs.Price) or 0,
                    sellPrice = tonumber(attrs.SellPrice) or 0,
                    name = attrs.Name or "",
                    type = attrs.Type,
                    max = tonumber(attrs.Max) or catMax -- Use Item Max or fallback to Cat Max
                }
                count = count + 1
            end
        end
    end
    
    print(string.format("[SeerItems] Parsed %d items.", count))
    SeerItems.loaded = true
    return true
end

function SeerItems.get(itemId)
    if not SeerItems.loaded then SeerItems.load() end
    return SeerItems.items[itemId]
end

function SeerItems.getPrice(itemId)
    local item = SeerItems.get(itemId)
    return item and item.price or 0
end

function SeerItems.getMax(itemId)
    local item = SeerItems.get(itemId)
    return item and item.max or 4000000000
end

function SeerItems.getName(itemId)
    local item = SeerItems.get(itemId)
    return item and item.name or ""
end

-- Auto-load
SeerItems.load()

return SeerItems
