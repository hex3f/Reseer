-- Minimal Object implementation to avoid require("core") conflict
local Object = {}
Object.meta = {__index = Object}

function Object:create()
  local meta = rawget(self, "meta")
  if not meta then error("Cannot inherit from instance object") end
  return setmetatable({}, meta)
end

function Object:new(...)
  local obj = self:create()
  if type(obj.initialize) == "function" then
    obj:initialize(...)
  end
  return obj
end

function Object:extend()
  local obj = self:create()
  local meta = {}
  -- Copy meta-methods
  for k, v in pairs(self.meta) do
    meta[k] = v
  end
  meta.__index = obj
  obj.meta = meta
  return obj
end

local XmlParser = Object:extend()

function XmlParser:initialize()
    self.xml = ""
    self.pos = 1
end

function XmlParser:parse(xmlText)
    self.xml = xmlText
    self.pos = 1
    local root = {children = {}}
    local stack = {root}
    
    while true do
        local type, content, attributes = self:nextToken()
        if not type then break end
        
        if type == "open" or type == "self-closing" then
            local node = {
                name = content,
                attributes = attributes,
                children = {}
            }
            table.insert(stack[#stack].children, node)
            
            if type == "open" then
                table.insert(stack, node)
            end
        elseif type == "close" then
            if stack[#stack].name == content then
                table.remove(stack)
            end
        elseif type == "text" then
            -- For now, we might ignore text nodes if they are just whitespace
            -- But for robustness, we can add them
            if content:match("%S") then
                 table.insert(stack[#stack].children, {text = content})
            end
        end
    end
    
    -- Return the first real child as root (since we used a dummy root)
    return root.children[1]
end

function XmlParser:nextToken()
    local i = self.pos
    local len = #self.xml
    
    -- Skip whitespace
    while i <= len and self.xml:sub(i, i):match("%s") do
        i = i + 1
    end
    
    if i > len then return nil end
    
    if self.xml:sub(i, i) == "<" then
        -- Tag
        local j = self.xml:find(">", i)
        if not j then return nil end -- Malformed
        
        local content = self.xml:sub(i+1, j-1)
        self.pos = j + 1
        
        -- Check for comments like <!-- -->
        if content:sub(1, 3) == "!--" then
            -- Skip comment
            -- If the comment ended with -->, we are good. content is just "!-- ...."
            -- But wait, find(">") stops at the first >, which might be inside a comment if logic is simple.
            -- Real comments can contain >? Actually XML comments can't contain --. 
            -- But effectively we just need to skip it.
            -- If the greedy find failed (e.g. comment has > inside), we might need loop.
            -- For simplicity assume standard "-->" ending.
             if content:sub(-2) == "--" then
                 return self:nextToken() -- Recursively get next token
             else
                 -- Need to find actual end of comment
                 local commentEnd = self.xml:find("%-%->", i)
                 if commentEnd then
                     self.pos = commentEnd + 3
                     return self:nextToken()
                 end
             end
             return self:nextToken()
        end

        -- Check closing tag </...>
        if content:sub(1, 1) == "/" then
            return "close", content:sub(2):match("^%S+") -- Name only
        end
        
        -- Check self-closing <... />
        local isSelfClosing = false
        if content:sub(-1) == "/" then
            isSelfClosing = true
            content = content:sub(1, -2)
        end
        
        -- Parse attributes
        local name = content:match("^%S+")
        local attributes = {}
        
        for key, val in content:gmatch("(%w+)%s*=%s*['\"]([^'\"]*)['\"]") do
            attributes[key] = val
        end
        
        return isSelfClosing and "self-closing" or "open", name, attributes
    else
        -- Text content
        local j = self.xml:find("<", i)
        if not j then j = len + 1 end
        
        local text = self.xml:sub(i, j-1)
        self.pos = j
        return "text", text
    end
end

return XmlParser
