; Omniserve Server Networking
; by Umby24
; Purpose: Provide interfaces to create network server plugins for Omniserve.
;############################

InitNetwork() ; - Just in case :)

Global NewMap Servers.NetworkServer()
Global NewMap RunningServers.NetworkServer()
Global RunningLock = CreateMutex()
Global ServerLock = CreateMutex()

Prototype.b ServerEvent(Client.l)

Procedure AddServer(Name.s, Port.l, *Connect, *Data, *Disconnect, Mode=#PB_Network_TCP) ; - Creates a network server
    
    LockMutex(ServerLock)
    AddMapElement(Servers(), Name)
    
    Servers(Name)\ID = 0
    Servers()\Port = Port
    Servers()\Connect = *Connect
    Servers()\Disconnect = *Disconnect
    Servers()\Data = *Data
    Servers()\Mode = Mode
    
    UnlockMutex(ServerLock)
    
    ProcedureReturn #True
EndProcedure

Procedure RemoveServer(Server.s) ; - Deletes a network server    
    LockMutex(ServerLock)
    
    If Not FindMapElement(Servers(), Server)
        UnlockMutex(ServerLock)
        ProcedureReturn #False
    EndIf
    
    If Servers(Server)\ID <> 0 ; - Server is still running, we need to close it.
        UnlockMutex(ServerLock)
        EndServer(Server)
        LockMutex(ServerLock)
    EndIf
    
    DeleteMapElement(Servers(), Server)
    UnlockMutex(ServerLock)
    
    ProcedureReturn #True
EndProcedure

Procedure StartServer(Server.s) ; - Starts the specified network server
    
    LockMutex(ServerLock)
    
    If Not FindMapElement(Servers(), Server)
        UnlockMutex(ServerLock)
        ProcedureReturn #False
    EndIf
    
    If Servers(Server)\ID <> 0 ; - Server is already listening.
        UnlockMutex(ServerLock)
        ProcedureReturn #False
    EndIf
    
    Protected ServerResult.l
    ServerResult = CreateNetworkServer(#PB_Any, Servers()\Port, Servers()\Mode)
    
    If Not ServerResult
        UnlockMutex(ServerLock)
        _log("error", "Failed to create network server on port " + Str(Servers()\Port) + ".", GetLineFile())
        ProcedureReturn #False
    EndIf
    
    Servers()\ID = ServerResult
    Servers()\ClientLock = CreateMutex()

    LockMutex(RunningLock) ; - Add server to list of running servers. Allows fast lookup when events occur.
    AddMapElement(RunningServers(), Str(Servers()\ID))
    RunningServers(Str(Servers()\ID)) = Servers()
    UnlockMutex(RunningLock)
    
    UnlockMutex(ServerLock)
    
    ProcedureReturn #True
EndProcedure

Procedure EndServer(Server.s) ; - Closes the specified network server
    LockMutex(ServerLock)
    
    If Not FindMapElement(Servers(), Server)
        UnlockMutex(ServerLock)
        ProcedureReturn #False
    EndIf
    
    If Servers(Server)\ID = 0
        UnlockMutex(ServerLock)
        ProcedureReturn #False
    EndIf
    
    LockMutex(RunningLock)
    
    If Not FindMapElement(RunningServers(), Str(Servers(Server)\ID))
        UnlockMutex(ServerLock)
        UnlockMutex(RunningLock)
        _log("warning", "Edge case detected: Server in Servers() but not RunningServers()", GetLineFile())
        ProcedureReturn #False
    EndIf
    
    DeleteMapElement(RunningServers(), Str(Servers(Server)\ID))
    UnlockMutex(RunningLock)
    
    ;LockMutex(Servers()\ClientLock)
    
    ForEach Servers(Server)\Clients()
        CloseClient(Servers()\Clients())
    Next
    
    ;UnlockMutex(Servers()\ClientLock)
    
    CloseNetworkServer(Servers(Server)\ID)
    Servers(Server)\ID = 0
    UnlockMutex(ServerLock)
    
    ProcedureReturn #True
EndProcedure

Procedure CallConnectEvent(*Event, Client.l, Server.l) ; - Calls the connect event on the remote plugin.
    Protected Result.b
    
    If *Event = #Null
        ProcedureReturn
    EndIf
    
    If Client = 0
        ProcedureReturn
    EndIf
    
    ; - First, call the event function.
    Define myFun.ServerEvent
    myFun = *Event
    Result = myFun(Client)
    
    ; - If result is false, do not add the client.
    If Result = #False
        ; - Drop Connection..
        CloseNetworkConnection(Client)
        ProcedureReturn
    EndIf
    
    ; - Add the client to the server's tracked clients.
    LockMutex(RunningLock)
    LockMutex(RunningServers(Str(Server))\ClientLock)
    
    AddElement(RunningServers(Str(Server))\Clients())
    RunningServers()\Clients() = AddClient(Client)
    
    UnlockMutex(RunningServers(Str(Server))\ClientLock)
    UnlockMutex(RunningLock)
    
    _log("info", "Client connected: " + GetClientIP(Client) + ".", GetLineFile())
EndProcedure

Procedure CallDataEvent(*Event, Client.l, Server.l)
    If *Event = #Null
        ProcedureReturn
    EndIf
    
    If Client = 0
        ProcedureReturn
    EndIf
    
    ; - First, call the event function.
    Define myFun.ServerEvent
    myFun = *Event
    myFun(Client)
    ; - Thats it for this function.
EndProcedure

Procedure CallDisconnectEvent(*Event, Client.l, Server.l)
    If *Event = #Null
        ProcedureReturn
    EndIf
    
    If Client = 0
        ProcedureReturn
    EndIf
    
    ; - First, call the event function.
    Define myFun.ServerEvent
    myFun = *Event
    myFun(Client)
    
    ; - Remove client from list of tracked clients..
    LockMutex(RunningLock)
    LockMutex(RunningServers(Str(Server))\ClientLock)
    
    Define pointer.i = FindMapElement(NetClients(), Str(Client))
    
    ForEach RunningServers(Str(Server))\Clients()
        If Not RunningServers(Str(Server))\Clients() = pointer
            Continue
        EndIf
        
        DeleteElement(RunningServers(Str(Server))\Clients())
        Break
    Next
    
    CloseClient(pointer)
    
    UnlockMutex(RunningServers(Str(Server))\ClientLock)
    UnlockMutex(RunningLock)
    
    _log("info", "Client disconnected: " + GetClientIP(Client) + ".", GetLineFile())
EndProcedure

Procedure ServerMain() ; - Handles incoming server events and sends them to the correct plugin.
    Protected Result.l, Server.l, Client.l
    
    Result = NetworkServerEvent()
    Server = EventServer()
    Client = EventClient()
    
    Select Result
        Case #PB_NetworkEvent_None
            ProcedureReturn
        Case #PB_NetworkEvent_Connect
            LockMutex(RunningLock)
            Define *Function = RunningServers(Str(Server))\Connect
            UnlockMutex(RunningLock)
            
            CallConnectEvent(*Function, Client, Server)
        Case #PB_NetworkEvent_Data
            LockMutex(RunningLock)
            Define *Function = RunningServers(Str(Server))\Data
            UnlockMutex(RunningLock)
            
            CallDataEvent(*Function, Client, Server)
        Case #PB_NetworkEvent_Disconnect
            LockMutex(RunningLock) ; - Safely get the pointer to the disconnect function.
            Define *Function = RunningServers(Str(Server))\Disconnect
            UnlockMutex(RunningLock)
            
            CallDisconnectEvent(*Function, Client, Server)
    EndSelect
    
EndProcedure

Procedure ServerShutdown() ; - Shuts down all network servers (Omniserve shutting down)
    _log("info", "Shutting down Network Servers...", GetLineFile())
    
    ForEach Servers()
        EndServer(MapKey(Servers()))
    Next
    
    _log("info", "Server shutdown complete.", GetLineFile())
    FreeMap(Servers())
EndProcedure

AddTask("Server Events", #Null, @ServerMain(), @ServerShutdown(), 1) ; - Registers the server event checker.
; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 200
; FirstLine = 195
; Folding = -8
; EnableXP