local json = require "cjson"

local function is_valid()
    local vaild_route = {'pull', 'train', 'reset'}

    local uri = ngx.var.uri
    local method = ngx.req.get_method()

    local str, err = ngx.re.match(uri, "^/v1/api/data/(" .. table.concat(vaild_route, "|") .. ")")
    return method == "POST" and str
end

local function has_params()
    ngx.req.read_body()
    local raw_body = ngx.req.get_body_data()
    local data
    pcall(function(s)
        data = json.decode(s)
    end, raw_body)
    return data and data.secure_key and #data.secure_key > 10
end

if not (is_valid() and has_params()) then
    ngx.exit(ngx.HTTP_NOT_FOUND)
end
