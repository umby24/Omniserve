#PLUGIN_VERSION = 0001

XIncludeFile "../Includes/Structures.pbi"

;{ Plugin Function Structure
Structure PluginFunction ; - Callable server functions
    *_Log
    *AddSettings
    *ReadSetting
    *SaveSetting
    *AddTask
    *DeleteTask
EndStructure
;}

;{ Function prototypes
Prototype _Log(Type.s, Message.s, LineFile.s)
Prototype AddSettings(Filename.s, *ReloadFunc)
Prototype.s ReadSetting(Filename.s, key.s)
Prototype SaveSetting(Filename.s, key.s, value.s)
Prototype AddTask(Name.s, *InitFunction, *MainFunction, *ShutdownFunction, Interval.l)
Prototype DeleteTask(Name.s)
;}

Macro GetLineFile()
    Str(#PB_Compiler_Line) + "," + #PB_Compiler_Procedure
EndMacro

Procedure DefinePrototypes(*Pointer.PluginFunction) ; Assigns function pointers from the server core.
    Global _Log._Log = *Pointer\_Log
    Global AddSettings.AddSettings = *Pointer\AddSettings
    Global ReadSetting.ReadSetting = *Pointer\ReadSetting
    Global SaveSetting.SaveSetting = *Pointer\SaveSetting
    Global AddTask.AddTask = *Pointer\AddTask
    Global DeleteTask.DeleteTask = *Pointer\DeleteTask
EndProcedure

; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 27
; Folding = 0
; EnableXP