#PLUGIN_VERSION = 0002

XIncludeFile "../../Includes/Structures.pbi"

;{ Plugin Function Structure
Structure PluginFunction ; - Callable server functions
    *_Log
    *AddSettings
    *ReadSetting
    *SaveSetting
    *AddTask
    *DeleteTask
    *CreateClient
    *CloseClient
    *ReadClientData
    *WriteClientData
    *PurgeClientData
    ; - Server functions
    *AddServer
    *RemoveServer
    *StartServer
    *EndServer
EndStructure
;}

;{ Function prototypes
Prototype _Log(Type.s, Message.s, LineFile.s)
Prototype AddSettings(Filename.s, *ReloadFunc)
Prototype.s ReadSetting(Filename.s, key.s)
Prototype SaveSetting(Filename.s, key.s, value.s)
Prototype AddTask(Name.s, *InitFunction, *MainFunction, *ShutdownFunction, Interval.l)
Prototype DeleteTask(Name.s)
; - Client Network
Prototype CreateClient(IP.s, Port.w)
Prototype CloseClient(*MyClient.NetworkClient)
Prototype ReadClientData(*MyClient.NetworkClient, Size.l)
Prototype WriteClientData(*MyClient.NetworkClient, *Data, Size.l)
Prototype PurgeClientData(*MyClient.NetworkClient)
; - Server Network
Prototype AddServer(Name.s, Port.l, *Connect, *Data, *Disconnect, Mode=#PB_Network_TCP)
Prototype RemoveServer(Server.s)
Prototype StartServer(Server.s)
Prototype EndServer(Server.s)
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
    
    ; - Client Network
    Global CreateClient.CreateClient = *Pointer\CreateClient
    Global CloseClient.CloseClient = *Pointer\CloseClient
    Global ReadClientData.ReadClientData = *Pointer\ReadClientData
    Global WriteClientData.WriteClientData = *Pointer\WriteClientData
    Global PurgeClientData.PurgeClientData = *Pointer\PurgeClientData
    
    ; - Server Network
    Global AddServer.AddServer = *Pointer\AddServer
    Global RemoveServer.RemoveServer = *Pointer\RemoveServer
    Global StartServer.StartServer = *Pointer\StartServer
    Global EndServer.EndServer = *Pointer\EndServer
EndProcedure

; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 16
; Folding = -
; EnableXP