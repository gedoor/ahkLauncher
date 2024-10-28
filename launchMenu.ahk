#Requires AutoHotkey v2.0
#SingleInstance Ignore
#Include lib\AppUtils.ahk
#Include lib\JumpList.ahk
#Include lib\ThemeUtils.ahk
#Include lib\LaunchMenuUtils.ahk
#Include lib\Utils.ahk
AppUtils.SetCurrentProcessExplicitAppUserModelID(AppUserModelID)
;@Ahk2Exe-SetMainIcon res\launcher.ico
KeyHistory(0)
CoordMode "Mouse", "Screen"
CoordMode "Menu", "Screen"
DetectHiddenWindows True
Persistent true
WM_MENURBUTTONUP := 0x0122
WM_UNINITMENUPOPUP := 0x0125
WM_MENUSELECT := 0x11F

TraySetIcon("res\launcher.ico")
A_IconTip := "导航菜单"
A_TrayMenu.Delete()
A_TrayMenu.Add("Config", (*) => Run(A_AhkPath " Config.ahk"))
A_TrayMenu.Default := "1&"
A_TrayMenu.Add("Reload", (*) => Reload())
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Add()
A_TrayMenu.Add("SelectLaunchDir", SelectLaunchDir)
A_TrayMenu.Add("OpenLaunchDir", (*) => Run(launcherLnk))
A_TrayMenu.Add("OpenAppDir", (*) => Run("explore " A_ScriptDir))
A_TrayMenu.Add()

launcherLnk := A_ScriptDir "\launchDir.lnk"

if !FileExist(launcherLnk) {
    AppUtils.SelectLaunchDir()
}

FileGetShortcut launcherLnk, &launcherPath

dpiZom := A_ScreenDPI / 96

IconSize := Integer(32 * dpiZom)

BulidLauncherMenu()

OnMessage(AppMsgNum, AppMsgCallback)

OnMessage(WM_MENURBUTTONUP, MenuRButtonUpCallback)

OnMessage(WM_UNINITMENUPOPUP, HideToolTip)

OnMessage(WM_MENUSELECT, HideToolTip)

for arg in A_Args {
    if arg = "show"
        showLauncherMenu()
}

Run '"' A_AhkPath '" "' A_ScriptDir '\Autorun.ahk"'

return

BulidLauncherMenu() {
    try {
        launcTree := getDirTree(launcherPath)
    } catch TimeoutError as err {
        MsgBox(err.Message)
        return
    }

    global launcherMenu
    global scriptMenu
    launcherMenu := createDirTreeMenu(launcTree, IconSize, LauncherMenuCallback)

    loadAhkScript := IniRead(configIni, "config", "loadAhkScript", 0)

    if (loadAhkScript) {
        scriptMenu := Menu()
        scriptMenu.DefineProp("data", { Value: Array() })

        loop files A_ScriptDir "\ux\*.ahk", "F"
        {
            menuName := SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - 4)
            scriptMenu.Add(menuName, LauncherMenuCallback)
            scriptMenu.data.Push({ path: A_LoopFileFullPath, name: menuName })
        }

        launcherMenu.Add("AhkScript", scriptMenu)
        launcherMenu.SetIcon("AhkScript", A_AhkPath, 1, IconSize)
    }

    A_TrayMenu.Add("Launcher", launcherMenu)
}

AppMsgCallback(wParam, lParam, *) {
    switch wParam {
        case 1111:
            showLauncherMenu()
        case 1112:
            BulidLauncherMenu()
    }
}

showLauncherMenu() {
    if not IsSet(launcherMenu) {
        ToolTip("加载中")
        SetTimer () => ToolTip(), -3000
        return
    }

    global dpiZom
    global IconSize
    nowDpiZom := A_ScreenDPI / 96
    if nowDpiZom != dpiZom {
        dpiZom := nowDpiZom
        IconSize := Integer(32 * dpiZom)
        BulidLauncherMenu()
        showLauncherMenu()
        return
    }

    for item in scriptMenu.data {
        if WinExist(item.path " - AutoHotkey") {
            scriptMenu.SetIcon(item.name, "%SystemRoot%\system32\shell32.dll", 295)
        } else {
            scriptMenu.SetIcon(item.name, "*")
        }
    }

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
        Run('"' A_AhkPath '" "' rPath '"')
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

MenuRButtonUpCallback(wParam, lParam, *) {
    menuItem := findMenu(launcherMenu.data, lParam, wParam)
    if menuItem {
        path := menuItem.path
        if path ~= ".*?.lnk$" {
            FileGetShortcut path, &path
        }
        ToolTip(path)
    }

}

SelectLaunchDir(*) {
    if AppUtils.SelectLaunchDir() {
        Reload
    }
}

HideToolTip(*) {
    ToolTip()
}