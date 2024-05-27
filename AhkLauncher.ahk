#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#Include lib\AppUtils.ahk
#Include lib\ICustomDestinationList.ahk
#Include lib\IShellLink.ahk
#Include lib\IObjectCollection.ahk
#Include lib\ArrayExtensions.ahk

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

appLnk := A_ScriptDir "\AhkLauncher.lnk"

if not FileExist(appLnk){
    appLnk := A_ScriptDir "\AhkLauncher.lnk"
    shellLink := IShellLink()
    shellLink.SetPath(A_ScriptDir "\AhkLauncher.exe")
    shellLink.SetTitle("AhkLauncher")
    shellLink.SetIconLocation(A_ScriptDir "\res\launcher.ico", 0)
    shellLink.Commit()
    shellLink.Save(appLnk, true)
}

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
    taskCol.AddObject(shellLink)

    shellLink := IShellLink()
    shellLink.SetTitle("打开导航文件夹")
    shellLink.SetPath(A_ScriptDir "\launchDir.lnk")
    shellLink.Commit
    taskCol.AddObject(shellLink)

    shellLink := IShellLink()
    shellLink.SetTitle("设置导航文件夹")
    shellLink.SetIconLocation(A_ScriptDir "\RES\CONFIG.ICO", 0)
    shellLink.SetPath(A_AhkPath)
    shellLink.SetArguments(A_ScriptFullPath " setDir")
    shellLink.Commit
    taskCol.AddObject(shellLink)

    shellLink := IShellLink()
    shellLink.SetTitle("刷新导航菜单")
    shellLink.SetIconLocation(A_ScriptDir "\RES\REFRESH.ICO", 0)
    shellLink.SetPath(A_AhkPath)
    shellLink.SetArguments(A_ScriptFullPath " reload")
    shellLink.Commit
    taskCol.AddObject(shellLink)

    jumpList := ICustomDestinationList()
    jumpList.BeginList(&MinSlots, &removedCol)
    jumpList.AddUserTasks(taskCol)

    removedCount := removedCol.GetCount()
    loop removedCount
    {
        rsl := IShellLink(removedCol.GetAt(A_Index - 1, IShellLink.Type))
        fileName := rsl.GetDescription()
        FileDelete(A_ScriptDir "\recent\" fileName)
    }

    recentArray := []
    loop files "recent\*", "F"
    {
        if A_LoopFileAttrib ~= "[HS]"
            continue
        recentArray.Push({
            name: A_LoopFileName,
            ext: A_LoopFileExt,
            path: A_LoopFileFullPath,
            created: A_LoopFileTimeCreated
        })
    }
    recentArray.Sort("N R", "created")

    if recentArray.Length > 6 {
        loop recentArray.Length - 6
        {
            FileDelete(recentArray[-A_Index].path)
        }
        recentArray.RemoveAt(7, recentArray.Length - 6)
    }

    if recentArray.Length > 0 {
        recentCol := IObjectCollection()
        for file in recentArray
        {
            shellLink := IShellLink()
            if file.ext != "" {
                title := SubStr(file.Name, 1, StrLen(file.name) - StrLen(file.ext) - 1)
                shellLink.SetTitle(title)
            } else {
                shellLink.SetTitle(file.name)
            }
            shellLink.SetDescription(file.name)
            shellLink.SetPath(file.path)
            shellLink.Commit
            recentCol.AddObject(shellLink)
        }
        jumpList.AppendCategory("最近", recentCol)
    }

    jumpList.CommitList
}