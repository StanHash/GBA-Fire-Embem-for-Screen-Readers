-- some of this references the work done on pokemon-access

local board = require 'gbafe.board'
local dialogue = require 'gbafe.dialogue'
local menus = require 'gbafe.menus'
local text = require 'gbafe.text'
local target_select = require 'gbafe.target_select'
local battle_forecast = require 'gbafe.battle_forecast'

local BattleUnit = require 'gbafe.BattleUnit'

local tolk = require 'tolk'

local prev_x, prev_y = 0, 0

--- @param message string
--- @param pred fun(): boolean
local function screen_info(message, pred)
    return { message = message, predicate = pred }
end

-- list of screens, most important first
local screen_info_table = {
    screen_info("Dialogue", dialogue.IsTalkActive),
    screen_info("Battle Target Selection", battle_forecast.IsActive),
    screen_info("Target Selection", target_select.IsActive),
    screen_info("Menu", menus.IsMenuActive),
    screen_info("Field", board.IsBoardVisible),
}

local function get_screen_message()
    for _, tab in ipairs(screen_info_table) do
        if tab.predicate() then
            return tab.message
        end
    end

    return nil
end

local function coord_to_sheet_column(coord)
    local A = string.byte('A')

    -- always do first coord
    local result = string.char(A + coord % 26)
    coord = math.floor(coord / 26)

    while coord > 0 do
        -- TODO: test this

        -- this should go Z .. AA
        -- this is not like numbers where there's zero you can lead with infinitely
        coord = coord - 1 -- so that we start with A and not B

        result = string.char(A + coord % 26) .. result
        coord = math.floor(coord / 26)
    end

    return result
end

-- translates a in-game position to a spreadsheet-like coordinate
local function position_to_cell(x, y)
    return coord_to_sheet_column(x) .. (y + 1)
end

local function nicer_unit(unit)
    local unit_id = unit:unit_id()
    local name = unit:pid_name()

    if unit_id >= 0x80 then
        local local_id = unit_id - 0x80
        return "Enemy " .. name .. " " .. ((unit:is_boss() and "Boss") or local_id)
    elseif unit_id >= 0x40 then
        return "NPC " .. name
    else
        return name
    end
end

local debug = true

--- Send message for reading to the screen reading.
--- Will also echo the message in the Lua console, for debugging.
--- @param message string
local function output(message)
    if #message > 0 then
        if debug then
            -- this may be undesirable when running for real?
            print(message)
        end

        tolk.output(message)
    end
end

--- Helper function for pretty-printing toggle status
--- @param bool_value boolean
--- @return string
local function boolean_on_off(bool_value)
    if bool_value then return "on" else return "off" end
end

local terrain_toggle = false
local coord_toggle = false
local unit_toggle = false
local unit_hp_toggle = false
local unit_class_toggle = false
local talk_toggle = false
local menu_toggle = false

local prev = {}

---@param func fun(unit: Unit): string
local function current_unit_output(func)
    local x, y = board.GetCursorPosition()
    local unit = board.GetUnitAt(x, y)

    if target_select.IsActive() then
        local target_addr = target_select.GetCurrentTargetAddr()

        if target_addr ~= nil then
            unit = target_select.Target:new(target_addr):unit() or unit
        end
    end

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

--- @type Unit|nil
local last_unit_for_item = nil
local last_item_slot = -1

local NTH = { [1] = "1st", [2] = "2nd", [3] = "3rd", [4] = "4th", [5] = "5th" }

--- @param unit Unit
--- @return string
local function unit_item(unit)
    if last_unit_for_item == nil or unit:unit_id() ~= last_unit_for_item:unit_id() then
        last_item_slot = -1
    end

    last_unit_for_item = unit

    local item_name = nil

    for i = 1, 5 do
        local item_slot = (last_item_slot + i) % 5
        local item = unit:get_item(item_slot)

        if item ~= nil then
            last_item_slot = item_slot

            item_name = item:name()

            local uses = item:uses()
            local max_uses = item:max_uses()

            if uses ~= 0 then
                item_name = item_name .. ", " .. uses

                if uses == 1 then
                    item_name = item_name .. " use left out of "
                else
                    item_name = item_name .. " uses left out of "
                end

                item_name = item_name .. max_uses
            end

            break
        end
    end

    if item_name ~= nil then
        if unit:get_item_count() == 1 then
            return item_name
        else
            return NTH[1 + last_item_slot] .. " item: " .. item_name
        end
    else
        return "This unit has no items"
    end
end

local function nice_battle_forecast()
    local bu_a = BattleUnit:new_a()
    local bu_b = BattleUnit:new_b()
    local hits_a = battle_forecast.GetHitCountA()
    local hits_b = battle_forecast.GetHitCountB()

    local sb = ""

    sb = sb .. "Your unit is " .. nicer_unit(bu_a)
    sb = sb .. ", " .. bu_a:hp_before() .. " HP"
    sb = sb .. ", " .. (bu_a:battle_attack() - bu_b:battle_defense()) .. " Attack"

    if hits_a > 1 then
        sb = sb .. " times " .. hits_a
    end

    sb = sb .. ", " .. bu_a:battle_hit_final() .. "% Hit"
    sb = sb .. ", " .. bu_a:battle_crit_final() .. "% Crit"

    sb = sb .. ", The opponent is " .. nicer_unit(bu_b)

    local item_name_b = battle_forecast.GetItemNameB()

    if item_name_b ~= nil then
        sb = sb .. " holding " .. item_name_b
    end

    sb = sb .. ", " .. bu_b:hp_before() .. " HP"

    if hits_b == 0 then
        sb = sb .. ", Cannot counterattack"
    else
        sb = sb .. ", " .. (bu_b:battle_attack() - bu_a:battle_defense()) .. " Attack"

        if hits_b > 1 then
            sb = sb .. " times " .. hits_b
        end

        sb = sb .. ", " .. bu_b:battle_hit_final() .. "% Hit"
        sb = sb .. ", " .. bu_b:battle_crit_final() .. "% Crit"
    end

    return sb
