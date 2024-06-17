#Requires AutoHotkey v2.0
#NoTrayIcon

icons.IconPicker()

class icons {
    Static IconSelectFileList := ["%SystemRoot%\explorer.exe"
                                , "%SystemRoot%\system32\accessibilitycpl.dll", "%SystemRoot%\system32\SensorsCpl.dll"
                                , "%SystemRoot%\system32\ddores.dll"          , "%SystemRoot%\system32\setupapi.dll"
                                , "%SystemRoot%\system32\gameux.dll"          , "%SystemRoot%\system32\shell32.dll"
                                , "%SystemRoot%\system32\imageres.dll"        , "%SystemRoot%\system32\UIHub.dll"
                                , "%SystemRoot%\system32\mmcndmgr.dll"        , "%SystemRoot%\system32\vpc.exe"
                                , "%SystemRoot%\system32\mmres.dll"           , "%SystemRoot%\system32\wmp.dll"
                                , "%SystemRoot%\system32\mstscax.dll"         , "%SystemRoot%\system32\wmploc.dll"
                                , "%SystemRoot%\system32\netshell.dll"        , "%SystemRoot%\system32\wpdshext.dll"
                                , "%SystemRoot%\system32\networkmap.dll"      , "%SystemRoot%\system32\wucltux.dll"
                                , "%SystemRoot%\system32\pifmgr.dll"          , "%SystemRoot%\system32\xpsrchvw.exe"]
    
