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
        state = {},
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
    rawset(instance, "service", convert(app.service, instance))
    return instance
end

convert = function(orig, params)
    local tmp = {}
    for k, v in pairs(orig) do
        if type(v) == "table" then
            tmp[k] = convert(orig[k], params)
        elseif type(v) == "function" then
            tmp[k] = v(params)
        end
    end
    return tmp
end

return _M