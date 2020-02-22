MyAddon = LibStub("AceAddon-3.0"):NewAddon("AutoMessage", "AceConsole-3.0",
                                           "AceEvent-3.0", "AceTimer-3.0")

MyAddon.L = {}
MyAddon.width = 423
MyAddon.height = 440
MyAddon.current_sender = "one"
MyAddon.channel_id = {}
MyAddon.channel_name = {}
Main_frame = {}
local AceGUI = LibStub("AceGUI-3.0")
local defaults = {
    profile = {
        newer = 0,
        message = {
            one = {
                send_status = false,
                send_time = 20,
                send_template = 1,
                send_channels = {
                    yell = false,
                    say = false,
                    guild = false,
                    raid = false,
                    channel_one = 1,
                    channel_two = 1,
                    channel_three = 1
                }
            },
            two = {
                send_status = false,
                send_time = 10,
                send_template = 1,
                send_channels = {
                    yell = false,
                    say = false,
                    guild = false,
                    raid = false,
                    channel_one = 1,
                    channel_two = 2,
                    channel_three = 1
                }
            },
            three = {
                send_status = false,
                send_time = 30,
                send_template = 1,
                send_channels = {
                    yell = false,
                    say = false,
                    guild = false,
                    raid = false,
                    channel_one = 1,
                    channel_two = 1,
                    channel_three = 2
                }
            }
        },
        template = {
            one = {title = "模板一", content = "模板内容1 自行更换"},
            two = {title = "模板二", content = "模板内容2 自行更换"},
            three = {
                title = "模板三",
                content = "模板内容3 自行更换"
            },
            four = {title = "模板四", content = "模板内容4 自行更换"},
            five = {title = "模板五", content = "模板内容5 自行更换"},
            six = {title = "模板六", content = "模板内容6 自行更换"},
            seven = {
                title = "模板七",
                content = "模板内容7 自行更换"
            },
            eight = {
                title = "模板八",
                content = "模板内容8 自行更换"
            },
            nine = {title = "模板九", content = "模板内容9 自行更换"}
        },
        money_raid_calculate = {
            money = 1550,
            person_base = 14,
            person = 1,
            adjust = false,
            adjust_person = 1,
            rl = true,
            rl_percent = 0.5,
            rl_money = 50,
            reward_percent = 0.2,
            reward_count = 30,
            reward_remain = 70,
            one_money_count = 100,
            send_channel_money = 1
        },
        replay_template = {
            text = {
                '密语一','密语二','密语三','密语四','密语五','密语六',
            },
            replay = {
                '回复一','回复二','回复三','回复四','回复五','回复六'
            }
            -- one = {text = '密语一', replay = '回复一'},
            -- two = {text = '密语二', replay = '回复一'},
            -- three = {text = '密语三', replay = '回复三'},
            -- four = {text = '密语四', replay = '回复四'},
            -- five = {text = '密语五', replay = '回复五'},
            -- six = {text = '密语六', replay = '回复六'}
        }
    }
}
function MyAddon:OnInitialize()
    MyAddon.L = MyAddon:Locale(GetLocale())
    -- MyAddon.L = MyAddon:Locale("enUS")
    self:Print(MyAddon.L["Announce"])

    MyAddon.db = LibStub("AceDB-3.0"):New("AutoMessageDB", defaults, true)
    MyAddon.db.profile.message.one.send_status, MyAddon.db.profile.message.two
        .send_status, MyAddon.db.profile.message.three.send_status = false
    MyAddon:RegisterChatCommand("am", "ChatCommand")
    MyAddon:RegisterChatCommand("automessage", "ChatCommand")
    MyAddon:RegisterChatCommand("automsg", "ChatCommand")
    MyAddon:initTabs()
    -- 添加密语监测事件
    MyAddon:RegisterEvent("CHAT_MSG_WHISPER", "WhisperReplay")
    if MyAddon.db.profile.newer >= 3 then
        Main_frame:Hide()
    else
        MyAddon.db.profile.newer = MyAddon.db.profile.newer + 1
    end
    MyAddon:SetupLDB()
end
function GetJoinedChannels()
    local channels = {}
    local chanList = {GetChannelList()}
    for i = 1, #chanList, 3 do
        table.insert(channels, {
            id = chanList[i],
            name = chanList[i + 1],
            isDisabled = chanList[i + 2] -- Not sure what a state of "blocked" would be
        })
    end
    return channels
end
function MyAddon:RenderChannel()
    local channels = GetJoinedChannels()
    -- MyAddon:Print(channels[1].name)
    MyAddon.channel_id[1] = 999
    MyAddon.channel_name[1] = "|cff00A310" .. MyAddon.L["select a channel"]
    for i, channel in ipairs(channels) do
        MyAddon.channel_id[i + 1] = channel.id
        MyAddon.channel_name[i + 1] = channel.name
    end
end

local function number_2_string(number)
    local string = ""
    if number == 1 then
        string = "one"
    elseif number == 2 then
        string = "two"
    elseif number == 3 then
        string = "three"
    elseif number == 4 then
        string = "four"
    elseif number == 5 then
        string = "five"
    elseif number == 6 then
        string = "six"
    elseif number == 7 then
        string = "seven"
    elseif number == 8 then
        string = "eight"
    elseif number == 9 then
        string = "nine"
    end
    return string
