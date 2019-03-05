local _M = {}

function _M:new(app)
    local instance = {
        app = app,
        request = BaseRequest:new(),
        response = BaseResponse:new(),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

