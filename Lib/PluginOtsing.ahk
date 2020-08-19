CreateSearchBox() {
	SetWinDelay, -1

	WinGet, PID, PID, % "ahk_id " . owner:=WinExist() 
	WinGet, ownerExe, ProcessName, % "ahk_id " . owner:=WinExist()
	StringLower, ownerExe, ownerExe
	global abimeesStats, abimeesAmb, searchWidth, searchHeight

	if (ownerExe == "stats.exe")
		guiName := "StatsOtsing", abimeesStats.kirjeldusOtsing := {}, abimeesStats.kirjeldusOtsing.resetMoodul := 1
	else
		guiName := "AmbOtsing", abimeesAmb.kirjeldusOtsing := {}, abimeesAmb.kirjeldusOtsing.resetMoodul := 1

	searchWidth := 170
	searchHeight := 30
	global searchVar, searchText, searchPhrase, searchTotalFound, searchCurrentFound

	GUI, %guiName%:New, +ToolWindow +Owner%owner% +Hwndowned -SysMenu -Caption
	Gui, %guiName%:Add, Edit, r1
	Gui, %guiName%:Add, Button, Default gButOtsi x135 y5 w30 h22, Otsi
	Gui, %guiName%:Add, Text, vsearchVar x170 y10, 0/0
	Gui, %guiName%:Add, Button, gButPrev x200 y5 w10 h22, <
	Gui, %guiName%:Add, Button, gButNext x210 y5 w10 h22, >

	WinGetPos, x_win, y_win, w_win, h_win, Kirjelduse sisestamine
	adjust_x := x_win + 8
	adjust_y := y_win + h_win - 8
	GUI, %guiName%:Show, x%adjust_x% y%adjust_y% w%searchWidth% h%searchHeight%, Otsing

	if (ownerExe == "stats.exe")
		abimeesStats.kirjeldusOtsing.ownerAhkId := owner, abimeesStats.kirjeldusOtsing.ownedAhkId := owned
	else
		abimeesAmb.kirjeldusOtsing.ownerAhkId := owner, abimeesAmb.kirjeldusOtsing.ownedAhkId := owned

	return

	ButOtsi:
		global searchText, searchPhrase, searchTotalFound, searchCurrentFound, searchWidth, searchHeight
		exeName := (A_Gui == "StatsOtsing") ? "stats.exe" : "registr.exe"
		ControlGetText, searchText, ThunderRT6TextBox1, Kirjelduse sisestamine ahk_exe %exeName%
		GuiControlGet, searchPhrase,%A_Gui%:, Edit1
		if (searchPhrase = "") {
			searchTotalFound := 0
			searchCurrentFound := 0
			return
		}
		StringReplace, searchText, searchText, %searchPhrase%, %searchPhrase%, UseErrorLevel
		searchTotalFound := ErrorLevel
		new_window_w := searchWidth + 60
		if (searchTotalFound = 0) {
			searchCurrentFound := 0
			GuiControl,%A_Gui%:,searchVar, 0/0
			new_window_w := searchWidth + 30
			Gui, %A_Gui%:Show, w%new_window_w% h%searchHeight%
			return
		}
		GuiControl,%A_Gui%:,searchVar, 1/%searchTotalFound%
		Gui, %A_Gui%:Show, w%new_window_w% h%searchHeight%

		foundPos := InStr(searchText, searchPhrase,,,1)
		start := foundPos-1
		end := foundPos-1+StrLen(searchPhrase)
		ControlFocus, ThunderRT6TextBox1, Kirjelduse sisestamine ahk_exe %exeName%
		SendMessage, 0xB1, %start%, %end%, ThunderRT6TextBox1, Kirjelduse sisestamine ahk_exe %exeName% ; EM_SETSEL
		SendMessage, 0x00B7,,, ThunderRT6TextBox1, Kirjelduse sisestamine ahk_exe %exeName% ; EM_SCROLLCARET
		searchCurrentFound := 1
		return

	ButPrev:
		global searchText, searchPhrase, searchTotalFound, searchCurrentFound
		exeName := (A_Gui == "StatsOtsing") ? "stats.exe" : "registr.exe"
		if (searchTotalFound = 0)	
			return
		if (searchCurrentFound != 1)
			searchCurrentFound := searchCurrentFound - 1
		GuiControl,%A_Gui%:,searchVar, %searchCurrentFound%/%searchTotalFound%
		foundPos := InStr(searchText, searchPhrase,,,searchCurrentFound)
		start := foundPos-1
		end := foundPos-1+StrLen(searchPhrase)
		ControlFocus, ThunderRT6TextBox1, Kirjelduse sisestamine ahk_exe %exeName%
		SendMessage, 0xB1, %start%, %end%, ThunderRT6TextBox1, Kirjelduse sisestamine ahk_exe %exeName% ; EM_SETSEL
		SendMessage, 0x00B7,,, ThunderRT6TextBox1, Kirjelduse sisestamine ahk_exe %exeName% ; EM_SCROLLCARET
		return
	ButNext:
		global searchText, searchPhrase, searchTotalFound, searchCurrentFound
		exeName := (A_Gui == "StatsOtsing") ? "stats.exe" : "registr.exe"
		if (searchTotalFound = 0)	
			return
		if (searchCurrentFound != searchTotalFound)
			searchCurrentFound := searchCurrentFound + 1
		GuiControl,%A_Gui%:,searchVar, %searchCurrentFound%/%searchTotalFound%
		foundPos := InStr(searchText, searchPhrase,,,searchCurrentFound)
		start := foundPos-1
		end := foundPos-1+StrLen(searchPhrase)
		ControlFocus, ThunderRT6TextBox1, Kirjelduse sisestamine ahk_exe %exeName%
		SendMessage, 0xB1, %start%, %end%, ThunderRT6TextBox1, Kirjelduse sisestamine ahk_exe %exeName% ; EM_SETSEL
		SendMessage, 0x00B7,,, ThunderRT6TextBox1, Kirjelduse sisestamine ahk_exe %exeName% ; EM_SCROLLCARET
		return
}