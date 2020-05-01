global DoubleClickTime := DllCall("GetDoubleClickTime", "UInt")
global ExperimentalMode := False
global AHKPath := A_ScriptDir . "\AutoHotkeyU32.exe"
global currentOsakond := "Does not yet exist"
global defaultOsakond
global visitedBrowsers := []
global browserName := "Edge"
global plugins := {}
global kiirlingid := {}
IniRead, output, %UserDataFolder%\abimees.ini, Plugins, Haiguslugu, 0
plugins.Haiguslugu := output
IniRead, output, %UserDataFolder%\abimees.ini, Plugins, Ester, 0
plugins.Ester := output
IniRead, output, %UserDataFolder%\abimees.ini, Plugins, LastViewed, 0
plugins.LastViewed := output
IniRead, output, %UserDataFolder%\abimees.ini, Plugins, Labor, 0
plugins.Labor := output
IniRead, output, %UserDataFolder%\abimees.ini, Plugins, Tellimused, 0
plugins.Tellimused := output

global ImageLibrary := {}
ImageLibrary["Ravipäevik"] := "|<>*127$53.y0081802V2000000124000000248t5SCCFIjU++W2WWeEXmZ4xwdMV8Z+++1Gd2F4IIIF5+4S8j7b2+8000E00008"
ImageLibrary["Anamnees"] := "|<>*127$50.40000000100000000c0000000+/7CmlllYH8+GmWWZ4WSYcjjYT8cd++20c+++GWWWa2WSYcb76U"
ImageLibrary["Epikriis"] := "|<>*127$61.y60M00q0BUNU00003000AM00001U006AnvDDaqRgv6PBgqPSAqrXBarvBi6PAlanP1arXBXNXNhanPNaqzVbqSTBanNk00M0A00002"
ImageLibrary["Etappepikriis"] := "|<>*127$71.z0000001g0P1UM000000M0030k000000k0061nntwSTBgvNzX0qPBanPlaqs6DgqPxar3BakAnNgq3Bj6P7UNanNgqPPAqrwNxwyDDanNgs0031U0M00008"
ImageLibrary["AvaTabel"] := "|<>*128$19.zzzzzzzzzw006003001U00k00M00A006003001U00k00M00A007zzz"
ImageLibrary["Unfilter"] := "|<>*143$21.zzzs00000000000E2030k7zzsknL33pkABQ0nr03nk0AQ03nk0GG00G002E00G003k4"
ImageLibrary.Edge := {}, ImageLibrary.Chrome := {}
ImageLibrary.Reload := "|<Chrome>*184$14.3wFzgsTM3y1z0zk0A0303s1q0MsQ7y0z2|<Edge>*160$14.C43Vlc6G0g0C01U0M0601k0o09U6C70z2|<IE11>*193$10.0U31yTtXA8k70w3MNzVsU"
ImageLibrary.Chrome["Reload"] := "|<Chrome>*184$14.3wFzgsTM3y1z0zk0A0303s1q0MsQ7y0z2"
ImageLibrary.Edge["Reload"] := "|<Edge>*160$14.C43Vlc6G0g0C01U0M0601k0o09U6C70z2"
ImageLibrary.IE11["Reload"] := "|<IE11>*193$10.0U31yTtXA8k70w3MNzVsU"
ImageLibrary.Edge_virtual["Reload"] := "|<>*153$16.D20QC3EAN0N00g03U0600M01U0700o02M0Mk31ks1y2"