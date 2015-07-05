; Basic IRC Bot Example
; In PB, Using Omniserve.
; By Umby24
;########################

XIncludeFile "Include.pbi"

Global *MyBot.NetworkClient

Global myThread.l

Declare DoIrcPreview()

Declare.s GetIrcString()

Procedure split(Array a$(1), s$, delimeter$)
  Protected count, i
  count = CountString(s$,delimeter$) + 1
 
  Dim a$(count)
  
  For i = 1 To count
    a$(i - 1) = StringField(s$,i,delimeter$)
Next

  ProcedureReturn count ;return count of substrings
EndProcedure

Procedure send_raw(string$, Socket)
    If Socket
        *myMem = AllocateMemory(Len(string$) + 2)
        PokeS(*myMem, string$, Len(string$))
        PokeA(*myMem + Len(string$), 13)
        PokeA(*myMem+ Len(string$) + 1, 10)
        
        WriteClientData(*MyBot, *myMem, Len(string$) + 2)
        PurgeClientData(*MyBot)
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
    
    ;FreeMemory(*MyBot\ReceiveBuffer)
    ;*MyBot\ReceiveOffset = 0
    ;*MyBot\ReceiveBuffer = 0
    
    ProcedureReturn Left(ircString, Len(ircString) - 2)
EndProcedure

Procedure DoIrc(NotUsed)
    _log("debug", "Thread created...", "a")
    
    While *MyBot\Connected = #True
        
        raw.s = GetIrcString()
        host.s = ""
        dat.s = ""
        message.s = ""
        second.s = ""
        
        If Left(raw, 1) = ":"
            host = Mid(raw, 2, FindString(raw, " ", 1) - 2)
        Else
            host = Left(raw, FindString(raw, " ", 1) - 1)
        EndIf
        
        dat = Mid(raw, FindString(raw, " ", 1) + 1, Len(raw) - (FindString(raw, " ", 1)))
        
        If FindString(dat, ":", 1) <> 0
            message = Mid(dat, FindString(dat, ":", 1) + 1, Len(dat) - (FindString(dat, ":", 1)))
        EndIf
        
        If host = "PING"
            send_raw("PONG " + dat, *MyBot\ID)
            Continue
        EndIf
        
        second.s = Left(dat, FindString(dat, " ", 1) - 1)
        name.s = Left(host, FindString(host, "!", 1) - 1)
        
        Dim splits.s(0)
        split(splits(), dat, " ")
        
        Select second
            Case "PRIVMSG"
                _log("chat", "[IRC] <" + name + "> " + message, GetLineFile())
                Continue
            Case "NOTICE"
                Continue
            Case "QUIT"
                Continue
            Case "JOIN"
                Continue
            Case "MODE" ;AuthServ
                Continue
            Case "PART"
                Continue
            Case "NICK"
                Continue
            Case "307" ;AuthServ
                Continue
            Case "330"; Authserv
                Continue
            Case "332"
                Continue
            Case "353" ;Players list
                Continue
            Case "376"
                send_raw("JOIN #Test", *MyBot\ID)
                _Log("info", "[IRC] Connected to IRC Channel.", GetLineFile())
                Continue
            Case "451"
                send_raw("NICK PureBot", *MyBot\ID)
                send_raw("USER Pure Pure Pure :PureIRC", *MyBot\ID)
                send_raw("MODE PureBot +B-x", *MyBot\ID)
                Continue
        EndSelect
        
        _Log("chat", "[IRC] " + raw, GetLineFile())
    Wend
EndProcedure

ProcedureCDLL PluginInit(*Info.PluginInfo, *Pointer.PluginFunction)
    DefinePrototypes(*Pointer) ; Define the server functions so we can access them.
    
    _Log("info", "Plugin INIT!", GetLineFile())
    
    *Info\ServeVersion = #PLUGIN_VERSION
    *Info\Name = "Basic IRC"
    *Info\Author = "Umby24"
    *Info\Description = "Basic IRC Bot in PB"
    *Info\Version = 1
    
    _log("info", "Loaded.", GetLineFile())
    IRCInit()
    
    myThread = CreateThread(@DoIrc(), 0)
    
    ;AddTask("IRC Client", #Null, @DoIrc(), #Null, 0)
EndProcedure

ProcedureCDLL PluginShutdown()
    If *MyBot\Connected = #False
        ProcedureReturn
    EndIf
    
    If IsThread(myThread)
        _log("info", "IRC Bot Thread killed.", GetLineFile())
        KillThread(myThread)
    EndIf
    
    CloseClient(*MyBot)
    
    _log("info", "IRC Bot killed.", GetLineFile())
EndProcedure

; IDE Options = PureBasic 5.00 (Windows - x64)
; ExecutableFormat = Shared Dll
; CursorPosition = 116
; FirstLine = 107
; Folding = --
; EnableThread
; EnableXP
; Executable = ..\IRC.x64.dll
; Compiler = PureBasic 5.00 (Windows - x64)