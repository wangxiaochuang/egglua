local utils = require("egglua.lib.utils.utils")
local Trie = require("egglua.lib.Trie")
local cjson = require "cjson"
local string_sub = string.sub
local string_gsub = string.gsub
local table_insert = table.insert
local _M = {}

local init

function _M:new(app)
    local o = {
        app = app,
        trie = Trie:new{}
    }
    setmetatable(o, {
        __index = self
    })
    return o
end

function _M:init()
    local appRootPath = self.app.appRootPath
    -- load app routers
    local appRouterFunc = dofile(appRootPath .. "/app/router.lua")
    if not appRouterFunc then
        error("require app router failed")
    end

    appRouterFunc(self.app)
end

local function compose(funcs)
    local nextWrapper = nil
    nextWrapper = function(ctx, idx)
        return function()
            if funcs[idx] then
                funcs[idx](ctx, nextWrapper(ctx, idx + 1))
            end
        end
    end

    return function(ctx)
        nextWrapper(ctx, 1)()
    end
end

local function composeMiddleware(app, routerMiddleware)
    local middlewareMap = app.middleware
    local config = app.config
    local unique = {
        router = true,
        output = true
    }

    local prepareMiddleware = {}
    table_insert(prepareMiddleware, middlewareMap["output"](config.router or {}))

    local coreMiddleware = app.config.coreMiddleware
    for _, item in ipairs(coreMiddleware) do
        if unique[item] then
            error("duplicate core middleware")
        end
        if not middlewareMap[item] then
            error("core middleware " .. item .. " not found")
        end
        unique[item] = true
        table_insert(prepareMiddleware, middlewareMap[item](config[item] or {}))
    end
    -- local pluginMiddleware = app.config.pluginMiddleware
    local appMiddleware = app.config.middleware or {}
    for _, item in ipairs(appMiddleware) do
        if unique[item] then
            error("duplicate app middleware with core: " .. item)
        end
        if not middlewareMap[item] then
            error("app middleware " .. item .. " not found")
        end
        unique[item] = true
        table_insert(prepareMiddleware, middlewareMap[item](config[item] or {}))
    end

    for _, item in ipairs(routerMiddleware) do
        if #item ~= 2 then
            error("router middleware is error: ")
        end
        if unique[item[1]] then
            error("duplicate router middleware: " .. item[1])
        end
        if not middlewareMap[item[1]] then
            error("router middleware " .. item[1] .. " not found")
        end
        table_insert(prepareMiddleware, middlewareMap[item[1]](utils.mixin(config[item[1]], item[2]) or {}))
    end

    table_insert(prepareMiddleware, middlewareMap["router"](config.router or {}))

    return compose(prepareMiddleware)
end

local function loadRouterFunc(router, params, method)
    local path = params.path
    if not path or string.len(path) == 0 then
        error("path can not be empty")
    end
    path = string_gsub(path, "//*", "/")
    local handler_func = params.handler
    if not handler_func then
        error("path[" .. path .. "] handler_func is nil")
    end

    local fnMiddleware = composeMiddleware(router.app, params.middleware)

    router.trie:add(path, fnMiddleware, handler_func, method)
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
    loadRouterFunc(self, params, "GET")
end

function _M:post(...)
    local params = parseParams({...})
    loadRouterFunc(self, params, "POST")
end

function _M:put(...)
    local params = parseParams({...})
    loadRouterFunc(self, params, "PUT")
end

function _M:delete(...)
    local params = parseParams({...})
    loadRouterFunc(self, params, "DELETE")
end

function _M:del(...)
    local params = parseParams({...})
    loadRouterFunc(self, params, "DELETE")
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
    local middleware = params.middleware

    if handler.index then
        local params = {
            name = name .. "_index",
            path = path,
            handler = handler.index,
            middleware = getSpecificMiddleware(middleware, "index")
        }
        loadRouterFunc(self, params, "GET")
    end
    if handler.new then
        local params = {
            name = name .. "_new",
            path = path .. "/new",
            handler = handler.new,
            middleware = getSpecificMiddleware(middleware, "new")
        }
        loadRouterFunc(self, params, "GET")
    end
    if handler.show then
        local params = {
            name = name .. "_show",
            path = path .. "/:id",
            handler = handler.show,
            middleware = getSpecificMiddleware(middleware, "show")
        }
        loadRouterFunc(self, params, "GET")
    end
    if handler.edit then
        local params = {
            name = name .. "_edit",
            path = path .. "/:id/edit",
            handler = handler.edit,
            middleware = getSpecificMiddleware(middleware, "edit")
        }
        loadRouterFunc(self, params, "GET")
    end
    if handler.create then
        local params = {
            name = name .. "_create",
            path = path,
            handler = handler.create,
            middleware = getSpecificMiddleware(middleware, "create")
        }
        loadRouterFunc(self, params, "POST")
    end
    if handler.update then
        local params = {
            name = name .. "_update",
            path = path .. "/:id",
            handler = handler.update,
            middleware = getSpecificMiddleware(middleware, "update")
        }
        loadRouterFunc(self, params, "PUT")
    end
    if handler.destroy then
        local params = {
            name = name .. "_destroy",
            path = path .. "/:id",
            handler = handler.destroy,
            middleware = getSpecificMiddleware(middleware, "destroy")
        }
        loadRouterFunc(self, params, "DELETE")
    end
end

return _M
