#NoEnv
#SingleInstance force
SendMode Input  ; Kiirem ja turvalisem teksti kirjutamine
CoordMode, Mouse, Client ; hiire liigutamise koordinaadid relatiivselt akna suhtes
CoordMode, Pixel, Client 
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, 50ms
#Hotstring C R
#Hotstring EndChars `n `t  ; ainult TAB, SPACE, ja ENTER kutsuvad kiirklahvid esile
#MaxHotkeysPerInterval 150
SetTitleMatchMode, 2
DetectHiddenWindows, On
SetWinDelay, -1 ; kiirem akende manipuleerimine
SetControlDelay, -1 ; muudab ControlClicki usaldusväärsemaks

global UserDataRoot := "Y:\UserData"
global UserDataFolder := "Y:\UserData\Abimees"  ; kaust kus on konfiguratsioonifailid

; kui konfiguratsioonifaile ei eksisteeri siis on aeg need luua
if (!FileExist(UserDataRoot)) {
	FileCreateDir, %UserDataRoot%
	FileSetAttrib, +H, %UserDataRoot%
	FileCreateDir, %UserDataFolder%
} else {
	if (!FileExist(UserDataFolder)) 
		FileCreateDir, %UserDataFolder%
}
if (!FileExist(UserDataFolder . "\abimees.ini")) {
	if (FileExist(A_ScriptDir . "\Lib\abimees.template.ini"))
		FileCopy, %A_ScriptDir%\Lib\abimees.template.ini, %UserDataFolder%\abimees.ini
	MsgBox, 36, Esmane käivitus, Kas soovid luua otsetee töölauale?
	IfMsgBox, Yes
		FileCreateShortcut, %A_AhkPath%, %A_Desktop%\Abimees.lnk, %A_ScriptDir%, "%A_ScriptFullPath%", Esteri abimees, %A_ScriptDir%\Resources\metallic_a.ico

	MsgBox, 36, Esmane käivitus, Kas soovid et Abimees käivitataks automaatselt sisselogimisel? (saad seda hiljem muuta paremklikkides Abimees ikooni)
 	IfMsgBox, Yes 
	{
		FileCreateShortcut, %A_AhkPath%, %A_Startup%\Abimees.lnk, %A_ScriptDir%, "%A_ScriptFullPath%", Esteri abimees, %A_ScriptDir%\Resources\metallic_a.ico
		IniWrite, 1, %UserDataFolder%\abimees.ini, Autostart, Abimees
	} else {
		 IniWrite, 0, %UserDataFolder%\abimees.ini, Autostart, Abimees
	 } 
	Sleep, 100 ; anna natuke aega IniWrite kirjutamise jaoks, lisaks kui kiirklavid.ahk on käivitumas siis selle jaoks ka
} 

#include <GlobalVariables>
#include <FindText>

OnExit("ExitFunc")

IniRead, defaultOsakond, %UserDataFolder%\abimees.ini, General, defaultOsakond, %A_Space% ; defaultOsakond = Esteris valitakse see automaatselt rippmenüüst
IniWrite, 0, %UserDataFolder%\abimees.ini, General, HaigusluguReady ; vajalik Viimati vaadatud mooduliga kommunikeerimiseks

;#NoTrayIcon  ; Eemalda kommentaar kui ei soovi ikooni
Menu, Tray, Icon, %A_ScriptDir%\Resources\metallic_a.ico
Menu, Tray, Tip, Abimees
Menu, Tray, NoMainWindow

; loe haigusloo abimehe jaoks kiirlingid sisse
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
	CreateTrayMenu() ; loo tray menu, mis on muutuv
}