end
-- send msg
local function prepare_send(sender)
    -- 发送者
    local _sender = sender
    MyAddon[_sender] = sender
    local status = MyAddon.db.profile.message[_sender].send_status -- 状态

    if status then
        local send_time = MyAddon.db.profile.message[_sender].send_time -- 时间
        local send_template = MyAddon.db.profile.message[_sender].send_template -- 模板
        send_template = number_2_string(send_template)
        local send_content = MyAddon.db.profile.template[send_template].content -- 模板内容
        -- 频道
        local yell = MyAddon.db.profile.message[_sender].send_channels.yell -- 大喊
        local say = MyAddon.db.profile.message[_sender].send_channels.say -- 说话
        local guild = MyAddon.db.profile.message[_sender].send_channels.guild -- 工会
        local raid = MyAddon.db.profile.message[_sender].send_channels.raid -- 团队
        local channel_one =
            MyAddon.channel_id[MyAddon.db.profile.message[_sender].send_channels
                .channel_one] -- 自定义频道
        local channel_two =
            MyAddon.channel_id[MyAddon.db.profile.message[_sender].send_channels
                .channel_two] -- 自定义频道
        local channel_three =
            MyAddon.channel_id[MyAddon.db.profile.message[_sender].send_channels
                .channel_three] -- 自定义频道
        -- MyAddon:Print("yell")
        -- MyAddon:Print(yell)
        -- MyAddon:Print("say")
        -- MyAddon:Print(say)
        -- MyAddon:Print("guild")
        -- MyAddon:Print(guild)
        -- MyAddon:Print("raid")
        -- MyAddon:Print(raid)
        -- MyAddon:Print("channel_one")
        -- MyAddon:Print(channel_one)
        -- MyAddon:Print("channel_two")
        -- MyAddon:Print(channel_two)
        -- MyAddon:Print("channel_three")
        -- MyAddon:Print(channel_three)

        -- MyAddon:Print("send_content")
        -- MyAddon:Print(send_content)
        -- 往对应的频道发送信息
        if yell then -- 大喊
            print('yell will be send')
            SendChatMessage(send_content, "YELL")
            print('yell send')
        end
        if say then -- 说话
            SendChatMessage(send_content, "SAY")
        end
        if guild then -- 工会
            SendChatMessage(send_content, "GUILD")
        end
        if raid then -- 团队
            SendChatMessage(send_content, "RAID")
        end
        if channel_one ~= 999 then -- 自选频道1
            SendChatMessage(send_content, "CHANNEL", nil, channel_one)
        end
        if channel_two ~= 999 then -- 自选频道2
            SendChatMessage(send_content, "CHANNEL", nil, channel_two)
        end
        if channel_three ~= 999 then -- 自选频道3
            SendChatMessage(send_content, "CHANNEL", nil, channel_three)
        end
        -- MyAddon:Print("发送结束")
        -- MyAddon:Print("send_time")
        MyAddon:ScheduleTimer(function() prepare_send(MyAddon[_sender]) end,
                              send_time)
        MyAddon:Print(send_time)
    end
end
-- draw sender wideget
function dropdown_render(_val, _label, _list, _callback, _width)
    local wideget = AceGUI:Create("Dropdown")
    if _width ~= nil then
        -- wideget:SetWidth(_width)
        wideget:SetRelativeWidth(_width)
    else
        wideget:SetWidth(60)
    end
    if _val == 1 then
        wideget:SetText("|cff00A310" .. MyAddon.L["select a channel"])
    else
        wideget:SetText(MyAddon.channel_name[_val])
    end
    wideget:SetLabel(_label)
    wideget:SetValue(_val)
    wideget:SetList(_list)
    wideget:SetCallback("OnValueChanged", _callback)
    return wideget
end
function dropdown_template_render(_val, _txt, _label, _list, _callback, _width)
    local wideget = AceGUI:Create("Dropdown")
    if _width ~= nil then
        wideget:SetRelativeWidth(_width)
    else
        wideget:SetWidth(47)
    end
    wideget:SetText(_txt)
    wideget:SetLabel(_label)
    wideget:SetValue(_val)
    wideget:SetList(_list)
    wideget:SetCallback("OnValueChanged", _callback)
    return wideget
end

local function checkbox_render(_val, _label, _callback)
    local wideget = AceGUI:Create("CheckBox")
    wideget:SetType("checkbox")
    -- wideget:SetWidth(42)
    wideget:SetRelativeWidth(0.125)
    wideget:SetValue(_val)
    wideget:SetLabel(_label)
    wideget:SetCallback("OnValueChanged", _callback)
    return wideget
end

local function editbox_render(_width, _label, _current_template, _address,
                              _callback)
    local wideget = AceGUI:Create("EditBox")
    wideget:SetLabel(_label)
    wideget:SetText(MyAddon.db.profile.template[_current_template][_address])
    wideget:SetRelativeWidth(_width)
    wideget:SetHeight(45)
    wideget:SetCallback("OnTextChanged", function(widget, event, txt)
        -- body
        MyAddon.db.profile.template[_current_template][_address] = txt
        -- MyAddon:Print(MyAddon.db.profile.template[_current_template][_address])
    end)
    return wideget
end

local function send_msg()
    -- body
end
local function Button_OnClick(frame)
    PlaySound(799) -- SOUNDKIT.GS_TITLE_OPTION_EXIT
    frame.obj:Hide()
