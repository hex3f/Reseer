-- 统一的 XML 加载器
-- 处理文件读取、BOM 移除和解析

local status_fs, fs = pcall(require, 'fs')
if not status_fs then
    if _G.fs then
        fs = _G.fs
    else
        print("[XmlLoader] WARNING: fs module not found, file loading disabled.")
        fs = {
            readFileSync = function() return nil end
        }
    end
end
local xml_parser = require('core/xml_parser')

local XmlLoader = {}

-- 移除 UTF-8 BOM
local function stripBOM(content)
    if not content then return nil end
    if #content >= 3 and string.byte(content, 1) == 0xEF and string.byte(content, 2) == 0xBB and string.byte(content, 3) == 0xBF then
        return string.sub(content, 4)
    end
    return content
end

-- 加载并解析 XML 文件
function XmlLoader.load(path)
    -- 尝试读取文件
    local success, content = pcall(function()
        return fs.readFileSync(path)
    end)
    
    if not success or not content then
        return nil, "File read failed: " .. path
    end
    
    -- 移除 BOM
    content = stripBOM(content)
    
    -- 解析 XML
    local parser = xml_parser:new()
    local tree = nil
    local parseSuccess, err = pcall(function()
        tree = parser:parse(content)
    end)
    
    if not parseSuccess or not tree then
        return nil, "XML parse failed: " .. (err or "unknown error")
    end
    
    return tree
end

return XmlLoader
