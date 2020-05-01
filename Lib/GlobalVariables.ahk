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
ImageLibrary.Chrome["ValiBlankett"] := "|<>*146$67.UU2EE800E00EE108400808YE0U4200404GMwY5mDDYnbR8WG398aGW+8cF914YG9Vt4IF4UWIF4l0WA4WEG98WIEF63l8C4wWFDAo"
ImageLibrary.Edge["ValiBlankett"] := "|<>*174$65.VUBUUk0100120E11U0206OA0U2200A0AYFt8DYSyPCztaKEN9BogaWONhUWoH9XtAsnH158YH46MlgY6OH8hAAV1tg7aynHDRo"
ImageLibrary.Chrome["Pildipank"] := "|<>*122$51.0000000000EE00100D+2U008014EE001008eSj7D9015IJ455E0D+Wcbcg011IJ555E08+Wcccd011Hpsx540000800004"
ImageLibrary.Edge["Pildipank"] := "|<>*158$42.088000Mxc9000Ma88000MbdtSCSPbd9N3PSxf9NDHQVf9NPHQVd9PHHOVdtSDHN000M000000M000U"
ImageLibrary.Chrome["Otsi"] := "|<>*144$21.0000000TA0SBU0ljDSBX3lgSSBVvlg3Psvn0004"
ImageLibrary.Edge["Otsi"] := "|<>*148$21.D60PAk0kzjS6n3kqSS6lvNa3NsznU"
ImageLibrary.Chrome["LisaUuring"] := "|<>*144$61.00000000000000000000AA00000300600000000033DD1anOrlxVg0knNjPBakrXsNgqBanMNvAAqP6nNgABa6PBXNgrqwT1wylgns000000000B"
ImageLibrary.Edge["LisaUuring"] := "|<>*150$60.kk00000A00k000000000knrkPArhwTkq0kPArhankrXkPAqBanknykPAqBankkykPAqBanyrbkTDqBaT0000000006000000000yU"
ImageLibrary.Chrome["Tellimused1kuu"] := "|<>*127$24.0800E800k800E9FFE+FFEAFFE+FFE9FFs8jDU"
ImageLibrary.Edge["Tellimused1kuu"] := "|<>*139$25.8400Q20021B990gYYUQGGE+9984YYy2Pns"
ImageLibrary.Reload := "|<Chrome>*184$14.3wFzgsTM3y1z0zk0A0303s1q0MsQ7y0z2|<Edge>*160$14.C43Vlc6G0g0C01U0M0601k0o09U6C70z2|<IE11>*193$10.0U31yTtXA8k70w3MNzVsU"
ImageLibrary.Chrome["Reload"] := "|<Chrome>*184$14.3wFzgsTM3y1z0zk0A0303s1q0MsQ7y0z2"
ImageLibrary.Edge["Reload"] := "|<Edge>*160$14.C43Vlc6G0g0C01U0M0601k0o09U6C70z2"
ImageLibrary.IE11["Reload"] := "|<IE11>*193$10.0U31yTtXA8k70w3MNzVsU"
ImageLibrary.Edge_virtual["Reload"] := "|<>*153$16.D20QC3EAN0N00g03U0600M01U0700o02M0Mk31ks1y2"