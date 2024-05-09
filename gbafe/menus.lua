-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

local addrs = require 'gbafe.addresses'
local procs = require 'gbafe.procs'
local strings = require 'gbafe.strings'

local bit = require 'bit'

local menus = {}

function menus.IsMenuActive()
    return procs.IsProcRunning(addrs.MenuProc)
end

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

--- @param menu_proc integer
local function get_current_menu_item_for_menu(menu_proc)
    local current_item_id = memory.readbyte(menu_proc + 0x61)
    local menu_item_proc_addr = memory.readlong(menu_proc + 0x34 + 4 * current_item_id)
    local menu_item_info_addr = memory.readlong(menu_item_proc_addr + 0x30)
    local menu_item_msg = memory.readshort(menu_item_info_addr + 0x04)

    if menu_item_msg ~= 0 then
        local menu_item_str = strings.GetString(menu_item_msg)
        return menu_item_str
    else
        return "Unknown menu item"
    end
end

function menus.GetCurrentMenuItemName()
    local menu_procs = procs.ListProcs(addrs.MenuProc)

    for _, menu_proc in ipairs(menu_procs) do
        if is_this_menu_active(menu_proc) then
            return get_current_menu_item_for_menu(menu_proc)
        end
    end

    return "There is no menu"
end

return menus
