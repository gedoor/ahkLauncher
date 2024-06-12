#Requires AutoHotkey v2.0
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode("Input")  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.

#SingleInstance Force

myGui := Gui()
myGui.OnEvent("Close", GuiClose)
myGui.SetFont("s13", "Arial")
myGui.BackColor := "C0C0C0"
ogcButtonOLDfolder := myGui.AddButton("xm y+20 h30 w100", "OLD folder:")
ogcButtonOLDfolder.OnEvent("Click", Br1.Bind("Normal"))
ogcEditOriginal := myGui.AddEdit("x+20 h30 w1000 vOriginal")
ogcButtonNEWfolder := myGui.AddButton("xm y+40 h30 w105", "NEW folder:")
ogcButtonNEWfolder.OnEvent("Click", Br2.Bind("Normal"))
ogcEditNewFolder := myGui.AddEdit("x+20 h30 w1000 vNewFolder")
ogcButtonCopyafolderandDeletetheoriginalone := myGui.AddButton("x400 y+30 w320", "Copy a folder and Delete the original one")
ogcButtonCopyafolderandDeletetheoriginalone.OnEvent("Click", Op1.Bind("Normal"))
ogcButtonCopyafolderandKeeptheoriginalone := myGui.AddButton("y+40 w320", "Copy a folder and Keep the original one")
ogcButtonCopyafolderandKeeptheoriginalone.OnEvent("Click", Op2.Bind("Normal"))
ogcButtonCreateaLinktoafolder := myGui.AddButton("y+40 w320", "Create a Link to a folder")
ogcButtonCreateaLinktoafolder.OnEvent("Click", Op3.Bind("Normal"))
myGui.Title := "Copy or Link folders"
myGui.Show()
return

GuiClose(*)
{ ; V1toV2: Added bracket
    myGui.destroy()
    ExitApp()
} ; V1toV2: Added Bracket before label


Br1(A_GuiEvent, GuiCtrlObj, Info, *)
{ ; V1toV2: Added bracket
    oSaved := myGui.Submit("0")
    Original := oSaved.Original
    NewFolder := oSaved.NewFolder
    Original := DirSelect(, , "Select your OLD folder: (THIS FOLDER CONTAINS THE FILES TO BE COPYED, IT WILL BE KEPT, DELETED OR LINKED.)")
    ogcEditOriginal.Value := Original
    return
} ; V1toV2: Added Bracket before label

Br2(A_GuiEvent, GuiCtrlObj, Info, *)
{ ; V1toV2: Added bracket
    oSaved := myGui.Submit("0")
    Original := oSaved.Original
    NewFolder := oSaved.NewFolder
    NewFolder := DirSelect(, , "Select your NEW folder:   (THIS FOLDER WILL HAVE THE NEW FILES OR THE ORIGINAL ONES FROM LINKING.)")
    ogcEditNewFolder.Value := NewFolder
    return
} ; V1toV2: Added Bracket before label

Op1(A_GuiEvent, GuiCtrlObj, Info, *)
{
    oSaved := myGui.Submit("0")
    Original := oSaved.Original
    NewFolder := oSaved.NewFolder

    if (Original) && (NewFolder)
    {
        msgResult := MsgBox("COPY a folder and DELETE the original one. `n`n From: " Original " `n`n To: " NewFolder, "Confirmation !", 1)
        if (msgResult = "OK")
        {
            command1 := "robocopy `"" . Original . "`" `"" . NewFolder . "`" /E /R:3 /W:15 /V /MT /MOVE /TEE /ETA /LOG:`"" . NewFolder . "\Log_Copied_files.txt`""
            RunWait("*RunAs " A_ComSpec " /c " command1, , "Min")

            msgResult := MsgBox("Open Logs ?", "Process Completed !!", 1)
            if (msgResult = "Ok")
            {
                Run("`"" NewFolder "\Log_Copied_files.txt`"")
                ExitApp()
            }
            else
                ExitApp()

        }
        else
            return
    }
    else
    {
        MsgBox("Please, select both folders")
        return
    }

}

Op2(A_GuiEvent, GuiCtrlObj, Info, *)
{
    oSaved := myGui.Submit("0")
    Original := oSaved.Original
    NewFolder := oSaved.NewFolder

    if (Original) && (NewFolder)
    {
        msgResult := MsgBox("COPY a folder and KEEP the original one. `n`n From: " Original " `n`n To: " NewFolder, "Confirmation !", 1)
        if (msgResult = "OK")
        {
            command1 := "robocopy `"" . Original . "`" `"" . NewFolder . "`" /E /R:3 /W:15 /V /MT /TEE /ETA /LOG:`"" . NewFolder . "\Log_Copied_files.txt`""
            RunWait("*RunAs " A_ComSpec " /c " command1, , "Min")

            msgResult := MsgBox("Open Logs ?", "Process Completed !!", 1)
            if (msgResult = "Ok")
            {
                Run("`"" NewFolder "\Log_Copied_files.txt`"")
                ExitApp()
            }
            else
                ExitApp()

        }
        else
            return
    }
    else
    {
        MsgBox("Please, select both folders")
        return
    }

}

Op3(A_GuiEvent, GuiCtrlObj, Info, *)
{
    oSaved := myGui.Submit("0")
    Original := oSaved.Original
    NewFolder := oSaved.NewFolder

    if (Original) && (NewFolder)
    {
        msgResult := MsgBox("Create a LINK to a folder. `n`n From: " Original " `n`n To: " NewFolder, "Confirmation !", 1)
        if (msgResult = "OK")
        {
            command1 := "robocopy `"" . Original . "`" `"" . NewFolder . "`" /E /R:3 /W:15 /V /MT /MOVE /TEE /ETA /LOG:`"" . NewFolder . "\Log_Copied_files.txt`""
            command2 := "mklink /d `"" . Original . "`" `"" . NewFolder
            RunWait("*RunAs " A_ComSpec " /c " command1 " & " command2, , "Min")

            msgResult := MsgBox("Open Logs ?", "Process Completed !!", 1)
            if (msgResult = "Ok")
            {
                Run("`"" NewFolder "\Log_Copied_files.txt`"")
                ExitApp()
            }
            else
                ExitApp()

        }
        else
            return
    }
    else
    {
        MsgBox("Please, select both folders")
        return
    }

}