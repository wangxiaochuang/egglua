local BaseApplication = require("elf.lib.core.BaseApplication")
local _M = {}

function _M.initapp(appname)
    local app = BaseApplication:new(appname)
    package.loaded["elf.index"] = app
end

return _M
