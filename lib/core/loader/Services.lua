local loadFuncs = require("elf.lib.core.loader.Functions")
local fileUtils = require("elf.lib.utils.FileUtils")

return function(app)
    local units = app.units
    for _, item in ipairs(units) do
        local path = item.path .. "/app/service"
        if fileUtils.isExist(path) then
            loadFuncs(app.service, path)
        end
    end
end
