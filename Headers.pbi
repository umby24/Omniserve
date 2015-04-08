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

Declare split(Array a$(1), s$, delimeter$)

Declare MainConsole(Nothing)

Declare ConsoleInit()

Declare HandleConsole(Input.s)

Declare HandleSwitch(Input.s)

Declare HandleExit(Input.s)

Declare LogInit()

Declare LogShutdown()

Declare _Log(Type.s, Message.s, LineFile.s)

Declare CreateClient(IP.s, Port.w)

Declare CloseClient(*MyClient.NetworkClient)

Declare ReadClientData(*MyClient.NetworkClient, Size.l)

Declare ClientEvents()

Declare AssignPlugPointer()

Declare CheckPlugins()

Declare LoadPlugin(File.s)

Declare UnloadPlugin(File.s)

Declare PluginsMain()

