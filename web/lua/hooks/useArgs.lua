local ngx = require("ngx")

local _M = {}

function _M.get_args()
    return ngx.req.get_uri_args()
end

function _M.post_args()
    ngx.req.read_body()
    ngx.req.get_post_args()
end

return _M
