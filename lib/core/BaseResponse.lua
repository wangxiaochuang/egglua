local _M = {}

function _M:new()
    local o = {
        headers = {},
        status = 200
    }
    setmetatable(o, {
        __index = self
    })
    return o
end

return _M