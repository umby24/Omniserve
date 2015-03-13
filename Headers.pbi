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

Declare CheckPlugins()

Declare LoadPlugin(File.s)

Declare UnloadPlugin(File.s)

Declare PluginsMain()

