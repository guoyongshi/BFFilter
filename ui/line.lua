

local methods = {
    ['SetText'] = function(self,text)
        self.text:SetText(text)
    end,
}

function BFF_SepLine(parent,label)
    local frame = CreateFrame('Frame',nil,parent)
    frame:SetHeight(18)
    frame:SetWidth(200)

    local text = frame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    text:SetPoint('TOP')
    text:SetPoint('BOTTOM')
    text:SetText(label or '')

    local lineL = frame:CreateTexture(nil, "BACKGROUND")
    lineL:SetHeight(8)
    lineL:SetPoint("LEFT", 3, 0)
    lineL:SetPoint("RIGHT", text, "LEFT", -5, 0)
    lineL:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
    lineL:SetTexCoord(0.81, 0.94, 0.5, 1)

    local lineR = frame:CreateTexture(nil, "BACKGROUND")
    lineR:SetHeight(8)
    lineR:SetPoint("RIGHT", -3, 0)
    lineR:SetPoint("LEFT", text, "RIGHT", 5, 0)
    lineR:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
    lineR:SetTexCoord(0.81, 0.94, 0.5, 1)

    local widget = {
        frame = frame,
        text = text,
        full_width = true
    }

    for m,f in pairs(methods) do
        widget[m] = f
    end

    setmetatable(widget,{__index = BFF_FrameBase})

    return widget
end
