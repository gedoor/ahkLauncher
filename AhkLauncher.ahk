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
    }
}

Send "^!+l"

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
    shellLink1 := IShellLink()
    shellLink1.SetTitle("打开导航文件夹")
    shellLink1.SetPath(A_ScriptDir "\launchDir.lnk")
    shellLink1.Commit

    shellLink2 := IShellLink()
    shellLink2.SetTitle("设置导航文件夹")
    shellLink2.SetIconLocation(A_ScriptDir "\RES\CONFIG.ICO", 0)
    shellLink2.SetPath(A_AhkPath)
    shellLink2.SetArguments(A_ScriptFullPath " setDir")
    shellLink2.Commit

    jumpList := ICustomDestinationList()
    jumpList.BeginList(&MinSlots, &removedCol)

    ; if removedCol.GetCount() > 0 {
    ;     removedCol.GetAt(0)
    ; }

    taskCol := IObjectCollection()
    taskCol.AddObject(shellLink1.comObj)
    taskCol.AddObject(shellLink2.comObj)

    recentCol := IObjectCollection()
    loop files "recent\*", "F"
    {
        if A_LoopFileAttrib ~= "[HS]"
            continue
        shellLink := IShellLink()
        shellLink.SetTitle(A_LoopFileName)
        if StrUpper(A_LoopFileExt) = "LNK" {
            FileGetShortcut(A_LoopFileFullPath, &outTarget, &outWrkDir, &outArgs)
            shellLink.SetPath(outTarget)
            shellLink.SetWorkingDirectory(outWrkDir)
            shellLink.SetArguments(outArgs)
        } else {
            shellLink.SetPath(A_LoopFileFullPath)
        }
        shellLink.Commit
        recentCol.AddObject(shellLink.comObj)
    }


    jumpList.AddUserTasks(taskCol.comObj)
    jumpList.AppendCategory("最近", recentCol.comObj)
    jumpList.AppendKnownCategory(0x2)
    jumpList.CommitList
}