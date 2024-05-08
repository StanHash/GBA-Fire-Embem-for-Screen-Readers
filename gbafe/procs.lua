-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

-- get access to procs

local addr_ProcArray = 0x02024E68
local addr_ProcTrees = 0x02026A70

local procs = {}

local function iter_procs(func)
    for i = 0, 0x3F do
        local proc_addr = addr_ProcArray + i * 0x6C
        local proc_script_addr = memory.readlong(proc_addr + 0x00)

        if proc_script_addr ~= 0 then
            func(proc_addr, proc_script_addr)
        end
    end
end

function procs.IsProcRunning(proc_script_addr)
    local found = false

    iter_procs(function(proc_addr, this_proc_script_addr)
        if this_proc_script_addr == proc_script_addr then
            found = true
        end
    end)

    return found
end

return procs
