;监控文件修改
#Include ..\lib\WatchFolder.ahk


WatchFolder("D:\Actionsoft\AWS\src\com", "FileChangeCallback", true, 0x00000010)


FileChangeCallback(path, notifications) {
    for key, notification in notifications {
        switch notification.Name {
            case "D:\Actionsoft\AWS\src\com\sy\common\file\web\page\fileManage.html":
                FileCopy(
                    "D:\Actionsoft\AWS\src\com\sy\common\file\web\page\fileManage.html",
                    "D:\Actionsoft\AWS\apps\install\com.awspaas.user.apps.file_manage\template\page\fileManage.html",
                    true
                )
            default:

        }
    }
}