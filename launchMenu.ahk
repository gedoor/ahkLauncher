#Requires AutoHotkey v2.0
#SingleInstance Ignore
#Include lib\ThemeUtils.ahk
#Include lib\util.ahk

;@Ahk2Exe-SetMainIcon res\launcher.ico

CoordMode "Mouse", "Screen"
CoordMode "Menu", "Screen"

TraySetIcon("res\launcher.ico")
A_IconTip := "导航菜单"
A_TrayMenu.Delete()
A_TrayMenu.Add("Reload", TrayMenuCallback)
A_TrayMenu.Add("Exit", TrayMenuCallback)
A_TrayMenu.Add()
A_TrayMenu.Add("SelectLaunchDir", TrayMenuCallback)
A_TrayMenu.Add("OpenLaunchDir", TrayMenuCallback)
A_TrayMenu.Add("OpenAppDir", TrayMenuCallback)

launcherLnk := A_ScriptDir "\launchDir.lnk"

if !FileExist(launcherLnk) {
    SelectLaunchDir()
}

FileGetShortcut launcherLnk, &launcherPath

dpiZom := A_ScreenDPI / 96

IconSize := Integer(32 * dpiZom)

try {
    launcTree := getDirTree(launcherPath)
} catch TimeoutError as err {
    MsgBox(err.Message)
    return
}

launcherMenu := createDirTreeMenu(launcTree, IconSize, LauncherMenuCallback)

A_TrayMenu.Add()
A_TrayMenu.Add("Launcher", launcherMenu)
A_TrayMenu.Default := "Launcher"

for arg in A_Args {
    if arg = "show"
        showLauncherMenu()
}

^!+F20:: showLauncherMenu()
^!+F21:: Reload()

return

showLauncherMenu() {
    if not IsSet(launcherMenu)
        return

    MouseGetPos(&mouseX, &mouseY)
    ; default menu pos to mouse pos
    menu_x := mouseX, menu_y := mouseY
    ;获取活动区域
    MonitorGetWorkArea(, &wLeft, &wTop, &wRight, &wBottom)

    menuW := 80 * dpiZom

    if mouseX > menuW {
        menu_x := mouseX - menuW
    }

    if mouseY > wBottom {
        menu_y := wBottom
    }
    ThemeUtils.darkMenuMode(ThemeUtils.SysIsDarkMode)
    launcherMenu.Show(menu_x, menu_y)
}

LauncherMenuCallback(ItemName, ItemPos, MyMenu) {
    rPath := MyMenu.files[ItemPos].path
    if not DirExist("recent") {
        DirCreate("recent")
    }
    try {
        Run(rPath)
        FileCreateShortcut(rPath, "recent\" ItemName)
    } catch {
        FileGetShortcut(rPath, &outTarget, &outWrkDir, &outArgs)
        try {
            Run(outTarget " " outArgs, outWrkDir)
            FileCreateShortcut(outTarget, "recent\" ItemName, outWrkDir, outArgs)
        } catch {
            try {
                pf64 := EnvGet("ProgramW6432")
                _outTarget64 := StrReplace(outTarget, A_ProgramFiles, pf64, , , 1)
                Run(_outTarget64 " " outArgs, outWrkDir)
                FileCreateShortcut(_outTarget64, "recent\" ItemName, outWrkDir, outArgs)
            } catch {
                MsgBox("运行" rPath "失败." A_LastError)
            }

        }
    }
    
}

TrayMenuCallback(ItemName, ItemPos, MyMenu) {
    switch ItemName, false {
        case "Reload":
            Reload
        case "Exit":
            ExitApp
        case "SelectLaunchDir":
            if SelectLaunchDir() {
                Reload
            }
        case "OpenLaunchDir":
            Run launcherLnk
        case "OpenAppDir":
            Run "explore " A_ScriptDir
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