-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

-- get access to procs

local procs = {}

-- TODO: move elsewhere
local addr_ProcArray = 0x02024E68
local addr_ProcTrees = 0x02026A70

local function iter_procs(func)
    for i = 0, 0x3F do
        local proc_addr = addr_ProcArray + i * 0x6C
        local proc_script_addr = memory.readlong(proc_addr + 0x00)

        if proc_script_addr ~= 0 then
            func(proc_addr, proc_script_addr)
        end
    end
end

function procs.FindProc(proc_script_addr)
    local addr = nil

    iter_procs(function(proc_addr, this_proc_script_addr)
        if this_proc_script_addr == proc_script_addr then
            addr = proc_addr
        end
    end)

    return addr
end

function procs.IsProcRunning(proc_script_addr)
    return procs.FindProc(proc_script_addr) ~= nil
end

return procs
