-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

local addrs = require 'gbafe.addresses'

local Unit = require 'gbafe.Unit'
local Item = require 'gbafe.Item'

-- Inheritance in lua is a bit magical
-- Here, BattleUnit is "just" an instance of Unit
-- however, any call to BattleUnit:new will generate a Unit-like object whose metatable is BattleUnit

--- @class BattleUnit: Unit
local BattleUnit = Unit:new(0)
BattleUnit.__index = BattleUnit

--- @return BattleUnit
function BattleUnit:new_a()
    --- @diagnostic disable: return-type-mismatch
    return self:new(addrs.BattleUnitA)
end

--- @return BattleUnit
function BattleUnit:new_b()
    --- @diagnostic disable: return-type-mismatch
    return self:new(addrs.BattleUnitB)
end

function BattleUnit:weapon_before()
    local weapon_before_raw = memory.readshort(self.unit_addr + 0x4A)

    if weapon_before_raw == 0 then
        return nil
    else
        return Item:new(weapon_before_raw)
    end
end

function BattleUnit:battle_attack()
    local battle_attack = memory.readshort(self.unit_addr + 0x5A)
    return battle_attack
end

function BattleUnit:battle_defense()
    local battle_defense = memory.readshort(self.unit_addr + 0x5C)
    return battle_defense
end

function BattleUnit:battle_hit_final()
    local battle_hit_final = memory.readshort(self.unit_addr + 0x64)
    return battle_hit_final
end

function BattleUnit:battle_crit_final()
    local battle_crit_final = memory.readshort(self.unit_addr + 0x6A)
    return battle_crit_final
end

function BattleUnit:hp_before()
    local hp_before = memory.readbyte(self.unit_addr + 0x72)
    return hp_before
end

return BattleUnit
