return function(options)
    return function(ctx, next)
        local method = string.upper(ctx.req.method)
        local matched = ctx.matched
        ctx.req.params = matched.params
        local handler = matched.handlers[method]
        if handler then
            handler{
                app = ctx.app,
                ctx = ctx
            }
        else
            ngx.say("404")
        end
    end
end