var waitExist = "";

function TelliNimekiri(nav, nimekiri) {
	return new Promise((resolve, reject) => {
		let labModulePopup = "#ctl00_pc_popup_popupPanel";
		console.log("Navigeerin" + nav);
		$("span:contains('" + nav[0] + "')").trigger("click");
		if (nav.length > 1) {
			console.log("Filtering shit");
			console.log($("span:contains('" + nav[0] + "')").parent().parent().find("span").filter("span :contains('" + nav[1] + "')"));
			$("span:contains('" + nav[0] + "')").parent().parent().find("span").filter("span :contains('" + nav[1] + "')").trigger("click");
		}
		waitForElement(labModulePopup).then(() => {
			console.log("Tellin: " + nimekiri);
			Object.keys(nimekiri).forEach(function(sektsioon) {
				console.log("Key: " + sektsioon);
				console.log($("span.headerBlue:contains('" + sektsioon + "')"));
				let sektsiooniSisu = $("span.headerBlue:contains('" + sektsioon + "')").parent().find("label");
				console.log($("span.headerBlue:contains('" + sektsioon + "')").parent().find("label"));
				nimekiri[sektsioon].forEach(function(order) {
					console.log(order);
					console.log(sektsiooniSisu.filter(":contains('" + order + "')").eq(0).attr('for'));
					let el = sektsiooniSisu.filter(":contains('" + order + "')").eq(0).attr('for'); 
					if (el) {document.getElementById(el).click();}
				});
			});
			console.log("Klikin");
			document.getElementById('ctl00_pc_popup_LabOrderModuleServiceSetForm_proceed').click();
			waitForElement("#ctl00_pc_popup_popupPanel", ':hidden')
				.then((res)=> {
					document.getElementById('ctl00_pc_LabOrderModuleNewOrder_patientAndCustomerControl_testData_setSelector_Arrow').click();
					console.log("resolved");
					resolve(res);}, () => {console.log("rejected");reject();});
		});
	});
}

MutationObserver = window.MutationObserver || window.WebKitMutationObserver;

var observer = new MutationObserver(function(mutations, observer) {
	if ($("#ctl00_pc_LabOrderModuleNewOrder_patientAndCustomerControl_testData_setSelector_Arrow").is(':visible') == true) {
		if (!($("#ctl00_pc_popup_popupPanel").is(':visible')) && !($("#kiirpaneel").is(':visible'))) {
			CreateLaborPanel();
		}
	}
});

$(document).ready(function() {
	var splitTitle = document.title.split(" - ");
	console.log("length is" + splitTitle.length);
	console.log(splitTitle);
	if (splitTitle.length > 2) {
		if (splitTitle[1] == "Labor") {
		    console.log("Already labor");
		}
		console.log("Readyfn setting title to: " + splitTitle[0] + " - " + splitTitle[2]);
		document.title = splitTitle[0] + " - " + splitTitle[2];
	} else {
		if ($("#ctl00_pc_LabOrderModuleNewOrder_patientAndCustomerControl_testData_setSelector_Arrow").is(':visible') == true) {
			setTitle("Labor");
			document.getElementById('ctl00_pc_LabOrderModuleNewOrder_patientAndCustomerControl_testData_setSelector_Arrow').click();
			CreateLaborPanel();
		} else if ($("#ctl00_pc_archive_chkPacs").is(':visible') == true) {
			setTitle("Pildipank");
			if ($('#ctl00_pc_archive_chkPacs').is(":checked") == false) {
				console.log("Pildipank already checked");
				$("#ctl00_pc_archive_chkPacs").attr("checked",true);
				$("#ctl00_pc_archive_search").trigger("click");

		 	}
			/*document.getElementById('ctl00_pc_archive_search').click();*/
		} else if ($("#ctl00_pc_RISOrderModuleControlsOrderucOrder_patientAndCustomerControl_exams_pickExamination").is(':visible')) {
			setTitle("Radioloogia");
			$("#ctl00_pc_RISOrderModuleControlsOrderucOrder_patientAndCustomerControl_exams_pickExamination").trigger("click");
		} else if ($("#ctl00_pc_LabOrderModuleNewOrder_answersControl_answersPanel").is(':visible')) {
			setTitle("Labori vastused");
			$("#ctl00_pc_LabOrderModuleNewOrder_answersControl_period_0").trigger("click");
		} else if ($("#ctl00_pc_FDOrderModuleNewOrderFunctionalDiagnostics_order_patientData_patientAndCustomerPanel").is(':visible')) {
			setTitle("Funktsionaaldiagnostika");
			$("#ctl00_pc_FDOrderModuleNewOrderFunctionalDiagnostics_order_patientData_fdExam_examinationPlace").val("Department");
			$("#ctl00_pc_FDOrderModuleNewOrderFunctionalDiagnostics_order_patientData_fdExam_arrival").val("Wheelchair");
			$("#ctl00_pc_FDOrderModuleNewOrderFunctionalDiagnostics_order_patientData_fdExam_newExam_i0_setTree").height("360px");
			document.getElementById('ctl00_pc_FDOrderModuleNewOrderFunctionalDiagnostics_order_patientData_fdExam_newExam_Arrow').click();
			waitForElement("#ctl00_pc_FDOrderModuleNewOrderFunctionalDiagnostics_order_patientData_fdExam_newExam_i0_setTree").then(() => {$("span.rtPlus").trigger("click");});
		} else {
			setTitle("Moodul");
		}

		window.onbeforeunload = function() {
			var res = document.title.split(" - ");
			console.log("Onbeforeunload setting title to: " + res[0] + " - " + res[2]);
			document.title = res[0] + " - " + res[2];
		};
	}
	observer.observe(document, {
  		subtree: true,
  		attributes: true
	});
});

