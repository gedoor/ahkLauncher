#Requires AutoHotkey v2.0

createDirTreeMenu(dirTree, iconSize, callback) {
    lMenu := Menu()
    for item in dirTree {
        if item.isDir {
            mMenu := createDirTreeMenu(item.cList, iconSize, callback)
            lMenu.Add(item.name, mMenu)
        } else {
            lMenu.Add(item.name, callback)
        }
        lMenu.SetIcon(A_Index "&", item.icon.path, item.icon.num + 1, iconSize)
    }
    lMenu.DefineProp("data", { Value: dirTree })
    return lMenu
}

getDirTree(path, maxSize := 100, start := 0) {
    list := []
    loop Files path "\*", "FD"
    {
        if A_LoopFileAttrib ~= "[HS]"
            continue
        if start > maxSize {
            throw TimeoutError("文件数量超过" maxSize "会影响速度")
        }
        start := start + 1
        if A_LoopFileAttrib ~= "[D]" {
            mList := getDirTree(A_LoopFileFullPath, maxSize, start)
            list.Push({
                isDir: true,
                name: A_LoopFileName,
                path: A_LoopFileFullPath,
                icon: getItemIcon(A_LoopFileFullPath),
                cList: mList
            })
        } else {
            fileName := A_LoopFileName
            if RegExMatch(fileName, "i).*?\.(exe|lnk)$") {
                fileName := SubStr(fileName, 1, StrLen(fileName) - 4)
            }
            list.Push({
                isDir: false,
                name: fileName,
                path: A_LoopFileFullPath,
                icon: getItemIcon(A_LoopFileFullPath),
            })
        }
    }
    return list
}

getItemIcon(fPath) {
    SplitPath fPath, , , &fExt
    fAttr := FileGetAttrib(fPath)

    OutIconChoice := { path: "" }

    ; support executable binaries
    if fExt = "exe" || fExt = "dll"
        OutIconChoice := { path: fPath, num: 0 }

    ; support windows shortcut/link files *.lnk
    if fExt = "lnk"
    {
        FileGetShortcut fPath, &OutTarget, , , , &OutIcon, &OutIconNum
        if FileExist(OutTarget) {
            SplitPath OutTarget, , , &OutTargetExt
            if OutTargetExt = "exe" || OutTargetExt = "dll"
                OutIconChoice := { path: OutTarget, num: 0 }
            if (OutIcon && OutIconNum)
                OutIconChoice := { path: OutIcon, num: (OutIconNum - 1) }
            else {
                ; Support shortcuts to folders with no custom icon set (default)
                _attr := FileGetAttrib(OutTarget)
                if (InStr(_attr, "D")) {
                    ; display default icon instead of blank file icon
                    OutIconChoice := { path: "imageres.dll", num: 4 }
                }
            }
        }
    }
    ; support windows internet shortcut files *.url
    else if fExt = "url"
    {
        OutIcon := IniRead(fPath, "InternetShortcut", "IconFile")
        OutIconNum := IniRead(fPath, "InternetShortcut", "IconIndex", 0)
        if FileExist(OutIcon)
            OutIconChoice := { path: OutIcon, num: OutIconNum }
    }

    ; support folder icons
    if (InStr(fAttr, "D")) {
        ; Customized may contain a hidden system file called desktop.ini
        _dini := fPath . "\desktop.ini"
        ; https://msdn.microsoft.com/en-us/library/cc144102.aspx

        ; case 1
        ; [.ShellClassInfo]
        ; IconResource=C:\WINDOWS\System32\SHELL32.dll,130
        _ico := IniRead(_dini, ".ShellClassInfo", "IconResource", 0)
        if (_ico) {
            lastComma := InStr(_ico, ",", true, -1, -1)
            OutIconChoice := { path: Substr(_ico, 1, lastComma - 1), num: substr(_ico, lastComma + 1) }
        } else {
            ; case 2
            ; [.ShellClassInfo]
            ; IconFile=C:\WINDOWS\System32\SHELL32.dll
            ; IconIndex=130
            _icoFile := IniRead(_dini, ".ShellClassInfo", "IconFile", "0")
            _icoIdx := IniRead(_dini, ".ShellClassInfo", "IconIndex", "0")
            if (_icoFile)
                OutIconChoice := { path: _icoFile, num: _icoIdx }
            else
                OutIconChoice := { path: "shell32.dll", num: 4 }
        }
    }

    ; support associated filetypes
    else if (StrLen(OutIconChoice.path) < 2)
        OutIconChoice := getExtIcon(fExt)

    return OutIconChoice
}

getExtIcon(Ext) {
    I1 := I2 := ""
    try {
        from := RegRead("HKEY_CLASSES_ROOT", "." Ext)
        DefaultIcon := RegRead("HKEY_CLASSES_ROOT", from "\DefaultIcon")
        DefaultIcon := StrReplace(DefaultIcon, "`"", "")
        DefaultIcon := StrReplace(DefaultIcon, "%SystemRoot%", A_WinDir)
        DefaultIcon := StrReplace(DefaultIcon, "%ProgramFiles%", A_ProgramFiles)
        DefaultIcon := StrReplace(DefaultIcon, "%windir%", A_WinDir)
        I := StrSplit(DefaultIcon, "`,")
        num := RegExReplace(I2, "[^\d-]+")
        DefaultIcon := I1 ":" num ;clean index number, but support negatives

        if (StrLen(DefaultIcon) < 4) {
            ;windows default to the OpenCommand if available
            OpenCommand := RegRead("HKEY_CLASSES_ROOT", from "\shell\open\command")
            if (OpenCommand) {
                OpenCommand := StrSplit(OpenCommand, "`"`"`"`"", "`"`"`"`"`t`n`r`"")[2]
                icon := { path: OpenCommand, num: 0 }
            } else {
                ; default file icon, if all else fails
                icon := { path: "shell32.dll", num: 0 }
            }
        } else {
            icon := { path: I1, num: num }
        }
    } catch {
        icon := { path: "shell32.dll", num: 0 }
    }

    return icon
}
