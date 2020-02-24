WinTitle:= "魔兽世界"
if (WinExist(WinTitle) > 0) {
    Sleep 3000
    WinActivate,
    Loop {
        ; Get pixel color at the top left corner
        WinGetPos, X, Y, , , %WinTitle%
        PixelGetColor, color,  X + 16,  Y + 39
        ;PixelGetColor, color, 8, 31
        ;msgbox,%color%
        ; if WinActive("World of Warcraft") or WinActive("魔兽世界")  and color = "0x333333" {
        if (color = "0x333333") {
            ;msgbox,%X%,%Y%
            MouseClick, X2 ;Trigger mouse click on BUTTON5(X2)
            ;msgbox, '123'
            Random delay, 5000, 8000
            Sleep delay ;avoid spamming button and being accidentally flagged for botting by WoW's anti-cheat system.
        }

        Sleep 500 ;5ms corresponds to 200 FPS / Hz.Should fit all screen refresh rates.
    }

}