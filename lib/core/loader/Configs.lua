local utils = require("egglua.lib.utils.utils")
local fileUtils = require("egglua.lib.utils.FileUtils")

return function(app)
    local coreRootPath = app.coreRootPath
    local appRootPath = app.appRootPath
    local envConf = nil
    local env = nil
    if fileUtils.isExist(appRootPath .. "/config/env.lua") then
        local tmp = dofile(appRootPath .. "/config/env.lua")
        if tmp then
            env = tmp.env
        end
    end
    -- 框架默认配置
    local defConf = dofile(coreRootPath .. "/config/config.default.lua")
    if not defConf then
        error("egglua default file not found")
    end
    -- 框架环境配置
    if env then
        envConf = dofile(coreRootPath .. "/config/config." .. env .. ".lua")
    end
    local conf = utils.mixin(defConf, envConf)
    local envConf = nil

    -- 应用默认配置
    defConf = dofile(appRootPath .. "/config/config.default.lua")
    if not defConf then
        error("app default file not found")
    end
    conf = utils.mixin(conf, defConf)
    -- 应用环境配置
    if env then
        envConf = dofile(appRootPath .. "/config/config." .. env .. ".lua")
    end
    
    conf = utils.mixin(conf, envConf)
    conf.env = env
    
    app.config = conf
end