; Tekita shell hook mis kontrollib kas "Haiguslugu" aken on avatud; kui on siis aktiveerib Abivahendi
DllCall( "RegisterShellHookWindow", UInt, A_ScriptHwnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage" )

; käivita automaatselt soovitud programmid. 
if (autoStart.EsterStatsionaar) {
	if (FileExist("G:\Statsionaar32\Stats.EXE"))
		Run, G:\Statsionaar32\Stats.EXE
}
if (autoStart.EsterRegistratuur) {
	if (FileExist("G:\Registratuur32\Registr.exe"))
		Run, G:\Registratuur32\Registr.exe
}
if (autoStart.Abimees) {
	if (!FileExist(A_Startup . "\Abimees.lnk")) 
		FileCreateShortcut, %A_AhkPath%, %A_Startup%\Abimees.lnk, %A_ScriptDir%, "%A_ScriptFullPath%", Esteri abimees, %A_ScriptDir%\Resources\metallic_a.ico
}

; kui Ester on juba avatud siis käivita Viimati vaadatud moodul, loe Esterist valitud osakonna nimi, vajadusel muuda vaikimisi osakond
if WinExist("Ester II Statsionaar") {
	if (!WinExist("abimees_lastviewed.ahk ahk_class AutoHotkey") && plugins.LastViewed)
		Run, %AHKPath% abimees_lastviewed.ahk
	ControlGetText, currentOsakond, Edit1, Ester II Statsionaar
	if (currentOsakond) {
		if (!WinExist("abimees_ester.ahk ahk_class AutoHotkey") and plugins.Ester) {
			WinActivate, Ester II Statsionaar
			WinWaitActive, Ester II Statsionaar,,1
			Run, %AHKPath% abimees_ester.ahk
		}
		if (!WinExist(currentOsakond . " ahk_exe stats.exe"))
			ChangeDefaultOsakond()
	}
}

; Deprecated, kahjuks tellimused ei avane enam tavalises veebilehitsejas kuhu saaks javascripti sisestada
;if (!WinExist("abimees_tellimused.ahk ahk_class AutoHotkey") && plugins.Tellimused)
;	Run, %AHKPath% abimees_tellimused.ahk

if (!WinExist("abimees_kiirklahvid.ahk ahk_class AutoHotkey") && plugins.Kiirklahvid)
	Run, %AHKPath% abimees_kiirklahvid.ahk

; loo haigusloo abimehe aknad nii stats kui ambulatoorse Esteri jaoks
if (WinExist("Haiguslugu ahk_exe stats.exe") && plugins.Haiguslugu) {
	WinActivate, Haiguslugu ahk_exe stats.exe
	WinWaitActive, Haiguslugu ahk_exe stats.exe,,1
	CreateHaiguslooAbivahend()
}
if (WinExist("Haiguslugu ahk_exe registr.exe") && plugins.Haiguslugu) {
	WinActivate, Haiguslugu ahk_exe registr.exe
	WinWaitActive, Haiguslugu ahk_exe registr.exe,,1
	CreateHaiguslooAbivahend()
}

return  ; ---------- EDASI VAID FUNKTSIOONID ------------

TrayMoodulHaiguslugu:
	DetectHiddenWindows, Off
	global UserDataFolder, abimeesStats, abimeesAmb
	if (plugins.Haiguslugu) {
		Menu, TrayMoodulid, Uncheck, Haigusloo abimees
		plugins.Haiguslugu := 0
		IniWrite, 0, %UserDataFolder%\abimees.ini, Plugins, Haiguslugu
		if (abimeesStats.ownedAhkId) {
			HaiguslooAbivahendHwnd := abimeesStats.ownedAhkId
			if (WinExist("ahk_id " . HaiguslooAbivahendHwnd))
				WinClose, ahk_id %HaiguslooAbivahendHwnd%
		}
		if (abimeesAmb.ownedAhkId) {
			HaiguslooAbivahendHwnd := abimeesAmb.ownedAhkId
			if (WinExist("ahk_id " . HaiguslooAbivahendHwnd))
				WinClose, ahk_id %HaiguslooAbivahendHwnd%
		}
	} else {
		Menu, TrayMoodulid, Check, Haigusloo abimees
		plugins.Haiguslugu := 1
		IniWrite, 1, %UserDataFolder%\abimees.ini, Plugins, Haiguslugu
		if (WinExist("Haiguslugu ahk_exe stats.exe")) {
			if (!abimeesStats.ownedAhkId or (!WinExist("ahk_id " . abimeesStats.ownedAhkId))) {
				WinActivate, Haiguslugu ahk_exe stats.exe
				WinWaitActive, Haiguslugu ahk_exe stats.exe,,1
				CreateHaiguslooAbivahend()
			}
		}
		if (WinExist("Haiguslugu ahk_exe registr.exe")) {
			if (!abimeesAmb.ownedAhkId or !WinExist("ahk_id " . abimeesAmb.ownedAhkId)) {
				WinActivate, Haiguslugu ahk_exe registr.exe
				WinWaitActive, Haiguslugu ahk_exe registr.exe,,1
				CreateHaiguslooAbivahend()
			}
		}
	}
	DetectHiddenWindows, On
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

TrayMoodulLastViewed:
	TrayMoodulidCheckUncheck("TrayMoodulid", "LastViewed", "Viimati vaadatud", "abimees_lastviewed.ahk")
	return

; Deprecated
;TrayMoodulTellimus:
;	TrayMoodulidCheckUncheck("TrayMoodulid", "Tellimused", "Tellimuslehe abimees", "abimees_tellimused.ahk")
;	return

TrayMoodulKiirklahvid:
	TrayMoodulidCheckUncheck("TrayMoodulid", "Kiirklahvid", "Kiirklahvid", "abimees_kiirklahvid.ahk")
	return
	
TrayAutostartEsterStatsionaar:
	TrayAutostartCheckUncheck("TrayAutostart", "EsterStatsionaar", "Ester II Statsionaar")
	return
	
TrayAutostartEsterRegistratuur:
	TrayAutostartCheckUncheck("TrayAutostart", "EsterRegistratuur", "Ester II Registratuur")
	return

TrayAutostartAbimees:
	TrayAutostartCheckUncheck("TrayAutostart", "Abimees", "Sisselogimisel Abimees")
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
	
	Menu, TrayMoodulid, Add, Haigusloo abimees, TrayMoodulHaiguslugu
	if (plugins.Haiguslugu)
		Menu, TrayMoodulid, Check, Haigusloo abimees
	Menu, TrayMoodulid, Add, Viimati vaadatud, TrayMoodulLastViewed
	if (plugins.LastViewed)
		Menu, TrayMoodulid, Check, Viimati vaadatud
; Deprecated
;	Menu, TrayMoodulid, Add, Tellimuslehe abimees, TrayMoodulTellimus
;	if (plugins.Tellimused)
;		Menu, TrayMoodulid, Check, Tellimuslehe abimees
	Menu, TrayMoodulid, Add, Kiirklahvid, TrayMoodulKiirklahvid
	if (plugins.Kiirklahvid)
		Menu, TrayMoodulid, Check, Kiirklahvid

	Menu, Tray, Add, Moodulid, :TrayMoodulid	
	
	Menu, TrayAutostart, Add, Ester II Statsionaar, TrayAutostartEsterStatsionaar
	if (autoStart.EsterStatsionaar)
		Menu, TrayAutostart, Check, Ester II Statsionaar
	Menu, TrayAutostart, Add, Ester II Registratuur, TrayAutostartEsterRegistratuur
	if (autoStart.EsterRegistratuur)
		Menu, TrayAutostart, Check, Ester II Registratuur
	Menu, TrayAutostart, Add, Sisselogimisel Abimees, TrayAutostartAbimees
	if (autoStart.Abimees)
		Menu, TrayAutostart, Check, Sisselogimise abimees
	Menu, Tray, Add, Käivita automaatselt, :TrayAutostart
		
	Menu, Tray, Add
	Menu, Tray, Add, Redigeeri kiirklahve, TrayKiirklahvid
	Menu, Tray, Add, Redigeeri sätete faili, TrayChangeIni
	Menu, Tray, Add, Kasutusinfo, TrayInfo
	Menu, Tray, Add
	Menu, Tray, Add, Taaskäivita, TrayRestart
	Menu, Tray, Add, Sulge, TrayExit
}

