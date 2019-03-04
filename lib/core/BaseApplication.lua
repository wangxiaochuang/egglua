local _M = {}
local BaseContext = require("egglua.lib.core.BaseContext")
local BaseRequest = require("egglua.lib.core.BaseRequest")
local BaseResponse = require("egglua.lib.core.BaseResponse")


function _M:new(o)
    o = o or {
        context = BaseContext:clone(),
        request = BaseRequest:clone(),
        response = BaseResponse:clone(),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end
