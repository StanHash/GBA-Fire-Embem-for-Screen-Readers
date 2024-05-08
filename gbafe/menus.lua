-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

local procs = require 'gbafe.procs'
local strings = require 'gbafe.strings'

local menus = {}

-- TODO: move addresses elsewhere
local addr_MenuProc = 0x085B64D0

function menus.IsMenuActive()
    return procs.IsProcRunning(addr_MenuProc)
end

function menus.GetCurrentMenuItemName()
    local menu_proc = procs.FindProc(addr_MenuProc)

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
