
local net = require('net')
local Packet = require('./packet')
local Handlers = require('../protocol/handlers')
local Buffer = require('./bytebuffer').Buffer

local PORT = 5001

local Server = {}

function Server.start()
    local server = net.createServer(function(client)
        local buffer = ""
        local expectedLen = nil

        print("Client connected: " .. tostring(client:getpeername().ip))

        client:on('data', function(chunk)
            buffer = buffer .. chunk

            while true do
                -- Check for header
                if expectedLen == nil then
                    if #buffer >= Packet.HEADER_LEN then
                        local header = Packet.readHeader(buffer)
                        expectedLen = header.len
                    else
                        break -- Wait for more data
                    end
                end

                -- Check for full packet
                if expectedLen and #buffer >= expectedLen then
                    local packetData = buffer:sub(1, expectedLen)
                    buffer = buffer:sub(expectedLen + 1)
                    
                    local header = Packet.readHeader(packetData)
                    local body = packetData:sub(Packet.HEADER_LEN + 1)
                    
                    print(string.format("Recv CMD: %d, User: %d, Len: %d", header.cmdId, header.userId, header.len))
                    
                    -- Dispatch
                    if Handlers[header.cmdId] then
                        Handlers[header.cmdId](client, header, body)
                    else
                        print("Unknown CMD: " .. header.cmdId)
                    end
                    
                    expectedLen = nil
                else
                    break -- Wait for more data
                end
            end
        end)

        client:on('end', function()
            print("Client disconnected")
        end)
        
        client:on('error', function(err)
            print("Client error: " .. tostring(err))
        end)
    end)

    server:listen(PORT, '0.0.0.0', function()
        print("Seer Server V2 listening on port " .. PORT)
    end)
    
    -- Also listen on 5002 for completeness
    local server2 = net.createServer(function(client) 
        -- Duplicate logic or shared handler? For now simple echo/ignore or same logic
        -- Just mirroring the structure for now
    end)
    server2:listen(5002, '0.0.0.0')
end

Server.start()
