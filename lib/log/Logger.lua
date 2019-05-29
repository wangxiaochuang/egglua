local log = ngx.log
local ERR = ngx.ERR
local INFO = ngx.INFO
local DEBUG = ngx.DEBUG

local _M = {}

function _M:error(fmt, ...)
    log(ERR, string.format(fmt, ... ))
end
function _M:info(fmt, ...)
    log(INFO, string.format(fmt, ... ))
end
function _M:debug(fmt, ...)
    log(DEBUG, string.format(fmt, ... ))
end

return _M