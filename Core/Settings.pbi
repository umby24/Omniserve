; Omniserve Settings
; By umby24
; Purpose: Provide an extensible interface for loading and saving settings
;################

Global NewMap AllSettings.Settings()
Global SettingsMutex
Prototype.i ReloadFunc()

Procedure AddSettings(Filename.s, *ReloadFunc)
    If FileSize("Settings") = -1
        CreateDirectory("Settings")
    EndIf
    
    LockMutex(SettingsMutex) ; - MUTEX LOCK
    
    AddMapElement(AllSettings(), Filename)
    AllSettings()\Filename = Filename
    AllSettings()\ReloadFunc = *ReloadFunc
    
    LoadSettings(Filename)
    AllSettings()\LastLoaded = GetFileDate("Settings/" + MapKey(AllSettings()), #PB_Date_Modified) 
    
    UnlockMutex(SettingsMutex) ; - MUTEX UNLOCK
EndProcedure

Procedure LoadSettings(Filename.s)
    If FileSize(Filename) = -1
        ProcedureReturn
    EndIf
    
    If Not OpenPreferences("Settings/" + Filename)
        ProcedureReturn
    EndIf
    
    ClearMap(AllSettings()\Entries())
    
    While ExaminePreferenceKeys()
        AddMapElement(AllSettings()\Entries(), PreferenceKeyName())
        AllSettings()\Entries() = PreferenceKeyValue()
    Wend
    
    ClosePreferences()
    
    If AllSettings()\ReloadFunc ; - Give the requesting plugin its chance at the locked object, to read its settings.
        Define reload.ReloadFunc
        reload()
    EndIf
    
EndProcedure

Procedure SaveSettings(Filename.s)
    If Not CreatePreferences(Filename)
        ProcedureReturn
    EndIf
    
    ForEach AllSettings()\Entries()
        WritePreferenceString(MapKey(AllSettings()\Entries()), AllSettings()\Entries())
    Next
    
    ClosePreferences()
EndProcedure

Procedure.s ReadSetting(Filename.s, key.s)
    LockMutex(SettingsMutex); - MUTEX LOCK
    
    If Not FindMapElement(AllSettings(), Filename)
        UnlockMutex(SettingsMutex) ; - MUTEX UNLOCK
        ProcedureReturn
    EndIf
    
    Define Result.s = AllSettings(Filename)\Entries(key)
    UnlockMutex(SettingsMutex) ; - MUTEX UNLOCK
    ProcedureReturn Result
EndProcedure

Procedure SaveSetting(Filename.s, key.s, value.s)
    LockMutex(SettingsMutex) ; - MUTEX LOCK
    
    If Not FindMapElement(AllSettings(), Filename)
        UnlockMutex(SettingsMutex) ; - MUTEX UNLOCK
        ProcedureReturn
    EndIf
    
    AllSettings(Filename)\Entries(key) = value
    UnlockMutex(SettingsMutex) ; - MUTEX UNLOCK
    
EndProcedure

Procedure SettingsMain()
    LockMutex(SettingsMutex) ; - MUTEX LOCK
    
    ForEach AllSettings()
        If GetFileDate("Settings/" + AllSettings()\Filename, #PB_Date_Modified) = AllSettings()\LastLoaded
            Continue
        EndIf
        
        LoadSettings(AllSettings()\Filename)
        AllSettings()\LastLoaded = GetFileDate("Settings/" + AllSettings()\Filename, #PB_Date_Modified)
    Next
    
    UnlockMutex(SettingsMutex) ; - MUTEX UNLOCK
EndProcedure

Procedure SettingsShutdown()
    LockMutex(SettingsMutex) ; - MUTEX LOCK
    
    ForEach AllSettings()
        SaveSettings(AllSettings()\Filename)
    Next
    
    UnlockMutex(SettingsMutex) ; - MUTEX UNLOCK
EndProcedure

SettingsMutex = CreateMutex()
AddTask("Settings", #Null, @SettingsMain(), #Null, 2000)
; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 44
; FirstLine = 3
; Folding = D+
; EnableThread
; EnableXP