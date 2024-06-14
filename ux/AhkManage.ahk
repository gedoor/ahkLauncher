#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance Force
#Include ..\lib\ArrayExtensions.ahk
#Include ..\lib\Utils.ahk
DetectHiddenWindows True

myGui := Gui()
myGui.Title := "ahk脚本进程管理"
lv := myGui.AddListView("r20 w700", ["Name"])
lv.OnEvent("ContextMenu", Ctrl_ContextMenu)

myGui.Opt("+MaxSizex200 +MaxSizey200")
myGui.Show()

upAhkProcess()

cMenu := Menu()
cMenu.DefineProp("data", { Value: "" })
cMenu.Add("结束", LvMenuCallback)

upAhkProcess() {
    global HWNDs
    HWNDs := WinGetList(".ahk - AutoHotkey")
    lv.Opt("-Redraw")
    lv.Delete()
    for item in HWNDs {
        lv.Add(, WinGetTitle("ahk_id " item))
    }
    lv.Opt("+Redraw")
}

Ctrl_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
    cMenu.data := HWNDs[Item]
    cMenu.Show()
}

LvMenuCallback(ItemName, ItemPos, MyMenu) {
    switch ItemPos {
        case 1:
        {
            Utils.sendCmd("退出", "ahk_id " MyMenu.data)
            index := HWNDs.IndexOf(MyMenu.data)
            HWNDs.RemoveAt(index, 1)
            lv.Delete(index)
        }
        default:

    }
}