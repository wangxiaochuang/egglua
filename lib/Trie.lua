local Node = require("egglua.lib.Node")
local string_gmatch = string.gmatch
local string_sub = string.sub
local string_gsub = string.gsub
local string_find = string.find
local table_insert = table.insert
local cjson = require "cjson"

local Trie = {}

local function check_segment(segment)
    if segment == "/" then return true end
    local tmp = string_gsub(segment, "([A-Za-z0-9._%-~]+)", "")
    if tmp ~= "" then
        error("segment[" .. segment .. "] is invalid")
    end
    return true
end

function Trie:new()
    local obj = {
        root = Node:new()
    }
    setmetatable(obj, {
        __index = self
    })
    return obj
end

local function _add(parent, pattern)
    for frag, other in string.gmatch(pattern, '(/[^/]*)(.*)') do
        if frag ~= "/" then
            frag = string_sub(frag, 2)
        end

        local node = parent:find_child(frag)
        if not node then
            node = Node:new()
            node.parent = parent

            if string_sub(frag, 1, 1) == ":" then
                if string_sub(frag, -1) == ")" then
                    local index = string_find(frag, "%(")
                    if index and index > 1 then
                        local regex = string_sub(frag, index + 1, #frag - 1)
                        if #regex > 0 then
                            node.name = string_sub(frag, 2, index-1)
                            node.regex = regex
                        else
                            error("invalid pattern: " .. frag)
                        end
                    else
                        error("invalid pattern: " .. frag)
                    end
                else
                    node.name = string_sub(frag, 2)
                end
                local colon_child = parent.colon_child
                if colon_child then
                    if colon_child.name ~= node.name or colon_child.regex ~= node.regex then
                        error("invalid pattern[3]: [" .. node.name .. "] conflict with [" .. colon_child.name .. "]")
                    end
                    node = colon_child
                else
                    parent.colon_child = node
                end
                check_segment(node.name)
            else
                parent.children[frag] = node
                check_segment(frag)
            end
        end
        if #other == 0 then
            return node
        else
            return _add(node, other)
        end
    end
end

function Trie:add(pattern, handler, method)
    local node = _add(self.root, pattern)
    if node.isEndpoint then
        error("duplicate router: " .. pattern)
    end
    node.isEndpoint = true
    node.pattern = pattern
    node.handlers[method] = handler
end

local function _match(parent, path, params)
    for frag, other in string.gmatch(path, '(/[^/]*)(.*)') do
        if frag ~= "/" then
            frag = string_sub(frag, 2)
        end
        check_segment(frag)

        local matched = nil
        if parent.children[frag] then
            -- the last one
            if #other == 0 and parent.children[frag].isEndpoint then
                return {
                    pattern = parent.children[frag].pattern,
                    handlers = parent.children[frag].handlers
                }
            end
            matched = _match(parent.children[frag], other, params)
        end

        local colon_child = parent.colon_child
        if not matched and colon_child then
            if colon_child.regex then
                if not string_find(frag, colon_child.regex) then
                    return nil
                end
            end

            if not params then params = {} end
            params[colon_child.name] = frag

            if #other == 0 and colon_child.isEndpoint then
                return {
                    pattern = colon_child.pattern,
                    handlers = colon_child.handlers,
                    params = params
                }
            end
            matched = _match(colon_child, other, params)
        end

        return matched
    end
end

function Trie:match(path)
    local matched = _match(self.root, path)
    return matched
end

return Trie