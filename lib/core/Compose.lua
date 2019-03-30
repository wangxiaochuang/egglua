return function(funcs)
    local function nextWrapper(ctx, idx, finalFunction)
        if not funcs[idx] then
            if finalFunction then
                finalFunction()
            end
            return function() end
        end
        return function()
            return funcs[idx](ctx, nextWrapper(ctx, idx + 1, finalFunction))
        end
    end

    return function(ctx, finalFunction)
        nextWrapper(ctx, 1, finalFunction)()
    end
end