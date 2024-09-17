#Include lib\AppUtils.ahk
#NoTrayIcon

autoRuns := StrSplit(IniRead(configIni, "config", "autoRuns", ""), ",")

for fileName in autoRuns {
    path := A_ScriptDir "\ux\" fileName
    Run '"' A_AhkPath '" "' path '"'
}