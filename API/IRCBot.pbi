; Basic IRC Bot Example
; In PB, Using Omniserve.
; By Umby24
;########################

XIncludeFile "Include.pbi"

Global *MyBot.NetworkClient

Declare DoIrcPreview()

Declare.s GetIrcString()

Procedure send_raw(string$, Socket)
    If Socket
        SendNetworkString(Socket, string$ + Chr(13) + Chr(10))
    EndIf
EndProcedure

Procedure IRCInit()
    *MyBot = CreateClient("irc.esper.net", 6667)
    
    If (*MyBot = 0)
        _Log("error", "Could not create IRC connection.", GetLineFile())
        ProcedureReturn
    EndIf
    
    send_raw("NICK PureBot", *MyBot\ID)
    send_raw("USER Pure Pure Pure :PureIRC", *MyBot\ID)
    send_raw("MODE PureBot +B-x", *MyBot\ID)
EndProcedure

Procedure.s GetIrcString()
    Define ircString.s = ""
    Define ircLast.s = ""
    Define Readbytes = 0
    Define character.s = ""
    
    While ircLast <> (Chr(13) + Chr(10))
        Readbytes = ReadClientData(*MyBot, 1)
        
        If ReadBytes = #False
            ircString = "Quittinggg"
            Break
        EndIf
        

        Define mychar.s = PeekS(*MyBot\ReceiveBuffer + (*MyBot\ReceiveOffset - 1), 1)

        ircLast = Right(ircLast, 1) + mychar
        ircString = ircString + mychar
    Wend
    
    ;FreeMemory(*MyBot\ReceiveBuffer) ;Free up the memory used in the IRC Process.
    ;*MyBot\ReceiveOffset = 0
    
    ProcedureReturn Left(ircString, Len(ircString) - 2)
EndProcedure

Procedure DoIrc()
    If *MyBot\Connected = #False
        DeleteTask("IRC Client")
        ProcedureReturn
    EndIf
    
    _Log("chat", "[IRC] " + GetIrcString(), GetLineFile())
EndProcedure

ProcedureCDLL PluginInit(*Info.PluginInfo, *Pointer.PluginFunction)
    DefinePrototypes(*Pointer) ; Define the server functions so we can access them.
    
    _Log("info", "Plugin INIT!", GetLineFile())
    
    *Info\ServeVersion = #PLUGIN_VERSION
    *Info\Name = "Basic IRC"
    *Info\Author = "Umby24"
    *Info\Description = "Basic IRC Bot in PB"
    *Info\Version = 1
    
    IRCInit()
    
    AddTask("IRC Client", #Null, @DoIrc(), #Null, 300)
EndProcedure
; IDE Options = PureBasic 5.30 (Windows - x64)
; ExecutableFormat = Shared Dll
; CursorPosition = 54
; FirstLine = 12
; Folding = -
; EnableThread
; EnableXP
; Executable = ..\Plugins\IRC.dll
; Compiler = PureBasic 5.30 (Windows - x64)