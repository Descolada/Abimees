#NoEnv
#SingleInstance force
#NoTrayIcon
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
CoordMode, Mouse, Client ; koordinaadid relatiivselt akna suhtes
CoordMode, Pixel, Client 
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, 1000
SetTitleMatchMode, 2

#include <GlobalVariables>
#include <FindText>
#include <Clip>

global currentPage := "", JSUrl, JSFile
IniRead, JSUrl, %UserDataFolder%\abimees.ini, Tellimused, JSUrl, https://cdn.jsdelivr.net/gh/Descolada/Abimees@latest/Lib/Javascript/
IniRead, JSFile, %UserDataFolder%\abimees.ini, Tellimused, JSFile, TellimusedJS.js


DllCall( "RegisterShellHookWindow", UInt, A_ScriptHwnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage" )

if WinExist("Tellimused -") {
	WinActivate, Tellimused -
	WaitBrowserLoaded()
}

return

ShellMessage( wParam,lParam )	; Gets all Shell Hook Messages
{
	global JSFile
	if (wParam = 1) { ;  HSHELL_WINDOWCREATED := 1 ; Only act on Window Created Messages
		wId:= lParam							; wID is Window Handle
		WinGetTitle, wTitle, ahk_id %wId%		; wTitle is Window Title
		WinGetClass, wClass, ahk_id %wId%		; wClass is Window Class
		WinGet, wExe, ProcessName, ahk_id %wId%	; wExe is Window Execute

		WinGetTitle, activeTitle, A
		WinGet, activeExe, ProcessName, A
		if (InStr(activeTitle, "Edge") or InStr(activeTitle, "Internet") or InStr(activeTitle, "Chrome") or InStr(activeExe, "msedge")) {
			return  ; not used because all browsers activate on redraw not created
			if WaitBrowserLoaded() {
				WinGetTitle, activeTitle, A
				WinGet, activeId, ID, A
				TrayTip, Message, Browser loaded (new window) %activeTitle%
				if (InStr(activeTitle, "Tellimused -")) {
					if (StringCount(activeTitle, " - ") == 2)
						;SendJavascriptRaw("TellimusedJS.js")
						SendJavascript(JSFile)
				}
			}
		}
	} else if (wParam = 6) { ;  HSHELL_WINDOWREDRAW := 6
		Sleep, 200
		WinGetTitle, activeTitle, A
		WinGetClass, activeClass, A
		WinGet, activeExe, ProcessName, A
		if (InStr(activeTitle, "Edge") or InStr(activeTitle, "Internet") or InStr(activeTitle, "Chrome") or InStr(activeExe, "msedge")) {
			if WaitBrowserLoaded() {
				global browserName
				WinGetTitle, activeTitle, A
				WinGet, activeId, ID, A
				if (browserName == "IE11") {
					;TrayTip, Message, Navigating away from %activeTitle%
					;pwb := WBGet()
					;FileRead, code, %A_ScriptDir%\Lib\Javascript\TellimusedJS_test.js
					;pwb.document.parentWindow.execScript(code,"javascript")
					return
				}
				;TrayTip, Message, Browser loaded (redraw) %activeTitle%
				if (InStr(activeTitle, "Tellimused -")) {
					strCount := StringCount(activeTitle, "- ")
					;TrayTip, Message, Tiitlis %activeTitle% on tellimused %strCount% korda
					if (browserName == "Edge_virtual")
						dashCount := 1
					else
						dashCount := 2
					if (StringCount(activeTitle, "- ") == dashCount) {
						;SendJavascriptRaw("TellimusedJS.js")
						SendJavascript(JSFile)
						Sleep, 1000 ; Sleep to wait for browser title to change
					}
				}
			}
		}
	}
}

WBGet(WinTitle="ahk_class IEFrame", Svr#=1) {               ;// based on ComObjQuery docs
	static msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
        , IID := "{0002DF05-0000-0000-C000-000000000046}"   ;// IID_IWebBrowserApp
;//     , IID := "{332C4427-26CB-11D0-B483-00C04FD90119}"   ;// IID_IHTMLWindow2
	SendMessage msg, 0, 0, Internet Explorer_Server%Svr#%, %WinTitle%
	
	if (ErrorLevel != "FAIL") {
		lResult:=ErrorLevel, VarSetCapacity(GUID,16,0)
		if DllCall("ole32\CLSIDFromString", "wstr","{332C4425-26CB-11D0-B483-00C04FD90119}", "ptr",&GUID) >= 0 {
			DllCall("oleacc\ObjectFromLresult", "ptr",lResult, "ptr",&GUID, "ptr",0, "ptr*",pdoc)
			return ComObj(9,ComObjQuery(pdoc,IID,IID),1), ObjRelease(pdoc)
		}
	}
}

StringCount(str, match) {
	StringReplace, str, str, %match%, %match%, UseErrorLevel
	return ErrorLevel
}

SendJavascriptRaw(fileName) {
	FileRead, code, %A_ScriptDir%\Lib\Javascript\%fileName%
	SendInput, !d
	Sleep, 40
	SendInput, j
	Clip("avascript:" . code)
	ClipSaved := ClipboardAll ; save the entire clipboard to the variable ClipSaved
	Send, {Enter}
}

SendJavascript(fileName) {
	global browserName, JSUrl
	if (browserName == "Chrome") {
		SetKeyDelay, 10, -1
		SendInput, !d
		Sleep, 40
		SendInput, j
		Clip("avascript:$.getScript('" . JSUrl . fileName . "');")
		Send, {Enter}
	} else {
		SetKeyDelay, 100, 50
		Sleep, 200
		SendEvent, !d
		Sleep, 100
		SendEvent, j
		Clip("avascript:$.getScript('" . JSUrl . fileName . "');")
		Sleep, 100
		Send, {Enter}
		SetKeyDelay, 10, -1
	}
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
	if WaitTextExist("Reload", 0,,,,10000) {
		return 1
	}
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
