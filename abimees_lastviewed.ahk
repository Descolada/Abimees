#NoEnv
#SingleInstance force
#NoTrayIcon
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
CoordMode, Mouse, Client ; koordinaadid relatiivselt akna suhtes
CoordMode, Pixel, Client 
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, 1000
SetTitleMatchMode, 2
DetectHiddenWindows, On

global patientList := []
global maxPatients := 15
IniRead maxPatients, %A_ScriptDir%\abimees_settings.ini, ViewedPatients, maxPatients, 15

UpdatePatientList()

; Tekita shell hook mis kontrollib kas "Haiguslugu" aken on avatud
DllCall( "RegisterShellHookWindow", UInt, A_ScriptHwnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage" )

SetWinDelay, -1

WinGet, PID, PID, % "ahk_id " . owner:=WinExist("Ester II Statsionaar ahk_class ThunderRT6FormDC") 
WinGetPos, x_haigus, y_haigus, w_haigus, h_haigus, Ester II Statsionaar ahk_class ThunderRT6FormDC
window_w := 120
window_h := maxPatients * 14
x_coord := A_ScreenWidth - window_w - 10
y_coord := 0

GUI, Main:New, +ToolWindow +Owner%owner% +Hwndowned

ptArr := ""
for i,e in patientList {
	pt := StrSplit(e, "|")
	ptArr .= pt[1] . "|"
}
ptArr := RTrim(ptArr, "|")

Gui, Main:Add, ListBox, x0 y0 w%window_w% r%maxPatients% gLBLastViewed vLBLastViewed, %ptArr%
GuiControlGet, posLastViewed, Pos, LBLastViewed
GUI, Main:Show, x%x_coord% y%y_coord% w%window_w% h%posLastViewedH%, Vaadatud pt-d

WinActivate, Ester II Statsionaar ahk_class ThunderRT6FormDC

WinWaitClose % "ahk_id " . owner ; ... or until the owner window does not exist

Gui , Main:Destroy
ExitApp

LBLastViewed:
	if (A_GuiEvent = "DoubleClick") {
		global patientList, maxPatients
		if A_EventInfo {
			pt := StrSplit(patientList[A_EventInfo], "|")
			ik := pt[2]
			WinActivate, Ester II Statsionaar ahk_class ThunderRT6FormDC
			WinWaitActive, Ester II Statsionaar ahk_class ThunderRT6FormDC
			Sleep, 40
			SetControlDelay -1 ; muudab ControlClicki usaldusväärsemaks
			ControlClick, ThunderRT6CommandButton10, Ester II Statsionaar ahk_class ThunderRT6FormDC,,,, NA
			WinWaitActive, Patsient ahk_class ThunderRT6FormDC
			Sleep, 40
			ControlGetText, butNo, Button2, Patsient ahk_class ThunderRT6FormDC
			if (butNo == "&No") {
				ControlClick, Button2, Patsient ahk_class ThunderRT6FormDC,,,, NA
				WinWaitActive, Patsient ahk_class ThunderRT6FormDC
				Sleep, 40
			}
			ControlSetText, ThunderRT6TextBox3, %ik%, Patsient ahk_class ThunderRT6FormDC
			Sleep, 200
			ControlClick, ThunderRT6CommandButton3, Patsient ahk_class ThunderRT6FormDC,,,, NA
			Sleep, 200
			ControlClick, ThunderRT6CommandButton3, Patsient ahk_class ThunderRT6FormDC,,,, NA
		}
	}
	return


OnLocationChangeMonitor(_hWinEventHook, _event, _hwnd) { ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd373885(v=vs.85).aspx
	STATIC ox, oy, nx, ny, ownerAhkId, ownedAhkId, hWinEventHook
	IF !_hwnd	; if the system sent the EVENT_OBJECT_LOCATIONCHANGE event for the caret:
		Return	; https://msdn.microsoft.com/en-us/library/windows/desktop/dd318066(v=vs.85).aspx
	IF !hWinEventHook			; register a event hook function for EVENT_OBJECT_LOCATIONCHANGE := "0x800B" 
		hWinEventHook := SetWinEventHook("0x800B", "0x800B",0, RegisterCallback("OnLocationChangeMonitor"),_hwnd,0,0)
		 , ownerAhkId := _hWinEventHook,   ownedAhkId := _event,   OnExit(Func("UnhookWinEvent").Bind(hWinEventHook))
	WinGetPos,  _x,  _y, _w, _h, ahk_id %ownerAhkId%
	WinGetPos, _x1, _y1,,, ahk_id %ownedAhkId%
	WinMove, ahk_id %ownedAhkId%,, % _x+_w, % _y
}



SetWinEventHook(_eventMin, _eventMax, _hmodWinEventProc, _lpfnWinEventProc, _idProcess, _idThread, _dwFlags) {
	DllCall("CoInitialize", "Uint", 0)
	return DllCall("SetWinEventHook","Uint",_eventMin,"Uint",_eventMax,"Ptr",_hmodWinEventProc,"Ptr",_lpfnWinEventProc,"Uint",_idProcess,"Uint",_idThread,"Uint",_dwFlags)
}  ; cf. https://autohotkey.com/boards/viewtopic.php?t=830
UnhookWinEvent(_hWinEventHook) {
	DllCall("UnhookWinEvent", "Ptr", _hWinEventHook)
	DllCall("CoUninitialize")
}  ; cf. https://autohotkey.com/boards/viewtopic.php?t=830

ShellMessage( wParam,lParam )	; Gets all Shell Hook Messages
{
	if (wParam = 1) { ;  HSHELL_WINDOWCREATED := 1 ; Only act on Window Created Messages
		global maxPatients, patientList
		wId:= lParam							; wID is Window Handle
		WinGetTitle, wTitle, ahk_id %wId%		; wTitle is Window Title
		WinGetClass, wClass, ahk_id %wId%		; wClass is Window Class
		WinGet, wExe, ProcessName, ahk_id %wId%	; wExe is Window Execute

		if InStr(wTitle, "Haiguslugu") {
			WinWaitActive, Haiguslugu ahk_class ThunderRT6FormDC
			IniRead, haiguslugu, abimees_settings.ini, Plugins, Haiguslugu, 0
			if (haiguslugu) {
				startTime := A_TickCount
				Loop {
					IniRead, ready, abimees_settings.ini, General, HaigusluguReady
					Sleep, 200
				} Until ((A_TickCount-startTime) > 3000 || ready)
				IniWrite, 0, abimees_settings.ini, General, HaigusluguReady
			} else {
				UpdateViewedPatients()
			}
			ControlGetText, patientName, ThunderRT6TextBox19, Haiguslugu ahk_class ThunderRT6FormDC
			UpdatePatientList()
			UpdateListBox()
		}
	}
}

UpdateListBox() {
	global patientList
	pt := "|"
	for i,e in patientList {
		name := StrSplit(e, "|")
		pt .= name[1] . "|"
	}
	pt := RTrim(pt, "|")
	GuiControl Main:, LBLastViewed, %pt%
}

UpdatePatientList() {
	global maxPatients, patientList := []
	Loop, %maxPatients% {
		IniRead pt, %A_ScriptDir%\abimees_settings.ini, ViewedPatients, patient%A_index%
		if pt 
			patientList.Push(pt)
	}
}

UpdateViewedPatients() {
	IniRead maxPatients, %A_ScriptDir%\abimees_settings.ini, ViewedPatients, maxPatients, 15
	patientList := []
	Loop, %maxPatients% {
		IniRead pt, %A_ScriptDir%\abimees_settings.ini, ViewedPatients, patient%A_index%
		if pt 
			patientList.Push(pt)
	}
	ControlGetText, patientName, ThunderRT6TextBox19, Haiguslugu ahk_class ThunderRT6FormDC

	; check if patient is already in list
	existing_i := -1
	for i,e in patientList {
		if InStr(e, patientName)
			existing_i := i, break
	}
			
	if (existing_i == -1) {
		ik := GetIsikukood()
		if !ik
			return
		patientList.InsertAt(1,patientName . "|" . ik)
		if patientList.Length() > maxPatients
			patientList.Pop()
	} else {
		patientList.InsertAt(1,patientList[existing_i])
		patientList.RemoveAt(existing_i+1)
	}
			
	Loop, %maxPatients% {
		v := patientList[A_index]
		IniWrite, %v%, %A_ScriptDir%\abimees_settings.ini, ViewedPatients, patient%A_index%
	}
	pt := StrSplit(patientList[1],"|")
	return pt[2]
}

GetIsikukood() {
	WinActivate, Haiguslugu ahk_class ThunderRT6FormDC
	SetControlDelay -1 ; muudab ControlClicki usaldusväärsemaks
	ControlClick, ThunderRT6CommandButton72, Haiguslugu ahk_class ThunderRT6FormDC,,,, NA
	WinWaitActive, Isikuandmed ahk_class ThunderRT6FormDC,,2
	ControlGetText, output, ThunderRT6TextBox9, Isikuandmed ahk_class ThunderRT6FormDC
	WinClose, Isikuandmed ahk_class ThunderRT6FormDC
	return output
}