end

-- NOT OK KEYS: X C A S (Q)
-- OK KEYS: anything else?

local commands = {
    -- ["key"] = function(shift_held)

    ["G"] = function(shift_held)
        local current_screen = get_screen_message()

        if current_screen ~= nil then
            output(current_screen)
        end
    end,

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
        if shift_held then
            unit_hp_toggle = not unit_hp_toggle
            output("Unit HP toggle " .. boolean_on_off(unit_hp_toggle))
        else
            current_unit_output(function(unit)
                return unit:current_hp() .. " HP out of " .. unit:max_hp()
            end)
        end
    end,

    ["J"] = function(shift_held)
        if shift_held then
            unit_class_toggle = not unit_class_toggle
            output("Unit Class toggle " .. boolean_on_off(unit_class_toggle))
        else
            current_unit_output(function(unit)
                return unit:jid_name()
            end)
        end
    end,

    ["L"] = function(shift_held)
        if shift_held then
            talk_toggle = not talk_toggle
            output("Follow dialogue toggle " .. boolean_on_off(talk_toggle))
        else
            output(dialogue.GetCurrentSlice())
        end
    end,

    ["M"] = function(shift_held)
        if shift_held then
            menu_toggle = not menu_toggle
            output("Menu command toggle " .. boolean_on_off(menu_toggle))
        else
            if target_select.IsActive() then
                local targetted_unit = target_select.Target:new(target_select.GetCurrentTargetAddr()):unit()

                if targetted_unit ~= nil then
                    output("Targetting " .. nicer_unit(targetted_unit))
                else
                    output("Unknown target")
                end
            else
                output(menus.GetCurrentMenuItemName() or "Unknown menu item")
            end
        end
    end,

    ["I"] = function(shift_held)
        if shift_held then
            output("Unit Item is not toggleable")
        else
            current_unit_output(unit_item)
        end
    end,

    ["B"] = function(shift_held)
        if battle_forecast.IsActive() then
            output(nice_battle_forecast())
        else
            output("There is no battle forecast")
        end
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

        local unit = board.GetUnitAt(x, y)

        if unit ~= nil then
            if unit_toggle then
                messages[#messages + 1] = nicer_unit(unit)
            end

            if unit_class_toggle then
                messages[#messages + 1] = unit:jid_name()
            end

            if unit_hp_toggle then
                messages[#messages + 1] = unit:current_hp() .. " HP out of " .. unit:max_hp()
            end
        end

        -- local message = join(" ", messages)

        -- if message ~= nil then
        --     output(message)
        -- end

        for i, message in ipairs(messages) do
            output(message)
        end
    end

    prev_x, prev_y = x, y
end

local last_menu_item = nil

local function process_menu_items()
    local in_menu = menus.IsMenuActive()
    local current_item = menus.GetCurrentMenuItemName()

    if menu_toggle then
        if in_menu and current_item ~= nil then
            if current_item ~= last_menu_item then
                output(current_item)
            end
        end
    end

    last_menu_item = current_item
end

local was_talk_active = false
local last_slice = nil

local function process_follow_dialogue()
    local talk_active = dialogue.IsTalkActive()
    local current_slice = dialogue.GetCurrentSlice()

    if talk_toggle then
        if talk_active then
            if current_slice ~= last_slice then
                output(current_slice)
            end
        elseif was_talk_active then
            output("End of dialogue")
        end
    end

    last_slice = current_slice
    was_talk_active = talk_active
end

local prev_screen = nil

-- TODO: what to do with this?
local function process_screen_change()
    local current_screen = get_screen_message()

    if current_screen ~= nil then
        if current_screen ~= prev_screen and current_screen ~= nil then
            output(current_screen)
        end

        prev_screen = current_screen
    end
end

local prev_target_addr = nil

local function process_target_change()
    local current_target_addr = target_select.GetCurrentTargetAddr()

    if menu_toggle then
        if current_target_addr ~= prev_target_addr and current_target_addr ~= nil then
            local targetted_unit = target_select.Target:new(current_target_addr):unit()

            if targetted_unit ~= nil then
                output("Targetting " .. nicer_unit(targetted_unit))
            end
        end
    end

    prev_target_addr = current_target_addr
end

local function main_loop()
    handle_user_input()

    -- TODO: those should only be called when on the corresponding screen

    process_coordinate_changes()
    process_menu_items()
    process_target_change()
    process_follow_dialogue()
end

text.monitor:init()

output("Ready")

while true do
    emu.frameadvance()
    main_loop()
end
