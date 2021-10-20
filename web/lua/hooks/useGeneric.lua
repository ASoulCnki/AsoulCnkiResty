local _M = {}

function _M.pick(table, keys)
    local res_table = {}
    for _, key in pairs(keys) do
        res_table[key] = table[key]
    end
    return res_table
end

function _M.omit(res_table, keys)
    for _, key in pairs(keys) do
        res_table[key] = nil
    end
    return res_table
end

return _M
