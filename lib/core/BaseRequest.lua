local _M = {}

function _M:new()
    local o = {
        headers = {},
        path = ngx.var.uri,
        method = ngx.req.get_method(),
        params = nil
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

return _M