function setTitle(newTitle) {
	var res = document.title.split(" - ");
	console.log("Setting title to: " + res[0] + " - " + newTitle + " - " + res[1]);
	document.title = res[0] + " - " + newTitle + " - " + res[1];
}

function waitForElement(selector, elStatus=':visible', maxTime=5000) {
	return new Promise((resolve, reject) => {
		const waitForEl = (selector, count = 0) => {
			const el = jQuery(selector);

			if (el.is(elStatus)) {
				resolve(el);
			} else {
				setTimeout(() => {
					count++;
					if (count < (maxTime/100)) {
						waitForEl(selector, count);
					} else {
						reject();
					}
 				}, 100);
			}
		};
		waitForEl(selector);
	});
};

function CreateLaborPanel() {
	add_html = `<style>.tellimusnupp:hover{background-color:#fff;}
.tellimusnupp {padding: 5px;}
.flexRow {display: flex; flex-direction: row; }
.flexCol {display: flex; flex-direction: column;flex-basis:50%;}</style>
	<div id="kiirpaneel" style="position: absolute; background-color: #f1f1f1; border: 1px solid #d3d3d3; text-align:center; width: 200px;">
<!-- Include a header DIV with the same name as the draggable DIV, followed by "header" -->
<div id="mydivheader" style="padding: 10px; cursor: move; background-color:#2196F3; color:#fff;">Kiirtellimused</div>
<div class="flexRow">
	<div class="flexCol" style="border-right:1px solid #d3d3d3;">
		<div id="CBC-5Diff" class="tellimusnupp">CBC-5Diff</div>
		<div class="separator" style="border-bottom:1px solid #d3d3d3;"></div>
		<div id="Biokeemia-3" class="tellimusnupp" title="Na, K, CRP">Biokeemia-3</div>
		<div id="Biokeemia-5" class="tellimusnupp" title="Na, K, Crea, ALAT, CRP">Biokeemia-5</div>
		<div id="Biokeemia-7" class="tellimusnupp" title="Na, K, Mg, Crea, Urea, ALAT, CRP">Biokeemia-7</div>
		<div id="Biokeemia-14" class="tellimusnupp" title="Na, K, Mg, Crea, Urea, ALAT, ASAT, Bil, ALP, Lip, Alb, Prot, Gluc, CRP">Biokeemia-14</div>
		<div class="separator" style="border-bottom:1px solid #d3d3d3;"></div>
		<div id="Uriin" class="tellimusnupp flexCol" title="uriini ribaanalüüs">Uriin</div>
	</div>
	<div class="flexCol">
		<div id="Verekülv" class="tellimusnupp" title="aeroobid, anaeroobid">Verekülv</div>
		<div id="Febriilne_neutropeenia" class="tellimusnupp" title="verekülv, kurgukaabe anaeroobid+Candida, ninakaabe gripp+bakterid PCR, sepsise PCR paneel, uriinikülv">Febriilne neutropeenia</div>
		<div id="Hüübimine" class="tellimusnupp" title="INR, PTs, aPTT, TT, Fibr, ATIII">Hüübimine</div>
		<div class="separator" style="border-bottom:1px solid #d3d3d3;"></div>
		<div id="Koroona24" class="tellimusnupp" title="CBC-5Diff, K, Na, Ca, Mg, Crea, Urea">Koroona q24h</div>
		<div id="Koroona48" class="tellimusnupp" title="CBC-5Diff, K, Na, Ca, Mg, Crea, Urea, ALAT, ASAT, ALP, LDH, Bil, CRP, kardiomarkerid, ferritiin, D-dimeerid">Koroona q48h</div>
	</div>
</div>
</div>`;

	if ($("#kiirpaneel").is(':visible') == true) {
		$("#kiirpaneel").remove();
	}
	function addSendBtn(butVal, butId) {return '<input type="submit" value="' + butVal + '" id="' + butId + '" class="btn2 btnSendLabor" style="width:150px" align="center">';};
	$("#ctl00_pc_LabOrderModuleNewOrder_patientAndCustomerControl_testData_setSelector").parent().parent().after(add_html);
	/*$(".tellimusnupp").hover(function(){$(this).css("background-color", "#fff");},function(){$(this).css("background-color", "#f1f1f1");});*/
	if (!($("#sendIn0").is(':visible'))) {
		$("#ctl00_pc_LabOrderModuleNewOrder_printReceiptMenu").before(addSendBtn("Saada täna","sendIn0"));
		$("#ctl00_pc_LabOrderModuleNewOrder_printReceiptMenu").before(addSendBtn("Saada homme","sendIn1"));
		$("#ctl00_pc_LabOrderModuleNewOrder_printReceiptMenu").before(addSendBtn("Saada ülehomme","sendIn2"));
		$("#ctl00_pc_LabOrderModuleNewOrder_printReceiptMenu").before('<input id="printAfter" ' + ((localStorage.getItem("printAfter") == "true") ? 'checked' : '') + ' type="checkbox" name="printAfter"><label for="printAfter">Trüki kleebised automaatselt</label>');
	}
	dragElement(document.getElementById("kiirpaneel"));
	$(".btnSendLabor").click(function () {
		let currentDate = new Date();
		currentDate.setDate(currentDate.getDate() + Number(this.id.substring(6)));
		sendDate = new Intl.DateTimeFormat('et', {day:"2-digit",month:"2-digit",year:"numeric"}).format(currentDate);
		$("#ctl00_pc_LabOrderModuleNewOrder_nextTabLink").trigger("click");
		console.log("clicked Edasi button");
		waitForElement("#ctl00_pc_LabOrderModuleNewOrder_sendToNurseButton")
			.then(() => {
				console.log("clicking send to nurse");
				$("#ctl00_pc_LabOrderModuleNewOrder_sendToNurseButton").trigger("click");
				waitForElement("#ctl00_pc_popup_popupPanel")
					.then(() => {
						$("#ctl00_pc_popup_LabOrderModuleSendToNurse_date").val(sendDate);
						$("#ctl00_pc_popup_LabOrderModuleSendToNurse_proceed").trigger("click");
						waitForElement("#ctl00_pc_LabOrderModuleNewOrder_copyButton")
							.then(() => {
								if (localStorage.getItem("printAfter") == "true") { $("#ctl00_pc_LabOrderModuleNewOrder_printAllBarCodes").trigger("click"); }
							});
					});
			});
	});
	$(".tellimusnupp").click(function () {
		let tellimusList = [];
		if (this.id == "CBC-5Diff") {
			TelliNimekiri(["Hematoloogia ja Glükohemoglobiin"], {'Hematoloogia ja Glüko':["CBC-5Diff"]});
		} else if (this.id.includes("Biokeemia")) {
			if (this.id == "Biokeemia-3") {
				tellimusList = {'Üldbiokeemilised':['P-K','P-Na'], 'Spetsiifilised valgud':['P-CRP']};
			} else if (this.id == "Biokeemia-5") {
				tellimusList = {'Üldbiokeemilised':['P-K','P-Na','P-Crea','P-ALAT'], 'Spetsiifilised valgud':['P-CRP']};
			} else if (this.id == "Biokeemia-7") {
				tellimusList = {'Üldbiokeemilised':['P-K','P-Na','P-Mg','P-Crea','P-Urea','P-ALAT'], 'Spetsiifilised valgud':['P-CRP']};
			} else if (this.id == "Biokeemia-14") {
				tellimusList = {'Üldbiokeemilised':['P-K','P-Na','P-Mg','P-Crea','P-Urea','P-ALAT','P-ASAT','P-ALP','P-Bil','P-Prot','P-Alb','P-Lip','P-Gluc'], 'Spetsiifilised valgud':['P-CRP']};
			}
			TelliNimekiri(["Kliinilise keemia uuringud","Biokeemia"], tellimusList);
		} else if (this.id == "Verekülv") {
			TelliNimekiri(["Mikrobioloogia","Veri"], {'veri':["aeroobsed","anaeroobsed"]});
		} else if (this.id == "Uriin") {
			TelliNimekiri(["Uriini ja rooja uuringud"], {'Uriini uuringud 1':["U-Strip"]});
		} else if (this.id == "Febriilne_neutropeenia") {
			TelliNimekiri(["Mikrobioloogia","Veri"], {'veri':["aeroobsed","anaeroobsed","Candida"]}).then(() => {
				TelliNimekiri(["Mikrobioloogia","Hingamisteed"], {'kurgukaabe':["aeroobsed","Candida"]}).then(() => {
					TelliNimekiri(["Molekulaardiagnostika","Täisveri"], {'Infektsioonid':["Sepsise"]}).then(() => {
						TelliNimekiri(["Molekulaardiagnostika","Ninakaabe"], {'Respiratoorsete':["Gripi","Resp. viiruste","Resp. bakterite"]}).then(() => {
							TelliNimekiri(["Mikrobioloogia","Uriin"], {'uriin (keskjoa)':["aeroobsed","Candida","Legionella","Streptococcus"]});
						});
					});
				});
			});
		} else if (this.id == "Hüübimine") {
			TelliNimekiri(["Hüübimine","Hüübimine"], {'Hüübimine':["P-INR","P-APTT","P-TT","P-Fibr","P-ATIII","P-PTs"]});
		} else if (this.id == "Koroona24") {
			TelliNimekiri(["Hematoloogia ja Glükohemoglobiin"], {'Hematoloogia ja Glüko':["CBC-5Diff"]}).then(() => {
				TelliNimekiri(["Kliinilise keemia uuringud","Biokeemia"], {'Üldbiokeemilised':['P-K','P-Na','P-Crea','P-Urea','P-Ca','P-Mg']});
			});
		} else if (this.id == "Koroona48") {
			TelliNimekiri(["Hematoloogia ja Glükohemoglobiin"], {'Hematoloogia ja Glüko':["CBC-5Diff"]}).then(() => {
				TelliNimekiri(["Kliinilise keemia uuringud","Biokeemia"], {'Üldbiokeemilised':['P-K','P-Na','P-Crea','P-Urea','P-Ca','P-Mg','P-ALAT','P-ASAT','P-ALP','P-LDH','P-Bil'], 'Spetsiifilised valgud':['P-CRP'], 'Südamemarkerid':['P-NT-proBNP','P-cTNT-hs','P-CK-MBm'], 'Aneemia':['P-Fer']}).then(()=>{
					TelliNimekiri(["Hüübimine","Hüübimine"], {'Hüübimine':["P-DDi"]});
				});
			});
		} else {
		}
		/*ctl00_pc_popup_LabOrderModuleServiceSetForm_groups_ctl00_tests_1
		ctl00_pc_popup_LabOrderModuleServiceSetForm_proceed*/
	});
	$("#printAfter").change(function () {
		if (this.checked) {
			window.localStorage.setItem("printAfter", "true");
		} else {
			window.localStorage.setItem("printAfter", "false");
		}
	});
}

function dragElement(elmnt) {
	var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
	if (document.getElementById(elmnt.id + "header")) {
		document.getElementById(elmnt.id + "header").onmousedown = dragMouseDown;
	} else {
		elmnt.onmousedown = dragMouseDown;
	}
	function dragMouseDown(e) {
		e = e || window.event;
		e.preventDefault();
		pos3 = e.clientX;
		pos4 = e.clientY;
		document.onmouseup = closeDragElement;
		document.onmousemove = elementDrag;
	}
	function elementDrag(e) {
		e = e || window.event;
		e.preventDefault();
		pos1 = pos3 - e.clientX;
		pos2 = pos4 - e.clientY;
		pos3 = e.clientX;
		pos4 = e.clientY;
		elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
		elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
	}
	function closeDragElement() {
		document.onmouseup = null;
		document.onmousemove = null;
	}
}
