klProcessLink:
	global kiirlingid
	switch (A_ThisMenuItem) {
		case "":
			return
		default:
			linkUrl := kiirlingid[A_ThisMenuItem]
			Run, %linkUrl%
	}
	return

CreateHaiguslooAbivahend() {
	global plugins, kiirlingid, UserDataFolder
	SetWinDelay, -1

	WinGet, PID, PID, % "ahk_id " . owner:=WinExist() 
	WinGet, ownerExe, ProcessName, % "ahk_id " . owner:=WinExist() 
	StringLower, ownerExe, ownerExe
	if (ownerExe == "stats.exe")
		guiName := "Statsionaar", global abimeesStats := {}, abimeesStats.resetMoodul := 1
	else
		guiName := "Registratuur", global abimeesAmb := {}, abimeesAmb.resetMoodul := 1
	
	
	IniWrite, 0, %UserDataFolder%\abimees.ini, General, HaigusluguReady
	windowName := "Abimees"
	if (plugins.LastViewed) {
		ik := UpdateViewedPatients(ownerExe)
		if ik
			windowName := ik
	}

	window_w :=100
	window_h := 300
	button_w := window_w
	button_h := 30

	GUI, %guiName%:New, +ToolWindow +Owner%owner% +Hwndowned -SysMenu
	if (kiirlingid != {})
		Gui, %guiName%:Add, Button, gButKiirlingid x0 y0 w%button_w% h%button_h%, Kiirlingid
	Gui, %guiName%:Add, Button, gButLaboriTellimus x0 y60 w%button_w% h%button_h%, Labori tellimus
	Gui, %guiName%:Add, Button, gButRadioloogiaTellimus x0 y90 w%button_w% h%button_h%, Radiol. tellimus
	Gui, %guiName%:Add, Button, gButFunktsionaaldgn x0 y120 w%button_w% h%button_h%, Funktsionaaldgn
	Gui, %guiName%:Add, Button, gButPildipank x0 y150 w%button_w% h%button_h%, Pildipank
	Gui, %guiName%:Add, Button, gButRavipaevik x0 y330 w%button_w% h%button_h%, Ravipäevik
	Gui, %guiName%:Add, Button, gButEpikriis x0 y360 w%button_w% h%button_h%, Epikriis
	Gui, %guiName%:Add, Button, gButUuringud x0 y420 w%button_w% h%button_h%, Uuringud
	Gui, %guiName%:Add, Button, gButKirjeldused x0 y450 w%button_w% h%button_h%, Kirjeldused
	WinGetPos, x_haigus, y_haigus, w_haigus, h_haigus, Haiguslugu ahk_exe %ownerExe%
	w_adjusted_x := x_haigus + w_haigus - 10
	adjusted_h_haigus := h_haigus-35
	GUI, %guiName%:Show, x%w_adjusted_x% y%y_haigus% w%window_w% h%adjusted_h_haigus%, %windowName%
	WinActivate, Haiguslugu ahk_exe %ownerExe%

	global resetAbimees = 1
	;abimeesStats.resetMoodul := 1

	OnLocationChangeMonitor(owner, owned, PID) ; INIT

	IniWrite, 1, %UserDataFolder%\abimees.ini, General, HaigusluguReady

	;WinWaitClose % "ahk_id " . owner ; ... or until the owner window does not exist
	;UnhookWinEvent(abimeesStats.hWinEventHook)
	;Gui, %guiName%:Destroy
	
	;if WinExist("Patsient ahk_class ThunderRT6FormDC")
	;	WinClose, Patsient ahk_class ThunderRT6FormDC
	return
	
	ButKiirlingid:
		Menu, Kiirlingid, Show
		return

	ButRavipaevik:
		FindAndOpenDocument((A_Gui == "Statsionaar") ? "stats.exe" : "registr.exe", "Ravipäevik")
		return

	;ButAnamnees:
	;	FindAndOpenDocument("Anamnees")
	;	return

	ButEpikriis:
		FindAndOpenDocument((A_Gui == "Statsionaar") ? "stats.exe" : "registr.exe", "Epikriis", "Etappepikriis")
		return

	ButUuringud:
		if (A_Gui == "Statsionaar") {
			WinActivate, Haiguslugu ahk_exe stats.exe
			WinWaitActive, Haiguslugu ahk_exe stats.exe,,1
		} else {
			WinActivate, Haiguslugu ahk_exe registr.exe
			WinWaitActive, Haiguslugu ahk_exe registr.exe,,1
		}
		FiltreeriDokumendid("u", (A_Gui == "Statsionaar") ? "stats.exe" : "registr.exe")
		return

	ButKirjeldused:
		if (A_Gui == "Statsionaar") {
			WinActivate, Haiguslugu ahk_exe stats.exe
			WinWaitActive, Haiguslugu ahk_exe stats.exe,,1
		} else {
			WinActivate, Haiguslugu ahk_exe registr.exe
			WinWaitActive, Haiguslugu ahk_exe registr.exe,,1
		}
		FiltreeriDokumendid("k", (A_Gui == "Statsionaar") ? "stats.exe" : "registr.exe")
		return

	ButLaboriTellimus:
		KlikiTellimuseNupule(3, (A_Gui == "Statsionaar") ? "stats.exe" : "registr.exe")
		return

	ButRadioloogiaTellimus:
		KlikiTellimuseNupule(1, (A_Gui == "Statsionaar") ? "stats.exe" : "registr.exe")
		return

	ButFunktsionaaldgn:
		KlikiTellimuseNupule(4, (A_Gui == "Statsionaar") ? "stats.exe" : "registr.exe")
		return

	ButPildipank:
		KlikiTellimuseNupule(10, (A_Gui == "Statsionaar") ? "stats.exe" : "registr.exe")
		return
}

