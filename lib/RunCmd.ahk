#Requires AutoHotkey v2.0

/**
 * 执行CMD命令
 * @param P_CmdLine 要执行的命令行 A_Comspec " /c " cmd。
 * @param {String} P_WorkingDir 工作目录,如果省略，则启动的进程将默认为A_WorkingDir。
 * @param {String} P_Codepage 默认：cp0。 使用utf-8或者utf-16处理unicode时。
 * @param {Integer} P_Func 默认值：Nil。辅助函数对象。当辅助函数可用时，RunCMD()将使用两个参数调用它 文本，行号。您可以在辅助函数中控制输出。
 * @param {Integer} P_Slow 默认值：True。当为 True 时，会减慢该功能以降低处理器使用率。
 * @returns {String} 
 */
RunCMD(P_CmdLine, P_WorkingDir := "", P_Codepage := "cp0", P_Func := 0, P_Slow := 1)
{  ;  RunCMD v1.00.2 for ah2 By SKAN on D67D/D7AF @ autohotkey.com/r/?t=133668
    ;  Based on StdOutToVar.ahk by Sean @ www.autohotkey.com/board/topic/15455-stdouttovar

    Local hPipeR := 0
        , hPipeW := 0
        , PIPE_NOWAIT := 1
        , HANDLE_FLAG_INHERIT := 1
        , dwMask := HANDLE_FLAG_INHERIT
        , dwFlags := HANDLE_FLAG_INHERIT

    DllCall("Kernel32\CreatePipe", "ptrp", &hPipeR, "ptrp", &hPipeW, "ptr", 0, "int", 0)
    , DllCall("Kernel32\SetHandleInformation", "ptr", hPipeW, "int", dwMask, "int", dwFlags)

    Local B_OK := 0
        , P8 := A_PtrSize = 8
        , STARTF_USESTDHANDLES := 0x100
        , STARTUPINFO := Buffer(P8 ? 104 : 68, 0)                  ;  STARTUPINFO

    NumPut("uint", P8 ? 104 : 68, STARTUPINFO)                                 ;  STARTUPINFO.cb
    , NumPut("uint", STARTF_USESTDHANDLES, STARTUPINFO, P8 ? 60 : 44)            ;  STARTUPINFO.dwFlags
    , NumPut("ptr", hPipeW, STARTUPINFO, P8 ? 88 : 60)                          ;  STARTUPINFO.hStdOutput
    , NumPut("ptr", hPipeW, STARTUPINFO, P8 ? 96 : 64)                          ;  STARTUPINFO.hStdError

    Local CREATE_NO_WINDOW := 0x08000000
        , PRIORITY_CLASS := DllCall("Kernel32\GetPriorityClass", "ptr", -1, "uint")
        , PROCESS_INFORMATION := Buffer(P8 ? 24 : 16, 0)                  ;  PROCESS_INFORMATION

    RunCMD.PID := 0
        , RunCMD.ExitCode := 0
        , RunCMD.Iterations := 0
        , B_OK := DllCall("Kernel32\CreateProcessW"
            , "ptr", 0                                                 ;  lpApplicationName
            , "ptr", StrPtr(P_CmdLine)                                 ;  lpCommandLine
            , "ptr", 0                                                 ;  lpProcessAttributes
            , "ptr", 0                                                 ;  lpThreadAttributes
            , "int", True                                              ;  bInheritHandles
            , "int", CREATE_NO_WINDOW | PRIORITY_CLASS                 ;  dwCreationFlags
            , "int", 0                                                 ;  lpEnvironment
            , "ptr", DirExist(P_WorkingDir) ? StrPtr(P_WorkingDir) : 0 ;  lpCurrentDirectory
            , "ptr", STARTUPINFO                                       ;  lpStartupInfo
            , "ptr", PROCESS_INFORMATION                               ;  lpProcessInformation
            , "uint")

    DllCall("Kernel32\CloseHandle", "ptr", hPipeW)

    If (B_OK = False
        and DllCall("Kernel32\CloseHandle", "ptr", hPipeR))
        Return

    RunCMD.PID := NumGet(PROCESS_INFORMATION, P8 ? 16 : 8, "uint")

    Local FileObj := FileOpen(hPipeR, "h", P_Codepage)
    , Line := ""
    , LineNum := 1
    , sOutput := ""
    , CRLF := "`r`n"

    Delay() => (Sleep(P_Slow), RunCMD.Iterations += 1)

    While DllCall("Kernel32\PeekNamedPipe", "ptr", hPipeR, "ptr", 0, "int", 0, "ptr", 0, "ptr", 0, "ptr", 0)
    and RunCMD.PID and Delay()
        While (RunCMD.PID != 0 and FileObj.AtEOF != 1)
            Line := FileObj.ReadLine()
            , sOutput .= P_Func ? P_Func.Call(Line CRLF, LineNum++)
                : Line CRLF

    Local hProcess := NumGet(PROCESS_INFORMATION, 0, "ptr")
    , hThread := NumGet(PROCESS_INFORMATION, A_PtrSize, "ptr")
    , ExitCode := 0

    DllCall("Kernel32\GetExitCodeProcess", "ptr", hProcess, "ptrp", &ExitCode)
    , DllCall("Kernel32\CloseHandle", "ptr", hProcess)
    , DllCall("Kernel32\CloseHandle", "ptr", hThread)
    , DllCall("Kernel32\CloseHandle", "ptr", hPipeR)
    , RunCMD.PID := 0
    , RunCMD.ExitCode := ExitCode

    Return RTrim(sOutput, CRLF)
}