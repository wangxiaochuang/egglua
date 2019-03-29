return function(options)
    return function(ctx, next)
        ngx.say("gzip begin")
        next()
        ngx.say("gzip end")
    end
end