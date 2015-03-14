#include "include.h"

extern "C" DLL_EXPORT void PluginInit(PluginInfo *Info, PluginFunction *Functions)
{
    Info->ServeVersion = 0001;
    Info->Name = "Test (C++)";
    Info->Author = "Umby24";
    Info->Description = "Example Plugin (In C++) :)";
    Info->Version = 1;

    Functions->_Log("info", "Hello from C++ Plugin!", "");
}
