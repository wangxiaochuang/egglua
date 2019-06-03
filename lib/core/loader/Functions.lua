local fileUtils = require("elf.lib.utils.FileUtils")
local string_sub = string.sub

local loadfunc = function(params)
    return params
end

local env = setmetatable({
    Service = loadfunc,
    Controller = loadfunc
}, {__index=_G})

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
            pkg[filename] = setfenv(assert(loadfile(path .. "/" .. file)), env)()
            if not pkg[filename] then
                error(path .. "/" .. file .. " not return module")
            end
        end
    end
end

return loadFuncs
