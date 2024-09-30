/************************************************************************
 * @description CapsLock + u 大小写转换, CapsLock + number 粘贴历史记录
 * @author kunfei
 ***********************************************************************/
#SingleInstance Force
#NoTrayIcon
KeyHistory(0)
#Include "..\lib\WinClip.ahk"


CapsLock:: {
    KeyWait('CapsLock')                               ; wait for Capslock to be released
    if (A_TimeSinceThisHotkey < 200)                  ; in 0.2 seconds
        and KeyWait('CapsLock', 'D T0.2')                 ; and pressed again within 0.2 seconds
        and (A_PriorKey = 'CapsLock')                     ; block other keys
        SetCapsLockState !GetKeyState('CapsLock', 'T')
}
*CapsLock:: Send '{Blind}{vk07}'                     ; This forces capslock into a modifying key & blocks the alt/start menus

#HotIf GetKeyState("CapsLock", "P")

; ---- Your hotkeys go here! ----
LAlt:: return                                        ; Disables Alt menu when CapsLock + Alt is pressed.
RAlt:: return
LWin:: return                                        ; Suppresses the Start Menu.
RWin:: return

;大小写转换
u:: {
    WinClip.SetText("", false)
    SendEvent("^c")
    cSelected := A_Clipboard
    if (cSelected) {
        if (IsIncludeLowercase(cSelected)) {
            WinClip.SetText(StrUpper(cSelected), false)
        } else {
            WinClip.SetText(StrLower(cSelected), false)
        }
        SendEvent("^v")
    }
    if (WinClip.History.Count > 0) {
        Sleep(1000)
        WinClip.History.Item[0].Push()
    }
}

;粘贴剪贴板历史第1条记录
1:: {
    if WinClip.History.Count >= 1 {
        WinClip.SetText(WinClip.History.Item[0].Content.GetText(), false)
        SendEvent("^v")
    }
}

;粘贴剪贴板历史第2条记录
2:: {
    if WinClip.History.Count >= 2 {
        WinClip.SetText(WinClip.History.Item[1].Content.GetText(), false)
        SendEvent("^v")
    }
}

;粘贴剪贴板历史第3条记录
3:: {
    if WinClip.History.Count >= 3 {
        WinClip.SetText(WinClip.History.Item[2].Content.GetText(), false)
        SendEvent("^v")
    }
}

;粘贴剪贴板历史第4条记录
4:: {
    if WinClip.History.Count >= 4 {
        WinClip.SetText(WinClip.History.Item[3].Content.GetText(), false)
        SendEvent("^v")
    }
}

;粘贴剪贴板历史第5条记录
5:: {
    if WinClip.History.Count >= 5 {
        WinClip.SetText(WinClip.History.Item[4].Content.GetText(), false)
        SendEvent("^v")
    }
}


#HotIf

;是否包含小写字母
IsIncludeLowercase(str) {
    return RegExMatch(str, "[a-z]") > 0
}