; 管理员权限
runAsAdmin() {
    if not A_IsAdmin
    {
        try
        {
            Run '*RunAs "' A_AhkPath '" "' A_ScriptFullPath
            ExitApp
        }
        catch error
        {
            MsgBox("you did not allow the script to run!")
        }
    }
}