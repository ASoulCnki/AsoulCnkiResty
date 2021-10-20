if ngx.ctx.cached then
    return
end

if ngx.ctx.cachable then
    local cache = ngx.shared.ranking_cache
    cache:set(ngx.ctx.cache_key, ngx.ctx.res, 3600)
end
