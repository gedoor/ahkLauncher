/************************************************************************
 * @description 喜欢的文件夹和文件的快速访问
 ***********************************************************************/

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
DllCall("Shell32.dll\SetCurrentProcessExplicitAppUserModelID", "str", "QuickerAccess")
Global CONFIG_FILEPATH := (()=>(SplitPath(A_ScriptName,,,,&Name), A_ScriptDir "\data\" Name ".ini"))()
Global DefaultConfig := Map("AddressList","%USERPROFILE%`nDocuments`nMusic`nPictures`nDownloads`n%WINDIR%\Web\Wallpaper`n%APPDATA%`n%TEMP%`n%SYSTEMROOT%\Notepad.exe`nipconfig /flushdns", "WindowSize","w400 h400", "ShowKey","!q")
Global Config := LoadConfig(CONFIG_FILEPATH, DefaultConfig)
Global PreparedAddressList, MainGui, hActvWnd

Init()

If FileExist(shell32dll := EnvGet("SystemRoot") "\System32\shell32.dll")
	TraySetIcon(shell32dll, "321")

MainGui := Gui("+Resize", "QuickerAccess")
MainGui.Opt("+Owner")
MainGui.SetFont("s10", "Segoe UI")
MainGui.MarginX := 0, MainGui.MarginY := 0
FilterEdit := MainGui.Add("Edit", "vFilterEdit")
FilterEdit.OnEvent("Change", FilterOnChange)
AddressList := MainGui.Add("ListView", "vAddressList +LV0x10000 -E0x200", ["Name", "Path"])
AddressList.OnEvent("Click", AddressListOnClick)
AddressList.OnEvent("ContextMenu", AddressListContextMenu)
DllCall("uxtheme\SetWindowTheme", "Ptr", AddressList.Hwnd, "Str", "Explorer", "Ptr", 0)

MainGui.OnEvent("Escape", (*) => MainGui.Hide())
MainGui.OnEvent("Size", MainGuiOnSize)
MainGui.OnEvent("DropFiles", MainGuiOnDropFiles)
OnMessage(0x100, MainGuiOnKeyDown) ; WM_KEYDOWN
OnMessage(0x232, MainGuiAfterSize) ; WM_EXITSIZEMOVE

MainGui.Show(Config["WindowSize"] " Hide")
ToggleHotkeys("On")

PreparedAddressList := PrepareAddressList(Config["AddressList"])

UpdateAddressList()
AdjustDimensions()

ToggleMainGui(*) {
	Global hActvWnd, MainGui
	If !(IsSet(MainGui) && MainGui)
		Return
	If InStr(A_ThisHotkey, "!")
		SendInput "{! up}"
	If !WinActive(MainGui.Hwnd) {
		hActvWnd := WinExist("A")
		MainGui.Show()
		FilterEdit.Focus()
		AddressList.Modify(1, "+Vis")
	} Else {
		MainGui.Hide()
	}
}

ToggleHotkeys(On:=true) {
	Hotkey Config["ShowKey"], ToggleMainGui, On
}

AddressListContextMenu(LV, ItemIndex, IsRightClick, X, Y) {
	M := Menu()
	If ItemIndex {
		ItemID := LV.GetItemParam(ItemIndex)
		M.Add("&Copy", CopyAddress)
		M.Add("&Edit", EditAddress)
		M.Add("&Remove", RemoveAddress)
	}
	M.Add("&Add new", AddAddress)
	M.Add()
	M.Add("Edit a&ddress list", (*) => EditAddressList())
	M.Show(X, Y)
	
	CopyAddress(*) {
		AddressItem := PreparedAddressList[ItemID]
		A_Clipboard := AddressItem["Address"]
	}
	EditAddress(*) {
		EditGui := EditAddressList()
		WinExist(AddressEdit := EditGui["AddressEdit"])
		LineIndex := SendMessage(0xBB, ItemID-1) ; EM_LINEINDEX
		LineLength := SendMessage(0xC1, LineIndex) ; EM_LINELENGTH
		SendMessage(0xB1, LineIndex, LineIndex+LineLength) ; EM_SETSEL
		SendMessage(0xB7) ; EM_SCROLLCARET
	}
	RemoveAddress(*) {
		LV.Delete(ItemIndex)
		AddressList := Config["AddressList"]
		AddressList.RemoveAt(ItemID)
		PreparedAddressList.RemoveAt(ItemID)
		IniDelete(CONFIG_FILEPATH, "AddressList")
		IniWrite(AddressList.Join("`n"), CONFIG_FILEPATH, "AddressList")
	}
	AddAddress(*) {
		EditGui := EditAddressList()
		WinExist(AddressEdit := EditGui["AddressEdit"])
		SendMessage(0xB1, -2, -1) ; EM_SETSEL
		SendMessage(0xB7) ; EM_SCROLLCARET
	}
}

EditAddressList() {
	Static Section := "AddressList"
	EditGui := Gui("+Resize +Owner" MainGui.Hwnd, "Edit Address List")
	EditGui.Close := OnClose
	EditGui.OnEvent("Escape", EditGui.Close)
	EditGui.OnEvent("Close", EditGui.Close)
	EditGui.OnEvent("Size", OnSize)
	EditGui.OnEvent("DropFiles", OnDropFiles)
	OnMessage(0x100, OnKeyDown) ; WM_KEYDOWN
	OnMessage(0x102, OnPaste) ; WM_CHAR
	OnMessage(0x104, OnSysKeyDown) ; WM_SYSKEYDOWN
	EditGui.MarginX := 0, EditGui.MarginY := 0
	EditGui.SetFont("s10", "Segoe UI")
	EditGui.MenuBar := MenuBar()
	EditMenu := Menu()
	EditMenu.Add("&Paste the clipboard as address	Ctrl+V", (*) => EditPaste(A_Clipboard, AddressEdit))
	EditMenu.Add("Move the current line &up	Alt+Up", (*) => MoveLine(AddressEdit, 0))
	EditMenu.Add("Move the current line &down	Alt+Down", (*) => MoveLine(AddressEdit, 1))
	EditGui.MenuBar.Add("&Edit", EditMenu)
	AddressList := ""
	For Address in Config[Section]
		AddressList .= Address "`n"
	AddressEdit := EditGui.Add("Edit", "w600 r16 -Wrap -E0x200 vAddressEdit", AddressList) ; WS_EX_CLIENTEDGE
	AddressEdit.OnEvent("Change", ChangeCB:=(*) => (
		AddressEdit.OnEvent("Change", ChangeCB, 0),
		EditGui.Title := "*" EditGui.Title
	), 1)
	OnMessage(0x111, FocusCB:=(wp, lp, msg, hwnd) => (  ; ON_EN_SETFOCUS
		hwnd = EditGui.Hwnd && (
			PostMessage(0xB1, 0, 0, lp), ; EM_SETSEL
			OnMessage(msg, FocusCB, 0)
		)
	), 1)
	(SaveButton := EditGui.Add("Button", "wp", "&Save")).OnEvent("Click", Save)
	EditGui.Show()
	Return EditGui
	
	OnSize(GuiObj, MinMax, Width, Height) {
		SaveButton.GetPos(,,, &H)
		Height -= H,
		AddressEdit.Move(,, Width, Height),
		SaveButton.Move(, Height, Width)
	}
	
	OnKeyDown(wp, lp, msg, hwnd) {
		; VK_BACK := 8, VK_S = 83
		If (hwnd = AddressEdit.Hwnd) {
			If (wp = 8 && GetKeyState("Ctrl")) {
				CaretIndex := SendMessage(0x1512,,, AddressEdit) ; EM_GETCARETINDEX
				LineNumber := EditGetCurrentLine(AddressEdit)
				LineIndex := SendMessage(0xBB, LineNumber-1, , AddressEdit) ; EM_LINEINDEX
				LineToCaretText := SubStr(AddressEdit.Text, LineIndex+1, CaretIndex-LineIndex)
				
				RightBoundPos := (
					P:=InStr(LineToCaretText, "\",, -2),
					!P && P:=InStr(LineToCaretText, " ",, -2),
				P)
				SendMessage(0xB1, LineIndex+StrLen(LineToCaretText), LineIndex+RightBoundPos, AddressEdit) ; EM_SETSEL
				SendMessage(0xC2, true, 0, AddressEdit) ; EM_REPLACESEL
				Return 0
			}
			If (wp = 83 && GetKeyState("Ctrl")) {
				Save()
				Return 0
			}
		}
	}
	
	OnSysKeyDown(wp, lp, msg, hwnd) {
		; VK_UP = 38, VK_DOWN = 40
		If (hwnd = AddressEdit.Hwnd) && (wp = 38 || wp = 40) {
			Direction := wp != 38
			MoveLine(AddressEdit, Direction)
			Return 0
		}
	}
	
	OnDropFiles(GuiObj, GuiCtrl, FileArray, X, Y) {
		If !GuiCtrl
			Return
		Switch GuiCtrl.Hwnd {
			Case AddressEdit.Hwnd:
				If !AddressEdit.Focused
					AddressEdit.Focus()
				;CharPos := 0
				LineNumber := 0
				CharLine := SendMessage(0xD7, 0, (Y << 16) | X, AddressEdit) ; EM_CHARFROMPOS
				;CharPos := (CharLine & 0xFFFF) + 1
				LineNumber := (CharLine >> 16) + 1
				LineCount := EditGetLineCount(AddressEdit)
				LineIndex := SendMessage(0xBB, LineNumber = LineCount ? LineNumber - 1 : LineNumber, , AddressEdit) ; EM_LINEINDEX
				SendMessage(0xB1, LineIndex, LineIndex, AddressEdit) ; EM_SETSEL
				Files := ""
				For File in FileArray
					Files .= File "`r`n"
				EditPaste Files, AddressEdit
				PostMessage(0xB1, LineIndex, LineIndex+StrLen(Files), AddressEdit) ; EM_SETSEL
		}
	}
	
	OnPaste(wp, lp, msg, hwnd) { ; Thanks to teadrinker https://www.autohotkey.com/boards/viewtopic.php?p=569093
		Static CF_HDROP := 0xF
		If !(wp = 0x16 && hwnd = AddressEdit.hwnd)
			Return
		DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
		If hData := DllCall("GetClipboardData", "UInt", CF_HDROP, "Ptr") {
			pDROPFILES := DllCall("GlobalLock", "Ptr", hData, "Ptr")
			Address := pDROPFILES + NumGet(pDROPFILES, "UInt")
			While (FilePath := StrGet(Address)) != "" {
				FilePaths .= (A_Index = 1 ? "" : "`r`n") FilePath
				Address += StrPut(FilePath)
			}
			DllCall("GlobalUnlock", "Ptr", hData)
			EditPaste FilePaths, AddressEdit
		}
		DllCall("CloseClipboard")
	}
	
	OnClose(*) {
		EditGui.Destroy()
		EditGui := unset
		OnMessage(0x100, OnKeyDown, 0) ; WM_KEYDOWN
		OnMessage(0x102, OnPaste, 0) ; WM_CHAR
		OnMessage(0x104, OnSysKeyDown, 0) ; WM_SYSKEYDOWN
	}

	Save(*) {
		AddressListStr := RTrim(AddressEdit.value, "`n")
		Global PreparedAddressList := PrepareAddressList(
			Config["AddressList"] := LoadAddressList(AddressListStr)
		)
		EditGui.Close()
		IniDelete(CONFIG_FILEPATH, Section),
		IniWrite(AddressListStr, CONFIG_FILEPATH, Section)
		UpdateAddressList()
		AdjustDimensions()
	}
}

AdjustDimensions() {
	Static Column1Padding := 15
	MainGui.GetClientPos(,, &Width, &Height)
	FilterEdit.Move(,, Width),
	FilterEdit.GetPos(, , , &H),
	Height -= H,
	LV := MainGui["AddressList"],
	LV.Opt("-Redraw")
	LV.Move(,, W := Width, Height),
	Width -= LV_GetVScrollWidth(LV),
	LV.ModifyCol(1, "AutoHdr"),
	Column1Width := SendMessage(0x101D, 0, , LV), ;LVM_GETCOLUMNWIDTH
	LV.ModifyCol(1, Column1Width+Column1Padding),
	LV.ModifyCol(2, Width-Column1Width-Column1Padding)
	LV.Opt("+Redraw")
}

MainGuiOnSize(GuiObj, MinMax, Width, Height) {
	AdjustDimensions()
}

MainGuiAfterSize(wParam, lParam, msg, hwnd) {
	if (hwnd == MainGui.Hwnd) {
		MainGui.GetPos(&X, &Y)
		MainGui.GetClientPos(, , &Width, &Height)
		Pos := "x" X " y" Y " w" Width " h" Height
		if (Pos != Config["WindowSize"]) {
			Config["WindowSize"] := Pos
			IniWrite(Pos, CONFIG_FILEPATH, "Settings", "WindowSize")
		}
	}
}

MainGuiOnKeyDown(wParam, lParam, Msg, hWnd) {
	Static VK_ENTER := 0xD, VK_SPACE := 0x20, VK_PRIOR := 0x21, VK_NEXT := 0x22,
	       VK_UP := 0x26, VK_DOWN := 0x28, VK_C := 0x43, VK_E := 0x45, VK_F := 0x46
	If !(GuiCtrl := GuiCtrlFromHwnd(hWnd))
		Return
	Switch GuiCtrl.Gui
	{
		Case MainGui:
			Switch wParam
			{
				Case VK_SPACE:
					If !GetKeyState("Ctrl") && GuiCtrl.Name = "AddressList" {
						If OpenSelected()
							MainGui.Minimize(), MainGui.Hide()
						MainGuiReset()
					}
				Case VK_ENTER:
					If OpenSelected()
						MainGui.Minimize(), MainGui.Hide()
					MainGuiReset()
					Return 0
				Case VK_PRIOR, VK_NEXT, VK_UP, VK_DOWN:
					LV := MainGui["AddressList"]
					If hWnd != LV.Hwnd {
						LV.Modify(0, "-Focus -Select")
						LV.Focus()
						LV.Modify(wParam = VK_DOWN || wParam = VK_NEXT ? 1 : LV.GetCount(), "+Vis +Focus +Select")
						Return 0
					}
				Case VK_C:
					Return GetKeyState("Ctrl") ? (AddressListCopy(), 0) : ""
				Case VK_E:
					Return GetKeyState("Ctrl") ? (EditAddressList(), 0) : ""
				Case VK_F:
					Return GetKeyState("Ctrl") ? (FilterEdit.Focus(), 0) : ""
			}
	}
}

MainGuiOnDropFiles(GuiObj, GuiCtrl, FileArray, X, Y) {
	If !GuiCtrl
		Return
	Switch GuiCtrl.Hwnd {
		Case (LV:=MainGui["AddressList"]).Hwnd:
			AddressList := Config["AddressList"]
			For File in FileArray {
				AddressList.Push(File)
				PreparedAddressList.Push(ParseAddress(File))
			}
			IniDelete(CONFIG_FILEPATH, "AddressList")
			IniWrite(AddressList.Join("`n"), CONFIG_FILEPATH, "AddressList")
			UpdateAddressList()
			AdjustDimensions()
			LV.Modify(LV.GetCount(), "+Focus +Vis")
	}
}

MainGuiReset() {
	FilterEdit.Value := ""
	UpdateAddressList()
	AdjustDimensions()
	AddressList.Modify(1, "+Vis")
}

AddressListOnClick(LV, RowNumber) {
	If !RowNumber
		Return
	MainGui.Minimize()
	MainGui.Hide()
	OpenSelected()
	MainGuiReset()
}

AddressListCopy() {
	LV := MainGui["AddressList"]
	Selected := ""
	RowNumber := 0
	While RowNumber := LV.GetNext(RowNumber)
		Selected .= (A_Index = 1 ? "" : "`r`n") PreparedAddressList[LV.GetItemParam(RowNumber)]["Address"]
	If !Selected
		Return
	A_Clipboard := Selected
}

FilterOnChange(FilterCtrl, *) {
	Static DebounceFunc := () => (UpdateAddressList(FilterCtrl.value), FnObj := unset)
	SetTimer DebounceFunc, 0
	SetTimer DebounceFunc, -(FilterCtrl.value = "" ? 1 : 100)
}

UpdateAddressList(Query:="") {
	Global PreparedAddressList
	Static ImageListID
	If Query != "" {
		FilteredRows := []
		FilterLen := StrLen(Query)
		PrimaryI := 1
		For Index, AddressItem in PreparedAddressList {
			Name := AddressItem["Name"]
			Path := AddressItem["Path"]
			If SubStr(Name, 1, FilterLen) = Query
				FilteredRows.InsertAt(PrimaryI++, Index)
			Else If InStr(Name, Query) || InStr(Path, Query)
				FilteredRows.Push(Index)
		}
	}
	LV := MainGui["AddressList"]
	LV.Opt("-Redraw")
	TopIndex := SendMessage(0x1027,,, LV)-1 ; LVM_GETTOPINDEX
	CountPerPage := SendMessage(0x1028,,, LV) ; LVM_GETCOUNTPERPAGE
	LV.Delete()
	; Calculate buffer size required for SHFILEINFO structure.
	sfi_size := A_PtrSize + 688
	sfi := Buffer(sfi_size)
	
	If !IsSet(ImageListID) {
		ImageListID := IL_Create(PreparedAddressList.Length)
		LV.SetImageList(ImageListID)
	}
	If IsSet(FilteredRows) {
		For Index, RowNumber in FilteredRows {
			Add(PreparedAddressList[RowNumber], Index, RowNumber)
		}
	} Else {
		For Index, AddressItem in PreparedAddressList {
			Add(AddressItem, Index, Index)
		}
	}
	If TopIndex > 0 && Query = ""
		LV.Modify(TopIndex+CountPerPage+1, "+Vis")
	LV.Opt("+Redraw")

	Add(Address, Index, ID) {
		; Get the high-quality small-icon associated with this file extension:
		pFilePath := StrPtr(Address["FilePath"])
		If DllCall("Shell32\SHGetFileInfoW", "Ptr", pFilePath
			, "Uint", DllCall("kernel32.dll\GetFileAttributes", "Ptr", pFilePath)
			, "Ptr", sfi, "UInt", sfi_size, "UInt", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
			hIcon := NumGet(sfi, 0, "Ptr") ; Extract the hIcon member from the structure:
		Else
			hIcon := LoadPicture("imageres.dll", "Icon243 w16 h-1", &ImageType) ; Load a default icon
		; Add the HICON directly to the small-icon and large-icon lists.
		; Below uses +1 to convert the returned index from zero-based to one-based:
		IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID, "Int", -1, "Ptr", hIcon) + 1
		;DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID2, "Int", -1, "Ptr", hIcon)
		; Now that it's been copied into the ImageLists, the original should be destroyed:
		DllCall("DestroyIcon", "Ptr", hIcon)
		LV.Add("Icon" IconNumber, Address["Name"], Address["Path"])
		LV.SetItemParam(Index, ID)
	}
}

ParseAddress(Address) {
	Address := ExpandEnvironmentStrings(Address)
	SplitPath Address, &FileName, &FileDir
	Name := FileName, Path := Address, FilePath := Address
	If !DllCall("Shlwapi\PathIsDirectory", "Ptr", StrPtr(Address)) {
		DllCall("Shlwapi\PathRemoveArgs", "Ptr", StrPtr(NameOnly:=FileName))
		HasArgs := FileName != NameOnly
		FilePath := (FileDir = "" ? "" : FileDir "\") NameOnly
		If HasArgs
			Name := NameOnly, Path := FileName
		Else If DllCall("Shlwapi\PathFileExists", "Ptr", StrPtr(FilePath))
			Name := NameOnly, Path := FilePath
		Else For Item in ComObject("Shell.Application").NameSpace(0x11).Items ; ssfDRIVES
			If Item.IsFolder && Item.Name = FileName && (
			Name := Item.Name, Path := FilePath := Address := Item.Path
			, true)
				Break
		Else
			Name := FileName, Path := FilePath
	}
	Return Map("Name", Name, "Path", Path, "FilePath", FilePath, "Address", Address)
}

OpenSelected() {
	Global PreparedAddressList, hActvWnd
	Static WC_EXPLORER_WINDOW := "CabinetWClass", WC_EXPLORER_DIALOG := "#32770"
	ErrorLevel := 0
	Target_blank := GetKeyState("Ctrl")
	RowNumber := 0
	SelectedRows := []
	LV := MainGui["AddressList"]
	While RowNumber := LV.GetNext(RowNumber)
		SelectedRows.Push(LV.GetItemParam(RowNumber))
	If !SelectedRows.Length && LV.GetCount()
		SelectedRows.Push(LV.GetItemParam(1))
	For Row in SelectedRows {
		Address := PreparedAddressList[Row]["Address"]
		IsDir := DllCall("Shlwapi\PathIsDirectory", "Ptr", StrPtr(Address))
		UseRun := false
		WorkingDir := A_WorkingDir
		If Target_blank || !(IsSet(hActvWnd) && WinExist(hActvWnd)) {
			UseRun := true
		} Else {
			ExplorerClass := WinGetClass(hActvWnd)
			hExplorerWnd := hActvWnd
			Global hActvWnd := unset
			Switch ExplorerClass {
				Case WC_EXPLORER_WINDOW:
					Local ExplorerWindowObj
					For Window in ComObject("Shell.Application").Windows {
					} Until Window.Hwnd = hExplorerWnd && ExplorerWindowObj := Window
					If IsDir {
						ExplorerWindowObj.Navigate2(Address)
					} Else {
						WorkingDir := ExplorerWindowObj.Document.Folder.Self.Path
						UseRun := true
					}
				Case WC_EXPLORER_DIALOG:
					If IsDir {
						Try If ControlGetHwnd("Address Band Root1", hExplorerWnd) {
							WinActivate(hExplorerWnd)
							ControlSend "{Ctrl down}{l down}{l up}{Ctrl up}",, hExplorerWnd
							ControlSetText Address, "Edit2", hExplorerWnd
							ControlSend "{Enter}", "Edit2", hExplorerWnd
							ControlFocus "Edit1", hExplorerWnd
						}
					} Else {
						ControlFocus "Edit1", hExplorerWnd
						ControlSetText Address, "Edit1", hExplorerWnd
						ControlSend "{Enter}", "Edit1", hExplorerWnd
					}
				Default:
					UseRun := true
			}
		}
		If UseRun {
			If IsDir && SubStr(Address, -1) != "\"
				Address .= "\"
			Try {
				Run(Address, WorkingDir)
			} Catch as Err {
				ErrorLevel := 1
				MainGui.Opt("+OwnDialogs")
				Msgbox(Err.Message, "Can't launch address", 0x30)
			}
		}
	} Else {
		ErrorLevel := 1
	}
	Return !ErrorLevel
}

LoadConfig(Path, Default) {
	Config := Map()

	Try Config["ShowKey"] := IniRead(Path, "Settings", "ShowKey")
	Catch
		IniWrite(Default["ShowKey"], Path, "Settings", "ShowKey"),
		Config["ShowKey"] := Default["ShowKey"]

	Try Config["WindowSize"] := IniRead(Path, "Settings", "WindowSize")
	Catch
		IniWrite(Default["WindowSize"], Path, "Settings", "WindowSize"),
		Config["WindowSize"] := Default["WindowSize"]

	Try Config["AddressList"] := IniRead(Path, "AddressList")
	Catch
		IniWrite(Default["AddressList"], Path, "AddressList"),
		Config["AddressList"] := Default["AddressList"]

	; Post-processing
	Config["AddressList"] := LoadAddressList(Config["AddressList"])
	Return Config
}

LoadAddressList(AddressListStr) {
	Local AddressList := []
	Loop Parse, AddressListStr, "`n"
		If (Address:=Trim(A_LoopField)) != ""
			AddressList.Push(Address)
	Return AddressList
}

PrepareAddressList(AddressListArr) {
	Local PreparedAddressList := []
	For Address in AddressListArr
		PreparedAddressList.Push(ParseAddress(Address))
	Return PreparedAddressList
}

Settings(*) {
	Global Config
	ToggleHotkeys("Off")
	SettingsGui := Gui(, "Settings")
	SettingsGui.SetFont("s10", "Segoe UI")
	SettingsGui.AddGroupBox("xm w300 h100 section", "Hotkeys")
	SettingsGui.AddButton("xm y+10 w300", "Save").OnEvent("Click", Save)
	SettingsGui.SetFont("s9", "Segoe UI")
	SettingsGui.AddText("xs+10 ys+45 section", "Show/Hide Window: ")
	SettingsGui.AddHotkey("x+10 vShowKey", Config["ShowKey"])
	SettingsGui.OnEvent("Close", (GuiObj, *) => ( ToggleHotkeys("On"), GuiObj.Destroy() ))
	SettingsGui.Show()
	
	Save(*) {
		Submission := SettingsGui.Submit()
		Config["ShowKey"] := Submission.ShowKey != "" ? Submission.ShowKey : DefaultConfig["ShowKey"]
		IniWrite(Config["ShowKey"], CONFIG_FILEPATH, "Settings", "ShowKey")
		ToggleHotkeys("On")
	}
}


LV_GetVScrollWidth(LV) {
	Static SM_CXVSCROLL := SysGet(2)
	If DllCall("GetWindowLong", "Ptr", LV.Hwnd, "Int", -16) & 0x200000 ;WS_VSCROLL
		Return SM_CXVSCROLL
	Return 0
}

MoveLine(editCtrl, direction) { ; Thanks to teadrinker https://www.autohotkey.com/boards/viewtopic.php?p=580004#p579968
	static EM_GETCARETINDEX := 0x1512, EM_LINEFROMCHAR := 0x00C9, EM_LINEINDEX := 0x00BB, EM_GETLINE := 0x00C4
		 , EM_LINELENGTH := 0x00C1, EM_GETLINECOUNT := 0x00BA, EM_SETSEL := 0x00B1, EM_REPLACESEL := 0x00C2
	editCtrl.Opt("-Redraw")
	WinExist(editCtrl)
	caretPos := SendMessage(EM_GETCARETINDEX)
	currentLineIdx := SendMessage(EM_LINEFROMCHAR, caretPos)
	swapLineIdx := currentLineIdx + (direction ? 1 : -1)
	if swapLineIdx < 0 || swapLineIdx = SendMessage(EM_GETLINECOUNT) {
		return
	}
	currentLinePos := SendMessage(EM_LINEINDEX, currentLineIdx)
	swapLinePos := SendMessage(EM_LINEINDEX, swapLineIdx)
	currentLineText := GetLineText(currentLineIdx, currentLinePos, &currentLineLen)
	swapLineText := GetLineText(swapLineIdx, swapLinePos, &swapLineLen)
	
	line1 := direction ? 'swapLine' : 'currentLine'
	line2 := direction ? 'currentLine' : 'swapLine'
	text := %line1%Text . '`r`n' . %line2%Text
	StrPut(text, buf := Buffer(StrPut(text), 0))
	SendMessage(EM_SETSEL, %line2%Pos, %line1%Pos + %line1%Len)
	SendMessage(EM_REPLACESEL, true, buf)
	newCaretPos := SendMessage(EM_LINEINDEX, swapLineIdx) + caretPos - currentLinePos
	SendMessage(EM_SETSEL, newCaretPos, newCaretPos)
	editCtrl.Opt("+Redraw")
	static GetLineText(lineIdx, startPos, &len) {
		len := SendMessage(EM_LINELENGTH, startPos)
		NumPut('UShort', len, buf := Buffer(len * 2 + 2, 0))
		(len > 0 && SendMessage(EM_GETLINE, lineIdx, buf))
		return StrGet(buf)
	}
}

ExpandEnvironmentStrings(Str) {
	Local Chars := 0
	Local Expanded := ""
	If (Chars := DllCall("ExpandEnvironmentStringsW", "Str", Str, "Ptr", 0, "UInt", 0, "Int")) {
		VarSetStrCapacity(&Expanded, ++Chars)
		DllCall("ExpandEnvironmentStringsW", "Str", Str, "Str", &Expanded, "UInt", Chars, "Int")
	}
	Return (Chars ? Expanded : Str)
}

Init() {
	Array.Prototype.Join := ArrayJoin
	ArrayJoin(ArrayObj, Delim:=",") {
		Str := ""
		For Index, Value in ArrayObj
			Str .= Delim . Value
		Return SubStr(Str, StrLen(Delim)+1)
	}
	Gui.ListView.Prototype.SetItemParam := SetItemParam
	SetItemParam(This, Row, Value) {
		Static OffParam := 24 + (A_PtrSize * 2)
		This.Create_LVITEM(&LVITEM, 0x00000004, Row) ; LVIF_PARAM
		NumPut("Ptr", Value, LVITEM, OffParam)
		Return DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x104C, "Ptr", 0, "Ptr", LVITEM, "UInt")
	}
	Gui.ListView.Prototype.GetItemParam := GetItemParam
	GetItemParam(This, Row) {
		Static OffParam := 24 + (A_PtrSize * 2)
		This.Create_LVITEM(&LVITEM, 0x00000004, Row) ; LVIF_PARAM
		DllCall("SendMessage", "Ptr", This.HWND, "UInt", 0x104B, "Ptr", 0, "Ptr", LVITEM, "UInt")
		Return NumGet(LVITEM, OffParam, "UPtr")
	}
	Gui.ListView.Prototype.Create_LVITEM := Create_LVITEM
	Create_LVITEM(This, &LVITEM, Mask := 0, Row := 1, Col := 1) {
		Static LVITEMSize := 48 + (A_PtrSize * 3)
		LVITEM := Buffer(LVITEMSize, 0)
		NumPut("UInt", Mask, "Int", Row - 1, "Int", Col - 1, LVITEM)
	}
}
