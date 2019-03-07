local utils = require("egglua.lib.utils.utils")
local _M = {}

local init

function _M:new(app)
    local o = {
    }
    setmetatable(o, self)
    self.__index = self
    init(o, app)
    return o
end

init = function(instance, app)
    local root = app.root
    -- load app routers
    local ok, appRouterFunc = pcall(require, root .. ".app.router")
    if not ok then
        error("require app router failed")
    end
    appRouterFunc(app)
end

function _M:resources(params)
    local path = params.path
    local handler = params.handler

    local pkg = utils.loadPackage(handler)
end

function _M:get(params)
    local path = params.path
    local handler = params.handler

    local pkg = utils.loadPackage(handler)
    assertFunction(pkg)
end

return _M
