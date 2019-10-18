


local Type, Version = "BFFListBox", 26
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local CreateFrame, UIParent = CreateFrame, UIParent

local function Item_OnClick(btn)
    local self = btn.obj
    self:SelectItem(btn.unikey)
end

local methods = {
    ["OnAcquire"] = function(self)

    end,
    ['AddItem'] = function(self,key,label)
        for _,it in ipairs(self.items) do
            if it.unikey == key then
                return
            end
        end
        local n = AceGUI:GetNextWidgetNum('ListBoxItem')
        local btn = CreateFrame('Button','BFFListBoxItem'.. n,self.frame,'OptionsListButtonTemplate')
        local idx = #(self.items)
        btn:SetPoint('TOPLEFT',7,-7-(idx*20))
        btn:SetPoint('RIGHT',-15,0)
        btn:SetHeight(20)
        btn:SetText(label)
        btn:SetScript("OnClick",Item_OnClick)
        btn.obj = self
        btn.unikey = key
        table.insert(self.items,btn)
    end,
    ['SelectItem'] = function(self,key)
        for _,it in pairs(self.items) do
            if it.unikey == key then
                if not it.selected then
                    it.selected = true
                    it:LockHighlight()
                end
            else
                if it.selected then
                    it.selected = false
                    it:UnlockHighlight()
                end
            end
        end
    end
}

local PaneBackdrop  = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local function Constructor()
    local frame = CreateFrame('Frame')
    frame:Hide()
    frame:EnableMouseWheel(true)
    frame:SetBackdrop(PaneBackdrop)
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4)

    local widget = {
        frame = frame,
        type = Type,
        items = {}
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)


