-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

-- collection of helpers for lua scripts

local helpers = {}

--- Clears any table of its contents, without breaking existing references. Returns input for convenience.
--- @param tab table
--- @return table
function helpers.clear_table(tab)
    for key in next, tab do
        rawset(tab, key, nil)
    end

    return tab
end

--- Gets keys in ascending order
--- @generic T
--- @param tab table<integer, T>
--- @return integer[]
function helpers.sorted_keys(tab)
    local keys = {}

    for x in pairs(tab) do
        table.insert(keys, x)
    end

    table.sort(keys)

    return keys
end

--- Like pairs but in ascending key order
--- @generic T
--- @param tab table<integer, T>
--- @return fun(): (integer, T)|nil
function helpers.sorted_pairs(tab)
    local keys = helpers.sorted_keys(tab)
    local idx = 1

    local my_next = function()
        local key = keys[idx]
        idx = idx + 1

        if key ~= nil then
            return key, tab[key]
        end

        return nil
    end

    return my_next
end

-- join list of strings with sep
function helpers.join(sep, string_list)
    if #string_list > 0 then
        local message = string_list[1]

        for i = 2, #string_list do
            message = message .. sep .. string_list[i]
        end

        return message
    else
        return nil
    end
end

return helpers
