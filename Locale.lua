function AutoMessage:Locale( _local )
    local L = {}
    if(_local == 'zhCN' or _local == nil) then --default zhCN
        L["announce"] = "喊话"
    end
    return L
end