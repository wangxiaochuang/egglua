local _M = {}
local BaseRequest = require("egglua.lib.core.BaseRequest")
local BaseResponse = require("egglua.lib.core.BaseResponse")

local convert

function _M:new(app)
    local instance = {
        app = app,
        req = BaseRequest:new(app),
        res = BaseResponse:new(app),
        helper = app.extends.helper,
        state = {data = "private"},
        matched = nil
    }
    local ext_ctx = app.extends.context
    setmetatable(instance, {
        __index = function(t, k)
            if self[k] then return self[k] end
            if ext_ctx then return ext_ctx[k] end
        end,
        __newindex = instance.res
    })
    
    rawset(instance, "service", setmetatable({ctx = instance, current = app.service}, {
        __index = function(t, k)
            t.current = t.current[k]
            return type(t.current) == "table" and t or t.current
        end
    }))
    return instance
end

return _M