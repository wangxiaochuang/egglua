local utils = require("egglua.lib.utils.utils")
local _M = {}

local init

function _M:new()
    local o = {
        root = nil,
        map = {}
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function _M:init(app)
    local root = app.root
    self.root = root
    -- load app routers
    local ok, appRouterFunc = pcall(require, root .. ".app.router")
    if not ok then
        error("require app router failed")
    end
    appRouterFunc(app)

    local cjson = require "cjson"
    ngx.say(cjson.encode(self.map))
    ngx.exit(200)
end

local function getNodeType(node)
    local res = string.find(node, '^:[%w_%-]+')
    if res then
        return "COLON"
    end

    res = string.find(node, '^[%w_%-]+$')
    if res then
        return "RAW"
    end

    return "REG"
end

local function addRouter(map, path, handler)
    for node, other in string .gmatch(path, '(/[^/]*)(.*)') do
        node = string.lower(string.sub(node, 2, -1))
        -- /home/
        if node == "" then node = "/" end

        local nodeType = getNodeType(node)
        if nodeType == "RAW" then
            if not map[node] then map[node] = {} end
            if other == "" then
                -- 确保没有同名的路由
                if map[node].__handler then error("router duplicate") end
                -- 确保尾部不是正则表达式
                for key, value in pairs(map.REG or {}) do
                    if value.__handler then error("router duplicate") end
                end
                -- 确保尾部不是冒号表达式
                for key, value in pairs(map.COLON or {}) do
                    if value.__handler then error("router duplicate") end
                end
                map[node].__handler = "handler"
            else
                return addRouter(map[node], other, handler)
            end
        else
            if not map[nodeType] then map[nodeType] = {} end
            if not map[nodeType][node] then map[nodeType][node] = {} end
            -- nodeType == "COLON" or "REG"    /home/:id  /home/:key/:id
            if other == "" then
                for key, value in pairs(map) do
                    if value.__handler then error("router duplicate") end
                end
                for key, value in pairs(map.REG or {}) do
                    if value.__handler then error("router duplicate") end
                end
                for key, value in pairs(map.COLON or {}) do
                    if value.__handler then error("router duplicate") end
                end
                map[nodeType][node].__handler = "handler"
            else
                return addRouter(map[nodeType][node], other, handler)
            end
        end
    end
end

local function loadRouterFunc(router, params, method)
    local root = router.root
    local path = params.path
    if not path or string.len(path) == 0 then
        error("path can not be empty")
    end
    local map = router.map
    local handler_func = root .. ".app.controller." .. params.handler

    for pkg, func in string.gmatch(handler_func, '(.*)%.([%w_%-]+)') do
        local pkg = utils.loadPackage(pkg)
        if not map[method] then map[method] = {} end
        -- map[method][path] = pkg[func]
        if not map[method] then map[method] = {} end
        addRouter(map[method], path, pkg[func])
    end
end

function _M:get(params)
    loadRouterFunc(self, params, "GET")
end

function _M:post(params)
    loadRouterFunc(self, params, "POST")
end

return _M
