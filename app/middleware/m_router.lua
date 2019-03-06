return function(options)
    return function(ctx, next)
        ngx.say("router begin")
        next()
        ngx.say("router end")
    end
end