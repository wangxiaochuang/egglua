local _M = {}
local cjson = require "cjson"
local tinsert = table.insert
local table_insert = table.insert
local string_gsub = string.gsub

function _M.mixin(a, b)
    local res = {}
    if a then
        for k, v in pairs(a) do
            res[k] = v
        end
    end
    if b then
        for k, v in pairs(b) do
            res[k] = v
        end
    end
    return res
end

function _M.mergeArray(a, b)
    if a and b then
        local i = #a
        for idx = 1, #b do
            a[i + idx] = b[idx]
        end
    end
    return a or b
end
function _M.convertToSet(t)
    -- if next(t) and not _M.is_array(t) then return nil end
    local res = {}
    for _, v in ipairs(t) do
        res[v] = true
    end
    return res
end

function _M.removeRepeat(t)
    if not t then return nil end
    local unique = {}
    local res = {}
    for _, v in ipairs(t) do
        if not res[v] then
            res[v] = true
            table_insert(res, v)
        end
    end
    return res
end

function _M.loadPackage(path, flag)
    if not path then
        error("package path can not be empty")
    end
    local ok, pkg = pcall(require, path)
    if flag then
        return ok and pkg or nil
    else    
        return ok and pkg or error("can not load package: " .. path)
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

function _M.getValues(dict)
    local res = {}

    if #dict > 0 then 
        for k, v in pairs(dict) do
            table_insert(res, v)
        end
    end

    return res
end

function _M.select(dict, key)
    local res = {}
    for _, item in ipairs(dict) do
        if item[key] then table_insert(res, item[key]) end
    end
    return next(res) and res or nil
end

function _M.is_array(t)
    if type(t) ~= "table" then return false end
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

function _M.trim_prefix_slash(s)
    local str, _ = string_gsub(s, "^(//*)", "")
    return str
end

function _M.trim_suffix_slash(s)
    local str, _ = string_gsub(s, "(//*)$", "")
    return str
end

return _M