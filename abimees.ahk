#NoEnv
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
CoordMode, Mouse, Client ; koordinaadid relatiivselt akna suhtes
CoordMode, Pixel, Client 
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, 1000
#Hotstring C R
#Hotstring EndChars `n `t  ; TAB, SPACE, ja ENTER kutsuvad ainult kiirklahvid esile
#MaxHotkeysPerInterval 150
SetTitleMatchMode, 2
DetectHiddenWindows, On

global UserDataRoot := "Y:\UserData"
global UserDataFolder := "Y:\UserData\Abimees"  ; Kui seda muuta siis peab muutma ka kõige viimast rida (#include kiirklahvid)

if (!FileExist(UserDataRoot)) {
	FileCreateDir, %UserDataRoot%
	FileSetAttrib, +H, %UserDataRoot%
	FileCreateDir, %UserDataFolder%
} else {
	if (!FileExist(UserDataFolder)) 
		FileCreateDir, %UserDataFolder%
}

if (!FileExist(UserDataFolder . "\abimees.ini"))
	if (FileExist(A_ScriptDir . "\Lib\abimees.ini.template"))
		FileCopy, %A_ScriptDir%\Lib\abimees.ini.template, %UserDataFolder%\abimees.ini

if (!FileExist(UserDataFolder "\kiirklahvid.ahk")) {
	if (FileExist(A_ScriptDir . "\Lib\kiirklahvid.ahk.template")) {
		FileCopy, %A_ScriptDir%\Lib\kiirklahvid.ahk.template, %UserDataFolder%\kiirklahvid.ahk
		Reload
	}
}

#include <GlobalVariables>
#include <FindText>

OnExit("ExitFunc")

IniRead, defaultOsakond, %UserDataFolder%\abimees.ini, General, defaultOsakond, %A_Space%
IniWrite, 0, %UserDataFolder%\abimees.ini, General, HaigusluguReady

;#NoTrayIcon  ; Eemalda kommentaar kui ei soovi ikooni
Menu, Tray, Icon, %A_ScriptDir%\metallic_a.ico
Menu, Tray, Tip, Abimees
Menu, Tray, NoMainWindow

IniRead, lingid, %UserDataFolder%\abimees.ini, Kiirlingid, kiirlingid, %A_Space%
if (lingid && (lingid != A_Space)) {
	lingidSplit := StrSplit(lingid,"|")
	for i,e in lingidSplit {
		if (e == "") {
			Menu, Kiirlingid, Add
		} else {
			linkSplit := StrSplit(e,";")
			linkName := linkSplit[1]
			kiirlingid[linkSplit[1]] := linkSplit[2]
			Menu, Kiirlingid, Add, %linkName%, klProcessLink
		}
	}	
}

if !ExperimentalMode {
	CreateTrayMenu()
}

; Tekita shell hook mis kontrollib kas "Haiguslugu" aken on avatud; kui on siis aktiveerib Abivahendi
DllCall( "RegisterShellHookWindow", UInt, A_ScriptHwnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage" )

if !WinExist("Ester II Statsionaar") {
	if (FileExist("G:\Statsionaar32\Stats.EXE"))
		Run, G:\Statsionaar32\Stats.EXE
} else {
	ControlGetText, currentOsakond, Edit1, Ester II Statsionaar
	if (currentOsakond) {
		if (!WinExist("abimees_ester.ahk ahk_class AutoHotkey") and plugins.Ester) {
			WinActivate, Ester II Statsionaar
			WinWaitActive, Ester II Statsionaar,,1
			Run, %AHKPath% abimees_ester.ahk
			
		}
		if (!WinExist("abimees_lastviewed.ahk ahk_class AutoHotkey") && plugins.LastViewed)
			Run, %AHKPath% abimees_lastviewed.ahk
	}
	ChangeDefaultOsakond()
}

if (!WinExist("abimees_labor.ahk ahk_class AutoHotkey") && plugins.Labor)
	Run, %AHKPath% abimees_labor.ahk

if (!WinExist("abimees_tellimused.ahk ahk_class AutoHotkey") && plugins.Tellimused)
	Run, %AHKPath% abimees_tellimused.ahk

if (WinExist("Haiguslugu ahk_class ThunderRT6FormDC") && plugins.Haiguslugu) {
	WinActivate, Haiguslugu ahk_class ThunderRT6FormDC
	WinWaitActive, Haiguslugu ahk_class ThunderRT6FormDC,,1
	CreateHaiguslooAbivahend()
}
return

TrayHaiguslugu:
	global HaiguslooAbivahendHwnd, UserDataFolder
	if (plugins.Haiguslugu) {
		Menu, Tray, Uncheck, Haigusloo abimees
		plugins.Haiguslugu := 0
		IniWrite, 0, %UserDataFolder%\abimees.ini, Plugins, Haiguslugu
		if (HaiguslooAbivahendHwnd)
			if (WinExist("ahk_id " . HaiguslooAbivahendHwnd))
				WinClose, ahk_id %HaiguslooAbivahendHwnd%
	} else {
		Menu, Tray, Check, Haigusloo abimees
		plugins.Haiguslugu := 1
		IniWrite, 1, %UserDataFolder%\abimees.ini, Plugins, Haiguslugu
		if (WinExist("Haiguslugu ahk_class ThunderRT6FormDC")) {
			if (!HaiguslooAbivahendHwnd || (HaiguslooAbivahend && (!WinExist("ahk_id " . HaiguslooAbivahendHwnd)))) {
				WinActivate, Haiguslugu ahk_class ThunderRT6FormDC
				WinWaitActive, Haiguslugu ahk_class ThunderRT6FormDC,,1
				CreateHaiguslooAbivahend()
			}
		}
	}
	return
	
TrayDefaultOsakondChange:
	global koikOsakonnad, defaultOsakond, UserDataFolder
	for i,e in koikOsakonnad
		Menu, TrayDefaultOsakond, Uncheck, %e%
	Menu, TrayDefaultOsakond, Check, %A_ThisMenuItem%
	IniWrite, %A_ThisMenuItem%, %UserDataFolder%\abimees.ini, General, defaultOsakond
	defaultOsakond := A_ThisMenuItem
	ChangeDefaultOsakond()
	return

TrayLastViewed:
	TrayCheckUncheck("LastViewed", "Viimati vaadatud", "abimees_lastviewed.ahk")
	return

TrayTellimus:
	TrayCheckUncheck("Tellimused", "Tellimuslehe abimees", "abimees_tellimused.ahk")
	return

TrayInfo:
	global UserDataFolder
	Run C:\Windows\Notepad.exe "%A_ScriptDir%\Loe mind.txt"
	return
	
TrayKiirklahvid:
	global UserDataFolder
	Run C:\Windows\Notepad.exe "%UserDataFolder%\kiirklahvid.ahk"
	return

TrayChangeIni:
	global UserDataFolder
	Run C:\Windows\Notepad.exe "%UserDataFolder%\abimees.ini"
	return

TrayExit:
	ExitApp
	return

TrayRestart:
	Reload
	return

#include <PluginHaiguslugu>
#include <PluginOtsing>

CreateTrayMenu() {
	Menu, Tray, NoStandard
	Menu, Tray, DeleteAll
	ControlGetText, currentOsakond, Edit1, Ester II Statsionaar
	if (currentOsakond) {
		global koikOsakonnad := []
		ControlGet, osakonnad, List,, ThunderRT6ComboBox1, Ester II Statsionaar ahk_class ThunderRT6FormDC
		Loop, Parse, osakonnad, `n
			koikOsakonnad.Push(A_LoopField)
		for i, e in koikOsakonnad
			Menu, TrayDefaultOsakond, Add, %e%, TrayDefaultOsakondChange, +Radio
			
		if (defaultOsakond != A_Space && defaultOsakond) {
			try {
				Menu, TrayDefaultOsakond, Check, %defaultOsakond%
			} catch e {
			}
		}
		Menu, Tray, Add, Vaikimisi osakond, :TrayDefaultOsakond
		Menu, Tray, Add
	}
	
	Menu, Tray, Add, Haigusloo abimees, TrayHaiguslugu
	if (plugins.Haiguslugu)
		Menu, Tray, Check, Haigusloo abimees
	Menu, Tray, Add, Viimati vaadatud, TrayLastViewed
	if (plugins.LastViewed)
		Menu, Tray, Check, Viimati vaadatud
	Menu, Tray, Add, Tellimuslehe abimees, TrayTellimus
	if (plugins.Tellimused)
		Menu, Tray, Check, Tellimuslehe abimees
	Menu, Tray, Add
	Menu, Tray, Add, Redigeeri kiirklahve, TrayKiirklahvid
	Menu, Tray, Add, Redigeeri sätete faili, TrayChangeIni
	Menu, Tray, Add, Kasutusinfo, TrayInfo
	Menu, Tray, Add
	Menu, Tray, Add, Taaskäivita, TrayRestart
	Menu, Tray, Add, Sulge, TrayExit
}

TrayCheckUncheck(plugin, menuName, ahkName) {
	global UserDataFolder
	if (plugins[plugin]) {
		Menu, Tray, Uncheck, %menuName%
		plugins[plugin] := 0
		IniWrite, 0, %UserDataFolder%\abimees.ini, Plugins, %plugin%
		if (WinExist(ahkName . " ahk_class AutoHotkey"))
			WinClose, %ahkName% ahk_class AutoHotkey
	} else {
		Menu, Tray, Check, %menuName%
		plugins[plugin] := 1
		IniWrite, 1, %UserDataFolder%\abimees.ini, Plugins, %plugin%
		if (!WinExist(ahkName . " ahk_class AutoHotkey"))
			Run, %AHKPath% %ahkName%
	}
}

JoinArray(strArray, delimiter := ", ")
{
  s := ""
  for i,v in strArray
    s .= delimiter . v
  return substr(s, 3)
}

HasVal(haystack, needle) {
	if !(IsObject(haystack)) || (haystack.Length() = 0)
		return 0
	for index, value in haystack
		if (value = needle)
			return index
	return 0
}

OnLocationChangeMonitor(_hWinEventHook, _event, _hwnd) { ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd373885(v=vs.85).aspx
	STATIC ox, oy, nx, ny, ownerAhkId, ownedAhkId, hWinEventHook
	global resetAbimees
	if resetAbimees
		hWinEventHook := 0, resetAbimees := 0
	IF !_hwnd	; if the system sent the EVENT_OBJECT_LOCATIONCHANGE event for the caret:
		Return	; https://msdn.microsoft.com/en-us/library/windows/desktop/dd318066(v=vs.85).aspx
	IF !hWinEventHook			; register a event hook function for EVENT_OBJECT_LOCATIONCHANGE := "0x800B"
		hWinEventHook := SetWinEventHook("0x800B", "0x800B",0, RegisterCallback("OnLocationChangeMonitor"),_hwnd,0,0)
		 , ownerAhkId := _hWinEventHook,   ownedAhkId := _event,   OnExit(Func("UnhookWinEvent").Bind(hWinEventHook))
	WinGetPos,  _x,  _y, _w, _h, ahk_id %ownerAhkId%
	WinMove, ahk_id %ownedAhkId%,, % _x+_w-10, % _y ; set the position of the window owned by owner
}

OnLocationChangeMonitorOtsing(_hWinEventHook, _event, _hwnd) { ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd373885(v=vs.85).aspx
	STATIC ox, oy, nx, ny, ownerAhkId, ownedAhkId, hWinEventHook
	global resetOtsing
	if resetOtsing
		hWinEventHook := 0, resetOtsing := 0
	IF !_hwnd	; if the system sent the EVENT_OBJECT_LOCATIONCHANGE event for the caret:
		Return	; https://msdn.microsoft.com/en-us/library/windows/desktop/dd318066(v=vs.85).aspx
	IF !hWinEventHook			; register a event hook function for EVENT_OBJECT_LOCATIONCHANGE := "0x800B" 
		hWinEventHook := SetWinEventHook("0x800B", "0x800B",0, RegisterCallback("OnLocationChangeMonitorOtsing"),_hwnd,0,0)
		 , ownerAhkId := _hWinEventHook,   ownedAhkId := _event,   OnExit(Func("UnhookWinEvent").Bind(hWinEventHook))
	WinGetPos,  _x,  _y, _w, _h, ahk_id %ownerAhkId%
	WinMove, ahk_id %ownedAhkId%,, % _x+8, % _y+_h-8 ; set the position of the window owned by owner
}

SetWinEventHook(_eventMin, _eventMax, _hmodWinEventProc, _lpfnWinEventProc, _idProcess, _idThread, _dwFlags) {
	DllCall("CoInitialize", "Uint", 0)
	return DllCall("SetWinEventHook","Uint",_eventMin,"Uint",_eventMax,"Ptr",_hmodWinEventProc,"Ptr",_lpfnWinEventProc,"Uint",_idProcess,"Uint",_idThread,"Uint",_dwFlags)
}  ; cf. https://autohotkey.com/boards/viewtopic.php?t=830
UnhookWinEvent(_hWinEventHook) {
	DllCall("UnhookWinEvent", "Ptr", _hWinEventHook)
	DllCall("CoUninitialize")
}  ; cf. https://autohotkey.com/boards/viewtopic.php?t=830

UpdateViewedPatients() {
	global UserDataFolder
	IniRead maxPatients, %UserDataFolder%\abimees.ini, ViewedPatients, maxPatients, 15
	patientList := []
	Loop, %maxPatients% {
		IniRead pt, %UserDataFolder%\abimees.ini, ViewedPatients, patient%A_index%, %A_Space%
		if (pt && pt != A_Space && pt != "ERROR") 
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
		IniWrite, %v%, %UserDataFolder%\abimees.ini, ViewedPatients, patient%A_index%
	}
	pt := StrSplit(patientList[1],"|")
	return pt[2]
}

ShellMessage( wParam,lParam )	; Gets all Shell Hook Messages
{
	if (wParam = 1) { ;  HSHELL_WINDOWCREATED := 1 ; Only act on Window Created Messages
		global plugins, AHKPath, currentOsakond
		
		wId:= lParam							; wID is Window Handle
		WinGetTitle, wTitle, ahk_id %wId%		; wTitle is Window Title
		WinGetClass, wClass, ahk_id %wId%		; wClass is Window Class
		WinGet, wExe, ProcessName, ahk_id %wId%	; wExe is Window Execute
	
		WinGetTitle, activeTitle, A
		WinGet, activeExe, ProcessName, A
		if (InStr(activeTitle, "Edge") or InStr(activeTitle, "Internet") or InStr(activeTitle, "Chrome") or InStr(activeExe, "msedge")) {
			;if WaitBrowserLoaded() {
			;	WinGetTitle, activeTitle, A
			;	WinGet, activeId, ID, A
			;	if (InStr(activeTitle, "Tellimused -")) {
			;		global visitedBrowsers, JS
			;		if (HasVal(visitedBrowsers, activeId)) {
			;			return
			;		} else {
			;			visitedBrowsers.Push(activeId)
			;			if (visitedBrowsers.maxIndex() > 20)
			;				visitedBrowsers.RemoveAt(1)
			;		}
			;		if (!WinExist("Labori tellimus")) {
			;			WinActivate, Tellimused -
			;			WinWaitActive, Tellimused -,,1
			;			;Sleep, 200
			;			;SendJavascript(JS.DefaultClicksOnLoad)
			;			;if !TextExist("Hematoloogia")
			;			;	SendJavascript("javascript:document.getElementById('ctl00_pc_LabOrderModuleNewOrder_patientAndCustomerControl_testData_setSelector_Arrow').click();")
			;			;if !TextExist("LisaUuring", 40)
			;			;	if TextExist("Pildipank", 40)
			;			;		TextExist("Otsi", 40)
			;		}
			;	}
			;}
		} else {
			if (wTitle="") {
				WinGetTitle,TopWindow,A
				if InStr(TopWindow, "Ester II Statsionaar") {
					if InStr(TopWindow, "Ester II Statsionaar") {
						CreateTrayMenu()
						ChangeDefaultOsakond()
						if (!WinExist("abimees_ester.ahk ahk_class AutoHotkey") && plugins.Ester)
							Run, %AHKPath% abimees_ester.ahk
						if (!WinExist("abimees_lastviewed.ahk ahk_class AutoHotkey") && plugins.LastViewed)
							Run, %AHKPath% abimees_lastviewed.ahk
					}
				}
			}

			if WinExist("Ester II Statsionaar")
				ControlGetText, currentOsakond, Edit1, Ester II Statsionaar

			if (InStr(wTitle, "Haiguslugu") && InStr(wClass, "ThunderRT6FormDC") && plugins.Haiguslugu) {
				WinWaitActive, Haiguslugu,,1
				CreateHaiguslooAbivahend()
			} else if InStr(wTitle, "Ester II Statsionaar") {
				CreateTrayMenu()
				ChangeDefaultOsakond()
			}
		}

	}
}

StringCount(str, match) {
	StringReplace, str, str, %match%, %match%, UseErrorLevel
	return ErrorLevel
}

SendJavascript(fileName) {
	ClipSaved := ClipboardAll ; save the entire clipboard to the variable ClipSaved
	clipboard := ""

	SendEvent, !d
	Sleep, 100
	SendEvent, j
	

	clipboard := "avascript:$.getScript('https://cdn.jsdelivr.net/gh/Descolada/TellimusedJS@latest/" . fileName . ".js');"
	ClipWait, 1              
	
	if (!ErrorLevel)         ; If NOT ErrorLevel, ClipWait found data on the clipboard
		SendEvent, ^v             ; paste the text
	
	Sleep, 100
	SendEvent, {Enter}

	clipboard := ClipSaved   
	ClipSaved =              ; Free the memory in case the clipboard was very large.
	SetKeyDelay, 10
}

GetURL() {
	ClipSaved := ClipboardAll ; save the entire clipboard to the variable ClipSaved

	SendInput, !d
	;Sleep, 40
	clipboard := ""           ; empty the clipboard (start off empty to allow ClipWait to detect when the text has arrived)

	SendInput, ^c
	ClipWait, 1              ; wait max. 2 seconds for the clipboard to contain data. 
	
if (!ErrorLevel) {         ; If NOT ErrorLevel, ClipWait found data on the clipboard

		result := clipboard
		clipboard := ClipSaved   ; restore original clipboard
		
ClipSaved =              ; Free the memory in case the clipboard was very large.
		return result
	} else {
		clipboard := ClipSaved   ; restore original clipboard
		
ClipSaved =              ; Free the memory in case the clipboard was very large.
		return 0
	}
}

WaitURLLoaded(url, maxTime=5000) {
	startTime := A_TickCount
	Loop {
		if (GetURL() == url)
			return 1
		
Sleep, 40

	} Until ((A_TickCount-startTime)>maxTime)
	return 0
}

WaitBrowserLoaded() {
	global browserName
	WinGetPos,,,wTellimus,hTellimus,A
	WinGetClass,wClass,A
	WinGetTitle,wTitle,A
	WinGet, wExe, ProcessName, A
	if InStr(wExe, "msedge") {
		browserName := "Edge_virtual"
	} else if InStr(wExe, "iexplore.exe") {
		browserName := "IE11"
	} else if InStr(wClass, "Chrome") {
		browserName := "Chrome"
	} else if InStr(wTitle, "Edge") {
		browserName := "Edge"
	}
	if WaitTextExist("Reload", 0)
		return 1
	return 0
}

WaitTextExist(searchText, click=40, clickCount=1, offsetX=0, nResult=1, maxTime=5000, inBrowser=1) {
	WinGetPos,xWindow,yWindow,wWindow,hWindow,A
	global ImageLibrary, browserName
	if inBrowser {
		images := ImageLibrary[browserName]
	} else {
		images := ImageLibrary
	}
	if (!images[searchText]) {
		TrayTip, Viga!, Teksti "%searchText%" ei leitud.
		return
	}
	foundText := FindText(xWindow, yWindow, xWindow+wWindow, yWindow+hWindow, 0, 0, images[searchText])
	startTime := A_TickCount
	Loop {
		if (foundText) {
			if (nResult > foundText.MaxIndex())
				nResult := 1
			outX := (foundText[nResult]).x, outY := (foundText[nResult]).y
			if (click) {
				if (offsetX != 0)
					outX := (foundText[nResult]).1 + offsetX
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
	} Until ((A_TickCount-startTime)>maxTime)
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
		TrayTip, Viga!, Teksti "%searchText%" ei leitud.
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

WaitImageExist(image, click=40, clickCount=1, inBrowser=1, maxTime=5000, correctionX=0, correctionY=0) { 
	global browserName
	WinGetPos,,,wWindow,hWindow,A
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

WaitControlVisible(controlName, winTitle, maxTime=5000) {
	maxLoops := maxTime / 40
	Loop, %maxLoops% {
		ControlGet, output, Visible, , %controlName%, %winTitle%
		if (output) {
			return 1
		} else {
			Sleep, 40
		}
	}
	return 0
}

ClickImageByName(name, sleepTime=40, clickCount=1, inBrowser=1, correctionX=0, correctionY=0) {
	global browserName
	WinGetPos,,,wTellimus,hTellimus,A
	if inBrowser {
		searchName := browserName . "\" . name
	} else {
		searchName := name
	}
	ImageSearch, outX, outY, 0, 0, wTellimus, hTellimus, %A_ScriptDir%\pildid\%searchName%.png
	if (ErrorLevel == 0) {
		searchX := Min(wTellimus, Max(0, outX + correctionX))
		searchY := Min(hTellimus, Max(0, outY + correctionY))
		MouseClick, left, %searchX%, %searchY%, %clickCount%
	}
	Sleep, %sleepTime%
}

ValiAnaluusid(nimi, navigatsioon, analuusid, scrolling := 0) {
	;WaitTextExist("ValiBlankett",,,,,10000)
	WaitTextExist("ValiBlankett",,,,10000)
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
	WaitTextExist("OK")
	return
}

TelliKliiniline(tellimus) {
	ValiAnaluusid("Kliiniline", ["Hematoloogia"], tellimus)
	return
}

TelliBiokeemia(tellimus) {
	ValiAnaluusid("Biokeemia", ["KliinilineKeemia","Biokeemia"], tellimus)
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

ChangeDefaultOsakond() {
	global defaultOsakond
	Control, ChooseString, %defaultOsakond%, ThunderRT6ComboBox1, Ester II Statsionaar ahk_class ThunderRT6FormDC
}

ExitFunc(ExitReason, ExitCode) {
	if WinExist("abimees_ester.ahk ahk_class AutoHotkey")
		WinClose, abimees_ester.ahk ahk_class AutoHotkey
	if WinExist("abimees_otsing.ahk ahk_class AutoHotkey")
		WinClose, abimees_otsing.ahk ahk_class AutoHotkey
	if WinExist("abimees_lastviewed.ahk ahk_class AutoHotkey")
		WinClose, abimees_lastviewed.ahk ahk_class AutoHotkey
	if WinExist("abimees_labor.ahk ahk_class AutoHotkey")
		WinClose, abimees_labor.ahk ahk_class AutoHotkey
	if WinExist("abimees_tellimused.ahk ahk_class AutoHotkey")
		WinClose, abimees_tellimused.ahk ahk_class AutoHotkey
}


#IfWinActive Haiguslugu ahk_class ThunderRT6FormDC
^r::
	FindAndOpenDocument("Ravipäevik")
	return

^!a::
	FindAndOpenDocument("Anamnees")
	return

^l::
	AvaLabor()
	return
#IfWinActive

#IfWinActive Tellimused
~^+s::
	global JS
	SendJavascript("TellimusedJS")
	return
#IfWinActive	
	
#IfWinActive Isikuandmed ahk_class ThunderRT6FormDC
~^c::
	ControlGetFocus, focused, Isikuandmed ahk_class ThunderRT6FormDC
	ControlGet, out, Selected,, %focused%
	if (out != "")
		clipboard := out
	
	return
#IfWinActive 


~^+r::
	Reload
	return

#IfWinActive Kirjelduse sisestamine ahk_class ThunderRT6FormDC
~^f::
	if WinActive("Kirjelduse sisestamine ahk_class ThunderRT6FormDC") {
		;global AHKPath
		;Run, %AHKPath% abimees_otsing.ahk
		CreateSearchBox()
	}
	return
#IfWinActive

~LButton::
	global lastMousexPos, lastMouseyPos, DoubleClickTime, DoubleClickError := 2
	CoordMode, Mouse, Screen
	MouseGetPos, currentMousexPos, currentMouseyPos 
	CoordMode, Mouse, Client
	correctedXCheck := lastMousexPos <= currentMousexPos + DoubleClickError && lastMousexPos >= currentMousexPos - DoubleClickError
	correctedYCheck := lastMouseyPos <= currentMouseyPos + DoubleClickError && lastMouseyPos >= currentMouseyPos - DoubleClickError
	;if (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < DoubleClickTime and currentMousexPos = lastMousexPos and currentMouseyPos = lastMouseyPos)
	if (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < DoubleClickTime and correctedXCheck and correctedYCheck)
	{
		MouseGetPos, currentMousexPos, currentMouseyPos
		SetTitleMatchMode, 2
		if !WinActive("ahk_class ThunderRT6FormDC") {
			;TrayTip, Message, Wrong window
			return
		}
		global currentOsakond
		WinGetActiveTitle, winTitle
		WinGet, winID, ID, %winTitle%
		if InStr(winTitle, "Korrusvaade") or InStr(winTitle, currentOsakond) or InStr(winTitle, "Palatiosakond") {
			ControlGetPos, ctrlX, ctrlY, ctrlW, ctrlH, SPR32X30_SpreadSheet1, A
			if !((currentMouseyPos > ctrlY && currentMouseyPos < (ctrlY+ctrlH-45)) && (currentMousexPos > ctrlX && currentMousexPos < (ctrlX+ctrlW-20)))
				return
			SetControlDelay -1 ; muudab ControlClicki usaldusväärsemaks
			if InStr(winTitle, "Palatiosakond")
				ControlClick, ThunderRT6CommandButton9, %currentOsakond% ahk_class ThunderRT6FormDC,,,, NA 
			else
				ControlClick, ThunderRT6CommandButton21, %currentOsakond% ahk_class ThunderRT6FormDC,,,, NA 
			Sleep,40
			Send,{Down 2}
			Sleep,40
			Send,{Enter}
		} else if InStr(winTitle, "Haiguslugu") {
			;ControlGet, selected, List, Count, SPR32X30_SpreadSheet1, Haiguslugu
			;MsgBox, %selected%
			PixelGetColor, color, currentMousexPos, currentMouseyPos
			ControlGetPos, ctrlX, ctrlY, ctrlW, ctrlH, SPR32X30_SpreadSheet1, A
			ctrlX := ctrlX - 8 ; Control vs Window koordinaadid erinevad, korrektsioon
			ctrlY := ctrlY - 16
			; Kontrolli kas hiir asub valikute kastis
			if ((currentMouseyPos > ctrlY && currentMouseyPos < (ctrlY+ctrlH-31)) && (currentMousexPos > ctrlX && currentMousexPos < (ctrlX+ctrlW-20))) {
			;if (currentMouseyPos > 330) && (currentMousexPos < 845) && (HasVal([0x000000, 0xFFFFFF, 0xC0DCC0, 0xD77800, 0xFF9933, 0x3F233F], color)) {
				Sleep, 200 ; Oota veidi et rida saaks valitud
				SetControlDelay -1 ; muudab ControlClicki usaldusväärsemaks
				ControlGetText, selectedText, SPR32X30EditHScroll1, Haiguslugu ahk_class ThunderRT6FormDC
				if (InStr("Anamnees,Ravipäevik,Konsultatsiooni otsus", Trim(selectedText))) {
					if WinExist("Kirjelduse sisestamine ahk_class ThunderRT6FormDC") {
						WinActivate, Kirjelduse sisestamine ahk_class ThunderRT6FormDC
						MsgBox, 51, Hoiatus, "Kirjelduse sisestamine" aken on juba avatud. Kas soovid enne jätkamist eelneva teksti salvestada?
						IfMsgBox, Yes 
						{
							ControlClick, ThunderRT6CommandButton3, Kirjelduse sisestamine ahk_class ThunderRT6FormDC,,,,NA
						} else {
							IfMsgBox, No
								ControlClick, ThunderRT6CommandButton4, Kirjelduse sisestamine ahk_class ThunderRT6FormDC,,,,NA
							else 
								return
						}
						WinActivate, Haiguslugu ahk_class ThunderRT6FormDC
					}
				}
				ControlClick, ThunderRT6CommandButton33, Haiguslugu ahk_class ThunderRT6FormDC,,,, NA ; kliki Täpsemalt nupule
				WinWaitNotActive, ahk_id %winID%,,1
				if ErrorLevel
					return
				Sleep,40
				WinGetActiveTitle, newWinTitle
				WinGet, newWinID, ID, %newWinTitle%
				if InStr(newWinTitle, "Haiguslugu") {
					ControlGetText, noBut, Button2, Haiguslugu ahk_class ThunderRT6FormDC
					if (noBut == "&No") {
						ControlClick, Button2, Haiguslugu ahk_class ThunderRT6FormDC,,,, NA
						WinWaitNotActive, ahk_id %newWinID%,,1
						WinGetActiveTitle, newWinTitle
						WinGet, newWinID, ID, %newWinTitle%
					}
				}
				;if InStr(newWinTitle, "Kirjelduse sisestamine") {
				;	Send, ^{End}
				if InStr(newWinTitle, "Labor") {
					WaitControlVisible("ThunderRT6CheckBox3","Labor ahk_class ThunderRT6FormDC", 3000)
					ControlClick, ThunderRT6CheckBox3, Labor ahk_class ThunderRT6FormDC,,,, NA
				}
			}
		} else if InStr(winTitle, "Labor") {
			ControlGetPos, ctrlX, ctrlY, ctrlW, ctrlH, SPR32X30_SpreadSheet2, A
			ctrlY := ctrlY - 30
			PixelGetColor, color, currentMousexPos, currentMouseyPos
			if ((currentMouseyPos > ctrlY && currentMouseyPos < (ctrlY+ctrlH-15)) && (currentMousexPos > ctrlX && currentMousexPos < (ctrlX+ctrlW-20))) {
			;if (currentMouseyPos > 99) && (currentMousexPos > 346) && (HasVal([0x000000, 0xFFFFFF, 0xC0DCC0, 0xD77800, 0xFF9933, 0x3F233F], color)) {
				SetControlDelay -1 ; muudab ControlClicki usaldusväärsemaks
				ControlClick, ThunderRT6CommandButton17, Labor ahk_class ThunderRT6FormDC,,,, NA ; kliki Areng
			}
		} else if InStr(winTitle, "Valimine tabelist ISIK,AADRESSID,asukohad") {
			ControlGetPos, ctrlX, ctrlY, ctrlW, ctrlH, SPR32X30_SpreadSheet1, A
			ctrlX := ctrlX - 8
			ctrlY := ctrlY - 32
			PixelGetColor, color, currentMousexPos, currentMouseyPos
			if ((currentMouseyPos > ctrlY && currentMouseyPos < (ctrlY+ctrlH-15)) && (currentMousexPos > ctrlX && currentMousexPos < (ctrlX+ctrlW-20))) {
			;if (currentMouseyPos > 16) && (currentMousexPos > 7) && (HasVal([0x000000, 0xFFFFFF, 0xC0DCC0, 0xD77800, 0xFF9933, 0x3F233F], color)) {
				SetControlDelay -1
				ControlClick, ThunderRT6CommandButton8, Valimine tabelist ISIK ahk_class ThunderRT6FormDC,,,, NA
				Sleep, 300
				ControlClick, ThunderRT6CommandButton3, Patsient ahk_class ThunderRT6FormDC,,,, NA
			}
		}
	} else {
		MouseGetPos,,, hoverWindow, hoverControl
		WinGetClass, hoverClass, ahk_id %hoverWindow%
		if !(hoverClass == "ThunderRT6FormDC")
			return
		if (HasVal(["ThunderRT6CommandButton9","ThunderRT6CommandButton10","ThunderRT6CommandButton11","ThunderRT6CommandButton12","ThunderRT6CommandButton13","ThunderRT6CommandButton14"], hoverControl)) {
			;TrayTip, Message, %hoverControl%
			ControlFocus, ThunderRT6TextBox27, Labor ahk_class ThunderRT6FormDC
			ControlClick, %hoverControl%, Labor ahk_class ThunderRT6FormDC
		}	
	}
	lastMousexPos := currentMousexPos, lastMouseyPos := currentMouseyPos
	return

~MButton::
	SetTitleMatchMode, 2
	if WinActive("Haiguslugu ahk_class ThunderRT6FormDC") {
		global currentOsakond
		MouseGetPos, currentMousexPos, currentMouseyPos
		PixelGetColor, color, currentMousexPos, currentMouseyPos
		if (currentMouseyPos > 330) && (currentMousexPos < 845) && (HasVal([0x000000, 0xFFFFFF, 0xC0DCC0, 0xD77800, 0xFF9933, 0x3F233F], color)) {
			MouseClick, Left
			Sleep, 100
			KlikiTellimuseNupule(10)
			WinWaitActive, Tellimus,,1
			if (!WinExist("abimees_tellimused.ahk ahk_class AutoHotkey")) {
				WaitBrowserLoaded()
				WaitTextExist("Tellimused1kuu",,,,,1000)
			}
		}
	}
	return


#h::  ; Win+H hotkey
	; Get the text currently selected. The clipboard is used instead of
	; "ControlGet Selected" because it works in a greater variety of editors
	; (namely word processors).  Save the current clipboard contents to be
	; restored later. Although this handles only plain text, it seems better
	; than nothing:
	AutoTrim Off  ; Retain any leading and trailing whitespace on the clipboard.
	ClipboardOld := ClipboardAll
	Clipboard := ""  ; Must start off blank for detection to work.
	Send ^c
	ClipWait 1
	if ErrorLevel  ; ClipWait timed out.
	    return
	; Replace CRLF and/or LF with `n for use in a "send-raw" hotstring:
	; The same is done for any other characters that might otherwise
	; be a problem in raw mode:
	StringReplace, Hotstring, Clipboard, ``, ````, All  ; Do this replacement first to avoid interfering with the others below.
	StringReplace, Hotstring, Hotstring, `r`n, ``r, All  ; Using `r works better than `n in MS Word, etc.
	StringReplace, Hotstring, Hotstring, `n, ``r, All
	StringReplace, Hotstring, Hotstring, %A_Tab%, ``t, All
	StringReplace, Hotstring, Hotstring, `;, ```;, All
	Clipboard := ClipboardOld  ; Restore previous contents of clipboard.
	; This will move the InputBox's caret to a more friendly position:
	SetTimer, MoveCaret, 10
	; Show the InputBox, providing the default hotstring:
	inputBoxText := "Kirjuta oma kiirklahv valitud kohta. Mõned kasulikud muudatused:`n:*: Lõpetab teksi koheselt ilma Enterit vajutamata`n:C: Muudab tõstutundlikuks`nNäide: :R:btw`::by the way`n"
	InputBox, Hotstring, Uus kiirklahv, %inputBoxText%,,,,,,,, :r0:`::%Hotstring%
	if ErrorLevel  ; The user pressed Cancel.
	    return
	if InStr(Hotstring, ":r0`:::")
	{
	    MsgBox Lühendit ei leitud ning kiirklahvi ei lisatud.
	    return
	}
	; Otherwise, add the hotstring and reload the script:
	global UserDataFolder
	FileAppend, `n%Hotstring%, %UserDataFolder%\kiirklahvid.ahk  ; Put a `n at the beginning in case file lacks a blank line at its end.
	Reload
	Sleep 200 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
	MsgBox, 4,, Näib et lisatud kiirklahv oli vigane. Kas soovid avada kiirklahvi faili redigeerimiseks? Katkine kiirklahv on selle faili lõpus.
	IfMsgBox, Yes, Run C:\Windows\Notepad.exe "%UserDataFolder%\kiirklahvid.ahk"
	return

MoveCaret:
	IfWinNotActive, Uus kiirklahv
	    return
	; Otherwise, move the InputBox's insertion point to where the user will type the abbreviation.
	Send {Home}{Right 4}
	SetTimer, MoveCaret, Off
	return

#include *i Y:\UserData\Abimees\kiirklahvid.ahk
