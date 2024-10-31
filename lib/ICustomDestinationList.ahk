#Requires AutoHotkey v2.0
#Include IObjectArray.ahk
#Include DllUtils.ahk

/**
 * 自定义任务跳转列表
 */
class ICustomDestinationList {

    __New() {
        CLSID := "{77f10cf0-3db5-4966-b520-b7c54fd35ed6}"
        IID := "{6332debf-87b5-4670-90c0-5e57b408a49e}"
        this.comObj := ComObject(CLSID, IID)
        this.Ptr := this.comObj.Ptr
    }

    /**
     * 设置AppUserModelID
     * @param {String} id
     */
    SetAppID(id) {
        ComCall(03, this, "str", id)
    }

    /**
     * 启动自定义跳转列表的生成会话。如需生成新的列表必须先调用此方法
     * @param {&Integer} MinSlots 输出跳转列表显示的最大数目
     * @param {&IObjectArray} removedCol 输出移除的项目
     * @returns {Integer} 是否执行成功
     */
    BeginList(&MinSlots, &removedCol)
    {
        result := ComCall(04, this, "uint*", &MinSlots := 0, "ptr", IObjectArray.Type.ptr, "ptr*", &ppv := 0)
        removedCol := IObjectArray(ComValue(0xD, ppv))
        return result
    }

    /**
     * 添加自定义类别
     * @param {String} szCategory 类别名称
     * @param {IObjectArray} ObjectArray IshellLink列表
     * @returns {Float | Integer | String} 
     */
    AppendCategory(szCategory, ObjectArray)
    {
        return ComCall(05, this, "str", szCategory, "ptr", ObjectArray.ptr)
    }

    /**
     * 指定系统“频繁”或“最近”类别应包含在自定义跳转列表中。
     * @param category 0x1 常用, 0x2 最近
     * @returns {Integer} 是否执行成功
     */
    AppendKnownCategory(category)
    {
        return ComCall(06, this, "uint", category)
    }

    /**
     * 添加任务列表
     * @param {IObjectArray} poa 任务列表
     */
    AddUserTasks(poa) {
        ComCall(07, this, "ptr", poa.ptr)
    }

    /**
     * 提交
     * @returns 是否执行成功
     */
    CommitList()
    {
        return ComCall(08, this)
    }

    /**
     * 检索列表中删除的当前目标列表。
     */
    GetRemovedDestinations()
    {
        ComCall(09, this, "ptr", IObjectArray.Type.ptr, "ptr*", &out)
        return IObjectArray(ComValue(0xD, out))
    }

    /**
     * 删除指定应用程序的自定义跳转列表。
     * @param {String} id AppUserModelID
     * @returns 是否执行成功
     */
    DeleteList(id)
    {
        return ComCall(10, this, "str", id)
    }

    /**
     * 停止BeginList 发起的跳转列表生成会话，而不提交任何更改。
     * @returns 是否执行成功
     */
    AbortList()
    {
        return ComCall(11, this)
    }
}