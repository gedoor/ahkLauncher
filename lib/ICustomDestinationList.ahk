#Include IObjectArray.ahk
#Include DllUtils.ahk

class ICustomDestinationList {

    __New() {
        CLSID := "{77f10cf0-3db5-4966-b520-b7c54fd35ed6}"
        IID := "{6332debf-87b5-4670-90c0-5e57b408a49e}"
        this.comObj := ComObject(CLSID, IID)
    }

    SetAppID(id) {
        ComCall(03, this.comObj, "str", id)
    }

    BeginList(&MinSlots, &removedCol)
    {
        result := ComCall(04, this.comObj, "uint*", &MinSlots := 0, "ptr", IObjectArray.Type().ptr, "ptr*", &ppv := 0)
        removedCol := IObjectArray(ppv)
        return result
    }

    AppendCategory(szCategory, ObjectArray)
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
        ComCall(09, this.comObj, "ptr", IObjectArray.Type().ptr, "ptr*", &out)
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