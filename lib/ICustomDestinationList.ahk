#Requires AutoHotkey v2.0
#Include IObjectArray.ahk
#Include DllUtils.ahk

class ICustomDestinationList {

    __New() {
        CLSID := "{77f10cf0-3db5-4966-b520-b7c54fd35ed6}"
        IID := "{6332debf-87b5-4670-90c0-5e57b408a49e}"
        this.comObj := ComObject(CLSID, IID)
        this.Ptr := this.comObj.Ptr
    }

    SetAppID(id) {
        ComCall(03, this, "str", id)
    }

    BeginList(&MinSlots, &removedCol)
    {
        result := ComCall(04, this, "uint*", &MinSlots := 0, "ptr", IObjectArray.Type.ptr, "ptr*", &ppv := 0)
        removedCol := IObjectArray(ppv)
        return result
    }

    AppendCategory(szCategory, ObjectArray)
    {
        return ComCall(05, this, "str", szCategory, "ptr", ObjectArray.ptr)
    }

    AppendKnownCategory(category)
    {
        return ComCall(06, this, "uint", category)
    }

    AddUserTasks(poa) {
        ComCall(07, this, "ptr", poa.ptr)
    }

    CommitList()
    {
        return ComCall(08, this)
    }

    GetRemovedDestinations()
    {
        ComCall(09, this, "ptr", IObjectArray.Type.ptr, "ptr*", &out)
        return out
    }

    DeleteList(id)
    {
        return ComCall(10, this, "str", id)
    }

    AbortList()
    {
        return ComCall(11, this)
    }
}