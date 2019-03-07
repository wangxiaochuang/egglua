local _M = {}
local tinsert = table.insert

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

function _M.loadPackage(path, flag)
    if not path then
        error("package path can not be empty")
    end
    local ok, pkg = pcall(require, path)
    if ok then
        return flag and pkg or nil
    else    
        return flag and pkg or error("can not load package: " .. path)
    end
end

function _M.split(str, delimiter)
    if not str or str == "" then return {} end
    if not delimiter or delimiter == "" then return { str } end

    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        tinsert(result, match)
    end
    return result
end

return _M