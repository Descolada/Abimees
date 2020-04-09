#NoEnv
#SingleInstance force
;#NoTrayIcon
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
CoordMode, Mouse, Client ; koordinaadid relatiivselt akna suhtes
CoordMode, Pixel, Client 
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, 1000
SetTitleMatchMode, 2

#include <GlobalVariables>
#include <FindText>

global LBTellimus

DllCall( "RegisterShellHookWindow", UInt, A_ScriptHwnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage" )

if WinExist("Tellimus") {
	WinActivate, Tellimus
	WaitBrowserLoaded()
	CreateLaboriAbivahend()
}

return

ShellMessage( wParam,lParam )	; Gets all Shell Hook Messages
{
	if (wParam = 1) { ;  HSHELL_WINDOWCREATED := 1 ; Only act on Window Created Messages
		wId:= lParam							; wID is Window Handle
		WinGetTitle, wTitle, ahk_id %wId%		; wTitle is Window Title
		WinGetClass, wClass, ahk_id %wId%		; wClass is Window Class
		WinGet, wExe, ProcessName, ahk_id %wId%	; wExe is Window Execute

		WinGetTitle, activeTitle, A
		if (InStr(activeTitle, "Edge") or InStr(activeTitle, "Internet") or InStr(activeTitle, "Chrome")) {
			if WaitBrowserLoaded() {
				WinGetTitle, activeTitle, A
				if (InStr(activeTitle, "Tellimused -")) {
					if (!WinExist("Labori tellimus")) {
						WinActivate, Tellimused -
						WinWaitActive, Tellimused -,,1
						if (TextExist("ValiBlankett") or TextExist("Hematoloogia")) {
							CreateLaboriAbivahend()
						}
					}
				}
			}
		}
	}
}

CreateLaboriAbivahend() {
	SetWinDelay, -1

	WinGet, PID, PID, % "ahk_id " . owner:=WinExist("A")
	WinGetPos, x_owner, y_owner, w_owner, h_owner, % "ahk_id " . owner
	WinGet, maximizedStatus, MinMax, % "ahk_id " . owner

	window_w := 120
	window_h := 200
	if (maximizedStatus == 0) {
		x_coord := x_owner + w_owner - 10
		y_coord := y_owner - 35
	} else {
		x_coord := A_ScreenWidth - window_w - 10
		y_coord := 200
	}


	button_w := 70
	button_h := 30
	tellimusArray := "Kliiniline|Biokeemia|Mikrobioloogia|Uriin ja roe"
	GUI, Main:New, +ToolWindow +Owner%owner% +Hwndowned +AlwaysOnTop

	Gui, Main:Add, ListBox, x0 y0 w%window_w% h%window_h% gLBTellimus vLBTellimus, Kliiniline|Biokeemia|Mikrobioloogia||CBC-5Diff|CHEM-3|CHEM-5|CHEM-13
	
	GUI, Main:Show, x%x_coord% y%y_coord% w%window_w% h%window_h%, Labori tellimus
	WinActivate, % "ahk_id " . owner
	if (maximizedStatus == 0) {
		OnLocationChangeMonitor(owner, owned, PID) ; INIT
	}

	WinWaitClose % "ahk_id " . owner ; ... or until the owner window does not exist

	Gui, Destroy

	LBTellimus:
		if (A_GuiEvent == "Normal") {
			GuiControlGet, itemText, , LBTellimus
			WinActivate, Tellimused -
			WinWaitActive, Tellimused -,,1
			if WaitTextExist("Katkesta",,,,,40)
				WaitTextExist("ValiBlankett")
			switch itemText {
				case "Kliiniline":
					ValiAnaluusid("", ["Hematoloogia"], [], 0)
				case "Biokeemia":
					ValiAnaluusid("", ["KliinilineKeemia","Biokeemia"], [], 0)
				case "Mikrobioloogia":
					ValiAnaluusid("", ["Mikro"], [], 0)
				case "CBC-5Diff":
					ValiAnaluusid("Kliiniline", ["Hematoloogia"], ["CBC-5Diff"])
				case "CHEM-5":
					ValiAnaluusid("Biokeemia", ["KliinilineKeemia","Biokeemia"], ["K","Na","Krea","Urea","CRP"])
				default:
					return
			}
			
		}
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


WaitTextExist(searchText, click=40, clickCount=1, offsetX=0, nResult=1, maxTime=5000, inBrowser=1) {
	WinGetPos,xWindow,yWindow,wWindow,hWindow,A
	global ImageLibrary, browserName
	if inBrowser {
		images := ImageLibrary[browserName]
	} else {
		images := ImageLibrary
	}
	if (!images[searchText]) {
		TrayTip, Viga!, Teksti "%searchText% ei leitud.
		return
	}
	foundText := FindText(xWindow, yWindow, xWindow+wWindow, yWindow+hWindow, 0, 0, images[searchText])
	maxLoops := maxTime / 40
	Loop, %maxLoops% {
		if (foundText) {
			if (nResult > foundText.MaxIndex())
				nResult := 1
			outX := (foundText[nResult]).x, outY := (foundText[nResult]).y
			if (click) {
				if (offsetX != 0)
					outX := (foundText[nResult]).1 + offsetX
			 	;for i,v in foundText
   				;	if (i<=2)
     				;		MouseTip(outX, outY)
				CoordMode, Mouse
				MouseClick, left, %outX%, %outY%, %clickCount%
				CoordMode, Mouse, Client ; koordinaadid relatiivselt akna suhtes
				Sleep, %click%
			}
			return 1
		} else {
			foundText := FindText(xWindow, yWindow, xWindow+wWindow, yWindow+hWindow, 0, 0, images[searchText])
			Sleep, 40
		}
	}
	return 0
}

TextExist(searchText, click=0, inBrowser=1) {
	WinGetPos,xWindow,yWindow,wWindow,hWindow,A
	global ImageLibrary, browserName
	if inBrowser {
		images := ImageLibrary[browserName]
	} else {
		images := ImageLibrary
	}
	if (!images[searchText]) {
		TrayTip, Viga!, Teksti "%searchText% ei leitud.
		return
	}
	foundText := FindText(xWindow, yWindow, xWindow+wWindow, yWindow+hWindow, 0, 0, images[searchText])
	if (foundText) {
		outX := (foundText[1]).x, outY := (foundText[1]).y
		if (click) {
			CoordMode, Mouse
			MouseClick, left, %outX%, %outY%, %clickCount%
			CoordMode, Mouse, Client ; koordinaadid relatiivselt akna suhtes
			Sleep, %click%
		}
		return 1
	}
	return 0
}

WaitBrowserLoaded() {
	global browserName
	WinGetPos,,,wTellimus,hTellimus,A
	WinGetClass,wClass,A
	WinGetTitle,wTitle,A
	if InStr(wClass, "Chrome") {
		browserName := "Chrome"
	} else if InStr(wTitle, "Edge") {
		browserName := "Edge"
	}
	if WaitTextExist("Reload", 0)
		return 1
	return 0
}

WaitImageExist(image, click=40, clickCount=1, inBrowser=1, maxTime=5000, correctionX=0, correctionY=0) { 
	global browserName
	WinGetPos,,,wWindow,hWindow
	if inBrowser {
		searchName := browserName . "\" . image
	} else {
		searchName := image
	}
	ImageSearch, outX, outY, 0, 0, wWindow, hWindow, %A_ScriptDir%\pildid\%searchName%.png
	maxLoops := maxTime / 40
	Loop, %maxLoops% {
		if (ErrorLevel != 0) {
			ImageSearch, outX, outY, 0, 0, wWindow, hWindow, %A_ScriptDir%\pildid\%searchName%.png
			Sleep, %click%
		} else {
			if (click) {
				searchX := Min(wWindow, Max(0, outX + correctionX))
				searchY := Min(hWindow, Max(0, outY + correctionY))
				;MsgBox, outX:%outX% outY:%outY% cX:%correctionX% cY:%correctionY% searchX:%searchX% searchY:%searchY%
				MouseClick, left, %searchX%, %searchY%, %clickCount%
			}
			return 1
		}
	}
	return 0
}

ValiAnaluusid(nimi, navigatsioon, analuusid, scrolling := 0, clickOK := 1) {
	if (!WaitTextExist("Hematoloogia",0,,,,40)) {
		WaitTextExist("ValiBlankett")
	}
	
	lenNav := navigatsioon.MaxIndex()
	for i, e in navigatsioon {
		if scrolling[i] {
			n := scrolling[i]
			Send, {Down %n%}
			Sleep, 40
		}
		if (i != lenNav)
			WaitTextExist(e,,,-15)
		else
			WaitTextExist(e)
	}
	for i,e in analuusid {
		WaitTextExist(nimi . "_" . e,,,-10)
	}
	if clickOK
		WaitTextExist("OK")
	return
}

SaadaLabor() {
	WaitTextExist("Edasi")
	WaitTextExist("SaadaProovivõtule")
	WaitTextExist("Kalender",,2,-5)
	global SubmenuAeg, SubmenuTruki
	relativeTime =
	relativeTime += SubmenuAeg, days
	FormatTime, relativeDate, %relativeTime%, dd.MM.yyyy
	SendInput, %relativeDate%
	;WaitTextExist("OK")
	;if (SubmenuTruki)
	;	WaitTextExist("TrukiKoikKoodid")
}