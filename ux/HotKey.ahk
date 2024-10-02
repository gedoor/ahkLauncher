/************************************************************************
 * @description CapsLock + u 大小写转换, CapsLock + number 粘贴历史记录
 * @author kunfei
 ***********************************************************************/
#SingleInstance Force
#NoTrayIcon
#Include "..\lib\WinClip.ahk"
#Include "..\lib\WinEvent.ahk"
KeyHistory(0)

; 切换窗口后关闭大写锁定键
WinEvent.Active((*) => SetCapsLockState('Off'))

CapsLock:: {
    ; wait for Capslock to be released
    KeyWait('CapsLock')
    ; in 0.2 seconds and pressed again within 0.2 seconds
    if ((A_TimeSinceThisHotkey < 200) and KeyWait('CapsLock', 'D T0.2'))
    {
        SetCapsLockState !GetKeyState('CapsLock', 'T')
    }
}

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

;显示选中文字的信息
p:: {
    WinClip.SetText("", false)
    SendEvent("^c")
    cSelected := A_Clipboard
    if (cSelected) {
        size := StrLen(cSelected)
        ToolTip("字数:" size)
        SetTimer () => ToolTip(), -3000
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