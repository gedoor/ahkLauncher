#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance Force
#Include ..\lib\ArrayExtensions.ahk
#Include ..\lib\Utils.ahk
DetectHiddenWindows True

processArray := Array()

myGui := Gui()
myGui.Title := "AHK脚本进程管理"
lv := myGui.AddListView("r20 w700", ["Name"])
lv.OnEvent("ContextMenu", Ctrl_ContextMenu)

myGui.Opt("+MaxSizex200 +MaxSizey200")
myGui.Show()
myGui.OnEvent("Close", Gui_Close)

upAhkProcess()

cMenu := Menu()
cMenu.DefineProp("data", { Value: "" })
cMenu.Add("结束", LvMenuCallback)

SetTimer(upAhkProcess, 10000)

upAhkProcess() {
    HWNDs := WinGetList(".ahk - AutoHotkey")
    for item in processArray {
        if HWNDs.IndexOf(item) == 0 {
            processArray.RemoveAt(A_Index)
            lv.Delete(A_Index)
        }
    }
    for item in HWNDs {
        if processArray.IndexOf(item) == 0 {
            processArray.Push(item)
            lv.Add(, WinGetTitle("ahk_id " item))
        }
    }
}

Ctrl_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
    cMenu.data := processArray[Item]
    cMenu.Show()
}

LvMenuCallback(ItemName, ItemPos, MyMenu) {
    switch ItemPos {
        case 1:
        {
            Utils.sendCmd("退出", "ahk_id " MyMenu.data)
            index := processArray.IndexOf(MyMenu.data)
            processArray.RemoveAt(index, 1)
            lv.Delete(index)
        }
        default:

    }
}

Gui_Close(GuiObj) {
    ExitApp()
}