    Static GetResourceList(str) { ; str = file name
        file_loc := [str, A_WinDir "\" str,A_WinDir "\System32\" str]
        exist := false, sFileName := ""
        
        For i, sFile in file_loc
            If FileExist(sFile)
                exist := true, sFileName := sFile
        
        If !exist {
            Msgbox "Specified file does not exist.`r`n`r`nSpecifically:    " str
            return
        }
        
        hModule := DllCall("GetModuleHandle", "Str", sFileName, "UPtr"), unload := false
        If !hModule
            hModule := DllCall("LoadLibrary", "Str", sFileName, "UPtr"), unload := true
        
        cbAddr := CallbackCreate(ObjBindMethod(this,"EnumIcons",List:=[]),,4)
        r1 := DllCall("EnumResourceNames", "UPtr", hModule, "Str", "#14", "UPtr", cbAddr, "UPtr", 0) ; #14
        CallbackFree(cbAddr)
        
        unload ? DllCall("FreeLibrary", "UPtr", hModule) : ""
        
        return List
    }
    Static EnumIcons(List, hModule, sType, sName, lParam) { ; callback for DllCall("EnumResourceNames")
        str := (StrLen(sName) > 5) ? StrGet(sName) : ""
        val := str ? str : "#" sName
        List.Push(val)
        
        return true
    }
    Static IconPicker(sIconFile:="", hwnd:=0, resources:=true) {
        this.resources := resources
        If sIconFile {
            str := sIconFile
            file_loc := [str, A_WinDir "\" str,A_WinDir "\System32\" str], exist := false, sFileName := ""
            For i, sFile in file_loc
                If FileExist(sFile)
                    exist := true, sIconFile := sFile
            
            If !exist
                throw Error("Specified file does not exist.",,str)
        }
        
        newList := []
        For i, file_name In this.IconSelectFileList
            If (FileExist(StrReplace(file_name,"%SystemRoot%",A_WinDir)))
                newList.Push(file_name)
        this.IconSelectFileList := newList
        
        hwndStr := WinExist("ahk_id " hwnd) ? " +Owner" hwnd : ""

        IconSelectUserGui := Gui("-MaximizeBox -MinimizeBox" hwndStr,"List Icons")
        IconSelectUserGui.OnEvent("close",this.gui_close.Bind(this))
        IconSelectUserGui.IconSelectIndex := ""
        
        IconSelectUserGui.Add("Text","","File:")
        ctl := IconSelectUserGui.Add("ComboBox","vIconFile x+m yp-3 w400",this.IconSelectFileList)
        
        ctl.OnEvent("change",this.gui_events.Bind(this)) ; ObjBindMethod(this,"gui_events")
        ctl.Text := sIconFile
        
        ctl := IconSelectUserGui.Add("Button","vPickFileBtn x+m yp-2 w30","•••")
        ctl.OnEvent("click",this.gui_events.Bind(this))
        
        LV := IconSelectUserGui.Add("ListView","vIconList xm w480 h220 Icon")
        LV.OnEvent("doubleclick",this.gui_events.Bind(this))
        
        ctl := IconSelectUserGui.Add("Button","vOkBtn x+-150 y+5 w75","OK")
        ctl.OnEvent("click",this.gui_events.Bind(this))
        
        ctl := IconSelectUserGui.Add("Button","vCancelBtn x+0 w75","Cancel")
        ctl.OnEvent("click",this.gui_events.Bind(this))
        
        ctl := IconSelectUserGui.Add("Button","vSwitch x+-480 w75","Show Index")
        ctl.OnEvent("click",this.gui_events.Bind(this))
        
        If (WinExist("ahk_id " hwnd)) {
            p := GuiFromHwnd(hwnd)
            p.GetPos(&x,&y,&w,&h), pPos := {x:x, y:y, w:w, h:h}
            x := pPos.x + (pPos.w / 2) - (261 * (A_ScreenDPI / 96))
            y := pPos.y + (pPos.h / 2) - (149 * (A_ScreenDPI / 96))
            params := "x" x " y" y
            IconSelectUserGui.Show(params)
        } Else
            IconSelectUserGui.Show()
        
        (sIconFile) ? this.IconSelectListIcons(IconSelectUserGui,sIconFile) : ""
        sIconFile := StrReplace(IconSelectUserGui["IconFile"].Text,"%SystemRoot%",A_WinDir)
        
        Pause
        
        If (idx := IconSelectUserGui.IconSelectIndex) {
            If !(IconSelectUserGui.IconIndexArray.Has(idx)) {
                For index, obj in IconSelectUserGui.IconIndexArray {
                    If (obj.name = idx) {
                        oOutput := obj
                        Break
                    }
                }
            } Else
                oOutput := IconSelectUserGui.IconIndexArray[idx]
        } Else
            oOutput := {index:0, type:"", file:"", name:""}
        
        IconSelectUserGui.Destroy()
        
        return oOutput
    }
    Static gui_events(ctl, info) {
        If (ctl.Name = "IconFile") {
            IconFile := StrReplace(ctl.Text,"%SystemRoot%",A_WinDir)
            this.IconSelectListIcons(ctl.gui,IconFile)
        } Else If (ctl.Name = "PickFileBtn") {
            IconFile := ctl.gui["IconFile"]
            IconFileStr := FileSelect("","C:\Windows\System32","Select an icon file:")
            
            If (IconFileStr)
                this.IconSelectListIcons(ctl.gui,IconFileStr)
        } Else if (ctl.Name = "IconList" Or ctl.Name = "OkBtn") {
            curCtl := ctl.gui["IconList"]
            curRow := curCtl.GetNext()
            
            If !curRow {
                Msgbox "No icon selected."
                return
            }
            
            ctl.gui.IconSelectIndex := curCtl.GetText(curRow)
            If ctl.Name = "OkBtn"
                Pause false
        } Else If (ctl.Name = "CancelBtn") {
            ctl.gui.IconSelectIndex := 0
            Pause false
        } Else If (ctl.Name = "Switch") {
            LV := ctl.gui["IconList"]
            
            If (ctl.Text = "Show Index") {
                Loop LV.GetCount()
                    LV.Modify(A_Index,,ctl.gui.IconIndexArray[A_Index].Index)
                ctl.Text := "Show Name"
            } Else {
                Loop LV.GetCount()
                    LV.Modify(A_Index,,ctl.gui.IconIndexArray[A_Index].Name)
                ctl.Text := "Show Index"
            }
        }
    }
    Static gui_close(_gui) {
        _gui.IconSelectIndex := 0
        Pause false
    }
    Static IconSelectListIcons(oGui,IconFile) {
        IconFile := StrReplace(IconFile,"%SystemRoot%",A_WinDir)
        If (FileExist(IconFile)) {
            iList := this.GetResourceList(IconFile)
            oGui.IconIndexArray := []
            
            LV := oGui["IconList"]
            LV.Delete()
            LV.Opt("-Redraw")
            
            ImgList := IL_Create(400,5,1)
            LV.SetImageList(ImgList,0)
            
            MaxIcons := 0
            For i, resName in iList {
                hPic := LoadPicture(IconFile,"Icon" i,&handleType)
                prefix := !handleType ? "HBITMAP" : ((handleType = 2) ? "HCURSOR" : "HICON")
                idx := (this.resources) ? resName : A_Index
                
                oGui.IconIndexArray.Push({type:prefix, name:resName, index:A_Index, file:IconFile})
                LV.Add("Icon" A_Index,((this.resources) ? resName : A_Index))
                
                result := IL_Add(ImgList,prefix ":" hPic)
                dll := DllCall("DestroyIcon", "ptr", hPic)
            }
            
            LV.Opt("+Redraw")
        } Else
            Msgbox "Invalid file selected."
    }
}