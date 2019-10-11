

local Type, Version = "MacroButton", 26
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local pairs = pairs

local CreateFrame, UIParent = CreateFrame, UIParent


--宏通过SetText设置，字符串格式xxxxx|/macrotext
--
local methods = {
    ["OnAcquire"] = function(self)
        -- restore default values
        self:SetHeight(24)
        self:SetWidth(200)
        self:SetDisabled(false)
        self:SetAutoWidth(false)
        self:SetText()
    end,

    ["SetText"] = function(self, text)
        local pos,_ = string.find(text or '','|/')
        local label = text
        if pos then
            label = string.sub(text,1,pos-1)
            local macrotext = string.sub(text,pos+1)
            self.frame:SetAttribute('macrotext',macrotext)
        end
        self.text:SetText(label)
        if self.autoWidth then
            self:SetWidth(self.text:GetStringWidth() + 30)
        end
    end,

    ["SetAutoWidth"] = function(self, autoWidth)
        self.autoWidth = autoWidth
        if self.autoWidth then
            self:SetWidth(self.text:GetStringWidth() + 30)
        end
    end,

    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        if disabled then
            self.frame:Disable()
        else
            self.frame:Enable()
        end
    end,
    ['SetMacro'] = function(self,macro)
        self.frame:SetAttribute('macrotext',macro)
    end
}

local function Constructor()
    local name = "AceGUI30Button" .. AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate,UIPanelButtonTemplate")
    frame:SetAttribute('type','macro')
    frame:Hide()

    local text = frame:GetFontString()
    text:ClearAllPoints()
    text:SetPoint("TOPLEFT", 15, -1)
    text:SetPoint("BOTTOMRIGHT", -15, 1)
    text:SetJustifyV("MIDDLE")

    local widget = {
        text  = text,
        frame = frame,
        type  = Type
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
