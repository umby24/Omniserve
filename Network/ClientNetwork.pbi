; Omniserve Client Networking
; by Umby24
; Purpose: Provide interfaces to create network client plugins for Omniserve.
;############################

InitNetwork()

Global NewMap NetClients.NetworkClient()
Global NetClientLock = CreateMutex()

Procedure CreateClient(IP.s, Port.w)
    Define myClient = OpenNetworkConnection(IP, Port, #PB_Network_TCP, 5000)
    
    If myClient = 0
        ProcedureReturn #False
    EndIf
    
    LockMutex(NetClientLock) ; - LOCK MUTEX
    
    AddMapElement(NetClients(), Str(myClient))
    
    NetClients()\ID = myClient
    NetClients()\ReceiveOffset = 0
    NetClients()\SendOffset = 0
    NetClients()\Connected = #True
    
    Define Pointer = @NetClients(Str(myClient))
    
    UnlockMutex(NetClientLock) ; - UNLOCK MUTEX
    
    ProcedureReturn Pointer
EndProcedure

Procedure CloseClient(*MyClient.NetworkClient)
    If *MyClient\Connected = #True
        CloseNetworkConnection(*MyClient\ID)
    EndIf
    
    *MyClient\Connected = #False
    
    If *MyClient\ReceiveBuffer
        FreeMemory(*MyClient\ReceiveBuffer)
    EndIf
    
    If *MyClient\SendBuffer
        FreeMemory(*MyClient\SendBuffer)
    EndIf
    
    *MyClient\ReceiveOffset = 0
    *MyClient\SendOffset = 0
    
    ProcedureReturn #True
EndProcedure

Procedure ReadClientData(*MyClient.NetworkClient, Size.l)
    Define Result.l, MemResult.l, *TempMem
    Result = 0
    
    If *MyClient\ReceiveBuffer <> 0
        *TempMem = AllocateMemory(MemorySize(*MyClient\ReceiveBuffer)) ; - Copy any existing data in the receive buffer..
        CopyMemory(*MyClient\ReceiveBuffer, *TempMem, MemorySize(*TempMem))
        *MyClient\ReceiveBuffer = ReAllocateMemory(*MyClient\ReceiveBuffer, MemorySize(*TempMem) + Size) ; - Possible size mismatch could cause a crash in here..
        
        CopyMemory(*TempMem, *MyClient\ReceiveBuffer, MemorySize(*TempMem))       ; - Will leave it up to plugin devs unless it becomes an issue.
        
        *MyClient\ReceiveOffset = MemorySize(*TempMem)
        FreeMemory(*TempMem)
    Else
        *MyClient\ReceiveBuffer = AllocateMemory(Size)
        *MyClient\ReceiveOffset = 0
        _log("debug", "Memsize" + MemorySize(*MyClient\ReceiveBuffer), GetLineFile())
    EndIf

    While Result <> Size
        If NetworkClientEvent(*MyClient\ID) = #PB_NetworkEvent_None
            Delay(1)
            Continue
        EndIf
        
        Size - Result
        Result = ReceiveNetworkData(*MyClient\ID, *MyClient\ReceiveBuffer + *MyClient\ReceiveOffset, Size)
        
        If Result = -1
            *MyClient\Connected = #False
            FreeMemory(*MyClient)
            FreeMemory(*MyClient)
            *MyClient\ReceiveOffset = 0
            *MyClient\SendOffset = 0
            ProcedureReturn #False
        EndIf
        
        *MyClient\ReceiveOffset + Result
        Delay(1) ; - Just in case we wait a while, let other threads run and not lock the cpu at 100% usage.
    Wend
    ProcedureReturn #True
EndProcedure

Procedure ClientEvents()
    LockMutex(NetClientLock)
    Define Result
    
    ForEach NetClients()
        Result = NetworkClientEvent(NetClients()\ID)
        
        If Result = #PB_NetworkEvent_Disconnect
            CloseClient(@NetClients())
        EndIf
    Next
    
    UnlockMutex(NetClientLock)
EndProcedure

AddTask("NetClientEvents", #Null, @ClientEvents(), #Null, 2000) ; Every 2 seconds, check for disconnects.
; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 88
; FirstLine = 33
; Folding = 0
; EnableXP