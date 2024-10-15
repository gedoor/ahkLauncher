;监控文件修改
#NoTrayIcon
#SingleInstance Force
#Include ..\lib\WatchFolder.ahk
#Include ..\lib\Json.ahk
#Include ..\lib\StdoutToVar.ahk

configPath := A_ScriptDir "\data\fileChangeListener.json"
if not DirExist("data") {
    DirCreate("data")
}

wJson := FileRead(configPath)

data := JSON.Load(wJson)

watch := Map()

for item in data {
    watchFileMap := Map()
    for watchFile in item.get("files", []) {
        watchFileMap[watchFile.get("file")] := watchFile
    }
    watch[item["dir"]] := watchFileMap
    WatchFolder(item["dir"], "FileChangeCallback", true, 0x00000010)
}

FileChangeCallback(path, notifications) {
    watchFileMap := watch.Get(path, "")
    if not watchFileMap
        return
    for key, notification in notifications {
        watchFile := watchFileMap.Get(notification.Name, "")
        if watchFile {
            switch watchFile["action"] {
                case "copy":
                {
                    FileCopy(
                        watchFile["file"],
                        watchFile["todo"],
                        true
                    )
                }
                case "cmd":
                {
                    try {
                        StdoutToVar(watchFile["todo"])
                    } catch {
                        TrayTip(, "AHK FileWatch")
                    }
                }
            }
        }
    }
}