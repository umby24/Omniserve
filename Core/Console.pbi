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
    
    If FindMapElement(ConsoleHandlers(), LCase(splits(0))) = #False
        _Log("error", "Could not find a console for  " + splits(0) + ".", GetLineFile())
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
        ProcedureReturn
    EndIf
    
    CurrentHandler = ""
    _log("info", "Console switched back to default.", GetLineFile())
EndProcedure

AddTask("Console Handler", @ConsoleInit(), #Null, #Null, 50000)

; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 87
; FirstLine = 34
; Folding = +-
; EnableThread
; EnableXP