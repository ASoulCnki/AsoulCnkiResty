local generic = require "lua.hooks.useGeneric"
local args = require "lua.hooks.useArgs"
local requests = require "resty.requests"
local url = require "net.url"
local error = require "hooks.useError"

local function req(params)
    local u = url.parse("https://asoulcnki.asia/v1/api/ranking/")
    u:setQuery(params)
    local r, err = requests.get(u, {
        headers = {
            ['user-agent'] = "asoulcnki-resty",
            timeouts = {16000}
        }
    })

    if not r then
        error.empty_data()
    end

    ngx.ctx.cachable = true
    return r:body()
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
local condi = (keys and keys.sortMode and tonumber(keys.sortMode) >= 0 and keys.timeRangeMode and
                  tonumber(keys.timeRangeMode) >= 0 and keys.pageSize and tonumber(keys.pageSize) >= 10 and
                  tonumber(keys.pageSize) <= 20 and keys.pageNum and tonumber(keys.pageNum) > 0)

if condi and (#(keys.ids or '') > 100 or #(keys.keys or '') > 100) then
    condi = false
end

if not (keys and condi) then
    -- return error
    ngx.exit(ngx.HTTP_NOT_FOUND)
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
    ngx.ctx.res = req(keys)
end

ngx.say(ngx.ctx.res)
ngx.eof()
