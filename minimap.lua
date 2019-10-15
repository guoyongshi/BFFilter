
local minimap_icon_texture
local cfgdlg = LibStub("AceConfigDialog-3.0")
local LDBCfg = LibStub("LibDataBroker-1.1"):NewDataObject("GYSGroupChannelFilter", {
    type = "data source",
    text = "SpellCastingHelper",
    icon = "Interface\\Icons\\INV_Misc_MissileSmall_Green",
    OnClick = function(self,button)
        if button == 'LeftButton' then
            bfwf_toggle_config_dialog()
        elseif button == 'RightButton' then
            bfwf_toggle_bf_filter()
        end
    end,
    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then
            return
        end

        GameTooltip_SetTitle(tooltip, '组队频道信息过滤')
        GameTooltip_AddInstructionLine(tooltip, '鼠标左键打开设置窗口')
        GameTooltip_AddInstructionLine(tooltip, '鼠标右键启用/禁用过滤器')
        if BFWC_Filter_SavedConfigs.enable then
            GameTooltip_AddInstructionLine(tooltip, '当前状态：已启用')
        else
            GameTooltip_AddInstructionLine(tooltip, '当前状态：已禁用')
        end

    end
})

bfwf_minimap_button_init = function()
    local dbicon = LibStub("LibDBIcon-1.0")
    if not dbicon then
        return
    end
    dbicon:Register("GYSGroupChannelFilter", LDBCfg, BFWC_Filter_SavedConfigs.minimap)
    if not dbicon:GetMinimapButton('GYSGroupChannelFilter') then
        minimap_icon_texture = nil
        return
    end
    minimap_icon_texture = dbicon:GetMinimapButton('GYSGroupChannelFilter').icon
end

bfwf_update_minimap_icon = function()
    if not minimap_icon_texture then
        return
    end
    if BFWC_Filter_SavedConfigs.enable then
        minimap_icon_texture:SetTexture('Interface\\AddOns\\BFFilter\\texture\\minimap')
    else
        minimap_icon_texture:SetTexture('Interface\\AddOns\\BFFilter\\texture\\pause')
    end
end