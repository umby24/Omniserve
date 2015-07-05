Structure Task
    ID.s
    *InitFunction
    *MainFunction
    *ShutdownFunction
    Interval.l
    Timer.l
EndStructure

Structure PluginInfo
    Name.s
    Author.s
    Description.s
    Version.l
    ServeVersion.l
EndStructure

Structure Plugin
    Valid.b
    Loaded.b
    LibId.i
    Path.s
    Info.PluginInfo
EndStructure

Structure Logger
    FileId.l
    Filename.s
EndStructure

Structure Settings
    Filename.s
    LastLoaded.l
    *ReloadFunc
    Map Entries.s()
EndStructure

Structure CoreSettings
    Logging.a
    Running.a
EndStructure

Structure NetworkClient
    ID.i
    *SendBuffer
    *ReceiveBuffer
    BufferSize.i
    ReceiveOffset.i
    Connected.a
EndStructure

Structure NetworkServer
    ID.i
    *SendBuffer
    *ReceiveBuffer
    ReceiveOffset.i
EndStructure

; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 46
; FirstLine = 8
; EnableThread
; EnableXP