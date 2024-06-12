#Requires AutoHotkey v2.0

StdoutToVar(sCmd, sDir:="", sEnc:="CP0") {
    ; Create 2 buffer-like objects to wrap the handles to take advantage of the __Delete meta-function.
    oHndStdoutRd := { Ptr: 0, __Delete: delete(this) => DllCall("CloseHandle", "Ptr", this) }
    oHndStdoutWr := { Base: oHndStdoutRd }
    
    If !DllCall( "CreatePipe"
               , "PtrP" , oHndStdoutRd
               , "PtrP" , oHndStdoutWr
               , "Ptr"  , 0
               , "UInt" , 0 )
        Throw OSError(,, "Error creating pipe.")
    If !DllCall( "SetHandleInformation"
               , "Ptr"  , oHndStdoutWr
               , "UInt" , 1
               , "UInt" , 1 )
        Throw OSError(,, "Error setting handle information.")

    PI := Buffer(A_PtrSize == 4 ? 16 : 24,  0)
    SI := Buffer(A_PtrSize == 4 ? 68 : 104, 0)
    NumPut( "UInt", SI.Size,          SI,  0 )
    NumPut( "UInt", 0x100,            SI, A_PtrSize == 4 ? 44 : 60 )
    NumPut( "Ptr",  oHndStdoutWr.Ptr, SI, A_PtrSize == 4 ? 60 : 88 )
    NumPut( "Ptr",  oHndStdoutWr.Ptr, SI, A_PtrSize == 4 ? 64 : 96 )

    If !DllCall( "CreateProcess"
               , "Ptr"  , 0
               , "Str"  , sCmd
               , "Ptr"  , 0
               , "Ptr"  , 0
               , "Int"  , True
               , "UInt" , 0x08000000
               , "Ptr"  , 0
               , "Ptr"  , sDir ? StrPtr(sDir) : 0
               , "Ptr"  , SI
               , "Ptr"  , PI )
        Throw OSError(,, "Error creating process.")

    ; The write pipe must be closed before reading the stdout so we release the object.
    ; The reading pipe will be released automatically on function return.
    oHndStdOutWr := ""

    ; Before reading, we check if the pipe has been written to, so we avoid freezings.
    nAvail := 0, nLen := 0
    While DllCall( "PeekNamedPipe"
                 , "Ptr"   , oHndStdoutRd
                 , "Ptr"   , 0
                 , "UInt"  , 0
                 , "Ptr"   , 0
                 , "UIntP" , &nAvail
                 , "Ptr"   , 0 ) != 0
    {
        ; If the pipe buffer is empty, sleep and continue checking.
        If !nAvail && Sleep(100)
            Continue
        cBuf := Buffer(nAvail+1)
        DllCall( "ReadFile"
               , "Ptr"  , oHndStdoutRd
               , "Ptr"  , cBuf
               , "UInt" , nAvail
               , "PtrP" , &nLen
               , "Ptr"  , 0 )
        sOutput .= StrGet(cBuf, nLen, sEnc)
    }
    
    ; Get the exit code, close all process handles and return the output object.
    DllCall( "GetExitCodeProcess"
           , "Ptr"   , NumGet(PI, 0, "Ptr")
           , "UIntP" , &nExitCode:=0 )
    DllCall( "CloseHandle", "Ptr", NumGet(PI, 0, "Ptr") )
    DllCall( "CloseHandle", "Ptr", NumGet(PI, A_PtrSize, "Ptr") )
    Return { Output: sOutput, ExitCode: nExitCode } 
}