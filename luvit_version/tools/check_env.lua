local fs = require('fs')
local buffer = require('buffer')

print("=== Environment Self-Check ===")

-- Check Luvit version
print("Luvit Version: " .. (process.version or "unknown"))

-- Check Buffer
print("Checking Buffer...")
local buf = buffer.Buffer:new(4)
if buf.writeUInt32BE then
    buf:writeUInt32BE(1, 0x12345678)
    print("Buffer.writeUInt32BE: OK")
else
    print("Buffer.writeUInt32BE: MISSING")
end

-- Check legacy buffer extensions
if buf.wuint then
    print("Buffer.wuint (extension): OK")
else
    print("Buffer.wuint (extension): MISSING")
end

-- Check fs
print("Checking fs...")
local success, err = pcall(function()
    local fd = fs.openSync("check_env_test.txt", "w")
    fs.writeSync(fd, -1, "test")
    fs.closeSync(fd)
    fs.unlinkSync("check_env_test.txt")
end)

if success then
    print("fs.openSync/writeSync: OK")
else
    print("fs.openSync/writeSync: FAILED - " .. tostring(err))
end

print("=== Check Complete ===")
