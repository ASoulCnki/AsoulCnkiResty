local ngx = require('ngx')

local _M = {}

function _M.get_client_info()
    local data = {
        ip = ngx.var.remote_addr,
        user_agent = ngx.var.get_headers()['user-agent'] or '',
        uri = ngx.var.uri
    }
    return data
end

return _M
