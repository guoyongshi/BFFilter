
local function utf8bytes(bs,offset)
    local b = bs[offset]
    if b<128 then
        return 1
    end

    if b<=192 then  --非法utf8序列
        return 0
    end
    local bvs={128,64,32,16,8,4}
    for i=1,#bvs do
        b = b-bvs[i]
        if b<0 then
            return i-1
        end
    end

    return 0
end

--字符串拆成字数组
local function string_split(msg)
    local bs = {string.byte(msg,1,-1)}
    local i = 1
    local s={}
    while i<#bs do
        local n = utf8bytes(bs,i)
        if n == 0 then
            return nil
        end
        table.insert(s,string.sub(msg,i,i+n-1))
        i = i+n
    end

    return s
end

local function is_symbol(c)
    local cv,_ = string.byte(c)
    if not cv then
        return false
    end
    if cv<48 then
        return true
    end

    if cv>57 and cv<65 then
        return true
    end

    if cv>90 and cv<97 then
        return true
    end

    if cv>122 and cv < 128 then
        return true
    end

    return false
end
--叠字过滤
local function trim_rchars(cs)
    local _cs = {}
    local lastc=''
    local rn = 0
    for _,c in ipairs(cs) do
        if lastc ~= c then
            rn = 1
            if is_symbol(lastc) and c == ' ' then
                --符号后面的空格直接不要
            else
                lastc = c
                table.insert(_cs,c)
            end
        else
            rn = rn + 1
            if rn==2 then
                --数字、字母、中文留两个
                if not is_symbol(c) then
                    table.insert(_cs,c)
                end
            end
        end
    end

    return _cs
end

--叠句过滤
local function trim_rsentence(cs)
    return cs
end

bfwf_trim_message = function(msg)
    if not msg then
        return false,msg
    end

    local cs = string_split(msg)
    if not cs then
        return false,msg
    end

    local cs1 = trim_rchars(cs)
    local cs2 = trim_rsentence(cs1)

    if #cs == #cs2 then
        return false,msg
    end

    if #cs1 ~= #cs2 then    --叠句过滤后可能会产生叠字
        cs2 = trim_rchars(cs2)
    end

    local _msg = ''
    for _,c in ipairs(cs2) do
        _msg = _msg .. c
    end

    return true,_msg
end

