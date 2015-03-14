XIncludeFile "Include.pbi"

ProcedureCDLL PluginInit(*Info.PluginInfo, *Pointer.PluginFunction)
    DefinePrototypes(*Pointer) ; Define the server functions so we can access them.

    _Log("info","I'm a plugin spinning up!", GetLineFile())
    
    *Info\ServeVersion = #PLUGIN_VERSION
    *Info\Name = "Example"
    *Info\Author = "Umby24"
    *Info\Description = "Just in example :) - In PB"
    *Info\Version = 1
     
    _Log("critical", "Yay, I'm alive!", GetLineFile())
EndProcedure

; IDE Options = PureBasic 5.30 (Windows - x64)
; ExecutableFormat = Shared Dll
; Folding = -
; EnableThread
; EnableXP
; Executable = ..\Plugins\Example.dll
; Compiler = PureBasic 5.30 (Windows - x86)