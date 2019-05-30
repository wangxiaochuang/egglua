local loadFuncs = require("egglua.lib.core.loader.Functions")
local fileUtils = require("egglua.lib.utils.FileUtils")

return function(app)
    local units = app.units
    for _, item in ipairs(units) do
        local path = item.path .. "/app/middleware"
        if fileUtils.isExist(path) then
            loadFuncs(app.middleware, path)
        end
    end

    -- compose framework, plugin and app middleware
    app:composeMiddleware()
end
