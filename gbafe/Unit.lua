-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

-- wrapper and helpers for interacting with GBAFE Units
-- TODO: handle FE6 vs. non-FE6 (struct layout changes slightly)

local addrs = require 'gbafe.addresses'
local strings = require 'gbafe.strings'

local Item = require 'gbafe.Item'

local bit = require 'bit'

--- @class Unit
--- @field unit_addr integer
local Unit = {}
Unit.__index = Unit

--- Create a unit from its address
--- @param unit_addr integer address of unit object
--- @return Unit
function Unit:new(unit_addr)
    return setmetatable({ unit_addr = unit_addr }, self)
end

--- Create a unit from its internal ID
--- @param unit_id integer
--- @return Unit|nil
function Unit:from_id(unit_id)
    local unit_addr = memory.readlong(addrs.UnitLookup + unit_id * 4)

    if unit_addr ~= 0 then
        return Unit:new(unit_addr)
    else
        return nil
    end
end

--- Get the units PID name message id (character name id)
--- @return integer
function Unit:pid_name_msg()
    local pinfo_addr = memory.readlong(self.unit_addr + 0x00)
    return memory.readshort(pinfo_addr + 0x00)
end

--- Get the units PID name (character name)
--- @return string
function Unit:pid_name()
    local msg = self:pid_name_msg()
    return strings.GetString(msg)
end

--- Get the units JID name message id (class name id)
--- @return integer
function Unit:jid_name_msg()
    local jinfo_addr = memory.readlong(self.unit_addr + 0x04)
    return memory.readshort(jinfo_addr + 0x00)
end

--- @return string
function Unit:jid_name()
    local msg = self:jid_name_msg()
    return strings.GetString(msg)
end

--- @return integer
function Unit:unit_id()
    return memory.readbyte(self.unit_addr + 0x0B)
end

--- @return integer
function Unit:max_hp()
    -- NOTE: FE6 would be +0x10
    return memory.readbyte(self.unit_addr + 0x12)
end

--- @return integer
function Unit:current_hp()
    -- NOTE: FE6 would be +0x11
    return memory.readbyte(self.unit_addr + 0x13)
end

--- @return integer
function Unit:get_item_raw(slot)
    -- NOTE: FE6 would be different
    return memory.readshort(self.unit_addr + 0x1E + 2 * slot)
end

--- @return Item
function Unit:get_item(slot)
    local raw_item = self:get_item_raw(slot)

    if raw_item ~= 0 then
        return Item:new(raw_item)
    else
        return nil
    end
end

function Unit:get_item_count()
    for i = 0, 4 do
        if self:get_item_raw(i) == 0 then
            return i
        end
    end

    return 5
end

function Unit:flags()
    -- NOTE: FE6 would be readshort
    return memory.readlong(self.unit_addr + 0x0C)
end

function Unit:is_active()
    return bit.band(self:flags(), 0x0001) ~= 0
end

function Unit:is_boss()
    local pinfo_addr = memory.readlong(self.unit_addr + 0x00)
    local jinfo_addr = memory.readlong(self.unit_addr + 0x04)

    local pinfo_attributes = memory.readlong(pinfo_addr + 0x28)
    local jinfo_attributes = memory.readlong(jinfo_addr + 0x28)

    local attributes = bit.bor(pinfo_attributes, jinfo_attributes)
    local boss_flag = bit.band(attributes, 0x00008000)

    return boss_flag ~= 0
end

return Unit
