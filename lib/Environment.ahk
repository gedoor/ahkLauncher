/************************************************************************
 * @description 永久更改用户和系统环境变量
 ***********************************************************************/
#Requires AutoHotkey v2.0

class Env {
    static UserAddFirst(name, value, type?, key?) => Env.PriVate.Add(name, value, type?, key?, True, 0)
    static UserAddLast(name, value, type?, key?) => Env.PriVate.Add(name, value, type?, key?, True, 1)
    static UserAddSort(name, value, type?, key?) => Env.PriVate.Add(name, value, type?, key?, True, 2)
    static UserAddUnique(name, value, type?, key?) => Env.PriVate.Add(name, value, type?, key?, True, 3)
    static UserAddFirstUnblock(name, value, type?, key?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, key?, True, 0))
    static UserAddLastUnblock(name, value, type?, key?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, key?, True, 1))
    static UserAddSortUnblock(name, value, type?, key?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, key?, True, 2))
    static UserAddUniqueUnblock(name, value, type?, key?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, key?, True, 3))
    static UserAddFirstFast(name, value, type?, key?) => Env.PriVate.Add(name, value, type?, key?, False, 0)
    static UserAddLastFast(name, value, type?, key?) => Env.PriVate.Add(name, value, type?, key?, False, 1)
    static UserAddSortFast(name, value, type?, key?) => Env.PriVate.Add(name, value, type?, key?, False, 2)
    static UserAddUniqueFast(name, value, type?, key?) => Env.PriVate.Add(name, value, type?, key?, False, 3)
    static UserAddFirstUnblockFast(name, value, type?, key?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, key?, False, 0))
    static UserAddLastUnblockFast(name, value, type?, key?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, key?, False, 1))
    static UserAddSortUnblockFast(name, value, type?, key?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, key?, False, 2))
    static UserAddUniqueUnblockFast(name, value, type?, key?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, key?, False, 3))
    static UserSubFast(name, value, type?, key?) => Env.PriVate.Sub(name, value, type?, key?, False)
    static UserRemove(name, value, type?, key?) => Env.PriVate.Sub(name, value, type?, key?)
    static UserRemoveFast(name, value, type?, key?) => Env.PriVate.Sub(name, value, type?, key?, False)
    static UserTempFirst(name, value, type?, key?) => Env.PriVate.Temp(name, value, type?, key?, True, 0)
    static UserTempLast(name, value, type?, key?) => Env.PriVate.Temp(name, value, type?, key?, True, 1)
    static UserTempFirstUnblock(name, value, type?, key?) => (Env.PriVate.Unblock(value), Env.PriVate.Temp(name, value, type?, key?, True, 0))
    static UserTempLastUnblock(name, value, type?, key?) => (Env.PriVate.Unblock(value), Env.PriVate.Temp(name, value, type?, key?, True, 1))
    static UserTempFirstFast(name, value, type?, key?) => Env.PriVate.Temp(name, value, type?, key?, False, 0)
    static UserTempLastFast(name, value, type?, key?) => Env.PriVate.Temp(name, value, type?, key?, False, 1)
    static UserTempFirstUnblockFast(name, value, type?, key?) => (Env.PriVate.Unblock(value), Env.PriVate.Temp(name, value, type?, key?, False, 0))
    static UserTempLastUnblockFast(name, value, type?, key?) => (Env.PriVate.Unblock(value), Env.PriVate.Temp(name, value, type?, key?, False, 1))

    static SystemAdd(name, value, type?) => Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
    static SystemAddFirst(name, value, type?) => Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 0)
    static SystemAddLast(name, value, type?) => Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 1)
    static SystemAddSort(name, value, type?) => Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 2)
    static SystemAddUnique(name, value, type?) => Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 3)
    static SystemAddFirstUnblock(name, value, type?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 0))
    static SystemAddLastUnblock(name, value, type?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 1))
    static SystemAddSortUnblock(name, value, type?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 2))
    static SystemAddUniqueUnblock(name, value, type?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 3))
    static SystemAddFirstFast(name, value, type?) => Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 0)
    static SystemAddLastFast(name, value, type?) => Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 1)
    static SystemAddSortFast(name, value, type?) => Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 2)
    static SystemAddUniqueFast(name, value, type?) => Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 3)
    static SystemAddFirstUnblockFast(name, value, type?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session\Manager\Environment", False, 0))
    static SystemAddLastUnblockFast(name, value, type?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 1))
    static SystemAddSortUnblockFast(name, value, type?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 2))
    static SystemAddUniqueUnblockFast(name, value, type?) => (Env.PriVate.Unblock(value), Env.PriVate.Add(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 3))
    static SystemSub(name, value, type?) => Env.PriVate.Sub(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True)
    static SystemSubFast(name, value, type?) => Env.PriVate.Sub(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False)
    static SystemRemove(name, value, type?) => Env.PriVate.Sub(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True)
    static SystemRemoveFast(name, value, type?) => Env.PriVate.Sub(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False)
    static SystemTemp(name, value, type?) => Env.PriVate.Temp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 0)
    static SystemTempFirst(name, value, type?) => Env.PriVate.Temp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 0)
    static SystemTempLast(name, value, type?) => Env.PriVate.Temp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 1)
    static SystemTempFirstUnblock(name, value, type?) => (Env.PriVate.Unblock(value), Env.PriVate.Temp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 0))
    static SystemTempLastUnblock(name, value, type?) => (Env.PriVate.Unblock(value), Env.PriVate.Temp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", True, 1))
    static SystemTempFirstFast(name, value, type?) => Env.PriVate.Temp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 0)
    static SystemTempLastFast(name, value, type?) => Env.PriVate.Temp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 1)
    static SystemTempFirstUnblockFast(name, value, type?) => (Env.PriVate.Unblock(value), Env.PriVate.Temp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 0))
    static SystemTempLastUnblockFast(name, value, type?) => (Env.PriVate.Unblock(value), Env.PriVate.Temp(name, value, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", False, 1))
    static SystemNew(name, value?, type?) => Env.PriVate.New(name, value?, type?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
    static SystemDel(name, value?) => Env.PriVate.Del(name, value?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
    static SystemRead(name, value?) => Env.PriVate.Read(name, value?, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
    static SystemSort(name) => Env.PriVate.Sort(name, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
    static SystemUnique(name) => Env.PriVate.Unique(name, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
    static SystemBackup(filepath := "SystemEnvironment.reg") => Env.PriVate.Backup(filepath, "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment")
    static SystemRestore(filepath := "SystemEnvironment.reg") => Env.PriVate.Restore(filepath)

    class PriVate {

        static Add(name, value, type := "", key := "HKCU\Environment", broadcast := true, pos := 0) {
            (value ~= "^\.(\.)?\\") && value := Env.PriVate.GetFullPathName(value)

            ; Check if the registry key exists.
            try reg := RegRead(key, name)
            if IsSet(reg) {
                Loop Parse, reg, ";"
                    if (A_LoopField == value)
                        return 0

                reg := Trim(reg, ";")
                value := (pos = 0) ? value ";" reg
                    : (pos = 1) ? reg ";" value
                    : (pos = 2) ? Sort(reg ";" value, "D;")
                    : Sort(reg ";" value, "U D;")
            }

            ; Create a new registry key.
            (type) || type := (value ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
            RegWrite value, type, key, name

            if (broadcast) {
                Env.PriVate.SettingChange()
                Env.PriVate.RefreshEnvironment()
            }
            return 1
        }

        static Sub(name, value, type := "", key := "HKCU\Environment", broadcast := True) {
            (value ~= "^\.(\.)?\\") && value := Env.PriVate.GetFullPathName(value)

            ; Registry key may be deleted.
            try reg := RegRead(key, name)
            catch
                return 0

            ; Can't use RegEx because of special characters.
            out := ""
            Loop Parse, reg, ";"
                if (A_LoopField != value) {
                    output .= (A_Index > 1 && out != "") ? ";" : ""
                    output .= A_LoopField
                }

            if (out = reg)
                return 0

            if (out != "") {
                (type) || type := (value ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
                RegWrite out, type, key, name
            }
            else
                RegDelete key, name

            if (broadcast) {
                Env.PriVate.SettingChange()
                Env.PriVate.RefreshEnvironment()
            }
            return 1
        }

        static Temp(name, value, type := "", key := "HKCU\Environment", broadcast := True, pos := 0) {
            if !DirExist(value)
                return 0

            Env.PriVate.Add(name, value, type, key, broadcast, pos)
            OnExit (*) => (Env.PriVate.Sub(name, value, type, key, broadcast), 0)
        }

        static New(name, value := "", type := "", key := "HKCU\Environment", broadcast := True) {
            (value ~= "^\.(\.)?\\") && value := Env.PriVate.GetFullPathName(value)
            (type) || type := (value ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
            RegWrite value, type, key, name
            if (broadcast) {
                Env.PriVate.SettingChange()
                Env.PriVate.RefreshEnvironment()
            }
            return 1
        }

        ; Value does nothing except let me easily change between functions.
        static Del(name, value := "", key := "HKCU\Environment", broadcast := True) {
            RegDelete key, name
            if (broadcast) {
                Env.PriVate.SettingChange()
                Env.PriVate.RefreshEnvironment()
            }
            return 1
        }

        static Read(name, value := "", key := "HKCU\Environment") {
            reg := RegRead(key, name)
            if (value != "") {
                Loop Parse, reg, ";"
                    if (A_LoopField = value)
                        return A_LoopField
                return "" ; Value not found
            }
            return reg
        }

        static Sort(name, key := "HKCU\Environment") {
            reg := RegRead(key, name)
            reg := Sort(reg, "D;")
            type := (reg ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
            RegWrite reg, type, key, name
            return 1
        }

        static Unique(name, key := "HKCU\Environment") {
            reg := RegRead(key, name)
            reg := Sort(reg, "U D;")
            type := (reg ~= "%") ? "REG_EXPAND_SZ" : "REG_SZ"
            RegWrite reg, type, key, name
            return 1
        }

        static Backup(filepath := "UserEnvironment.reg", key := "HKCU\Environment") {
            _cmd := (A_Is64bitOS != A_PtrSize >> 3) ? A_WinDir "\SysNative\cmd.exe" : A_ComSpec
            _cmd .= ' /K "reg export "' key '" "' filepath '" && pause && exit'
            try RunWait _cmd
            catch
                return "FAIL"
            return "SUCCESS"
        }

        static Restore(filepath := "UserEnvironment.reg") {
            try RunWait filepath
            catch
                return "FAIL"
            return "SUCCESS"
        }

        static RefreshEnvironment() {
            Path := ""
            PathExt := ""
            Loop Parse, "HKCU\Environment,HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "CSV"
            {
                Loop Reg, A_LoopField
                {
                    value := RegRead()
                    if (A_LoopRegType == "REG_EXPAND_SZ")
                        value := Env.PriVate.ExpandEnvironmentStrings(value)

                    if (A_LoopRegName = "PATH")
                        Path .= value . ";"
                    else if (A_LoopRegName = "PATHEXT")
                        PathExt .= value . ";"
                    else
                        EnvSet A_LoopRegName, value
                }
            }
            EnvSet "PATH", Path
            EnvSet "PATHEXT", PathExt
        }

        static ExpandEnvironmentStrings(str) {
            length := 1 + DllCall("ExpandEnvironmentStrings", "str", str, "ptr", 0, "int", 0)
            VarSetStrCapacity(&expanded_str, length)
            DllCall("ExpandEnvironmentStrings", "str", str, "str", expanded_str, "int", length)
            return expanded_str
        }

        static GetFullPathName(path) {
            cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
            VarSetStrCapacity(&buf, cc)
            DllCall("GetFullPathName", "str", path, "uint", cc, "str", buf, "ptr", 0, "uint")
            return buf
        }

        static SettingChange() {
            SendMessage 0x1A, 0, StrPtr("Environment"), , "ahk_id" 0xFFFF ; 0x1A is WM_SETTINGCHANGE
        }

        static Unblock(filepath) {
            Loop Files filepath "\*", 'FR'
                if FileExist(A_LoopFileFullPath ":Zone.Identifier:$DATA")
                    FileDelete A_LoopFileFullPath ":Zone.Identifier:$DATA"
        }
    }

}