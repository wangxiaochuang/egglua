return function(options)
    return function(ctx, next)
        local res = ctx.res
        local say = ngx.say
        ngx.say = function()
            ngx.log(ngx.ERR, "you should not use ngx.say function")
        end

        next()

        ngx.status = res.status
        say(res.body)
    end
end