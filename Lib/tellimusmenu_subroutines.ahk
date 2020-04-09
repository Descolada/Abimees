;MenuBiokeemiaKliiniline:
;	AvaLabor()
;	TelliKliiniline()
;	TelliBiokeemia()
;	global MenuSaadaTellimusChecked
;	if MenuSaadaTellimusChecked
;		SaadaLabor()
;	return

MenuTelli:
	global MenuSaadaTellimusChecked, Tellimused, SubmenuAeg
	AvaLabor()
	if (Tellimused.Kliiniline)[1]
		ValiAnaluusid("Kliiniline", ["Hematoloogia"], Tellimused.Kliiniline)
	if (Tellimused.Biokeemia)[1]
		ValiAnaluusid("Biokeemia", ["KliinilineKeemia","Biokeemia"], Tellimused.Biokeemia)
	if (Tellimused.Molekulaar)[1] {
		molekulaarNinakaabe := [], molekulaarVeri := [], molekulaarCOVID := []
		for i,e in (Tellimused.Molekulaar) {	
			if ("Ninakaabe" in e)
				molekulaarKurgukaabe.Push(((Tellimused.Shorthands)[e])*)
			else if ("Verest" in e)
				molekulaarVeri.Push(((Tellimused.Shorthands)[e])*)
			else if ("COVID" in e)
				molekulaarCOVID.Push(((Tellimused.Shorthands)[e])*)
		}
		if molekulaarNinakaabe[1]
			ValiAnaluusid("Molekulaar_Ninakaabe", ["Molekulaar", "Molekulaar_Kurgukaabe"], molekulaarNinakaabe, [0,7])
		if molekulaarVeri[1]
			ValiAnaluusid("Molekulaar_Taisveri", ["Molekulaar", "Molekulaar_Taisveri"], molekulaarVeri, [0,7])
		if molekulaarCOVID[1]
			ValiAnaluusid("Molekulaar_COVID", ["Molekulaar", "Molekulaar_COVID"], molekulaarCOVID, [0,7])
	}
	if (Tellimused.Mikrobioloogia)[1] {
		mikrobioloogiaVeri := [], mikrobioloogiaUriin := []
		for i,e in (Tellimused.Mikrobioloogia) {	
			if ("Vere" in e)
				mikrobioloogiaVeri.Push(((Tellimused.Shorthands)[e])*)
			else if ("Uriini" in e)
				mikrobioloogiaUriin.Push(((Tellimused.Shorthands)[e])*)
		}
		if mikrobioloogiaVeri[1]
			ValiAnaluusid("Mikro_Veri", ["Mikro", "Mikro_Veri"], mikrobioloogiaVeri)
		if mikrobioloogiaUriin[1]
			ValiAnaluusid("Mikro_Uriin", ["Mikro", "Mikro_Uriin"], mikrobioloogiaUriin)
	}
	if (Tellimused.UriinRoe)[1]
		ValiAnaluusid("UriinRoe", ["UriinRoe"], Tellimused.UriinRoe)

	
	if (SubmenuAeg != -1)
		SaadaLabor()

	TellimusedClearAll()
	return

TellimusedClearAll() {
	global TellimusteNimekiri
	CheckMenuItemList("MyMenu", ["Kliiniline","Biokeemia","Uriin ja roe","Molekulaardiagnostika","Mikrobioloogia"], "Uncheck")
	for i,e in ["Kliiniline","Biokeemia","UriinRoe","Molekulaar","Mikrobioloogia"] 
		for k,el in TellimusteNimekiri[e] {
			if k is digit
				Menu, Submenu%e%, Uncheck, %el%
			else 
				Menu, Submenu%e%, Uncheck, %k%
		}
	return
}

PaneelSepsis:
	global Tellimused
	Tellimused.Molekulaar := ["Ninakaabe gripile","Ninakaabe respiratoorsetele viirustele","Verest sepsisepaneel"]
	Tellimused.Mikrobioloogia := ["Verekülv bakteritele","Verekülv Candidale","Uriinikülv (keskjoa) bakteritele","Uriinikülv (keskjoa) Candidale"]
	CheckMenuItemList("SubmenuMolekulaar", Tellimused.Molekulaar)
	CheckMenuItemList("SubmenuMikrobioloogia", Tellimused.Mikrobioloogia)
	Menu, MyMenu, Check, Molekulaardiagnostika
	Menu, MyMenu, Check, Mikrobioloogia
	Menu, MyMenu, Show, 5, 55
	return

PaneelVereulekanne:
	global Tellimused
	Tellimused.Kliiniline := ["CBC-5Diff"]
	Tellimused.UriinRoe := ["U-strip"]
	CheckMenuItemList("SubmenuKliiniline", ["CBC","CBC-5Diff","CBC-5Diff-RET"],"Uncheck")
	CheckMenuItemList("SubmenuKliiniline", Tellimused.Kliiniline)
	Menu, MyMenu, Check, Kliiniline
	CheckMenuItemList("SubmenuUriinRoe", Tellimused.UriinRoe)
	Menu, MyMenu, Check, Uriin ja roe
	Menu, MyMenu, Show, 5, 55
	return

