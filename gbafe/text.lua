-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

-- Monitor drawn text and allows getting what a particular text object would display.
-- This is kind of a mess currently and could be simplified

local helpers = require 'helpers'

local addrs = require 'gbafe.addresses'
local strings = require 'gbafe.strings'

local text = {}

local function get_current_font()
    local font_addr = memory.readlong(addrs.ActiveFont)
    return font_addr
end

--- @class Monitor
--- @field ready boolean
--- @field font_info_table table<integer, integer[]>
--- @field text_info_table table<integer, table>
local Monitor = {}
Monitor.__index = Monitor

function Monitor:new()
    local result = setmetatable({
        ready = false,
        font_info_table = {},
        text_info_table = {},
    }, self)

    result:clear()

    return result
end

function Monitor:get_font_table(font_addr)
    local font_table = self.font_info_table[font_addr]

    if font_table == nil then
        font_table = {}
        self.font_info_table[font_addr] = font_table
    end

    return font_table
end

function Monitor:get_text_table(text_addr)
    local text_table = self.text_info_table[text_addr]

    if text_table == nil then
        local font_addr = get_current_font()
        local font_table = self:get_font_table(font_addr)
        table.insert(font_table, text_addr)

        text_table = { strings = {} }
        self.text_info_table[text_addr] = text_table
    end

    return text_table
end

function Monitor:reset_font(font_addr)
    local font_texts = self:get_font_table(font_addr)

    for _, text_addr in ipairs(font_texts) do
        self.text_info_table[text_addr] = nil
    end

    helpers.clear_table(font_texts)
end

function Monitor:on_font_init()
    local font_addr = memory.getregister("r0")

    if font_addr == 0 then
        font_addr = addrs.DefaultFont
    end

    self:reset_font(font_addr)
end

function Monitor:on_font_reset()
    local font_addr = get_current_font()
    self:reset_font(font_addr)
end

function Monitor:on_init_text()
    local text_addr = memory.getregister("r0")
    self:get_text_table(text_addr).strings = {}
end

function Monitor:on_clear_text()
    -- same logic
    self:on_init_text()
end

function Monitor:on_draw_string()
    local text_addr = memory.getregister("r0")
    local string_addr = memory.getregister("r1")

    local text_cursor = memory.readbyte(text_addr + 0x02)
    local string_value = strings.DecodeRawString(string_addr)

    self:get_text_table(text_addr).strings[text_cursor] = string_value
end

--- @param text_info table
--- @return string|nil
local function raw_get_text_string(text_info)
    local xs = helpers.sorted_keys(text_info.strings)

    if #xs > 0 then
        local result = text_info.strings[xs[1]]

        for i = 2, #xs do
            local next_text_bit = text_info.strings[xs[i]]

            -- heuristic "glued" characters
            if #next_text_bit < 2 and xs[i] < xs[i - 1] + 16 then
                result = result .. next_text_bit
            else
                result = result .. " " .. next_text_bit
            end
        end

        return result
    end

    return nil
end

function Monitor:get_text_string(text_addr)
    return raw_get_text_string(self:get_text_table(text_addr))
end

function Monitor:is_ready() return self.ready == true end

function Monitor:init()
    memory.registerexec(addrs.InitTextFont, function() self:on_font_init() end)
    memory.registerexec(addrs.InitText, function() self:on_init_text() end)
    memory.registerexec(addrs.ResetTextFont, function() self:on_font_reset() end)
    memory.registerexec(addrs.ClearText, function() self:on_clear_text() end)
    memory.registerexec(addrs.Text_DrawString, function() self:on_draw_string() end)

    self.ready = true
end

function Monitor:clear()
    self.ready = false

    memory.registerexec(addrs.InitTextFont, nil)
    memory.registerexec(addrs.InitText, nil)
    memory.registerexec(addrs.ResetTextFont, nil)
    memory.registerexec(addrs.ClearText, nil)
    memory.registerexec(addrs.Text_DrawString, nil)
end

text.monitor = Monitor:new()

vba.registerexit(function()
    text.monitor:clear()
end)

return text
