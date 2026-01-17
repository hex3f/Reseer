local fs = require('fs')

local function main()
    -- Get args
    local args = process.argv
    local inputPath = args[2]
    local outputPath = args[3]
    
    if not inputPath or not outputPath then
        print("Usage: luvit extract_xml.lua <input.bin> <output.xml>")
        return
    end
    
    print("Reading from: " .. inputPath)
    local content, err = fs.readFileSync(inputPath)
    
    if not content then
        print("Error reading file: " .. tostring(err))
        return
    end
    
    -- Check for ZLib header (0x78 0x9C is default zlib, 0x78 0xDA is best compression)
    -- But strict Zlib check: byte 0 = 0x78, byte 1 is valid flags.
    local byte1 = string.byte(content, 1)
    local byte2 = string.byte(content, 2)
    local byte3 = string.byte(content, 3)
    
    local outputContent = content
    
    -- Simple heuristic: If it starts with '<', it's already XML. 
    -- If it starts with 'FWS' or 'CWS' it's SWF (compressed/uncompressed).
    -- If it starts with 0x78, it MIGHT be zlib.
    
    if string.char(byte1) == '<' then
        print("Format: Plain XML detected.")
    elseif byte1 == 0x78 and (byte2 == 0x9C or byte2 == 0xDA or byte2 == 0x01) then
        print("Format: ZLib compressed data detected. Decompressing...")
        local zlib = require('zlib')
        if zlib then
             -- Try inflate
             local status, result = pcall(function() return zlib.inflate(content) end)
             if status then
                 outputContent = result
                 print("Decompression successful.")
             else
                 print("Decompression failed, saving as is. Error: " .. tostring(result))
             end
        else
            print("Warning: zlib module not found in environment, saving as is.")
        end
    else
        print(string.format("Format: Unknown header (0x%02X 0x%02X 0x%02X). Saving as is.", byte1, byte2, byte3 or 0))
    end

    print("Writing to: " .. outputPath)
    fs.writeFileSync(outputPath, outputContent)
    print("Done.")
end

main()
