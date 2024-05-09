-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

-- Utilities for accessing the board (map)

local addrs = require 'gbafe.addresses'
local strings = require 'gbafe.strings'

local Unit = require 'gbafe.Unit'

local board = {}

local function deref_cell(x, y, addr_map)
    local addr_rows = memory.readlong(addr_map)
    local addr_row = memory.readlong(addr_rows + 4 * y)
    local cell = memory.readbyte(addr_row + x)

    return cell
end

function board.GetMapSize()
    local x = memory.readshort(addrs.MapSize + 0)
    local y = memory.readshort(addrs.MapSize + 2)

    return x, y
end

function board.GetCursorPosition()
    local x = memory.readshort(addrs.BmStatus + 0x14)
    local y = memory.readshort(addrs.BmStatus + 0x16)

    return x, y
end

---@param x integer
---@param y integer
---@return Unit | nil
function board.GetUnitAt(x, y)
    local unit_id = deref_cell(x, y, addrs.MapUnit)

    if unit_id ~= 0 then
        local unit_addr = memory.readlong(addrs.UnitLookup + unit_id * 4)
        return Unit:new(unit_addr)
    else
        return nil
    end
end

function board.GetActiveUnit()
    local unit_addr = memory.readlong(addrs.ActiveUnit)

    if unit_addr ~= 0 then
        return Unit:new(unit_addr)
    else
        return nil
    end
end

-- grabbed from decomp symbols, unused (grabbing from in-game text)
local fallback_terrain_names = {
    [0x00] = "TILE",
    [0x01] = "Plain",
    [0x02] = "ROAD",
    [0x03] = "VILLAGE",
    [0x04] = "VILLAGE",
    [0x05] = "HOUSE",
    [0x06] = "ARMORY",
    [0x07] = "VENDOR",
    [0x08] = "ARENA",
    [0x09] = "C ROOM",
    [0x0A] = "FORT",
    [0x0B] = "GATE",
    [0x0C] = "FOREST",
    [0x0D] = "THICKET",
    [0x0E] = "SAND",
    [0x0F] = "DESERT",
    [0x10] = "RIVER",
    [0x11] = "MOUNTAIN",
    [0x12] = "PEAK",
    [0x13] = "BRIDGE",
    [0x14] = "BRIDGE",
    [0x15] = "SEA",
    [0x16] = "LAKE",
    [0x17] = "FLOOR",
    [0x18] = "FLOOR",
    [0x19] = "FENCE",
    [0x1A] = "WALL",
    [0x1B] = "WALL",
    [0x1C] = "RUBBLE",
    [0x1D] = "PILLAR",
    [0x1E] = "DOOR",
    [0x1F] = "THRONE",
    [0x20] = "CHEST",
    [0x21] = "CHEST",
    [0x22] = "ROOF",
    [0x23] = "GATE",
    [0x24] = "CHURCH",
    [0x25] = "RUINS",
    [0x26] = "CLIFF",
    [0x27] = "BALLISTA",
    [0x28] = "BALLISTA",
    [0x29] = "BALLISTA",
    [0x2A] = "SHIP FLAT",
    [0x2B] = "SHIPWRECK",
    [0x2C] = "TILE",
    [0x2D] = "STAIRS",
    [0x2E] = "WALL",
    [0x2F] = "GLACIER",
    [0x30] = "ARENA",
    [0x31] = "VALLEY",
    [0x32] = "FENCE",
    [0x33] = "SNAG",
    [0x34] = "BRIDGE",
    [0x35] = "SKY",
    [0x36] = "DEEPS",
    [0x37] = "RUINS",
    [0x38] = "INN",
    [0x39] = "BARREL",
    [0x3A] = "BONE",
    [0x3B] = "DARK",
    [0x3C] = "WATER",
    [0x3D] = "GUNNELS",
    [0x3E] = "DECK",
    [0x3F] = "BRACE",
    [0x40] = "MAST",
}

function board.GetTerrainNameAt(x, y)
    local terrain = deref_cell(x, y, addrs.MapTerrain)
    local terrain_name_msg = memory.readshort(addrs.TerrainNameMsg + 2 * terrain)

    -- if terrain_names[terrain] ~= nil then
    --     return terrain_names[terrain]
    if terrain_name_msg ~= 0 then
        local terrain_name = strings.GetString(terrain_name_msg)

        if terrain_name ~= nil then
            return terrain_name
        end
    end

    if fallback_terrain_names[terrain] ~= nil then
        return fallback_terrain_names[terrain]
    else
        return "Unknwown terrain"
    end
end

return board
