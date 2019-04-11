local fileUtils = require("egglua.lib.utils.FileUtils")
local string_sub = string.sub

Service = function(params)
    return params
end

Controller = function(params)
    return params
end

local function loadFuncs(pkg, path)
    local dirs = fileUtils.getDirs(path)
    for _, dir in ipairs(dirs) do
        if not pkg[dir] then pkg[dir] = {} end
        loadFuncs(pkg[dir], path .. "/" .. dir)
    end

    local files = fileUtils.getFiles(path)
    for _, file in ipairs(files) do
        if string_sub(file, -4) == ".lua" then
            filename = string_sub(file, 1, -5)
            pkg[filename] = dofile(path .. "/" .. file)
        end
    end
end

return loadFuncs