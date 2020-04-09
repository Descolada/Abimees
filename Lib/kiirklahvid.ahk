; Kiirklahvide kirjutamine
; ::tekst::See on minu tekst   -> kirjutades "tekst" ja vajutades tühikut/enterit asendatakse "tekst" lausega "See on minu tekst"
; :*:  alguse korral asendatakse tekst koheselt, ei pea vajutama tühikut/enterit
; Mitme paragrahviga teksti saab kirjutada kui ümbritseda see sulgudega
; :r0:  alguse korral saab sisestada lisaklahve, näiteks liigutada kursorit mingi arvu võrra vasakule

::.ak::arst-resident Jakob Prii, D09005
::.vak::valvearst Jakob Prii, D09005

::.uus::
	FormatTime, CurrentDateTime,, dd.MM.yy kl HH:mm
	Send %CurrentDateTime%{ENTER}
	return

::.kp::
	FormatTime, CurrentDateTime,, dd.MM.yy
	Send %CurrentDateTime%{ENTER}
	return

::.konsult::
	FormatTime, CurrentDateTime,, dd.MM.yy kl HH:mm
	Send %CurrentDateTime% käidud EMOs konsulteerimas{SPACE}
	return

::.lisa::
	FormatTime, CurrentDateTime,, HH:mm
	Send Kl %CurrentDateTime% täiendus:{SPACE}
	return

::.epikr::
	ControlGetText, kuupaev, SPR32X30Date1, Haiguslugu
	;FormatTime, CurrentDateTime,, .MM.yy
	Send %kuupaev% erakorraliselt hospitaliseeritud hematoloogia osakonda{SPACE}
	return

::.anamnees::
(
Haiguse anamnees: 

Kaasuvalt: 

Ravimid: 
Allergiad: 
Operatsioonid: 

Eluanamnees: 

Objektiivne leid:
Vitaalid:
EKG:
Vereanalüüsid:
RAD
)

::.koju::
	FormatTime, CurrentDateTime,, dd.MM.yy
	Send %CurrentDateTime% lubatud rahuldavas üldseisundis kodusele ravile.

::üs::Üldseisund 
::a&o::Adekvaatselt kontaktne ja igakülgselt orienteeritud.
::.kiirenorm::Kopsudes bilat vesik h/k; südametoonid normofrekventsed, regulaarsed, kõrvalkahinateta. Kõht pehme, valutu. Perifeeria tursevaba.
:*:SILMAD::SILMADe liikuvus normis, nüstagme ei esine, pupillid sümmeetrilised ja valgusele reageerivad normipäraselt.
:*:SUU::SUU limaskest niiske, intaktne; keel niiske; hambad saneeritud.
:*:KOPS::KOPSudes bilateraalne vesikulaarne hingamiskahin.
:*:SÜDA::SÜDAmetoonid normofrekventsed, regulaarsed, kõrvalkahinateta. Jugulaarveenid normipärased. Perifeeria tursevaba. 
:*:KÕHT::KÕHT pehme, valutu, lisamasse ei tuvasta, maks roidekaare all.
:*:NAHK::NAHK vaadeldavas osas lööbevaba. Suurenenud lümfisõlmi palpeerides ei tunne. 
:*:NEURO::NEUROstaatuses kraniaalnärvid normipärased. Üla- ja alajäsemete lihasjõudlus normipärane. Süvarefleksid vallanduvad üla- ja alajäsemetel normipäraselt. Barre stabiilne. SNK ja KPK täpsed. Romberg stabiilne. Kõnnak normipärane.

:r0:.muutusteta::
	gosub ::.uus
	Send Üldseisund muutusteta. Enesetunne rahuldav. Kaebusteta.{ENTER}
	Send Obj. Kopsudes bilat vesik h/k; südametoonid normofrekventsed, regulaarsed, kõrvalkahinateta. Kõht pehme, valutu. Perifeeria tursevaba.{ENTER}
	Send Jätkub senine ravi.{ENTER}
	Send arst-resident Jakob Prii, D09005
	return

::.exitus::
(
Osakonnaõde kutsub, kuna patsient leitud voodist elutuna.
Läbivaatusel pt kõnetamisele ega valule ei reageeri. Monitoril elektrilist aktiivsust ei esine. Pupillid laiad ja valgusele reageerimatud. 60s jooksul kuulatlusel südametoone ega a carotisel pulssi ei esine.
Exitus lethalis fikseeritud . Elektrooniline surmateatis täidetud. Lähedasi teavitatud. Lahangule ei lähe.
arst-resident Jakob Prii, D09005
)

::.DNR::Prognoos tõsine. Arvestade patsiendi vanust, üldseisundit, ning kaasuvaid haigusi, siis III astme intensiivravi prognoosi ei parandaks ja piirdume II astme ravivõimalustega. Vereprodukte võib üle kanda. Vasopressoorset ravi võib alustada.

::.KOK::SUITSETAMISEST LOOBUDA. Soovituslik vaktsineerida gripi vastu igal sügisel, ühekordselt teha ka pneumokoki vaktsiin. 

::.KOKiägenemine::
(
KOKi ägenemise korral (õhupuuduse süvenemine, rögaerituse rohkenemine, või röga värvi muutumine):
Kui esineb rohkem kui üks ägenemise tunnus või lisandub palavik siis konsulteeri arstiga antibiootikumravi alustamise osas.
Võtta prednisolooni 30mg hommikuti 5 päeva jooksul
Berodual 15 tilka + NaCl 0.9% 1,5ml nebuliseerida 4 korda päevas
Pulmicort 0,5ml + NaCl 0.9% 1,5ml nebuliseerida 2 korda päevas
)

:*:PAle::Perearsti jälgimisele.


; --------------- RAVIMID ------------------
:*r0:.panto::T.pantoprasool mg x1, {left 7}
:*r0:.omep::T.omeprasool mg x1, {left 7}
:*r0:.metfor::T.metformiin mg x3, {left 7}
:*r0:.metop::T.metoprolool mg x2, {left 7}
:*r0:.ator::T.atorvastatiin mg x1, {left 7}
:*r0:.rosu::T.rosuvastatiin mg x1, {left 7}
:*r0:.Folver::T.Folverlan (foolhape) 5mg x1 3 kuud, 
:*r0:.tora::T.torasemiid mg x1, {left 7}
:*r0:.spiro::T.Spirix (spironolaktoon) mg x1, {left 7}
:*r0:.enal::T.enalapriil mg x1, {left 7}
:*r0:.rami::T.ramipriil mg x1, {left 7}
:*r0:.perindo::T.perindopriil mg x1, {left 7}
:*r0:.amlo::T.amlodipiin mg x1, {left 7}
:*r0:.riva::T.Xarelto (rivaroksabaan) mg x1, {left 7}
:*r0:.apiks::T.Eliquis (apiksabaan) mg x2, {left 7}

