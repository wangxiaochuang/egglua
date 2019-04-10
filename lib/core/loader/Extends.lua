local table_insert = table.insert
local fileUtils = require("egglua.lib.utils.FileUtils")
local utils = require("egglua.lib.utils.utils")

return function(app)
    local units = app.units

    local application = {}
    for _, item in ipairs(units) do
        local path = item.path .. "/app/extend/application.lua"
        if fileUtils.isExist(path) then
            application = utils.mixin(application, dofile(path))
        end
    end
    app.extends.application = application

    local context = {}
    for _, item in ipairs(units) do
        local path = item.path .. "/app/extend/context.lua"
        if fileUtils.isExist(path) then
            context = utils.mixin(context, dofile(path))
        end
    end
    app.extends.context = context

    local request = {}
    for _, item in ipairs(units) do
        local path = item.path .. "/app/extend/request.lua"
        if fileUtils.isExist(path) then
            request = utils.mixin(request, dofile(path))
        end
    end
    app.extends.request = request

    local response = {}
    for _, item in ipairs(units) do
        local path = item.path .. "/app/extend/response.lua"
        if fileUtils.isExist(path) then
            response = utils.mixin(response, dofile(path))
        end
    end
    app.extends.response = response

    local helper = {}
    for _, item in ipairs(units) do
        local path = item.path .. "/app/extend/helper.lua"
        if fileUtils.isExist(path) then
            helper = utils.mixin(helper, dofile(path))
        end
    end
    app.extends.helper = helper
end