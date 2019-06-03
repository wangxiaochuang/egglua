local fileUtils = require("egglua.lib.utils.FileUtils")

return function(app)
    local units = app.units
    for _, item in ipairs(units) do
        local path = item.path .. "/app.lua"
        if fileUtils.isExist(path) then
            local appFunc = dofile(path)
            local ok, err = pcall(appFunc, app)
            if not ok then
                ngx.log(ngx.ERR, err)
                error(path .. " exec error")
            end
        end
    end
end