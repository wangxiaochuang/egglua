local utils = require("egglua.lib.utils.utils")
local Trie = require("egglua.lib.Trie")
local cjson = require "cjson"
local string_sub = string.sub
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
        matched.handlers["GET"]()
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
    local handler_func = params.handler
    if not handler_func then
        error("path[" .. path .. "] handler_func is nil")
    end
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

function _M:resources(params)
    local handler = params.handler
    local path = params.path 

    if path == "/" then
        error("resources path can not be /")
    end
    if string_sub(path, -1) == "/" then
        path = string_sub(path, 1, #path - 1)
    end

    if handler.index then
        self:get{
            path = path,
            handler = handler.index
        }
    end
    if handler.new then
        self:get{
            path = path .. "/new",
            handler = handler.new
        }
    end
    if handler.show then
        self:get{
            path = path .. "/:id",
            handler = handler.show
        }
    end
    if handler.edit then
        self:get{
            path = path .. "/:id/edit",
            handler = handler.edit
        }
    end
    if handler.create then
        self:post{
            path = path,
            handler = handler.create
        }
    end
    if handler.update then
        self:put{
            path = path .. "/:id",
            handler = handler.update
        }
    end
    if handler.destroy then
        self:delete{
            path = path .. "/:id",
            handler = handler.destroy
        }
    end
end

return _M
