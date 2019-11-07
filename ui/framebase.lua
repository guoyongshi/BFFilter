
BFF_PaneBackdrop  = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

BFF_FrameBase = {}

BFF_FrameBase.SetParent = function(self,parent)
    self.frame:SetParent(parent.frame or parent)
end

BFF_FrameBase.SetSize = function(self,w,h)
    self.frame:SetSize(w,h)
end

BFF_FrameBase.SetWidth = function(self,w)
    self.frame:SetWidth(w)
end

BFF_FrameBase.SetHeight = function(self,h)
    self.frame:SetHeight(h)
end

BFF_FrameBase.SetPoint = function(self,...)
    self.frame:SetPoint(...)
end

BFF_FrameBase.Show = function(self)
    self.shown = true
    self.frame:Show()
end

BFF_FrameBase.Hide = function(self)
    self.shown = false
    self.frame:Hide()
end

BFF_FrameBase.IsShown= function(self)
    return self.frame:IsShown()
end

BFF_FrameBase.SetFrameStrata = function(self,strata)
    self.frame:SetFrameStrata(strata)
end

BFF_FrameBase.SetCallback = function(self,event,target,func)
    self.events = self.events or {}
    self.events[event] = {
        target = target,
        func = func
    }
end

BFF_FrameBase.Fire = function (self,event,...)
    if not self.events then
        return
    end

    local hdl = self.events[event]
    if not hdl then
        return
    end

    hdl.func(hdl.target,...)
end

BFF_FrameBase.SetBackdrop = function(self,...)
    self.frame:SetBackdrop(...)
end

BFF_FrameBase.SetBackdropColor = function(self,...)
    self.frame:SetBackdropColor(...)
end

BFF_FrameBase.SetBackdropBorderColor = function(self,...)
    self.frame:SetBackdropBorderColor(...)
end

BFF_FrameBase.SetFullWidth=function(self,full)
    self.full_width = not not full
end