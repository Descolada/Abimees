#NoEnv
#SingleInstance force
#NoTrayIcon
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
CoordMode, Mouse, Client ; koordinaadid relatiivselt akna suhtes
CoordMode, Pixel, Client 
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, 1000
SetTitleMatchMode, 2

WinActivate, Kirjelduse sisestamine
WinWaitActive, Kirjelduse sisestamine
SetWinDelay, -1

WinGet, PID, PID, % "ahk_id " . owner:=WinExist() 

window_w := 170
window_h := 30
global searchVar, searchText, searchPhrase, searchTotalFound, searchCurrentFound

GUI, New, +ToolWindow +Owner%owner% +Hwndowned -SysMenu -Caption
Gui, Add, Edit, r1
Gui, Add, Button, Default gButOtsi x135 y5 w30 h22, Otsi
Gui, Add, Text, vsearchVar x170 y10, 0/0
Gui, Add, Button, gButPrev x200 y5 w10 h22, <
Gui, Add, Button, gButNext x210 y5 w10 h22, >

WinGetPos, x_win, y_win, w_win, h_win, Kirjelduse sisestamine
adjust_x := x_win + 8
adjust_y := y_win + h_win - 8
GUI, Show, x%adjust_x% y%adjust_y% w%window_w% h%window_h%, Otsing

OnLocationChangeMonitor(owner, owned, PID) ; INIT

WinWaitClose % "ahk_id " . owner ; ... or until the owner window does not exist

Gui , Destroy
ExitApp

ButOtsi:
	global searchText, searchPhrase, searchTotalFound, searchCurrentFound
	ControlGetText, searchText, ThunderRT6TextBox1, Kirjelduse sisestamine
	GuiControlGet, searchPhrase,, Edit1
	if (searchPhrase = "") {
		searchTotalFound := 0
		searchCurrentFound := 0
		return
	}
	StringReplace, searchText, searchText, %searchPhrase%, %searchPhrase%, UseErrorLevel
	searchTotalFound := ErrorLevel
	new_window_w := window_w + 60
	if (searchTotalFound = 0) {
		searchCurrentFound := 0
		GuiControl,,searchVar, 0/0
		new_window_w := window_w + 30
		Gui, Show, w%new_window_w% h%window_h%
		return
	}
	GuiControl,,searchVar, 1/%searchTotalFound%
	Gui, Show, w%new_window_w% h%window_h%
		foundPos := InStr(searchText, searchPhrase,,,1)
	start := foundPos-1
	end := foundPos-1+StrLen(searchPhrase)
	ControlFocus, ThunderRT6TextBox1, Kirjelduse sisestamine
	SendMessage, 0xB1, %start%, %end%, ThunderRT6TextBox1, Kirjelduse sisestamine ; EM_SETSEL
	SendMessage, 0x00B7,,, ThunderRT6TextBox1, Kirjelduse sisestamine ; EM_SCROLLCARET
	searchCurrentFound := 1
	return
ButPrev:
	global searchText, searchPhrase, searchTotalFound, searchCurrentFound
	if (searchTotalFound = 0)	
		return
	if (searchCurrentFound != 1)
		searchCurrentFound := searchCurrentFound - 1
	GuiControl,,searchVar, %searchCurrentFound%/%searchTotalFound%
	foundPos := InStr(searchText, searchPhrase,,,searchCurrentFound)
	start := foundPos-1
	end := foundPos-1+StrLen(searchPhrase)
	ControlFocus, ThunderRT6TextBox1, Kirjelduse sisestamine
	SendMessage, 0xB1, %start%, %end%, ThunderRT6TextBox1, Kirjelduse sisestamine ; EM_SETSEL
	SendMessage, 0x00B7,,, ThunderRT6TextBox1, Kirjelduse sisestamine ; EM_SCROLLCARET
	return
ButNext:
	global searchText, searchPhrase, searchTotalFound, searchCurrentFound
	if (searchTotalFound = 0)	
		return
	if (searchCurrentFound != searchTotalFound)
		searchCurrentFound := searchCurrentFound + 1
	GuiControl,,searchVar, %searchCurrentFound%/%searchTotalFound%
	foundPos := InStr(searchText, searchPhrase,,,searchCurrentFound)
	start := foundPos-1
	end := foundPos-1+StrLen(searchPhrase)
	ControlFocus, ThunderRT6TextBox1, Kirjelduse sisestamine
	SendMessage, 0xB1, %start%, %end%, ThunderRT6TextBox1, Kirjelduse sisestamine ; EM_SETSEL
	SendMessage, 0x00B7,,, ThunderRT6TextBox1, Kirjelduse sisestamine ; EM_SCROLLCARET
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
	WinMove, ahk_id %ownedAhkId%,, % _x+8, % _y + _h - 8
}


SetWinEventHook(_eventMin, _eventMax, _hmodWinEventProc, _lpfnWinEventProc, _idProcess, _idThread, _dwFlags) {
	DllCall("CoInitialize", "Uint", 0)
	return DllCall("SetWinEventHook","Uint",_eventMin,"Uint",_eventMax,"Ptr",_hmodWinEventProc,"Ptr",_lpfnWinEventProc,"Uint",_idProcess,"Uint",_idThread,"Uint",_dwFlags)
}  ; cf. https://autohotkey.com/boards/viewtopic.php?t=830
UnhookWinEvent(_hWinEventHook) {
	DllCall("UnhookWinEvent", "Ptr", _hWinEventHook)
	DllCall("CoUninitialize")
}  ; cf. https://autohotkey.com/boards/viewtopic.php?t=830