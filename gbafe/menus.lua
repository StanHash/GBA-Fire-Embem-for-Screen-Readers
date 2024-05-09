-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

local addrs = require 'gbafe.addresses'
local procs = require 'gbafe.procs'
local text = require 'gbafe.text'

local bit = require 'bit'

local menus = {}

--- @param menu_proc integer
--- @return boolean
local function is_this_menu_active(menu_proc)
    if not procs.IsThisProcActive(menu_proc) then
        return false
    end

    -- check that menu isn'the frozen
    local flags = memory.readbyte(menu_proc + 0x63)
    return bit.band(0x40, flags) == 0
end

local function get_current_menu()
    local menu_procs = procs.ListProcs(addrs.MenuProc)

    for _, menu_proc in ipairs(menu_procs) do
        if is_this_menu_active(menu_proc) then
            return menu_proc
        end
    end

    return nil
end

function menus.IsMenuActive()
    return get_current_menu() ~= nil
end

--- @param menu_proc integer
local function get_current_menu_item_for_menu(menu_proc)
    local current_item_id = memory.readbyte(menu_proc + 0x61)
    local menu_item_proc_addr = memory.readlong(menu_proc + 0x34 + 4 * current_item_id)

    local menu_item_str = text.monitor:get_text_string(menu_item_proc_addr + 0x34)

    --[[
    if menu_item_str == nil then
        local menu_item_info_addr = memory.readlong(menu_item_proc_addr + 0x30)
        local menu_item_msg = memory.readshort(menu_item_info_addr + 0x04)

        if menu_item_msg ~= 0 then
            menu_item_str = strings.GetString(menu_item_msg)
        end
    end
    ]]

    return menu_item_str
end

function menus.GetCurrentMenuItemName()
    local menu_proc = get_current_menu()

    if menu_proc ~= nil then
        return get_current_menu_item_for_menu(menu_proc)
    end

    return "There is no menu"
end

return menus
