#Requires AutoHotkey v2.0
#Include DllUtils.ahk

class IShellLink {

    static CLSID := "{00021401-0000-0000-C000-000000000046}"
    static IID := "{000214F9-0000-0000-C000-000000000046}"

    static Call(comObj?) {
        return super.Call(comObj?)
    }

    static Type := DllUtils.IIDFromString(this.IID)

    __New(comObj?) {
        if IsSet(comObj) {
            this.comObj := comObj
        } else {
            this.comObj := ComObject(IShellLink.CLSID, IShellLink.IID)
        }
        if IsNumber(this.comObj) {
            this.Ptr := this.comObj
        } else {
            this.Ptr := this.comObj.Ptr
        }
        IPersistFileIID := "{0000010b-0000-0000-C000-000000000046}"
        this.PersistFile := this.QueryInterface(DllUtils.IIDFromString(IPersistFileIID))
        IPropertyStoreIID := "{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}"
        this.PropertyStore := this.QueryInterface(DllUtils.IIDFromString(IPropertyStoreIID))
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
        ComCall(0, this, "ptr", riid.ptr, "ptr*", &pinterface := 0)
        return pinterface
    }

    GetDescription()
    {
        VarSetStrCapacity(&description, 64) 
        ComCall(06, this, "str", description, "int", 64)
        return description
    }

    SetDescription(description)
    {
        return ComCall(07, this, "str", description)
    }

    SetWorkingDirectory(dir)
    {
        return ComCall(09, this, "str", dir)
    }

    SetArguments(args)
    {
        return ComCall(11, this, "str", args)
    }

    SetHotkey(hotkey)
    {
        return ComCall(13, this, "short", hotkey)
    }

    SetShowCmd(cmd)
    {
        return ComCall(15, this, "int", cmd)
    }

    SetIconLocation(path, index)
    {
        return ComCall(17, this, "str", path, "int", index)
    }

    SetRelativePath(path)
    {
        return ComCall(18, this, "str", path, "uint", 0) ; msdn: param 2 is reserved
    }

    SetPath(path)
    {
        return ComCall(20, this, "str", path)
    }

    SetTitle(title) {
        PKEY_Title := DllUtils.DEFINE_PROPERTYKEY("{F29F85E0-4FF9-1068-AB91-08002B27B3D9}", 2)
        this.SetValue(PKEY_Title, DllUtils.InitVariantFromString(title))
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
        ComCall(5, this.PropertyStore, "ptr", PROPERTYKEY.ptr, "ptr", StrPtr(PROPVARIANT))
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