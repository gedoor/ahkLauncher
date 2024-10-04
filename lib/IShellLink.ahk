#Requires AutoHotkey v2.0
#Include DllUtils.ahk

class IShellLink {

    static CLSID := "{00021401-0000-0000-C000-000000000046}"
    static IID := "{000214F9-0000-0000-C000-000000000046}"

    static PKEY_Title := DllUtils.DEFINE_PROPERTYKEY("{F29F85E0-4FF9-1068-AB91-08002B27B3D9}", 2)
    static PKEY_AppUserModel_ID := DllUtils.DEFINE_PROPERTYKEY("{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}", 5)

    static Type := DllUtils.IIDFromString(this.IID)

    __New(comObj?) {
        if IsSet(comObj) {
            this.comObj := comObj
        } else {
            this.comObj := ComObject(IShellLink.CLSID, IShellLink.IID)
        }
        this.Ptr := this.comObj.Ptr
        IPersistFileIID := "{0000010b-0000-0000-C000-000000000046}"
        this.PersistFile := ComObjQuery(this.Ptr, IPersistFileIID)
        IPropertyStoreIID := "{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}"
        this.PropertyStore := ComObjQuery(this.Ptr, IPropertyStoreIID)
    }

    ; IPersistFile
    /**
     * 确定对象自上次保存到其当前文件以来是否已更改。
     * @returns {BOOL}
     */
    IsDirty()
    {
        return ComCall(4, this.PersistFile)
    }
    /**
     * 打开指定文件并从文件内容初始化对象。
     * @param {String} pszFileName 要打开的文件的绝对路径。
     * @param {Integer} dwMode 打开文件时要使用的访问模式。 可能的值取自 STGM 枚举。 方法可以将此值视为建议，并在必要时添加更严格的权限。 如果 dwMode 为 0，则实现应使用用户打开文件时使用的任何默认权限打开文件。
     * @returns 是否成功
     */
    Load(Filename, Mode)
    {
        return ComCall(5, this.PersistFile, "str", FileName, "int", Mode, "int", 0)
    }
    /**
     * 将 对象的副本保存到指定文件。如.lnk
     * @param {String} pszFileName 对象应保存到的文件的绝对路径。 如果 pszFileName 为 NULL，则 对象应将其数据保存到当前文件（如果有）。
     * @param {BOOL} fRemember 指示 pszFileName 参数是否用作当前工作文件。 如果为 TRUE，则 pszFileName 将成为当前文件，并且对象应在保存后清除其脏标志。 如果 为 FALSE，则此保存操作是将 副本另存为 ... 操作。 在这种情况下，当前文件保持不变，对象不应清除其脏标志。 如果 pszFileName 为 NULL，则实现应忽略 fRemember 标志。
     * @returns 是否成功
     */
    Save(pszFileName, fRemember)
    {
        return ComCall(6, this.PersistFile, "str", pszFileName, "int", fRemember, "int", 0)
    }
    /**
     * 通知该对象它可以写入它的文件。 它通过通知对象可以从 NoScribble 模式还原 (，在该模式中，它不得写入其文件) ，到可以) 的普通模式 (。 组件在收到 IPersistFile：：Save 调用时进入 NoScribble 模式。
     * @param {String} pszFileName 先前保存对象的文件的绝对路径。
     * @returns 是否成功
     */
    SaveCompleted(pszFileName)
    {
        return ComCall(7, this.PersistFile, "str", pszFileName, "int", 0)
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

    GetTitle() {
        return this.GetValue(IShellLink.PKEY_Title)
    }

    SetTitle(title) {
        this.SetValue(IShellLink.PKEY_Title, DllUtils.InitVariantFromString(title))
    }

    GetAppUserModelID(){
        return this.GetValue(IShellLink.PKEY_AppUserModel_ID)
    }

    SetAppUserModelID(appId) {
        this.SetValue(IShellLink.PKEY_AppUserModel_ID, DllUtils.InitVariantFromString(appId))
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
        result := ComCall(5, this.PropertyStore, "ptr", PROPERTYKEY.ptr, "ptr", ptr := Buffer(16))
        return StrGet(NumGet(ptr, 8, "ptr"))
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