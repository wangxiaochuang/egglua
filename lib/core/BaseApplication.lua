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
local loadConfigs = require("egglua.lib.core.loader.Configs")
local loadPlugins = require("egglua.lib.core.loader.Plugins")
local loadControllers = require("egglua.lib.core.loader.Controllers")
local loadServices = require("egglua.lib.core.loader.Services")
local loadMiddlewares = require(("egglua.lib.core.loader.Middlewares"))
local loadRouters = require("egglua.lib.core.loader.Routers")

local init, handle

function _M:new(appname, env)
    local o = {
        coreRootPath = nil,
        appRootPath = nil,
        env = env,
        router = nil,
        plugins = nil,
        controller = {},
        service = {},
        config = nil,
        -- functions set
        middleware = {},
        -- global middleware
        fnMiddleware = nil
    }
    setmetatable(o, {
        __index = self
    })
    init(o, appname)
    return o
end

init = function(app, appname)
    local coreRootPath = app.coreRootPath
    local appRootPath = app.appRootPath
    for item in string_gmatch(package.path, '([^;]*%?.lua);') do
        if not coreRootPath then
            coreRootPath = string_gsub(item, "%?.lua", "egglua")
            if not fileUtils.isExist(coreRootPath .. "/lib/core/BaseApplication.lua") then
                coreRootPath = nil
            end
        end
        if not appRootPath then
            appRootPath = string_gsub(item, "%?.lua", appname)
            if not fileUtils.isExist(appRootPath .. "/app/router.lua") then
                appRootPath = nil
            end
        end
    end
    if not coreRootPath then error("egglua not found") end
    if not appRootPath then error(appname .. " router.lua not found") end
    app.coreRootPath = coreRootPath
    app.appRootPath = appRootPath

    loadConfigs(app)
    loadPlugins(app)
    loadMiddlewares(app)
    loadControllers(app)
    loadServices(app)
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

local function errhandleWrapper(debug)
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

    return compose(prepareMiddleware)
end

function _M:run()
    local ctx = BaseContext:new(self)
    handle(ctx, errhandleWrapper(self.config.debug))
end

return _M
