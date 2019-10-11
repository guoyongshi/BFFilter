
local function whitelist_init()
    if BFWC_Filter_SavedConfigs.whitelist then
       return
    end

    BFWC_Filter_SavedConfigs.whitelist_enable = true
    BFWC_Filter_SavedConfigs.whitelist = { '任务','JY' }
end

local function blacklist_init()
    if BFWC_Filter_SavedConfigs.blacklist then
        return
    end

    BFWC_Filter_SavedConfigs.blacklist_enable = true
    BFWC_Filter_SavedConfigs.blacklist = {
        '/组','一组','邮寄','大量','带价','代价','位面','老板','支付'
    }
end

local function dungeons_init()
    if BFWC_Filter_SavedConfigs.dungeons then
        return
    end

    BFWC_Filter_SavedConfigs.dungeons = {}
    for _,d in ipairs(bfwf_dungeons) do
        BFWC_Filter_SavedConfigs.dungeons[d.name] = true
    end
end

local function reset_configs()
    BFWC_Filter_SavedConfigs = {
        saved = true,
        enable = true,
        interval = 10,
        hide_enter_leave = true,
        auto_filter_by_level = true,
        filter_request_to_join = true,
        minimap = { hide = false},
    }
    dungeons_init()
    whitelist_init()
    blacklist_init()
end

StaticPopupDialogs['BFWC_CONFIRM'] = {
    text = '',
    button1 = '是',
    button2 = '取消',
    timeout = 0,
    showAlert = true,
    whileDead = true,
    preferredIndex = STATICPOPUP_NUMDIALOGS,
    OnAccept = function(self)

    end
}

StaticPopupDialogs['BFWC_MSGBOX'] = {
    text = '',
    button1 = '好的'
}

function bfwf_msgbox(msg)
    StaticPopupDialogs['BFWC_MSGBOX'].text = msg
    local dlg = StaticPopup_Show('BFWC_MSGBOX')
    if dlg then
        --不设置成tooltip，会被设置窗口遮挡
        dlg:SetFrameStrata("TOOLTIP")
    end
end

function bfwf_confirm(msg,yes,no,func)
    StaticPopupDialogs['BFWC_CONFIRM'].text = msg
    if yes and yes:len()>0 then
        StaticPopupDialogs['BFWC_CONFIRM'].button1 = yes
    else
        StaticPopupDialogs['BFWC_CONFIRM'].button1 = '是'
    end
    if no and no:len()>0 then
        StaticPopupDialogs['BFWC_CONFIRM'].button2 = no
    else
        StaticPopupDialogs['BFWC_CONFIRM'].button2 = '取消'
    end
    StaticPopupDialogs['BFWC_CONFIRM'].OnAccept = func
    local dlg = StaticPopup_Show('BFWC_CONFIRM',"","")
    if dlg then
        --不设置成tooltip，会被设置窗口遮挡
        dlg:SetFrameStrata("TOOLTIP")
    end
end

local send_msg_time = {

}

local classes = {
    ['ROGUE']={'盗贼','盗贼','盗贼'},
    ['SHAMAN']={'萨满','奶萨','萨满'},
    ['PRIEST']={'牧师','奶牧','牧师'},
    ['WARLOCK']={'术士','术士','术士'},
    ['MAGE']={'法师','法师','法师'},
    ['HUNTER']={'猎人','猎人','猎人'},
    ['DRUID']={'德鲁伊','奶德','熊T'},
    ['PALADIN']={'骑士','奶骑','骑士T'},
    ['WARRIOR']={'战士','战士','战士T'},
}

