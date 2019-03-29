local loadFuncs = require("egglua.lib.core.loader.Functions")
local fileUtils = require("egglua.lib.utils.FileUtils")

return function(app)
    local path = app.appRootPath .. "/app/service"
    if fileUtils.isExist(path) then
        loadFuncs(app.service, path)
    end
end