KlikiTellimuseNupule(downRepeats, exeName = "stats.exe") {
	StringLower, exeName, exeName
	WinActivate, Haiguslugu ahk_exe %exeName%
	Sleep, 40
	SetControlDelay -1 ; muudab ControlClicki usaldusväärsemaks
	ControlClick, % (exeName == "stats.exe") ? "ThunderRT6CommandButton42" : "ThunderRT6CommandButton27", Haiguslugu ahk_exe %exeName%,,,, NA
	Sleep,150
	Send,{Down %downRepeats%}
	Send,{Enter}
	return
}

GetIsikukood(exeName = "stats.exe") {
	WinActivate, Haiguslugu ahk_exe %exeName%
	SetControlDelay -1 ; muudab ControlClicki usaldusväärsemaks
	ControlClick, % (exeName == "stats.exe") ? "ThunderRT6CommandButton72" : "ThunderRT6CommandButton55", Haiguslugu ahk_exe %exeName%,,,, NA
	WinWaitActive, Isikuandmed ahk_exe %exeName%,,2
	ControlGetText, output, ThunderRT6TextBox9, Isikuandmed ahk_exe %exeName%
	WinClose, Isikuandmed ahk_exe %exeName%
	return output
}

FiltreeriDokumendid(selectionChar, exeName = "stats.exe") {
	SetControlDelay -1
	; Kontrolli kas nimekiri on filtreeritud, kui on siis võta see maha
	ControlGet, filtered, Checked,, ThunderRT6CheckBox1, Haiguslugu ahk_exe %exeName%
	if filtered {
		ControlClick, ThunderRT6CheckBox1, Haiguslugu ahk_exe %exeName%,,,, NA
		Sleep, 100
	}
	; Filtreeri Kirjelduse järgi
	ControlClick, % (exeName == "stats.exe") ? "ThunderRT6CommandButton12" : "ThunderRT6CommandButton2", Haiguslugu ahk_exe %exeName%,,,, NA
	Sleep, 40
	Send, {%selectionChar%}{Enter}
}

