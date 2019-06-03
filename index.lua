local BaseApplication = require("egglua.lib.core.BaseApplication")
local _M = {}

function _M.initapp(appname)
    local app = BaseApplication:new(appname)
    package.loaded["egglua.index"] = app
end

return _M