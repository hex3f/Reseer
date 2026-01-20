-- Minimal Object implementation
local Object = {}
Object.meta = {__index = Object}
function Object:create() local meta = rawget(self, "meta"); if not meta then error("Cannot inherit") end; return setmetatable({}, meta) end
function Object:new(...) local obj = self:create(); if type(obj.initialize) == "function" then obj:initialize(...) end; return obj end
function Object:extend() local obj = self:create(); local meta = {}; for k, v in pairs(self.meta) do meta[k] = v end; meta.__index = obj; obj.meta = meta; return obj end

local DataClient = Object:extend()

function DataClient:initialize(url)
    self.url = url
end

function DataClient:get(path, cb)
    if cb then cb(nil, nil) end
end

function DataClient:post(path, data, cb)
    if cb then cb(nil, nil) end
end

return DataClient
