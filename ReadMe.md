这是一个魔兽世界自动喊话界面版插件，目的是为了方便组队的时候间隔时间发送组队信息至公共频道。
鉴于暴雪粑粑决定将sendchatmessage 方法设置为私有方法，不再可以自由使用。现采用中间件的方式来发送消息，现版本插件喊话依赖于messagequeue，请自行下载释放到addon目录；另还需要配合AutoHotKey使用。
前期准备:
1,下载automessage messagequeue 释放只addon 目录，下载autohotkey并安装
2，点击启动messagequeue下的PixelTrigger脚本启动ahk功能，作为后备。默认每条消息间隔5-8秒
3，游戏内打开automessage，配置相关信息模板 点击发送。
ps：机制为automessage 为messagequeue 提供消息队列，messagequeue监测ahk的鼠标点击事件并在游戏内触发后发送消息到对应频道。
AutoMessage Plugin Use Guide
ZN-CH
    功能介绍：
        在设定的频道，按照设定的间隔时间，发送设定的模板内容
    使用介绍：
        1、定义喊话模班，本模板旨在存储喊话内容避免每次都需要重新输入
        2、设置喊话间隔时间
        3、选择喊话频道，频道多选，自由定制
        4、选择需要发送的内容模板序号
        !!!注意喊话间隔时间，太频繁被屏蔽就糗了
        !!!因暴雪数据保存机制，填完模板后请至少正常退出一次游戏。让数据保存到本地，小退回人物选择界面或直接重载界面（测试标签页有快捷功能可用）即可!!!
        ---本窗体会自动在前几次载入，之后会在后台静默等待命令。你可以使用命令把他叫出来干活---
        大脚世界频道与大脚世界频道2[3,4...]互斥，其他频道同理！
        好了，愉快的喊起来吧。不喊了记得回来停掉哟
    指令介绍： 
        /am /automessage /automsg

EN

    Function introduction:
        In the set channel, according to the set interval time, send the set template 
    contentUser introduction:
        1. Define the shoutout module. This template is designed to store the shoutout content to avoid re-entering it every time
        2. Set the interval time for Shouting
        3, choose Shouting channel, channel selection, free customization
        4. Select the content template serial number to be sent
        !!!!Pay attention to the time between the words, too often blocked embarrassing!!!!
        !!!!Due to blizzard's data saving mechanism, please exit the game at least once after completing the template.Let the data save to the local, small return to the character selection interface or directly reload the interface (test TAB has a shortcut function available) can be!!!
        -- -this window will load automatically in the first few times, and then silently wait for commands in the background.You can call him out to work by ---
        commandBigfoot world channel and bigfoot world channel 2[3,4...]Mutual exclusion, the other channels are the same!
        All right, cheer up.Don't shout remember to come back to stop 
    Instruction introduction:
        /am /automessage /automsg# AutoMessage
