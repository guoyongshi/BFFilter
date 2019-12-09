
local timer = LibStub('AceTimer-3.0')
local last_show_message = {

}

local dirty = false
local _G = _G

local function get_whisper_frame()
    for i=1,NUM_CHAT_WINDOWS do
        local name,_=GetChatWindowInfo(i)
        if name == '私聊' or name == '私' or name == '密' then
            return ''..i
        end
    end
    return nil
end
local function add_msgto_chatframe(name,msg)
    local num = BFWC_Filter_SavedConfigs.white_to_chatframe_num or get_whisper_frame()
    if not num then
        return
    end
    local chatframe = _G['ChatFrame' .. num]
    if not chatframe then
        return
    end

    if not BFWC_Filter_SavedConfigs.white_to_chatframe_num then
        BFWC_Filter_SavedConfigs.white_to_chatframe_num = num
    end

    local color = '|c' .. BFWC_Filter_SavedConfigs.white_to_chatframe_color.hex
    local tlcolor = bfwf_player_color[name]
    if not tlcolor then
        tlcolor = '|cff11d72a'
    end

    if BFWC_Filter_SavedConfigs.use_class_color_for_text then
        color = tlcolor
    end
    local h,m=GetGameTime()
    local s = math.floor(GetTime()%60)
    local _msg = string.format('|cff189694%.2d:%.2d:%.2d|r',h,m,s)
    _msg = _msg ..'|Hplayer:' .. name .. '|h[' .. tlcolor .. name .. '|r]|h:'
    _msg = _msg .. color .. msg .. '|r'
    chatframe:AddMessage(_msg)

    if BFWC_Filter_SavedConfigs.new_msg_flash then
        if not chatframe:IsShown() then
            FCF_StartAlertFlash(chatframe)
        end
    end
end

local function to_short_name(fullname)
    local name
    local sp,_ = string.find(fullname,'-')
    if sp then
        name = string.sub(fullname,1,sp-1)
    else
        name = fullname
    end

    return name
end

local function add_msg_to_team_log(line,message,lmessage,playerguid,fullname,shortname,mymsg)
    local add_to_log = true
    for _,m in ipairs(bfwf_chat_team_log) do
        if m.line == line then
            add_to_log = false
            break
        end
    end

    if not mymsg and add_to_log and BFWC_Filter_SavedConfigs.filter_request_to_join and string.find(lmessage,'求组') then
        add_to_log = false
    end
    
    if BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid].dungeons_filter then
        local j = BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid].dungeons_filter;
        local dungeon = BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid].dungeons[j];
        local find = false;
        
        if not dungeon.keys then
            return;
        end
        for _, key in ipairs(dungeon.keys) do
            if string.find(string.lower(message), string.lower(key)) then
                find = true;
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
        local idx = 0
        for i = 1, #bfwf_chat_team_all_log do
            if bfwf_chat_team_all_log[i].playerid == playerguid then
                idx = i
                break
            end
        end
        if idx > 0 then
            bfwf_chat_team_all_log[idx] = data
        else
            table.insert(bfwf_chat_team_all_log, 1, data)
        end
	
	    if #bfwf_chat_team_all_log > 100 then
		    local oldid = 0
		    local oldtime = GetTime()
		    for i = 1, #bfwf_chat_team_all_log do
			    if bfwf_chat_team_all_log[i].time < oldtime then
				    oldid = i
				    oldtime = bfwf_chat_team_all_log[i].time
			    end
		    end
		    table.remove(bfwf_chat_team_all_log, oldix, 1)
	    end
        
        
        if not find then
            return
        end
    end



    if not add_to_log then
        return
    end

    if not shortname then
        shortname = to_short_name(fullname)
    end
    if BFWC_Filter_SavedConfigs.white_to_chatframe then
        if bfwf_player_color[shortname] or not timer then
            add_msgto_chatframe(shortname,message)
        else
            --职业颜色没缓存好，延迟0.3秒(filter在AddMessage之前执行)
            timer:ScheduleTimer(add_msgto_chatframe,0.3,shortname,message)
        end
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

