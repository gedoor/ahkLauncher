#Requires AutoHotkey v2.0
#SingleInstance Ignore
#NoTrayIcon
#Include lib\AppUtils.ahk
#Include lib\Json.ahk
#Include lib\ArrayExtensions.ahk
#Include lib\Utils.ahk
TraySetIcon("res\launcher.ico")
DetectHiddenWindows True
AppUtils.SetCurrentProcessExplicitAppUserModelID(AppUserModelID)

startUpLink := A_Startup "\launchMenu.lnk"

createStartUpLink()

configUi := Constructor()

configUi.Show("w620 h420")


Constructor()
{
    cfgGui := Gui()
    cfgGui.Title := "AhkLauncher配置"
    cfgGui.AddText("x24 y16 w572 h59", "这是一个将文件夹显示为导航菜单的应用,因为trueLuanchBar不更新了,对win11支持不好,所以开发了这个应用.")
    isStartUp := FileExist(startUpLink) ? 1 : 0
    CheckBoxStartUp := cfgGui.AddCheckbox("x24 y56 w100 h23 Checked" isStartUp, "开机启动")
    loadAhkScript := IniRead(configIni, "config", "loadAhkScript", 0)
    CheckBoxLoadAhkScript := cfgGui.AddCheckbox("x124 y56 w200 h23 Checked" loadAhkScript, "加载 AHK 脚本菜单")
    cfgGui.AddGroupBox("x24 y90 w572 h50", "导航文件夹")

    launcherLnk := A_ScriptDir "\launchDir.lnk"
    launcherPath := ""
    if FileExist(launcherLnk) {
        FileGetShortcut launcherLnk, &launcherPath
    }
    editLuncherDir := cfgGui.AddEdit("x32 y108 w460", launcherPath)
    buttonLuncherDir := cfgGui.AddButton("x500 y106 w40 h24", "选择")

    cfgGui.AddText("x24 y150", "AHK Script")
    uxView := cfgGui.AddListView("x24 y170 w572 h230 +NoSort +Grid Backgrounde0e0e0", ["name", "autoRun", "status"])
    uxView.ModifyCol(1, 300)
    uxView.ModifyCol(2, 80)
    uxView.ModifyCol(3, 80)

    autoRuns := StrSplit(IniRead(configIni, "config", "autoRuns", ""), ",")
    uxFiles := Array()
    loop files A_ScriptDir "\ux\*.ahk", "F"
    {
        uxFiles.Push({
            name: A_LoopFileName,
            autoRun: Autorun(A_LoopFileName),
            status: Status(A_LoopFileName)
        })
    }

    for item in uxFiles {
        uxView.Add(, item.name, item.autoRun, item.status)
    }

    uxView.OnEvent("ContextMenu", Ctrl_ContextMenu)

    buttonLuncherDir.OnEvent("Click", SelectLaunchDirHandler)
    CheckBoxStartUp.OnEvent("Click", StartUpEventHandler)
    CheckBoxLoadAhkScript.OnEvent("Click", LoadAhkScriptEventHandler)
    cfgGui.OnEvent('Close', (*) => ExitApp())

    SetTimer(UpUxView, 1000)

    UpUxView() {
        for item in uxFiles {
            isAutorun := Autorun(item.name)
            mStatus := Status(item.name)
            if (item.autoRun != isAutorun || item.status != mStatus) {
                item.autoRun := isAutorun
                item.status := mStatus
                uxView.Modify(A_Index, , item.name, item.autoRun, item.status)
            }
        }
    }

    SelectLaunchDirHandler(*) {
        launcherPath := AppUtils.SelectLaunchDir()
        if (launcherPath) {
            editLuncherDir.Text := launcherPath
        }
    }

    StartUpEventHandler(*) {
        if (CheckBoxStartUp.Value) {
            createStartUpLink
        } else {
            FileDelete(startUpLink)
        }
    }

    LoadAhkScriptEventHandler(*) {
        if (CheckBoxLoadAhkScript.Value) {
            IniWrite(1, configIni, "config", "loadAhkScript")
        } else {
            IniWrite(0, configIni, "config", "loadAhkScript")
        }
    }

    cMenu := Menu()
    cMenu.DefineProp("data", { Value: "" })
    Ctrl_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
        cMenu.Delete
        cMenu.data := Item
        ux := uxFiles[Item]
        If (ux.status) {
            cMenu.Add("结束", EndScript)
        } else {
            cMenu.Add("运行", RunScript)
        }
        if (ux.autoRun = "✕") {
            cMenu.Add("启用自动运行", EnableAutoRun)
        } else {
            cMenu.Add("禁用自动运行", DisableAutoRun)
        }
        cMenu.Show()
    }

    EnableAutoRun(ItemName, ItemPos, MyMenu) {
        filePos := MyMenu.data
        fileName := uxFiles[filePos].name
        if (autoRuns.IndexOf(fileName) = 0) {
            autoRuns.Push(fileName)
            IniWrite(autoRuns.Join(), configIni, "config", "autoRuns")
        }
        index := uxFiles.IndexOf(fileName)
        if (index > 0) {
            uxView.Modify(index, , fileName, "✓", Status(fileName))
        }
    }

    DisableAutoRun(ItemName, ItemPos, MyMenu) {
        filePos := MyMenu.data
        fileName := uxFiles[filePos].name
        fileIndex := autoRuns.IndexOf(fileName)
        if (fileIndex > 0) {
            autoRuns.RemoveAt(fileIndex)
            IniWrite(autoRuns.Join(), configIni, "config", "autoRuns")
        }
        index := uxFiles.IndexOf(fileName)
        if (index > 0) {
            uxView.Modify(index, , fileName, "✕", Status(fileName))
        }
    }

    RunScript(ItemName, ItemPos, MyMenu) {
        filePos := MyMenu.data
        fileName := uxFiles[filePos].name
        uxPath := A_ScriptDir "\ux\" fileName
        Run '"' A_AhkPath '" "' uxPath '"'
    }

    EndScript(ItemName, ItemPos, MyMenu) {
        filePos := MyMenu.data
        fileName := uxFiles[filePos].name
        Utils.sendCmd("退出", A_ScriptDir "\ux\" fileName)
    }

    Autorun(fileName) {
        return autoRuns.IndexOf(fileName) ? "✓" : "✕"
    }

    Status(fileName) {
        path := A_ScriptDir "\ux\" fileName
        return WinExist(path " - AutoHotkey") ? "运行中" : ""
    }

    return cfgGui
}


createStartUpLink() {
    shellLink := IShellLink()
    shellLink.SetPath(A_ScriptDir "\AhkLauncher.exe")
    shellLink.SetWorkingDirectory(A_ScriptDir)
    shellLink.SetTitle("AhkLauncher")
    shellLink.SetArguments(A_ScriptDir "\launchMenu.ahk")
    shellLink.SetIconLocation(A_ScriptDir "\res\launcher.ico", 0)
    shellLink.SetAppUserModelID(AppUserModelID)
    shellLink.Commit()
    shellLink.Save(startUpLink, true)
}