-- Debug entry point to catch top-level require errors
local function main()
    require('./start_gameserver')
end

local function traceback(err)
    local msg = debug.traceback(err, 2)
    print("\n\n=== CRITICAL STARTUP ERROR ===")
    print(msg)
    print("==============================\n")
    
    -- Try to write to file using io
    local f = io.open("debug_crash.log", "w")
    if f then
        f:write(msg)
        f:close()
        print("Error details written to debug_crash.log")
    end
    return msg
end

xpcall(main, traceback)
