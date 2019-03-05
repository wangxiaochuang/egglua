local _M = {}
local BaseContext = require("egglua.lib.core.BaseContext")
local BaseRequest = require("egglua.lib.core.BaseRequest")
local BaseResponse = require("egglua.lib.core.BaseResponse")


function _M:new()
    local o = {
        router = nil
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function _M:run()
    local ctx = BaseContext:new(self),
end

return _M
