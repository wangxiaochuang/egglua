local table_insert = table.insert
local fileUtils = require("egglua.lib.utils.FileUtils")

local function findPlugins(plugins, path)
    if fileUtils.isExist(path .. "/config/framework.lua") then
        findPlugins(plugins, fileUtils.findPath(dofile(path .. "/config/framework.lua"), "/config/config.lua"))
    end

    if fileUtils.isExist(path .. "/config/plugin.lua") then
        for k, v in pairs(dofile(path .. "/config/plugin.lua")) do
            if v.enable then
                local root = fileUtils.findPath(v.name, "/config/config.lua")
                local name = v.name
                if root then
                    table_insert(plugins, {
                        name = name,
                        path = root
                    })
                else
                    error("plugin[" .. name .. "] not found")
                end
            end
        end
    end
end

return function(app)
    local coreRootPath = app.coreRootPath
    local appRootPath = app.appRootPath

    local plugins = {}
    findPlugins(plugins, coreRootPath)
    findPlugins(plugins, appRootPath)
    app.plugins = plugins
end