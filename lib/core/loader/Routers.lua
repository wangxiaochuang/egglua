local BaseRouter = require("egglua.lib.core.router.BaseRouter")



return function(app)
    local appRootPath = app.appRootPath
    BaseRouter:new(app)

    -- load app routers
    local appRouterFunc = dofile(appRootPath .. "/app/router.lua")
    if not appRouterFunc then
        error("require app router failed")
    end

    appRouterFunc(app)
end