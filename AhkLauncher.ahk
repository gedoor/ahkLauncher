#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#Include lib\AppUtils.ahk
#Include lib\LauncherJumpList.ahk
;@Ahk2Exe-SetMainIcon res\launcher.ico
AppUtils.SetCurrentProcessExplicitAppUserModelID(AppUserModelID)
KeyHistory(0)
DetectHiddenWindows True

for arg in A_Args {
    switch arg {
        case "setDir":
        {
            AppUtils.SelectLaunchDir()
            ExitApp
        }
        case "upJumpList":
        {
            LauncherJumpList.up()
            ExitApp
        }
        case "reload":
        {
            try {
                PostMessage(AppMsgNum, 1112, 1112, , "launchMenu.ahk - AutoHotkey")
            } catch {
                Run A_AhkPath " launchMenu.ahk"
            }
            ExitApp
        }
    }
}

try {
    PostMessage(AppMsgNum, 1111, 1111, , "launchMenu.ahk - AutoHotkey")
} catch {
    Run A_AhkPath " launchMenu.ahk show"
}

AppUtils.createAppLnk(A_ScriptDir "\res\launcher.ico")

LauncherJumpList.up(AppUserModelID)