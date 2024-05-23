class JumpList_IID {

    static __New() {
        this.IObjectArray := this.GUID("{92CA9DCD-5622-4bba-A805-5E9F541BD8C9}")
        this.IPersistFile := this.GUID("{0000010b-0000-0000-C000-000000000046}")
        this.IPropertyStore := this.GUID("{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}")
    }

    static GUID(sGUID) ; 转换字符串为二进制的 GUID 并返回其缓冲.
    {
        GUID := Buffer(16, 0)
        if DllCall("ole32\CLSIDFromString", "WStr", sGUID, "Ptr", GUID) < 0
            throw ValueError("Invalid parameter #1", -1, sGUID)
        return GUID
    }

}

class JumpList_PROPERTY_KEY {

    static __New() {
        this.PKEY_Title := this.DEFINE_PROPERTYKEY("{F29F85E0-4FF9-1068-AB91-08002B27B3D9}", 2)
    }

    static DEFINE_PROPERTYKEY(fmtid, propertyid)
    {
        PropertyKeyStruct := Buffer(20)
        DllCall("ole32.dll\CLSIDFromString", "str", fmtid, "ptr", PropertyKeyStruct)
        NumPut("int", propertyid, PropertyKeyStruct, 16)
        return PropertyKeyStruct
    }

}

class COM {
    static InitVariantFromString(str)
    {
        variant := Buffer(8 + 2 * A_PtrSize)
        NumPut("short", 31, variant, 0) 		; VT_LPWSTR
        hr := DllCall("Shlwapi\SHStrDupW", "ptr", StrPtr(str), "ptr*", &tempptr := 0)
        NumPut("ptr", tempptr, variant, 8)
        return variant
    }

    static InitVariantFromBoolean(bool)
    {
        variant := Buffer(8 + 2 * A_PtrSize)
        NumPut(11, variant, 0, "short") 		; VT_BOOL
        NumPut(bool, variant, 8, "int")
        return variant
    }
}


class CustomDestinationList {

    __New() {
        CLSID := "{77f10cf0-3db5-4966-b520-b7c54fd35ed6}"
        IID := "{6332debf-87b5-4670-90c0-5e57b408a49e}"
        this.comObj := ComObject(CLSID, IID)
    }

    SetAppID(id) {
        ComCall(03, this.comObj, "str", id)
    }

    BeginList()
    {
        ComCall(04, this.comObj, "uint*", &MinSlots := 0, "ptr", JumpList_IID.IObjectArray.ptr, "ptr*", &ppv := 0)
        return { minSlots: MinSlots, ppv: ppv }
    }

    AppendCategory(&szCategory, &ObjectArray)
    {
        return ComCall(05, this.comObj, "str", szCategory, "ptr", ObjectArray.ptr)
    }

    AppendKnownCategory(category)
    {
        return ComCall(06, this.comObj, "uint", category)
    }

    AddUserTasks(poa) {
        ComCall(07, this.comObj, "ptr", poa.ptr)
    }

    CommitList()
    {
        return ComCall(08, this.comObj)
    }

    GetRemovedDestinations()
    {
        ComCall(09, this.comObj, "ptr", JumpList_IID.IObjectArray.ptr, "ptr*", &out)
        return out
    }

    DeleteList(id)
    {
        return ComCall(10, this.comObj, "str", id)
    }

    AbortList()
    {
        return ComCall(11, this.comObj)
    }
}

class ShellLinkW {

    __New() {
        CLSID := "{00021401-0000-0000-C000-000000000046}"
        IID := "{000214F9-0000-0000-C000-000000000046}"
        this.comObj := ComObject(CLSID, IID)
        this.PersistFile := this.QueryInterface(JumpList_IID.IPersistFile)
        this.PropertyStore := this.QueryInterface(JumpList_IID.IPropertyStore)
    }

    ; IPersistFile
    IsDirty()
    {
        return ComCall(4, this.PersistFile)
    }
    Load(Filename, Mode)
    {
        return ComCall(5, this.PersistFile, "str", FileName, "int", Mode, "int", 0)
    }
    Save(Filename, fRemember)
    {
        return ComCall(6, this.PersistFile, "str", FileName, "int", fRemember, "int", 0)
    }
    SaveCompleted(Filename)
    {
        return ComCall(7, this.PersistFile, "str", FileName, "int", 0)
    }
    ; IShellLink
    QueryInterface(riid)
    {
        ComCall(0, this.comObj, "ptr", riid.ptr, "ptr*", &pinterface := 0)
        return pinterface
    }

    SetDescription(description)
    {
        return ComCall(07, this.comObj, "str", description)
    }

    SetWorkingDirectory(dir)
    {
        return ComCall(09, this.comObj, "str", dir)
    }

    SetArguments(args)
    {
        return ComCall(11, this.comObj, "str", args)
    }

    SetHotkey(hotkey)
    {
        return ComCall(13, this.comObj, "short", hotkey)
    }

    SetShowCmd(cmd)
    {
        return ComCall(15, this.comObj, "int", cmd)
    }

    SetIconLocation(path, index)
    {
        return ComCall(17, this.comObj, "str", path, "int", index)
    }

    SetRelativePath(path)
    {
        return ComCall(18, this.comObj, "str", path, "uint", 0) ; msdn: param 2 is reserved
    }

    SetPath(path)
    {
        return ComCall(20, this.comObj, "str", path)
    }

    SetTitle(title) {
        this.SetValue(JumpList_PROPERTY_KEY.PKEY_Title, COM.InitVariantFromString(title))
    }

    ; IPropertyStore
    GetCount()
    {
        ComCall(3, this.PropertyStore, "int*", &cProps := 0)
        return cProps
    }
    GetAt(iProp)
    {
        VarSetStrCapacity(&PROPERTYKEY, 20)
        ComCall(4, this.PropertyStore, "int", iProp, "ptr", PROPERTYKEY.ptr)
        return PROPERTYKEY
    }
    GetValue(PROPERTYKEY)
    {
        VarSetStrCapacity(&PROPVARIANT, 8 + 2 * A_PtrSize)
        ComCall(5, this.PropertyStore, "ptr", PROPERTYKEY.ptr, "ptr", PROPVARIANT.ptr)
        return PROPVARIANT
    }
    SetValue(key, variant)
    {
        return ComCall(6, this.PropertyStore, "ptr", key.ptr, "ptr", variant.ptr)
    }
    Commit()
    {
        return ComCall(7, this.PropertyStore)
    }
}

class EnumerableObjectCollection {

    __new()
    {
        CLSID := "{2d3468c1-36a7-43b6-ac24-d3f02fd9607a}"
        IID := "{5632b1a4-e38a-400a-928a-d4cd63230295}"
        this.comObj := ComObject(CLSID, IID)
    }
    ; IObjectArray
    QueryInterface(&IID, &pobject)
    {
        return ComCall(0, this.comObj, "ptr", IID.ptr, "ptr*", pobject)
    }
    GetCount()
    {
        ComCall(3, this.comObj, "uint*", &cObjects := 0)
        return cObjects
    }
    GetAt(Index)
    {
        ComCall(4, this.comObj, "uint", Index, "ptr*", &pVoid)
        return pVoid
    }
    ; IObjectCollection
    AddObject(Unknown)
    {
        return ComCall(5, this.comObj, "ptr", Unknown)
    }
    AddFromArray(objectArray)
    {
        ComCall(6, this.comObj, "ptr", objectArray)
    }
    RemoveObjectAt(uiIndex)
    {
        ComCall(7, this.comObj, "ptr", uiIndex.ptr)
    }
    Clear()
    {
        ComCall(8, this.comObj)
    }
}