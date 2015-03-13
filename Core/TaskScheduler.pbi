; Omniserve Task Scheduler
; By umby24
; Purpose: Provide time based calls of functions, and call functions on server start and shutdown.
;#####################

Global NewMap OmniTasks.Task()
Prototype.i Task_Function()

Procedure AddTask(Name.s, *InitFunction, *MainFunction, *ShutdownFunction, Interval.l)
    AddMapElement(OmniTasks(), Name, #PB_Map_ElementCheck)
    
    OmniTasks()\ID = Name
    OmniTasks()\InitFunction = *InitFunction
    OmniTasks()\MainFunction = *MainFunction
    OmniTasks()\ShutdownFunction = *ShutdownFunction
    OmniTasks()\Interval = Interval
    OmniTasks()\Timer = 0
    
EndProcedure

Procedure DeleteTask(Name.s)
    DeleteMapElement(OmniTasks(), Name)
EndProcedure

Procedure RunInitTasks()
    Protected myFun.Task_Function
    
    ForEach OmniTasks()
        If Not OmniTasks()\InitFunction
            Continue
        EndIf
        
        myfun = OmniTasks()\InitFunction
        myfun()
    Next
    
    ;Init Tasks Completed.
EndProcedure

Procedure RunMainTasks()
    Protected myfun.Task_Function
    
    ForEach OmniTasks()
        If (ElapsedMilliseconds() - OmniTasks()\Timer) >= OmniTasks()\Interval
            OmniTasks()\Timer = ElapsedMilliseconds()
            
            If Not OmniTasks()\MainFunction
               Continue
           EndIf
           
             myfun = OmniTasks()\MainFunction
             myfun()
        EndIf
    Next
    
    ;Complete.
EndProcedure

Procedure RunShutdownTasks()
    Protected myFun.Task_Function
    
    ForEach OmniTasks()
        If Not OmniTasks()\ShutdownFunction
            Continue
        EndIf
        
        myfun = OmniTasks()\ShutdownFunction
        myfun()
    Next
    
    ;Shutdown tasks complete.
EndProcedure


; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 44
; FirstLine = 31
; Folding = -
; EnableThread
; EnableXP