-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

-- Strings in GBAFE are huffman-encoded with a custom table encoding
-- However, ROM-hacks of GBAFE work around this by encoding text raw and "marking" the text pointers
-- We support both

local addrs = require 'gbafe.addresses'

local bit = require 'bit'

local strings = {}

local function huffman_decode(addr)
    -- adapted from this python script (written by me)
    -- https://github.com/StanHash/DOC/blob/master/huffman/huffman.py

    local root_node_addr = memory.readlong(addrs.HuffRoot)
    local root_node = memory.readlong(root_node_addr)

    local byte = 0
    local bits = 0

    local result = ""

    for i = 1, 0x1000 do
        local node = root_node

        -- while node isn't leaf
        while bit.band(node, 0x80000000) == 0 do
            if bits == 0 then
                -- read new byte!
                bits = 8
                byte = memory.readbyte(addr)
                addr = addr + 1
            end

            -- this_bit = byte & 1
            local this_bit = byte % 2

            -- next_node_idx = 0xFFFF & (node >> (16 * this_bit))
            local next_node_idx = bit.band(0xFFFF, bit.rshift(node, 16 * this_bit))

            node = memory.readlong(addrs.HuffTable + next_node_idx * 4)

            byte = bit.rshift(byte, 1)
            bits = bits - 1
        end

        local value = bit.band(node, 0xFFFF)

        if value > 0xFF then
            -- big value! two bytes
            result = result .. string.char(
                bit.band(0xFF, value),
                bit.band(0xFF, bit.rshift(value, 8)))
        elseif value ~= 0 then
            -- small value! one byte
            result = result .. string.char(
                bit.band(0xFF, value))
        else
            -- zero! the end
            return result
        end
    end

    return "ERROR TEXT"
end

-- this is public, to allow other modules to grab text from ram
function strings.DecodeRawString(addr, end_addr)
    local result = ""

    for i = 1, 0x1000 do
        local byte = memory.readbyte(addr)
        addr = addr + 1

        if byte == 0 or (addr == end_addr) then
            return result
        end

        result = result .. string.char(byte)
    end

    return "ERROR TEXT"
end

-- TODO: move elsewhere
local abbrev_table = {
    ["Mntn"] = "Mountain",
}

-- TODO: this should be better than this
local function expand_abbrev(value)
    if abbrev_table[value] ~= nil then
        return abbrev_table[value]
    else
        return value
    end
end

--- Gets a string from the game's message table
--- @param string_id integer
--- @return string
function strings.GetString(string_id)
    local string_addr = memory.readlong(addrs.MessageTable + 4 * string_id)
    local is_anti_huffman_marked = bit.band(string_addr, 0x80000000) ~= 0

    if is_anti_huffman_marked then
        local result = strings.DecodeRawString(bit.band(string_addr, 0x0FFFFFFF))
        return expand_abbrev(result)
    else
        local result = huffman_decode(string_addr)
        return expand_abbrev(result)
    end
end

return strings
