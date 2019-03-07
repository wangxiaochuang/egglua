local _M = {}
local cjson = require("cjson")
local BaseContext = require("egglua.lib.core.BaseContext")
local BaseRouter = require("egglua.lib.core.router.BaseRouter")
local utils = require("egglua.lib.utils.utils")
local tinsert = table.insert
local tconcat = table.concat

local init, loadMiddlewares, loadConfig, handle, compose, loadPlugins, loadRouters

function _M:new(root, env)
    local o = {
        root = root,
        env = env,
        router = nil,
        -- middlewares = nil,
        plugins = nil,
        config = nil,
        fnMiddlewares = nil
    }
    setmetatable(o, self)
    self.__index = self
    init(o)
    o.router = BaseRouter:new(o)
    return o
end

init = function(app)
    loadConfig(app)
    loadPlugins(app)
    loadMiddlewares(app)
    loadRouters(app)
end

loadConfig  = function(app)
    local root = app.root
    local env = app.env
    local envConf = nil
    -- 框架默认配置
    local ok, defConf = pcall(require, "egglua.config.config-default")
    if not ok then
        error("egglua default config does not exist")
    end
    -- 框架环境配置
    if env then
        _, envConf = pcall(require, "egglua.config.config-" .. env)
    end
    local conf = utils.mixin(defConf, envConf)
    local envConf = nil

    -- 应用默认配置
    ok, defConf = pcall(require, root .. ".config.config-default")
    if not ok then
        error("egglua default config does not exist")
    end
    conf = utils.mixin(conf, defConf)
    -- 应用环境配置
    if env then
        _, envConf = pcall(require, root .. ".config.config-" .. env)
    end
    
    conf = utils.mixin(conf, envConf)
    
    app.config = conf
end

loadPlugins = function(app)
end

loadMiddlewares = function(app)
    local root = app.root
    local config = app.config
    -- coreMiddleware
    local allMiddlewares = {}
    for _, item in ipairs(config.coreMiddleware) do
        local ok, fn = pcall(require, "egglua.app.middleware.m_" .. item)
        if not ok then
            error("require middleware " .. item .. " failed")
        end
        tinsert(allMiddlewares, fn(config[item] or {}))
    end

    -- app middleware
    for _, item in ipairs(config.middleware or {}) do
        local ok, fn = pcall(require, root .. ".app.middleware.m_" .. item)
        if not ok then
            error("require middleware " .. item .. " failed")
        end
        tinsert(allMiddlewares, fn(config[item] or {}))
    end

    app.fnMiddlewares = compose(allMiddlewares)
end

loadRouters = function(app)
end

compose = function(funcs)
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

function _M:run()
    local ctx = BaseContext:new(self)
    handle(self, ctx)
end

handle = function(app, ctx)
    local err_msg = nil
    local ok, ee = xpcall(function()
        app.fnMiddlewares(ctx)
    end, function(msg)
        if msg then
            if type(msg) == "string" then
                err_msg = msg 
            elseif type(msg) == "table" then
                err_msg = "[ERROR]" .. tconcat(msg, "|") .. "[/ERROR]"
            end
        else
            err_msg = ""
        end
        err_msg = err_msg .. "\n" .. traceback()
    end)
    if not ok then
        ngx.say("inter server failed")
        ngx.log(ngx.ERR, err_msg)
    end
end

return _M
