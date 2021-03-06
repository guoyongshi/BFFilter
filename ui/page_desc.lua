
local function onPageResize(self,w,h)
    self:DoLayout(w,h)
end

function BFFPage_Desc(parent)
    local box = BFF_ListLayout(parent)
    local cb = BFF_CheckBox(UIParent,'在昨天D组的比赛结束之后，S9小组赛落下帷幕。LPL的IG以及FPX战队进入八强，值得一提的因为FPX是一号种子，IG是二号种子，所以不少观众都担心八强不会内战吧？还好抽签的结果不错，二支队五避免了内战，尽可能的让LPL保留冲击四强的火种。')
    cb:SetSize(500,32)

    box:AddChild(cb,true)

    local line = BFF_SepLine(parent,'华丽分隔线')
    box:AddChild(line,true)

    for i=1,30 do
        local btn = CreateFrame('Button',nil,parent,'UIPanelButtonTemplate')
        btn:SetSize(100,30)
        btn:SetText('按钮'..i)

        box:AddChild(btn)

        line = BFF_SepLine(parent,'华丽分隔线' .. i)
        box:AddChild(line,true)
    end

    box.OnPageResize = onPageResize
    return box
end

