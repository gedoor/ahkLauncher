#Requires AutoHotkey v2.0
#SingleInstance Ignore
#Include lib\util.ahk

CoordMode "Mouse", "Screen"
CoordMode "Menu", "Screen"

A_IconTip := "导航菜单"
A_TrayMenu.Delete()
A_TrayMenu.Add("Reload", TrayMenuCallback)
A_TrayMenu.Add("Exit", TrayMenuCallback)
A_TrayMenu.Add("SelectLaunchDir", TrayMenuCallback)

launcherLnk := A_ScriptDir "\launchDir.lnk"

if !FileExist(launcherLnk) {
    SelectLaunchDir()
}

FileGetShortcut launcherLnk, &launcherPath

dpiZom := A_ScreenDPI / 96

IconSize := Integer(32 * dpiZom)

try {
    launcTree := getDirTree(launcherPath)
} catch TimeoutError as err{
    MsgBox(err.Message)
    return
}

launcherMenu := createDirTreeMenu(launcTree, IconSize, LauncherMenuCallback)

A_TrayMenu.Add()
A_TrayMenu.Add("Launcher", launcherMenu)
A_TrayMenu.Default := "Launcher"

showLauncherMenu()

^!+l:: showLauncherMenu()

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

    launcherMenu.Show(menu_x, menu_y)
}

LauncherMenuCallback(ItemName, ItemPos, MyMenu) {
    rPath := MyMenu.files[ItemPos].path
    try {
        Run(rPath)
    } catch {
        FileGetShortcut(rPath, &outTarget, &outWrkDir, &outArgs)
        try {
            Run(outTarget " " outArgs, outWrkDir)
        } catch {
            try {
                pf64 := EnvGet("ProgramW6432")
                _outTarget64 := StrReplace(outTarget, A_ProgramFiles, pf64, , , 1)
                Run(_outTarget64 " " outArgs, outWrkDir)
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
        default:
            SelectLaunchDir()
            Reload
    }
}

SelectLaunchDir() {
    SelectedFolder := DirSelect(, 0, "选择导航文件夹")
    if SelectedFolder
        FileCreateShortcut SelectedFolder, A_ScriptDir "\launchDir.lnk"
}