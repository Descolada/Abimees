#NoEnv
#SingleInstance force
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Hotstring C R
#Hotstring EndChars `n `t  ; TAB, SPACE, ja ENTER kutsuvad ainult kiirklahvid esile
#MaxHotkeysPerInterval 150
SetTitleMatchMode, 2
#InstallKeybdHook 
#UseHook On

Coordmode, Caret, Screen
Coordmode, Tooltip, Screen

global UserDataRoot := "Y:\UserData"
global UserDataFolder := "Y:\UserData\Abimees"  ; Kui seda muuta siis peab muutma ka kõige viimast rida (#include kiirklahvid)
global Autosuggest
IniRead, Autosuggest, %UserDataFolder%\abimees.ini, Kiirklahvid, Autosuggest, 0

if (!FileExist(UserDataRoot)) {
	FileCreateDir, %UserDataRoot%
	FileSetAttrib, +H, %UserDataRoot%
	FileCreateDir, %UserDataFolder%
} else {
	if (!FileExist(UserDataFolder)) 
		FileCreateDir, %UserDataFolder%
}

if (!FileExist(UserDataFolder . "\abimees.ini"))
	if (FileExist(A_ScriptDir . "\Lib\abimees.template.ini"))
		FileCopy, %A_ScriptDir%\Lib\abimees.template.ini, %UserDataFolder%\abimees.ini

if (!FileExist(UserDataFolder "\kiirklahvid.ahk")) {
	if (FileExist(A_ScriptDir . "\Lib\kiirklahvid.template.ahk")) {
		FileCopy, %A_ScriptDir%\Lib\kiirklahvid.template.ahk, %UserDataFolder%\kiirklahvid.ahk
		Reload
	}
}

;#NoTrayIcon  ; Eemalda kommentaar kui ei soovi ikooni
Menu, Tray, Icon, %A_ScriptDir%\Resources\keyboard.ico
Menu, Tray, Tip, Kiirklahvid
Menu, Tray, NoMainWindow

Menu, Tray, NoStandard
Menu, Tray, DeleteAll
Menu, Tray, Add, Redigeeri kiirklahve, TrayKiirklahvid
Menu, Tray, Add, Näita kirjutades soovitusi, TrayAutosuggest
if (Autosuggest)
	Menu, Tray, Check, Näita kirjutades soovitusi
Menu, Tray, Add, Taaskäivita, TrayRestart
Menu, Tray, Add, Sulge, TrayExit

global TooltipGuiHwnd, flagAllSelected := false

Loop, Read, Y:\UserData\Abimees\kiirklahvid.ahk 
   If RegExMatch(A_LoopReadLine,"^\s*:.*?:(.*)", line) {  ; gathers the hotstrings
		buf := StrSplit(line1, "::")
;hs.= line1 "`n"
		hs .= buf[1] . "`n"
	}



Loop { 
	Input, out,B V L1, {BS}
	ToolTip
	if (WinExist("ahk_id " . TooltipGuiHwnd)) {
		GUI, Main:Destroy
	}
	If InStr(ErrorLevel, "EndKey") {
		if (flagAllSelected)
			str := ""
		StringTrimRight, str, str, 1
		if (str == "") {
			continue
		} 
	}
	flagAllSelected := false
	;if out in ,,,`t,`n, ,?,!        ; hotstring delimiters
	if (HasVal(["", ",", "`t", "`n", " ", "?", "!"], out) && !InStr(ErrorLevel, "EndKey")) {
		ToolTip % str:= ""
		if (WinExist("ahk_id " . TooltipGuiHwnd)) {
			GUI, Main:Destroy
		}
	} else {
		if (RegexMatch(out, "[0-9]") && str != "") {
			outNum := out + 0
			if (outNum > 0 && outNum <= buf.MaxIndex()) {
				selected := buf[outNum]
				if (SubStr(selected, 1, StrLen(str)) == str) {		
					StringTrimLeft, remainder, selected, % StrLen(str)
					;MsgBox, %selected% %remainder% %str%
					SendLevel, 1
					SendEvent, {BackSpace}%remainder%{Space}
					SendLevel, 0
					Sleep, 200
					str := ""
					continue
				}
			}
		}
		matches := RegExReplace(hs,"m`a)^(?!\Q" (str.= out) "\E).*\n" )
		
		buf := StrSplit(matches, "`n")
		Loop, % vNum := buf.Length()
		{
			if !buf[vNum]
				buf.RemoveAt(vNum)
			vNum--
		}
		if (!buf or buf[1] == "")
			continue
		;MsgBox, % buf[1]
		newbuf := ""
		for i,e in buf {
			if (i > 5 or e == "")
				break
			newbuf .= i . ": " . e . "`n"
		}
		if (buf.MaxIndex() > 5) 
			newbuf .= "... ning veel " . (buf.MaxIndex() - 5) . " kiirklahvi"

		;CreateTooltipGui(buf, 5)
		if (Autosuggest)
			ToolTip, % newbuf, % A_CaretX, % A_CaretY + 15
	}
}

TrayKiirklahvid:
	global UserDataFolder
	Run C:\Windows\Notepad.exe "%UserDataFolder%\kiirklahvid.ahk"
	return
	
TrayAutosuggest:
	TrayAutosuggestCheckUncheck("Tray", "Näita kirjutades soovitusi")
	return

TrayExit:
	ExitApp
	return

TrayRestart:
	Reload
	return

TrayAutosuggestCheckUncheck(trayName, menuName) {
	global UserDataFolder, Autosuggest
	if (Autosuggest) {
		Menu, %trayName%, Uncheck, %menuName%
		Autosuggest := 0
		IniWrite, 0, %UserDataFolder%\abimees.ini, Kiirklahvid, Autosuggest
	} else {
		Menu, %trayName%, Check, %menuName%
		Autosuggest := 1
		IniWrite, 1, %UserDataFolder%\abimees.ini, Kiirklahvid, Autosuggest
	}
}

HasVal(haystack, needle) {
	if !(IsObject(haystack)) || (haystack.Length() = 0)
		return 0
	for index, value in haystack
		if (value = needle)
			return index
	return 0
}

CreateTooltipGui(listElementsArray, listMax) {
	window_w := 100
	Coordmode, Caret, Screen
	x_coord := A_CaretX
	y_coord := A_CaretY + 15
	static LBHotstringSuggest

	GUI, Main:New, +ToolWindow +Hwndowned +AlwaysOnTop -Caption

	LBContent := ""
	for i,e in listElementsArray {
		LBContent .= i . ": " . e . "|"
		if (i > listMax or e == "")
			break
	}
	if (listElementsArray.MaxIndex() > listMax)
		LBContent .= "... ning veel " . (listElementsArray.MaxIndex() - listMax) . " kiirklahvi"
	else
		LBContent := RTrim(LBContent, "|")
	
	window_r := (listElementsArray.MaxIndex() > listMax) ? listMax : listElementsArray.MaxIndex()

	Gui, Main:Add, ListBox, x0 y0 w%window_w% r%window_r% gLBHotstringSuggest vLBHotstringSuggest, %LBContent%
	GuiControlGet, posHotstringSuggest, Pos, LBHotstringSuggest
	GUI, Main:Show, x%x_coord% y%y_coord% w%window_w% h%posHotstringSuggestH% NoActivate, Võimalikud kiirklahvid
	
	global TooltipGuiHwnd := owned
}

JoinArray(strArray, delimiter := ", ")
{
  s := ""
  for i,v in strArray
    s .= delimiter . v
  return substr(s, 3)
}

LBHotstringSuggest:
	return

RemoveToolTip:
	if (WinExist("ahk_id " . TooltipGuiHwnd)) {
		GUI, Main:Destroy
	}	
	ToolTip
	return
	
~^+r::
	Reload
	return

~^a::
	global flagAllSelected
	flagAllSelected := true
	return
	
~LButton::
~RButton::
~MButton::
	global str := "", out := ""
	ToolTip
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
