; Restart MIDI Mixer.exe

TrayIcon_Button("MIDI Mixer.exe", "R")  ; right click tray button
Sleep 100 ; wait for menu
Send {Up} ; press up on keyboard to select "Exit"
Sleep 50 ; wait for menu
Send {Up} ; press up on keyboard to select "Restart"
Sleep 50 ; wait for menu
Send {Enter}  ; press enter on the "Restart" item


; ----------------------------------------------------------------------------------------------------------------------
; Name ..........: TrayIcon library
; Description ...: Provide some useful functions to deal with Tray icons.
; AHK Version ...: AHK_L 1.1.22.02 x32/64 Unicode
; Code from .....: Sean (http://www.autohotkey.com/forum/viewtopic.php?t=17314)
; Author ........: Cyruz (http://ciroprincipe.info) (http://ahkscript.org/boards/viewtopic.php?f=6&t=1229)
; Mod from ......: Fanatic Guru - Cyruz
; License .......: WTFPL - http://www.wtfpl.net/txt/copying/
; Version Date ..: 2019.03.12
; Upd.20160120 ..: Fanatic Guru - Went through all the data types in the DLL and NumGet and matched them up to MSDN
; ...............:                which fixed idCmd.
; Upd.20160308 ..: Fanatic Guru - Fix for Windows 10 NotifyIconOverflowWindow.
; Upd.20180313 ..: Fanatic Guru - Fix problem with "VirtualFreeEx" pointed out by nnnik.
; Upd.20180313 ..: Fanatic Guru - Additional fix for previous Windows 10 NotifyIconOverflowWindow fix breaking non
; ...............:                hidden icons.
; Upd.20190312 ..: Cyruz        - Added TrayIcon_Set, code merged and refactored.
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function ......: TrayIcon_GetInfo
; Description ...: Get a series of useful information about tray icons.
; Parameters ....: sExeName  - The exe for which we are searching the tray icon data. Leave it empty to receive data for 
; ...............:             all tray icons.
; Return ........: oTrayInfo - An array of objects containing tray icons data. Any entry is structured like this:
; ...............:             oTrayInfo[A_Index].idx     - 0 based tray icon index.
; ...............:             oTrayInfo[A_Index].idcmd   - Command identifier associated with the button.
; ...............:             oTrayInfo[A_Index].pid     - Process ID.
; ...............:             oTrayInfo[A_Index].uid     - Application defined identifier for the icon.
; ...............:             oTrayInfo[A_Index].msgid   - Application defined callback message.
; ...............:             oTrayInfo[A_Index].hicon   - Handle to the tray icon.
; ...............:             oTrayInfo[A_Index].hwnd    - Window handle.
; ...............:             oTrayInfo[A_Index].class   - Window class.
; ...............:             oTrayInfo[A_Index].process - Process executable.
; ...............:             oTrayInfo[A_Index].tray    - Tray Type (Shell_TrayWnd or NotifyIconOverflowWindow).
; ...............:             oTrayInfo[A_Index].tooltip - Tray icon tooltip.
; Info ..........: TB_BUTTONCOUNT message - http://goo.gl/DVxpsg
; ...............: TB_GETBUTTON message   - http://goo.gl/2oiOsl
; ...............: TBBUTTON structure     - http://goo.gl/EIE21Z
; ----------------------------------------------------------------------------------------------------------------------

TrayIcon_GetInfo(sExeName := "")
{
    d := A_DetectHiddenWindows
    DetectHiddenWindows, On

    oTrayInfo := []
    For key,sTray in ["Shell_TrayWnd", "NotifyIconOverflowWindow"]
    {
        idxTB := TrayIcon_GetTrayBar(sTray)
        WinGet, pidTaskbar, PID, ahk_class %sTray%
        
        hProc := DllCall("OpenProcess",    UInt,0x38, Int,0, UInt,pidTaskbar)
        pRB   := DllCall("VirtualAllocEx", Ptr,hProc, Ptr,0, UPtr,20, UInt,0x1000, UInt,0x04)

        szBtn := VarSetCapacity(btn, (A_Is64bitOS ? 32 : 20), 0)
        szNfo := VarSetCapacity(nfo, (A_Is64bitOS ? 32 : 24), 0)
        szTip := VarSetCapacity(tip, 128 * 2, 0)

        ; TB_BUTTONCOUNT = 0x0418
        SendMessage, 0x0418, 0, 0, ToolbarWindow32%idxTB%, ahk_class %sTray%
        Loop, %ErrorLevel%
        {
             ; TB_GETBUTTON 0x0417
            SendMessage, 0x0417, A_Index-1, pRB, ToolbarWindow32%idxTB%, ahk_class %sTray%

            DllCall("ReadProcessMemory", Ptr,hProc, Ptr,pRB, Ptr,&btn, UPtr,szBtn, UPtr,0)

            iBitmap := NumGet(btn, 0, "Int")
            idCmd   := NumGet(btn, 4, "Int")
            fsState := NumGet(btn, 8, "UChar")
            fsStyle := NumGet(btn, 9, "UChar")
            dwData  := NumGet(btn, (A_Is64bitOS ? 16 : 12), "UPtr")
            iString := NumGet(btn, (A_Is64bitOS ? 24 : 16), "Ptr")

            DllCall("ReadProcessMemory", Ptr,hProc, Ptr,dwData, Ptr,&nfo, UPtr,szNfo, UPtr,0)

            hWnd  := NumGet(nfo, 0, "Ptr")
            uId   := NumGet(nfo, (A_Is64bitOS ?  8 :  4), "UInt")
            msgId := NumGet(nfo, (A_Is64bitOS ? 12 :  8), "UPtr")
            hIcon := NumGet(nfo, (A_Is64bitOS ? 24 : 20), "Ptr")

            WinGet, nPid, PID, ahk_id %hWnd%
            WinGet, sProcess, ProcessName, ahk_id %hWnd%
            WinGetClass, sClass, ahk_id %hWnd%

            If ( !sExeName || sExeName == sProcess || sExeName == nPid )
            {
                DllCall("ReadProcessMemory", Ptr,hProc, Ptr,iString, Ptr,&tip, UPtr,szTip, UPtr,0)
                oTrayInfo.Push({ "idx"     : A_Index-1
                               , "idcmd"   : idCmd
                               , "pid"     : nPid
                               , "uid"     : uId
                               , "msgid"   : msgId
                               , "hicon"   : hIcon
                               , "hwnd"    : hWnd
                               , "class"   : sClass
                               , "process" : sProcess
                               , "tooltip" : StrGet(&tip, "UTF-16")
                               , "tray"    : sTray })
            }
        }
        DllCall("VirtualFreeEx", Ptr,hProc, Ptr,pRB, UPtr,0, UInt,0x8000)
        DllCall("CloseHandle",   Ptr,hProc)
    }
    DetectHiddenWindows, %d%
    Return oTrayInfo
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_GetTrayBar
; Description ..: Get the tray icon handle.
; Parameters ...: sTray - Traybar to retrieve.
; Return .......: Tray icon handle.
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_GetTrayBar(sTray:="Shell_TrayWnd")
{
    d := A_DetectHiddenWindows
    DetectHiddenWindows, On
    WinGet, ControlList, ControlList, ahk_class %sTray%
    RegExMatch(ControlList, "(?<=ToolbarWindow32)\d+(?!.*ToolbarWindow32)", nTB)
    Loop, %nTB%
    {
        ControlGet, hWnd, hWnd,, ToolbarWindow32%A_Index%, ahk_class %sTray%
        hParent := DllCall( "GetParent", Ptr, hWnd )
        WinGetClass, sClass, ahk_id %hParent%
        If !(sClass == "SysPager" || sClass == "NotifyIconOverflowWindow" )
            Continue
        idxTB := A_Index
        Break
    }
    DetectHiddenWindows, %d%
    Return idxTB
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_GetHotItem
; Description ..: Get the index of tray's hot item.
; Return .......: Index of tray's hot item.
; Info .........: TB_GETHOTITEM message - http://goo.gl/g70qO2
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_GetHotItem()
{
    idxTB := TrayIcon_GetTrayBar()
    SendMessage, 0x0447, 0, 0, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd ; TB_GETHOTITEM = 0x0447
    Return ErrorLevel << 32 >> 32
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TrayIcon_Button
; Description ..: Simulate mouse button click on a tray icon.
; Parameters ...: sExeName - Executable Process Name of tray icon.
; ..............: sButton  - Mouse button to simulate (L, M, R).
; ..............: bDouble  - True to double click, false to single click.
; ..............: nIdx     - Index of tray icon to click if more than one match.
; ----------------------------------------------------------------------------------------------------------------------
TrayIcon_Button(sExeName, sButton:="L", bDouble:=False, nIdx:=1)
{
    d := A_DetectHiddenWindows
    DetectHiddenWindows, On
    WM_MOUSEMOVE      = 0x0200
    WM_LBUTTONDOWN    = 0x0201
    WM_LBUTTONUP      = 0x0202
    WM_LBUTTONDBLCLK  = 0x0203
    WM_RBUTTONDOWN    = 0x0204
    WM_RBUTTONUP      = 0x0205
    WM_RBUTTONDBLCLK  = 0x0206
    WM_MBUTTONDOWN    = 0x0207
    WM_MBUTTONUP      = 0x0208
    WM_MBUTTONDBLCLK  = 0x0209
    sButton := "WM_" sButton "BUTTON"
    oIcons  := TrayIcon_GetInfo(sExeName)
    If ( bDouble )
        PostMessage, oIcons[nIdx].msgid, oIcons[nIdx].uid, %sButton%DBLCLK,, % "ahk_id " oIcons[nIdx].hwnd
    Else
    {
        PostMessage, oIcons[nIdx].msgid, oIcons[nIdx].uid, %sButton%DOWN,, % "ahk_id " oIcons[nIdx].hwnd
        PostMessage, oIcons[nIdx].msgid, oIcons[nIdx].uid, %sButton%UP,, % "ahk_id " oIcons[nIdx].hwnd
    }
    DetectHiddenWindows, %d%
    Return
}