#Requires AutoHotkey v2.0
#SingleInstance Ignore
#Include lib\AppUtils.ahk
#Include lib\JumpList.ahk
#Include lib\ThemeUtils.ahk
#Include lib\TreeMenuUtils.ahk
#Include lib\Utils.ahk
AppUtils.SetCurrentProcessExplicitAppUserModelID(AppUserModelID)
;@Ahk2Exe-SetMainIcon res\launcher.ico
KeyHistory(0)
CoordMode "Mouse", "Screen"
CoordMode "Menu", "Screen"

TraySetIcon("res\launcher.ico")
A_IconTip := "导航菜单"
A_TrayMenu.Delete()
A_TrayMenu.Add("open", TrayMenuCallback)
A_TrayMenu.Default := "open"
A_TrayMenu.Add("Reload", TrayMenuCallback)
A_TrayMenu.Add("Exit", TrayMenuCallback)
A_TrayMenu.Add()
A_TrayMenu.Add("SelectLaunchDir", TrayMenuCallback)
A_TrayMenu.Add("OpenLaunchDir", TrayMenuCallback)
A_TrayMenu.Add("OpenAppDir", TrayMenuCallback)

launcherLnk := A_ScriptDir "\launchDir.lnk"

if !FileExist(launcherLnk) {
    AppUtils.SelectLaunchDir()
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

loadAhkScript := IniRead(configIni, "config", "loadAhkScript", 0)

if (loadAhkScript){
    scriptMenu := Menu()
    scriptMenu.DefineProp("data", { Value: Array() })
    
    loop files A_ScriptDir "\ux\*.*", "F"
    {
        menuName := SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - 4)
        scriptMenu.Add(menuName, LauncherMenuCallback)
        scriptMenu.data.Push({ path: A_LoopFileFullPath })
    }
    
    launcherMenu.Add("AhkScript", scriptMenu)
    launcherMenu.SetIcon("AhkScript", A_AhkPath, 1, IconSize)
}

for arg in A_Args {
    if arg = "show"
        showLauncherMenu()
}

A_TrayMenu.Add()
A_TrayMenu.Add("Launcher", launcherMenu)

OnMessage(AppMsgNum, MsgCallback)

Persistent true

return

MsgCallback(wParam, lParam, msg, hwnd) {
    switch wParam {
        case 1111:
            showLauncherMenu()
        case 1112:
            Reload()
    }
}

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
    rPath := MyMenu.data[ItemPos].path
    if not DirExist("recent") {
        DirCreate("recent")
    }
    if (rPath ~= ".*?.ahk$") {
        Run '"' A_AhkPath '" "' rPath '"'
        return
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
    JumpList.up(AppUserModelID)
}

TrayMenuCallback(ItemName, ItemPos, MyMenu) {
    switch ItemName, false {
        case "open":
            Run A_AhkPath " Config.ahk"
        case "Reload":
            Reload
        case "Exit":
            ExitApp
        case "SelectLaunchDir":
            if AppUtils.SelectLaunchDir() {
                Reload
            }
        case "OpenLaunchDir":
            Run launcherLnk
        case "OpenAppDir":
            Run "explore " A_ScriptDir
    }
}