#SingleInstance force
#NoEnv

SendMode Input

;encoder 5
;-
F22 & F21::
    appVolume("Brave.exe", -5)
return
;+
F23 & F21::
    appVolume("Brave.exe", +5)
return
;click
F21 & F20::
    appVolume("Brave.exe", -100)
return

;encoder 4
;-
F24 & F21::
    appVolume2("Spotify.exe", -5)
return
;+
F21::
    appVolume2("Spotify.exe", +5)
return
;click
F22 & F20::
    appVolume2("Spotify.exe", -100)
return

;encoder 3
;-
F23 & F22::
    appVolume3("Discord.exe", -5)
return
;+
F24 & F22::
    appVolume3("Discord.exe", +5)
return
;click
F23 & F20::
    appVolume2("Spotify.exe", -100)
return

;encoder 2
;-
F22::
    WinGet, ActivePID, PID, A 
    SetAppVolume(ActivePID, GetAppVolume(ActivePID) - 5)
return
;+
F24 & F23::
    WinGet, ActivePID, PID, A 
    SetAppVolume(ActivePID, GetAppVolume(ActivePID) + 5)
return
;click
F24 & F20::
    MsgBox 2
return

;encoder 1
;click
F20::
    MsgBox 1
return

;SW (1;1)
F19::Media_Prev
;MsgBox SW (1 1)
return

;SW (1;2)
F24 & F19::Media_Play_Pause
    ;MsgBox SW (1 2)
return

;SW (1;3)
F23 & F19::Media_Next
    ;MsgBox SW (1 3)
return

;SW (1;4)
F22 & F19::
    MsgBox SW (1 4)
return

;SW (2;1)
F21 & F19::
    MsgBox SW (2 1)
return

;SW (2;2)
F20 & F19::
    MsgBox SW (2 2)
return

;SW (2;3)
F18::
    MsgBox SW (2 3)
return

;SW (2;4)
F24 & F18::
    MsgBox SW (2 4)
return

;Ctrl & Numpad 4: Previous Track
^Numpad4::Media_Prev

;Ctrl & Numpad 6: Next Track

^Numpad6::Media_Next

;Ctrl & Numpad 5: Play/Pause Track
^Numpad5::Media_Play_Pause

;open volume mixer
#v::
    Run C:\Windows\System32\SndVol.exe
    WinWait, ahk_exe SndVol.exe
    If WinExist("ahk_exe SndVol.exe") 
        WinActivate, ahk_exe SndVol.exe
    WinMove, ahk_exe SndVol.exe,, 2080, 1060 
Return