PaneelKurgukaabeViirusedBakterid:
	return

PaneelKurgukaabeViirusedCOVID19:
	return

KliinilineItemClicked:
	global Tellimused
	Menu, SubmenuKliiniline, Uncheck, CBC
	Menu, SubmenuKliiniline, Uncheck, CBC-5Diff
	Menu, SubmenuKliiniline, Uncheck, CBC-5Diff-RET
	switch A_ThisMenuItem {
		case "CBC":
			if (A_ThisMenuItem != (Tellimused.Kliiniline)[1]) {
				Menu, SubmenuKliiniline, Check, CBC
				(Tellimused.Kliiniline)[1] := A_ThisMenuItem
			} else {
				(Tellimused.Kliiniline).RemoveAt(1)
			}
		case "CBC-5Diff":
			if (A_ThisMenuItem != (Tellimused.Kliiniline)[1]) {
				Menu, SubmenuKliiniline, Check, CBC-5Diff
				(Tellimused.Kliiniline)[1] := A_ThisMenuItem
			} else {
				(Tellimused.Kliiniline).RemoveAt(1)
			}
		case "CBC-5Diff-RET":
			if (A_ThisMenuItem != (Tellimused.Kliiniline)[1]) {
				Menu, SubmenuKliiniline, Check, CBC-5Diff-RET
				(Tellimused.Kliiniline)[1] := A_ThisMenuItem
			} else {
				(Tellimused.Kliiniline).RemoveAt(1)
			}
	}
	if ((Tellimused.Kliiniline)[1] == "")
		Menu, MyMenu, Uncheck, Kliiniline
	else 
		Menu, MyMenu, Check, Kliiniline
	Menu, MyMenu, Show, 5, 55
	return

CheckMenuItemList(menuName, itemList, check := "Check") {
	for i,e in itemList {
		Menu, %menuName%, %check%, %e% 
	}
}

BiokeemiaItemClicked:
	global Tellimused
	switch A_ThisMenuItem {
		case "CHEM-3":
			Tellimused.Biokeemia := ["Na","K","CRP"]
			CheckMenuItemList("SubmenuBiokeemia", Tellimused.Biokeemia)
		case "CHEM-5":
			Tellimused.Biokeemia := ["Na","K","Krea","Urea","CRP"]
			CheckMenuItemList("SubmenuBiokeemia", Tellimused.Biokeemia)
		case "CHEM-8":
			Tellimused.Biokeemia := ["Na","K","Krea","Urea","CRP","Bil","ASAT","ALAT"]
			CheckMenuItemList("SubmenuBiokeemia", Tellimused.Biokeemia)
		case "CHEM-13":
			Tellimused.Biokeemia := ["Na","K","Krea","Urea","CRP","Bil","ASAT","ALAT","ALP","LDH","UA"]
			CheckMenuItemList("SubmenuBiokeemia", Tellimused.Biokeemia)
		default:
			bLen := (Tellimused.Biokeemia).MaxIndex()
			for i,e in (Tellimused.Biokeemia) {
				if (e == A_ThisMenuItem) {
					(Tellimused.Biokeemia).RemoveAt(i)
					Menu, SubmenuBiokeemia, Uncheck, %A_ThisMenuItem%
				}	
			}
			if ((Tellimused.Biokeemia).MaxIndex() == bLen) {
				(Tellimused.Biokeemia).Push(A_ThisMenuItem)
				Menu, SubmenuBiokeemia, Check, %A_ThisMenuItem%
			}	
	}
	if (!(Tellimused.Biokeemia)[1]) {
		Menu, MyMenu, Uncheck, Biokeemia
	} else {
		Menu, MyMenu, Check, Biokeemia
	}
	Menu, MyMenu, Show, 5, 55
	return

ItemClickedRoutine(shorthand, fullName) {
	global Tellimused
	bLen := (Tellimused[shorthand]).MaxIndex()
	for i,e in (Tellimused[shorthand]) {
		if (e == A_ThisMenuItem) {
			(Tellimused[shorthand]).RemoveAt(i)
			Menu, Submenu%shorthand%, Uncheck, %A_ThisMenuItem%
		}	
	}
	if ((Tellimused[shorthand]).MaxIndex() == bLen) {
		(Tellimused[shorthand]).Push(A_ThisMenuItem)
		Menu, Submenu%shorthand%, Check, %A_ThisMenuItem%
	}	
	if (!(Tellimused[shorthand])[1]) {
		Menu, MyMenu, Uncheck, %fullName%
	} else {
		Menu, MyMenu, Check, %fullName%
	}
	Menu, MyMenu, Show, 5, 55
	return
}

