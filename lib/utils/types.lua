local _M = {}
local type = type

function _M:assertFunc(func, errmsg)
    assert(type(func) == "function")
end

return _M