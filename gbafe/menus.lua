-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

local addrs = require 'gbafe.addresses'
local procs = require 'gbafe.procs'
local strings = require 'gbafe.strings'

local menus = {}

function menus.IsMenuActive()
    return procs.IsProcRunning(addrs.MenuProc)
end

function menus.GetCurrentMenuItemName()
    local menu_proc = procs.FindProc(addrs.MenuProc)

    if not menu_proc or menu_proc == 0 then
        return "There is no menu"
    end

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

return menus
