/************************************************************************
 * @description 主题库
 ***********************************************************************/

#Requires AutoHotkey v2.0

class ThemeUtils {

    /**
     * 应用主题
     */
    static SysIsDarkMode => !RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme", 1)


    /**
     * 切换系统亮色暗色主题
     */
    static SwitchSysTheme() {
        isLightTheme := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "SystemUsesLightTheme", 1)
        RegWrite(!isLightTheme, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "SystemUsesLightTheme")
        RegWrite(!isLightTheme, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
    }


    /**
     * 设置菜单是否是drak模式
     * @param {Integer} Mode Dark = 1, Default (Light) = 0
     */
    static darkMenuMode(Mode := 1) {
        DllCall(DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "uxtheme", "ptr"), "ptr", 135, "ptr"), "int", mode)
        DllCall(DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "uxtheme", "ptr"), "ptr", 136, "ptr"))
    }


}