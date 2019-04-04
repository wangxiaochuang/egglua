local _M = {}
local table_insert = table.insert
local string_sub = string.sub
local string_gsub = string.gsub
local string_gmatch = string.gmatch

local function popen (command, n)
    if not n then n = math.huge end
    local result, err

    for i = 1, n do
        local file = io.popen(command)
        result, err = file:read("*a")
        file:close()

        if err and err == "Interrupted system call" then
        else
            break
        end
    end

    return result, err
end

function _M.isExist(path)
    local file, err = io.open(path)
    if not file then
        return false
    else

        return true
    end
end
function _M.isDir (path)
    local file = io.open(path)

    if not file then
        return false
    end

    local content, err = file:read(0)
    file:close()

    if not content and err == "Is a directory" then
        return true
    else
        return false
    end
end

function _M.isFile (path)
    local file = io.open(path)

    if not file then
        return false
    end

    local content = file:read(0)
    file:close()

    if not content then
        return false
    else
        return true
    end
end

function _M.getDirs(path)
    local allfiles = _M.readdir(path)
    local res = {}
    if allfiles then
        for _, filename in ipairs(allfiles) do
            if _M.isDir(path .. "/" .. filename) and string_sub(filename, 1, 1) ~= "." then
                table_insert(res, filename)
            end
        end
    end
    return res
end

function _M.getFiles(path)
    local allfiles = _M.readdir(path)
    local res = {}
    if allfiles then
        for _, filename in ipairs(allfiles) do
            if _M.isFile(path .. "/" .. filename) and string_sub(filename, 1, 1) ~= "." then
                table_insert(res, filename)
            end
        end
    end
    return res
end

function _M.readdir(path, n)
    local content = popen("ls -a '" .. path .. "'", n)

    if not content or content == "" then
        return nil, "No such file or directory"
    end

    local dir = {}
    local i = 0
    local start = 1
    while true do
        i = string.find(content, "\n", i + 1)
        if i == nil then 
            break
        else
            local file = string.sub(content, start, i - 1)
            start = i + 1

            if file ~= "." and file ~= ".." then
                table.insert(dir, file)
            end
        end
    end

    return dir
end

function _M.findPath(name, checkpath)
    local path = nil
    checkpath = checkpath or ""
    for item in string_gmatch(package.path, '([^;]*%?.lua);') do
        if not path then
            path = string_gsub(item, "%?.lua", name)
            if not _M.isExist(path .. checkpath) then
                path = nil
            end
        end
    end
    return path
end

return _M