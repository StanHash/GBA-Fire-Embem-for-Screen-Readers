-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

-- wrapper and helpers for interacting with GBAFE Units
-- TODO: handle FE6 vs. non-FE6 (struct layout changes slightly)

local strings = require 'gbafe.strings'

local bit = require 'bit'

local Unit = {}
Unit.__index = Unit

function Unit:new(unit_addr)
    local result = { unit_addr = unit_addr }
    return setmetatable(result, self)
end

function Unit:pid_name_msg()
    local pinfo_addr = memory.readlong(self.unit_addr + 0x00)
    return memory.readshort(pinfo_addr + 0x00)
end

function Unit:pid_name()
    local msg = self:pid_name_msg()
    return strings.GetString(msg)
end

function Unit:jid_name_msg()
    local jinfo_addr = memory.readlong(self.unit_addr + 0x04)
    return memory.readshort(jinfo_addr + 0x00)
end

function Unit:jid_name()
    local msg = self:jid_name_msg()
    return strings.GetString(msg)
end

function Unit:unit_id()
    return memory.readbyte(self.unit_addr + 0x0B)
end

function Unit:max_hp()
    -- NOTE: FE6 would be +0x10
    return memory.readbyte(self.unit_addr + 0x12)
end

function Unit:current_hp()
    -- NOTE: FE6 would be +0x11
    return memory.readbyte(self.unit_addr + 0x13)
end

function Unit:get_item(slot)
    -- NOTE: FE6 would be different
    return memory.readshort(self.unit_addr + 0x1E + 2 * slot)
end

function Unit:get_item_count()
    for i = 0, 4 do
        if self:get_item(i) == 0 then
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
