#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#Include lib\AppUtils.ahk
#Include lib\JumpList.ahk
;@Ahk2Exe-SetMainIcon res\launcher.ico
AppUtils.SetCurrentProcessExplicitAppUserModelID(AppUserModelID)
KeyHistory(0)

for arg in A_Args {
    switch arg {
        case "setDir":
            {
                AppUtils.SelectLaunchDir()
                ExitApp
            }
        case "upJumpList":
            {
                JumpList.up()
                ExitApp
            }
        case "reload":
            {
                Send "^!+{F21}"
                ExitApp
            }
    }
}

Send "^!+{F20}"

Run A_AhkPath " launchMenu.ahk show"

AppUtils.createAppLnk()

JumpList.up(AppUserModelID)