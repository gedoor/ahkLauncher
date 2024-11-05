/************************************************************************
 * @description 
 * CapsLock 双击切换大小写
 * CapsLock + LButton 拖动窗口
 * CapsLock + RButton 调整窗口大小
 * CapsLock + u 大小写转换
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
SetWinDelay 2
CoordMode "Mouse"

; 切换窗口后关闭大写锁定键
WinEvent.Active((*) => SetCapsLockState('Off'))

; 禁用左Shift切换输入法,不改变shift原有功能
~LShift:: Send "{Blind}{vkFF}"

; 双击CapsLock切换大小写
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
*CapsLock:: Send '{Blind}{vkFF}'


#HotIf GetKeyState("CapsLock", "P")

; Disables Alt menu and Start Menu when CapsLock pressed!
LAlt:: return
RAlt:: return
LWin:: return
RWin:: return

; 翻译
q:: {
    cSelected := GetSelectedText()
    text := GoogleTranslate(cSelected, &from := 'auto', 'zh')
    MsgBox text, "翻译"
}

; 大小写转换
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

; 显示选中文字的信息
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

; 粘贴剪贴板历史第1条记录
1:: {
    if WinClip.History.Count >= 1 {
        WinClip.SetText(WinClip.History.Item[0].Content.GetText(), false)
        SendEvent("^v")
    }
}

; 粘贴剪贴板历史第2条记录
2:: {
    if WinClip.History.Count >= 2 {
        WinClip.SetText(WinClip.History.Item[1].Content.GetText(), false)
        SendEvent("^v")
    }
}

; 粘贴剪贴板历史第3条记录
3:: {
    if WinClip.History.Count >= 3 {
        WinClip.SetText(WinClip.History.Item[2].Content.GetText(), false)
        SendEvent("^v")
    }
}

; 粘贴剪贴板历史第4条记录
4:: {
    if WinClip.History.Count >= 4 {
        WinClip.SetText(WinClip.History.Item[3].Content.GetText(), false)
        SendEvent("^v")
    }
}

; 粘贴剪贴板历史第5条记录
5:: {
    if WinClip.History.Count >= 5 {
        WinClip.SetText(WinClip.History.Item[4].Content.GetText(), false)
        SendEvent("^v")
    }
}

; 拖动窗口
LButton::
{
    ; Get the initial mouse position and window id, and
    ; abort if the window is maximized.
    MouseGetPos &KDE_X1, &KDE_Y1, &KDE_id
    if WinGetMinMax(KDE_id)
        return
    ; Get the initial window position.
    WinGetPos &KDE_WinX1, &KDE_WinY1, &width, &height, KDE_id ; &width and &height added by Cebolla
    Loop
    {
        if !GetKeyState("LButton", "P") ; Break if button has been released.
            break
        MouseGetPos &KDE_X2, &KDE_Y2 ; Get the current mouse position.
        KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
        KDE_Y2 -= KDE_Y1
        KDE_WinX2 := (KDE_WinX1 + KDE_X2) ; Apply this offset to the window position.
        KDE_WinY2 := (KDE_WinY1 + KDE_Y2)
        WinMove KDE_WinX2, KDE_WinY2, width, height, KDE_id ; Move the window to the new position.
    }
}

; 调整窗口大小
RButton::
{
    ; Get the initial mouse position and window id, and
    ; abort if the window is maximized.
    MouseGetPos &KDE_X1, &KDE_Y1, &KDE_id
    style := WinGetStyle(KDE_id)
    ; 样式没有0x40000 无法调整大小的窗口
    if not (style & 0x40000) {
        return
    }
    if WinGetMinMax(KDE_id)
        return
    ; Get the initial window position and size.
    WinGetPos &KDE_WinX1, &KDE_WinY1, &KDE_WinW, &KDE_WinH, KDE_id
    ; Define the window region the mouse is currently in.
    ; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
    if (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
        KDE_WinLeft := 1
    else
        KDE_WinLeft := -1
    if (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
        KDE_WinUp := 1
    else
        KDE_WinUp := -1
    Loop
    {
        if !GetKeyState("RButton", "P") ; Break if button has been released.
            break
        MouseGetPos &KDE_X2, &KDE_Y2 ; Get the current mouse position.
        ; Get the current window position and size.
        WinGetPos &KDE_WinX1, &KDE_WinY1, &KDE_WinW, &KDE_WinH, KDE_id
        KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
        KDE_Y2 -= KDE_Y1
        ; Then, act according to the defined region.
        WinMove KDE_WinX1 + (KDE_WinLeft + 1) / 2 * KDE_X2  ; X of resized window
        , KDE_WinY1 + (KDE_WinUp + 1) / 2 * KDE_Y2  ; Y of resized window
        , KDE_WinW - KDE_WinLeft * KDE_X2  ; W of resized window
        , KDE_WinH - KDE_WinUp * KDE_Y2  ; H of resized window
        , KDE_id
        KDE_X1 := (KDE_X2 + KDE_X1) ; Reset the initial position for the next iteration.
        KDE_Y1 := (KDE_Y2 + KDE_Y1)
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