

bfwf_split_str = function(str, sp)
    local strs = {}
    if not sp then
        sp = 0x2c
    else
        sp,_ = string.byte(sp,1,1)
    end
    if not str then
        return strs
    end

    local bs = {string.byte(str,1,-1)}
    local tmp = {}
    for i=1,#bs do
        local b = bs[i]
        if b == sp then
            if #tmp>0 then
                table.insert(strs,table.concat(tmp))
                tmp = {}
            end
        elseif b ~= 0xd and b ~= 0xa then
            table.insert(tmp,string.char(b))
        end
    end

    if #tmp>0 then
        table.insert(strs,table.concat(tmp))
    end

    return strs
end

local last_log_time = 0
function bfwf_log(...)
    local s = string.format(...)
    if not s then
        return
    end

    if string.len(s) == 0 then
        return
    end

    if not log_frame then
        for _, name in ipairs(CHAT_FRAMES) do
            local tab = _G and _G[name .. 'Tab']
            if tab and tab:GetText() == '组队' then
                log_frame = _G and _G[name]
            end
        end
    end

    if log_frame then
        local now = GetTime()
        local dt = now - last_log_time
        if dt > 5 then
            dt = 0
        end
        last_log_time = now
        s = s .. string.format('    %.1f %.2f', now, dt)
        log_frame:AddMessage(s)
    end
end

function bfwf_format_time(s)
    if s < 60 then
        return '刚刚'
    end

    return string.format('%d分钟前',math.floor(s/60))
end