FindAndOpenDocument(exeName, doc, backupDoc = "") {
	if !WinExist("Haiguslugu") {
		TrayTip, Viga!, Ava kõigepealt haiguslugu
		return
	}
	;WinClose, Kirjelduse sisestamine ahk_exe %exeName%

	if ((doc == "Anamnees" || doc == "Ravipäevik") && WinExist("Kirjelduse sisestamine ahk_exe " . exeName)) {
		WinActivate, Kirjelduse sisestamine ahk_exe %exeName%

		MsgBox, 51, Hoiatus, "Kirjelduse sisestamine" aken on juba avatud. Kas soovid enne jätkamist eelneva teksti salvestada?
		IfMsgBox, Yes 
		{
			ControlClick, % (exeName == "stats.exe") ? "ThunderRT6CommandButton3" : "ThunderRT6CommandButton2", Kirjelduse sisestamine ahk_exe %exeName%,,,,NA
		} else {
			IfMsgBox, No
				ControlClick, % (exeName == "stats.exe") ? "ThunderRT6CommandButton4" : "ThunderRT6CommandButton3", Kirjelduse sisestamine ahk_exe %exeName%,,,,NA
			else 
				return
		}
	}

	WinActivate, Haiguslugu ahk_exe %exeName%
	WinWaitActive, Haiguslugu ahk_exe %exeName%,,1
	FiltreeriDokumendid("k", exeName)
	; wait until Filtered button is clicked	
	startTime := A_TickCount
	Loop {
		ControlGet, filteredChecked, Checked,, ThunderRT6CheckBox1, Haiguslugu ahk_exe %exeName%
		if ((A_TickCount-startTime)>1000)
			break
		else
			Sleep, 40
	} Until (filteredChecked)
	if (!filteredChecked)
		return
	Sleep, 50

	;WaitTextExist(searchText, click=40, clickCount=1, offsetX=0, nResult=1, maxTime=5000, inBrowser=1)
	if (!WaitTextExist(doc,200,,,,200,0)) {
 		if (doc == "Anamnees" || doc == "Ravipäevik") {
			MsgBox, 36, Dokument, Dokumenti %doc% ei leitud. Kas soovid selle luua?
			IfMsgBox, Yes 
			{
				ControlClick, ThunderRT6CommandButton53, Haiguslugu ahk_exe %exeName%,,,, NA
				Sleep, 200
				Send, {Up}
				WinWaitNotActive, Haiguslugu ahk_exe %exeName%,,1
				ControlClick, Button1, A,,,, NA
				Sleep, 100
				if (WinActive("Haiguslugu ahk_exe " . exeName)) {
					SendEvent, %doc%
					Send, {Tab}
				}
			}
		} else {
			if (backupDoc != "") {
				if (!WaitTextExist(backupDoc,200,,,,0,0)) {
					if (doc == "Epikriis") {
						ControlClick, ThunderRT6CheckBox1, Haiguslugu ahk_exe %exeName%,,,, NA
						ControlClick, % (exeName == "stats.exe") ? "ThunderRT6CommandButton45" : "ThunderRT6CommandButton29", Haiguslugu ahk_exe %exeName%,,,, NA
					} else
						TrayTip, Viga!, Ei leidnud pilti nimega %doc%
					return
				}
			}
		}
	}
	
	if WinActive("Valimine tabelist ahk_exe " . exeName) {
		ControlClick, ThunderRT6CommandButton7, Valimine tabelist ahk_exe %exeName%,,,, NA ; Sulge "Valimine tabelist"
		WinWaitNotActive, Valimine tabelist ahk_exe %exeName%, 1
	}
	ControlClick, % (exeName == "stats.exe") ? "ThunderRT6CommandButton33" : "ThunderRT6CommandButton20", Haiguslugu ahk_exe %exeName%,,,, NA ; kliki Täpsemalt nupule

	WinWaitNotActive, ahk_id %winID%,,1
	if ErrorLevel
		return
	Sleep, 200
	
	if WinActive("Haiguslugu ahk_class ThunderRT6FormDC") {
		ControlGetText, noBut, Button2, Haiguslugu ahk_exe %exeName%
		if (noBut == "&No") {
			ControlClick, Button2, Haiguslugu ahk_exe %exeName%,,,, NA
			Sleep, 100
		}
	}

	if WinExist("Valimine tabelist ahk_exe " . exeName) {
		ControlClick, ThunderRT6CommandButton7, Valimine tabelist ahk_exe %exeName%,,,, NA ; Sulge "Valimine tabelist"
		WinWaitNotActive, Valimine tabelist ahk_exe %exeName%, 1
	}
	Sleep, 200
	If WinExist("Kirjelduse sisestamine ahk_exe " . exeName)
		WinActivate, Kirjelduse sisestamine ahk_exe %exeName%
	return
}

AvaLabor() {
	KlikiTellimuseNupule(3)
	WinWaitActive, Tellimus,,1
	WaitBrowserLoaded()
	WinGet, status, MinMax, Tellimus
	if status == 0
		WinMaximize, Tellimus
	return
}