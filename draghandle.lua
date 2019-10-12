
local draghandle_prototype = CreateFrame and CreateFrame('Frame',nil,UIParent) or {} --方便做语法错误检查
local draghandle_meta = { __index = draghandle_prototype }

local function onMouseDown(self,button)
    self.xpos = self:GetLeft()
    self.ypos = self:GetTop()
	if button == 'LeftButton' then
		self:StartMoving()
		self.isMoving = true
	end
end

local function onMouseUp(self,button)
	if self.isMoving then
		self:StopMovingOrSizing()
		self.isMoving = false
	end

    if not self.xpos or not self.ypos then
        return
    end

    local dx = self:GetLeft()-self.xpos
    local dy = self:GetTop()-self.ypos
    local dis = math.sqrt(dx*dx+dy*dy)

    if dis>2 then
        return
    end

    if button == 'LeftButton' then
        self:OnLeftButton()
    elseif button == 'RightButton' then
        self:OnRightButton()
    end
end

local function onMouseEnter(self)
	self.icon:SetAlpha(1.0)
	self.bg:SetAlpha(1.0)
    self:ShowTooltip(true)
end

local function onMouseLeave(self)
	self.icon:SetAlpha(0.5)
	self.bg:SetAlpha(0.5)
    self:ShowTooltip(false)
end

function draghandle_prototype:Init()
	self.bg = self:CreateTexture(nil,'BACKGROUND')
	self.bg:SetTexture('Interface/Buttons/UI-EmptySlot')
	self.bg:SetPoint("TOPLEFT", self, "TOPLEFT",0,0)
	self.bg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT",0,0)
	self.bg:SetAlpha(0.5)
	self.bg:Show()

	self.icon = self:CreateTexture(nil,'ARTWORK')
    if BFWC_Filter_SavedConfigs.enable then
        self.icon:SetTexture('Interface/AddOns/BFFilter/texture/minimap')
    else
        self.icon:SetTexture('Interface/AddOns/BFFilter/texture/pause')
    end
	self.icon:SetPoint("TOPLEFT", self, "TOPLEFT",12,-12)
	self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT",-12,12)
	self.icon:SetAlpha(0.5)
    self.icon:Show()

	self:SetMovable(true)
	self:EnableMouse(true)
    self:SetUserPlaced(true)
	self:SetScript('OnMouseDown',onMouseDown)
	self:SetScript('OnMouseUp',onMouseUp)
	self:SetScript('OnEnter',onMouseEnter)
	self:SetScript('OnLeave',onMouseLeave)
	self:SetSize(64,64)
    self.is_enable = 'x'
    self.tooltip = CreateFrame("GameTooltip", "BFWFDragHandleTooltip", UIParent, "GameTooltipTemplate")
end

local function getAnchors(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return "CENTER" end
    local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
    local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
    return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end


function draghandle_prototype:ShowTooltip(show)
    if not show then
        self.tooltip:Hide()
        return
    end

    self.tooltip:SetOwner(self, "ANCHOR_NONE")
    self.tooltip:SetPoint(getAnchors(self))
    GameTooltip_SetTitle(self.tooltip, '组队频道信息过滤')
    GameTooltip_AddInstructionLine(self.tooltip, '鼠标左键打开设置窗口')
    GameTooltip_AddInstructionLine(self.tooltip, '鼠标右键启用/禁用过滤器')
    if BFWC_Filter_SavedConfigs.enable then
        GameTooltip_AddInstructionLine(self.tooltip, '当前状态：已启用')
    else
        GameTooltip_AddInstructionLine(self.tooltip, '当前状态：已禁用')
    end
    self.tooltip:Show()
end

local cfgdlg = LibStub('AceConfigDialog-3.0')
function draghandle_prototype:OnLeftButton()
    cfgdlg:SetDefaultSize("BigFootWorldChannelFilter", 800, 600)
    cfgdlg:Open("BigFootWorldChannelFilter")
    cfgdlg.OpenFrames['BigFootWorldChannelFilter'].frame:SetFrameStrata("MEDIUM")
end

function draghandle_prototype:OnRightButton()
    bfwf_toggle_bf_filter()
end

local function onHide(self)
	if self.isMoving then
		self:StopMoving()
		self.isMoving = false
	end
end

--在插件加载时创建窗口，窗口位置缓存才生效
local hdl = setmetatable(CreateFrame('Frame','BFWFDragHandle',UIParent),draghandle_meta)
hdl:SetScript('OnHide',onHide)
hdl:Init()
hdl:SetPoint('TOPRIGHT',-150,-150)
hdl:Hide()

bfwf_show_drag_handle = function()
    hdl:Show()
end

bfwf_hide_drag_handle = function()
    hdl:Hide()
end

bfwf_update_drag_handle = function()
    if not hdl then
        return
    end

    if hdl.is_enable == BFWC_Filter_SavedConfigs.enable then
        return
    end

    hdl.is_enable = BFWC_Filter_SavedConfigs.enable
    if BFWC_Filter_SavedConfigs.enable then
        hdl.icon:SetTexture('Interface/AddOns/BFFilter/texture/minimap')
    else
        hdl.icon:SetTexture('Interface/AddOns/BFFilter/texture/pause')
    end
end
