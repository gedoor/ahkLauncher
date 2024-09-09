#Include ..\lib\HotGestures.ahk
#SingleInstance Force
#NoTrayIcon
KeyHistory(0)
A_HotkeyInterval := 200  ; 此为默认值 (毫秒).
A_MaxHotkeysPerInterval := 200

gesture1 := HotGestures.Gesture("↑:0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10")
gesture2 := HotGestures.Gesture("↓:0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10")
gesture3 := HotGestures.Gesture("←:-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0|-10,0")
gesture4 := HotGestures.Gesture("→:10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0|10,0")
gesture5 := HotGestures.Gesture("↑↓:0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,-10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10|0,10")

hgs := HotGestures(0.1, 20)
hgs.Register(gesture1, "Top")
hgs.Register(gesture2, "Bottom")
hgs.Register(gesture3, "Back")
hgs.Register(gesture4, "Forward")
hgs.Register(gesture5, "Refresh")

rButtonDown := false
wheel := false

WheelDown:: {
    if (rButtonDown) {
        Send("{PgDn}")
        global wheel
        wheel := true
    } else {
        Send("{WheelDown}")
    }
}

WheelUp:: {
    if (rButtonDown) {
        Send("{PgUp}")
        global wheel
        wheel := true
    } else {
        Send("{WheelUp}")
    }
}

lastRButton := 0

$RButton:: {
    if (A_TickCount - lastRButton < 100) {
        return
    }
    global lastRButton
    global wheel
    global rButtonDown
    rButtonDown := true
    wheel := false
    hgs.Start()
    KeyWait("RButton")
    rButtonDown := false
    hgs.Stop()
    lastRButton := A_TickCount
    if hgs.Result.Valid {
        switch hgs.Result.MatchedGesture {
            case gesture1: ; ↑
            {
                Send("^{Home}")
                return
            }
            case gesture2: ; ↓
            {
                Send("^{End}")
                return
            }
            case gesture3: ; ←
            {
                Send("{Browser_Back}")
                return
            }
            case gesture4: ; →
            {
                Send("{Browser_Forward}")
                return
            }
            case gesture5: ; ↑↓
            {
                Send("{Browser_Refresh}")
                return
            }
            default: return
        }
    }
    else if (!wheel) {
        Send("{RButton}")
    }
}