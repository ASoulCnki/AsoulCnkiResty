local json = require "cjson"
local ngx = require 'ngx'
local args = require "hooks.useArgs"
local config = require "config"
local utf8 = require "lua-utf8"

local config_data_key_len = config.api.data.secure_key_len

local function is_valid()
    local vaild_route = {'pull', 'train', 'reset'}

    local uri = ngx.var.uri
    local method = ngx.req.get_method()

    local str, err = ngx.re.match(uri, "^/v1/api/data/(" .. table.concat(vaild_route, "|") .. ")")
    if err then
        return false
    end
    return method == "POST" and str
end

local function has_params()
    local raw_body = args.post_data()
    local data, _ = json.decode(raw_body)

    if data then
        return data and data.secure_key and utf8.len(data.secure_key) >= config_data_key_len
    else
        return false
    end
end

if not (is_valid() and has_params()) then
    ngx.exit(ngx.HTTP_NOT_FOUND)
end
