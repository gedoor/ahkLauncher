/************************************************************************
 * @description 文件监察配置
 ***********************************************************************/
#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance Force
#Include ..\lib\Json.ahk
#Include ..\lib\ArrayExtensions.ahk
TraySetIcon("..\res\fcl.ico")
DllCall("Shell32.dll\SetCurrentProcessExplicitAppUserModelID", "str", "AhkFileWatch")

configPath := A_ScriptDir "\data\fileChangeListener.json"
if not DirExist("data") {
    DirCreate("data")
}


cfgGui := Gui()
cfgGui.Title := "FileWatchConfig"
statusBar := cfgGui.AddStatusBar(, " 这是一个监察文件夹变动进行一些操作的应用.")
fMenu := Menu()
fMenu.Add("save", SaveConfig)
fMenu.Add("reload", ReloadConfig)
mBar := MenuBar()
mBar.Add("文件", fMenu)
mBar.Add("添加监察文件夹", AddWatchDir)
cfgGui.MenuBar := mBar

wacthDirMenu := Menu()
wacthDirMenu.DefineProp("data", { Value: "" })
wacthDirMenu.Add("添加监察文件", WacthDirMenuCallback)
wacthDirMenu.Add("删除", WacthDirMenuCallback)

wacthFileMenu := Menu()
wacthFileMenu.DefineProp("data", { Value: "" })
wacthFileMenu.Add("编辑", WacthFileMenuCallback)
wacthFileMenu.Add("删除", WacthFileMenuCallback)

tv := cfgGui.AddTreeView("x0 y0 w620 h398")
tv.OnEvent("ContextMenu", TvContextMenu)

ReloadConfig()

cfgGui.Show("w620 h420")

SaveConfig(*) {
    if (cfg) {
        for item in cfg {
            item.Delete("id")
            for watchFile in item.get("files", []) {
                watchFile.Delete("id")
            }
        }
        cfgJson := JSON.Dump(cfg)
        try FileDelete configPath
        FileAppend(cfgJson, configPath)
    }
}

ReloadConfig(*) {
    tv.Delete()
    global cfg
    cfgJson := FileRead(configPath)
    cfg := !cfgJson ? [] : JSON.Load(cfgJson)
    If cfg {
        for item in cfg {
            id := tv.Add(item["dir"], 0, "+Expand")
            item["id"] := id
            for watchFile in item.get("files", []) {
                id1 := tv.Add(watchFile["file"], id)
                watchFile["id"] := id1
            }
        }
    }
}

AddWatchDir(*) {
    cfgGui.Opt("+OwnDialogs")
    SelectedFolder := DirSelect(, 0, "选择监察文件夹")
    if SelectedFolder {
        for item in cfg {
            if SelectedFolder = item["dir"] {
                MsgBox("已有此文件夹的检查配置")
                return
            }
        }
        id := tv.Add(SelectedFolder)
        cfg.Push(Map("dir", SelectedFolder, "files", [], "id", id))
    }
}

AddWatchFile(wacthDir) {
    wfUi := WacthFileUi(wacthDir)
    wfUi.fileEdit.Text := ""
    wfUi.actionEdit.Text := ""
    wfUi.todoEdit.Text := ""
    wfUi.Show("w600 h400")
}

EditWatchFile(watchFile) {
    wfUi := WacthFileUi(watchFile)
    wfUi.fileEdit.Text := watchFile["file"]
    wfUi.actionEdit.Text := watchFile["action"]
    wfUi.todoEdit.Text := watchFile["todo"]
    wfUi.Show("w600 h400")
}

Remove(id) {
    pId := tv.GetParent(id)
    if pId = 0 {
        for wDir in cfg {
            if id = wDir["id"] {
                cfg.RemoveAt(A_Index)
                tv.Delete(id)
                return
            }
        }
    } else {
        for wDir in cfg {
            if pId = wDir["id"] {
                for wFile in wDir["files"] {
                    if id = wFile["id"] {
                        wDir["files"].RemoveAt(A_Index)
                        tv.Delete(id)
                        return
                    }
                }
            }
        }
    }
}

TvContextMenu(GuiCtrlObj, id, *) {
    if id = 0
        return
    tv.Modify(id, "Select")
    for item in cfg {
        if id = item["id"] {
            wacthDirMenu.data := item
            wacthDirMenu.Show
            return
        } else {
            for watchFile in item.get("files", []) {
                if id = watchFile["id"] {
                    wacthFileMenu.data := watchFile
                    wacthFileMenu.Show
                    return
                }
            }
        }
    }
}

WacthDirMenuCallback(ItemName, ItemPos, MyMenu) {
    wacthDir := MyMenu.data
    switch ItemName {
        case "添加监察文件":
            AddWatchFile(wacthDir)
        case "删除":
            Remove(wacthDir["id"])
    }
}

WacthFileMenuCallback(ItemName, ItemPos, MyMenu) {
    wacthFile :=  MyMenu.data
    switch ItemName {
        case "编辑":
            EditWatchFile(wacthFile)
        case "删除":
            Remove(wacthFile["id"])
    }
}

class WacthFileUi {

    wfUi := Gui()
    
    __New(data) {
        this.data := data
        this.wfUi.Title := "文件事件"
        this.wfUi.Opt("+Owner" cfgGui.Hwnd)
        this.wfUi.AddText("x16 y18 w60", "文件:")
        this.wfUi.AddText("x16 y48 w60", "操作:")
        this.wfUi.AddText("x16 y78 w60", "内容:")
        this.fileEdit := this.wfUi.AddEdit("x60 y16 w500")
        this.actionEdit := this.wfUi.AddDDL("x60 y46 w500", ["copy", "cmd"])
        this.todoEdit := this.wfUi.AddEdit("x60 y76 w500 h260")
        this.okButton := this.wfUi.AddButton("x280 y350 w50", "确认")
        this.okButton.DefineProp("data", {Value: this})
        this.okButton.OnEvent("Click", this.OkCallback)
    }

    OkCallback(*) {
        mClass := this.data
        if mClass.data.Has("dir") {
            id := tv.Add(mClass.fileEdit.Text, mClass.data["id"])
            mClass.data["files"].Push(Map(
                "file", mClass.fileEdit.Text,
                "action", mClass.actionEdit.Text,
                "todo", mClass.todoEdit.Text,
                "id", id
            ))
        }
        if mClass.data.Has("file") {
            mClass.data["file"] := mClass.fileEdit.Text
            mClass.data["action"] := mClass.actionEdit.Text
            mClass.data["todo"] := mClass.todoEdit.Text
            tv.Modify(mClass.data["id"], , mClass.fileEdit.Text)
        }
        mClass.wfUi.Destroy
    }

    Show(options?) {
        this.wfUi.Show(options)
    }
}