local _chatframex_hook_addmessage = false

local function get_name_color(msg)
    local pos1,pos2=string.find(msg,'\124Hplayer:')
    if not pos1 or not pos2 then
        return
    end
    pos1,_ = string.find(msg,'%[',pos2)
    if not pos1 then
        return
    end
    local color = string.sub(msg,pos1+1,pos1+10)
    if not color or string.len(color) ~= 10 then
        return
    end
    pos2,_ = string.find(msg,'|r',pos1+11)
    if not pos2 then
        return
    end
    local name = string.sub(msg,pos1+11,pos2-1)
    if not name or string.len(name) == 0 then
        return
    end

    return name,color
end
local function __chatframex_new_addmessage(chatframe,msg,...)
    local name,color = get_name_color(msg)
    if name and color then
        bfwf_player_color[name] = color
    end

    if chatframe._chatframex_origin_addmessage then
        chatframe._chatframex_origin_addmessage(chatframe,msg,...)
    end
end

--返回true拦截，false放行
--同一条信息，过滤器会被多次调用，每个聊天标签一次(line相同)
--每条消息都有不同的行号(line)
--修改消息：return false,newmsg, from, a, b, c, d, e, chnum, chname, f,line,...
--fullname不一定能完整取到，有时服务器名取不到。即使同一个人，刚才能取到，现在不一定能取到
local last_line_number = 0
local last_return
local last_message
local last_trim = 0
local function chat_message_filter(chatFrame, event, message,...)
    if not BFWC_Filter_SavedConfigs.enable then
        return false
    end

    if not message or string.len(message)==0 then
        return false
    end

    --fullname, a, b, shortname, d, e, chnum, chname, f,line,playerguid,
    local fullname = select(1,...)
    local shortname = select(4,...)
    local chnum = select(7,...)
    local chname = select(8,...)
    local line = select(10,...)
    local playerguid = select(11,...)

    if line == last_line_number then
        if last_return then
            return true
        end
        if last_trim == 0 then
            return false
        end
        return false,last_message,...
    end
    last_return = false
    last_line_number = line
    last_trim = 0
    last_message = message

    --目前尚未发现playerguid取不到的情况
    if not playerguid then
        if not bfwf_g_data.playerguid_null then
            bfwf_g_data.playerguid_null = 1
        else
            bfwf_g_data.playerguid_null = bfwf_g_data.playerguid_null + 1
        end
        return false
    end

    if not chname then
        return false
    end

    --一些整合插件会把频道名过滤成简称
    --大脚：
    local filter_it = false
    local black_to_all = false  --黑名单过滤其它频道
    --大脚世界频道满员时会自动加入大脚世界频道

    if bfwf_start_whith(chname,'世') then
        filter_it = true
    elseif bfwf_start_whith(chname,'寻') then
        filter_it = true
    elseif bfwf_start_whith(chname,'大脚世界频道') then
        filter_it = true
    elseif bfwf_start_whith(chname,'寻求组队') then
        filter_it = true
    elseif BFWC_Filter_SavedConfigs.blacklist_enable and BFWC_Filter_SavedConfigs.blacklist_to_all_channel~=false then
        black_to_all = true
        filter_it = true
    end
    if not filter_it then
        return false
    end

    local mymsg = (playerguid == bfwf_g_data.myid)
    if mymsg and not bfwf_orging_team and not bfwf_waiting_job then
        return false
    end

    if not _chatframex_hook_addmessage then
        for i=1,10 do
            local cf = _G['ChatFrame'..i]
            if cf and cf.GetID and cf.AddMessage then
                local chns = {GetChatWindowChannels(cf:GetID() or 1)}
                for _,v in ipairs(chns) do
                    if bfwf_start_whith(v,'大脚世界频道') then
                        cf._chatframex_origin_addmessage = cf.AddMessage
                        cf.AddMessage = __chatframex_new_addmessage
                        _chatframex_hook_addmessage = true
                        break
                    end
                end
            end
        end
    end

    if BFWC_Filter_SavedConfigs.interval>0 then
        local now = GetTime()
        local last_time = last_show_message[playerguid] and last_show_message[playerguid].time or 0
        local last_line = last_show_message[playerguid] and last_show_message[playerguid].line or 0
        if (now-last_time) < BFWC_Filter_SavedConfigs.interval and line ~= last_line then
            last_return = true
            return true
        else
            last_show_message[playerguid] = { time = now, line = line}
        end
    end

    if BFWC_Filter_SavedConfigs.hide_enter_leave then
        if event == CHAT_MSG_CHANNEL_JOIN or event == CHAT_MSG_CHANNEL_LEAVE then
            last_return = true
            return true
        end
    end

    local lmessage = string.lower(message)
    if BFWC_Filter_SavedConfigs.blacklist_enable then
        for _,k in ipairs(BFWC_Filter_SavedConfigs_G.blacklist) do
            local lk = string.lower(k)
            if lk:len()>0 and string.find(lmessage,lk) then
                last_return = true
                return true
            end
        end
        if BFWC_Filter_SavedConfigs.not_sel_dungeons_as_blacklist then
            for _,d in ipairs(bfwf_dungeons) do
                if not BFWC_Filter_SavedConfigs.dungeons[d.name] then
                    for _,k in ipairs(d.keys) do
                        local lk = string.lower(k)
                        if lk:len()>0 and string.find(lmessage,lk) then
                            last_return = true
                            return true
                        end
                    end
                end
            end
        end
        if black_to_all then
            last_return = false
            return false
        end
    end


    local trim = 0
    local _msg = ''
    if not BFWC_Filter_SavedConfigs.remain_unchanged_msg then
        trim,_msg = bfwf_trim_message(message)
        last_trim = trim
        if trim>0 then
            if BFWC_Filter_SavedConfigs.enable_debug then
                message = _msg .. '|r|cffbb9e75[-' .. trim .. ']|r'
            else
                message = _msg
            end
            last_message = message
        end
    end


    for _,d in ipairs(bfwf_dungeons) do
        if BFWC_Filter_SavedConfigs.dungeons[d.name] then
            for _,k in ipairs(d.keys) do
                local lk = string.lower(k)
                if lk:len()>0 and string.find(lmessage,lk) then
                    add_msg_to_team_log(line,message,lmessage,playerguid,fullname,shortname,mymsg)
                    if trim>0 then
                        return false,message,...
                    end
                    return false
                end
            end
        end
    end

    for _, k in ipairs(BFWC_Filter_SavedConfigs.whitelist) do
        local lk = string.lower(k)
        if lk:len() > 0 and string.find(lmessage, lk) then
            add_msg_to_team_log(line, message, lmessage, playerguid, fullname, shortname,mymsg)
            if trim>0 then
                return false,message,...
            end
            return false
        end
    end

    if BFWC_Filter_SavedConfigs.whiteonly then
        last_return = true
        return true
    end

    if trim > 0 then
        return false,message,...
    end
    return false
end

local function say_yell_Filter(self,event,message,...)
    if BFWC_Filter_SavedConfigs.blacklist_to_all_channel==false then
        return
    end
    if BFWC_Filter_SavedConfigs.blacklist_enable then
        local lmessage = string.lower(message)
        for _,k in ipairs(BFWC_Filter_SavedConfigs_G.blacklist) do
            local lk = string.lower(k)
            if lk:len()>0 and string.find(lmessage,lk) then
                return true
            end
        end
    end
    return false
end
local function filter_proxy(...)
    local now = GetTime()
    local ret,msg,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13 = chat_message_filter(...)
    local dt = GetTime()-now
    if not msg then
        return ret
    end
    return ret,msg .. dt,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13
end

bfwf_chat_filter_init = function()
    if BFWC_Filter_SavedConfigs.enable_debug then
        ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL', filter_proxy)
    else
        ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL', chat_message_filter)
    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", say_yell_Filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", say_yell_Filter)

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
	cfgreg:NotifyChange(BFF_ADDON_NAME)
end

