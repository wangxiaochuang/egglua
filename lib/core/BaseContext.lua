local _M = {}
local BaseRequest = require("egglua.lib.core.BaseRequest")
local BaseResponse = require("egglua.lib.core.BaseResponse")

function _M:new(app)
    local instance = {
        app = app,
        req = BaseRequest:new(),
        res = BaseResponse:new(),
        state = {},
        matched = nil
    }
    setmetatable(instance, {
        __index = self,
        __newindex = instance.res
    })
    return instance
end

return _M