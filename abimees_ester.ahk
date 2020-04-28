#NoEnv
#SingleInstance force
#NoTrayIcon
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
CoordMode, Mouse, Client ; koordinaadid relatiivselt akna suhtes
CoordMode, Pixel, Client 
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, 1000
SetTitleMatchMode, 2

if !WinExist("Ester II Statsionaar") {
	Run, G:\Statsionaar32\Stats.EXE
} else {
	ControlGetText, currentOsakond, Edit1, Ester II Statsionaar
	if (currentOsakond) {
		WinActivate, Ester II Statsionaar
		WinWaitActive, Ester II Statsionaar
		CreateEsteriAbivahend()
		if WinExist(currentOsakond)
			WinActivate, %currentOsakond%
	}
	;ChangeDefaultOsakond()
}


return


CreateEsteriAbivahend() {
	WinActivate, Ester II Statsionaar
	SetWinDelay, -1

	WinGet, PID, PID, % "ahk_id " . owner:=WinExist("Ester II Statsionaar") 
	WinGetPos, x_haigus, y_haigus, w_haigus, h_haigus, Ester II Statsionaar
	window_w := 70
	window_h := 300
	button_w := 70
	button_h := 30
	w_adjusted_x := x_haigus + w_haigus - 10
	adjusted_h_haigus := h_haigus-35

	GUI, New, +ToolWindow +Owner%owner% +Hwndowned -SysMenu

	Gui, Add, Button, gButOsakond1 x0 y0 w%button_w% h%button_h%, I sise
	Gui, Add, Button, gButOsakond2 x0 y30 w%button_w% h%button_h%, II sise
	Gui, Add, Button, gButOsakond3 x0 y60 w%button_w% h%button_h%, Gastro
	Gui, Add, Button, gButOsakond4 x0 y90 w%button_w% h%button_h%, Reuma
	Gui, Add, Button, gButOsakond5 x0 y120 w%button_w% h%button_h%, Endo
	Gui, Add, Button, gButOsakond6 x0 y150 w%button_w% h%button_h%, Pulmo
	Gui, Add, Button, gButOsakond7 x0 y180 w%button_w% h%button_h%, Nefro
	Gui, Add, Button, gButOsakond8 x0 y210 w%button_w% h%button_h%, Hemato
	
	GUI, Show, x%w_adjusted_x% y%y_haigus% w%window_w% h%adjusted_h_haigus%, Osakond
	WinActivate, Ester II Statsionaar

	OnLocationChangeMonitor(owner, owned, PID) ; INIT

	WinWaitClose % "ahk_id " . owner ; ... or until the owner window does not exist

	Gui , Destroy
	ExitApp

	ButOsakond1:
		ClickButton("I sisehaiguste")
		return

	ButOsakond2:
		ClickButton("II sisehaiguste")
		return

	ButOsakond3:
		ClickButton("Gastro")
		return

	ButOsakond4:
		ClickButton("Reuma")
		return

	ButOsakond5:
		ClickButton("Endo")
		return

	ButOsakond6:
		ClickButton("Pulmo")
		return

	ButOsakond7:
		ClickButton("Nefro")
		return

	ButOsakond8:
		ClickButton("Hemato")
		return

	LVLastViewed:
		return
}

ClickButton(osakond) {
	SetControlDelay -1
	WinActivate, Ester II Statsionaar
	WinWaitActive, Ester II Statsionaar
	Control, ChooseString, %osakond%, ThunderRT6ComboBox1, Ester II Statsionaar
	ControlClick, ThunderRT6CommandButton11, Ester II Statsionaar,,,, NA
	return
}


OnLocationChangeMonitor(_hWinEventHook, _event, _hwnd) { ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd373885(v=vs.85).aspx
	STATIC ox, oy, nx, ny, ownerAhkId, ownedAhkId, hWinEventHook
	IF !_hwnd	; if the system sent the EVENT_OBJECT_LOCATIONCHANGE event for the caret:
		Return	; https://msdn.microsoft.com/en-us/library/windows/desktop/dd318066(v=vs.85).aspx
	IF !hWinEventHook			; register a event hook function for EVENT_OBJECT_LOCATIONCHANGE := "0x800B" 
		hWinEventHook := SetWinEventHook("0x800B", "0x800B",0, RegisterCallback("OnLocationChangeMonitor"),_hwnd,0,0)
		 , ownerAhkId := _hWinEventHook,   ownedAhkId := _event,   OnExit(Func("UnhookWinEvent").Bind(hWinEventHook))
	WinGetPos,  _x,  _y, _w, _h, ahk_id %ownerAhkId%
	WinGetPos, _x1, _y1,,, ahk_id %ownedAhkId%
	WinMove, ahk_id %ownedAhkId%,, % _x+_w-10, % _y
}

SetWinEventHook(_eventMin, _eventMax, _hmodWinEventProc, _lpfnWinEventProc, _idProcess, _idThread, _dwFlags) {
	DllCall("CoInitialize", "Uint", 0)
	return DllCall("SetWinEventHook","Uint",_eventMin,"Uint",_eventMax,"Ptr",_hmodWinEventProc,"Ptr",_lpfnWinEventProc,"Uint",_idProcess,"Uint",_idThread,"Uint",_dwFlags)
}  ; cf. https://autohotkey.com/boards/viewtopic.php?t=830
UnhookWinEvent(_hWinEventHook) {
	DllCall("UnhookWinEvent", "Ptr", _hWinEventHook)
	DllCall("CoUninitialize")
}  ; cf. https://autohotkey.com/boards/viewtopic.php?t=830