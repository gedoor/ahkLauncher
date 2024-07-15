#Requires AutoHotkey v2.0
#SingleInstance Ignore
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
    myGui.Add("Text", "x24 y16 w546 h59", "这是一个将文件夹显示为导航菜单的应用,因为trueLuanchBar不更新了,对win11支持不好,所以开发了这个应用.")
    isStartUp := FileExist(startUpLink) ? 1 : 0
    CheckBoxStartUp := myGui.Add("CheckBox", "x24 y56 w267 h23 Checked" isStartUp, "开机启动")
    loadAhkScript := IniRead(configIni, "config", "loadAhkScript", 0)
    CheckBoxLoadAhkScript := myGui.Add("CheckBox", "x24 y86 w266 h23 Checked" loadAhkScript, "加载 AHK 脚本")
    CheckBoxStartUp.OnEvent("Click", StartUpEventHandler)
    CheckBoxLoadAhkScript.OnEvent("Click", LoadAhkScriptEventHandler)
    myGui.OnEvent('Close', (*) => ExitApp())

    StartUpEventHandler(*){
        if (CheckBoxStartUp.Value) {
            createStartUpLink
        } else {
            FileDelete(startUpLink)
        }
    }

    LoadAhkScriptEventHandler(*){
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