local utils = require("egglua.lib.utils.utils")
local Trie = require("egglua.lib.Trie")
local compose = require("egglua.lib.core.Compose")
local cjson = require "cjson"
local string_sub = string.sub
local string_gsub = string.gsub
local table_insert = table.insert
local _M = {}

local init

local templates = {
    index = {
        method = "GET",
    },
    new = {
        method = "GET",
        path = "/new"
    },
    show = {
        method = "GET",
        path = "/:id"
    },
    edit = {
        method = "GET",
        path = "/:id/edit"
    },
    create = {
        method = "POST",
    },
    update = {
        method = "PUT",
        path = "/:id"
    },
    destroy = {
        method = "DELETE",
        path = "/:id"
    }
}

function _M:new(app)
    local o = {
        app = app,
        trie = Trie:new{}
    }
    setmetatable(o, {
        __index = self
    })
    app.router = o
    return o
end

function _M:composeMiddleware(middlewares)
    local config = self.app.config
    local middlewareMap = self.app.middleware
    local globalMiddleware = utils.removeRepeat(utils.mergeArray(config.coreMiddleware, config.middleware))
    local unique = utils.convertToSet(globalMiddleware)
    -- middlwares = {{"auth", {k=v}}, {"gzip"}}

    local prepareMiddleware = {}
    for _, item in ipairs(middlewares) do
        local key = item[1]
        local opts = utils.mixin(config[key], item[2])
        if unique[key] then
            error("duplicate router middleware: " .. item[1])
        end
        unique[key] = true

        if not middlewareMap[key] then
            error("core middleware " .. item .. " not found")
        end
        table_insert(prepareMiddleware, middlewareMap[key](opts or {}))
    end

    return compose(prepareMiddleware)
end

function _M:addRouter(params, method)
    local path = params.path
    if not path or string.len(path) == 0 then
        error("path can not be empty")
    end
    path = string_gsub(path, "//*", "/")
    local handler_func = params.handler
    if not handler_func then
        error("path[" .. path .. "] handler_func is nil")
    end

    local fnMiddleware = self:composeMiddleware(params.middleware)

    self.trie:add(path, fnMiddleware, handler_func, method)
end

local function parseParams(params)
    local res = {}
    if #params < 2 then
        error("router params length error " .. cjson.encode(params))
    end
    if type(params[2]) == "string" then
        if type(params[1]) ~= "string" then
            error("router params error")
        end
        res.name = params[1]
        res.path = params[2]
        res.handler = params[#params]
        params[1] = nil
        params[2] = nil
        params[#params] = nil
    else
        if type(params[1]) ~= "string" then
            error("router params error")
        end
        res.path = params[1]
        res.handler = params[#params]
        params[1] = nil
        params[#params] = nil
    end

    res.middleware = utils.getValues(params)
    return res
end

function _M:get(...)
    local params = parseParams({...})
    self:addRouter(params, "GET")
end

function _M:post(...)
    local params = parseParams({...})
    self:addRouter(params, "POST")
end

function _M:put(...)
    local params = parseParams({...})
    self:addRouter(params, "PUT")
end

function _M:delete(...)
    local params = parseParams({...})
    self:addRouter(params, "DELETE")
end

function _M:del(...)
    local params = parseParams({...})
    self:addRouter(params, "DELETE")
end

local function getSpecificMiddleware(t, key)
    local res = {}
    for _, item in ipairs(t) do
        if utils.is_array(item) then
            table_insert(res, item)
        else
            if item[key] then
                table_insert(res, item[key])
            end
        end
    end
    return res
end

function _M:resources(...)
    local params = parseParams({...})

    local path = params.path

    if path == "/" then
        error("resources path can not be /")
    end
    if string_sub(path, -1) == "/" then
        path = string_sub(path, 1, #path - 1)
        params.path = path
    end

    local name = params.name
    if not name then
        name = string.match(path, ".*/([%w_]+)")
    end
    local handler = params.handler
    if type(handler) ~= "table" then error("resources handler is not a table") end
    local middleware = params.middleware

    for key, item in pairs(templates) do
        if handler[key] then
            local params = {
                name = name .. "_" .. key,
                path = path .. (item.path or ""),
                handler = handler[key],
                middleware = getSpecificMiddleware(middleware, key)
            }
            self:addRouter(params, item.method or "GET")
        end
    end
end

return _M