end
-- function that draws the widgets for the tab
local function DrawGroup_message(container)
    MyAddon.channel_id = {}
    MyAddon.channel_name = {}
    MyAddon:RenderChannel()
    -- 组件初始化
    local time_range = AceGUI:Create("Slider")
    time_range:SetLabel(MyAddon.L["time gap"])
    -- time_range:SetWidth(100)
    time_range:SetRelativeWidth(0.5)
    time_range:SetSliderValues(5, 120, 1)
    time_range:SetValue(MyAddon.db.profile.message[MyAddon.current_sender]
                            .send_time)
    time_range:SetCallback("OnValueChanged", function(wideget, event, val)
        MyAddon.db.profile.message[MyAddon.current_sender].send_time = val
    end)

    container:AddChild(time_range)
    local pre_sender = MyAddon.current_sender
    local pre_status = MyAddon.db.profile.message[pre_sender].send_status -- 状态

    local send_btn = AceGUI:Create("Button")
    if pre_status then
        send_btn:SetText("|cff00FF33" .. MyAddon.L["stop"])
    else
        send_btn:SetText(MyAddon.L["send"])
    end
    send_btn:SetRelativeWidth(0.2)
    send_btn:SetCallback("OnClick", function(wideget, event)
        local sender = MyAddon.current_sender
        local status = MyAddon.db.profile.message[sender].send_status -- 状态
        if not status then
            MyAddon.db.profile.message[sender].send_status = true
            wideget:SetText("|cff00FF33" .. MyAddon.L["stop"])
            MyAddon:Print(string.upper(sender) .. " |cff00A310" ..
                              MyAddon.L["send"] .. "中....")
            prepare_send(sender)
        else
            wideget:SetText(MyAddon.L["send"])
            MyAddon.db.profile.message[sender].send_status = false
            MyAddon:Print(string.upper(sender) .. "|cffC70000 ■■" ..
                              MyAddon.L["stop"] .. "■■")
        end
    end)
    container:AddChild(send_btn)
    local tmplate_tmp = MyAddon.db.profile.template
    local send_template = MyAddon.db.profile.message[MyAddon.current_sender]
                              .send_template
    local txt_template_select = dropdown_template_render(send_template,
                                                         tmplate_tmp[number_2_string(
                                                             send_template)]
                                                             .title,
                                                         MyAddon.L["template"] ..
                                                             MyAddon.L["choose"],
                                                         {
        tmplate_tmp.one.title, tmplate_tmp.two.title, tmplate_tmp.three.title,
        tmplate_tmp.four.title, tmplate_tmp.five.title, tmplate_tmp.six.title,
        tmplate_tmp.seven.title, tmplate_tmp.eight.title, tmplate_tmp.nine.title
    }, function(wideget, event, val)
        MyAddon:Print(MyAddon.L["selected template "] .. val)
        MyAddon.db.profile.message[MyAddon.current_sender].send_template = val
    end, 0.3)
    container:AddChild(txt_template_select)

    local function checkbox_callback(wideget, event, val)
        -- MyAddon:Print(val)
        MyAddon.db.profile.message[MyAddon.current_sender].send_channels.yell =
            val
    end

    local yell = checkbox_render(
                     MyAddon.db.profile.message[MyAddon.current_sender]
                         .send_channels.yell, "|cffFF1919" .. MyAddon.L["Yell"],
                     function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels
                .yell = val
        end)
    local say = checkbox_render(
                    MyAddon.db.profile.message[MyAddon.current_sender]
                        .send_channels.say, MyAddon.L["Say"],
                    function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels.say =
                val
        end)
    local guild = checkbox_render(
                      MyAddon.db.profile.message[MyAddon.current_sender]
                          .send_channels.guild,
                      "|cff1CFF24" .. MyAddon.L["Guild"],
                      function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels
                .guild = val
        end)
    local raid = checkbox_render(
                     MyAddon.db.profile.message[MyAddon.current_sender]
                         .send_channels.raid, "|cffFF7C0A" .. MyAddon.L["Raid"],
                     function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels
                .raid = val
        end)
    container:AddChild(yell)
    container:AddChild(say)
    container:AddChild(guild)
    container:AddChild(raid)

    local select_channel_one = dropdown_render(
                                   MyAddon.db.profile.message[MyAddon.current_sender]
                                       .send_channels.channel_one,
                                   MyAddon.L["Channel select one"],
                                   MyAddon.channel_name,
                                   function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels
                .channel_one = val
        end, 0.5)
    local select_channel_two = dropdown_render(
                                   MyAddon.db.profile.message[MyAddon.current_sender]
                                       .send_channels.channel_two,
                                   MyAddon.L["Channel select two"],
                                   MyAddon.channel_name,
                                   function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels
                .channel_two = val
        end, 0.5)
    local select_channel_threee = dropdown_render(
                                      MyAddon.db.profile.message[MyAddon.current_sender]
                                          .send_channels.channel_three,
                                      MyAddon.L["Channel select three"],
        -- {"|cff00A310未选", 1, 2, 3, 4, 5, 6, 7, 8, 9},
                                      MyAddon.channel_name,
                                      function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels
                .channel_three = val
        end, 0.5)
    container:AddChild(select_channel_one)
    container:AddChild(select_channel_two)
    container:AddChild(select_channel_threee)

    local send_all = AceGUI:Create("Button")
    send_all:SetHeight(40)
    send_all:SetText(MyAddon.L["send all"])
    send_all:SetRelativeWidth(0.5)
    send_all:SetCallback("OnClick", function(wideget, event)
        MyAddon.db.profile.message.one.send_status, MyAddon.db.profile.message
            .two.send_status, MyAddon.db.profile.message.three.send_status =
            true, true, true
        send_btn:SetText("|cff00FF33" .. MyAddon.L["stop"])
        prepare_send("one")
        prepare_send("two")
        prepare_send("three")
        MyAddon:Print(string.upper("one two three") .. "|cffffffff ■■" ..
                          MyAddon.L["all send"] .. "■■")
    end)
    container:AddChild(send_all)

    MyAddon:ScheduleTimer(function()
        send_all:Click()
        MyAddon:Print('clicked')
    end, 30)
    local stop_btn = AceGUI:Create("Button")
    -- stop_btn:SetFullWidth(true)
    stop_btn:SetHeight(40)
    stop_btn:SetText(MyAddon.L["stop all"])
    stop_btn:SetRelativeWidth(0.5)
    stop_btn:SetCallback("OnClick", function(wideget, event)
        MyAddon.db.profile.message.one.send_status, MyAddon.db.profile.message
            .two.send_status, MyAddon.db.profile.message.three.send_status =
            false, false, false
        -- MyAddon:Destory()
        Main_frame:Hide()
        MyAddon:initTabs()
        MyAddon:Print(string.upper("one two three") .. "|cffC70000 ■■" ..
                          MyAddon.L["all stoped"] .. "■■")
    end)
    container:AddChild(stop_btn)
