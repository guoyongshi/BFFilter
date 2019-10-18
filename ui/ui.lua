
local gui = LibStub('AceGUI-3.0')
local dlg
function bfwf_toggle_options_dlg()
    if dlg and dlg:IsShown() then
        dlg:Hide()
        dlg = nil
    else
        if not dlg then
            dlg = gui:Create('BFFOptionsDialog')
        end
        dlg:SetLayout('Bfflayout')  --放构造里会被冲掉
        dlg:Show()
    end
end

