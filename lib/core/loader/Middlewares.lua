local loadFuncs = require("egglua.lib.core.loader.Functions")
local fileUtils = require("egglua.lib.utils.FileUtils")

return function(app)
    -- framework middleware
    local coreMiddlewarePath = app.coreRootPath .. "/app/middleware"
    if not fileUtils.isExist(coreMiddlewarePath) then
        error("core middleware not found")
    end
    loadFuncs(app.middleware, coreMiddlewarePath)
    -- plugins middleware
    -- app middleware
    local appMiddlewarePath = app.appRootPath .. "/app/middleware"
    if fileUtils.isExist(appMiddlewarePath) then
        loadFuncs(app.middleware, appMiddlewarePath)
    end

    -- compose framework, plugin and app middleware
    app.fnMiddleware = app:composeMiddleware()
end
