
local methods = {
    ['OnItemSelected'] = function(self,value)
        for _,it in ipairs(self.pages) do
            if it.name == value then
                it.page.selected = true
                it.page:Show()
            else
                it.page.selected = false
                it.page:Hide()
            end
        end
    end,
    ['ShowPage'] = function(self,value)
        self.lb:SelectItem(value)
        self:OnItemSelected('',value)
    end,
    ['SetTitle'] = function(self,title)
        self.titletext:SetText(title)
        self.titlebg:SetWidth((self.titletext:GetWidth() or 0) + 10)
    end
}

local FrameBackdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
}

local function Title_OnMouseDown(frame)
    frame:GetParent():StartMoving()
end

local function MoverSizer_OnMouseUp(mover)
    local frame = mover:GetParent()
    frame:StopMovingOrSizing()
end

local function create_title(dlg)
    local titlebg = dlg:CreateTexture(nil, "OVERLAY")
    titlebg:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
    titlebg:SetTexCoord(0.31, 0.67, 0, 0.63)
    titlebg:SetPoint("TOP", 0, 12)
    titlebg:SetWidth(100)
    titlebg:SetHeight(40)

    local title = CreateFrame("Frame", nil, dlg)
    title:EnableMouse(true)
    title:SetScript("OnMouseDown", Title_OnMouseDown)
    title:SetScript("OnMouseUp", MoverSizer_OnMouseUp)
    title:SetAllPoints(titlebg)

    local titletext = title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titletext:SetPoint("TOP", titlebg, "TOP", 0, -14)
    dlg.titletext = titletext

    local titlebg_l = dlg:CreateTexture(nil, "OVERLAY")
    titlebg_l:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
    titlebg_l:SetTexCoord(0.21, 0.31, 0, 0.63)
    titlebg_l:SetPoint("RIGHT", titlebg, "LEFT")
    titlebg_l:SetWidth(30)
    titlebg_l:SetHeight(40)

    local titlebg_r = dlg:CreateTexture(nil, "OVERLAY")
    titlebg_r:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
    titlebg_r:SetTexCoord(0.67, 0.77, 0, 0.63)
    titlebg_r:SetPoint("LEFT", titlebg, "RIGHT")
    titlebg_r:SetWidth(30)
    titlebg_r:SetHeight(40)

    return titletext,titlebg
end

local function SizerSE_OnMouseDown(frame)
    frame:GetParent():StartSizing("BOTTOMRIGHT")
end

local function close_dialog(btn)
    btn.obj.frame:Hide()
end

local function create_close_button(dlg)
    local deco = CreateFrame("Frame", nil, dlg)
    deco:SetSize(17, 40)

    local bg1 = deco:CreateTexture(nil, "BACKGROUND")
    bg1:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    bg1:SetTexCoord(0.31, 0.67, 0, 0.63)
    bg1:SetAllPoints(deco)

    local bg2 = deco:CreateTexture(nil, "BACKGROUND")
    bg2:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    bg2:SetTexCoord(0.235, 0.275, 0, 0.63)
    bg2:SetPoint("RIGHT", bg1, "LEFT")
    bg2:SetSize(10, 40)

    local bg3 = deco:CreateTexture(nil, "BACKGROUND")
    bg3:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    bg3:SetTexCoord(0.72, 0.76, 0, 0.63)
    bg3:SetPoint("LEFT", bg1, "RIGHT")
    bg3:SetSize(10, 40)

    deco:SetPoint("TOPRIGHT", -30, 12)

    local close_button = CreateFrame("BUTTON", nil, deco, "UIPanelCloseButton")
    close_button:SetPoint("CENTER", deco, "CENTER", 1, -1)
    close_button:SetScript("OnClick", close_dialog)

    local closebutton = CreateFrame('Button',nil,dlg,'UIPanelButtonTemplate')
    closebutton:SetScript("OnClick", close_dialog)
    closebutton:SetPoint("BOTTOMRIGHT", -27, 17)
    closebutton:SetHeight(20)
    closebutton:SetWidth(100)
    closebutton:SetText(CLOSE or '关闭')

    return close_button,closebutton
end

