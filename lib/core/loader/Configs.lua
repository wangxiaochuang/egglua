local utils = require("egglua.lib.utils.utils")
local fileUtils = require("egglua.lib.utils.FileUtils")

return function(app)
    local appRootPath = app.appRootPath
    local units = app.units
    local env = nil
    local envPath = appRootPath .. "/config/env.lua"
    if fileUtils.isExist(envPath) then
        local tmp = dofile(envPath)
        if tmp then
            env = tmp.env
        end
    end
    local config = {}
    for _, item in ipairs(units) do
        local conf = dofile(item.path .. "/config/config.lua")
        if type(conf) ~= "table" then
            error(item.name .. " config is not table")
        end
        config = utils.mixin(config, conf)
    end

    if env then
        for _, item in ipairs(units) do
            local envConfPath = item.path .. "/config/config." .. env .. ".lua"
            if fileUtils.isExist(envConfPath) then
                local envconf = dofile(envConfPath)
                config = utils.mixin(config, envconf)
            end
            config = utils.mixin(config, conf)
        end
    end
    
    config.env = env
    app.config = config
end
