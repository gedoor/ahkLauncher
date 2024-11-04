class AhkScript {

    /**
     * 重载
     * @param scriptName 脚本名称
     */
    static Reload(scriptName) {
        this.Post0x111(scriptName, 65303)
    }

    /**
     * 编辑
     * @param scriptName 脚本名称
     */
    static Edit(scriptName) {
        this.Post0x111(scriptName, 65304)
    }

    /**
     * 挂起
     * @param scriptName 脚本名称
     */
    static Suspend(scriptName) {
        this.Post0x111(scriptName, 65305)
    }

    /**
     * 暂停
     * @param scriptName 脚本名称
     */
    static Puse(scriptName) {
        this.Post0x111(scriptName, 65306)
    }

    /**
     * 退出
     * @param scriptName 脚本名称
     */
    static Exit(scriptName) {
        this.Post0x111(scriptName, 65307)
    }

    static Post0x111(scriptName, message) {
        try {
            if InStr(scriptName, " - AutoHotkey v") {
                PostMessage(0x111, message, , , scriptname)
            } else {
                PostMessage(0x111, message, , , scriptname " - AutoHotkey v")
            }
            return true
        } catch {
            MsgBox("未找到" scriptname)
            return false
        }
    }

}