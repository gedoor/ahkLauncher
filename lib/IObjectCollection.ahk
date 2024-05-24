class IObjectCollection {

    static CLSID := "{2d3468c1-36a7-43b6-ac24-d3f02fd9607a}"
    static IID := "{5632b1a4-e38a-400a-928a-d4cd63230295}"

    static Call(comObj?) {
        return super.Call(comObj?)
    }

    __new(comObj?)
    {
        if IsSet(comObj) {
            this.comObj := comObj
        } else {
            this.comObj := ComObject(IObjectCollection.CLSID, IObjectCollection.IID)
        }
    }
    ; IObjectArray
    QueryInterface(&IID, &pobject)
    {
        return ComCall(0, this.comObj, "ptr", IID.ptr, "ptr*", pobject)
    }
    GetCount()
    {
        ComCall(3, this.comObj, "uint*", &count := 0)
        return count
    }
    GetAt(Index, Type)
    {
        ComCall(4, this.comObj, "uint", Index, "ptr", Type.ptr, "ptr*", &pVoid)
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