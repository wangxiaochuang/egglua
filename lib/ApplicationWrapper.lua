local BaseApplication = require("egglua.lib.core.BaseApplication")

local _M = {}

local createApplication = function(option)
    local app = BaseApplication:new()
    -- @todo
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

function _M:create_app(option)
    self.app = createApplication(option)
    return self.app
end

return _M