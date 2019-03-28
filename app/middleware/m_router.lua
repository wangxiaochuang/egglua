return function(options)
    return function(ctx, next)
        local router = ctx.app.router
        local path = ctx.req.path
        local method = string.upper(ctx.req.method)
        local matched = router.trie:match(path)
        if not matched then
            ngx.say("404")
        else
            ctx.req.params = matched.params
            local handler = matched.handlers[method]
            if handler then
                handler(ctx)
            else
                ngx.say("404")
            end
        end
    end
end