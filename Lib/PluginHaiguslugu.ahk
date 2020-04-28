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
	global plugins, kiirlingid
	SetWinDelay, -1

	WinGet, PID, PID, % "ahk_id " . owner:=WinExist() 
	IniWrite, 0, abimees_settings.ini, General, HaigusluguReady
	windowName := "Abimees"
	if (plugins.LastViewed) {
		ik := UpdateViewedPatients()
		if ik
			windowName := ik
	}

	window_w :=100
	window_h := 300
	button_w := window_w
	button_h := 30

	GUI, Haiguslugu:New, +ToolWindow +Owner%owner% +Hwndowned -SysMenu
	if (kiirlingid != {})
		Gui, Haiguslugu:Add, Button, gButKiirlingid x0 y0 w%button_w% h%button_h%, Kiirlingid
	Gui, Haiguslugu:Add, Button, gButLaboriTellimus x0 y60 w%button_w% h%button_h%, Labori tellimus
	Gui, Haiguslugu:Add, Button, gButRadioloogiaTellimus x0 y90 w%button_w% h%button_h%, Radiol. tellimus
	Gui, Haiguslugu:Add, Button, gButFunktsionaaldgn x0 y120 w%button_w% h%button_h%, Funktsionaaldgn
	Gui, Haiguslugu:Add, Button, gButPildipank x0 y150 w%button_w% h%button_h%, Pildipank
	Gui, Haiguslugu:Add, Button, gButRavipaevik x0 y330 w%button_w% h%button_h%, Ravipäevik
	Gui, Haiguslugu:Add, Button, gButEpikriis x0 y360 w%button_w% h%button_h%, Epikriis
	Gui, Haiguslugu:Add, Button, gButUuringud x0 y420 w%button_w% h%button_h%, Uuringud
	Gui, Haiguslugu:Add, Button, gButKirjeldused x0 y450 w%button_w% h%button_h%, Kirjeldused
	WinGetPos, x_haigus, y_haigus, w_haigus, h_haigus, Haiguslugu
	w_adjusted_x := x_haigus + w_haigus - 10
	adjusted_h_haigus := h_haigus-35
	GUI, Haiguslugu:Show, x%w_adjusted_x% y%y_haigus% w%window_w% h%adjusted_h_haigus%, %windowName%
	WinActivate, Haiguslugu

	global HaiguslooAbivahendHwnd := owned
	global resetAbimees = 1
	OnLocationChangeMonitor(owner, owned, PID) ; INIT

	IniWrite, 1, abimees_settings.ini, General, HaigusluguReady

	WinWaitClose % "ahk_id " . owner ; ... or until the owner window does not exist
	Gui, Haiguslugu:Destroy
	
	if WinExist("Patsient ahk_class ThunderRT6FormDC")
		WinClose, Patsient ahk_class ThunderRT6FormDC
	return
	
	ButKiirlingid:
		Menu, Kiirlingid, Show
		return

	ButRavipaevik:
		FindAndOpenDocument("Ravipäevik")
		return

	;ButAnamnees:
	;	FindAndOpenDocument("Anamnees")
	;	return

	ButEpikriis:
		FindAndOpenDocument("Epikriis", "Etappepikriis")
		return

	ButUuringud:
		WinActivate, Haiguslugu ahk_class ThunderRT6FormDC
		WinWaitActive, Haiguslugu ahk_class ThunderRT6FormDC,,1
		FiltreeriDokumendid("u")
		return

	ButKirjeldused:
		WinActivate, Haiguslugu ahk_class ThunderRT6FormDC
		WinWaitActive, Haiguslugu ahk_class ThunderRT6FormDC,,1
		FiltreeriDokumendid("k")
		return

	ButLaboriTellimus:
		KlikiTellimuseNupule(3)
		return

	ButRadioloogiaTellimus:
		KlikiTellimuseNupule(1)
		return

	ButFunktsionaaldgn:
		KlikiTellimuseNupule(4)
		return

	ButPildipank:
		KlikiTellimuseNupule(11)
		return
}

