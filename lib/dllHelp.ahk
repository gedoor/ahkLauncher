class dllHelp {

    static __New() {
        this.LoadDllFunction("user32.dll", "PrivateExtractIconsW")
    }

    static LoadDllFunction(file, function)
    {
        if !hModule := DllCall("GetModuleHandleW", "Wstr", file, "UPtr")
            hModule := DllCall("LoadLibraryW", "Wstr", file, "UPtr")

        ret := DllCall("GetProcAddress", "Ptr", hModule, "AStr", function, "UPtr")
        if !ret
            throw OSError("Could not load function '" function "'")
        else
            this.DefineProp("p" function, { Value: ret })
    }

    static IconExtract(icoPath, iconNum, size) {
        ;http://msdn.microsoft.com/en-us/library/ms648075%28v=VS.85%29.aspx
        DllCall(this.pPrivateExtractIconsW, "Str", icoPath, "UInt", iconNum, "UInt", size, "UInt", size, "Ptr*", &handle := 0, "Ptr", 0, "UInt", 1, "UInt", 0)
        if !handle
        {
            SplitPath(icoPath, , , &Ext)
            if (Ext = "exe")
                DllCall(this.pPrivateExtractIconsW, "Str", "shell32.dll", "UInt", 2, "UInt", size, "UInt", size, "Ptr*", &handle := 0, "Ptr", 0, "UInt", 1, "UInt", 0)
        }
        return handle
    }

}