; Omniserve Plugins
; By umby24
; Purpose: Load and  Unload Extensions to the server.
;################

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
EndStructure

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
        #Extension = ".x86.dll"
    CompilerElse
        #Extension = ".x64.dll"
    CompilerEndIf
CompilerElse
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
        #Extension = ".x86.a"
    CompilerElse
        #Extension = ".x64.a"
    CompilerEndIf
CompilerEndIf

Global NewMap PluginDirectory.Plugin()
Global PlugPointer.PluginFunction
Global PlugMutex

Procedure AssignPlugPointer()
    PlugMutex = CreateMutex()
    PlugPointer\_Log = @_Log()
    PlugPointer\AddSettings = @AddSettings()
    PlugPointer\AddTask = @AddTask()
    PlugPointer\DeleteTask = @DeleteTask()
    PlugPointer\ReadSetting = @ReadSetting()
    PlugPointer\SaveSetting = @SaveSetting()
    PlugPointer\ReadClientData = @ReadClientData()
    PlugPointer\CreateClient = @CreateClient()
    PlugPointer\CloseClient = @CloseClient()
EndProcedure

Procedure CheckPlugins()
    Protected Result, Entry.s
    
    If FileSize("Plugins") = -1
        CreateDirectory("Plugins")
    EndIf
    
    LockMutex(PlugMutex) ; - MUTEX LOCK
    ; - Delete files from the list that have been deleted.
    ForEach PluginDirectory()
        If FileSize("Plugins/" + MapKey(PluginDirectory())) > -1
            Continue
        EndIf
        
        DeleteMapElement(PluginDirectory())
    Next
    UnlockMutex(PlugMutex) ; - MUTEX UNLOCK
    
    ; - Search the Plugin Directory for files.
    Result = ExamineDirectory(#PB_Any, "Plugins", "*" + #Extension)
    
    If Not Result
        ProcedureReturn
    EndIf
    
    While NextDirectoryEntry(Result)
        If DirectoryEntryType(Result) = #PB_DirectoryEntry_Directory ; - If it's a directory, ignore it.
            Continue
        EndIf
        
        Entry = DirectoryEntryName(Result) ; - Get the name of the file.
        
        LockMutex(PlugMutex) ; - MUTEX LOCK
        
        If FindMapElement(PluginDirectory(), Entry) ; - Make sure we don't already track it.
            Continue
        EndIf
        
        AddMapElement(PluginDirectory(), Entry) ; - Add it to our tracker

        Define IsGood.b
        PluginDirectory()\LibId = OpenLibrary(#PB_Any, "Plugins/" + Entry)
        
        If Not PluginDirectory()\LibId
            _Log("warning", "Could not open library " + Entry, GetLineFile())
            PluginDirectory()\Loaded = #False
            PluginDirectory()\Valid = #False
            PluginDirectory()\Path = "Plugins/" + Entry
            UnlockMutex(PlugMutex) ; - MUTEX UNLOCK
            Continue
        EndIf
        
        UnlockMutex(PlugMutex) ; - MUTEX UNLOCK
        IsGood = LoadPlugin(Entry) ; - Find out if it's a valid plugin or not.
        LockMutex(PlugMutex) ; - MUTEX LOCK
        PluginDirectory()\Valid= IsGood
        PluginDirectory()\Loaded = IsGood
        PluginDirectory()\Path = "Plugins/" + Entry
        
        UnlockMutex(PlugMutex) ; - MUTEX UNLOCK
    Wend
    
    FinishDirectory(Result)
EndProcedure

Procedure LoadPlugin(File.s)
    LockMutex(PlugMutex) ; - MUTEX LOCK
    
    If Not PluginDirectory(File)\LibId
        PluginDirectory()\LibId = OpenLibrary(#PB_Any, "Plugins/" + File)
        
        If Not PluginDirectory()\LibId
            _Log("warning", "Could not open library " + file, GetLineFile())
            UnlockMutex(PlugMutex) ; - MUTEX UNLOCK
            ProcedureReturn #False
        EndIf
        
    EndIf
    
    CallCFunction(PluginDirectory()\LibId, "PluginInit", @PluginDirectory()\Info, @PlugPointer)

    If Not PluginDirectory()\Info\ServeVersion = #VERSION
        _Log("warning", "Could not open library " + file + " Invalid Version. " + Str(PluginDirectory()\Info\ServeVersion), GetLineFile())
        CloseLibrary(PluginDirectory()\LibId)
        UnlockMutex(PlugMutex) ; - MUTEX UNLOCK
        ProcedureReturn #False
    EndIf
    ;TODO - Load plugin event methods
    
    _Log("info", "Plugin Loaded: " + PluginDirectory()\Info\Name + " (By " + PluginDirectory()\Info\Author + ", Version: " + Str(PluginDirectory()\Info\Version) + ")", GetLineFile())
    
    UnlockMutex(PlugMutex) ; - MUTEX UNLOCK
    ProcedureReturn #True
EndProcedure

Procedure UnloadPlugin(File.s)
    LockMutex(PlugMutex) ; - MUTEX LOCK
    
    If IsLibrary(PluginDirectory(File)\LibId) = #False Or PluginDirectory(FIle)\Loaded = #False
        UnlockMutex(PlugMutex) ; - MUTEX UNLOCK
        ProcedureReturn #True
    EndIf
    
    If PluginDirectory()\Valid
        CallCFunction(PluginDirectory()\LibId, "PluginShutdown")
    EndIf
    
    CloseLibrary(PluginDirectory()\LibId)
    PluginDirectory()\Loaded = #False
    
    _Log("info", "Plugin unloaded: " + file, GetLineFile())
    
    UnlockMutex(PlugMutex) ; - MUTEX UNLOCK
    ProcedureReturn #True
EndProcedure

Procedure PluginsMain()
    CheckPlugins()
EndProcedure

AddTask("Plugin Check", @AssignPlugPointer(), @PluginsMain(), #Null, 1000) ; - Register with the task scheduler to check for new plugins every second.
; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 137
; FirstLine = 127
; Folding = --
; EnableThread
; EnableXP