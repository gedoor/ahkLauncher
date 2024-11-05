/************************************************************************
 * @description win11剪贴板历史库
 ***********************************************************************/

class WinClip {
	static pIClipboardStatic := CreateInterface("Windows.ApplicationModel.DataTransfer.Clipboard", "{C627E291-34E2-4963-8EED-93CBB0EA3D70}")
	static pIClipboardStatic2 := CreateInterface("Windows.ApplicationModel.DataTransfer.Clipboard", "{D2AC1B6A-D29F-554B-B303-F0452345FE02}")
	static pIClipboardContentOptions := CreateInstance("Windows.ApplicationModel.DataTransfer.ClipboardContentOptions", "{E888A98C-AD4B-5447-A056-AB3556276D2B}")
	; 获取当前剪贴板内容
	static Content => (ComCall(6, this.pIClipboardStatic, "ptr*", &pIDataPackageView := 0), IDataPackageView(pIDataPackageView))
	; 获取当前历史记录集合
	static History{
		get{
			ComCall(6, this.pIClipboardStatic2, "uint*", &pIAsyncOperation := 0)
			pIClipboardHistoryItemsResult := WaitForAsync(pIAsyncOperation)
			ComCall(7, pIClipboardHistoryItemsResult, "ptr*", &pIReadOnlyList := 0)
			ObjRelease(pIClipboardHistoryItemsResult)
			return IReadOnlyListForClipboardHistoryItem(pIReadOnlyList)
		}
	}
	; 检查是否启用了历史记录
	static IsHistoryEnabled => (ComCall(10, this.pIClipboardStatic2, "char*", &bRes := 0), bRes)
	; 检查是否启用了多设备同步
	static IsRoamingEnabled => (ComCall(11, this.pIClipboardStatic2, "char*", &bRes := 0), bRes)
	; 清空当前剪贴板
	static Clear() => (ComCall(9, this.pIClipboardStatic))
	; 使设置在剪贴板的数据的原始应用程序关闭后可用
	static Flush() => (ComCall(8, this.pIClipboardStatic))
	; 清空历史记录
	static ClearHistory() => (ComCall(7, this.pIClipboardStatic2, "char*", &bRes := 0), bRes)
	; 为当前剪贴板设置文本，可选择是否加入历史记录和是否允许多设备同步
	static SetText(text, isAllowedInHistory := "", isRoamable := ""){
		A_Clipboard := ""
		ComCall(7, this.pIClipboardContentOptions, "char", (isRoamable  = 1 || isRoamable = 0) ? isRoamable : this.IsHistoryEnabled)
		ComCall(9, this.pIClipboardContentOptions, "char", (isAllowedInHistory = 1 || isAllowedInHistory = 0) ? isAllowedInHistory : this.IsHistoryEnabled)
		dataPackage := CreateDataPackage(), dataPackage.SetText(text)
		ComCall(12, this.pIClipboardStatic2, "ptr", dataPackage, "ptr", this.pIClipboardContentOptions, "char*", &bRes := 0)
		this.Flush()
		return bRes
	}
}
class IReadOnlyList extends InterfaceBase {
	; 检索指定索引的项目，0为第一个项目
	Item[index] => (ComCall(6, this, "int", index, "ptr*", &pItem := 0), pItem)
	; 检索此列表的项目数量
	Count => (ComCall(7, this, "uint*", &count := 0), count)
}
class IReadOnlyListForClipboardHistoryItem extends IReadOnlyList {
	Item[index] => (ComCall(6, this, "int", index, "ptr*", &pItem := 0), IClipboardHistoryItem(pItem))
}
class IClipboardHistoryItem extends InterfaceBase {
	; 此记录的ID
	Id => (ComCall(6, this, "ptr*", &pId:= 0), StrGet(pId + 28))
	; 时间戳
	Timestamp => (ComCall(7, this, "ptr*", &dateTime := 0), DateAdd(16010101000000, dateTime / 1e7, "S"))
	; 内容
	Content => (ComCall(8, this, "ptr*", &pIDataPackageView := 0), IDataPackageView(pIDataPackageView))
	; 删除此记录
	Delete() => (ComCall(8, WinClip.pIClipboardStatic2, "ptr", this, "char*", &bRes := 0), bRes)
	; 将此记录放到当前剪贴板
	Push() => (ComCall(9, WinClip.pIClipboardStatic2, "ptr", this, "char*", &bRes := 0), !bRes)
}
class IDataPackageView extends InterfaceBase {
	; 获取此内容支持的格式
	AvailableFormats{
		get{
			ComCall(9, this, "ptr*", &pIReadOnlyList := 0)
			formatsReadOnlyList := IReadOnlyList(pIReadOnlyList)
			formats := []
			loop formatsReadOnlyList.Count
				formats.Push(StrGet(formatsReadOnlyList.Item[A_Index - 1] + 28))
			return formats
		}
	}
	; 检查是否包含某种格式
	Contains(standardFormat) => (ComCall(10, this, "ptr", CreateHString(standardFormat), "char*", &bRes := 0), bRes)
	; 获取文本
	GetText(){
		try ComCall(12, this, "uint*", &pIAsyncOperation := 0)
		catch
			return
		return StrGet(WaitForAsync(pIAsyncOperation) + 28)
	}
	; 获取Html
	GetHtml(){
		try ComCall(15, this, "uint*", &pIAsyncOperation := 0)
		catch
			return
		return StrGet(WaitForAsync(pIAsyncOperation) + 28)
	}
	; 获取富文本
	GetRtf(){
		try ComCall(17, this, "uint*", &pIAsyncOperation := 0)
		catch
			return
		return StrGet(WaitForAsync(pIAsyncOperation) + 28)
	}
}
class IDataPackage extends InterfaceBase {
	SetText(text) => ComCall(16, this, "ptr", CreateHString(text))
}
class InterfaceBase {
	__New(ptr) => this.Ptr := ptr
	__Delete() => ObjRelease(this.Ptr)
}
class HString {
	__New(ptr) => this.Ptr := ptr
	__Delete() => DllCall("Combase\WindowsDeleteString", "ptr", this)
	GetStr() => StrGet(this.Ptr + 28)
}
CreateDataPackage() => IDataPackage(CreateInstance("Windows.ApplicationModel.DataTransfer.DataPackage", "{61EBF5C7-EFEA-4346-9554-981D7E198FFE}").Ptr)
CreateHString(str) => (DllCall("Combase\WindowsCreateString", "wstr", str, "uint", StrLen(str), "ptr*", &hStr := 0), HString(hStr))
CreateInterface(name, uuid){
	if res := DllCall("ole32\CLSIDFromString", "wstr", uuid, "ptr", pClsid := Buffer(16), "uint")
		throw Error("CLSIDFromString failed: " res)
	DllCall("Combase\WindowsCreateString", "wstr", name, "uint", StrLen(name), "ptr*", &hString := 0)
	if res := DllCall("Combase\RoGetActivationFactory", "ptr", hString, "ptr", pClsid, "ptr*", &pInterface := 0, "uint"){
		DllCall("Combase\WindowsDeleteString", "ptr", hString)
		throw Error("RoGetActivationFactory failed: " res)
	}
	DllCall("Combase\WindowsDeleteString", "ptr", hString)
	return pInterface
}
CreateInstance(name, uuid){
	DllCall("Combase\RoActivateInstance", "ptr", CreateHString(name), "ptr*", &instance := 0, "uint")
	return ComObjQuery(instance, uuid)
}
WaitForAsync(pIAsyncOperation){
	IAsyncInfo := ComObjQuery(pIAsyncOperation, "{00000036-0000-0000-C000-000000000046}")
	status := 0
	while !status
		ComCall(7, IAsyncInfo, "uint*", &status)
	if status != 1
		throw Error("AsyncOpertion Error")
	ComCall(8, pIAsyncOperation, "ptr*", &pResult := 0)
	ObjRelease(pIAsyncOperation)
	return pResult
}