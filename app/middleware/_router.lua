return function(options)
    return function(ctx, next)
        local method = string.upper(ctx.req.method)
        local matched = ctx.matched

        ngx.say("router begin")
        matched.fnMiddleware(ctx, function() 
            ctx.req.params = matched.params
            local this = {
                ctx = ctx, 
                app = ctx.app, 
                logger = ctx.logger, 
                service = ctx.service
            }
            matched.handlers[method](this)
        end)
        ngx.say("router end")
    end
end