class Utils {


    static sendCmd(cmd, scriptname)
    {
        DetectHiddenWindows(true)
        cmd_no := Map("重启", 65303, "编辑", 65304, "挂起", 65305, "暂停", 65306, "退出", 65307)
        try {
            PostMessage(0x111, cmd_no[cmd], , , scriptname " - AutoHotkey")
        } catch {
            MsgBox("未找到" scriptname)
        }
    }

}