end
local function Draw_replay(container)
    -- container:ReleaseChildren()
    container:SetLayout("Flow")
    MyAddon:Print("replay module")

    local replay_one_text = AceGUI:Create("EditBox")
    replay_one_text:SetLabel('密语一')
    replay_one_text:SetText(MyAddon.db.profile.replay_template.text[1])
    replay_one_text:SetRelativeWidth(0.3)
    replay_one_text:SetCallback("OnEnterPressed", function(widget, event, txt)
        MyAddon.db.profile.replay_template.text[1] = txt
        -- Draw_calc(container)
    end)
    container:AddChild(replay_one_text)
    local replay_one_replay = AceGUI:Create("EditBox")
    replay_one_replay:SetLabel('回复一')
    replay_one_replay:SetText(MyAddon.db.profile.replay_template.replay[1])
    replay_one_replay:SetRelativeWidth(0.7)
    replay_one_replay:SetCallback("OnEnterPressed", function(widget, event, txt)
        MyAddon.db.profile.replay_template.replay[1] = txt
        -- Draw_calc(container)
    end)
    container:AddChild(replay_one_replay)

    local replay_two_text = AceGUI:Create("EditBox")
    replay_two_text:SetRelativeWidth(0.3)
    replay_two_text:SetLabel('密语二')
    replay_two_text:SetText(MyAddon.db.profile.replay_template.text[2])
    replay_two_text:SetCallback("OnValueChanged", function(widget, event, txt)
        MyAddon.db.profile.replay_template.text[2] = txt
        -- Draw_calc(container)
    end)
    container:AddChild(replay_two_text)
    local replay_two_replay = AceGUI:Create("EditBox")
    replay_two_replay:SetRelativeWidth(0.7)
    replay_two_replay:SetLabel('回复二')
    replay_two_replay:SetText(MyAddon.db.profile.replay_template.replay[2])
    replay_two_replay:SetCallback("OnValueChanged", function(widget, event, txt)
        MyAddon.db.profile.replay_template.replay[2] = txt
        -- Draw_calc(container)
    end)
    container:AddChild(replay_two_replay)

    local replay_three_text = AceGUI:Create("EditBox")
    replay_three_text:SetRelativeWidth(0.3)
    replay_three_text:SetLabel('密语三')
    replay_three_text:SetText(MyAddon.db.profile.replay_template.text[3])
    replay_three_text:SetCallback("OnValueChanged", function(widget, event, txt)
        MyAddon.db.profile.replay_template.text[3] = txt
        -- Draw_calc(container)
    end)
    container:AddChild(replay_three_text)
    local replay_three_replay = AceGUI:Create("EditBox")
    replay_three_replay:SetRelativeWidth(0.7)
    replay_three_replay:SetLabel('回复三')
    replay_three_replay:SetText(MyAddon.db.profile.replay_template.replay[3])
    replay_three_replay:SetCallback("OnValueChanged",
                                    function(widget, event, txt)
        MyAddon.db.profile.replay_template.replay[3] = txt
        -- Draw_calc(container)
    end)
    container:AddChild(replay_three_replay)

    local replay_four_text = AceGUI:Create("EditBox")
    replay_four_text:SetRelativeWidth(0.3)
    replay_four_text:SetLabel('密语四')
    replay_four_text:SetText(MyAddon.db.profile.replay_template.text[4])
    replay_four_text:SetCallback("OnValueChanged", function(widget, event, txt)
        MyAddon.db.profile.replay_template.text[4] = txt
        -- Draw_calc(container)
    end)
    container:AddChild(replay_four_text)
    local replay_four_replay = AceGUI:Create("EditBox")
    replay_four_replay:SetRelativeWidth(0.7)
    replay_four_replay:SetLabel('回复四')
    replay_four_replay:SetText(MyAddon.db.profile.replay_template.replay[4])
    replay_four_replay:SetCallback("OnValueChanged",
                                   function(widget, event, txt)
        MyAddon.db.profile.replay_template.replay[4] = txt
        -- Draw_calc(container)
    end)
    container:AddChild(replay_four_replay)

    local replay_five_text = AceGUI:Create("EditBox")
    replay_five_text:SetRelativeWidth(0.3)
    replay_five_text:SetLabel('密语五')
    replay_five_text:SetText(MyAddon.db.profile.replay_template.text[5])
    replay_five_text:SetCallback("OnValueChanged", function(widget, event, txt)
        MyAddon.db.profile.replay_template.text[5] = txt
        -- Draw_calc(container)
    end)
    container:AddChild(replay_five_text)
    local replay_five_replay = AceGUI:Create("EditBox")
    replay_five_replay:SetRelativeWidth(0.7)
    replay_five_replay:SetLabel('回复五')
    replay_five_replay:SetText(MyAddon.db.profile.replay_template.replay[5])
    replay_five_replay:SetCallback("OnValueChanged",
                                   function(widget, event, txt)
        MyAddon.db.profile.replay_template.replay[5] = txt
        -- Draw_calc(container)
    end)
    container:AddChild(replay_five_replay)

    local replay_six_text = AceGUI:Create("EditBox")
    replay_six_text:SetRelativeWidth(0.3)
    replay_six_text:SetLabel('密语六')
    replay_six_text:SetText(MyAddon.db.profile.replay_template.text[6])
    replay_six_text:SetCallback("OnValueChanged", function(widget, event, txt)
        MyAddon.db.profile.replay_template.text[6] = txt
        -- Draw_calc(container)
    end)
    container:AddChild(replay_six_text)
    local replay_six_replay = AceGUI:Create("EditBox")
    replay_six_replay:SetRelativeWidth(0.7)
    replay_six_replay:SetLabel('回复六')
    replay_six_replay:SetText(MyAddon.db.profile.replay_template.replay[6])
    replay_six_replay:SetCallback("OnValueChanged", function(widget, event, txt)
        MyAddon.db.profile.replay_template.replay[6] = txt
        -- Draw_calc(container)
    end)
    container:AddChild(replay_six_replay)

end
function calc_one_count()
    MyAddon:Print("ssss")
    local person = MyAddon.db.profile.money_raid_calculate.person +
                       MyAddon.db.profile.money_raid_calculate.person_base
    if MyAddon.db.profile.money_raid_calculate.rl then
        person = person +
                     tonumber(MyAddon.db.profile.money_raid_calculate.rl_percent)
    end
    if MyAddon.db.profile.money_raid_calculate.adjust then
        person = person +
                     tonumber(MyAddon.db.profile.money_raid_calculate
                                  .adjust_person / 10)
    end
    local money = MyAddon.db.profile.money_raid_calculate.money
    one_money_count = money / person
    MyAddon:Print(MyAddon.db.profile.money_raid_calculate.rl_percent)
    MyAddon.db.profile.money_raid_calculate.one_money_count = one_money_count
    MyAddon.db.profile.money_raid_calculate.rl_money =
        math.floor(one_money_count) *
            MyAddon.db.profile.money_raid_calculate.rl_percent
    MyAddon.db.profile.money_raid_calculate.reward_count =
        math.floor(one_money_count) *
            MyAddon.db.profile.money_raid_calculate.reward_percent
    MyAddon.db.profile.money_raid_calculate.reward_remain =
        math.floor(one_money_count) - math.floor(one_money_count) *
            MyAddon.db.profile.money_raid_calculate.reward_percent
end

