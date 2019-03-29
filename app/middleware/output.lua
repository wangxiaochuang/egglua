local say = ngx.say

return function(options)
    return function(ctx, next)
        local res = ctx.res
        -- ngx.say = function()
            -- ngx.log(ngx.ERR, "you should not use ngx.say function")
        -- end

        next()

        ngx.status = res.status
        say(res.body)
    end
end