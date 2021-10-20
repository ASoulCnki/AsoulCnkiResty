local _M = {}

function _M.empty_data()
    ngx.say('{"code":500, "message":"Interval Server Error", "data":[]}')
    ngx.exit(ngx.HTTP_OK)
end

return _M
