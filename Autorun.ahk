#Include lib\AppUtils.ahk
#Include lib\ArrayExtensions.ahk
#NoTrayIcon

autoRuns := StrSplit(IniRead(configIni, "config", "autoRuns", ""), ",")

for fileName in autoRuns {
    path := A_ScriptDir "\ux\" fileName
    if not DirExist(path) {
        autoRuns.RemoveAt(A_Index)
        IniWrite(autoRuns.Join(), configIni, "config", "autoRuns")
    } else {
        Run '"' A_AhkPath '" "' path '"'
    }
}