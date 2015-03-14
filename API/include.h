#ifdef BUILD_DLL
    #define DLL_EXPORT __declspec(dllexport)
#else
    #define DLL_EXPORT __declspec(dllimport)
#endif

struct PluginFunction {
    void (*_Log)(char type[], char message[], char lineFile[]);
    void (*AddSettings)(char[], int);
    char* (*ReadSetting)(char[], char[]);
    void (*SaveSetting)(char[], char[], char[]);
    void (*AddTask)(char[], int, int, int, int);
    void (*DeleteTask)(char[]);
};

struct PluginInfo {
    char *Name;
    char *Author;
    char *Description;
    int Version;
    int ServeVersion;
};
