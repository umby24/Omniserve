; Universal Plugin based Network Application -- Omniserve
; By Umby24
; Purpose: Provide a plugin based application for universally serving  various types of content
; This file: Main file, starts the omni server.
; #################################
EnableExplicit

; - TODO: Move to event based client architecture, like server networking.
; - TODO: Provide basic compression algorithim support, such as zlib, zip, and lzma.
; - TODO: Test server networking, and provide examples.

#VERSION = 0001

; - Macros
Macro GetLineFile() ; - Macro for logging.
    Str(#PB_Compiler_Line) + "," + #PB_Compiler_Procedure
EndMacro

OpenConsole()
ConsoleTitle("Omniserve")
EnableGraphicalConsole(#False)

XIncludeFile "Includes/Structures.pbi"
XIncludeFile "Headers.pbi"

Global OmniSettings.CoreSettings

; - Core System Files

XIncludeFile "Core/TaskScheduler.pbi"
XIncludeFile "Core/Settings.pbi"

XIncludeFile "Core/Logger.pbi"
XIncludeFile "Network/ClientNetwork.pbi"
XIncludeFile "Network/ServerNetwork.pbi"
XIncludeFile "Core/Plugins.pbi"
XIncludeFile "Core/Console.pbi"
;{
Procedure LoadCoreSettings()
    If LCase(AllSettings()\Entries("Logging")) = "true"
        OmniSettings\Logging = #True
    ElseIf LCase(AllSettings()\Entries("Logging")) = "false"
        OmniSettings\Logging = #False
    EndIf
EndProcedure
;}

_Log("info", "Starting Omniserve...", GetLineFile())
OmniSettings\Running = #True

RunInitTasks()
_Log("info", "Started", GetLineFile())

While OmniSettings\Running
    RunMainTasks()
    Delay(1)
Wend

OmniSettings\Running = #False

_Log("info", "Shutting Down...", GetLineFile())
_Log("info", "Complete.", GetLineFile())

Input()
CloseConsole()
; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 10
; Folding = 0
; EnableThread
; EnableXP