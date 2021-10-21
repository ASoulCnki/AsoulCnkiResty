local ngx = require("ngx")

local _M = {}

-- Method: GET, get uri args
function _M.get_args()
    return ngx.req.get_uri_args()
end

-- Method: POST, get post args
function _M.post_args()
    ngx.req.read_body()
    return ngx.req.get_post_args()
end

-- Method: POST, get post body
function _M.post_data()
    ngx.req.read_body()
    return ngx.req.get_body_data()
end

return _M
