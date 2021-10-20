local config = require "config"
local expire = config.expire

if ngx.ctx.cached then
    return
end

if ngx.ctx.cachable then
    local cache = ngx.shared.check_cache
    cache:set(ngx.ctx.cache_key, ngx.ctx.res, expire)
end
