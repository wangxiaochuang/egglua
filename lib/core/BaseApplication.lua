local _M = {}
local BaseContext = require("egglua.lib.core.BaseContext")

function _M:new()
    local o = {
        router = nil,
        fnMiddlewares = nil
    }
    ngx.say("first init application")
    setmetatable(o, self)
    self.__index = self
    o:loadMiddlewares()
    return o
end

function _M:loadMiddlewares()
    self.fnMiddlewares = function(ctx)
    end
end

function _M:run()
    local ctx = BaseContext:new(self)
    self:handle(ctx)
end

function _M:handle(ctx)
    local fnMiddlewares = self.fnMiddlewares
    ngx.header['Content-Type'] = "application/json; charset=utf-8"
    ngx.say("handle request")
end

return _M
