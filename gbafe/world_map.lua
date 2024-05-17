-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

local helpers = require 'helpers'

local addrs = require 'gbafe.addresses'
local procs = require 'gbafe.procs'
local text = require 'gbafe.text'

local world_map = {}

function world_map.IsActive()
    return procs.IsProcRunning(addrs.WMMainProc)
end

function world_map.IsPlayerInterfaceActive()
    return procs.IsProcRunning(addrs.WMPlayerInterfaceProc)
end

function world_map.GetCurrentWMNodeName()
    local pi_proc_addr = procs.FindProc(addrs.WMPlayerInterfaceProc)

    if pi_proc_addr ~= nil then
        local pi_text_addr = pi_proc_addr + 0x2C

        local first_line = text.monitor:get_text_string(pi_text_addr)

        if first_line == nil then
            return nil
        end

        local pid = memory.readbyte(pi_proc_addr + 0x5F)
        local jid = memory.readbyte(pi_proc_addr + 0x60)

        if pid ~= 0 or jid ~= 0 then
            local second_line = text.monitor:get_text_string(pi_text_addr + 8)
            return ("%s, %s"):format(first_line, second_line)
        else
            return first_line
        end
    end

    return nil
end

return world_map
