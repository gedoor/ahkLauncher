/************************************************************************
 * @description 鼠标手势录入
 ***********************************************************************/
#Requires AutoHotkey v2.0
#Include ..\lib\GestureRecorder.ahk
#NoTrayIcon
DllCall("Shell32.dll\SetCurrentProcessExplicitAppUserModelID", "str", "GestureRecorder")

GestureRecorder.Show