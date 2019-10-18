

local Type, Version = "BFFPageFindTeam", 26
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local CreateFrame, UIParent = CreateFrame, UIParent

local function Constructor()
    local page = AceGUI:Create('SimpleGroup')


    return page
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

