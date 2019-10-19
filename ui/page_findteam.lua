
local methods = {

}

function BFFPage_FindTeam(parent)
    local frame = CreateFrame('ScrollFrame',nil,parent)
    frame:EnableMouseWheel(true)
    frame:SetBackdrop(BFF_PaneBackdrop)
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4)

    local widget = {
        frame = frame
    }

    for m,f in pairs(methods) do
        widget[m] = f
    end

    setmetatable(widget,{__index = BFF_FrameBase})

    return widget
end

