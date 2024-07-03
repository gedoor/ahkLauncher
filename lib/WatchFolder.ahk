#Requires AutoHotkey v2.0

/**
 * Monitors a specified folder, including its subfolders (if enabled), for changes and triggers a user-defined function when changes occur.
 * This is an AHK v2 conversion of just me's WatchFolder()
 * https://www.autohotkey.com/boards/viewtopic.php?t=8384
 * 
 * @tested_with                         AHK 2.0.17
 * @tested_on                           Win 11 Pro
 * 
 * @usage                               WatchFolder(Folder, UserFunc[, SubTree := False[, Watch := 3]])
 * 
 * @param {String} Folder               The full qualified path of the folder to be watched.
 *                                          Pass the string "**PAUSE" and set UserFunc to either True or False to pause respectively resume watching.
 *                                          Pass the string "**END" and an arbitrary value in UserFunc to completely stop watching anytime.
 *                                          If not, it will be done internally on exit.
 * @param {String} UserFunc             The name of a user-defined function to call on changes. The function must accept at least two parameters:
 *                                          1: The path of the affected folder. The final backslash is not included even if it is a drive's root directory (e.g. C:).
 *                                          2: An array of change notifications containing the following keys:
 *                                              Action:   One of the integer values specified as FILE_ACTION_... (see below).
 *                                                          In case of renaming Action is set to FILE_ACTION_RENAMED (4).
 *                                              Name: The full path of the changed file or folder.
 *                                              OldName: The previous path in case of renaming, otherwise not used.
 *                                              IsDir: True if Name is a directory; otherwise False. In case of Action 2 (removed) IsDir is always False.
 *                                          Pass the string "**DEL" to remove the directory from the list of watched folders.
 * @param {Boolean} SubTree             Set to true if you want the whole subtree to be watched (i.e. the contents of all sub-folders).
 *                                          Default: False - sub-folders aren't watched.
 * @param {Number}  Watch               The kind of changes to watch for. This can be one or any combination of the FILE_NOTIFY_CHANGES_... values specified below.
 *                                          Default: 0x03 - FILE_NOTIFY_CHANGE_FILE_NAME + FILE_NOTIFY_CHANGE_DIR_NAME
 * 
 * @returns {Boolean}                   Returns True on success; otherwise False.
 * 
 * @remarks                             Due to the limits of the API function WaitForMultipleObjects() you cannot watch more than MAXIMUM_WAIT_OBJECTS (64) folders simultaneously.
 * 
 * @msdn
 * ReadDirectoryChangesW:           msdn.microsoft.com/en-us/library/aa365465(v=vs.85).aspx
 * FILE_NOTIFY_CHANGE_FILE_NAME     = 1     (0x00000001) : Notify about renaming, creating, or deleting a file.
 * FILE_NOTIFY_CHANGE_DIR_NAME      = 2     (0x00000002) : Notify about creating or deleting a directory.
 * FILE_NOTIFY_CHANGE_ATTRIBUTES    = 4     (0x00000004) : Notify about attribute changes.
 * FILE_NOTIFY_CHANGE_SIZE          = 8     (0x00000008) : Notify about any file-size change.
 * FILE_NOTIFY_CHANGE_LAST_WRITE    = 16    (0x00000010) : Notify about any change to the last write-time of files.
 * FILE_NOTIFY_CHANGE_LAST_ACCESS   = 32    (0x00000020) : Notify about any change to the last access time of files.
 * FILE_NOTIFY_CHANGE_CREATION      = 64    (0x00000040) : Notify about any change to the creation time of files.
 * FILE_NOTIFY_CHANGE_SECURITY      = 256   (0x00000100) : Notify about any security-descriptor change.
 * FILE_NOTIFY_INFORMATION:         msdn.microsoft.com/en-us/library/aa364391(v=vs.85).aspx
 * FILE_ACTION_ADDED                = 1     (0x00000001) : The file was added to the directory.
 * FILE_ACTION_REMOVED              = 2     (0x00000002) : The file was removed from the directory.
 * FILE_ACTION_MODIFIED             = 3     (0x00000003) : The file was modified.
 * FILE_ACTION_RENAMED              = 4     (0x00000004) : The file was renamed (not defined by Microsoft).
 * FILE_ACTION_RENAMED_OLD_NAME     = 4     (0x00000004) : The file was renamed and this is the old name.
 * FILE_ACTION_RENAMED_NEW_NAME     = 5     (0x00000005) : The file was renamed and this is the new name.
 * GetOverlappedResult:             msdn.microsoft.com/en-us/library/ms683209(v=vs.85).aspx
 * CreateFile:                      msdn.microsoft.com/en-us/library/aa363858(v=vs.85).aspx
 * FILE_FLAG_BACKUP_SEMANTICS       = 0x02000000
 * FILE_FLAG_OVERLAPPED             = 0x40000000
 */
