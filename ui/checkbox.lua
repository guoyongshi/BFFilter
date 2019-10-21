

local methods = {
    --和一个table的一个值(bool)绑定
    ['BindValue'] = function(self,data,key)
        if not data or not key then
            return
        end
        self.bind_data = data
        self.bind_key = key
    end,
    ['OnChanged'] = function(self,func)
        self.on_changed_callback = func
    end,
    --文字一行显示不下是否自动调整高度
    ['SetAutoHeight'] = function(self,autoheight)
        self.autoheight = not not autoheight
    end,
    ['SetText'] = function(self,text)
        self.text:SetText(text)
    end,
    ['Toggle'] = function(self)
        self.selected = not self.selected
        if self.bind_data and self.bind_key then
            self.bind_data[self.bind_key] = self.selected
        end
        if self.selected then
            self.check:Show()
        else
            self.check:Hide()
        end
    end
}

local function widget_OnEnter(self)
    local widget = self.obj
    widget.highlight:Show()
end

local function widget_OnLeave(self)
    local widget = self.obj
    widget.highlight:Hide()
end

local function widget_OnMouseDown(self)

end

local function widget_OnMouseUp(self)
    local widget = self.obj
    widget:Toggle()
end

local function widget_Resize(self)
    local w = self.obj
    local h = w.text:GetStringHeight()
    self:SetHeight(h+10)
end

function BFF_CheckBox(parent,label)
    local frame = CreateFrame('Button',nil,parent)
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", widget_OnEnter)
    frame:SetScript("OnLeave", widget_OnLeave)
    frame:SetScript("OnMouseDown", widget_OnMouseDown)
    frame:SetScript("OnMouseUp", widget_OnMouseUp)
    frame:SetScript("OnSizeChanged", widget_Resize)

    --frame:SetBackdrop(BFF_PaneBackdrop)
    --frame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    --frame:SetBackdropBorderColor(0.4, 0.9, 0.4)


    local checkbg = frame:CreateTexture(nil, "ARTWORK")
    checkbg:SetWidth(24)
    checkbg:SetHeight(24)
    checkbg:SetPoint("TOPLEFT")
    checkbg:SetTexture(130755) -- Interface\\Buttons\\UI-CheckBox-Up

    local check = frame:CreateTexture(nil, "OVERLAY")
    check:SetAllPoints(checkbg)
    check:SetTexture(130751) -- Interface\\Buttons\\UI-CheckBox-Check
    check:Hide()

    local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(130753) -- Interface\\Buttons\\UI-CheckBox-Highlight
    highlight:SetBlendMode("ADD")
    highlight:SetAllPoints(checkbg)
    highlight:Hide()

    local text = frame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetNonSpaceWrap(true)
    text:SetPoint('TOPLEFT',checkbg,'TOPRIGHT',0,0)
    text:SetHeight(18)  --必须设置一个初始高度，否则计算字符串所需高度时结果是一行的高度
    text:SetPoint('BOTTOMRIGHT')
    text:SetText(label or '')

    local widget = {
        frame = frame,
        text = text,
        check = check,
        highlight = highlight,
        selected = false
    }

    for m,f in pairs(methods) do
        widget[m] = f
    end

    setmetatable(widget,{__index = BFF_FrameBase})

    frame:HookScript('OnShow',function (self,...)
        local w = self.obj
        if w.bind_data and w.bind_key then
            w.selected = not not w.bind_data[w.bind_key]
            if w.selected then
                w.check:Show()
            else
                w.check:Hide()
            end
        end
    end)

    frame.obj = widget

    return widget
end
