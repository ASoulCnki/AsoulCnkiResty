local json = require "cjson"
local args = require "hooks.useArgs"
local config = require "config"

local config_data_key = config.api.data.secure_key

local function is_valid()
    local vaild_route = {'pull', 'train', 'reset'}

    local uri = ngx.var.uri
    local method = ngx.req.get_method()

    local str, err = ngx.re.match(uri, "^/v1/api/data/(" .. table.concat(vaild_route, "|") .. ")")
    return method == "POST" and str
end

local function has_params()
    local raw_body = args.post_data()
    local data, err = json.decode(raw_body)

    if data then
        return data and data.secure_key and data.secure_key == config_data_key
    else
        return false
    end
end

if not (is_valid() and has_params()) then
    ngx.exit(ngx.HTTP_NOT_FOUND)
end
