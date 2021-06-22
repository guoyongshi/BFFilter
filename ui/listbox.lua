
local CreateFrame, UIParent = CreateFrame, UIParent

local function Item_OnClick(self)
    self.obj:SelectItem(self.unikey)
end

local methods = {
    ['AddItem'] = function(self,key,label)
        for _,it in ipairs(self.items) do
            if it.unikey == key then
                return
            end
        end

        local idx = #(self.items)
        local item = CreateFrame('Button','BFFListBoxItem'.. idx,self.frame,'OptionsListButtonTemplate')

        item:SetPoint('TOPLEFT',7,-7-(idx*20))
        item:SetPoint('RIGHT',-15,0)
        item:SetHeight(20)
        item:SetText(label)
        item:SetScript("OnClick",Item_OnClick)
        item.unikey = key
        item.obj = self
        table.insert(self.items,item)
    end,
    ['SelectItem'] = function(self,key)
        local unikey = nil
        for _,it in pairs(self.items) do
            if it.unikey == key then
                if not it.selected then
                    unikey = it.unikey
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
        if unikey then
            self:Fire('OnItemSelected',unikey)
        end
    end
}

function BFF_ListBox(parent)
    local frame = CreateFrame('Frame',nil,parent or UIParent,BackdropTemplateMixin and "BackdropTemplate")
    frame:EnableMouseWheel(true)
    frame:SetBackdrop(BFF_PaneBackdrop)
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4)

    local widget = {
        items = {},
        frame = frame
    }
    for m,f in pairs(methods) do
        widget[m] = f
    end

    setmetatable(widget,{__index = BFF_FrameBase})

    return widget
end
