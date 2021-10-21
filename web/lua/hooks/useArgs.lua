local ngx = require("ngx")

local _M = {}

function _M.get_args()
    return ngx.req.get_uri_args()
end

function _M.post_args()
    ngx.req.read_body()
    return ngx.req.get_post_args()
end

function _M.post_data()
    ngx.req.read_body()
    return ngx.req.get_body_data()
end

return _M
