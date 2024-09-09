#Requires AutoHotkey v2.0
#SingleInstance Ignore
#NoTrayIcon
#Include lib\AppUtils.ahk
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