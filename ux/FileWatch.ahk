;监控文件修改
#NoTrayIcon
#SingleInstance Force
#Include ..\lib\WatchFolder.ahk
#Include ..\lib\Json.ahk

configPath := A_ScriptDir "\data\fileChangeListener.json"
if not DirExist("data") {
    DirCreate("data")
}

data := [{
    dir: "D:\Actionsoft\AWS\src\com",
    files: [
        {
            file: "D:\Actionsoft\AWS\src\com\sy\common\file\web\page\fileManage.html",
            action: "copy",
            to: "D:\Actionsoft\AWS\apps\install\com.awspaas.user.apps.file_manage\template\page\fileManage.html"
        },
        {
            file: "D:\Actionsoft\AWS\src\com\sy\common\file\web\page\ftp.html",
            action: "copy",
            to: "D:\Actionsoft\AWS\apps\install\com.awspaas.user.apps.file_manage\template\page\ftp.html"
        },
        {
            file: "D:\Actionsoft\AWS\src\com\sy\common\file\action.xml",
            action: "copy",
            to: "D:\Actionsoft\AWS\apps\install\com.awspaas.user.apps.file_manage\web\com.awspaas.user.apps.file_manage\action.xml"
        },
        {
            file: "D:\Actionsoft\AWS\src\com\sy\common\dwplus\web\js\dwPlus.js",
            action: "copy",
            to: "D:\Actionsoft\AWS\apps\install\com.awspaas.user.apps.common.dwplus\web\com.awspaas.user.apps.common.dwplus\js\dwPlus.js"
        },
    ]
}]

wJson := JSON.Dump(data)

try FileDelete configPath
FileAppend(wJson, configPath)

watch := Map()

for item in data {
    watchFileMap := Map()
    for watchFile in item.files {
        watchFileMap[watchFile.file] := watchFile
    }
    watch[item.dir] := watchFileMap
    WatchFolder(item.dir, "FileChangeCallback", true, 0x00000010)
}


FileChangeCallback(path, notifications) {
    watchFileMap := watch.Get(path, "")
    if not watchFileMap
        return
    for key, notification in notifications {
        watchFile := watchFileMap.Get(notification.Name, "")
        if watchFile {
            switch watchFile.action {
                case "copy":
                    FileCopy(
                        watchFile.file,
                        watchFile.to,
                        true
                    )
                    
            }
        }
    }
}