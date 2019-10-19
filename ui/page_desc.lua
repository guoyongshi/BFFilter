
local methods = {

}

function BFFPage_Desc(parent)
    local frame = CreateFrame('ScrollFrame',nil,parent)
    frame:EnableMouseWheel(true)
    frame:SetBackdrop(BFF_PaneBackdrop)
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4)

    local cbx = BFF_CheckBox(frame,'复选框测试')
    cbx:SetPoint('TOPLEFT',10,-10)
    local cfg = {
        xxxx = true
    }
    cbx:BindValue(cfg,'xxxx')
    cbx:OnChanged(function (self,value)
        print(self,value,cfg.xxxx)
    end)

    local widget = {
        frame = frame
    }

    for m,f in pairs(methods) do
        widget[m] = f
    end

    setmetatable(widget,{__index = BFF_FrameBase})

    return widget
end

