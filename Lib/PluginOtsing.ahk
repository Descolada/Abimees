CreateSearchBox() {
	WinActivate, Kirjelduse sisestamine
	SetWinDelay, -1

	WinGet, PID, PID, % "ahk_id " . owner:=WinExist() 

	window_w := 170
	window_h := 30
	global searchVar, searchText, searchPhrase, searchTotalFound, searchCurrentFound

	GUI, Otsing:New, +ToolWindow +Owner%owner% +Hwndowned -SysMenu -Caption
	Gui, Otsing:Add, Edit, r1
	Gui, Otsing:Add, Button, Default gButOtsi x135 y5 w30 h22, Otsi
	Gui, Otsing:Add, Text, vsearchVar x170 y10, 0/0
	Gui, Otsing:Add, Button, gButPrev x200 y5 w10 h22, <
	Gui, Otsing:Add, Button, gButNext x210 y5 w10 h22, >

	WinGetPos, x_win, y_win, w_win, h_win, Kirjelduse sisestamine
	adjust_x := x_win + 8
	adjust_y := y_win + h_win - 8
	GUI, Otsing:Show, x%adjust_x% y%adjust_y% w%window_w% h%window_h%, Otsing

	global resetOtsing = 1
	OnLocationChangeMonitorOtsing(owner, owned, PID) ; INIT

	WinWaitClose % "ahk_id " . owner ; ... or until the owner window does not exist

	Gui, Otsing:Destroy
	return

	ButOtsi:
		global searchText, searchPhrase, searchTotalFound, searchCurrentFound
		ControlGetText, searchText, ThunderRT6TextBox1, Kirjelduse sisestamine
		GuiControlGet, searchPhrase,Otsing:, Edit1
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
			GuiControl,Otsing:,searchVar, 0/0
			new_window_w := window_w + 30
			Gui, Otsing:Show, w%new_window_w% h%window_h%
			return
		}
		GuiControl,Otsing:,searchVar, 1/%searchTotalFound%
		Gui, Otsing:Show, w%new_window_w% h%window_h%

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
		GuiControl,Otsing:,searchVar, %searchCurrentFound%/%searchTotalFound%
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
		GuiControl,Otsing:,searchVar, %searchCurrentFound%/%searchTotalFound%
		foundPos := InStr(searchText, searchPhrase,,,searchCurrentFound)
		start := foundPos-1
		end := foundPos-1+StrLen(searchPhrase)
		ControlFocus, ThunderRT6TextBox1, Kirjelduse sisestamine
		SendMessage, 0xB1, %start%, %end%, ThunderRT6TextBox1, Kirjelduse sisestamine ; EM_SETSEL
		SendMessage, 0x00B7,,, ThunderRT6TextBox1, Kirjelduse sisestamine ; EM_SCROLLCARET
		return
}