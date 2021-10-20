local ngx = ngx
local uri = ngx.var.uri

local api = {'check', 'ranking', 'data'}

-- Path Limit
local str, err = ngx.re.match(uri, "^/v1/api/(" .. table.concat(api, '|') .. ')')
if str then
    return
else
    ngx.exit(ngx.HTTP_FORBIDDEN)
end
