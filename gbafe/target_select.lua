-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

local addrs = require 'gbafe.addresses'
local procs = require 'gbafe.procs'

local Unit = require 'gbafe.Unit'

local target_select = {}

local function get_target_select_proc()
    return procs.FindProc(addrs.TargetSelectProc)
end

function target_select.IsActive()
    return get_target_select_proc() ~= nil
end

--- @class Target
--- @field private target_addr integer
target_select.Target = {}
target_select.Target.__index = target_select.Target

function target_select.Target:new(target_addr)
    return setmetatable({ target_addr = target_addr }, self)
end

function target_select.Target:position()
    local x = memory.readbyte(self.target_addr + 0x00)
    local y = memory.readbyte(self.target_addr + 0x01)

    return x, y
end

function target_select.Target:unit_id()
    local unit_id = memory.readbyte(self.target_addr + 0x02)
    return unit_id
end

function target_select.Target:unit()
    return Unit:from_id(self:unit_id())
end

function target_select.Target:extra_value()
    local extra_value = memory.readbyte(self.target_addr + 0x03)
    return extra_value
end

--- @return integer|nil
function target_select.GetCurrentTargetAddr()
    local proc_addr = get_target_select_proc()

    if proc_addr ~= nil then
        local target_addr = memory.readlong(proc_addr + 0x30)
        return target_addr
    end

    return nil
end

return target_select
