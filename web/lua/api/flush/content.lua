local ngx = require 'ngx'

local ranking_cache = ngx.shared.ranking_cache
local check_cache = ngx.shared.check_cache

local key = ngx.req.get_uri_args()

if key.secret and key.secret == "114514" then
    ranking_cache:flush_all()
    check_cache:flush_all()
    ngx.say('OK')
    ngx.exit(ngx.HTTP_OK)
end
ngx.exit(ngx.HTTP_NOT_FOUND)
