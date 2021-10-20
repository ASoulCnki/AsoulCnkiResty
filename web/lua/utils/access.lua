local ngx = require "ngx"
local uri = ngx.var.uri

local api = {'check', 'ranking', 'data', 'flush'}

-- Path Limit
local str, err = ngx.re.match(uri, "^/v1/api/(" .. table.concat(api, '|') .. ')$')
if not str[1] then
    ngx.exit(ngx.HTTP_FORBIDDEN)
end
