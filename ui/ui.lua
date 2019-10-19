
local dlg
function bfwf_toggle_options_dlg()
    if dlg and dlg:IsShown() then
        dlg:Hide()
    else
        if not dlg then
            dlg = BFFOptionsDialog()
        end
        dlg:SetTitle('组队频道信息过滤器')
        dlg:Show()
    end
end

