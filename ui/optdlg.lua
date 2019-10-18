
local Type, Version = "BFFOptionsDialog", 26
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local function OnSelected(self,event,value)
    print(value)
end

local PaneBackdrop  = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}


AceGUI:RegisterLayout('Bfflayout',function(content,children)

end)
local methods = {
    ['OnSelected'] = function()
        for _,it in ipairs(self.items) do
            if it.selected then
                it:LockHighlight()
            else
                it:UnlockHighlight()
            end
        end
    end
}
local function Constructor()
    local win = AceGUI:Create('Frame')
    win.pages = {}
    win.frame:SetFrameStrata('MEDIUM')

    local items = {
        { name = 'Desc', text = '说明', page = AceGUI:Create('BFFPageDesc') },
        { name = 'Gen', text = '通用设置', page = AceGUI:Create('BFFPageGen') },
        { name = 'White', text = '白名单', page = AceGUI:Create('BFFPageWhite') },
        { name = 'Black', text = '黑名单', page = AceGUI:Create('BFFPageBlack') },
        { name = 'FindTeam', text = '我要找队伍', page = AceGUI:Create('BFFPageFindTeam') }
    }
    local flist  = AceGUI:Create('BFFListBox')
    win:AddChild(flist)
    flist:SetWidth(175)
    flist:SetPoint('TOPLEFT')
    flist:SetPoint('BOTTOMLEFT')

    for _,it in ipairs(items) do
        flist:AddItem(it.name,it.text)
    end

    local page = CreateFrame('Frame',nil,win.content)
    page:SetPoint('TOPLEFT',flist.frame,'TOPRIGHT',5,0)
    page:SetPoint('BOTTOMRIGHT',0,0)
    page:SetBackdrop(PaneBackdrop)
    page:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    page:SetBackdropBorderColor(0.4, 0.4, 0.4)

    for method,func in pairs(methods) do
        win[method] = func
    end
    return win
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
