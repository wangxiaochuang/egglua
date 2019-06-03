local table_insert = table.insert
local fileUtils = require("elf.lib.utils.FileUtils")

local map = {}

local function findPlugins(plugins, path)
    if fileUtils.isExist(path .. "/config/framework.lua") then
        findPlugins(plugins, fileUtils.findPath(dofile(path .. "/config/framework.lua"), "/config/config.lua"))
    end

    if fileUtils.isExist(path .. "/config/plugin.lua") then
        for name, opt in pairs(dofile(path .. "/config/plugin.lua")) do

            if type(opt) == "boolean" then
                if map[name] then
                    map[name].enable = opt
                else
                    opt = {
                        enable = opt
                    }
                end
            end
            if type(opt) == "table" and opt.enable then
                local package = opt.package or name
                local root = fileUtils.findPath(package, "/config/config.lua")
                if root then
                    local plugin = {
                        name = name,
                        path = root,
                        enable = true
                    }
                    map[name] = plugin
                    table_insert(plugins, plugin)
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
