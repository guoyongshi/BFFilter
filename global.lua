BFWC_Filter_SavedConfigs = {
}
BFWC_Filter_SavedConfigs_G = {}

bfwf_big_foot_world_channel_joined = false

bfwf_dungeons = {
    {name='怒焰裂谷(13 ~ 18)',lmin=13,lmax=18,sel=true,keys={'ny','怒焰'}},
    {name='哀嚎洞穴(17 ~ 24)',lmin=17,lmax=24,sel=true,keys={'ah','哀嚎洞穴'}},
    {name='死亡矿井(17 ~ 26)',lmin=17,lmax=26,sel=true,keys={'swkj','矿井'}},
    {name='影牙城堡(22 ~ 30)',lmin=22,lmax=30,sel=true,keys={'yy','影牙'}},
    {name='黑暗深渊(24 ~ 32)',lmin=24,lmax=32,sel=true,keys={'hasy','黑暗深渊'}},
    {name='监狱(24 ~ 32)',lmin=24,lmax=32,sel=true,keys={'jy','监狱'}},
    {name='诺莫瑞根(29 ~ 38)',lmin=29,lmax=38,sel=true,keys={'nmrg','诺莫瑞根'}},
    {name='剃刀沼泽(29 ~ 38)',lmin=29,lmax=38,sel=true,keys={'tdzz','剃刀沼泽'}},
    {name='血色修道院(26 ~ 45)',lmin=26,lmax=45,sel=true,keys={'xs','血色','墓地','图书馆','军械库','武器库','教堂'}},
    {name='剃刀高地(37 ~ 46)',lmin=37,lmax=46,sel=true,keys={'tdgd','剃刀高地'}},
    {name='奥达曼(41 ~ 51)',lmin=41,lmax=51,sel=true,keys={'adm','奥达曼'}},
    {name='祖尔法拉克(42 ~ 46)',lmin=43,lmax=49,sel=true,keys={'zul','祖尔'}},
    {name='玛拉顿(46 ~ 55)',lmin=46,lmax=55,sel=true,keys={'mld','玛拉顿'}},
    {name='阿塔哈卡神庙(50 ~ 56)',lmin=50,lmax=56,sel=true,keys={'athk','神庙'}},
    {name='黑石深渊(52 ~ 60)',lmin=52,lmax=60,sel=true,keys={'hs','黑石深渊'}},
    {name='黑石塔上/下层(55 ~ 60)',lmin=55,lmax=60,sel=true,keys={'hs','黑石塔','黑上','黑下','黑石上','黑石下'}},
    {name='厄运之槌(55 ~ 60)',lmin=55,lmax=60,sel=true,keys={'ey','厄运'}},
    {name='通灵学院(55 ~ 60)',lmin=55,lmax=60,sel=true,keys={'tl','通灵','学院'}},
    {name='斯坦索姆(55 ~ 60)',lmin=55,lmax=60,sel=true,keys={'stsm','斯坦'}},

    {name='祖尔格拉布(团)',lmin=60,lmax=60,sel=false,keys={'zg','祖格'}},
    {name='安其拉废墟(团)',lmin=60,lmax=60,sel=false,keys={'fx','安其拉','废墟'}},
    {name='熔火之心(团)',lmin=60,lmax=60,sel=false,keys={'mc','熔火之心'}},
    {name='奥妮克希亚的巢穴(团)',lmin=60,lmax=60,sel=false,keys={'黑龙','ol','奥妮','巢穴'}},
    {name='黑翼之巢(团)',lmin=60,lmax=60,sel=false,keys={'bl','黑翼'}},
    {name='其拉神殿(团)',lmin=60,lmax=60,sel=false,keys={'taq','神殿','其拉神'}},
    {name='纳克萨玛斯(团)',lmin=60,lmax=60,sel=false,keys={'naxx','纳克','萨玛斯'}},
}

bfwf_player = {}

bfwf_configs_init = function() end
bfwf_update_minimap_icon = function() end
bfwf_minimap_button_init = function() end
bfwf_chat_filter_init = function() end
bfwf_toggle_bf_filter = function() end
bfwf_split_str = function() end
bfwf_toggle_config_dialog = function() end
bfwf_update_config_dialog = function() end
bfwf_update_dungeons_filter = function() end

bfwf_show_drag_handle = function() end
bfwf_hide_drag_handle = function() end
bfwf_update_drag_handle = function() end

bfwf_update_icon = function()
    bfwf_update_drag_handle()
    bfwf_update_minimap_icon()
end

bfwf_chat_team_log = {}
bfwf_chat_task_log = {}

bfwf_g_data = {
    level = 0,
}
