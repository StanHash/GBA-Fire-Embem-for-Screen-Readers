-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

local addrs = require 'gbafe.addresses'
local strings = require 'gbafe.strings'

local bit = require 'bit'

local items = {}

function items.GetIid(item)
    return bit.band(0xFF, item)
end

function items.GetItemUses(item)
    return bit.band(0xFF, bit.rshift(item, 8))
end

function items.GetItemMaxUses(item)
    local iinfo_addr = addrs.IInfoTable + items.GetIid(item) * 0x24
    return memory.readbyte(iinfo_addr + 0x14)
end

function items.GetItemName(item)
    local iinfo_addr = addrs.IInfoTable + items.GetIid(item) * 0x24
    local item_msg = memory.readshort(iinfo_addr + 0x00)
    return strings.GetString(item_msg)
end

return items
