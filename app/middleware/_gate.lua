local string_upper = string.upper
local cjson = require "cjson"
local say = ngx.say

return function(options)
    return function(ctx, next)
        local res = ctx.res
        if not ctx.app.config.debug then
            ngx.say = function()
                ngx.log(ngx.ERR, "you should not use ngx.say function")
            end
        end

        local path = ctx.req.path
        local method = string_upper(ctx.req.method)
        local trie = ctx.app.router.trie
        local matched = trie:match(path, method)
        if not matched then
            ngx.status = 404
            return
        end
        rawset(ctx, "matched", matched)

        next()

        ngx.status = res.status
        if type(res.body) == "table" then
            say(cjson.encode(res.body))
        else
            say(res.body)
        end
    end
end