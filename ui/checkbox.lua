

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
    end
}

function BFF_CheckBox(parent,label)
    local cbx = CreateFrame('CheckButton',nil,parent,'InterfaceOptionsCheckButtonTemplate')
    cbx.Text:SetText(label)

    local widget = {
        frame = cbx,
        selected = false
    }

    for m,f in pairs(methods) do
        widget[m] = f
    end

    setmetatable(widget,{__index = BFF_FrameBase})

    cbx:HookScript('OnShow',function (self,...)
        local w = self.obj
        if w.bind_data and w.bind_key then
            w.selected = not not w.bind_data[w.bind_key]
            self:SetChecked(w.selected)
        end
    end)

    cbx:HookScript('OnClick',function (self,...)
        local w = self.obj
        local ck = self:GetChecked()
        if w.bind_data and w.bind_key then
            w.bind_data[w.bind_key] = ck
        end
        if ck ~= w.selected and w.on_changed_callback then
            w.selected = ck
            w:on_changed_callback(ck)
        end
    end)

    cbx.obj = widget

    return widget
end