local function Draw_calc(container)
    calc_one_count()
    -- money_raid_calculate = {
    --     money = 500,
    --     person = 20,
    --     RL = true,
    --     rl_percent = 0.5,
    --     rl_money = 0.5,
    --     reward_percent = 0.3,
    --     reward_count = 0.3,
    --     reward_remain = 0.7
    -- }

    container:ReleaseChildren()
    container:SetLayout("Flow")
    MyAddon:Print("calc module")

    local money_input = AceGUI:Create("EditBox")
    money_input:SetLabel("可分配金币")
    money_input:SetText(MyAddon.db.profile.money_raid_calculate.money)
    money_input:SetRelativeWidth(0.3)
    money_input:SetCallback("OnEnterPressed", function(widget, event, txt)
        -- body
        MyAddon.db.profile.money_raid_calculate.money = txt
        Draw_calc(container)
    end)
    container:AddChild(money_input)

    local person = AceGUI:Create("Dropdown")
    person:SetRelativeWidth(0.3)
    person:SetText(MyAddon.db.profile.money_raid_calculate.person + 14)
    person:SetLabel(MyAddon.L["raid person"])
    person:SetValue(MyAddon.db.profile.money_raid_calculate.person)
    person:SetList({
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
        33, 34, 35, 36, 37, 38, 39, 40
    })
    person:SetCallback("OnValueChanged", function(widget, event, txt)
        MyAddon.db.profile.money_raid_calculate.person = txt
        Draw_calc(container)
    end)
    container:AddChild(person)
    local adjust = AceGUI:Create("CheckBox")
    adjust:SetType("checkbox")
    adjust:SetRelativeWidth(0.1)
    adjust:SetLabel('')
    adjust:SetValue(MyAddon.db.profile.money_raid_calculate.adjust)
    adjust:SetCallback("OnValueChanged", function(widget, event, txt)
        MyAddon.db.profile.money_raid_calculate.adjust = txt
        Draw_calc(container)
    end)
    container:AddChild(adjust)
    local adjust_person = AceGUI:Create("Dropdown")
    adjust_person:SetRelativeWidth(0.3)
    adjust_person:SetText(
        MyAddon.db.profile.money_raid_calculate.adjust_person / 10)
    adjust_person:SetLabel("调节人数")
    adjust_person:SetValue(MyAddon.db.profile.money_raid_calculate.adjust_person)
    adjust_person:SetList({0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9})
    adjust_person:SetCallback("OnValueChanged", function(widget, event, txt)
        MyAddon.db.profile.money_raid_calculate.adjust_person = txt
        Draw_calc(container)
    end)
    if not (MyAddon.db.profile.money_raid_calculate.adjust) then
        adjust_person:SetDisabled(true)
    end
    container:AddChild(adjust_person)
    local raid_leader = AceGUI:Create("CheckBox")
    raid_leader:SetType("checkbox")
    -- raid_leader:SetWidth(42)
    raid_leader:SetRelativeWidth(0.3)
    raid_leader:SetValue(MyAddon.db.profile.money_raid_calculate.rl)
    raid_leader:SetLabel("指挥工资")
    raid_leader:SetCallback("OnValueChanged", function(widget, event, txt)
        MyAddon.db.profile.money_raid_calculate.rl = txt
        Draw_calc(container)
    end)
    container:AddChild(raid_leader)

    local raid_percent = AceGUI:Create("EditBox")
    raid_percent:SetLabel("指挥比例")
    if MyAddon.db.profile.money_raid_calculate.rl then
        raid_percent:SetText(MyAddon.db.profile.money_raid_calculate.rl_percent)
    else
        raid_percent:SetText(0)
    end

    raid_percent:SetRelativeWidth(0.4)
    raid_percent:SetCallback("OnEnterPressed", function(widget, event, txt)
        -- body
        MyAddon.db.profile.money_raid_calculate.rl_percent = txt
        Draw_calc(container)
    end)
    container:AddChild(raid_percent)

    local raid_money = AceGUI:Create("EditBox")
    raid_money:SetLabel("指挥金额")
    raid_money:SetDisabled(true)
    if MyAddon.db.profile.money_raid_calculate.rl then
        raid_money:SetText(MyAddon.db.profile.money_raid_calculate.rl_money)
    else
        raid_money:SetText(0)
    end
    raid_money:SetRelativeWidth(0.3)
    raid_money:SetCallback("OnTextChanged", function(widget, event, txt)
        -- body
        MyAddon.db.profile.money_raid_calculate.rl_money = txt
    end)
    container:AddChild(raid_money)
    -- 奖惩比例
    local reward_percent = AceGUI:Create("EditBox")
    reward_percent:SetLabel("奖惩比例")
    reward_percent:SetText(MyAddon.db.profile.money_raid_calculate
                               .reward_percent)
    reward_percent:SetRelativeWidth(0.3)
    reward_percent:SetCallback("OnEnterPressed", function(widget, event, txt)
        -- body
        MyAddon.db.profile.money_raid_calculate.reward_percent = txt
        Draw_calc(container)
    end)

    container:AddChild(reward_percent)
    -- 惩罚后所得
    local reward_remain = AceGUI:Create("EditBox")
    reward_remain:SetLabel("惩罚后所得")
    reward_remain:SetDisabled(true)
    reward_remain:SetText(MyAddon.db.profile.money_raid_calculate.reward_remain)
    reward_remain:SetRelativeWidth(0.4)
    reward_remain:SetCallback("OnTextChanged", function(widget, event, txt)
        -- body
        MyAddon.db.profile.money_raid_calculate.reward_remain = txt
    end)
    container:AddChild(reward_remain)
    -- 奖励所得
    local reward_count = AceGUI:Create("EditBox")
    reward_count:SetLabel("奖励所得")
    reward_count:SetDisabled(true)
    reward_count:SetText(MyAddon.db.profile.money_raid_calculate.reward_count)
    reward_count:SetRelativeWidth(0.3)
    reward_count:SetCallback("OnTextChanged", function(widget, event, txt)
        -- body
        MyAddon.db.profile.money_raid_calculate.reward_count = txt
    end)
    container:AddChild(reward_count)
    -- 一人份
    local one_count = AceGUI:Create("EditBox")
    one_count:SetLabel("一人份")
    one_count:SetDisabled(true)
    -- one_count:SetText(calc_one_count())
    one_count:SetText(MyAddon.db.profile.money_raid_calculate.one_money_count)
    one_count:SetRelativeWidth(0.5)
    one_count:SetCallback("OnTextChanged", function(widget, event, txt)
        -- body
        MyAddon.db.profile.money_raid_calculate.one_money_count = txt
    end)
    container:AddChild(one_count)

    -- 取整
    local integer = AceGUI:Create("EditBox")
    integer:SetLabel("取整数")
    integer:SetDisabled(true)
    integer:SetText(math.floor(MyAddon.db.profile.money_raid_calculate
                                   .one_money_count))
    integer:SetRelativeWidth(0.5)
    integer:SetCallback("OnTextChanged", function(widget, event, txt)
        -- body
        -- MyAddon.db.profile.money_raid_calculate.reward_count = txt
    end)
    container:AddChild(integer)
    -- 二人份
    local two_count = AceGUI:Create("EditBox")
    two_count:SetLabel("二人份")
    two_count:SetDisabled(true)
    two_count:SetText(2 *
                          math.floor(MyAddon.db.profile.money_raid_calculate
                                         .one_money_count))
    two_count:SetRelativeWidth(0.25)
    two_count:SetCallback("OnTextChanged", function(widget, event, txt)
        -- body
        -- MyAddon.db.profile.money_raid_calculate.reward_count = txt
    end)
    container:AddChild(two_count)
    -- 三人份
    local three_count = AceGUI:Create("EditBox")
    three_count:SetLabel("三人份")
    three_count:SetDisabled(true)
    three_count:SetText(3 *
                            math.floor(MyAddon.db.profile.money_raid_calculate
                                           .one_money_count))
    three_count:SetRelativeWidth(0.25)
    three_count:SetCallback("OnTextChanged", function(widget, event, txt)
        -- body
        -- MyAddon.db.profile.money_raid_calculate.reward_count = txt
    end)
    container:AddChild(three_count)

    -- 四人份
    local four_count = AceGUI:Create("EditBox")
    four_count:SetLabel("四人份")
    four_count:SetDisabled(true)
    four_count:SetText(4 *
                           math.floor(MyAddon.db.profile.money_raid_calculate
                                          .one_money_count))
    four_count:SetRelativeWidth(0.25)
    four_count:SetCallback("OnTextChanged", function(widget, event, txt)
        -- body
        -- MyAddon.db.profile.money_raid_calculate.reward_count = txt
    end)
    container:AddChild(four_count)

    -- 五人份
    local five_count = AceGUI:Create("EditBox")
    five_count:SetLabel("五人份")
    five_count:SetDisabled(true)
    five_count:SetText(5 *
                           math.floor(MyAddon.db.profile.money_raid_calculate
                                          .one_money_count))
    five_count:SetRelativeWidth(0.25)
    five_count:SetCallback("OnTextChanged", function(widget, event, txt)
        -- body
        -- MyAddon.db.profile.money_raid_calculate.reward_count = txt
    end)
    container:AddChild(five_count)

    -- 结果文字
    local gap_txt = '-----------------'
    local usr = MyAddon.L['author']
    local result_count = AceGUI:Create("EditBox")
    result_count:SetLabel("结果文字")
    local raid_money = "团队可分配金币：" ..
                           MyAddon.db.profile.money_raid_calculate.money
    local raid_person = "团队分配人数："
    local raid_person_count = MyAddon.db.profile.money_raid_calculate.person +
                                  MyAddon.db.profile.money_raid_calculate
                                      .person_base
    if MyAddon.db.profile.money_raid_calculate.adjust then
        raid_person_count = raid_person_count +
                                MyAddon.db.profile.money_raid_calculate
                                    .adjust_person / 10
    end
    local rl_percent = "指挥多获取比例："
    local rl_money = "指挥多获得金币数量："
    if MyAddon.db.profile.money_raid_calculate.rl then
        rl_percent = rl_percent ..
                         MyAddon.db.profile.money_raid_calculate.rl_percent
        rl_money = rl_money .. MyAddon.db.profile.money_raid_calculate.rl_money
        raid_person_count = raid_person_count +
                                MyAddon.db.profile.money_raid_calculate
                                    .rl_percent
    end
    raid_person = raid_person .. raid_person_count
    local reward_percent = "团队奖惩比例：" ..
                               MyAddon.db.profile.money_raid_calculate
                                   .reward_percent
    local reward_remain = "惩罚后所得：" ..
                              MyAddon.db.profile.money_raid_calculate
                                  .reward_remain
    local reward_count = "奖励所得：" ..
                             MyAddon.db.profile.money_raid_calculate
                                 .reward_count
    local one_person = "每人标准所得：" ..
                           math.floor(MyAddon.db.profile.money_raid_calculate
                                          .one_money_count)
    local two_person = "两人标准所得：" .. 2 *
                           math.floor(MyAddon.db.profile.money_raid_calculate
                                          .one_money_count)
    local three_person = "三人标准所得：" .. 3 *
                             math.floor(MyAddon.db.profile.money_raid_calculate
                                            .one_money_count)
    local four_person = "四人标准所得：" .. 4 *
                            math.floor(MyAddon.db.profile.money_raid_calculate
                                           .one_money_count)
    local five_person = "五人标准所得：" .. 5 *
                            math.floor(MyAddon.db.profile.money_raid_calculate
                                           .one_money_count)
    local result_text = {
        raid_money, raid_person, rl_percent, rl_money, gap_txt, reward_percent,
        reward_remain, reward_count, gap_txt, one_person, two_person,
        three_person, four_person, five_person, usr
    }
    result_count:SetText(raid_money .. raid_person .. rl_percent .. rl_money ..
                             reward_percent .. reward_remain .. reward_count ..
                             one_person .. two_person .. three_person ..
                             four_person .. five_person .. usr)
    result_count:SetRelativeWidth(0.5)
    result_count:SetCallback("OnTextChanged", function(widget, event, txt)
        -- body
        -- MyAddon.db.profile.money_raid_calculate.reward_count = txt
    end)
    container:AddChild(result_count)
    local money_channel_txt = {'说话', '大喊', '团队', '工会'}
    local money_channel_code = {'SAY', 'Yell', 'RAID', 'GUILD'}
    local send_channel_money = AceGUI:Create("Dropdown")
    send_channel_money:SetRelativeWidth(0.2)
    send_channel_money:SetText(money_channel_txt[MyAddon.db.profile
                                   .money_raid_calculate.send_channel_money])
    send_channel_money:SetLabel("发送频道")
    send_channel_money:SetValue(MyAddon.db.profile.money_raid_calculate
                                    .send_channel_money)
    send_channel_money:SetList(money_channel_txt)
    send_channel_money:SetCallback("OnValueChanged",
                                   function(widget, event, txt)
        MyAddon.db.profile.money_raid_calculate.send_channel_money = txt
        Draw_calc(container)
    end)

    container:AddChild(send_channel_money)

    -- 发送结果
    local send_result = AceGUI:Create("Button")
    send_result:SetText("发送结果")
    send_result:SetRelativeWidth(0.3)
    send_result:SetCallback("OnClick", function(wideget, event)
        local channel_will_send = MyAddon.db.profile.money_raid_calculate
                                      .send_channel_money
        for i, v in ipairs(result_text) do
            SendChatMessage(v, money_channel_code[channel_will_send])
            -- MyAddon:ScheduleTimer(function()
            -- end, 50)
        end
    end)
    container:AddChild(send_result)
    -- local Label = AceGUI:Create("Label")
    -- -- heading:SetWidth(normal_width - padding)
    -- Label:SetRelativeWidth(1)
    -- -- heading:SetColor(0, 120, 255)
    -- Label:SetText(
    --     "|cff5555ffcalc module：\n\nlearning....\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n.")
    -- container:AddChild(Label)
