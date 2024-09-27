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
    SendEvent "^c"
    cSelected := A_Clipboard
    WinClip.History.Item[0].Delete()
    if (cSelected) {
        if (IsUpper(cSelected)) {
            WinClip.SetText(StrLower(cSelected), false)
        } else {
            WinClip.SetText(StrUpper(cSelected), false)
        }
        SendEvent "^v"
    }
}

#HotIf