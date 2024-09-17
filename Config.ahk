#Requires AutoHotkey v2.0
#SingleInstance Ignore
#NoTrayIcon
#Include lib\AppUtils.ahk
#Include lib\Json.ahk
#Include lib\ArrayExtensions.ahk
#Include lib\Utils.ahk
DetectHiddenWindows True
AppUtils.SetCurrentProcessExplicitAppUserModelID(AppUserModelID)

startUpLink := A_Startup "\launchMenu.lnk"

createStartUpLink()

configUi := Constructor()

configUi.Show("w620 h420")


Constructor()
{
    myGui := Gui()
    myGui.Title := "AhkLauncher配置"
    myGui.AddText("x24 y16 w546 h59", "这是一个将文件夹显示为导航菜单的应用,因为trueLuanchBar不更新了,对win11支持不好,所以开发了这个应用.")
    isStartUp := FileExist(startUpLink) ? 1 : 0
    CheckBoxStartUp := myGui.AddCheckbox("x24 y56 w100 h23 Checked" isStartUp, "开机启动")
    loadAhkScript := IniRead(configIni, "config", "loadAhkScript", 0)
    CheckBoxLoadAhkScript := myGui.AddCheckbox("x124 y56 w200 h23 Checked" loadAhkScript, "加载 AHK 脚本菜单")
    myGui.AddGroupBox("x24 y90 w560 h50", "导航文件夹")

    launcherLnk := A_ScriptDir "\launchDir.lnk"
    launcherPath := ""
    if FileExist(launcherLnk) {
        FileGetShortcut launcherLnk, &launcherPath
    }
    editLuncherDir := myGui.AddEdit("x32 y106 w460 h23", launcherPath)
    buttonLuncherDir := myGui.AddButton("x500 y106 w40 h23", "选择")

    myGui.AddText("x24 y150", "AHK Script")
    uxView := myGui.AddListView("x24 y170 w560 h200 +NoSort", ["name", "autoRun", "status"])
    uxView.ModifyCol(1, 200)
    uxView.ModifyCol(2, 80)
    uxView.ModifyCol(3, 80)

    uxFiles := Array()
    loop files A_ScriptDir "\ux\*.ahk", "F"
    {
        uxFiles.Push(A_LoopFileName)
    }

    autoRuns := StrSplit(IniRead(configIni, "config", "autoRuns", ""), ",")

    for item in uxFiles {
        uxView.Add(, item, Autorun(item), Status(item))
    }

    uxView.OnEvent("ContextMenu", Ctrl_ContextMenu)

    buttonLuncherDir.OnEvent("Click", SelectLaunchDirHandler)
    CheckBoxStartUp.OnEvent("Click", StartUpEventHandler)
    CheckBoxLoadAhkScript.OnEvent("Click", LoadAhkScriptEventHandler)
    myGui.OnEvent('Close', (*) => ExitApp())

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
        fileName := uxFiles[Item]
        If (Status(fileName)) {
            cMenu.Add("结束", EndScript)
        }
        cMenu.Add("启用自动运行", EnableAutoRun)
        cMenu.Add("禁用自动运行", DisableAutoRun)
        cMenu.Show()
    }

    EnableAutoRun(ItemName, ItemPos, MyMenu) {
        filePos := MyMenu.data
        fileName := uxFiles[filePos]
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
        fileName := uxFiles[filePos]
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

    EndScript(ItemName, ItemPos, MyMenu) {
        filePos := MyMenu.data
        fileName := uxFiles[filePos]
        Utils.sendCmd("退出", "ahk_id " A_ScriptDir "\ux\" fileName)
        uxView.Modify(filePos, , fileName, Autorun(fileName), Status(fileName))
    }

    Autorun(fileName) {
        return autoRuns.IndexOf(fileName) ? "✓" : "✕"
    }

    Status(fileName) {
        path := A_ScriptDir "\ux\" fileName
        return WinExist(path " - AutoHotkey") ? "运行中" : ""
    }

    return myGui
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