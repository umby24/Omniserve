; Omniserve Logger
; By umby24
; Purpose: Provide logging to console and file for all plugins.
;###############

Global LogMain.Logger

Procedure LogInit()
    Protected Incriment.l
    
    If FileSize("Log") = -1 ; Creates the Log directory if it doesn't exist.
        CreateDirectory("Log")
    EndIf
    
    Incriment = 0
    
    While 1
        If FileSize("Log\Log" + Str(Incriment) + ".txt") = -1
            LogMain\Filename = "Log" + Str(Incriment) + ".txt"
            Break
        EndIf
        
        Incriment = Incriment + 1
    Wend
    
   ; If SystemSettings\Logging = #True
        LogMain\FileId = OpenFile(#PB_Any, "Log\" + LogMain\Filename)
        
        If LogMain\FileId = 0
            _Log("warning", "Couldn't open log file, continuing without logging.", GetLineFile())
            ;SystemSettings\Logging = #False
        EndIf
  ;  EndIf
    
EndProcedure
        
Procedure LogShutdown()
    If IsFile(LogMain\FileID)
        CloseFile(LogMain\FileID)
    EndIf
EndProcedure

Procedure _Log(Type.s, Message.s, LineFile.s)
    Protected Result
    
    ConsoleColor(15, 0)
    Print(FormatDate("%hh:%ii:%ss", Date()) + "> ")
    
    Select LCase(Type)
        Case "debug"
            ConsoleColor(12, 0)
            Print("[DEBUG] (" + LineFile + ") ")
            ConsoleColor(15, 0)
        Case "info"
            ConsoleColor(14, 0)
            Print("[Info] ")
            ConsoleColor(15, 0)
        Case "warning"
            ConsoleColor(12, 0)
            Print("[Warning]  (" + LineFile + ") ")
            ConsoleColor(15, 0)
        Case "error"
            ConsoleColor(4, 0)
            Print("[ERROR]  (" + LineFile + ") ")
            ConsoleColor(15, 0)
        Case "critical"
            ConsoleColor(4, 0)
            Print("[CRITICAL](" + LineFile + ") ")
            ConsoleColor(15, 0)
        Case "chat"
            ConsoleColor(10, 0)
            Print("[Chat] ")
            ConsoleColor(15, 0)
        Case "command"
            ConsoleColor(5, 0)
            Print("[Command] ")
            ConsoleColor(15, 0)
        Default
            ConsoleColor(13, 0)
    EndSelect
    
    PrintN(Message)
    ConsoleColor(15, 0)
    
  ;  If SystemSettings\Logging = #True
        If IsFile(LogMain\FileID)
            Result = WriteStringN(LogMain\FileID, "[" + UCase(Type) + "] " + LineFile + "| " + Message)
            
            If Result = #False
               ; SystemSettings\Logging = #False
                CloseFile(LogMain\FileID)
                _Log("warning", "Error writing to log file, turning off logging.", GetLineFile())
            EndIf
        EndIf
   ; EndIf
    
EndProcedure

AddTask("Log", @LogInit(), #Null, @LogShutdown(), 1000)
; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 98
; FirstLine = 56
; Folding = -
; EnableThread
; EnableXP