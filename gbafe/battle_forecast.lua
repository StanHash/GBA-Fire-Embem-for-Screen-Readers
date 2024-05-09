-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

local addrs = require 'gbafe.addresses'
local procs = require 'gbafe.procs'
local text = require 'gbafe.text'

local battle_forecast = {}

local function get_bksel_proc()
    return procs.FindProc(addrs.BattleForeecastProc)
end

local function for_bksel_proc(func)
    local proc_addr = get_bksel_proc()

    if proc_addr ~= nil then
        return func(proc_addr)
    else
        return nil
    end
end

function battle_forecast.IsActive()
    return get_bksel_proc() ~= nil
end

function battle_forecast.GetHitCountA()
    return for_bksel_proc(function(proc_addr)
        return memory.readbyte(proc_addr + 0x50)
    end)
end

function battle_forecast.GetHitCountB()
    return for_bksel_proc(function(proc_addr)
        return memory.readbyte(proc_addr + 0x51)
    end)
end

function battle_forecast.IsEffectiveA()
    return for_bksel_proc(function(proc_addr)
        return memory.readbyte(proc_addr + 0x52)
    end)
end

function battle_forecast.IsEffectiveB()
    return for_bksel_proc(function(proc_addr)
        return memory.readbyte(proc_addr + 0x53)
    end)
end

function battle_forecast.GetItemNameB()
    return for_bksel_proc(function(proc_addr)
        return text.monitor:get_text_string(proc_addr + 0x48)
    end)
end

return battle_forecast