function bfwf_myinfo(d1,d2)
    local info = ''
    info = info .. (UnitLevel("player") or '??') .. '级'
    local class = classes[bfwf_player.class]
    if bfwf_player.classes == 1 then
        info = info .. class[1]
        return info
    end

    --local d1 = BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid].first_duty
    if d1=='T' then
        info = info .. class[3]
    elseif d1=='N' then
        info = info .. class[2]
    else
        info = info .. class[1]
    end

    --local d2 = BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid].second_duty
    if not d2 or d2=='X' or d2==d1 then
        return info
    end
    if d2=='D' then
        info = info .. '，也可以DPS'
    elseif d2=='N' then
        info = info .. '，也可以奶'
    elseif d2=='T' then
        info = info .. '，也可以T'
    end
    return info
end

local last_select_team_leader
local last_whisper = {}
local function whisper_level_duty()
    if not last_select_team_leader then
        return
    end

    local d1 = BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid].first_duty
    local d2 = BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid].second_duty
    if bfwf_player.classes == 1 then
        d1 = 'D'
    end
    if not d1 then
        d1 = 'D'
        --bfwf_msgbox('先选择你的职责')
        --return
    end
    local dt = GetTime()-(last_whisper[last_select_team_leader.id] or 0)
    if dt < 60 then
        bfwf_msgbox('您刚给Ta发过申请，等会再发吧!')
        return
    end

    local info = bfwf_myinfo(d1,d2)
    local msg = '是否将您的信息\n|cffff7eff' .. info .. '|r\n发送给 |cffbb9e75' .. last_select_team_leader.name .. '|r ?'
    bfwf_confirm(msg,nil,nil,function ()
        SendChatMessage(info,"WHISPER", nil,last_select_team_leader.name)
        last_whisper[last_select_team_leader.id] = GetTime()
    end)
end