KlikiTellimuseNupule(downRepeats) {
	WinActivate, Haiguslugu ahk_class ThunderRT6FormDC
	Sleep, 40
	SetControlDelay -1 ; muudab ControlClicki usaldusväärsemaks
	ControlClick, ThunderRT6CommandButton42, Haiguslugu ahk_class ThunderRT6FormDC,,,, NA
	Sleep,40
	Send,{Down %downRepeats%}
	Send,{Enter}
	return
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

FiltreeriDokumendid(selectionChar) {
	SetControlDelay -1
	; Kontrolli kas nimekiri on filtreeritud, kui on siis võta see maha
	ControlGet, filtered, Checked,, ThunderRT6CheckBox1, Haiguslugu ahk_class ThunderRT6FormDC
	if filtered {
		ControlClick, ThunderRT6CheckBox1, Haiguslugu ahk_class ThunderRT6FormDC,,,, NA
		Sleep, 100
	}

	; Filtreeri Kirjelduse järgi
	ControlClick, ThunderRT6CommandButton12, Haiguslugu ahk_class ThunderRT6FormDC,,,, NA
	Sleep, 40
	Send, {%selectionChar%}{Enter}
}

FindAndOpenDocument(doc, backupDoc = "") {
	if !WinExist("Haiguslugu") {
		TrayTip, Viga!, Ava kõigepealt haiguslugu
		return
	}

	WinActivate, Haiguslugu ahk_class ThunderRT6FormDC
	WinWaitActive, Haiguslugu ahk_class ThunderRT6FormDC,,1
	FiltreeriDokumendid("k")
	; wait until Filtered button is clicked	
	startTime := A_TickCount
	Loop {
		ControlGet, filteredChecked, Checked,, ThunderRT6CheckBox1, Haiguslugu ahk_class ThunderRT6FormDC
		if ((A_TickCount-startTime)>1000)
			break
		else
			Sleep, 40
	} Until (filteredChecked)
	if (!filteredChecked)
		return

	;WaitTextExist(searchText, click=40, clickCount=1, offsetX=0, nResult=1, maxTime=5000, inBrowser=1)
	if (!WaitTextExist(doc,200,,,,200,0)) {
		if (backupDoc != "") {
			if (!WaitTextExist(backupDoc,200,,,,0,0)) {
				TrayTip, Viga!, Ei leidnud pilti nimega %doc%
				return
			}
		}
	}
	if WinActive("Valimine tabelist ahk_class ThunderRT6FormDC") {
		ControlClick, ThunderRT6CommandButton7, Valimine tabelist ahk_class ThunderRT6FormDC,,,, NA ; Sulge "Valimine tabelist"
		Sleep, 100
	}
	ControlClick, ThunderRT6CommandButton33, Haiguslugu ahk_class ThunderRT6FormDC,,,, NA ; kliki Täpsemalt nupule

	WinWaitNotActive, ahk_id %winID%,,1
	if ErrorLevel
		return
	if WinActive("Haiguslugu ahk_class ThunderRT6FormDC") {
		ControlGetText, noBut, Button2, Haiguslugu ahk_class ThunderRT6FormDC
		if (noBut == "&No") {
			ControlClick, Button2, Haiguslugu ahk_class ThunderRT6FormDC,,,, NA
			Sleep, 100
		}
	}

	if WinActive("Valimine tabelist ahk_class ThunderRT6FormDC") {
		ControlClick, ThunderRT6CommandButton7, Valimine tabelist ahk_class ThunderRT6FormDC,,,, NA ; Sulge "Valimine tabelist"
		If WinExist("Kirjelduse sisestamine ahk_class ThunderRT6FormDC")
			WinActivate, Kirjelduse sisestamine ahk_class ThunderRT6FormDC
	}
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