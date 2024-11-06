/************************************************************************
 * @description 鼠标手势
 ***********************************************************************/
#Requires AutoHotkey v2.0
#Include ..\lib\HotGestures.ahk
#SingleInstance Force
#NoTrayIcon
KeyHistory(0)
A_HotkeyInterval := 200  ; 此为默认值 (毫秒).
A_MaxHotkeysPerInterval := 200

gestureUp := HotGestures.Gesture("↑:0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10")
gestureDown := HotGestures.Gesture("↓:0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10")
gestureLeft := HotGestures.Gesture("←:-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0")
gestureRight := HotGestures.Gesture("→:10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0")
gestureUpDown := HotGestures.Gesture("↑↓:0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10")

hgs := HotGestures(0.1, 20)
hgs.Register(gestureUp, "Top")
hgs.Register(gestureDown, "Bottom")
hgs.Register(gestureLeft, "Back")
hgs.Register(gestureRight, "Forward")
hgs.Register(gestureUpDown, "Refresh")

wheel := false

#HotIf GetKeyState("RButton", "P")

WheelDown:: {
    Send("{PgDn}")
    global wheel := true
}

WheelUp:: {
    Send("{PgUp}")
    global wheel := true
}

#HotIf

lastRButton := 0

$RButton:: {
    global lastRButton
    if (A_TickCount - lastRButton < 300) {
        return
    }
    global wheel := false
    hgs.Start()
    KeyWait("RButton")
    hgs.Stop()
    lastRButton := A_TickCount
    if hgs.Result.Valid {
        switch hgs.Result.MatchedGesture {
            case gestureUp: ; ↑
            {
                Send("^{Home}")
                return
            }
            case gestureDown: ; ↓
            {
                Send("^{End}")
                return
            }
            case gestureLeft: ; ←
            {
                if isInternetExplorer() {
                    Send("!{Left}")
                } else {
                    Send("{Browser_Back}")
                }
                return
            }
            case gestureRight: ; →
            {
                if isInternetExplorer() {
                    Send("!{Right}")
                } else {
                    Send("{Browser_Forward}")
                }
                return
            }
            case gestureUpDown: ; ↑↓
            {
                Send("{Browser_Refresh}")
                return
            }
            default: return
        }
    }
    else if (!wheel) {
        SendEvent("{RButton}")
    }
}

isInternetExplorer() {
    curCtrl := ControlGetFocus("A")
    curCtrlClassNN := ""
    Try curCtrlClassNN := ControlGetClassNN(curCtrl)
    return InStr(curCtrlClassNN, "Internet Explorer")
}