;监控文件修改
#NoTrayIcon
#SingleInstance Force
#Include ..\lib\WatchFolder.ahk
#Include ..\lib\Json.ahk
#Include ..\lib\RunCmd.ahk
#Include ..\lib\ArrayExtensions.ahk

configPath := A_ScriptDir "\data\fileChangeListener.json"
if not DirExist("data") {
    DirCreate("data")
}

wJson := FileRead(configPath)

data := JSON.Load(wJson)

for item in data {
    WatchFolder(item["dir"], "FileChangeCallback", true, 0x00000010)
}

FileChangeCallback(path, notifications) {
    watchDirIndex := data.Find((v) => v["dir"] = path)
    if watchDirIndex > 0 {
        watchDir := data[watchDirIndex]
        for key, notification in notifications {
            filePath := notification.name
            watchFileIndex := watchDir["files"].Find((v) => v["file"] = filePath)
            if watchFileIndex > 0 {
                watchFile := watchDir["files"][watchFileIndex]
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
                                RunCMD(watchFile["todo"])
                            } catch {
                                TrayTip(, "AHK FileWatch")
                            }
                        }
                    }
                }
            }
        }
    }
}