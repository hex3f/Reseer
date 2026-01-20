-- Test script to load handlers one by one and report failures
local tprint = print
local function try_load(path)
    local ok, err = pcall(require, path)
    if ok then
        print("PASS: " .. path)
    else
        print("FAIL: " .. path)
        print("ERROR: " .. tostring(err))
    end
end

print("Testing Utils...")
try_load("./utils/binary_writer")
try_load("./utils/binary_reader")
try_load("./utils/response_builder")

print("\nTesting Core...")
try_load("./core/logger")
try_load("./core/userdb")

print("\nTesting Handlers...")
local handlers = {
    './handlers/nono_handlers',
    './handlers/pet_handlers',
    './handlers/pet_advanced_handlers',
    './handlers/task_handlers',
    './handlers/fight_handlers',
    './handlers/item_handlers',
    './handlers/friend_handlers',
    './handlers/mail_handlers',
    './handlers/map_handlers',
    './handlers/room_handlers',
    './handlers/team_handlers',
    './handlers/teampk_handlers',
    './handlers/arena_handlers',
    './handlers/exchange_handlers',
    './handlers/game_handlers',
    './handlers/misc_handlers',
    './handlers/special_handlers',
    './handlers/system_handlers',
    './handlers/teacher_handlers',
}

for _, h in ipairs(handlers) do
    try_load(h)
end
