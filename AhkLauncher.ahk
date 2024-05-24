#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#Include lib\ICustomDestinationList.ahk
#Include lib\IShellLink.ahk
#Include lib\IObjectCollection.ahk

for arg in A_Args {
    switch arg {
        case "setDir":
            {
                SelectLaunchDir()
                ExitApp
            }
        case "upJumpList":
            {
                upJumpList()
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

upJumpList()


SelectLaunchDir() {
    SelectedFolder := DirSelect(, 0, "选择导航文件夹")
    if SelectedFolder {
        FileCreateShortcut SelectedFolder, A_ScriptDir "\launchDir.lnk"
        return true
    } else {
        return false
    }
}

upJumpList() {

    taskCol := IObjectCollection()

    shellLink := IShellLink()
    shellLink.SetTitle("打开应用文件夹")
    shellLink.SetPath(A_ScriptDir)
    shellLink.Commit
    taskCol.AddObject(shellLink.comObj)

    shellLink := IShellLink()
    shellLink.SetTitle("打开导航文件夹")
    shellLink.SetPath(A_ScriptDir "\launchDir.lnk")
    shellLink.Commit
    taskCol.AddObject(shellLink.comObj)

    shellLink := IShellLink()
    shellLink.SetTitle("设置导航文件夹")
    shellLink.SetIconLocation(A_ScriptDir "\RES\CONFIG.ICO", 0)
    shellLink.SetPath(A_AhkPath)
    shellLink.SetArguments(A_ScriptFullPath " setDir")
    shellLink.Commit
    taskCol.AddObject(shellLink.comObj)

    shellLink := IShellLink()
    shellLink.SetTitle("刷新导航菜单")
    shellLink.SetIconLocation(A_ScriptDir "\RES\REFRESH.ICO", 0)
    shellLink.SetPath(A_AhkPath)
    shellLink.SetArguments(A_ScriptFullPath " reload")
    shellLink.Commit
    taskCol.AddObject(shellLink.comObj)

    jumpList := ICustomDestinationList()
    jumpList.BeginList(&MinSlots, &removedCol)
    jumpList.AddUserTasks(taskCol.comObj)

    removedCount := removedCol.GetCount()
    loop removedCount
    {
        rsl := IShellLink(removedCol.GetAt(A_Index - 1, IShellLink.Type))
        fileName := rsl.GetDescription()
        FileDelete(A_ScriptDir "\recent\" fileName)
    }

    recentCol := IObjectCollection()
    loop files "recent\*", "F"
    {
        if A_LoopFileAttrib ~= "[HS]"
            continue
        shellLink := IShellLink()
        if A_LoopFileExt != "" {
            title := SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - StrLen(A_LoopFileExt) - 1)
            shellLink.SetTitle(title)
        } else {
            shellLink.SetTitle(A_LoopFileName)
        }
        shellLink.SetDescription(A_LoopFileName)
        shellLink.SetPath(A_LoopFileFullPath)
        shellLink.Commit
        recentCol.AddObject(shellLink.comObj)
    }
    jumpList.AppendCategory("最近", recentCol.comObj)

    jumpList.CommitList
}
