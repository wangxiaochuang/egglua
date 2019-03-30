return function(options)
    return function(ctx, next)
        ngx.say("parse body begin")
        next()
        ngx.say("parse body end")
    end
end