-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
local config_options = {
    type = 'group',
    name = '组队频道信息过滤器',
    args = {
        common = {
            type = 'group',
            name = '通用设置',
            order = 1,
            width = 0.5,
            args = {
                reset = {
                    type = 'execute',
                    name = '恢复默认设置',
                    order = 1,
                    func = function()
                        reset_configs()
                    end
                },

                join = {
                    type = 'execute',
                    name = '加入大脚世界频道|/join 大脚世界频道',
                    order = 2,
                    func = function()
                        --JoinChannelByName('大脚世界频道')
                    end,
                    disabled = function() return bfwf_big_foot_world_channel_joined end,
                    dialogControl = 'MacroButton'
                },

                leave = {
                    type = 'execute',
                    name = '离开大脚世界频道|/leave 大脚世界频道',
                    order = 3,
                    func = function()
                        --LeaveChannelByName('大脚世界频道')
                    end,
                    disabled = function() return not bfwf_big_foot_world_channel_joined end,
                    dialogControl = 'MacroButton'
                },

                desc = {
                    type = 'description',
                    name = '\n|cffcc0000您现在还未加入|r|cfffed51f大脚世界频道|r|cffcc0000，请先加入!|r\n',
                    hidden = function() return not bfwf_big_foot_world_channel_joined end
                },

                desc = {
                    type = 'description',
                    name = '\n' ..
                            '将大脚世界频道有用的组队信息保留下来,其它信息全部过滤掉！\n\n' ..
                            '即：只显示包含白名单关键词的信息。同时包含黑白关键词的会被过滤掉。\n\n' ..
                            '注意：本插件会过滤掉大脚世界频道的大部分信息，有可能包括您想看到的信息，比如闲聊，请谨慎使用。\n' ..
                            '\n'
                ,
                    width = 'full',
                    order = 4
                },

                autojoin = {
                    type = 'toggle',
                    name = '自动加入大脚世界频道',
                    order = 6,
                    width = 'full',
                    get = function(info)
                        return BFWC_Filter_SavedConfigs.autojoin_bigfoot
                    end,
                    set = function(info, val)
                        BFWC_Filter_SavedConfigs.autojoin_bigfoot = val
                    end
                },
                enable = {
                    type = 'toggle',
                    name = '启用过滤器',
                    order = 7,
                    width = 'full',
                    get = function(info)
                        return BFWC_Filter_SavedConfigs.enable
                    end,
                    set = function(info, val)
                        BFWC_Filter_SavedConfigs.enable = val
                        bfwf_update_minimap_icon()
                    end
                },

                enterleave = {
                    type = 'toggle',
                    name = '不显示进入/离开频道信息',
                    order = 8,
                    width = 'full',
                    get = function(info)
                        return BFWC_Filter_SavedConfigs.hide_enter_leave
                    end,
                    set = function(info, val)
                        BFWC_Filter_SavedConfigs.hide_enter_leave = val
                    end,
                    disabled = function(info)
                        return not BFWC_Filter_SavedConfigs.enable
                    end
                },

                minimap = {
                    type = 'toggle',
                    name = '显示小地图按钮',
                    order = 9,
                    width = 'full',
                    set = function(info, val)
                        BFWC_Filter_SavedConfigs.minimap.hide = not val
                        if val then
                            LibStub("LibDBIcon-1.0"):Show("BigFootWorldChannelFilter")
                        else
                            LibStub("LibDBIcon-1.0"):Hide("BigFootWorldChannelFilter")
                        end
                    end,
                    get = function(info)
                        return not BFWC_Filter_SavedConfigs.minimap.hide
                    end
                },

                interval = {
                    type = 'range',
                    name = '刷屏过滤(同一个人，间隔小于设定秒数的发言将被过滤掉)',
                    desc = '同一个人，间隔小于设定秒数的发言将被过滤掉',
                    min = 0,
                    max = 60,
                    step = 1,
                    width = 'full',
                    order = 10,
                    get = function(info)
                        return BFWC_Filter_SavedConfigs.interval
                    end,
                    set = function(info, val)
                        BFWC_Filter_SavedConfigs.interval = val
                    end,
                    disabled = function(info)
                        return not BFWC_Filter_SavedConfigs.enable
                    end
                }
            }
        },

        blacklist = {
            type = 'group',
            name = '黑名单',
            order = 2,
            width = 0.5,
            disabled = function(info)
                return not BFWC_Filter_SavedConfigs.enable or not BFWC_Filter_SavedConfigs.blacklist_enable
            end,
            args = {
                enable = {
                    type = 'toggle',
                    name = '启用黑名单',
                    order = 1,
                    disabled = false,
                    get = function(info) return BFWC_Filter_SavedConfigs.blacklist_enable end,
                    set = function(info, val) BFWC_Filter_SavedConfigs.blacklist_enable = val  end
                },
                editor = {
                    type = 'input',
                    name = '自定义关键词(用英文逗号分隔)',
                    multiline = true,
                    usage = '关键词之间用英文逗号分隔，不要回车',
                    width = 'full',
                    order = 2,
                    disabled = function() return not BFWC_Filter_SavedConfigs.blacklist_enable end,
                    get = function()
                        local s = ''
                        for _,k in ipairs(BFWC_Filter_SavedConfigs.blacklist) do
                            if s:len()>0 then
                                s = s .. ','
                            end
                            s = s .. k
                        end
                        return s
                    end,
                    set = function(info,val)
                        BFWC_Filter_SavedConfigs.blacklist = bfwf_split_str(val)
                    end
                }
            }
        },

        whitelist = {
            type = 'group',
            name = '白名单',
            order = 3,
            width = 0.5,
            disabled = function(info)
                return not BFWC_Filter_SavedConfigs.enable or not BFWC_Filter_SavedConfigs.whitelist_enable
            end,
            args = {
                enable = {
                    type = 'toggle',
                    name = '启用白名单',
                    order = 1,
                    disabled = false,
                    get = function(info) return BFWC_Filter_SavedConfigs.whitelist_enable end,
                    set = function(info, val) BFWC_Filter_SavedConfigs.whitelist_enable = val  end
                },
                editor = {
                    type = 'input',
                    name = '自定义关键词(用英文逗号分隔)',
                    multiline = true,
                    usage = '关键词之间用英文逗号分隔，不要回车',
                    width = 'full',
                    order = 2,
                    disabled = function() return not BFWC_Filter_SavedConfigs.whitelist_enable end,
                    get = function()
                        local s = ''
                        for _,k in ipairs(BFWC_Filter_SavedConfigs.whitelist) do
                            if s:len()>0 then
                                s = s .. ','
                            end
                            s = s .. k
                        end
                        return s
                    end,
                    set = function(info,val)
                        BFWC_Filter_SavedConfigs.whitelist = bfwf_split_str(val)
                    end
                },
                autosel = {
                    type = 'toggle',
                    name = '根据我的等级自动过滤组队信息！',
                    disabled = function() return not BFWC_Filter_SavedConfigs.whitelist_enable end,
                    get = function(info) return BFWC_Filter_SavedConfigs.auto_filter_by_level end,
                    set = function(info,val)
                        BFWC_Filter_SavedConfigs.auto_filter_by_level = val
                        bfwf_update_dungeons_filter()
                    end,
                    width = 'full',
                    order = 3,
                },
                desc = {
                    type = 'description',
                    name = '\n手动选择关心的副本组队信息\n中括号内文字是预设的关键字，如果不能满足需求可自行添加白名单关键词。',
                    order = 4,
                    width = 'full'
                }
            }
        },

        teamlog1 = {
            type = 'group',
            name = '我要找队伍',
            order = 4,
            width = 'full',
            args = {
                desc1 = {
                    order = 1,
                    type = 'description',
                    name = '最近的组队喊话记录',
                    width = 1
                },
                beg = {
                    type = 'toggle',
                    order = 1.1,
                    name = '过滤|cffbb9e75求组|r信息',
                    get = function() return BFWC_Filter_SavedConfigs.filter_request_to_join  end,
                    set = function(info,val)
                        BFWC_Filter_SavedConfigs.filter_request_to_join = val
                    end
                },
                desc2 = {
                    order = 1.2,
                    type = 'description',
                    name = '|cffff0000您还没加入大脚世界频道，请在“通用设置”里先加入，大部分组队信息都在该频道|r',
                    hidden=function() return bfwf_big_foot_world_channel_joined  end,
                    width = 'full'
                },

                history = {
                    type = 'select',
                    name = '最近的喊话组队记录',
                    order = 2,
                    width = 'full',
                    dialogControl = 'ListBox',
                    values = function ()
                        local arr = {}
                        for _,m in ipairs(bfwf_chat_team_log) do
                            local dt = GetTime()-m.time
                            if dt < 180 then
                                local text = '[|cff3ee157' .. bfwf_format_time(dt)
                                text = text .. '|r |cffbb9e75' .. m.name .. '|r ] '
                                text = text .. '|cffb3f0e7' .. m.text ..'|r'
                                --arr[#arr+1] = { text = text,id = m.playerid}
                                arr[#arr+1] = {text = text,id = m.playerid,name=m.fullname,time=m.time}
                            end
                        end
                        return arr
                    end,
                    width = 'full',
                    set = function(info,val)
                        last_select_team_leader = val
                    end,
                    get = function(info)
                        return last_select_team_leader
                    end
                },

                desc3 = {
                    order = 3,
                    type = 'group',
                    name = '将我的等级、职责密给队长',
                    inline = true,
                    width = 'full',
                    args = {
                        first = {
                            type = 'select',
                            name = '主责',
                            order = 1,
                            values = function ()
                                if bfwf_player.classes==1 then
                                    return {['D']='DPS'}
                                end

                                if bfwf_player.classes==2 then
                                    if bfwf_player.class == 'WARRIOR' then
                                        return {['D']='DPS',['T']='坦克'}
                                    end
                                    return {['D']='DPS',['N']='奶'}
                                end

                                return {['D']='DPS',['T']='坦克',['N']='奶'}
                            end,
                            get = function(info)
                                if bfwf_player.classes==1 then
                                    return 'D'
                                end
                                if not bfwf_g_data.myid or not BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid]  then
                                    return 'D'
                                end
                                return BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid].first_duty or 'D'
                            end,
                            set = function(info,val)
                                if not bfwf_g_data.myid or not BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid]  then
                                    return
                                end

                                BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid].first_duty = val
                            end,
                            disabled = function() return bfwf_player.classes==1 end
                        },
                        second = {
                            type = 'select',
                            name = '次责',
                            order = 2,
                            values = function ()
                                if bfwf_player.classes==1 then
                                    return {['X']='无',['D']='DPS'}
                                end

                                if bfwf_player.classes==2 then
                                    if bfwf_player.class == 'WARRIOR' then
                                        return {['X']='无',['D']='DPS',['T']='坦克'}
                                    end
                                    return {['X']='无',['D']='DPS',['N']='奶'}
                                end

                                return {['X']='无',['D']='DPS',['T']='坦克',['N']='奶'}
                            end,
                            get = function(info)
                                if bfwf_player.classes==1 then
                                    return '无'
                                end
                                if not bfwf_g_data.myid or not BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid]  then
                                    return
                                end
                                return BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid].second_duty
                            end,
                            set = function(info,val)
                                if not bfwf_g_data.myid or not BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid]  then
                                    return
                                end

                                BFWC_Filter_SavedConfigs.player[bfwf_g_data.myid].second_duty = val
                            end,
                            disabled = function() return bfwf_player.classes==1 end
                        },
                        send = {
                            type = 'execute',
                            name = '发送',
                            order = 3,
                            disabled = function(info) return not last_select_team_leader end,
                            func = whisper_level_duty
                        }
                    }
                }
            }
        }
    }
}