appVolume(app, volume)
{
    static lastPid := 0
    Process, Exist, % lastPid
    if (ErrorLevel)
    {
        SetAppVolume(lastPid, GetAppVolume(lastPid) + volume)
        return
    }
    for proc in ComObjGet("winmgmts:")
        .ExecQuery("SELECT ProcessId FROM Win32_Process WHERE Name = """ app """")
    {
        if (-1 != currVol := GetAppVolume(proc.ProcessId))
        {
            SetAppVolume(proc.ProcessId, currVol + volume)
            lastPid := proc.ProcessId
            return
        }
    }
}

appVolume2(app, volume)
{
    static lastPid := 0
    Process, Exist, % lastPid
    if (ErrorLevel)
    {
        SetAppVolume(lastPid, GetAppVolume(lastPid) + volume)
        return
    }
    for proc in ComObjGet("winmgmts:")
        .ExecQuery("SELECT ProcessId FROM Win32_Process WHERE Name = """ app """")
    {
        if (-1 != currVol := GetAppVolume(proc.ProcessId))
        {
            SetAppVolume(proc.ProcessId, currVol + volume)
            lastPid := proc.ProcessId
            return
        }
    }
}

appVolume3(app, volume)
{
    static lastPid := 0
    Process, Exist, % lastPid
    if (ErrorLevel)
    {
        SetAppVolume(lastPid, GetAppVolume(lastPid) + volume)
        return
    }
    for proc in ComObjGet("winmgmts:")
        .ExecQuery("SELECT ProcessId FROM Win32_Process WHERE Name = """ app """")
    {
        if (-1 != currVol := GetAppVolume(proc.ProcessId))
        {
            SetAppVolume(proc.ProcessId, currVol + volume)
            lastPid := proc.ProcessId
            return
        }
    }
}

appVolumeAlt(app, volume)
{
    static lastPid := 0
    if (WinExist("ahk_pid " lastPid))
    {
        SetAppVolume(lastPid, GetAppVolume(lastPid) + volume)
        return
    }
    for proc in ComObjGet("winmgmts:")
        .ExecQuery("SELECT ProcessId FROM Win32_Process WHERE Name = """ app """")
    {
        if (-1 != currVol := GetAppVolume(proc.ProcessId))
        {
            SetAppVolume(proc.ProcessId, currVol + volume)
            lastPid := proc.ProcessId
        }
    }
}
GetAppVolume(PID)
{
    MasterVolume := IMMDevice := IAudioSessionManager2 := IAudioSessionEnumerator := SessionCount := IAudioSessionControl := ProcessId := ""

    IMMDeviceEnumerator := ComObjCreate("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
    DllCall(NumGet(NumGet(IMMDeviceEnumerator+0)+4*A_PtrSize), "UPtr", IMMDeviceEnumerator, "UInt", 0, "UInt", 1, "UPtrP", IMMDevice, "UInt")
    ObjRelease(IMMDeviceEnumerator)

    VarSetCapacity(GUID, 16)
    DllCall("Ole32.dll\CLSIDFromString", "Str", "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}", "UPtr", &GUID)
    DllCall(NumGet(NumGet(IMMDevice+0)+3*A_PtrSize), "UPtr", IMMDevice, "UPtr", &GUID, "UInt", 23, "UPtr", 0, "UPtrP", IAudioSessionManager2, "UInt")
    ObjRelease(IMMDevice)

    DllCall(NumGet(NumGet(IAudioSessionManager2+0)+5*A_PtrSize), "UPtr", IAudioSessionManager2, "UPtrP", IAudioSessionEnumerator, "UInt")
    ObjRelease(IAudioSessionManager2)

    DllCall(NumGet(NumGet(IAudioSessionEnumerator+0)+3*A_PtrSize), "UPtr", IAudioSessionEnumerator, "UIntP", SessionCount, "UInt")
    loop, % SessionCount
    {
        DllCall(NumGet(NumGet(IAudioSessionEnumerator+0)+4*A_PtrSize), "UPtr", IAudioSessionEnumerator, "Int", A_Index-1, "UPtrP", IAudioSessionControl, "UInt")
        IAudioSessionControl2 := ComObjQuery(IAudioSessionControl, "{BFB7FF88-7239-4FC9-8FA2-07C950BE9C6D}")
        ObjRelease(IAudioSessionControl)

        DllCall(NumGet(NumGet(IAudioSessionControl2+0)+14*A_PtrSize), "UPtr", IAudioSessionControl2, "UIntP", ProcessId, "UInt")
        if (PID = ProcessId)
        {
            ISimpleAudioVolume := ComObjQuery(IAudioSessionControl2, "{87CE5498-68D6-44E5-9215-6DA47EF883D8}")
            DllCall(NumGet(NumGet(ISimpleAudioVolume+0)+4*A_PtrSize), "UPtr", ISimpleAudioVolume, "FloatP", MasterVolume, "UInt")
            ObjRelease(ISimpleAudioVolume)
        }
        ObjRelease(IAudioSessionControl2)
    }
    ObjRelease(IAudioSessionEnumerator)

    if MasterVolume is Float
    {
        return Round(MasterVolume * 100)
    }
return -1
}

SetAppVolume(PID, MasterVolume)
{
    MasterVolume := MasterVolume > 100 ? 100 : MasterVolume < 0 ? 0 : MasterVolume

    IMMDevice := IAudioSessionManager2 := IAudioSessionEnumerator := SessionCount := IAudioSessionControl := ProcessId := ""

    IMMDeviceEnumerator := ComObjCreate("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
    DllCall(NumGet(NumGet(IMMDeviceEnumerator+0)+4*A_PtrSize), "UPtr", IMMDeviceEnumerator, "UInt", 0, "UInt", 1, "UPtrP", IMMDevice, "UInt")
    ObjRelease(IMMDeviceEnumerator)

    VarSetCapacity(GUID, 16)
    DllCall("Ole32.dll\CLSIDFromString", "Str", "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}", "UPtr", &GUID)
    DllCall(NumGet(NumGet(IMMDevice+0)+3*A_PtrSize), "UPtr", IMMDevice, "UPtr", &GUID, "UInt", 23, "UPtr", 0, "UPtrP", IAudioSessionManager2, "UInt")
    ObjRelease(IMMDevice)

    DllCall(NumGet(NumGet(IAudioSessionManager2+0)+5*A_PtrSize), "UPtr", IAudioSessionManager2, "UPtrP", IAudioSessionEnumerator, "UInt")
    ObjRelease(IAudioSessionManager2)

    DllCall(NumGet(NumGet(IAudioSessionEnumerator+0)+3*A_PtrSize), "UPtr", IAudioSessionEnumerator, "UIntP", SessionCount, "UInt")
    loop, % SessionCount
    {
        DllCall(NumGet(NumGet(IAudioSessionEnumerator+0)+4*A_PtrSize), "UPtr", IAudioSessionEnumerator, "Int", A_Index-1, "UPtrP", IAudioSessionControl, "UInt")
        IAudioSessionControl2 := ComObjQuery(IAudioSessionControl, "{BFB7FF88-7239-4FC9-8FA2-07C950BE9C6D}")
        ObjRelease(IAudioSessionControl)

        DllCall(NumGet(NumGet(IAudioSessionControl2+0)+14*A_PtrSize), "UPtr", IAudioSessionControl2, "UIntP", ProcessId, "UInt")
        if (PID = ProcessId)
        {
            ISimpleAudioVolume := ComObjQuery(IAudioSessionControl2, "{87CE5498-68D6-44E5-9215-6DA47EF883D8}")
            DllCall(NumGet(NumGet(ISimpleAudioVolume+0)+3*A_PtrSize), "UPtr", ISimpleAudioVolume, "Float", MasterVolume/100.0, "UPtr", 0, "UInt")
            ObjRelease(ISimpleAudioVolume)
        }
        ObjRelease(IAudioSessionControl2)
    }
    ObjRelease(IAudioSessionEnumerator)
}