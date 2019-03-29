local _M = {}
local cjson = require("cjson")
local BaseContext = require("egglua.lib.core.BaseContext")
local BaseRouter = require("egglua.lib.core.router.BaseRouter")
local utils = require("egglua.lib.utils.utils")
local tinsert = table.insert
local tconcat = table.concat
local string_sub = string.sub
local string_gsub = string.gsub
local string_gmatch = string.gmatch
local fileUtils = require("egglua.lib.utils.FileUtils")

local init, loadMiddlewares, loadConfig, handle, compose, loadPlugins, loadRouters, loadControllers, loadServices

function _M:new(appname, env)
    local o = {
        coreRootPath = nil,
        appRootPath = nil,
        root = appname,
        env = env,
        router = nil,
        plugins = nil,
        controller = {},
        service = {},
        config = nil,
        middleware = {}
    }
    setmetatable(o, self)
    self.__index = self
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
    if not appRootPath then error(appname .. " not found") end
    app.coreRootPath = coreRootPath
    app.appRootPath = appRootPath

    loadConfig(app)
    loadPlugins(app)
    loadControllers(app)
    loadServices(app)
    loadMiddlewares(app)
    loadRouters(app)
end

loadConfig  = function(app)
    local coreRootPath = app.coreRootPath
    local appRootPath = app.appRootPath
    local env = app.env
    local envConf = nil
    -- 框架默认配置
    local defConf = dofile(coreRootPath .. "/config/config.default.lua")
    if not defConf then
        error("egglua default file not found")
    end
    -- 框架环境配置
    if env then
        envConf = dofile(coreRootPath .. "/config/config." .. env .. ".lua")
    end
    local conf = utils.mixin(defConf, envConf)
    local envConf = nil

    -- 应用默认配置
    defConf = dofile(appRootPath .. "/config/config.default.lua")
    if not defConf then
        error("app default file not found")
    end
    conf = utils.mixin(conf, defConf)
    -- 应用环境配置
    if env then
        envConf = dofile(appRootPath .. "/config/config." .. env .. ".lua")
    end
    
    conf = utils.mixin(conf, envConf)
    
    app.config = conf
end

loadPlugins = function(app)
end

local function loadFuncs(pkg, path)

    local dirs = fileUtils.getDirs(path)
    for _, dir in ipairs(dirs) do
        if not pkg[dir] then pkg[dir] = {} end
        loadControllerFunc(pkg[dir], path .. "/" .. dir)
    end

    local files = fileUtils.getFiles(path)
    for _, file in ipairs(files) do
        if string_sub(file, -4) == ".lua" then
            filename = string_sub(file, 1, -5)
            pkg[filename] = dofile(path .. "/" .. file)
        end
    end
end

loadControllers = function(app)
    local path = app.appRootPath .. "/app/controller"
    if not fileUtils.isExist(path) then
        error("app controller not found")
    end
    loadFuncs(app.controller, path)
end

loadServices = function(app)
    local path = app.appRootPath .. "/app/service"
    loadFuncs(app.service, path)
end

loadMiddlewares = function(app)
    -- framework middleware
    local coreMiddlewarePath = app.coreRootPath .. "/app/middleware"
    loadFuncs(app.middleware, coreMiddlewarePath)
    -- plugins middleware
    -- app middleware
    local appMiddlewarePath = app.appRootPath .. "/app/middleware"
    loadFuncs(app.middleware, appMiddlewarePath)
end

loadRouters = function(app)
    local router = BaseRouter:new(app)
    app.router = router
    router:init()
end



function _M:run()
    local ctx = BaseContext:new(self)
    handle(ctx)
end

handle = function(ctx)
    local app = ctx.app

    local err_msg = nil
    local path = ctx.req.path
    local trie = app.router.trie
    local matched = trie:match(path)
    if not matched then
        ngx.say(404)
        return
    end
    ctx.matched = matched
    matched.fnMiddleware(ctx)
    --[[
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
    ]]
end

return _M
