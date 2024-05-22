#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#Include lib\JumpList.ahk

for arg in A_Args {
    switch arg {
        case "setDir": 
        {
            SelectLaunchDir()
            ExitApp
        }
    }
}

Send "^!+l"

Run "launcher.exe launchMenu.ahk show"

shellLink1 := ShellLinkW()
shellLink1.SetTitle("打开导航文件夹")
shellLink1.SetPath(A_ScriptDir "\launchDir.lnk")
shellLink1.Commit

shellLink2 := ShellLinkW()
shellLink2.SetTitle("设置导航文件夹")
shellLink2.SetPath(A_AhkPath)
shellLink2.SetArguments(A_ScriptFullPath " setDir")
shellLink2.Commit

slCol := EnumerableObjectCollection()
slCol.AddObject(shellLink1.comObj)
slCol.AddObject(shellLink2.comObj)

jumpList := CustomDestinationList()
jumpList.BeginList
jumpList.AddUserTasks(slCol.comObj)
jumpList.CommitList

SelectLaunchDir() {
    SelectedFolder := DirSelect(, 0, "选择导航文件夹")
    if SelectedFolder {
        FileCreateShortcut SelectedFolder, A_ScriptDir "\launchDir.lnk"
        return true
    } else {
        return false
    }
}