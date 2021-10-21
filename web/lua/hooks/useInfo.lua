local ngx = require('ngx')

local _M = {}

function _M.get_client_info()
    local headers = ngx.req.get_headers()

    local data = {
        ip = headers['ali-cdn-real-ip'] or ngx.var.remote_addr,
        user_agent = headers['user-agent'] or '',
        uri = ngx.var.uri
    }
    return data
end

return _M
