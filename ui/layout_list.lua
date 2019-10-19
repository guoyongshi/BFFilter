

local methods = {
    ['AddChild'] = function(self,child)
        if not child then
            return
        end
        table.insert(self.children,child)
    end
}

local function do_layout(self)

end

function BFF_ListLayout(parent)
    local frame = CreateFrame('ScrollFrame',nil,parent)
    frame:EnableMouseWheel(true)

    local widget = {
        frame = frame,
        children = {}
    }

    for m,f in pairs(methods) do
        widget[m] = f
    end

    setmetatable(widget,{__index = BFF_FrameBase})

    return widget
end