WatchFolder(Folder, UserFunc, SubTree := False, Watch := 0x03) {
    Static DummyObject := { Base: { __Delete: WatchFolder.Bind("**END", "") } }
    Static TimerID := "**" . A_TickCount
    Static TimerFunc := WatchFolder.Bind(TimerID, "")
    Static MAXIMUM_WAIT_OBJECTS := 64
    Static MAX_DIR_PATH := 260 - 12 + 1
    Static SizeOfLongPath := MAX_DIR_PATH << !!1
    Static SizeOfFNI := 0xFFFF ; size of the FILE_NOTIFY_INFORMATION structure buffer (64 KB)
    Static SizeOfOVL := 32     ; size of the OVERLAPPED structure (64-bit)
    Static WatchedFolders := Map()
    Static EventArray := Map()
    Static WaitObjects := 0
    Static BytesRead := 0
    Static Paused := False
    ; ===============================================================================================================================
    If (Folder = "")
        Return False
    SetTimer(TimerFunc, 0)
    RebuildWaitObjects := False
    ; ===============================================================================================================================
    If (Folder = TimerID) { ; called by timer
        If (ObjCount := EventArray.Count) && !Paused {
            ObjIndex := DllCall("WaitForMultipleObjects", "UInt", ObjCount, "Ptr", WaitObjects, "Int", 0, "UInt", 0, "UInt")
            While (ObjIndex >= 0) && (ObjIndex < ObjCount) {
                Event := NumGet(WaitObjects, ObjIndex * A_PtrSize, "UPtr")
                Folder := EventArray[Event]
                If DllCall("GetOverlappedResult", "Ptr", Folder.Handle, "Ptr", Folder.OVLAddr, "UIntP", &BytesRead, "Int", True) {
                    Changes := Map()
                    FNIAddr := Folder.FNIAddr
                    FNIMax := FNIAddr + BytesRead
                    OffSet := 0
                    PrevIndex := 0
                    PrevAction := 0
                    PrevName := ""
                    Loop {
                        FNIAddr += Offset
                        OffSet := NumGet(FNIAddr + 0, "UInt")
                        Action := NumGet(FNIAddr + 4, "UInt")
                        Length := NumGet(FNIAddr + 8, "UInt") // 2
                        Name := Folder.Name . "\" . StrGet(FNIAddr + 12, Length, "UTF-16")
                        IsDir := InStr(FileExist(Name), "D") ? 1 : 0
                        If (Name = PrevName) {
                            If (Action = PrevAction)
                                Continue
                            If (Action = 1) && (PrevAction = 2) {
                                PrevAction := Action
                                Changes.Delete(PrevIndex--)
                                Continue
                            }
                        }

                        If (Action = 4) {
                            PrevIndex := A_Index
                            Changes[A_Index] := { Action: Action, OldName: Name, IsDir: 0 }
                        }
                        Else If (Action = 5) && (PrevAction = 4) {
                            Changes[PrevIndex].Name := Name
                            Changes[PrevIndex].IsDir := IsDir
                        }
                        Else {
                            PrevIndex := A_Index
                            Changes[A_Index] := { Action: Action, Name: Name, IsDir: IsDir }
                        }

                        PrevAction := Action
                        PrevName := Name
                    } Until (Offset = 0) || ((FNIAddr + Offset) > FNIMax)

                    If (Changes.Count > 0)
                        Folder.Func.Call(Folder.Name, Changes)
                    DllCall("ResetEvent", "Ptr", Event)
                    DllCall("ReadDirectoryChangesW", "Ptr", Folder.Handle, "Ptr", Folder.FNIAddr, "UInt", SizeOfFNI, "Int", Folder.SubTree, "UInt", Folder.Watch, "UInt", 0, "Ptr", Folder.OVLAddr, "Ptr", 0)
                }
                ObjIndex := DllCall("WaitForMultipleObjects", "UInt", ObjCount, "Ptr", WaitObjects, "Int", 0, "UInt", 0, "UInt")
                Sleep(0)
            }
        }
    }
    ; ===============================================================================================================================
    Else If (Folder = "**PAUSE") { ; called to pause/resume watching
        Paused := !!UserFunc
        RebuildObjects := Paused
    }
    ; ===============================================================================================================================
    Else If (Folder = "**END") { ; called to stop watching
        For Event, Folder In EventArray {
            DllCall("CloseHandle", "Ptr", Folder.Handle)
            DllCall("CloseHandle", "Ptr", Event)
        }
        WatchedFolders := Map()
        EventArray := Map()
        Paused := False
        Return True
    }
    ; ===============================================================================================================================
    Else { ; called to add, update, or remove folders
        Folder := RTrim(Folder, "\")
        LongPath := Buffer(MAX_DIR_PATH << !!1, 0)
        If !DllCall("GetLongPathName", "Str", Folder, "Ptr", LongPath, "UInt", MAX_DIR_PATH)
            Return False
        LongPath := StrGet(LongPath, "UTF-16")
        Folder := LongPath
        If (WatchedFolders.HasOwnProp(Folder)) {
            Event := WatchedFolders[Folder]
            FolderObj := EventArray[Event]
            DllCall("CloseHandle", "Ptr", FolderObj.Handle)
            DllCall("CloseHandle", "Ptr", Event)
            EventArray.Delete(Event)
            WatchedFolders.Delete(Folder)
            RebuildWaitObjects := True
        }
        If InStr(FileExist(Folder), "D") && (UserFunc != "**DEL") && (EventArray.Count < MAXIMUM_WAIT_OBJECTS) {
            If (IsFunc(UserFunc) && (UserFunc := %UserFunc%) && (UserFunc.MinParams >= 2)) && (Watch &= 0x017F) {
                Handle := DllCall("CreateFile", "Str", Folder . "\", "UInt", 0x01, "UInt", 0x07, "Ptr", 0, "UInt", 0x03, "UInt", 0x42000000, "Ptr", 0, "UPtr")
                If (Handle > 0) {
                    Event := DllCall("CreateEvent", "Ptr", 0, "Int", 1, "Int", 0, "Ptr", 0)
                    FolderObj := { Name: Folder, Func: UserFunc, Handle: Handle, SubTree: !!SubTree, Watch: Watch }
                    FolderObj.FNIBuff := Buffer(SizeOfFNI)
                    DllCall("RtlZeroMemory", "Ptr", FolderObj.FNIBuff.Ptr, "Ptr", SizeOfFNI)
                    FolderObj.FNIAddr := FolderObj.FNIBuff.Ptr

                    FolderObj.OVLBuff := Buffer(SizeOfOVL)
                    DllCall("RtlZeroMemory", "Ptr", FolderObj.OVLBuff.Ptr, "Ptr", SizeOfOVL)
                    NumPut("Ptr", Event, FolderObj.OVLBuff.Ptr + 8, A_PtrSize * 2)
                    FolderObj.OVLAddr := FolderObj.OVLBuff.Ptr
                    DllCall("ReadDirectoryChangesW", "Ptr", Handle, "Ptr", FolderObj.FNIAddr, "UInt", SizeOfFNI, "Int", SubTree, "UInt", Watch, "UInt", 0, "Ptr", FolderObj.OVLAddr, "Ptr", 0)
                    EventArray[Event] := FolderObj
                    WatchedFolders[Folder] := Event
                    RebuildWaitObjects := True

                    ; Event creation
                    Event := DllCall("CreateEvent", "Ptr", 0, "Int", 1, "Int", 0, "Ptr", 0)
                }
            }
        }
        If (RebuildWaitObjects) {
            WaitObjects := Buffer(MAXIMUM_WAIT_OBJECTS * A_PtrSize, 0)
            Offset := WaitObjects.Ptr
            For Event In EventArray {
                Offset := NumPut("Ptr", Event, Offset, 0)
            }
        }
    }
    ; ===============================================================================================================================
    If (EventArray.Count > 0)
        SetTimer(TimerFunc, -100)
    Return (RebuildWaitObjects) ; returns True on success, otherwise False

    ; ===============================================================================================================================
    IsFunc(FunctionName) {
        Try
            return %FunctionName%.MinParams + 1
        Catch
            return 0
        return
    }
}