
local Type, ItemType, Version = "ListBox", 'ListBoxItem', 26
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local CreateFrame, UIParent = CreateFrame, UIParent
local create_listbox_item

BFWC_ListBoxs = {}
local methods = {

    ["OnAcquire"] = function(self)
        self:superOnAcquire()
        self:SetDisabled(false)
        self:SetCallback('OnItemSelected',self.OnItemSelected)
        local found = false
        for _,o in ipairs(BFWC_ListBoxs) do
            if o == self then
                found = true
            end
        end

        if not found then
            table.insert(BFWC_ListBoxs,self)
        end
    end,

    ['OnRelease'] = function(self)
        for i=#BFWC_ListBoxs,1,-1 do
            if BFWC_ListBoxs[i] == self then
                table.remove(BFWC_ListBoxs,i)
            end
        end
    end,

    ['SetDisabled'] = function(self,dis)

    end,

    ['SetValue'] = function(self,val)

    end,

    --之前的children已经被清掉
    ['SetList'] = function(self,list)
        for _,it in ipairs(list) do
            local item = AceGUI:Create('ListBoxItem')
            item:SetItem(it.text,it,it.id==self.selitemid)
            self:realAddChild(item)
        end

        --TODO:滚到恰当位置，保持被选中元素的显示位置
        --value 0~1000
        --self.scrollbar:SetValue(500)
    end,
    ['SetLabel'] = function(self,label)
        self.name = label
    end,
    ['AddChild'] = function(self,child,beforeWidget)

    end,
    ['OnItemSelected'] = function(self,event,data)
        local itemid = data.id
        if itemid and itemid == self.selitemid then
            self.selitemid = nil
        else
            self.selitemid = itemid
        end

        for _,widget in pairs(self.children) do
            widget:SetSelected(widget.itemdata.id==self.selitemid)
        end

        if not self.selitemid then
            self:Fire('OnValueChanged',nil)
        else
            self:Fire('OnValueChanged',data)
        end
    end,

    ['LayoutFinished'] = function(self,width,height)
        if not self.frame:GetParent() or not self.frame:GetParent():GetParent() then
            return
        end
        local winh = math.floor(self.frame:GetParent():GetParent():GetHeight())
        local oldh = math.floor(self.frame:GetHeight())
        local newh = winh - 130
        if oldh == newh then
            return
        end

        self.frame:SetHeight(newh)
    end
}

local function Constructor()

    scroll = AceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    --scroll:SetHeight(350)
    scroll:SetAutoAdjustHeight(true)
    scroll:SetLayout('fill')
    local tx = scroll.frame:CreateTexture(nil, "BACKGROUND")
    --Interface\\MINIMAP\\TooltipBackdrop
    tx:SetTexture('Interface\\Tooltips\\CHATBUBBLE-BACKGROUND') -- Interface\\Tooltips\\UI-Tooltip-Background
    tx:SetPoint("TOPLEFT", 0, 0)
    tx:SetPoint("BOTTOMRIGHT", 0, 0)

    scroll.superOnAcquire = scroll.OnAcquire
    scroll.type = Type
    scroll.scroll = scroll
    scroll.realAddChild = scroll.AddChild
    scroll:FixScroll()
    for method,func in pairs(methods) do
        scroll[method] = func
    end

    return scroll
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

local item_methods = {
    ["OnAcquire"] = function(self)
        self:SetFullWidth(true)
        self.resizing = true
        self:SetHeight(36)
        self.resizing = nil
    end,

    ["SetText"] = function(self, text)
        self.label:SetText(text)
    end,

    ['SetSelected'] = function(self,sel)
        if self.selected == sel then
            return
        end
        self.selected = sel
        if sel then
            self.border:SetBackdropColor(0.3, 0.3, 0.3)
            self.border:SetBackdropBorderColor(0.8, 0.8, 0.8)
        else
            self.border:SetBackdropColor(0.1, 0.1, 0.1)
            self.border:SetBackdropBorderColor(0.4, 0.4, 0.4)
        end
    end,

    ['SetItem'] = function(self,text,data,hilight)
        self.label:SetText(text)
        self.itemdata = data
        self:SetSelected(hilight)
    end
}

local function OnItemClick(self,button)
    self.obj.parent:Fire('OnItemSelected',self.obj.itemdata)
end

local function ConstructorItem()
    local frame = CreateFrame("Button", nil, UIParent)
    frame:Hide()
    frame:SetScript('OnClick',OnItemClick)

    local itemBackdrop  = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 5, bottom = 3 }
    }

    local border = CreateFrame("Frame", nil, frame)
    border:SetPoint("TOPLEFT", 0, 0)
    border:SetPoint("BOTTOMRIGHT", 0, 0)
    border:SetBackdrop(itemBackdrop)
    border:SetBackdropColor(0.1, 0.1, 0.1)
    border:SetBackdropBorderColor(0.4, 0.4, 0.4)

    local label = border:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint('TOPLEFT',5,-5)
    label:SetPoint('BOTTOMRIGHT',-5,5)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("MIDDLE")

    local item = {
        label = label,
        frame = frame,
        border = border,
        type  = ItemType
    }
    for method, func in pairs(item_methods) do
        item[method] = func
    end

    return AceGUI:RegisterAsWidget(item)
end

AceGUI:RegisterWidgetType(ItemType, ConstructorItem, Version)
