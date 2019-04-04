local _M = {}

function _M:new(app)
    local o = {
        headers = {},
        status = 200
    }
    local ext_res = app.extends.response
    setmetatable(o, {
        __index = function(t, k)
            if self[k] then return self[k] end
            if ext_res then return ext_res[k] end
        end
    })
    return o
end

return _M