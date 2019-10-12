
local last_show_message = {

}

--消息瘦身
local function reduce_message(msg)
    local last_char = 0
end

local dirty = false

local function add_msg_to_team_log(line,message,playerguid,fullname,shortname)
    local add_to_log = true
    for _,m in ipairs(bfwf_chat_team_log) do
        if m.line == line then
            add_to_log = false
            break
        end
    end

    if add_to_log and BFWC_Filter_SavedConfigs.filter_request_to_join and string.find(lmessage,'求组') then
        add_to_log = false
    end

    if not add_to_log then
        return
    end

    local idx = 0
    dirty = true
    for i = 1, #bfwf_chat_team_log do
        if bfwf_chat_team_log[i].playerid == playerguid then
            idx = i
            break
        end
    end
    local data = {
        line = line,
        playerid = playerguid,
        fullname = fullname,
        name = shortname,
        time = GetTime(),
        text = message
    }
    if idx > 0 then
        bfwf_chat_team_log[idx] = data
    else
        table.insert(bfwf_chat_team_log, 1, data)
    end

    if #bfwf_chat_team_log > 100 then
        local oldid = 0
        local oldtime = GetTime()
        for i = 1, #bfwf_chat_team_log do
            if bfwf_chat_team_log[i].time < oldtime then
                oldid = i
                oldtime = bfwf_chat_team_log[i].time
            end
        end
        table.remove(bfwf_chat_team_log, oldix, 1)
    end
end
--返回true拦截，false放行
--同一条信息，过滤器会被多次调用，每个聊天标签一次(line相同)
--每条消息都有不同的行号(line)
--修改消息：return false,newmsg, from, a, b, c, d, e, chnum, chname, f,line,...
--fullname不一定能完整取到，有时服务器名取不到。即使同一个人，刚才能取到，现在不一定能取到
local function chat_message_filter(chatFrame, event, message, fullname, a, b, shortname, d, e, chnum, chname, f,line,playerguid,...)
    if not BFWC_Filter_SavedConfigs.enable then
        return false
    end

    if playerguid == bfwf_g_data.myid then
        return false
    end

    --目前尚未发现playerguid取不到的情况
    if not playerguid then
        if not bfwf_g_data.playerguid_null then
            bfwf_g_data.playerguid_null = 1
        else
            bfwf_g_data.playerguid_null = bfwf_g_data.playerguid_null + 1
        end
        return false
    end

    if not BFWC_Filter_SavedConfigs.blacklist_enable and not BFWC_Filter_SavedConfigs.whitelist_enable then
        return false
    end

    if chname ~= '大脚世界频道' and chname ~= '寻求组队' then
        return false
    end

    if BFWC_Filter_SavedConfigs.interval>0 then
        local now = GetTime()
        local last_time = last_show_message[playerguid] and last_show_message[playerguid].time or 0
        local last_line = last_show_message[playerguid] and last_show_message[playerguid].line or 0
        if (now-last_time) < BFWC_Filter_SavedConfigs.interval and line ~= last_line then
            return true
        else
            last_show_message[playerguid] = { time = now, line = line}
        end
    end

    if BFWC_Filter_SavedConfigs.hide_enter_leave then
        if event == CHAT_MSG_CHANNEL_JOIN or event == CHAT_MSG_CHANNEL_LEAVE then
            return true
        end
    end

    local lmessage = string.lower(message)
    if BFWC_Filter_SavedConfigs.blacklist_enable then
        for _,k in ipairs(BFWC_Filter_SavedConfigs.blacklist) do
            local lk = string.lower(k)
            if lk:len()>0 and string.find(lmessage,lk) then
                return true
            end
        end

        if not BFWC_Filter_SavedConfigs.whitelist_enable then
            return false
        end
    end

    for _,d in ipairs(bfwf_dungeons) do
        if BFWC_Filter_SavedConfigs.dungeons[d.name] then
            for _,k in ipairs(d.keys) do
                local lk = string.lower(k)
                if lk:len()>0 and string.find(lmessage,lk) then
                    add_msg_to_team_log(line,message,playerguid,fullname,shortname)
                    return false
                end
            end
        end
    end

    if BFWC_Filter_SavedConfigs.whitelist_enable then
        for _,k in ipairs(BFWC_Filter_SavedConfigs.whitelist) do
            local lk = string.lower(k)
            if lk:len()>0 and string.find(lmessage,lk) then
                add_msg_to_team_log(line,message,playerguid,fullname,shortname)
                return false
            end
        end
    end

    return false
end

bfwf_chat_filter_init = function()
    ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL', chat_message_filter)
    bfwf_update_icon()
end

bfwf_toggle_bf_filter = function()
    BFWC_Filter_SavedConfigs.enable = not BFWC_Filter_SavedConfigs.enable
    bfwf_update_icon()
end

local cfgreg = LibStub("AceConfigRegistry-3.0")
local acegui = LibStub("AceGUI-3.0")
bfwf_update_config_dialog = function()
	if not dirty then
		return
	end
	if not cfgreg then
		return
	end
    if acegui.FocusedWidget then
        return
    end
    local shown = false
    for _,o in ipairs(BFWC_ListBoxs) do
        if o.name == '最近的喊话组队记录' and o:IsShown() then
            shown = true
        end
    end

    if not shown then
        return
    end
	dirty = false
	cfgreg:NotifyChange('BigFootWorldChannelFilter')
end