end

local function DrawGroup_message_template(container)
    local one_title = editbox_render(0.25, "模板一", "one", "title")
    local two_title = editbox_render(0.25, "模板二", "two", "title")
    local three_title = editbox_render(0.25, "模板三", "three", "title")
    local four_title = editbox_render(0.25, "模板四", "four", "title")
    local five_title = editbox_render(0.25, "模板五", "five", "title")
    local six_title = editbox_render(0.25, "模板六", "six", "title")
    local seven_title = editbox_render(0.25, "模板七", "seven", "title")
    local eight_title = editbox_render(0.25, "模板八", "eight", "title")
    local nine_title = editbox_render(0.25, "模板九", "nine", "title")

    local one_content = editbox_render(0.7, "模板内容", "one", "content")
    local two_content = editbox_render(0.7, "模板内容", "two", "content")
    local three_content =
        editbox_render(0.7, "模板内容", "three", "content")
    local four_content = editbox_render(0.7, "模板内容", "four", "content")
    local five_content = editbox_render(0.7, "模板内容", "five", "content")
    local six_content = editbox_render(0.7, "模板内容", "six", "content")
    local seven_content =
        editbox_render(0.7, "模板内容", "seven", "content")
    local eight_content =
        editbox_render(0.7, "模板内容", "eight", "content")
    local nine_content = editbox_render(0.7, "模板内容", "nine", "content")

    container:AddChild(one_title)
    container:AddChild(one_content)

    container:AddChild(two_title)
    container:AddChild(two_content)

    container:AddChild(three_title)
    container:AddChild(three_content)

    container:AddChild(four_title)
    container:AddChild(four_content)

    container:AddChild(five_title)
    container:AddChild(five_content)

    container:AddChild(six_title)
    container:AddChild(six_content)

    container:AddChild(seven_title)
    container:AddChild(seven_content)

    container:AddChild(eight_title)
    container:AddChild(eight_content)

    container:AddChild(nine_title)
    container:AddChild(nine_content)
