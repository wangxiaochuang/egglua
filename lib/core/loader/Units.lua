local table_insert = table.insert
local utils = require("elf.lib.utils.utils")
local fileUtils = require("elf.lib.utils.FileUtils")

local function findFramework(units, name, path)
    if fileUtils.isExist(path .. "/config/framework.lua") then
        findFramework(units, fileUtils.findPath(dofile(path .. "/config/framework.lua"), "/config/config.lua"))
    end
    table_insert(units, {
        name = name,
        path = path
    })
end
return function(app)
    local coreRootPath = app.coreRootPath
    local appRootPath = app.appRootPath
    local plugins = app.plugins

    local units = {}
    --utils.mergeArray(units, plugins)
    for _, item in ipairs(plugins) do
        if item.enable then
            table_insert(units, item)
        end
    end

    table_insert(units, {
        name = "elf",
        path = coreRootPath
    })

    local framework = nil
    if fileUtils.isExist(appRootPath .. "/config/framework.lua") then
        framework = dofile(appRootPath .. "/config/framework.lua")
    end
    local frameworkRootPath = fileUtils.findPath(framework, "/config/config.lua")
    if not frameworkRootPath then
        error(framework .. " framework not found")
    end
    findFramework(units, framework, frameworkRootPath)

    table_insert(units, {
        name = app.appname,
        path = appRootPath
    })

    app.units = units
end