MolekulaarItemClicked:
	ItemClickedRoutine("Molekulaar", "Molekulaardiagnostika")
	return

MikrobioloogiaItemClicked:
	ItemClickedRoutine("Mikrobioloogia", "Mikrobioloogia")
	return

UriinRoeItemClicked:
	ItemClickedRoutine("UriinRoe","Uriin ja roe")
	return

CheckKliinilineBiokeemia(kliiniline, biokeemia) {
	global Tellimused, TellimusteNimekiri
	Tellimused.Kliiniline := kliiniline, Tellimused.Biokeemia := biokeemia
	CheckMenuItemList("SubmenuKliiniline", ["CBC","CBC-5Diff","CBC-5Diff-RET"], "Uncheck")
	CheckMenuItemList("SubmenuBiokeemia", TellimusteNimekiri.Biokeemia, "Uncheck")
	CheckMenuItemList("SubmenuKliiniline", kliiniline)
	Menu, MyMenu, Check, Kliiniline
	CheckMenuItemList("SubmenuBiokeemia", Tellimused.Biokeemia)
	Menu, MyMenu, Check, Biokeemia
	Menu, MyMenu, Show, 5, 55
}

MenuBiokeemiaKliiniline:
	CheckKliinilineBiokeemia(["CBC-5Diff"], ["Na","K","Krea","Urea","CRP"])
	return

MenuHematoloogia3:
	CheckKliinilineBiokeemia(["CBC-5Diff"], ["Na","K","CRP"])
	return

MenuHematoloogia5:
	CheckKliinilineBiokeemia(["CBC-5Diff"], ["Na","K","Krea","ALAT","CRP"])
	return

MenuHematoloogia7:
	CheckKliinilineBiokeemia(["CBC-5Diff"], ["Na","K","Krea","ALAT","ASAT","Bil","CRP"])
	return

BiokeemiaUncheckAll:
	global TellimusteNimekiri
	CheckMenuItemList("SubmenuBiokeemia", TellimusteNimekiri.Biokeemia, "Uncheck")
	Menu, MyMenu, Uncheck, Biokeemia
	Menu, MyMenu, Show, 5, 55
	return

Submenu0p:
	global SubmenuAeg
	if (SubmenuAeg == 0) {
		SubmenuAeg := -1
		Menu, MySubmenu, Uncheck, Täna
		Menu, MyMenu, Uncheck, Saada tellimus automaatselt
	} else {
		SubmenuAeg := 0
		CheckMenuItemList("MySubmenu", ["Homme", "Ülehomme", "3 päeva pärast"], "Uncheck")
		Menu, MySubmenu, Check, Täna
		Menu, MyMenu, Check, Saada tellimus automaatselt
	}
	Menu, MyMenu, Show, 5, 55
	return
Submenu1p:
	global SubmenuAeg
	if (SubmenuAeg == 1) {
		SubmenuAeg := -1
		Menu, MySubmenu, Uncheck, Homme
		Menu, MyMenu, Uncheck, Saada tellimus automaatselt
	} else {
		SubmenuAeg := 1
		CheckMenuItemList("MySubmenu", ["Täna", "Ülehomme", "3 päeva pärast"], "Uncheck")
		Menu, MySubmenu, Check, Homme
		Menu, MyMenu, Check, Saada tellimus automaatselt
	}
	Menu, MyMenu, Show, 5, 55
	return
Submenu2p:
	global SubmenuAeg
	if (SubmenuAeg == 2) {
		SubmenuAeg := -1
		Menu, MySubmenu, Uncheck, Ülehomme
		Menu, MyMenu, Uncheck, Saada tellimus automaatselt
	} else {
		SubmenuAeg := 2
		CheckMenuItemList("MySubmenu", ["Täna", "Homme", "3 päeva pärast"], "Uncheck")
		Menu, MySubmenu, Check, Ülehomme
		Menu, MyMenu, Check, Saada tellimus automaatselt
	}
	Menu, MyMenu, Show, 5, 55
	return
Submenu3p:
	global SubmenuAeg
	if (SubmenuAeg == 3) {
		SubmenuAeg := -1
		Menu, MySubmenu, Uncheck, 3 päeva pärast
		Menu, MyMenu, Uncheck, Saada tellimus automaatselt
	} else {
		SubmenuAeg := 3
		CheckMenuItemList("MySubmenu", ["Täna", "Homme", "Ülehomme"], "Uncheck")
		Menu, MySubmenu, Check, 3 päeva pärast
		Menu, MyMenu, Check, Saada tellimus automaatselt
	}
	Menu, MyMenu, Show, 5, 55
	return

SubmenuTruki:
	global SubmenuTruki
	if (SubmenuTruki == 1) 
		Menu, MySubmenu, Uncheck, Trüki kõik
	else
		Menu, MySubmenu, Check, Trüki kõik
	SubmenuTruki := SubmenuTruki ? 0 : 1
	Menu, MyMenu, Show, 5, 55
	return