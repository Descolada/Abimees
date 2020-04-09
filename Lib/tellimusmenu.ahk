Menu, SubmenuKliiniline, Add, CBC, KliinilineItemClicked, +Radio
Menu, SubmenuKliiniline, Add, CBC-5Diff, KliinilineItemClicked, +Radio
Menu, SubmenuKliiniline, Add, CBC-5Diff-RET, KliinilineItemClicked, +Radio

Menu, SubmenuBiokeemia, Add, CHEM-3, BiokeemiaItemClicked
Menu, SubmenuBiokeemia, Add, CHEM-5, BiokeemiaItemClicked
Menu, SubmenuBiokeemia, Add, CHEM-8, BiokeemiaItemClicked
Menu, SubmenuBiokeemia, Add, CHEM-13, BiokeemiaItemClicked
Menu, SubmenuBiokeemia, Add
for i,e in TellimusteNimekiri.Biokeemia
	Menu, SubmenuBiokeemia, Add, %e%, BiokeemiaItemClicked
Menu, SubmenuBiokeemia, Add
Menu, SubmenuBiokeemia, Add, Eemalda kõik valikud, BiokeemiaUncheckAll

Menu, MySubmenu, Add, Täna, Submenu0p, +Radio
Menu, MySubmenu, Add, Homme, Submenu1p, +Radio
if (SubmenuAeg == 1)
	Menu, MySubmenu, Check, Homme
Menu, MySubmenu, Add, Ülehomme, Submenu2p, +Radio
Menu, MySubmenu, Add, 3 päeva pärast, Submenu3p, +Radio
Menu, MySubmenu, Add
Menu, MySubmenu, Add, Trüki kõik, SubmenuTruki
if (SubmenuTruki == 1)
	Menu, MySubmenu, Check, Trüki kõik

for i,e in ["Mikrobioloogia","Molekulaar","UriinRoe"] {
	for k,el in TellimusteNimekiri[e] {
		if k is digit
			Menu, Submenu%e%, Add, %el%, %e%ItemClicked
		else {
			Menu, Submenu%e%, Add, %k%, %e%ItemClicked
			(Tellimused.Shorthands)[k] := el
		}
	}
}

;Menu, SubmenuMikrobioloogia, Add, Verekülv bakteritele, MikrobioloogiaItemClicked
;Menu, SubmenuMikrobioloogia, Add, Verekülv Candidale, MikrobioloogiaItemClicked
;Menu, SubmenuMikrobioloogia, Add, Uriinikülv (keskjoa) bakteritele, MikrobioloogiaItemClicked
;Menu, SubmenuMikrobioloogia, Add, Uriinikülv (keskjoa) Candidale, MikrobioloogiaItemClicked
;Menu, SubmenuMikrobioloogia, Add, Uriinikülv (kateeter) bakteritele, MikrobioloogiaItemClicked
;Menu, SubmenuMikrobioloogia, Add, Uriinikülv (kateeter) Candidale, MikrobioloogiaItemClicked
;(Tellimused.Shorthands)["Verekülv bakteritele"] := ["Aer","Anaer"]
;(Tellimused.Shorthands)["Verekülv Candidale"] := ["Candida"]
;(Tellimused.Shorthands)["Uriinikülv (keskjoa) bakteritele"] := ["BaktKeskjoa"]
;(Tellimused.Shorthands)["Uriinikülv (keskjoa) Candidale"] := ["CandidaKeskjoa"]
;(Tellimused.Shorthands)["Uriinikülv (kateeter) bakteritele"] := ["BaktKateeter"]
;(Tellimused.Shorthands)["Uriinikülv (kateeter) Candidale"] := ["CandidaKateeter"]

;Menu, SubmenuMolekulaar, Add, Ninakaabe gripile, MolekulaarItemClicked
;Menu, SubmenuMolekulaar, Add, Ninakaabe respiratoorsetele viirustele, MolekulaarItemClicked
;Menu, SubmenuMolekulaar, Add, Ninakaabe bakteritele, MolekulaarItemClicked
;Menu, SubmenuMolekulaar, Add, COVID-19, MolekulaarItemClicked
;Menu, SubmenuMolekulaar, Add, Verest sepsisepaneel, MolekulaarItemClicked
;(Tellimused.Shorthands)["Ninakaabe gripile"] := ["Gripp"]
;(Tellimused.Shorthands)["Ninakaabe respiratoorsetele viirustele"] := ["Viirused"]
;(Tellimused.Shorthands)["Ninakaabe bakteritele"] := ["Bakterid"]
;(Tellimused.Shorthands)["COVID-19"] := ["COVID"]
;(Tellimused.Shorthands)["Verest sepsisepaneel"] := ["Sepsis"]

;Menu, SubmenuUriinRoe, Add, U-strip, UriinRoeItemClicked
;Menu, SubmenuUriinRoe, Add, Peitveri, UriinRoeItemClicked
;(Tellimused.Shorthands)["U-strip"] := ["U-strip"]
;(Tellimused.Shorthands)["Peitveri"] := ["Peitveri"]

Menu, PaneelSubmenuKurgukaabe, Add, Viirused+bakterid, PaneelKurgukaabeViirusedBakterid
Menu, PaneelSubmenuKurgukaabe, Add, Viirused+COVID-19, PaneelKurgukaabeViirusedCOVID19

Menu, PaneelSubmenu, Add, Sepsis, PaneelSepsis
Menu, PaneelSubmenu, Add, Vereülekanne, PaneelVereulekanne
Menu, PaneelSubmenu, Add, Kurgukaabe, :PaneelSubmenuKurgukaabe

Menu, MyMenu, Add, Kliiniline, :SubmenuKliiniline
Menu, MyMenu, Add, Biokeemia, :SubmenuBiokeemia
Menu, MyMenu, Add, Mikrobioloogia, :SubmenuMikrobioloogia
Menu, MyMenu, Add, Molekulaardiagnostika, :SubmenuMolekulaar
Menu, MyMenu, Add, Uriin ja roe, :SubmenuUriinRoe
Menu, MyMenu, Add, CBC-5Diff + CHEM-5, MenuBiokeemiaKliiniline
Menu, MyMenu, Add, Hematoloogia-3, MenuHematoloogia3
Menu, MyMenu, Add, Hematoloogia-5, MenuHematoloogia5
Menu, MyMenu, Add, Hematoloogia-7, MenuHematoloogia7
Menu, MyMenu, Add, Paneelid, :PaneelSubmenu
Menu, MyMenu, Add
Menu, MyMenu, Add, Saada tellimus automaatselt, :MySubmenu
if (SubmenuAeg == 1)
	Menu, MyMenu, Check, Saada tellimus automaatselt
Menu, MyMenu, Add
Menu, MyMenu, Add, Telli valitud, MenuTelli