local generic = require "lua.hooks.useGeneric"
local args = require "hooks.useArgs"
local requests = require "resty.requests"
local url = require "net.url"
local error = require "hooks.useError"
local retry = require "hooks.useRetry"
local config = require "config"

local config_base_url = config.requests.base_url
local expire = config.expire
local empty_data = error.empty_data

local function req(params)
    local opts = {
        headers = {
            ['user-agent'] = "asoulcnki-resty",
            timeouts = {16000, 16000, 16000}
        }
    }

    local u = url.parse(config_base_url .. "/ranking/")
    u:setQuery(params)

    return function()
        local r, err = requests.get(u, opts)
        if r then
            ngx.ctx.cachable = true
            return r:body()
        end
        return nil
    end
end

local cache = ngx.shared.ranking_cache

local require_key = {'sortMode', 'timeRangeMode', 'pageSize', 'pageNum', 'ids', 'keys'}

local params = args.get_args()
local keys = generic.pick(params, require_key)

-- Limits:
-- sortMode >= 0
-- timeRangeMode >= 0
-- pageNum >= 1
-- 10 <= pageSize <= 20

local t = function(s)
    pcall(function(s)
        data = tonumber(s)
    end, s)
    return data or -1
end

local condi =
    (keys and keys.sortMode and t(keys.sortMode) >= 0 and keys.timeRangeMode and t(keys.timeRangeMode) >= 0 and
        keys.pageSize and t(keys.pageSize) >= 10 and t(keys.pageSize) <= 20 and keys.pageNum and t(keys.pageNum) > 0)

if condi and (#(keys.ids or '') > 100 or #(keys.keys or '') > 100) then
    condi = false
end

if not (keys and condi) then
    -- return error
    error.lint()
end

if not cache then
    return
end

local cache_table = {keys.sortMode, keys.timeRangeMode, keys.pageSize, keys.pageNum, keys.ids or 0, keys.keys or 0}

local cache_key = table.concat(cache_table, '-')

local data, err = cache:get(cache_key)

if data then
    ngx.say(data)
    ngx.eof()

    ngx.ctx.cached = true
else
    if err then
        ngx.log(ngx.ERR, err)
    end
    ngx.ctx.cached = false
    ngx.ctx.cache_key = cache_key
    ngx.ctx.res = retry.retry(req(keys), 3, empty_data)
end

ngx.say(ngx.ctx.res)
ngx.eof()

if ngx.ctx.cache_key then
    cache:set(ngx.ctx.cache_key, ngx.ctx.res, expire)
    ngx.log(ngx.ERR, '[cache] new check cache, ID: ', ngx.ctx.cache_key)
end
