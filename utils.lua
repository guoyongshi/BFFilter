

bfwf_split_str = function(str, c)
    local strs = {}
    if not c then
        c = 0x2c
    end
    if not str then
        return strs
    end

    local len = str:len()
    if len == 0 then
        return strs
    end


    local n = str:len()
    local start = 1
    for i = 1, n do
        local b = string.byte(str, i)
        if b == c then
            if i ~= start then
                strs[#strs + 1] = string.sub(str, start, i - 1)
            end
            start = i + 1
        end
    end

    if start <= n then
        strs[#strs + 1] = string.sub(str, start, n)
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