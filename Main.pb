; Universal Plugin based Network Application -- Omniserve
; By Umby24
; Purpose: Provide a plugin based application for universally serving  various types of content
; This file: Main file, starts the omni server.
; #################################
EnableExplicit

#VERSION = 0001

; - Macros
Macro GetLineFile()
    Str(#PB_Compiler_Line) + #PB_Compiler_Procedure
EndMacro

;{
Global OmniSettings.CoreSettings

Procedure LoadCoreSettings()
    
EndProcedure
;}

OpenConsole("Omniserve")
EnableGraphicalConsole(#True)

XIncludeFile "Includes/Structures.pbi"
XIncludeFile "Headers.pbi"
; - Core System Files

XIncludeFile "Core/TaskScheduler.pbi"
XIncludeFile "Core/Settings.pbi"
XIncludeFile "Core/Logger.pbi"
XIncludeFile "Core/Plugins.pbi"



_Log("info", "Starting Omniserve...", GetLineFile())
RunInitTasks()
_Log("info", "Started", GetLineFile())

Define i.l

For i = 0 To 100
    RunMainTasks()
    Delay(10)
Next

_Log("info", "Shutting Down...", GetLineFile())
RunShutdownTasks()
_Log("info", "Complete.", GetLineFile())
Input()
CloseConsole()
; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 18
; Folding = -
; EnableThread
; EnableXP