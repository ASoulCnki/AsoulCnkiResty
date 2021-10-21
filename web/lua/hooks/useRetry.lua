local _M = {}

function _M.retry(fn, max_retries, fail_callback)
    if type(fn) ~= 'function' or type(fail_callback) ~= 'function' then
        error('TypeError: fn should be function')
    end
    local count, r = 0, nil
    while count < max_retries and r == nil do
        r = fn()
        count = count + 1
    end

    if r == nil then
        fail_callback()
    end

    return r
end

return _M
