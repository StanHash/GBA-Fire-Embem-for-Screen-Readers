-- some of this references the work done on pokemon-access

local board = require 'gbafe.board'
local strings = require 'gbafe.strings'
local dialogue = require 'gbafe.dialogue'

local tolk = require 'tolk'

local prev_x, prev_y = 0, 0

local function coord_to_sheet_column(coord)
    local a = string.byte('A')

    -- always do first coord
    local result = string.char(a + coord % 26)
    coord = math.floor(coord / 26)

    while coord > 0 do
        -- TODO: test this

        -- this should go Z .. AA
        -- this is not like numbers where there's zero you can lead with infinitely
        coord = coord - 1 -- so that we start with A and not B

        result = string.char(a + coord % 26) .. result
        coord = math.floor(coord / 26)
    end

    return result
end

-- translates a in-game position to a spreadsheet-like coordinate
local function position_to_cell(x, y)
    return coord_to_sheet_column(x) .. (y + 1)
end

-- join list of strings with sep
local function join(sep, string_list)
    if #string_list > 0 then
        local message = string_list[1]

        for i = 2, #string_list do
            message = message .. sep .. string_list[i]
        end

        return message
    else
        return nil
    end
end

local function nicer_unit(unit)
    local unit_id = unit:unit_id()

    local name = unit:pid_name()

    -- local class_msg = unit:jid_name_msg()
    -- local class_str = GetString(class_msg)

    if unit_id >= 0x80 then
        return "Enemy " .. name .. " " .. ((unit:is_boss() and "Boss") or (unit_id - 0x80))
    elseif unit_id >= 0x40 then
        return "NPC " .. name
    else
        return name
    end
end

local debug = true

local function output(message)
    if debug then
        -- this may be undesirable when running for real?
        print(message)
    end

    tolk.output(message)
end

local function boolean_on_off(bool_value)
    if bool_value then return "on" else return "off" end
end

local terrain_toggle = false
local coord_toggle = false
local unit_toggle = false

local prev = {}

local function current_unit_output(func)
    local x, y = board.GetCursorPosition()
    local unit = board.GetUnitAt(x, y)

    if unit ~= nil then
        output(func(unit))
    else
        unit = board.GetActiveUnit()

        if unit ~= nil and unit:is_active() then
            output("Active unit, " .. func(unit))
        else
            output("No unit")
        end
    end
end

-- NOT OK KEYS: X C A S (Q)
-- OK KEYS: anything else?

local commands = {
    -- ["key"] = function(shift_held)

    ["T"] = function(shift_held)
        -- terrain name key
        if shift_held then
            terrain_toggle = not terrain_toggle
            output("Terrain toggle " .. boolean_on_off(terrain_toggle))
        else
            local x, y = board.GetCursorPosition()
            output(board.GetTerrainNameAt(x, y))
        end
    end,

    ["Y"] = function(shift_held)
        if shift_held then
            coord_toggle = not coord_toggle
            output("Coordinate toggle " .. boolean_on_off(coord_toggle))
        else
            local x, y = board.GetCursorPosition()
            output(position_to_cell(x, y))
        end
    end,

    ["U"] = function(shift_held)
        if shift_held then
            unit_toggle = not unit_toggle
            output("Unit toggle " .. boolean_on_off(unit_toggle))
        else
            current_unit_output(nicer_unit)
        end
    end,

    ["H"] = function(shift_held)
        current_unit_output(function(unit)
            return unit:current_hp() .. " HP out of " .. unit:max_hp()
        end)
    end,

    ["J"] = function(shift_held)
        current_unit_output(function(unit)
            return unit:jid_name()
        end)
    end,

    ["L"] = function(shift_held)
        output(dialogue.GetTalkString())
    end
}

local function handle_user_input()
    local kbd = input.read()

    local shift_held = kbd["shift"] == true

    for key, func in pairs(commands) do
        if kbd[key] and not prev[key] then
            tolk.silence()
            func(shift_held)
            break
        end
    end

    prev = kbd
end

local function process_coordinate_changes()
    local x, y = board.GetCursorPosition()

    if x ~= prev_x or y ~= prev_y then
        local messages = {}

        if coord_toggle then
            messages[#messages + 1] = position_to_cell(x, y)
        end

        if terrain_toggle then
            messages[#messages + 1] = board.GetTerrainNameAt(x, y)
        end

        if unit_toggle then
            local unit = board.GetUnitAt(x, y)

            if unit ~= nil then
                messages[#messages + 1] = nicer_unit(unit)
            end
        end

        local message = join(" ", messages)

        if message ~= nil then
            output(message)
        end
    end

    prev_x, prev_y = x, y
end

local function main_loop()
    handle_user_input()
    process_coordinate_changes()
end

output("Ready")

while true do
    emu.frameadvance()
    main_loop()
end