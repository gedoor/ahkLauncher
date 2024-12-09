/************************************************************************
 * @description 提取文件到另一个文件夹
 ***********************************************************************/

#Requires AutoHotkey v2.0
#NoTrayIcon
TraySetIcon("shell32.dll", 219)
DllCall("Shell32.dll\SetCurrentProcessExplicitAppUserModelID", "str", "AhkScreenFiles")
FileEncoding("UTF-8")
mainGui := Gui(, "文件提取器")
mainGui.Add("Text","x10 y10","搜索文件夹:")
mainGui.Add("Text","x10 y40","提取文件名文件:")
mainGui.Add("Text","x10 y70","输出文件夹:")
editDir := mainGui.AddEdit("x110 y6 w300")
editTxt := mainGui.AddEdit("x110 y36 w300")
editOutDir := mainGui.AddEdit("x110 y66 w300")
buttonDir := mainGui.AddButton("x420 y6 w100", "选择文件夹")
buttonTxt := mainGui.AddButton("x420 y36 w100","选择txt文件")
buttonOutDir := mainGui.AddButton("x420 y66 w100","选择输出文件夹")
textLoading := mainGui.AddText("x30 y100 vLoading Hidden", "提取中...")
buttonOk := mainGui.AddButton("x200 y130", "开始提取文件")
buttonDir.OnEvent("Click", SelectDir)
buttonTxt.OnEvent("Click", SelectTxt)
buttonOutDir.OnEvent("Click", SelectOutDir)
buttonOk.OnEvent("Click", StartScreen)
mainGui.OnEvent("Close", (*) => ExitApp)
mainGui.Show()

return

SelectDir(*) {
    mainGui.Opt("+OwnDialogs")
    select := DirSelect(editDir.Text,,"选择搜索文件夹")
    if (select){
        editDir.Text := select
    }
}

SelectTxt(*){
    mainGui.Opt("+OwnDialogs")
    select := FileSelect(,,"选择筛选txt文件")
    if (select)
        editTxt.Text := select
}

SelectOutDir(*) {
    mainGui.Opt("+OwnDialogs")
    select := DirSelect(editOutDir.Text,,"选择输出文件夹")
    if (select){
        editOutDir.Text := select
    }
}

StartScreen(*) {
    mainGui.Submit(false)
    dir := editDir.Text
    If !FileExist(dir) {
        MsgBox("查找的文件夹不存在")
        Return
    }
    txt := editTxt.Text
    If !FileExist(txt) {
        MsgBox("筛选文件不存在")
        Return
    }
    out := editOutDir.Text
    If !FileExist(out) {
        MsgBox("输出文件夹不存在")
        Return
    }
    UpLoadingState(true)
    FileNames := Array()
    loop read txt
    {
        FileNames.Push(A_LoopReadLine)
    }
    loop files dir "\*", "R"
    {
        for fName in FileNames {
            if InStr(A_LoopFileName, fName) {
                FileCopy(A_LoopFileFullPath, out)
                break
            }
        }
    }
    UpLoadingState(false)
}

UpLoadingState(isLoading) {
    editDir.Enabled := !isLoading
    editTxt.Enabled := !isLoading
    editOutDir.Enabled := !isLoading
    buttonDir.Enabled := !isLoading
    buttonTxt.Enabled := !isLoading
    buttonOutDir.Enabled := !isLoading
    buttonOk.Enabled := !isLoading
    textLoading.Visible := isLoading
}
