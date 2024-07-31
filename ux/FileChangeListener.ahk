;监控文件修改
#NoTrayIcon
#SingleInstance Force
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
            case "D:\Actionsoft\AWS\src\com\sy\common\file\web\page\ftp.html":
                FileCopy(
                    "D:\Actionsoft\AWS\src\com\sy\common\file\web\page\ftp.html",
                    "D:\Actionsoft\AWS\apps\install\com.awspaas.user.apps.file_manage\template\page\ftp.html",
                    true
                )
            case "D:\Actionsoft\AWS\src\com\sy\common\file\action.xml":
                FileCopy(
                    "D:\Actionsoft\AWS\src\com\sy\common\file\action.xml",
                    "D:\Actionsoft\AWS\apps\install\com.awspaas.user.apps.file_manage\web\com.awspaas.user.apps.file_manage\action.xml",
                    true
                )
            case "D:\Actionsoft\AWS\src\com\sy\common\dwplus\web\js\dwPlus.js":
                FileCopy(
                    "D:\Actionsoft\AWS\src\com\sy\common\dwplus\web\js\dwPlus.js",
                    "D:\Actionsoft\AWS\apps\install\com.awspaas.user.apps.common.dwplus\web\com.awspaas.user.apps.common.dwplus\js\dwPlus.js",
                    true
                )
        }
    }
}