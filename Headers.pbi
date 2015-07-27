Declare AddTask(Name.s, *InitFunction, *MainFunction, *ShutdownFunction, Interval.l)

Declare DeleteTask(Name.s)

Declare RunInitTasks()

Declare RunMainTasks()

Declare RunShutdownTasks()

Declare AddSettings(Filename.s, *ReloadFunc)

Declare LoadSettings(Filename.s)

Declare SaveSettings(Filename.s)

Declare.s ReadSetting(Filename.s, key.s)

Declare SaveSetting(Filename.s, key.s, value.s)

Declare SettingsMain()

Declare SettingsShutdown()

Declare LogInit()

Declare LogShutdown()

Declare _Log(Type.s, Message.s, LineFile.s)

Declare CreateClient(IP.s, Port.w)

Declare AddClient(ClientId.l)

Declare CloseClient(*MyClient.NetworkClient)

Declare ReadClientData(*MyClient.NetworkClient, Size.l)

Declare WriteClientData(*MyClient.NetworkClient, *Data, Size.l)

Declare PurgeClientData(*MyClient.NetworkClient)

Declare ClientEvents()

Declare AddServer(Name.s, Port.l, *Connect, *Data, *Disconnect, Mode=#PB_Network_TCP) ; - Creates a network server

Declare RemoveServer(Server.s) ; - Deletes a network server    

Declare StartServer(Server.s) ; - Starts the specified network server

Declare EndServer(Server.s) ; - Closes the specified network server

Declare CallConnectEvent(*Event, Client.l, Server.l) ; - Calls the connect event on the remote plugin.

Declare CallDataEvent(*Event, Client.l, Server.l)

Declare CallDisconnectEvent(*Event, Client.l, Server.l)

Declare ServerMain() ; - Handles incoming server events and sends them to the correct plugin.

Declare ServerShutdown() ; - Shuts down all network servers (Omniserve shutting down)

Declare AssignPlugPointer()

Declare CheckPlugins()

Declare LoadPlugin(File.s)

Declare UnloadPlugin(File.s)

Declare PluginsMain()

Declare PluginsShutdown()

Declare split(Array a$(1), s$, delimeter$)

Declare MainConsole(Nothing)

Declare ConsoleInit()

Declare HandleConsole(Input.s)

Declare HandleSwitch(Input.s)

Declare HandleExit(Input.s)

Declare HandlePlugins(Input.s)

Declare HandlePluginUnload(Input.s)

Declare HandlePluginLoad(Input.s)

