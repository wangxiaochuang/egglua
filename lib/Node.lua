local Node = {}

function Node:new(opts)
    local obj = {
        pattern = nil,
        endpoint = false,
        parent = nil,
        regex = nil,
        name = nil,
        handlers = {
            GET = nil,
            POST = nil,
        },
        children = {},
        colon_child
    }
    setmetatable(obj, {
        __index = self
    })
    return obj
end

function Node:find_child(key)
    return self.children[key]
end

return Node