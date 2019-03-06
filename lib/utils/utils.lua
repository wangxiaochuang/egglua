local _M = {}

function _M.mixin(a, b)
    if a and b then
        for k, _ in pairs(b) do
            a[k] = b[k]
        end
    end
    return a
end

function _M.mergeArray(a, b)
    local i = #a
    for idx = 1, #b do
        a[i + idx] = b[idx]
    end
    return a
end

return _M