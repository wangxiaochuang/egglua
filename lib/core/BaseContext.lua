local _M = {}
local BaseRequest = require("egglua.lib.core.BaseRequest")
local BaseResponse = require("egglua.lib.core.BaseResponse")

function _M:new(app)
    local instance = {
        app = app,
        req = BaseRequest:new(),
        res = BaseResponse:new(),
        body = "init body data, you should not see it",
        state = {},
        matched = nil
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end

return _M