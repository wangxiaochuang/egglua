local loadFuncs = require("egglua.lib.core.loader.Functions")
local fileUtils = require("egglua.lib.utils.FileUtils")

return function(app)
    local path = app.appRootPath .. "/app/controller"
    if not fileUtils.isExist(path) then
        error("app controller not found")
    end
    loadFuncs(app.controller, path)
end