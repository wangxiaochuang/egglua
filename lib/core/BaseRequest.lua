local _M = {}

function _M:new(app)
    local o = {
        headers = {},
        path = ngx.var.uri,
        method = ngx.req.get_method(),
        params = nil
    }
    local ext_req = app.extends.request
    setmetatable(o, {
        __self = function(t, k)
            if self[k] then return self[k] end
            if ext_req then return ext_req[k] end
        end
    })
    return o
end

return _M
