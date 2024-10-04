#Requires AutoHotkey v2.0
#Include DllUtils.ahk

class IObjectArray {

    static CLSID := "{2d3468c1-36a7-43b6-ac24-d3f02fd9607a}"
    static IID := "{92CA9DCD-5622-4bba-A805-5E9F541BD8C9}"

    static Type := DllUtils.IIDFromString(this.IID)

    __new(comObj?)
    {
        if IsSet(comObj) {
            this.comObj := comObj
        } else {
            this.comObj := ComObject(IObjectArray.CLSID, IObjectArray.IID)
        }
        this.Ptr := this.comObj.Ptr
    }

    QueryInterface(&IID, &pobject)
    {
        return ComCall(0, this, "ptr", IID.ptr, "ptr*", pobject)
    }
    GetCount()
    {
        ComCall(3, this, "uint*", &count := 0)
        return count
    }
    GetAt(Index, type)
    {
        ComCall(4, this, "uint", Index, "ptr", type.ptr, "ptr*", &pVoid := 0)
        return pVoid
    }
}