TrayAutostartCheckUncheck(trayName, pluginName, menuName) {
	global UserDataFolder
	if (autoStart[pluginName]) {
		Menu, %trayName%, Uncheck, %menuName%
		autoStart[pluginName] := 0
		IniWrite, 0, %UserDataFolder%\abimees.ini, Autostart, %pluginName%
		if (pluginName == "Abimees" && FileExist(A_Startup . "\Abimees.lnk"))
			FileDelete, %A_Startup%\Abimees.lnk
	} else {
		Menu, %trayName%, Check, %menuName%
		autoStart[pluginName] := 1
		IniWrite, 1, %UserDataFolder%\abimees.ini, Autostart, %pluginName%
		if (pluginName == "Abimees" && !FileExist(A_Startup . "\Abimees.lnk"))
			FileCreateShortcut, %A_AhkPath%, %A_Startup%\Abimees.lnk, %A_ScriptDir%, "%A_ScriptFullPath%", Esteri abimees, %A_ScriptDir%\Resources\metallic_a.ico
	}
}

TrayMoodulidCheckUncheck(trayName, pluginName, menuName, ahkName) {
	global UserDataFolder
	if (plugins[pluginName]) {
		Menu, %trayName%, Uncheck, %menuName%
		plugins[pluginName] := 0
		IniWrite, 0, %UserDataFolder%\abimees.ini, Plugins, %pluginName%
		if (WinExist(ahkName . " ahk_class AutoHotkey"))
			WinClose, %ahkName% ahk_class AutoHotkey
	} else {
		Menu, %trayName%, Check, %menuName%
		plugins[pluginName] := 1
		IniWrite, 1, %UserDataFolder%\abimees.ini, Plugins, %pluginName%
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
	IF !_hwnd	; if the system sent the EVENT_OBJECT_LOCATIONCHANGE event for the caret:
		Return	; https://msdn.microsoft.com/en-us/library/windows/desktop/dd318066(v=vs.85).aspx

	global abimeesStats, abimeesAmb

	WinGetTitle, ownerTitle, A
	WinGetClass, ownerClass, A
	WinGet, wExe, ProcessName, A
	StringLower, wExe, wExe
	if (InStr(ownerTitle, "Haiguslugu") && wExe == "stats.exe") {
		IF (!(abimeesStats.hWinEventHook)) {			; register a event hook function for EVENT_OBJECT_LOCATIONCHANGE := "0x800B" 
			abimeesStats.hWinEventHook := SetWinEventHook("0x800B", "0x800B",0, RegisterCallback("OnLocationChangeMonitor"),_hwnd,0,0)
			,abimeesStats.ownerAhkId := _hWinEventHook, abimeesStats.ownedAhkId := _event
		}
		ownerId := abimeesStats.ownerAhkId, ownedId := abimeesStats.ownedAhkId
		WinGetPos,  _x,  _y, _w, _h, ahk_id %ownerId%
		WinMove, ahk_id %ownedId%,, % _x+_w-10, % _y ; set the position of the window owned by owner
	} else if (InStr(ownerTitle, "Haiguslugu") && wExe == "registr.exe") {
		IF (!(abimeesAmb.hWinEventHook)) {			; register a event hook function for EVENT_OBJECT_LOCATIONCHANGE := "0x800B" 
			abimeesAmb.hWinEventHook := SetWinEventHook("0x800B", "0x800B",0, RegisterCallback("OnLocationChangeMonitor"),_hwnd,0,0)
			,abimeesAmb.ownerAhkId := _hWinEventHook, abimeesAmb.ownedAhkId := _event
		}
		ownerId := abimeesAmb.ownerAhkId, ownedId := abimeesAmb.ownedAhkId
		WinGetPos,  _x,  _y, _w, _h, ahk_id %ownerId%
		WinMove, ahk_id %ownedId%,, % _x+_w-10, % _y ; set the position of the window owned by owner
	} else if (InStr(ownerTitle, "Kirjelduse sisestamine") && wExe == "stats.exe") {
		if (abimeesStats.kirjeldusOtsing.resetMoodul == 0 || !IsObject(abimeesStats.kirjeldusOtsing))
			return
		ownerId := abimeesStats.kirjeldusOtsing.ownerAhkId, ownedId := abimeesStats.kirjeldusOtsing.ownedAhkId
		WinGetPos,  _x,  _y, _w, _h, Kirjelduse sisestamine ahk_id %ownerId%
		WinMove, ahk_id %ownedId%,, % _x+8, % _y+_h-8 ; set the position of the window owned by owner
	} else if (InStr(ownerTitle, "Kirjelduse sisestamine") && wExe == "registr.exe") {
		if (abimeesAmb.kirjeldusOtsing.resetMoodul == 0 || !IsObject(abimeesAmb.kirjeldusOtsing))
			return
		ownerId := abimeesAmb.kirjeldusOtsing.ownerAhkId, ownedId := abimeesAmb.kirjeldusOtsing.ownedAhkId
		WinGetPos,  _x,  _y, _w, _h, Kirjelduse sisestamine ahk_id %ownerId%
		WinMove, ahk_id %ownedId%,, % _x+8, % _y+_h-8 ; set the position of the window owned by owner
	}
}

SetWinEventHook(_eventMin, _eventMax, _hmodWinEventProc, _lpfnWinEventProc, _idProcess, _idThread, _dwFlags) {
	DllCall("CoInitialize", "Uint", 0)
	return DllCall("SetWinEventHook","Uint",_eventMin,"Uint",_eventMax,"Ptr",_hmodWinEventProc,"Ptr",_lpfnWinEventProc,"Uint",_idProcess,"Uint",_idThread,"Uint",_dwFlags)
}  ; cf. https://autohotkey.com/boards/viewtopic.php?t=830
UnhookWinEvent(_hWinEventHook) {
	DllCall("UnhookWinEvent", "Ptr", _hWinEventHook)
	DllCall("CoUninitialize")
}  ; cf. https://autohotkey.com/boards/viewtopic.php?t=830

UpdateViewedPatients(exeName = "stats.exe") {
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
			StringLower, wExe, wExe
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

			if (WinExist("Ester II Statsionaar")) {
				ControlGetText, currentOsakond, Edit1, Ester II Statsionaar
				if (InStr(wTitle, currentOsakond) || InStr(wTitle, "Korrusvaade")) {
					if (!WinExist("abimees_lastviewed.ahk ahk_class AutoHotkey") && plugins.LastViewed) {
						Run, %AHKPath% abimees_lastviewed.ahk
						WinWait, abimees_lastviewed.ahk ahk_class AutoHotkey,, 2
						WinActivate, %wTitle%
					}
				}
			}

			if (InStr(wTitle, "Haiguslugu") && InStr(wClass, "ThunderRT6FormDC")) {
				if (plugins.Haiguslugu) {
					WinWaitActive, Haiguslugu,,1
					CreateHaiguslooAbivahend()
				}
			} else if InStr(wTitle, "Ester II Statsionaar") {
				CreateTrayMenu()
				ChangeDefaultOsakond()
			}
		}
	} else if (wParam == 2) {
		global abimeesStats, abimeesAmb
		SetFormat, Integer, Hex
		wId := lParam + 0
		SetFormat, Integer, D
		WinGetTitle, wTitle, ahk_id %wId%		; wTitle is Window Title
		WinGetClass, wClass, ahk_id %wId%		; wClass is Window Class
		WinGet, wExe, ProcessName, ahk_id %wId%	; wExe is Window Execute
		if (abimeesStats.ownerAhkId == wId) {
			UnhookWinEvent(abimeesStats.hWinEventHook)
			Gui, Statsionaar:Destroy
			if WinExist("Patsient ahk_class ThunderRT6FormDC")
				WinClose, Patsient ahk_class ThunderRT6FormDC
		} else if (abimeesAmb.ownerAhkId == wId) {
			UnhookWinEvent(abimeesAmb.hWinEventHook)
			Gui, Registratuur:Destroy
		} else if (abimeesStats.kirjeldusOtsing.ownerAhkId == wId) {
			UnhookWinEvent(abimeesStats.kirjeldusOtsing.hWinEventHook)
			Gui, StatsOtsing:Destroy
			abimeesStats.kirjeldusOtsing.resetMoodul := 0
		} else if (abimeesAmb.kirjeldusOtsing.ownerAhkId == wId) {
			UnhookWinEvent(abimeesAmb.kirjeldusOtsing.hWinEventHook)
			Gui, AmbOtsing:Destroy
			abimeesAmb.kirjeldusOtsing.resetMoodul := 0
		}

		;TrayTip, Message, %wTitle% %wExe%
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
				MouseClick, left, %outX%, %outY%, %clickCount%, 0
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
			MouseClick, left, %outX%, %outY%, %clickCount%, 0
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
				MouseClick, left, %searchX%, %searchY%, %clickCount%, 0
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
		MouseClick, left, %searchX%, %searchY%, %clickCount%, 0
	}
	Sleep, %sleepTime%
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
	if WinExist("abimees_kiirklahvid.ahk ahk_class AutoHotkey")
		WinClose, abimees_kiirklahvid.ahk ahk_class AutoHotkey
