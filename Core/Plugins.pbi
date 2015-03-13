; Omniserve Plugins
; By umby24
; Purpose: Load and  Unload Extensions to the server.
;################
;TODO - Mutex this..

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    #Extension = ".dll"
CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
    #Extension = ".a"
CompilerEndIf

Global NewMap PluginDirectory.Plugin()

Procedure CheckPlugins()
    Protected Result, Entry.s
    
    If FileSize("Plugins") = -1
        CreateDirectory("Plugins")
    EndIf
    
    ; - Delete files from the list that have been deleted.
    ForEach PluginDirectory()
        If FileSize("Plugins/" + MapKey(PluginDirectory())) > -1
            Continue
        EndIf
        
        DeleteMapElement(PluginDirectory())
    Next
    
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
            Continue
        EndIf
        
        IsGood = LoadPlugin(Entry) ; - Find out if it's a valid plugin or not.
        PluginDirectory()\Valid= IsGood
        PluginDirectory()\Loaded = IsGood
        PluginDirectory()\Path = "Plugins/" + Entry
    Wend
    
    FinishDirectory(Result)
EndProcedure

Procedure LoadPlugin(File.s)
    If Not PluginDirectory(File)\LibId
        PluginDirectory()\LibId = OpenLibrary(#PB_Any, "Plugins/" + File)
        
        If Not PluginDirectory()\LibId
            _Log("warning", "Could not open library " + file, GetLineFile())
            ProcedureReturn #False
        EndIf
        
    EndIf
    
    CallCFunction(PluginDirectory()\LibId, "PluginInit", @PluginDirectory()\Info, @_Log())

    If Not PluginDirectory()\Info\ServeVersion = #VERSION
        CloseLibrary(PluginDirectory()\LibId)
        ProcedureReturn #False
    EndIf

    _Log("info", "Plugin Loaded: " + file, GetLineFile())
    ProcedureReturn #True
EndProcedure

Procedure UnloadPlugin(File.s)
    If IsLibrary(PluginDirectory(File)\LibId) = #False Or PluginDirectory(FIle)\Loaded = #False
        ProcedureReturn #True
    EndIf
    
    If PluginDirectory()\Valid
        CallCFunction(PluginDirectory()\LibId, "PluginShutdown")
    EndIf
    
    CloseLibrary(PluginDirectory()\LibId)
    PluginDirectory()\Loaded = #False
    
    _Log("info", "Plugin unloaded: " + file, GetLineFile())
    ProcedureReturn #True
EndProcedure

Procedure PluginsMain()
    CheckPlugins()
EndProcedure

AddTask("Plugin Check", #Null, @PluginsMain(), #Null, 1000) ; - Register with the task scheduler to check for new plugins every second.
; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 5
; Folding = -
; EnableThread
; EnableXP