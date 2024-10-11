/************************************************************************
 * @description 
 * CapsLock + u 大小写转换, 
 * CapsLock + p 显示选中文字信息
 * CapsLock + number 粘贴历史记录
 * @author kunfei
 ***********************************************************************/
#SingleInstance Force
#NoTrayIcon
#Include "..\lib\WinClip.ahk"
#Include "..\lib\WinEvent.ahk"
#Include "..\lib\GoogleTranslate.ahk"
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
; This forces capslock into a modifying key & blocks the alt/start menus
*CapsLock:: Send '{Blind}{vkE8}'

#HotIf GetKeyState("CapsLock", "P")

; Disables Alt menu and Start Menu when CapsLock pressed!
LAlt:: return
RAlt:: return
LWin:: return
RWin:: return

;翻译
q:: {
    cSelected := GetSelectedText()
    text := GoogleTranslate(cSelected, &from := 'auto', 'zh')
    MsgBox text, "翻译"
}

;大小写转换
u:: {
    cSelected := GetSelectedText()
    if Trim(cSelected) {
        if (IsIncludeLowercase(cSelected)) {
            WinClip.SetText(StrUpper(cSelected), false, false)
        } else {
            WinClip.SetText(StrLower(cSelected), false, false)
        }
        SendEvent("^v")
    }
    SetTimer () => RestoreClip(), -1000
}

;显示选中文字的信息
p:: {
    cSelected := GetSelectedText()
    if Trim(cSelected) {
        strLenth := StrLen(cSelected)
        wordCount := StrLen(RegExReplace(cSelected, "\s+", ""))
        ToolTip("字符串长度:" strLenth "`n文字数量:" wordCount)
        SetTimer () => ToolTip(), -3000
    }
    SetTimer () => RestoreClip(), -1000
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

;获取选择的文本
GetSelectedText() {
    A_Clipboard := ""
    SendEvent("^c")
    if (ClipWait(1)) {
        cSelected := A_Clipboard
        SetTimer () => DeleteClipHistory(cSelected), -500
        return cSelected
    }
    return ""
}

;删除ClipHistory顶部记录
DeleteClipHistory(text) {
    if WinClip.History.Count > 0 && WinClip.History.Item[0].Content.GetText() = text {
        WinClip.History.Item[0].Delete()
    }
}

;恢复剪贴板
RestoreClip() {
    if (WinClip.History.Count > 0) {
        WinClip.History.Item[0].Push()
    }
}

;是否包含小写字母
IsIncludeLowercase(str) {
    return RegExMatch(str, "[a-z]") > 0
}