; Deprecated
;	if WinExist("abimees_tellimused.ahk ahk_class AutoHotkey")
;		WinClose, abimees_tellimused.ahk ahk_class AutoHotkey
}
	
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
~^a::
	WinGetActiveTitle, winTitle
	WinGet, winExe, ProcessName, %winTitle%
	SendMessage, 0xB1, 0, -1, ThunderRT6TextBox1, Kirjelduse sisestamine ahk_exe %winExe% ; EM_SETSEL
	return
#IfWinActive

~LButton::
	global lastMousexPos, lastMouseyPos, DoubleClickTime, DoubleClickError := 2
	CoordMode, Mouse, Screen
	MouseGetPos, currentMousexPos, currentMouseyPos 
	CoordMode, Mouse, Client
	correctedXCheck := (currentMousexPos <= (lastMousexPos + DoubleClickError)) && (currentMousexPos >= (lastMousexPos - DoubleClickError))
	correctedYCheck := (currentMouseyPos <= (lastMouseyPos + DoubleClickError)) && (currentMouseyPos >= (lastMouseyPos - DoubleClickError))
	lastMousexPos := currentMousexPos, 	lastMouseyPos := currentMouseyPos
	;if (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < DoubleClickTime and currentMousexPos = lastMousexPos and currentMouseyPos = lastMouseyPos)
	if (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < DoubleClickTime and correctedXCheck and correctedYCheck)
	{
		MouseGetPos, currentMousexPos, currentMouseyPos,, activeControl
		SetTitleMatchMode, 2
		;if !WinActive("ahk_class ThunderRT6FormDC") {
			;TrayTip, Message, Wrong window
		;	return
		;}
		global currentOsakond
		WinGetActiveTitle, winTitle
		WinGet, winID, ID, %winTitle%
		WinGet, winExe, ProcessName, %winTitle%
		StringLower, winExe, winExe
		SetControlDelay -1

		if (winExe == "stats.exe" || winExe == "registr.exe") {
			if InStr(winTitle, "Korrusvaade") or InStr(winTitle, currentOsakond) or InStr(winTitle, "Palatiosakond") {
				ControlGetPos, ctrlX, ctrlY, ctrlW, ctrlH, SPR32X30_SpreadSheet1, A	
				if !((currentMouseyPos > ctrlY && currentMouseyPos < (ctrlY+ctrlH-45)) && (currentMousexPos > ctrlX && currentMousexPos < (ctrlX+ctrlW-20)))
					return
				Sleep, 150 ; Oota veidi, muidu mõnikord ei avane valikudialoogi ja hakkab kleebiseid trükkima
				SetControlDelay -1 ; muudab ControlClicki usaldusväärsemaks
				if InStr(winTitle, "Palatiosakond") {
					ControlClick, ThunderRT6CommandButton9, %currentOsakond% ahk_exe %winExe%,,,, NA 
				} else {
					ControlClick, ThunderRT6CommandButton21, %currentOsakond% ahk_exe %winExe%,,,, NA 
				}
				Sleep, 150
				Send, k
				;WaitTextExist("AvaHaigusluguMenu",,,,,,0)
			} else if (InStr(winTitle, "Vastuvõtuosakond") || InStr(winTitle, "jälgimisel olevad")) {
				ControlGetPos, ctrlX, ctrlY, ctrlW, ctrlH, SPR32X30_SpreadSheet1, A
				ctrlX := ctrlX - 8 ; Control vs Window koordinaadid erinevad, korrektsioon
				ctrlY := ctrlY - 16
				; Kontrolli kas hiir asub valikute kastis
				if ((currentMouseyPos > ctrlY && currentMouseyPos < (ctrlY+ctrlH-31)) && (currentMousexPos > ctrlX && currentMousexPos < (ctrlX+ctrlW-20))) {
					SetControlDelay -1
					ControlClick, ThunderRT6CommandButton24, Vastuvõtuosakond ahk_exe %winExe%,,,, NA
				}
			} else if InStr(winTitle, "Haiguslugu") {
				PixelGetColor, color, currentMousexPos, currentMouseyPos
				ControlGetPos, ctrlX, ctrlY, ctrlW, ctrlH, SPR32X30_SpreadSheet1, A
				ctrlX := ctrlX - 8 ; Control vs Window koordinaadid erinevad, korrektsioon
				ctrlY := ctrlY - 16
				; Kontrolli kas hiir asub valikute kastis
				if ((currentMouseyPos > ctrlY && currentMouseyPos < (ctrlY+ctrlH-31)) && (currentMousexPos > ctrlX && currentMousexPos < (ctrlX+ctrlW-20))) {
					Sleep, 200 ; Oota veidi et rida saaks valitud
					SetControlDelay -1 ; muudab ControlClicki usaldusväärsemaks
					ControlGetText, selectedText, SPR32X30EditHScroll1, Haiguslugu ahk_exe %winExe%
					if (InStr("Anamnees,Ravipäevik,Konsultatsiooni otsus", Trim(selectedText))) {
						if WinExist("Kirjelduse sisestamine ahk_exe " . winExe) {
							WinActivate, Kirjelduse sisestamine ahk_exe %winExe%
							MsgBox, 51, Hoiatus, "Kirjelduse sisestamine" aken on juba avatud. Kas soovid enne jätkamist eelneva teksti salvestada?
							IfMsgBox, Yes 
							{
								ControlClick, ThunderRT6CommandButton3, Kirjelduse sisestamine ahk_exe %winExe%,,,,NA
							} else {
								IfMsgBox, No
									ControlClick, ThunderRT6CommandButton4, Kirjelduse sisestamine ahk_exe %winExe%,,,,NA
								else 
									return
							}
							WinActivate, Haiguslugu ahk_exe %winExe%
						}
					}
					ControlClick, % (winExe == "stats.exe") ? "ThunderRT6CommandButton33" : "ThunderRT6CommandButton20", Haiguslugu ahk_exe %winExe%,,,, NA ; kliki Täpsemalt nupule
					WinWaitNotActive, ahk_id %winID%,,1
					if ErrorLevel
						return
					Sleep,40
					WinGetActiveTitle, newWinTitle
					WinGet, newWinID, ID, %newWinTitle%
					if InStr(newWinTitle, "Haiguslugu") {
						ControlGetText, noBut, Button2, Haiguslugu ahk_exe %winExe%
						if (noBut == "&No") {
							ControlClick, Button2, Haiguslugu ahk_exe %winExe%,,,, NA
							WinWaitNotActive, ahk_id %newWinID%,,1
							WinGetActiveTitle, newWinTitle
							WinGet, newWinID, ID, %newWinTitle%
						}
					}
					;if InStr(newWinTitle, "Kirjelduse sisestamine") {
					;	Send, ^{End}
					if InStr(newWinTitle, "Labor") {
						WaitControlVisible("ThunderRT6CheckBox3","Labor ahk_exe " . winExe, 3000)
						ControlClick, % (winExe == "stats.exe") ? "ThunderRT6CheckBox3" : "ThunderRT6CheckBox2", Labor ahk_exe %winExe%,,,, NA
					}
				}
			} else if InStr(winTitle, "Labor") {
				ControlGet, SS1, Visible,, SPR32X30_SpreadSheet1, A 
				if (SS1)
					ControlGetPos, ctrlX, ctrlY, ctrlW, ctrlH, SPR32X30_SpreadSheet1, A ; Kõikide proovide tabel
				else
					ControlGetPos, ctrlX, ctrlY, ctrlW, ctrlH, SPR32X30_SpreadSheet2, A ; Ühe proovi analüüside tabel
				ctrlY := ctrlY - 30
				PixelGetColor, color, currentMousexPos, currentMouseyPos
				if ((currentMouseyPos > ctrlY && currentMouseyPos < (ctrlY+ctrlH-15)) && (currentMousexPos > ctrlX && currentMousexPos < (ctrlX+ctrlW-20))) {
					SetControlDelay -1 ; muudab ControlClicki usaldusväärsemaks
					if (SS1)
						ControlClick, ThunderRT6CheckBox3, Labor ahk_exe %winExe%,,,, NA ; kliki Filtreeri
					else
						ControlClick, ThunderRT6CommandButton17, Labor ahk_exe %winExe%,,,, NA ; kliki Areng
				}
			} else if InStr(winTitle, "Valimine tabelist ISIK,AADRESSID,asukohad") {
				ControlGetPos, ctrlX, ctrlY, ctrlW, ctrlH, SPR32X30_SpreadSheet1, A
				ctrlX := ctrlX - 8
				ctrlY := ctrlY - 32
				PixelGetColor, color, currentMousexPos, currentMouseyPos
				if ((currentMouseyPos > ctrlY && currentMouseyPos < (ctrlY+ctrlH-15)) && (currentMousexPos > ctrlX && currentMousexPos < (ctrlX+ctrlW-20))) {
					SetControlDelay -1
					ControlClick, ThunderRT6CommandButton8, Valimine tabelist ISIK ahk_exe %winExe%,,,, NA ; valib patsiendi Patsiendi aknasse
					Sleep, 300
					ControlClick, ThunderRT6CommandButton3, Patsient ahk_exe %winExe%,,,, NA ; avab valitud patsiendi
				}
			}
		} else if (winExe == "digilugu.klient.exe") {
			SetControlDelay -1 ; muudab ControlClicki usaldusväärsemaks
			if (activeControl) {
				ControlClick, WindowsForms10.BUTTON.app.0.262c0e4_r6_ad13, %winTitle%,,,, NA
			}
		}
	} else {
		MouseGetPos,,, hoverWindow, hoverControl
		WinGetClass, hoverClass, ahk_id %hoverWindow%
		WinGetTitle, hoverTitle, ahk_id %hoverWindow%
		
		if !(InStr(hoverClass, "ThunderRT6Form"))
			return
		if (InStr(hoverTitle, "Labor")) {
			if (HasVal(["ThunderRT6CommandButton9","ThunderRT6CommandButton10","ThunderRT6CommandButton11","ThunderRT6CommandButton12","ThunderRT6CommandButton13","ThunderRT6CommandButton14"], hoverControl)) {
				;TrayTip, Message, %hoverControl%
				ControlFocus, ThunderRT6TextBox27, Labor ahk_class ThunderRT6FormDC
				MouseClick, left
				;ControlClick, %hoverControl%, Labor ahk_class ThunderRT6FormDC
			}	
		} else if (InStr(hoverTitle, "Ambulatoorne")) {
			WinGetActiveTitle, activeTitle
			ControlGetFocus, activeControl, %activeTitle%
			if (hoverControl == "ThunderRT6ListBox1") {
				ih := InputHook(,"{Enter}{Esc}")
				ih.Start()
				inp := ""
				lastChangeTime := A_TickCount
				While (InStr(activeTitle, "Ambulatoorne") and (activeControl == "ThunderRT6ListBox1")) {
					if ((A_TickCount - lastChangeTime) > 2000) {
						if (inp != "") {
							inp := ""
							ih.Stop()
							ih.Start()
						}
					}
					new_inp := ih.Input
					if (inp != new_inp) {
						inp := new_inp
						LB_SELECTSTRING := 0x018C
						SendMessage, % LB_SELECTSTRING, 3, &inp, ThunderRT6ListBox1, Ambulatoorne vastuvõtt
						;TrayTip, Message, %inp% Error: %ErrorLevel%
						lastChangeTime := A_TickCount
						ToolTip, % inp, % A_CaretX + 15, % A_CaretY
						SetTimer, RemoveToolTip, -2000
					}
					WinGetActiveTitle, activeTitle
					ControlGetFocus, activeControl, %activeTitle%
					Sleep, 50
				}
				ih.Stop()
			}
		}
	}
	return

~MButton::
	SetTitleMatchMode, 2
	if WinActive("Haiguslugu ahk_class ThunderRT6FormDC") {
		global currentOsakond
		MouseGetPos, currentMousexPos, currentMouseyPos
		WinGet, winExe, ProcessName, A
		ControlGetPos, ctrlX, ctrlY, ctrlW, ctrlH, SPR32X30_SpreadSheet1, A
		ctrlX := ctrlX - 8 ; Control vs Window koordinaadid erinevad, korrektsioon
		ctrlY := ctrlY - 16
		; Kontrolli kas hiir asub valikute kastis
		if ((currentMouseyPos > ctrlY && currentMouseyPos < (ctrlY+ctrlH-31)) && (currentMousexPos > ctrlX && currentMousexPos < (ctrlX+ctrlW-20))) {
			MouseClick, Left
			Sleep, 100
			KlikiTellimuseNupule(9, winExe)
		}
	}
	return
	

RemoveToolTip:
	ToolTip
	return
;#include *i Y:\UserData\Abimees\kiirklahvid.ahk
