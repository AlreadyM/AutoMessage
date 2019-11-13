MyAddon = LibStub("AceAddon-3.0"):NewAddon("AutoMessage", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

MyAddon.L = {}
MyAddon.width = 423
MyAddon.height = 400
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
            one = {
                title = "模板一",
                content = "模板内容1 自行更换"
            },
            two = {
                title = "模板二",
                content = "模板内容2 自行更换"
            },
            three = {
                title = "模板三",
                content = "模板内容3 自行更换"
            },
            four = {
                title = "模板四",
                content = "模板内容4 自行更换"
            },
            five = {
                title = "模板五",
                content = "模板内容5 自行更换"
            },
            six = {
                title = "模板六",
                content = "模板内容6 自行更换"
            },
            seven = {
                title = "模板七",
                content = "模板内容7 自行更换"
            },
            eight = {
                title = "模板八",
                content = "模板内容8 自行更换"
            },
            nine = {
                title = "模板九",
                content = "模板内容9 自行更换"
            }
        }
    }
}
function MyAddon:OnInitialize()
     MyAddon.L = MyAddon:Locale( GetLocale() )
    --MyAddon.L = MyAddon:Locale("enUS")
    self:Print(MyAddon.L["Announce"])


    MyAddon.db = LibStub("AceDB-3.0"):New("AutoMessageDB", defaults, true)
    MyAddon.db.profile.message.one.send_status,
        MyAddon.db.profile.message.two.send_status,
        MyAddon.db.profile.message.three.send_status = false
    MyAddon:RegisterChatCommand("am", "ChatCommand")
    MyAddon:RegisterChatCommand("automessage", "ChatCommand")
    MyAddon:RegisterChatCommand("automsg", "ChatCommand")
    MyAddon:initTabs()
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
        table.insert(
            channels,
            {
                id = chanList[i],
                name = chanList[i + 1],
                isDisabled = chanList[i + 2] -- Not sure what a state of "blocked" would be
            }
        )
    end
    return channels
end
function MyAddon:RenderChannel()
    local channels = GetJoinedChannels()
    -- MyAddon:Print(channels[1].name)
    MyAddon.channel_id[1] = 999
    MyAddon.channel_name[1] = "|cff00A310"..MyAddon.L["select a channel"]
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
        local channel_one = MyAddon.channel_id[MyAddon.db.profile.message[_sender].send_channels.channel_one] --自定义频道
        local channel_two = MyAddon.channel_id[MyAddon.db.profile.message[_sender].send_channels.channel_two] --自定义频道
        local channel_three = MyAddon.channel_id[MyAddon.db.profile.message[_sender].send_channels.channel_three] --自定义频道
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
            SendChatMessage(send_content, "YELL")
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
        if channel_one ~= 999 then --自选频道1
            SendChatMessage(send_content, "CHANNEL", nil, channel_one)
        end
        if channel_two ~= 999 then --自选频道2
            SendChatMessage(send_content, "CHANNEL", nil, channel_two)
        end
        if channel_three ~= 999 then -- 自选频道3
            SendChatMessage(send_content, "CHANNEL", nil, channel_three)
        end
        -- MyAddon:Print("发送结束")
        -- MyAddon:Print("send_time")
        MyAddon:ScheduleTimer(
            function()
                prepare_send(MyAddon[_sender])
            end,
            send_time
        )
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
        wideget:SetText("|cff00A310"..MyAddon.L["select a channel"])
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
    --wideget:SetWidth(42)
    wideget:SetRelativeWidth(0.125)
    wideget:SetValue(_val)
    wideget:SetLabel(_label)
    wideget:SetCallback("OnValueChanged", _callback)
    return wideget