end
local function Draw_help(container)
    local Label = AceGUI:Create("Label")
    -- heading:SetWidth(normal_width - padding)
    Label:SetRelativeWidth(1)
    -- heading:SetColor(0, 120, 255)
    Label:SetText("|cff5555ff喊话功能使用介绍：\n" ..
                      "|cffffffff1、定义喊话模班，本模板旨在存储喊话内容避免每次都需要重新输入\n" ..
                      "2、设置喊话间隔时间\n" ..
                      "3、选择喊话频道，频道多选，自由定制\n" ..
                      "4、选择需要发送的内容模板序号\n" ..
                      "！！！注意喊话间隔时间，太频繁被屏蔽就糗了\n" ..
                      "|cffFF1919！！！因暴雪数据保存机制，填完模板后请至少正常退出一次游戏。让数据保存到本地，小退回人物选择界面或直接重载界面|cff047D00（测试标签页有快捷功能可用）|cffFF1919即可！！!\n" ..
                      "|cffFFDC2B---本窗体会自动在前几次载入，之后会在后台静默等待命令。你可以使用命令把他叫出来干活---\n" ..
                      "|cffFF1919大脚世界频道与大脚世界频道2[3,4...]互斥，其他频道同理！\n" ..
                      "好了，愉快的喊起来吧。不喊了记得回来停掉哟\n" ..
                      "|cff5555ff指令介绍：\n" ..
                      "|cffFFDC2B/am /automessage /automsg\n")
    container:AddChild(Label)
end
local function Draw_test(container)
    local Label = AceGUI:Create("Label")
    -- heading:SetWidth(normal_width - padding)
    Label:SetRelativeWidth(1)
    -- heading:SetColor(0, 120, 255)
    Label:SetText("|cff5555ff" .. MyAddon.L["reload ui"] ..
                      "：\n\n\n\n\n\n\n\n\n\n\n\n\n.")
    local reload_btn = AceGUI:Create("Button")
    reload_btn:SetFullWidth(true)
    reload_btn:SetHeight(40)
    reload_btn:SetText(MyAddon.L["reload ui"])
    -- reload_btn:SetRelativeWidth(0.25)
    reload_btn:SetCallback("OnClick", function(wideget, event) ReloadUI() end)
    local join_channel = AceGUI:Create("Button")
    join_channel:SetFullWidth(true)
    join_channel:SetHeight(30)
    join_channel:SetText(MyAddon.L["join channel"])
    -- join_channel:SetRelativeWidth(0.25)
    join_channel:SetCallback("OnClick", function(wideget, event)
        MyAddon:Join_BigFoot_Channel_1_2_5()
        MyAddon:Print("join channel runing done")
    end)
    container:AddChild(reload_btn)
    container:AddChild(join_channel)
    container:AddChild(Label)
end
-- Callback function for OnGroupSelected

local function SelectGroup_sender(container, event, group)
    MyAddon.current_sender = group
    container:ReleaseChildren()
    -- MyAddon:Print("current_sender" .. MyAddon.current_sender)
    local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    -- setscrollframe
    scrollcontainer:SetFullWidth(true)
    -- scrollcontainer:SetFullHeight(true) -- probably?
    scrollcontainer:SetHeight(MyAddon.height - 200) -- probably?

    scrollcontainer:SetLayout("Fill") -- important!
    container:AddChild(scrollcontainer)
    local backframe = AceGUI:Create("ScrollFrame")
    backframe:SetLayout("Flow") -- probably?
    -- backframe:SetFullWidth(true)
    -- backframe:SetFullHeight(true) -- probably?
    -- backframe:SetHeight(MyAddon.height - 200) -- probably?
    scrollcontainer:AddChild(backframe)
    -- Draw_sender(backframe)
    if group == "template" then
        DrawGroup_message_template(backframe)
    else
        DrawGroup_message(backframe)
    end
end
local function Draw_sender_tab(container)
    -- Fill Layout - the TabGroup widget will fill the whole frame
    container:SetLayout("Fill")
    -- Create the TabGroup
    local tabpannel = AceGUI:Create("TabGroup")
    local tab_option = {
        {text = MyAddon.L["one"], value = "one"},
        {text = MyAddon.L["two"], value = "two"},
        {text = MyAddon.L["three"], value = "three"},
        {text = MyAddon.L["template"], value = "template"}
    }
    tabpannel:SetLayout("Flow")
    -- Setup which tabs to show
    tabpannel:SetTabs(tab_option)
    -- Register callback
    tabpannel:SetCallback("OnGroupSelected", SelectGroup_sender)
    -- Set initial Tab (this will fire the OnGroupSelected callback)
    tabpannel:SelectTab("one")

    -- add to the frame container
    container:AddChild(tabpannel)
    -- body
end
-- Callback function for OnGroupSelected
local function SelectGroup_outer(container, event, group)
    -- print("tab changed")
    container:ReleaseChildren()
    MyAddon.current_tab = group
    local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
    -- setscrollframe
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true) -- probably?
    scrollcontainer:SetLayout("Fill") -- important!
    container:AddChild(scrollcontainer)
    local backframe = AceGUI:Create("ScrollFrame")
    backframe:SetLayout("List") -- probably?
    -- backframe:SetLayout("Flow") -- probably?
    -- scrollcontainer:SetFullWidth(true)
    backframe:SetFullHeight(true) -- probably?
    backframe:SetHeight(MyAddon.height - 180) -- probably?
    scrollcontainer:AddChild(backframe)

    if group == "message" then
        Draw_sender_tab(backframe)
    elseif group == "replay" then
        Draw_replay(backframe)
    elseif group == "calc" then
        Draw_calc(backframe)
    elseif group == "help" then
        Draw_help(backframe)
    elseif group == "test" then
        Draw_test(backframe)
    end
end

