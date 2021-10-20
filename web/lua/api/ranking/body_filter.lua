if ngx.ctx.cached then
    return
end

local cache = ngx.shared.ranking_cache

cache:set(ngx.ctx.cache_key, ngx.ctx.res, 5)
