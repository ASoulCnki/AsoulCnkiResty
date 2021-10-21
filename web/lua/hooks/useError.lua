local json = require "cjson"
local info = require "hooks.useInfo"

local _M = {}

-- return empty data when upstream unreachable
function _M.empty_data()
    ngx.say('{"code":500, "message":"Interval Server Error", "data":[]}')
    ngx.exit(ngx.HTTP_OK)
end

-- return hint when api call wrong way
function _M.lint(message)
    local data = {
        info = info.get_client_info(),
        code = -412,
        message = message or "Error: Call API in Wrong Way",
        hint = {
            info = "Read API Doc on GitHub",
            url = [[https://github.com/ASoulCnki/.github/tree/master/api]]
        },
        data = ngx.null
    }
    ngx.say(json.encode(data))
    ngx.exit(ngx.HTTP_OK)
end

return _M
