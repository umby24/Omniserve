XIncludeFile "Structures.pbi"
Prototype _Log(Type.s, Message.s, LineFile.s)

ProcedureCDLL PluginInit(*Info.PluginInfo, *LogFunc)
    Define asdf._Log
    asdf = *LogFunc
    OpenConsole()
    asdf("info","I'm a plugin spinning up!", "asdf")
    *Info\ServeVersion = 0001
    
    asdf("critical", "Yay, I'm alive!","yay")
EndProcedure

ProcedureCDLL PluginShutdown()
    
EndProcedure

; IDE Options = PureBasic 5.30 (Windows - x64)
; ExecutableFormat = Shared Dll
; CursorPosition = 14
; Folding = -
; EnableThread
; EnableXP
; Executable = ..\Plugins\FirstPlugin.dll