function MyAddon:initTabs(container)
    -- Create the frame container
    Main_frame = AceGUI:Create("Frame")
    -- Main_frame:SetName('Main_frame')
    Main_frame:SetTitle(MyAddon.L["AddonName"])
    Main_frame:SetWidth(MyAddon.width)
    Main_frame:SetHeight(MyAddon.height)
    Main_frame:SetStatusText(MyAddon.L["author"])
    Main_frame:SetCallback("OnClose",
                           function(widget) AceGUI:Release(widget) end)
    tinsert(UISpecialFrames, AutoMessageFrame)
    -- Main_frame:EnableKeyboard(true)

    -- frame:SetScript("OnHide", Frame_OnClose)

    -- Fill Layout - the TabGroup widget will fill the whole frame
    Main_frame:SetLayout("Fill")

    -- Create the TabGroup
    local tabpannel = AceGUI:Create("TabGroup")
    local tab_option = {
        {text = MyAddon.L["Announce"], value = "message"},
        {text = MyAddon.L["replay"], value = "replay"},
        {text = MyAddon.L["calc"], value = "calc"},
        {text = MyAddon.L["Help"], value = "help"},
        {text = MyAddon.L["Test"], value = "test"}
    }
    tabpannel:SetLayout("Flow")
    -- Setup which tabs to show
    tabpannel:SetTabs(tab_option)
    -- Register callback
    tabpannel:SetCallback("OnGroupSelected", SelectGroup_outer)
    -- Set initial Tab (this will fire the OnGroupSelected callback)
    -- tabpannel:SelectTab("help")
    tabpannel:SelectTab("message")
    -- add to the frame Main_frame
    Main_frame:AddChild(tabpannel)
    Main_frame.obj = Main_frame
    -- print("inited tabpannel")
end
function MyAddon:ChatCommand(input)
    if not input or input:trim() == "" then
        if (Main_frame:IsShown()) then
            Main_frame:Hide()
        else
            MyAddon:initTabs()
        end
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("am", "automessage",
                                                  "automsg", input)
    end
end
function MyAddon:WhisperReplay(msg_type, msg,author_1,a,b,author_2,d,e,f,g,h,i,j,k)
    -- MyAddon:Print('----')
    -- MyAddon:Print(msg_type)
    -- MyAddon:Print(msg)
    -- MyAddon:Print(author_1)
    -- MyAddon:Print(a)
    -- MyAddon:Print(b)
    -- MyAddon:Print(author_2)
    -- MyAddon:Print(d)
    -- MyAddon:Print(e)
    -- MyAddon:Print(f)
    -- MyAddon:Print(g)
    -- MyAddon:Print(h)
    -- MyAddon:Print(i)
    -- MyAddon:Print(j)
    -- MyAddon:Print(k)
    replay_template = MyAddon.db.profile.replay_template
    for i, v in ipairs(replay_template.text) do
        -- MyAddon:Print(v)
        -- MyAddon:Print(v)
        if v==msg then
            send_content = replay_template.replay[i]
            -- MyAddon:Print(send_content)
            SendChatMessage(send_content, "WHISPER",nil,author_1)
        end
    end
end

function MyAddon:Destory()
    -- Main_frame:Hide()
    AceGUI:Release(Main_frame)
    -- Main_frame:Hide()
    Main_frame = {}
end
function MyAddon:ToggleFrame()
    if Main_frame:IsShown() then
        Main_frame:Hide()
    else
        Main_frame:Show()
    end
end
function MyAddon:Join_BigFoot_Channel_1_2_5()
    local _local = GetLocale()
    -- _local = 'enUS'
    local channels = {
        "大脚世界频道", "大脚世界频道2", "大脚世界频道3",
        "大脚世界频道4"
        -- "大脚世界频道5",
        -- "大脚世界频道6",
        -- "大脚世界频道7",
        -- "大脚世界频道7",
        -- "大脚世界频道8",
        -- "大脚世界频道9"
    }
    if _local == "zhCN" then -- default
    elseif _local == "enUS" then -- rewrite channel here for you country
        channels = {}
    end

    for i, v in ipairs(channels) do
        -- MyAddon:Print(v)
        JoinChannelByName(v)
    end
end
function MyAddon:Locale(_local)
    local L = {}
    if _local == "zhCN" or _local == nil then -- defualt
        L["AddonName"] = "自动喊话"
        -- Main tab
        L["Announce"] = "喊话"
        L["replay"] = "自动回复"
        L["calc"] = "算账"
        L["Help"] = "帮助"
        L["Test"] = "测试"
        -- Announce tab
        L["one"] = "喊一"
        L["two"] = "二"
        L["three"] = "三"
        L["template"] = "模板"
        L["choose"] = "选择"
        L["selected template "] = "已选择的模板序号为"
        -- wideget
        L["time gap"] = "时间间隔"
        L["Yell"] = "喊"
        L["Say"] = "说"
        L["Guild"] = "会"
        L["Raid"] = "团"
        L["Channel select one"] = "频道一"
        L["Channel select two"] = "频道二"
        L["Channel select three"] = "频道三"
        -- btn
        L["send"] = "发送"
        L["stop"] = "停止"
        L["send all"] = "发送所有"
        L["stop all"] = "停止所有"
        L["all send"] = "都已发送"
        L["all stoped"] = "都已停止"
        L["reload ui"] = "重载界面"
        L["join channel"] = "加入大脚世界频道1-4"
        L["select a channel"] = "选择一个频道"
        -- calc module
        L["raid person"] = "团队人数"
        L["author"] = "by 怀旧服 狮心·拾忆重逢 @20191028"
    elseif _local == "enUS" then
        L["AddonName"] = "AutoMessage"
        -- Main tab
        L["Announce"] = "Announce"
        L["replay"] = "replay"
        L["calc"] = "calc"
        L["Help"] = "Help"
        L["Test"] = "Test"
        -- Announce tab
        L["one"] = "one"
        L["two"] = "two"
        L["three"] = "three"
        L["template"] = "template"
        L["choose"] = "choose"
        L["selected template "] = "you have selected template "
        -- wideget
        L["time gap"] = "time gap"
        L["Yell"] = "Y"
        L["Say"] = "S"
        L["Guild"] = "G"
        L["Raid"] = "R"
        L["Channel select one"] = "Channel select one"
        L["Channel select two"] = "Channel select two"
        L["Channel select three"] = "Channel select three"
        L["select a channel"] = "select a channel"
        -- btn
        L["send"] = "Send"
        L["stop"] = "Stop"
        L["send all"] = "Send All"
        L["stop all"] = "Stop All"
        L["all send"] = "Already Send All"
        L["all stoped"] = "Already Stoped All"
        L["reload ui"] = "Reload Ui"
        L["join channel"] = "join channel bigfoot one2four"
        L["author"] = "by reminiscence service 狮心·拾忆重逢 @20191028"
    end
    return L
end
