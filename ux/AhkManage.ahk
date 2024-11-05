/************************************************************************
 * @description Ahk脚本管理
 ***********************************************************************/
#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance Force
#Include ..\lib\ArrayExtensions.ahk
#Include ..\lib\AhkScriptUtils.ahk
#Include ..\lib\WinEvent.ahk
DetectHiddenWindows True

cMenu := Menu()
cMenu.DefineProp("data", { Value: "" })
cMenu.Add("重载", LvMenuCallback)
cMenu.Add("结束", LvMenuCallback)

myGui := Gui()
myGui.Title := "AHK脚本进程管理"
lv := myGui.AddListView("r20 w600 +NoSort +Sort +Grid -LV0x10 Backgrounde9e9e9", ["Name", "PID"])
lv.ModifyCol(1, 500)
lv.ModifyCol(2, "AutoHdr")
lv.OnEvent("ContextMenu", Ctrl_ContextMenu)

myGui.Show()
myGui.OnEvent("Close", Gui_Close)

InitProcess()

WinEvent.Close(InitProcess, ".ahk - AutoHotkey")
WinEvent.Create(InitProcess, ".ahk - AutoHotkey")

InitProcess(*) {
    HWNDs := WinGetList(".ahk - AutoHotkey")
    processArray := HWNDs.map((v) => {id: WinGetPID("ahk_id " v), title: WinGetTitle("ahk_id " v)})
    lvRow := lv.GetCount()
    lvArray := Array(lvRow)
    while lvRow > 0 {
        text := lv.GetText(lvRow)
        if (processArray.find((v) => v.title = text) = 0) {
            lv.Delete(lvRow)
        } else {
            lvArray.Push(text)
        }
        lvRow := lvRow - 1
    }
    for item in processArray {
        title := item.title
        if InStr(title, "AhkLauncher.ahk") {
            return
        }
        if lvArray.indexof(title) = 0 {
            lv.Add(, title, item.id)
        }
    }
}

Ctrl_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
    cMenu.data := {title: lv.GetText(Item), pos: Item}
    cMenu.Show()
}

LvMenuCallback(ItemName, ItemPos, MyMenu) {
    lvRow := MyMenu.data
    switch ItemPos {
        case 1:
        {
            AhkScript.Reload(lvRow.title)
        }
        case 2:
        {
            AhkScript.Exit(lvRow.title)
            lv.Delete(lvRow.pos)
        }
    }
}

Gui_Close(GuiObj) {
    ExitApp()
}