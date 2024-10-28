#Include ..\lib\GestureRecorder.ahk
#NoTrayIcon
DllCall("Shell32.dll\SetCurrentProcessExplicitAppUserModelID", "str", "GestureRecorder")

GestureRecorder()