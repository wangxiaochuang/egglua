local BaseApplication = require("egglua.lib.core.BaseApplication")
local lrucache = require "resty.lrucache"

local _M = {}

local c, err = lrucache.new(200)  -- allow up to 200 items in the cache
if not c then
    return error("failed to create the cache: " .. (err or "unknown"))
end

local createApplication = function(root, env)
    local app = c:get("app")
    if app then
        return app
    else
        app = BaseApplication:new(root, env)
        c:set("app", app)
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

function _M:create_app(root, env)
    self.app = createApplication(root, env)
    return self.app
end

return _M