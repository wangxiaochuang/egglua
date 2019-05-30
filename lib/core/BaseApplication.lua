local _M = {}
local say = ngx.say
local BaseContext = require("egglua.lib.core.BaseContext")
local table_concat = table.concat
local utils = require("egglua.lib.utils.utils")
local compose = require("egglua.lib.core.Compose")
local string_gsub = string.gsub
local string_gmatch = string.gmatch
local table_insert = table.insert
local fileUtils = require("egglua.lib.utils.FileUtils")

local loadPlugins = require("egglua.lib.core.loader.Plugins")
local loadUnits = require("egglua.lib.core.loader.Units")
local loadConfigs = require("egglua.lib.core.loader.Configs")
local loadExtends = require("egglua.lib.core.loader.Extends")
local loadApps = require("egglua.lib.core.loader.Apps")
local loadServices = require("egglua.lib.core.loader.Services")
local loadMiddlewares = require(("egglua.lib.core.loader.Middlewares"))
local loadControllers = require("egglua.lib.core.loader.Controllers")
local loadRouters = require("egglua.lib.core.loader.Routers")

local init, handle

function _M:new(appname)
    local o = {
        coreRootPath = nil,
        appRootPath = nil,
        router = nil,
        plugins = nil,
        units = {},
        controller = {},
        extends = {
        },
        service = {},
        config = nil,
        appname = appname,
        -- functions set
        middleware = {},
        -- global middleware
        fnMiddleware = nil
    }
    setmetatable(o, {
        __index = function(t, k)
            if self[k] then return self[k] end
            local ext_app = o.extends.application
            if ext_app then return ext_app[k] end
        end
    })
    init(o)
    return o
end

init = function(app)
    local appname = app.appname
    local filepath = debug.getinfo(1, 'S').source:sub(2)
    local s = string.find(filepath, "/lib/core/BaseApplication.lua")
    if not s then
        error("egglua not found")
    end
    local coreRootPath = string.sub(filepath, 1, s - 1)

    -- find app root path
    local appRootPath = fileUtils.findPath(appname, "/app/router.lua")
    if not appRootPath then
        error(appname .. " not found")
    end

    app.coreRootPath = coreRootPath
    app.appRootPath = appRootPath

    loadPlugins(app)
    loadUnits(app)
    loadConfigs(app)
    loadExtends(app)
    loadApps(app)
    loadServices(app)
    loadMiddlewares(app)
    loadControllers(app)
    loadRouters(app)
end

handle = function(ctx, errhandle)
    local app = ctx.app
    local err_msg = nil
    local ok, ee = xpcall(function()
        app.fnMiddleware(ctx)
    end, function(msg)
        if msg then
            if type(msg) == "string" then
                err_msg = msg 
            elseif type(msg) == "table" then
                err_msg = "[ERROR]" .. table_concat(msg, "|") .. "[/ERROR]"
            end
        else
            err_msg = ""
        end
        err_msg = err_msg .. "\n" .. traceback()
    end)
    if not ok then
        errhandle(500, "system error =^_^=", err_msg)
        return
    end
end

function _M.errhandle(debug)
    return function(status, msg, debug)
        ngx.status = status
        if debug then
            say(debug)
        else
            say(msg)
        end
        ngx.exit(ngx.status)
    end
end

function _M:composeMiddleware()
    local config = self.config
    local coreMiddleware = config.coreMiddleware
    table_insert(coreMiddleware, 1, "_gate")
    table_insert(coreMiddleware, "_router")
    local middlewareMap = self.middleware
    local globalMiddleware = utils.removeRepeat(utils.mergeArray(config.coreMiddleware, config.middleware))

    local prepareMiddleware = {}
    for _, item in ipairs(globalMiddleware) do
        local key = item
        local opts = config[key]

        if not middlewareMap[key] then
            error("core middleware " .. key .. " not found")
        end
        table_insert(prepareMiddleware, middlewareMap[key](opts or {}))
    end

    self.fnMiddleware = compose(prepareMiddleware)
end

function _M:run()
    local ctx = BaseContext:new(self)
    handle(ctx, self.errhandle(self.config.debug))
end

return _M
