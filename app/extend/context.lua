local _M = {}

function _M:say()
    ngx.say("i am in extend context")
end

return _M