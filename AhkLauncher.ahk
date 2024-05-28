#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#Include lib\AppUtils.ahk
#Include lib\JumpList.ahk

AppUtils.SetCurrentProcessExplicitAppUserModelID(AppUserModelID)

for arg in A_Args {
    switch arg {
        case "setDir":
            {
                SelectLaunchDir()
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

createAppLnk()

JumpList.up(AppUserModelID)

createAppLnk() {
    appLnk := A_ScriptDir "\AhkLauncher.lnk"

    if not FileExist(appLnk) {
        shellLink := IShellLink()
        shellLink.SetPath(A_ScriptDir "\AhkLauncher.exe")
        shellLink.SetWorkingDirectory(A_ScriptDir)
        shellLink.SetTitle("AhkLauncher")
        shellLink.SetIconLocation(A_ScriptDir "\res\launcher.ico", 0)
        shellLink.SetAppUserModelID(AppUserModelID)
        shellLink.Commit()
        shellLink.Save(appLnk, true)
    }
}

SelectLaunchDir() {
    SelectedFolder := DirSelect(, 0, "选择导航文件夹")
    if SelectedFolder {
        FileCreateShortcut SelectedFolder, A_ScriptDir "\launchDir.lnk"
        return true
    } else {
        return false
    }
}