
local BFFilter=LibStub("AceAddon-3.0"):NewAddon("BigFootWorldChannelFilter", "AceConsole-3.0","AceTimer-3.0")

local function update_player_info()
    local _, class, _ = UnitClass('player')
    bfwf_player.class=class
    bfwf_player.classes=1   --单一职业
    if class=='SHAMAN' or class=='PRIEST' or class=='WARRIOR' then
        bfwf_player.classes = 2 --双职业
    elseif class == 'DRUID' or class=='PALADIN' then
        bfwf_player.classes = 3  --三职业
    end
end

--插件加载完成
function BFFilter:OnInitialize()
    self:RegisterChatCommand("bff", "OnCommand")

    bfwf_configs_init()

    bfwf_minimap_button_init()
    bfwf_chat_filter_init()
end

--用户登录完成
function BFFilter:OnEnable()
    if not self.timer then
        self.timer = self:ScheduleRepeatingTimer("OnCheck", 1)
    end

    if not bfwf_g_data.myid then
        bfwf_g_data.myid,_ = UnitGUID('player')
    end

    bfwf_player.level = UnitLevel('player')

    if not BFWC_Filter_SavedConfigs.player then
        BFWC_Filter_SavedConfigs.player = {}
    end
    if bfwf_g_data.myid and not BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid] then
        BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid] = {}
    end

    update_player_info()

    self:OnLevelUp()

    if BFWC_Filter_SavedConfigs.show_drag_handle then
        bfwf_show_drag_handle()
    end
end

function BFFilter:OnDisable()
    if self.timer then
        self:CancelTimer(self.timer)
        self.timer = nil
    end
end

function BFFilter:OnCommand(input)
    bfwf_toggle_config_dialog()
end

local last_level = 0
function BFFilter:OnCheck()
    if not bfwf_player.class then
        update_player_info()
    end

    if not bfwf_g_data.myid then
        bfwf_g_data.myid,_ = UnitGUID('player')
    end

    bfwf_player.level = UnitLevel('player') or bfwf_player.level

    if bfwf_player.level>last_level then
        self:OnLevelUp()
    end
    self:CheckBigFootChannel()

    if not bfwf_g_data.myid then
        bfwf_g_data.myid = UnitGUID('player')
    end

    bfwf_update_config_dialog()
end

function BFFilter:CheckBigFootChannel()
    local channels = { GetChannelList() }
    for _,k in ipairs(channels) do
        if k == '大脚世界频道' then
            bfwf_big_foot_world_channel_joined = true
            return
        end
    end

    bfwf_big_foot_world_channel_joined = false
    if BFWC_Filter_SavedConfigs.autojoin_bigfoot then
        JoinChannelByName('大脚世界频道')
    end
end

bfwf_update_dungeons_filter = function()
    if BFWC_Filter_SavedConfigs.auto_filter_by_level then
        local lv = bfwf_player.level
        for _,d in ipairs(bfwf_dungeons) do
            if lv>=d.lmin and lv<= d.lmax then
                BFWC_Filter_SavedConfigs.dungeons[d.name] = true
            else
                BFWC_Filter_SavedConfigs.dungeons[d.name] = false
            end
        end
    end
end
function BFFilter:OnLevelUp()
    last_level = bfwf_player.level
    bfwf_update_dungeons_filter()
end