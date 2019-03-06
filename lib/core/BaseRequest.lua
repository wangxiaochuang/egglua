local _M = {}

function _M:new()
    local o = {
        headers = {},
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

return _M
