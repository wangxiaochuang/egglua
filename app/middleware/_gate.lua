local string_upper = string.upper
local cjson = require "cjson"
local say = ngx.say

return function(options)
    return function(ctx, next)
        local res = ctx.res

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

        if not ctx.app.config.debug then
            ngx.status = res.status
        end
        if type(res.body) == "table" then
            ctx.app.output(cjson.encode(res.body))
        else
            ctx.app.output(res.body)
        end
    end
end