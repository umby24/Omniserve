Global NewMap ConsoleHandlers.i()
Global NewMap OmniserveCommands.i()
Global CurrentHandler.s = ""
Global ConsoleThread.i

Prototype ConsoleHandler(Input.s)

Procedure split(Array a$(1), s$, delimeter$)
  Protected count, i
  count = CountString(s$,delimeter$) + 1
 
  Dim a$(count)
  
  For i = 1 To count
    a$(i - 1) = StringField(s$,i,delimeter$)
Next

  ProcedureReturn count ;return count of substrings
EndProcedure

Procedure MainConsole(Nothing)
    Protected Inputline.s
    
    While OmniSettings\Running
        Inputline = Input()
        
        Define myHand.ConsoleHandler = ConsoleHandlers(CurrentHandler)
        myHand(Inputline)
    Wend
EndProcedure

Procedure ConsoleInit()
    AddMapElement(OmniserveCommands(), "plugins")
    OmniserveCommands() = @HandlePlugins()
    
    AddMapElement(OmniserveCommands(), "unload")
    OmniserveCommands() = @HandlePluginUnload()
    
    AddMapElement(OmniserveCommands(), "load")
    OmniserveCommands() = @HandlePluginLoad()
    
    AddMapElement(OmniserveCommands(), "switch")
    OmniserveCommands() = @HandleSwitch()
    
    AddMapElement(OmniserveCommands(), "exit")
    OmniserveCommands() = @HandleExit()
    
    AddMapElement(ConsoleHandlers(), "")
    ConsoleHandlers() = @HandleConsole()
    
    ConsoleThread = CreateThread(@MainConsole(),  0)
EndProcedure

Procedure HandleConsole(Input.s)
    Dim splits.s(0)
    split(splits(), Input, " ")
    
    If FindMapElement(OmniserveCommands(), LCase(splits(0))) = #False
        _Log("error", "Could not find command " + splits(0) + ".", GetLineFile())
        ProcedureReturn
    EndIf
    
    Define myHandler.ConsoleHandler = OmniserveCommands(LCase(splits(0)))
    myHandler(Input)
EndProcedure

Procedure HandleSwitch(Input.s)
    Dim splits.s(0)
    split(splits(), Input, " ")
    
    If ArraySize(splits()) <> 2
        _Log("error", "Incorrect number of arguments. Usage: switch [newconsole]", GetLineFile())
        ProcedureReturn
    EndIf
    
    If FindMapElement(ConsoleHandlers(), LCase(splits(1))) = #False
        _Log("error", "Could not find a console for  " + splits(1) + ".", GetLineFile())
        ProcedureReturn
    EndIf
    
    CurrentHandler = LCase(splits(1))
    _log("info", "Console switched to " + splits(1), GetLineFile())
EndProcedure

Procedure HandleExit(Input.s)
    If CurrentHandler = ""
        OmniSettings\Running = #False
        _log("info", "Shutting down server.", GetLineFile())
        
        KillThread(ConsoleThread)
        RunShutdownTasks()
        ProcedureReturn
    EndIf
    
    CurrentHandler = ""
    _log("info", "Console switched back to default.", GetLineFile())
EndProcedure

Procedure HandlePlugins(Input.s)
    Define plugins.s = ""
    
    ForEach PluginDirectory()
        If PluginDirectory()\Loaded
            plugins + PluginDirectory()\Info\Name + "(" + MapKey(PluginDirectory()) + "), "
        EndIf
    Next
    
    _log("info", "Loaded plugins: " + Left(plugins, Len(plugins) - 2), GetLineFile())
EndProcedure

Procedure HandlePluginUnload(Input.s)
    Define message.s = ""
    message = Mid(Input, FindString(Input, " ") + 1, Len(Input) - (FindString(Input, " ") + 1))
    
    Dim splits.s(0)
    split(splits(), Input, " ")
    
    If ArraySize(splits()) <> 2
        _Log("error", "Incorrect number of arguments. Usage: unload [plugin]", GetLineFile())
        ProcedureReturn
    EndIf
    
    If Not FindMapElement(PluginDirectory(), splits(1))
        _log("error", "Could not find a plugin by that name.", GetLineFile())
        ProcedureReturn
    EndIf
    
    UnloadPlugin(splits(1))
    _log("info", "Plugin unloaded.", GetLineFile())
EndProcedure

Procedure HandlePluginLoad(Input.s)
    Define message.s = ""
    message = Mid(Input, FindString(Input, " ") + 1, Len(Input) - (FindString(Input, " ") + 1))
    
    Dim splits.s(0)
    split(splits(), Input, " ")
    
    If ArraySize(splits()) <> 2
        _Log("error", "Incorrect number of arguments. Usage: load [plugin]", GetLineFile())
        ProcedureReturn
    EndIf
    
    If Not FindMapElement(PluginDirectory(), splits(1))
        _log("error", "Could not find a plugin by that name.", GetLineFile())
        ProcedureReturn
    EndIf
    
    LoadPlugin(splits(1))
EndProcedure

AddTask("Console Handler", @ConsoleInit(), #Null, #Null, 50000)

; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 39
; FirstLine = 12
; Folding = +-
; EnableThread
; EnableXP