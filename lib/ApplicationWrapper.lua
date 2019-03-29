local BaseApplication = require("egglua.lib.core.BaseApplication")
local lrucache = require "resty.lrucache"

local _M = {}

local c, err = lrucache.new(5)  -- allow up to 200 items in the cache
if not c then
    return error("failed to create the cache: " .. (err or "unknown"))
end

local createApplication = function(appname, env)
    local app = c:get(appname)
    if app then
        return app
    else
        app = BaseApplication:new(appname, env)
        c:set(appname, app)
    end

    return app
end

function _M:new()
    local instance = {
        app = nil
    }

    setmetatable(instance, {
        __index = self,
        __call = self.create_app
    })

    return instance
end

function _M:create_app(appname, env)
    self.app = createApplication(appname, env)
    return self.app
end

return _M
