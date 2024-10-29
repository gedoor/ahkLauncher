#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance Force
#Include ..\lib\ArrayExtensions.ahk
#Include ..\lib\AhkScriptUtils.ahk
DetectHiddenWindows True

processArray := Array()

myGui := Gui()
myGui.Title := "AHK脚本进程管理"
lv := myGui.AddListView("r20 w690 +NoSort +Grid -LV0x10 Backgrounde9e9e9", ["Name"])
lv.OnEvent("ContextMenu", Ctrl_ContextMenu)

myGui.Opt("+MaxSizex200 +MaxSizey200")
myGui.Show()
myGui.OnEvent("Close", Gui_Close)

upAhkProcess()

cMenu := Menu()
cMenu.DefineProp("data", { Value: "" })
cMenu.Add("结束", LvMenuCallback)

SetTimer(upAhkProcess, 1000)

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
            AhkScript.Exit("ahk_id " MyMenu.data)
            index := processArray.IndexOf(MyMenu.data)
            processArray.RemoveAt(index, 1)
            lv.Delete(index)
        }
    }
}

Gui_Close(GuiObj) {
    ExitApp()
}