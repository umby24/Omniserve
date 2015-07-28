; Omniserve Server Test
; by Umby24
; Purpose: Test network server functions of Omniserve
;############################

XIncludeFile "Include.pbi" ; - Include omniserve library

Procedure ClientConnect(Client.l)
    _log("info", "[Plugin] Client connected.", GetLineFile())
    _log("info", "[Plugin] IP: " + GetClientIP(Client) + " Port: " + Str(GetClientPort(Client)), GetLineFile())
EndProcedure

Procedure ClientData(Client.l)
    _log("info", "[Plugin] Client sent data", GetLineFile())
EndProcedure

Procedure ClientDisconnect(Client.l)
    _log("info", "[Plugin] Client disconnected.", GetLineFile())
    _log("info", "[Plugin] IP: " + GetClientIP(Client) + " Port: " + Str(GetClientPort(Client)), GetLineFile())
EndProcedure

Procedure CreateServer()
    If Not AddServer("TestServer", 9999, @ClientConnect(), @ClientData(), @ClientDisconnect())
        _log("error", "[Plugin] Could not create server.", GetLineFile())
        ProcedureReturn
    EndIf
    
    If Not StartServer("TestServer")
        _log("error", "[Plugin] Could not start server.", GetLineFile())
        ProcedureReturn
    EndIf
    
    _log("info", "[Plugin] Server created, listening on port 9999.", GetLineFile())
EndProcedure

Procedure EndDerp()
    If Not EndServer("TestServer")
        _log("error", "[Plugin] Could not stop server.", GetLineFile())
        ProcedureReturn
    EndIf
    
    If Not RemoveServer("TestServer")
        _log("error", "[Plugin] Could not remove server.", GetLineFile())
        ProcedureReturn
    EndIf
    
    _log("error", "[Plugin] Server removed.", GetLineFile())
EndProcedure

ProcedureCDLL PluginInit(*Info.PluginInfo, *Pointer.PluginFunction)
    DefinePrototypes(*Pointer) ; Define the server functions so we can access them.
    
    *Info\ServeVersion = #PLUGIN_VERSION
    *Info\Name = "Test Server"
    *Info\Author = "Umby24"
    *Info\Description = "Basic Server Networking test"
    *Info\Version = 1
    
    _log("info", "Test Server initiating...", GetLineFile())
    CreateServer()
EndProcedure

ProcedureCDLL PluginShutdown()
    EndDerp()
EndProcedure
; IDE Options = PureBasic 5.30 (Windows - x64)
; ExecutableFormat = Shared Dll
; CursorPosition = 36
; FirstLine = 11
; Folding = --
; EnableThread
; EnableXP
; Executable = server.x64.dll