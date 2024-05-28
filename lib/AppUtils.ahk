AppUserModelID := "legado.ahk.launcher"

class AppUtils {

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