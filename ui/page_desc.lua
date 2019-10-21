
function BFFPage_Desc(parent)
    local box = BFF_ListLayout(parent)
    local cb = BFF_CheckBox(UIParent,'名字要长。。。。。。。。名字要长。。。。。。。。名字要长。。。。。。。。\n名字要长。。。。。。。。名字要长。。。。。。。。名字要长。。。。。。。。')

    box:AddChild(cb)
    for i=1,30 do
        local btn = CreateFrame('Button',nil,UIParent,'UIPanelButtonTemplate')
        btn:SetSize(100,30)
        btn:SetText('按钮'..i)

        box:AddChild(btn)
    end

    return box
end

