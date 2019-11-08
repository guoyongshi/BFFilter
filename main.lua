
--https://github.com/tomrus88/BlizzardInterfaceCode
local BFFilter=LibStub("AceAddon-3.0"):NewAddon(BFF_ADDON_NAME, "AceConsole-3.0","AceTimer-3.0")

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

    if BFWC_Filter_SavedConfigs.use_class_color then
        SetCVar("chatClassColorOverride", "0")
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

    bfwf_send_team_create_msg()
    bfwf_send_wanted_job_msg()
end

local bf_channel_num
local try_auto_join = 0
function BFFilter:CheckBigFootChannel()
    local channels = { GetChannelList() }
    for i,k in ipairs(channels) do
        if bfwf_start_whith(k,'大脚世界频道') then
            bf_channel_num = channels[i-1]
            bfwf_big_foot_world_channel_joined = true
            return
        end
    end

    bfwf_big_foot_world_channel_joined = false
    if BFWC_Filter_SavedConfigs.autojoin_bigfoot then
        if try_auto_join>3 then
            --大脚世界频道的有可能被捣乱加上密码
            BFWC_Filter_SavedConfigs.autojoin_bigfoot = false
            try_auto_join = 0
            return
        end
        local chatframe = DEFAULT_CHAT_FRAME
        if not chatframe then
            chatframe = ChatFrame1
        end
        local id
        if chatframe and chatframe.GetID then
            id = ChatFrame1:GetID()
        end
        try_auto_join = try_auto_join + 1
        JoinPermanentChannel('大脚世界频道',nil,id)
        ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, '大脚世界频道')
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

--SendChatMessage不能随便设置文字颜色，物品、技能等链接可以带颜色，但链接的颜色和名称
--不能改，改了就会变成普通文字
bfwf_make_team_create_msg = function(avoid_kick)
    local msg = ''
    local idx = BFWC_Filter_SavedConfigs.last_orgteam
    if not idx then
        return ''
    end

    local orig_msg = BFWC_Filter_SavedConfigs.last_orgteam_note
    if not orig_msg or string.len(orig_msg)==0 then
        return ''
    end

    if avoid_kick then
        local ws = bff_msg_split(BFWC_Filter_SavedConfigs.last_orgteam_note)
        local cs = {'+','-','~','.','_','='}
        local pos = math.random(1,#ws+1)
        table.insert(ws,pos,' ')
        table.insert(ws,cs[math.random(1,#cs)])
        orig_msg = table.concat(ws)
    end

    if idx==1 then
        return orig_msg
    end
    if idx==2 then
        return '任务队,' .. orig_msg
    end

    local pos,_ = string.find(bfwf_dungeons[idx-2].name,'%(')
    local name
    if pos then
        name = string.sub(bfwf_dungeons[idx-2].name,1,pos-1)
    else
        name = bfwf_dungeons[idx-2].name
    end

    local keys = bfwf_dungeons[idx-2].keys
    if keys and keys[1] and keys[1]~=name then
        name = name .. ',' .. string.upper(keys[1])
    end

    msg = '[' .. name .. '],' .. orig_msg
    return msg
end

bfwf_make_wanted_job_msg = function(avoid_kick)
    local msg = ''
    local idx = BFWC_Filter_SavedConfigs.last_job
    if not idx then
        return ''
    end

    local orig_msg = BFWC_Filter_SavedConfigs.last_job_note
    if not orig_msg or string.len(orig_msg)==0 then
        return ''
    end

    if avoid_kick then
        local ws = bff_msg_split(BFWC_Filter_SavedConfigs.last_job_note)
        local cs = {'+','-','~','.','_','='}
        local pos = math.random(1,#ws+1)
        table.insert(ws,pos,' ')
        table.insert(ws,cs[math.random(1,#cs)])
        orig_msg = table.concat(ws)
    end

    if idx==1 then
        return orig_msg
    end
    if idx==2 then
        return '任务队,' .. orig_msg
    end

    local pos,_ = string.find(bfwf_dungeons[idx-2].name,'%(')
    local name
    if pos then
        name = string.sub(bfwf_dungeons[idx-2].name,1,pos-1)
    else
        name = bfwf_dungeons[idx-2].name
    end
    local keys = bfwf_dungeons[idx-2].keys
    if keys and keys[1] and keys[1]~=name then
        name = name .. ',' .. string.upper(keys[1])
    end

    msg = '[' .. name .. '],' .. orig_msg
    return msg
end

local last_team_msg_time = 0
local last_wanted_job_time = 0

bfwf_finish_org_team = function()
    if not bfwf_orging_team then
        return
    end
    bfwf_orging_team = false
    DEFAULT_CHAT_FRAME:AddMessage('|cff0099ff[BFFilter]|r|cffffd100组队完成！！！！！！|r')
    local msg = bfwf_make_team_create_msg(true)
    if string.len(msg or '')==0 then
        return
    end
    if not bf_channel_num then
        return
    end
    msg = '[已满员]'..msg
    SendChatMessage(msg,'CHANNEL',nil,bf_channel_num)
end

bfwf_send_team_create_msg = function()

    if not bfwf_orging_team then
        return
    end

    local nmem = GetNumGroupMembers()
    if nmem>=bfwf_org_team_count and BFWC_Filter_SavedConfigs.auto_fin_org_team~='no' then
        bfwf_finish_org_team()
        return
    end

    local msg = bfwf_make_team_create_msg(true)
    if string.len(msg or '')==0 then
        return
    end

    if not bf_channel_num then
        return
    end
    local now = GetTime()
    local dt = now-last_team_msg_time
    if dt<15 then
        return
    end
    last_team_msg_time = now

    SendChatMessage(msg,'CHANNEL',nil,bf_channel_num)
end

bfwf_send_wanted_job_msg = function()

    if bfwf_orging_team then
        return
    end
    if not bfwf_waiting_job then
        return
    end

    if GetNumGroupMembers()>0 then
        bfwf_waiting_job = false
        return
    end

    local msg = bfwf_make_wanted_job_msg(true)
    if string.len(msg or '')==0 then
        return
    end

    if not bf_channel_num then
        return
    end
    local now = GetTime()
    local dt = now-last_wanted_job_time
    if dt<15 then
        return
    end
    last_wanted_job_time = now

    SendChatMessage(msg,'CHANNEL',nil,bf_channel_num)
end
