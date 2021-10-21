local ngx = require 'ngx'
local config = require "config"

local secret = config.api.flush.secret

local ranking_cache = ngx.shared.ranking_cache
local check_cache = ngx.shared.check_cache

local key = ngx.req.get_uri_args()

if key.secret and key.secret == secret then
    ranking_cache:flush_all()
    check_cache:flush_all()
    ngx.say('OK')
    ngx.eof()
    ngx.log(ngx.ERR, "[cache] Flushed")
else
    ngx.exit(ngx.HTTP_NOT_FOUND)
end
