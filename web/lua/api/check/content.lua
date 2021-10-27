local ngx = require 'ngx'
local json = require "cjson"
local args = require "hooks.useArgs"
local request = require "resty.requests"
local config = require "config"
local utf8 = require "lua-utf8"
local error = require "hooks.useError"
local retry = require "hooks.useRetry"

local expire = config.cache.expire
local config_check = config.api.check
local config_base_url = config.requests.base_url
local error_lint = error.lint
local error_empty = error.empty_data

local function is_valid_method()
    local method = ngx.req.get_method()
    return method == "POST"
end

local function req(body)
    local opts = {
        body = body,
        headers = {
            ["content-type"] = "application/json",
            ["user-agent"] = "asoulcnki-resty"
        },
        timeouts = {16000, 16000, 16000}
    }

    local api_check = config_base_url .. '/check'

    return function()
        local res, _ = request.post(api_check, opts)

        if res then
            ngx.ctx.cachable = true
            return res:body()
        end
        return nil
    end
end

if not is_valid_method() then
    error_lint("Error: Method should be POST")
end

local body_data = args.post_data()

local data, _ = json.decode(body_data)
if not data then
    error_lint("Error: Post data should be JSON")
end

if (data and data.text) then
    if type(data.text) ~= 'string' then
        error_lint("Error: Text should be string")
    end

    local len = utf8.len(data.text)
    if len < config_check.min_length or len > config_check.max_length then
        error_lint("Error: Text too long or too short")
    end
else
    error_lint("Error: Data should has `text` property")
end

local cache = ngx.shared.check_cache;

if not cache then
    return
end

local cache_key = ngx.md5(data.text)

local cache_data, err = cache:get(cache_key)

if cache_data then
    ngx.say(cache_data)
    ngx.exit(ngx.HTTP_OK)
else
    if err then
        ngx.log(ngx.ERR, err)
    end
    ngx.ctx.res = retry.retry(req(body_data), 3, error_empty)
    ngx.ctx.cache_key = cache_key
end

ngx.say(ngx.ctx.res)
ngx.eof()

if ngx.ctx.cache_key then
    cache:set(ngx.ctx.cache_key, ngx.ctx.res, expire)
    ngx.log(ngx.ERR, '[cache] new check cache, ID: ', ngx.ctx.cache_key)
end
