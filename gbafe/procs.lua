-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

-- get access to procs

local addrs = require 'gbafe.addresses'

local procs = {}

---@param func fun(proc_addr: integer, proc_script_addr: integer)
local function iter_procs(func)
    for i = 0, 0x3F do
        local proc_addr = addrs.ProcArray + i * 0x6C
        local proc_script_addr = memory.readlong(proc_addr + 0x00)

        if proc_script_addr ~= 0 then
            func(proc_addr, proc_script_addr)
        end
    end
end

--- List all procs running the given script
--- @param proc_script_addr integer
--- @return integer[]
function procs.ListProcs(proc_script_addr)
    local result = {}

    iter_procs(function(proc_addr, this_proc_script_addr)
        if this_proc_script_addr == proc_script_addr then
            result[#result + 1] = proc_addr
        end
    end)

    return result
end

--- Get one proc running the given script. If multiple exist, get the first one.
--- @param proc_script_addr integer
--- @return integer|nil
function procs.FindProc(proc_script_addr)
    local list = procs.ListProcs(proc_script_addr)

    if #list > 0 then
        return list[1]
    else
        return nil
    end
end

function procs.IsThisProcActive(proc_addr)
    local lock_counter = memory.readbyte(proc_addr + 0x28)
    return lock_counter == 0
end

function procs.IsProcRunning(proc_script_addr)
    return procs.FindProc(proc_script_addr) ~= nil
end

return procs
