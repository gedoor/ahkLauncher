#Requires AutoHotkey v2.0

class DllUtils {

    static IIDFromString(IIDStr) {
        GUID := Buffer(16, 0)
        if DllCall("ole32\IIDFromString", "WStr", IIDStr, "Ptr", GUID) < 0
            throw ValueError("Invalid parameter #1", -1, IIDStr)
        return GUID
    }

    static DEFINE_PROPERTYKEY(fmtid, propertyid)
    {
        PropertyKeyStruct := Buffer(20)
        DllCall("ole32.dll\CLSIDFromString", "str", fmtid, "ptr", PropertyKeyStruct)
        NumPut("int", propertyid, PropertyKeyStruct, 16)
        return PropertyKeyStruct
    }

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