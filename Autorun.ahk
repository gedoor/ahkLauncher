#Include lib\AppUtils.ahk
#Include lib\ArrayExtensions.ahk
#NoTrayIcon

autoRuns := StrSplit(IniRead(configIni, "config", "autoRuns", ""), ",")
removed := []

for fileName in autoRuns {
    path := A_ScriptDir "\ux\" fileName
    if FileExist(path) {
        Run '"' A_AhkPath '" "' path '"'
    } else {
        removed.Push(A_Index)
    }
}

if removed.Length > 0 {
    for index in removed.Reverse() {
        autoRuns.RemoveAt(index)
    }
    IniWrite(autoRuns.Join(), configIni, "config", "autoRuns")
}