local function str_cat(arr)
    local s = '    ['
    local first = true
    for _,k in ipairs(arr or {}) do
        if first then
            first = false
        else
            s = s .. ','
        end
        s = s .. '|cffbb9e75' .. string.upper(k) .. '|r'
        first = false
    end
    s = s .. ']'
    return s
end

bfwf_configs_init = function()
    if not BFWC_Filter_SavedConfigs.saved then
        reset_configs()
    end

    whitelist_init()

    blacklist_init()

    local args = config_options.args.whitelist.args

    local order = 10
    for _,d in ipairs(bfwf_dungeons) do
        order = order + 1
        args[d.name] = {
            type = 'toggle',
            name = '|cff0c32da' .. d.name .. '|r' .. str_cat(d.keys),
            width = 'full',
            order = order,
            disabled = function(info) return BFWC_Filter_SavedConfigs.auto_filter_by_level end,
            get = function(info) return BFWC_Filter_SavedConfigs.dungeons[info[2]] end,
            set = function(info,val) BFWC_Filter_SavedConfigs.dungeons[info[2]] = val end
        }
    end

    LibStub("AceConfig-3.0"):RegisterOptionsTable("BigFootWorldChannelFilter", config_options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BigFootWorldChannelFilter", "组队频道过滤")
end

--[[
"PARENT"
"BACKGROUND"
"LOW"
"MEDIUM"
"HIGH"
"DIALOG"
"FULLSCREEN"
"FULLSCREEN_DIALOG"
"TOOLTIP"
--]]
bfwf_toggle_config_dialog = function()
    local cfgdlg = LibStub("AceConfigDialog-3.0")
    local st = cfgdlg:GetStatusTable('BigFootWorldChannelFilter',{'teamlog1'})
    for k,v in pairs(st) do
        print(k,v)
        for a,b in pairs(v) do
            print(a,b)
        end
    end
    --cfgdlg:SetDefaultSize("BigFootWorldChannelFilter", 800, 600)
    --cfgdlg:Open("BigFootWorldChannelFilter")
    --cfgdlg.OpenFrames['BigFootWorldChannelFilter'].frame:SetFrameStrata("MEDIUM")
end