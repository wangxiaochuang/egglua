local _M = {}

function _M:clone()
    local o = {}
    for key, val in pairs(self) do
        o[key] = val
    end
end

return _M
