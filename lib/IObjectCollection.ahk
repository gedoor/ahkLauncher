#Requires AutoHotkey v2.0

class IObjectCollection extends IObjectArray {

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
        this.Ptr := this.comObj.Ptr
    }

    ; IObjectCollection
    AddObject(Unknown)
    {
        return ComCall(5, this, "ptr", Unknown)
    }
    AddFromArray(objectArray)
    {
        ComCall(6, this, "ptr", objectArray)
    }
    RemoveObjectAt(uiIndex)
    {
        ComCall(7, this, "ptr", uiIndex.ptr)
    }
    Clear()
    {
        ComCall(8, this)
    }
}