local function create_sizzer(dlg)
    local sizer_se = CreateFrame("Frame", nil, dlg)
    sizer_se:SetPoint("BOTTOMRIGHT")
    sizer_se:SetWidth(25)
    sizer_se:SetHeight(25)
    sizer_se:EnableMouse()
    sizer_se:SetScript("OnMouseDown",SizerSE_OnMouseDown)
    sizer_se:SetScript("OnMouseUp", MoverSizer_OnMouseUp)

    local line1 = sizer_se:CreateTexture(nil, "BACKGROUND")
    line1:SetWidth(14)
    line1:SetHeight(14)
    line1:SetPoint("BOTTOMRIGHT", -8, 8)
    line1:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
    local x = 0.1 * 14/17
    line1:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)

    local line2 = sizer_se:CreateTexture(nil, "BACKGROUND")
    line2:SetWidth(8)
    line2:SetHeight(8)
    line2:SetPoint("BOTTOMRIGHT", -8, 8)
    line2:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
    local x = 0.1 * 8/17
    line2:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)
end

local function onFrameSizeChanged(container)
    local w = container:GetWidth()
    local h = container:GetHeight()
    if not w or not h then
        return
    end

    for _,page in ipairs(container.obj.pages) do
        if page.page.selected and page.page.OnPageResize then
            page.page:OnPageResize(w,h)
        end
    end
end
local function create_page_container(dlg,lb)
    local pagecontainer = CreateFrame('Frame',nil,dlg)
    pagecontainer:SetPoint('TOPLEFT',lb.frame,'TOPRIGHT',0,0)
    pagecontainer:SetPoint('BOTTOMRIGHT',dlg,'BOTTOMRIGHT',-15,42)
    pagecontainer:SetBackdrop(BFF_PaneBackdrop)
    pagecontainer:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    pagecontainer:SetBackdropBorderColor(0.4, 0.4, 0.4)

    pagecontainer:SetScript('OnSizeChanged',onFrameSizeChanged)

    return pagecontainer
end

local function create_status_bar(dlg)
    local statusbg = CreateFrame("Button", nil, dlg)
    statusbg:SetPoint("BOTTOMLEFT", 15, 15)
    statusbg:SetPoint("BOTTOMRIGHT", -132, 15)
    statusbg:SetHeight(24)
    statusbg:SetBackdrop(BFF_PaneBackdrop)
    statusbg:SetBackdropColor(0.1,0.1,0.1)
    statusbg:SetBackdropBorderColor(0.4,0.4,0.4)

    local statustext = statusbg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statustext:SetPoint("TOPLEFT", 7, -2)
    statustext:SetPoint("BOTTOMRIGHT", -7, 2)
    statustext:SetHeight(20)
    statustext:SetJustifyH("LEFT")
    statustext:SetText("")
    return statustext
end

local function create_pages(pagecontainer,lb)
    local pages = {
        { name = 'Desc', text = '说明', page = BFFPage_Desc(pagecontainer) },
        { name = 'Gen', text = '通用设置', page = BFFPage_Gen(pagecontainer) },
        { name = 'White', text = '白名单', page = BFFPage_White(pagecontainer) },
        { name = 'Black', text = '黑名单', page = BFFPage_Black(pagecontainer) },
        { name = 'FindTeam', text = '找队伍', page = BFFPage_FindTeam(pagecontainer) }
    }

    for _,it in ipairs(pages) do
        lb:AddItem(it.name,it.text)
        it.page:SetPoint('TOPLEFT',5,-5)
        it.page:SetPoint('BOTTOMRIGHT',0,10)
        it.page:Hide()
    end

    return pages
end

function BFF_OptionsDialog()
    local dlg = CreateFrame('Frame',nil,UIParent)
    dlg:SetPoint('CENTER')
    dlg:SetSize(900,600)
    dlg:EnableMouse(true)
    dlg:SetMovable(true)
    dlg:SetResizable(true)
    dlg:SetFrameStrata("MEDIUM")
    dlg:SetBackdrop(FrameBackdrop)
    dlg:SetBackdropColor(0, 0, 0, 1)
    dlg:SetMinResize(400, 200)
    local titletext,titlebg = create_title(dlg)
    create_sizzer(dlg)
    local close1,close2=create_close_button(dlg)

    local lb = BFF_ListBox(dlg)
    lb:SetPoint('TOPLEFT',15,-35)
    lb:SetPoint('BOTTOMLEFT',15,42)
    lb:SetWidth(175)

    local pagecontainer = create_page_container(dlg,lb)

    local statustext = create_status_bar(dlg)

    local pages = create_pages(pagecontainer,lb)

    local widget = {
        frame = dlg,
        listbox = lb,
        pages = pages,
        titletext = titletext,
        statustext = statustext,
        titlebg = titlebg
    }

    for m,f in pairs(methods) do
        widget[m] = f
    end

    lb:SetCallback('OnItemSelected',widget,widget.OnItemSelected)
    setmetatable(widget,{__index = BFF_FrameBase})

    close1.obj = widget
    close2.obj = widget
    pagecontainer.obj = widget

    return widget
end

