/************************************************************************
 * @description 清理资源管理器图标缓存
 ***********************************************************************/

#Requires AutoHotkey v2.0
#NoTrayIcon
#Include ..\lib\RunAsAdmin.ahk

runAsAdmin()

try FileDelete("%localappdata%\Iconcache.db")

ProcessClose("explorer.exe")