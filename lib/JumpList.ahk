#Requires AutoHotkey v2.0

#Include ICustomDestinationList.ahk
#Include IShellLink.ahk
#Include IObjectCollection.ahk
#Include ArrayExtensions.ahk

class JumpList {

    /**
     * 更新任务栏跳转列表
     * @param {String} appId AppUserModelID
     */
    static up(appId?){

        taskCol := IObjectCollection()

        shellLink := IShellLink()
        shellLink.SetTitle("打开应用文件夹")
        shellLink.SetPath(A_ScriptDir)
        shellLink.Commit()
        taskCol.AddObject(shellLink)
    
        shellLink := IShellLink()
        shellLink.SetTitle("打开导航文件夹")
        shellLink.SetPath(A_ScriptDir "\launchDir.lnk")
        shellLink.Commit()
        taskCol.AddObject(shellLink)
    
        shellLink := IShellLink()
        shellLink.SetTitle("刷新导航菜单")
        shellLink.SetIconLocation(A_ScriptDir "\RES\REFRESH.ICO", 0)
        shellLink.SetPath(A_AhkPath)
        shellLink.SetArguments(A_ScriptFullPath " reload")
        shellLink.Commit()
        taskCol.AddObject(shellLink)
    
        shellLink := IShellLink()
        shellLink.SetTitle("设置")
        shellLink.SetIconLocation(A_ScriptDir "\RES\CONFIG.ICO", 0)
        shellLink.SetPath(A_AhkPath)
        shellLink.SetArguments(A_ScriptDir "\Config.ahk")
        shellLink.Commit()
        taskCol.AddObject(shellLink)
    
        jumpList := ICustomDestinationList()
        if IsSet(appId) {
            jumpList.SetAppID(appId)
        }
        jumpList.BeginList(&MinSlots, &removedCol)
        jumpList.AddUserTasks(taskCol)
    
        removedCount := removedCol.GetCount()
        loop removedCount
        {
            rsl := IShellLink(ComValue(0xD, removedCol.GetAt(A_Index - 1, IShellLink.Type)))
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
                shellLink.Commit()
                recentCol.AddObject(shellLink)
            }
            jumpList.AppendCategory("最近", recentCol)
        }
    
        jumpList.CommitList
    }
    
}