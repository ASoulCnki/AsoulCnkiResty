local generic = require "lua.hooks.useGeneric"
local args = require "lua.hooks.useArgs"
local http = require "resty.http"
local json = require "cjson"
local httpc = http.new()

local function requests(params)
    -- Bug: requests(): network is unreachable

    local res, err = httpc:request_uri("https://asoulcnki.asia/v1/api/ranking/", {
        method = "GET",
        query = params,
        ssl_verify = false
    })
    if res then
        return res:read_body()
    else
        if err then
            ngx.log(ngx.ERR, err)
        end
        return '{"code":500, "message":"Interval Server Error", "data":[]}'
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
    ngx.ctx.res = requests(keys)
end

ngx.say(ngx.ctx.res or 'nil')
ngx.eof()
