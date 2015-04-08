; Basic IRC Bot Example
; In PB, Using Omniserve.
; By Umby24
;########################

XIncludeFile "Include.pbi"

Global *MyBot.NetworkClient

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
    
    ProcedureReturn Left(ircString, Len(ircString) - 2)
EndProcedure

Procedure DoIrc()
    If *MyBot\Connected = #False
        DeleteTask("IRC Client")
        ProcedureReturn
    EndIf
    
    raw.s = GetIrcString()
    host.s = ""
    dat.s = ""
    message.s = ""
    
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
        ProcedureReturn
    EndIf
    
    second.s = Left(dat, FindString(dat, " ", 1) - 1)
    name.s = Left(host, FindString(host, "!", 1) - 1)
    
    Dim splits.s(0)
    split(splits(), dat, " ")
    
    Select second
        Case "PRIVMSG"
            _log("chat", "<" + name + "> &f" + message, GetLineFile())
            ProcedureReturn
        Case "NOTICE"
            ProcedureReturn
        Case "QUIT"
            ProcedureReturn
        Case "JOIN"
            ProcedureReturn
        Case "MODE" ;AuthServ
            ProcedureReturn
        Case "PART"
            ProcedureReturn
        Case "NICK"
            ProcedureReturn
        Case "307" ;AuthServ
            ProcedureReturn
        Case "330"; Authserv
            ProcedureReturn
        Case "332"
            ProcedureReturn
        Case "353" ;Players list
            ProcedureReturn
        Case "376"
            send_raw("JOIN #Test", *MyBot\ID)
            _Log("info", "[IRC] Connected to IRC Channel.", GetLineFile())
            ProcedureReturn
        Case "451"
            send_raw("NICK PureBot", *MyBot\ID)
            send_raw("USER Pure Pure Pure :PureIRC", *MyBot\ID)
            send_raw("MODE PureBot +B-x", *MyBot\ID)
            _log("info", "sent register", GetLineFile())
            ProcedureReturn
    EndSelect
    
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
    
    AddTask("IRC Client", #Null, @DoIrc(), #Null, 50)
EndProcedure
; IDE Options = PureBasic 5.30 (Windows - x64)
; ExecutableFormat = Shared Dll
; CursorPosition = 103
; FirstLine = 67
; Folding = 2-
; EnableThread
; EnableXP
; Executable = ..\Plugins\IRC.dll
; Compiler = PureBasic 5.30 (Windows - x64)