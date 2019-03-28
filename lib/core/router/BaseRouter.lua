local utils = require("egglua.lib.utils.utils")
local Trie = require("egglua.lib.Trie")
local cjson = require "cjson"
local _M = {}

local init

function _M:new()
    local o = {
        root = nil,
        map = {},
        trie = Trie:new{}
    }
    setmetatable(o, {
        __index = self
    })
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

    --[[
    local matched = self.trie:match("/home/id/xiao")
    if matched then
        ngx.say(cjson.encode(matched))
    else
        ngx.say("it is nil")
    end
    ngx.exit(200)
    ]]--
end

local function loadRouterFunc(router, params, method)
    local root = router.root
    local path = params.path
    if not path or string.len(path) == 0 then
        error("path can not be empty")
    end
    local handler_func = root .. ".app.controller." .. params.handler
    router.trie:add(path, handler_func, method)
end

function _M:get(params)
    loadRouterFunc(self, params, "GET")
end

function _M:post(params)
    loadRouterFunc(self, params, "POST")
end

function _M:put(params)
    loadRouterFunc(self, params, "PUT")
end

function _M:delete(params)
    loadRouterFunc(self, params, "DELETE")
end

function _M:del(params)
    loadRouterFunc(self, params, "POST")
end

return _M
