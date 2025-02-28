#Include IShellLink.ahk

AppUserModelID := "legado.ahk.launcher"
AppMsgNum := DllCall("RegisterWindowMessage", "Str", "AhkLauncher")
configIni := A_ScriptDir "\Config.ini"

class AppUtils {

    /**
     * 使用AppUserModelID创建App快捷方式
     */
    static createAppLnk(icon, iconIndex := 0, userModelId := AppUserModelID) {
        appName := SubStr(A_ScriptName, 1, StrLen(A_ScriptName) - 4)
        appLnk := A_ScriptDir "\" appName ".lnk"

        if not FileExist(appLnk) {
            shellLink := IShellLink()
            shellLink.SetPath(A_ScriptDir "\AhkLauncher.exe")
            shellLink.SetArguments(A_ScriptFullPath)
            shellLink.SetWorkingDirectory(A_ScriptDir)
            shellLink.SetTitle(appName)
            shellLink.SetIconLocation(icon, iconIndex)
            shellLink.SetAppUserModelID(userModelId)
            shellLink.Commit()
            shellLink.Save(appLnk, true)
        }
    }

    static SelectLaunchDir() {
        SelectedFolder := DirSelect(, 0, "选择导航文件夹")
        if SelectedFolder {
            FileCreateShortcut SelectedFolder, A_ScriptDir "\launchDir.lnk"
            return SelectedFolder
        } else {
            return ""
        }
    }

    static SetCurrentProcessExplicitAppUserModelID(appId) {
        DllCall("Shell32.dll\SetCurrentProcessExplicitAppUserModelID", "str", appId)
    }

    static GetCurrentProcessExplicitAppUserModelID() {
        DllCall("Shell32.dll\GetCurrentProcessExplicitAppUserModelID", "ptr*", &x := 0)
        if x = 0 {
            return ""
        }
        appId := StrGet(x)
        DllCall("Ole32.dll\CoTaskMemFree", "ptr", x)
        return appId
    }

    static GetCurrentApplicationUserModelId() {
        rc := DllCall('GetCurrentApplicationUserModelId', 'UInt*', &length := 0, 'Ptr', 0)

        ERROR_INSUFFICIENT_BUFFER := 122
        APPMODEL_ERROR_NO_APPLICATION := 15703
        if (rc != ERROR_INSUFFICIENT_BUFFER)
        {
            if (rc = APPMODEL_ERROR_NO_APPLICATION)
                return ""
        }

        sizeofwchar_t := 2

        try
            fullName := Buffer(length * sizeofwchar_t)
        catch MemoryError
        {
            MsgBox("Error allocating memory\n")
            ExitApp(2)
        }

        rc := DllCall('GetCurrentApplicationUserModelId', 'UInt*', &length, 'Ptr', fullName)

        ERROR_SUCCESS := 0
        if (rc != ERROR_SUCCESS)
        {
            MsgBox("Error " rc " retrieving ApplicationUserModelId\n")
            ExitApp(3)
        }
        MsgBox(StrGet(fullName))
    }

}