#NoTrayIcon
#SingleInstance Force
#Include ..\lib\Json.ahk
#Include ..\lib\ArrayExtensions.ahk
TraySetIcon("..\res\fcl.ico")

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
tv := cfgGui.AddTreeView("x0 y0 w620 h398")

ReloadConfig()

cfgGui.Show("w620 h420")

SaveConfig(*) {
    if(cfg) {
        for item in cfg {
            item.Delete("id")
            for watchFile in item.get("files", []) {
                watchFile.Delete("id")
            }
        }
        cfgJson := JSON.Dump(cfg)

    }
}

ReloadConfig(*) {
    tv.Delete()
    global cfg
    cfgJson := FileRead(configPath)
    cfg := !cfgJson ? "" : JSON.Load(cfgJson)
    If cfg {
        for item in cfg {
            id := tv.Add(item["dir"])
            item["id"] := id
            for watchFile in item.get("files", []) {
                id1 := tv.Add(watchFile["file"], id)
                watchFile["id"] := id1
            }
        }
    }
}

AddWatchDir(*) {
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

AddWatchFile(*) {

}