end
local function editbox_render(_width, _label, _current_template, _address, _callback)
    local wideget = AceGUI:Create("EditBox")
    wideget:SetLabel(_label)
    wideget:SetText(MyAddon.db.profile.template[_current_template][_address])
    wideget:SetRelativeWidth(_width)
    wideget:SetHeight(45)
    wideget:SetCallback(
        "OnTextChanged",
        function(widget, event, txt)
            -- body
            MyAddon.db.profile.template[_current_template][_address] = txt
            -- MyAddon:Print(MyAddon.db.profile.template[_current_template][_address])
        end
    )
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
    time_range:SetSliderValues(5, 70, 5)
    time_range:SetValue(MyAddon.db.profile.message[MyAddon.current_sender].send_time)
    time_range:SetCallback(
        "OnValueChanged",
        function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_time = val
        end
    )

    container:AddChild(time_range)
    local pre_sender = MyAddon.current_sender
    local pre_status = MyAddon.db.profile.message[pre_sender].send_status -- 状态

    local send_btn = AceGUI:Create("Button")
    if pre_status then
        send_btn:SetText("|cff00FF33"..MyAddon.L['stop'])
    else
        send_btn:SetText(MyAddon.L['send'])
    end
    send_btn:SetRelativeWidth(0.2)
    send_btn:SetCallback(
        "OnClick",
        function(wideget, event)
            local sender = MyAddon.current_sender
            local status = MyAddon.db.profile.message[sender].send_status -- 状态
            if not status then
                MyAddon.db.profile.message[sender].send_status = true
                wideget:SetText("|cff00FF33"..MyAddon.L['stop'])
                MyAddon:Print(string.upper(sender) .. " |cff00A310"..MyAddon.L['send'].."中....")
                prepare_send(sender)
            else
                wideget:SetText(MyAddon.L['send'])
                MyAddon.db.profile.message[sender].send_status = false
                MyAddon:Print(string.upper(sender) .. "|cffC70000 ■■"..MyAddon.L['stop'].."■■")
            end
        end
    )
    container:AddChild(send_btn)
    local tmplate_tmp = MyAddon.db.profile.template
    local send_template = MyAddon.db.profile.message[MyAddon.current_sender].send_template
    local txt_template_select =
        dropdown_template_render(
        send_template,
        tmplate_tmp[number_2_string(send_template)].title,
        MyAddon.L['template']..MyAddon.L['choose'],
        {
            tmplate_tmp.one.title,
            tmplate_tmp.two.title,
            tmplate_tmp.three.title,
            tmplate_tmp.four.title,
            tmplate_tmp.five.title,
            tmplate_tmp.six.title,
            tmplate_tmp.seven.title,
            tmplate_tmp.eight.title,
            tmplate_tmp.nine.title
        },
        function(wideget, event, val)
            MyAddon:Print(MyAddon.L['selected template '] .. val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_template = val
        end,
        0.3
    )
    container:AddChild(txt_template_select)

    local function checkbox_callback(wideget, event, val)
        -- MyAddon:Print(val)
        MyAddon.db.profile.message[MyAddon.current_sender].send_channels.yell = val
    end

    local yell =
        checkbox_render(
        MyAddon.db.profile.message[MyAddon.current_sender].send_channels.yell,
        "|cffFF1919"..MyAddon.L['Yell'],
        function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels.yell = val
        end
    )
    local say =
        checkbox_render(
        MyAddon.db.profile.message[MyAddon.current_sender].send_channels.say,
        MyAddon.L['Say'],
        function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels.say = val
        end
    )
    local guild =
        checkbox_render(
        MyAddon.db.profile.message[MyAddon.current_sender].send_channels.guild,
        "|cff1CFF24"..MyAddon.L['Guild'],
        function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels.guild = val
        end
    )
    local raid =
        checkbox_render(
        MyAddon.db.profile.message[MyAddon.current_sender].send_channels.raid,
        "|cffFF7C0A"..MyAddon.L['Raid'],
        function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels.raid = val
        end
    )
    container:AddChild(yell)
    container:AddChild(say)
    container:AddChild(guild)
    container:AddChild(raid)

    local select_channel_one =
        dropdown_render(
        MyAddon.db.profile.message[MyAddon.current_sender].send_channels.channel_one,
        MyAddon.L['Channel select one'],
        MyAddon.channel_name,
        function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels.channel_one = val
        end,
        0.5
    )
    local select_channel_two =
        dropdown_render(
        MyAddon.db.profile.message[MyAddon.current_sender].send_channels.channel_two,
        MyAddon.L['Channel select two'],
        MyAddon.channel_name,
        function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels.channel_two = val
        end,
        0.5
    )
    local select_channel_threee =
        dropdown_render(
        MyAddon.db.profile.message[MyAddon.current_sender].send_channels.channel_three,
        MyAddon.L['Channel select three'],
        -- {"|cff00A310未选", 1, 2, 3, 4, 5, 6, 7, 8, 9},
        MyAddon.channel_name,
        function(wideget, event, val)
            MyAddon.db.profile.message[MyAddon.current_sender].send_channels.channel_three = val
        end,
        0.5
    )
    container:AddChild(select_channel_one)
    container:AddChild(select_channel_two)
    container:AddChild(select_channel_threee)

    local send_all = AceGUI:Create("Button")
    send_all:SetHeight(40)
    send_all:SetText(MyAddon.L['send all'])
    send_all:SetRelativeWidth(0.5)
    send_all:SetCallback(
        "OnClick",
        function(wideget, event)
            MyAddon.db.profile.message.one.send_status,
                MyAddon.db.profile.message.two.send_status,
                MyAddon.db.profile.message.three.send_status = true,true,true
                    send_btn:SetText("|cff00FF33"..MyAddon.L['stop'])
                    prepare_send('one')   
                    prepare_send('two')   
                    prepare_send('three')   
            MyAddon:Print(string.upper("one two three") .. "|cffffffff ■■"..MyAddon.L['all send'].."■■")
        end
    )
    container:AddChild(send_all)
    local stop_btn = AceGUI:Create("Button")
    -- stop_btn:SetFullWidth(true)
    stop_btn:SetHeight(40)
    stop_btn:SetText(MyAddon.L['stop all'])
    stop_btn:SetRelativeWidth(0.5)
    stop_btn:SetCallback(
        "OnClick",
        function(wideget, event)
            MyAddon.db.profile.message.one.send_status,
                MyAddon.db.profile.message.two.send_status,
                MyAddon.db.profile.message.three.send_status = false,false,false
            -- MyAddon:Destory()
            Main_frame:Hide()
            MyAddon:initTabs()
            MyAddon:Print(string.upper("one two three") .. "|cffC70000 ■■"..MyAddon.L['all stoped'].."■■")
        end
    )
    container:AddChild(stop_btn)
end
local function Draw_invite(container)
    MyAddon:Print("invite module")
    local Label = AceGUI:Create("Label")
    -- heading:SetWidth(normal_width - padding)
    Label:SetRelativeWidth(1)
    -- heading:SetColor(0, 120, 255)
    Label:SetText("|cff5555ffinvite module：\n\nlearning....\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n.")
    container:AddChild(Label)
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
    local three_content = editbox_render(0.7, "模板内容", "three", "content")
    local four_content = editbox_render(0.7, "模板内容", "four", "content")
    local five_content = editbox_render(0.7, "模板内容", "five", "content")
    local six_content = editbox_render(0.7, "模板内容", "six", "content")
    local seven_content = editbox_render(0.7, "模板内容", "seven", "content")
    local eight_content = editbox_render(0.7, "模板内容", "eight", "content")
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
    Label:SetText(
        "|cff5555ff喊话功能使用介绍：\n" ..
            "|cffffffff1、定义喊话模班，本模板旨在存储喊话内容避免每次都需要重新输入\n" ..
                "2、设置喊话间隔时间\n" ..
                    "3、选择喊话频道，频道多选，自由定制\n" ..
                        "4、选择需要发送的内容模板序号\n" ..
                            "！！！注意喊话间隔时间，太频繁被屏蔽就糗了\n" ..
                                "|cffFF1919！！！因暴雪数据保存机制，填完模板后请至少正常退出一次游戏。让数据保存到本地，小退回人物选择界面或直接重载界面|cff047D00（测试标签页有快捷功能可用）|cffFF1919即可！！!\n" ..
                                    "|cffFFDC2B---本窗体会自动在前几次载入，之后会在后台静默等待命令。你可以使用命令把他叫出来干活---\n" ..
                                        "|cffFF1919大脚世界频道与大脚世界频道2[3,4...]互斥，其他频道同理！\n" ..
                                            "好了，愉快的喊起来吧。不喊了记得回来停掉哟\n" ..
                                                "|cff5555ff指令介绍：\n" .. "|cffFFDC2B/am /automessage /automsg\n"
    )
    container:AddChild(Label)
end
local function Draw_test(container)
    local Label = AceGUI:Create("Label")
    -- heading:SetWidth(normal_width - padding)
    Label:SetRelativeWidth(1)
    -- heading:SetColor(0, 120, 255)
    Label:SetText("|cff5555ff"..MyAddon.L["reload ui"].."：\n\n\n\n\n\n\n\n\n\n\n\n.")
    local reload_btn = AceGUI:Create("Button")
    reload_btn:SetFullWidth(true)
    reload_btn:SetHeight(40)
    reload_btn:SetText(MyAddon.L["reload ui"])
    --reload_btn:SetRelativeWidth(0.25)
    reload_btn:SetCallback(
        "OnClick",
        function(wideget, event)
            ReloadUI()
        end
    )
    local join_channel = AceGUI:Create("Button")
    join_channel:SetFullWidth(true)
    join_channel:SetHeight(30)
    join_channel:SetText(MyAddon.L['join channel'])
    -- join_channel:SetRelativeWidth(0.25)
    join_channel:SetCallback(
        "OnClick",
        function(wideget, event)
            MyAddon:Join_BigFoot_Channel_1_2_5()
            MyAddon:Print("join channel runing done")
        end
    )
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
    --scrollcontainer:SetFullHeight(true) -- probably?
    scrollcontainer:SetHeight(MyAddon.height - 200) -- probably?

    scrollcontainer:SetLayout("Fill") -- important!
    container:AddChild(scrollcontainer)
    local backframe = AceGUI:Create("ScrollFrame")
    backframe:SetLayout("Flow") -- probably?
    --backframe:SetFullWidth(true)
    --backframe:SetFullHeight(true) -- probably?
    --backframe:SetHeight(MyAddon.height - 200) -- probably?
    scrollcontainer:AddChild(backframe)
    --Draw_sender(backframe)
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
        {
            text = MyAddon.L['one'],
            value = "one"
        },
        {
            text = MyAddon.L['two'],
            value = "two"
        },
        {
            text = MyAddon.L['three'],
            value = "three"
        },
        {
            text = MyAddon.L['template'],
            value = "template"
        }
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
    --backframe:SetLayout("Flow") -- probably?
    --scrollcontainer:SetFullWidth(true)
    backframe:SetFullHeight(true) -- probably?
    backframe:SetHeight(MyAddon.height - 180) -- probably?
    scrollcontainer:AddChild(backframe)

    if group == "message" then
        Draw_sender_tab(backframe)
    elseif group == "invite" then
        Draw_invite(backframe)
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
    Main_frame:SetStatusText(MyAddon.L['status'])
    Main_frame:SetCallback(
        "OnClose",
        function(widget)
            AceGUI:Release(widget)
        end
    )
    tinsert(UISpecialFrames,AutoMessageFrame);
    -- Main_frame:EnableKeyboard(true)

    -- frame:SetScript("OnHide", Frame_OnClose)

    -- Fill Layout - the TabGroup widget will fill the whole frame
    Main_frame:SetLayout("Fill")

    -- Create the TabGroup
    local tabpannel = AceGUI:Create("TabGroup")
    local tab_option = {
        {
            text = MyAddon.L["Announce"],
            value = "message"
        },
        {
            text = MyAddon.L["Invite"],
            value = "invite"
        },
        {
            text = MyAddon.L["Help"],
            value = "help"
        },
        {
            text = MyAddon.L["Test"],
            value = "test"
        }
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
        LibStub("AceConfigCmd-3.0"):HandleCommand("am", "automessage", "automsg", input)
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
     --_local = 'enUS'
    local channels = {
        "大脚世界频道",
        "大脚世界频道2",
        "大脚世界频道3",
        "大脚世界频道4",
        -- "大脚世界频道5",
        -- "大脚世界频道6",
        -- "大脚世界频道7",
        -- "大脚世界频道7",
        -- "大脚世界频道8",
        -- "大脚世界频道9"
    }
    if _local == 'zhCN' then --default
    elseif _local == 'enUS' then -- rewrite channel here for you country
        channels = {}
    end

    for i, v in ipairs(channels)  do
        -- MyAddon:Print(v)
        JoinChannelByName(v)
    end
end
function MyAddon:Locale( _local )
    local L = {}
    if _local == 'zhCN' or _local == nil then -- defualt
        L["AddonName"] = "自动喊话"
        --Main tab
        L["Announce"] = "喊话"
        L["Invite"] = "邀请"
        L["Help"] = "帮助"
        L["Test"] = "测试"
        -- Announce tab
        L['one'] ="喊一"
        L['two'] ="二"
        L['three'] ="三"
        L['template'] = "模板"
        L['choose'] = '选择'
        L['selected template '] = "已选择的模板序号为"
        -- wideget 
        L["time gap"] = "时间间隔"
        L['Yell'] = '喊'
        L['Say'] = '说'
        L['Guild'] = '会'
        L['Raid'] = '团'
        L['Channel select one'] = '频道一'
        L['Channel select two'] = '频道二'
        L['Channel select three'] = '频道三'
        -- btn
        L['send'] = '发送'
        L['stop'] = '停止'
        L['send all'] = '发送所有'
        L['stop all'] = '停止所有'
        L['all send']= '都已发送'
        L['all stoped']= '都已停止'
        L['reload ui'] = '重载界面'
        L['join channel'] = '加入大脚世界频道1-4'
        L["select a channel"] = "选择一个频道"
        
        L['status'] = 'by 怀旧服 狮心·拾忆重逢 @20191028'
    elseif _local == 'enUS' then
        L["AddonName"] = 'AutoMessage'
        --Main tab
        L["Announce"] = "Announce"
        L["Invite"] = "Invite"
        L["Help"] = "Help"
        L["Test"] = "Test"
        -- Announce tab
        L['one'] ="one"
        L['two'] ="two"
        L['three'] ="three"
        L['template'] = "template"
        L['choose'] = 'choose'
        L['selected template '] = "you have selected template "
        -- wideget 
        L["time gap"] = "time gap"
        L['Yell'] = 'Y'
        L['Say'] = 'S'
        L['Guild'] = 'G'
        L['Raid'] = 'R'
        L['Channel select one'] = 'Channel select one'
        L['Channel select two'] = 'Channel select two'
        L['Channel select three'] = 'Channel select three'
        L["select a channel"] = "select a channel"
        --btn
        L['send'] = 'Send'
        L['stop'] = 'Stop'
        L['send all'] = 'Send All'
        L['stop all'] = 'Stop All'
        L['all send']= 'Already Send All'
        L['all stoped']= 'Already Stoped All'
        L['reload ui'] = 'Reload Ui'
        L['join channel'] = 'join channel bigfoot one2four'
        L['status'] = 'by reminiscence service 狮心·拾忆重逢 @20191028'
    end
    return L
end