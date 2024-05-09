-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

local addrs = require 'gbafe.addresses'
local strings = require 'gbafe.strings'

local bit = require 'bit'

--- @class Item
--- @field value integer
local Item = {}
Item.__index = Item

--- @param value integer
--- @return Item
function Item:new(value)
    local result = { value = value }
    return setmetatable(result, self)
end

--- @return integer
function Item:iid()
    return bit.band(0xFF, self.value)
end

--- @return integer
function Item:iinfo_addr()
    return addrs.IInfoTable + self:iid() * 0x24
end

--- @return integer
function Item:uses()
    return bit.band(0xFF, bit.rshift(self.value, 8))
end

--- @return integer
function Item:max_uses()
    return memory.readbyte(self:iinfo_addr() + 0x14)
end

--- @return string
function Item:name()
    local item_msg = memory.readshort(self:iinfo_addr() + 0x00)
    return strings.GetString(item_msg)
end

return Item
