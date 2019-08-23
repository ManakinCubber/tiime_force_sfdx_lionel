({
	updateFirms: function(cmp, helper) {
		const firms = cmp.get("c.getFirms");
		firms.setParams({
			leadId: cmp.get("v.LeadObject.Id"),
		});
		firms.setCallback(this, function(res) {
			if (res.getState() === "SUCCESS") {
				const selected = cmp.get("v.LeadObject.Partenaire__c");
				const result = res.getReturnValue();
				const list = [];
				var isOnline = {};
				
				for(let key in result) {
					list.push({value:helper.buildFirmEntryText(result[key]), key:result[key].account.Id});
					isOnline[result[key].account.Id] = result[key].account.OnlinePartner__c;
				}
				
				cmp.set("v.isOnline", isOnline);
				cmp.set("v.showPhysique", !isOnline[selected]);
				cmp.set("v.firms", result);
				cmp.set("v.firmList", list);

				helper.updateContacts(cmp, helper);
			}
		});
		$A.enqueueAction(firms);
	},
	buildFirmEntryText: function(wrapper) {
		let text = wrapper.account.Name;

		/*if(wrapper.account.OnlinePartner__c && wrapper.distance != undefined)
			text += ' (' + wrapper.distance + ' km ou en ligne)';
		else */
		if(wrapper.account.OnlinePartner__c)
			text += ' (En ligne)';
		else if(wrapper.distance != undefined)
			text += ' (' + wrapper.distance + ' km)';

		return text; 
	},
	saveFirm: function(cmp, helper) {
		const action = cmp.get("c.updateFirm");
		const firmId = cmp.get("v.LeadObject.Partenaire__c");
		action.setParams({
			record: cmp.get("v.LeadObject.Id"),
			firm: firmId == '' ? null : firmId
		});
		action.setCallback(this, function(res) {
			if (res.getState() !== "SUCCESS") {
				console.log("saveFirm :  error!!");
				helper.showToast("error", "Erreur", "Erreur lors de la mise à jour du cabinet partenaire sélectionné.");
			}
		});
		$A.enqueueAction(action);
	},
	updateContacts: function(cmp, helper) {
		const contacts = cmp.get("c.getContacts");
		contacts.setParams({
			firm: cmp.get("v.LeadObject.Partenaire__c")
		});
		contacts.setCallback(this, function(res) {
			if (res.getState() === "SUCCESS") {
				const result = res.getReturnValue();
				const list = [];
				for(let key in result)
					list.push({value:result[key].Name, key:result[key].Id});

				cmp.set("v.contacts", result);
				cmp.set("v.contactsList", list);
				if(cmp.get("v.contactsList").length == 1) {
					cmp.set("v.LeadObject.Contact_Partenaire__c", cmp.get("v.contactsList")[0]["key"]);
				}else{
					cmp.set("v.LeadObject.Contact_Partenaire__c", null);
				}
				helper.updateMailBody(cmp);
			}
		});
		$A.enqueueAction(contacts);
	},
	updateMailBody : function(cmp) {
		this.updateSelectedFirm(cmp);
		this.updateSelectedContact(cmp);
		this.formatDate(cmp);
		if(cmp.get("v.appointmentType") == "physique") {
			this.makeAdress(cmp);
			if(cmp.get("v.appointmentLocation") == "au bureau") {
				if(cmp.get("v.firmIsGroup") == false) {
					cmp.set("v.LeadObject.Email_Body__c", cmp.get("v.TemplateBureau"));
				} else {
					cmp.set("v.LeadObject.Email_Body__c", cmp.get("v.TemplateBureauGroupe"));
				}
			} else {
				if(cmp.get("v.firmIsGroup") == false) {
					cmp.set("v.LeadObject.Email_Body__c", cmp.get("v.TemplateClient"));
				} else {
					cmp.set("v.LeadObject.Email_Body__c", cmp.get("v.TemplateClientGroupe"));
				}
			}
		} else if(cmp.get("{!v.appointmentType}") == "téléphonique") {
			this.makeAdress(cmp);
			if(cmp.get("{!v.LeadObject.RDV_EC_confirmer__c}") == "Oui") {
				cmp.set("v.LeadObject.Email_Body__c", cmp.get("v.TemplateTelAConfirmer"));
			} else {
				if(cmp.get("v.firmIsGroup") == false) {
					cmp.set("v.LeadObject.Email_Body__c", cmp.get("v.TemplateTel"));
				} else {
					cmp.set("v.LeadObject.Email_Body__c", cmp.get("v.TemplateTelGroupe"));
				}
			}
		} else {
			cmp.set("v.LeadObject.Email_Body__c", null);
		}
	},
	makeAdress : function(cmp) {
		const obj = cmp.get("v.LeadObject");
		if(obj != null && obj.Street != null && obj.PostalCode != null && obj.City != null)
			cmp.set("v.address", obj.Street + ', ' + obj.PostalCode + ' ' + obj.City);
		else
			cmp.set("v.address", "<ADRESSE>");
	},
	formatDate : function(cmp) {
		var date = cmp.get("v.LeadObject").Rendez_vous__c;
		var months = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Decembre"];
		if(date) {
			var d = new Date(date);
			var datestring = ("0" + d.getDate()).slice(-2) + " " + months[d.getMonth()];
			var time= ("0" + d.getHours()).slice(-2) + "H" + ("0" + d.getMinutes()).slice(-2);
			cmp.set("v.formattedDate", datestring);
			cmp.set("v.formattedTime", time);
		} else {
			cmp.set("v.formattedDate", "<DATE>");
			cmp.set("v.formattedTime", "<HEURE>");
		}
	},
	createLogError: function(component, errorMessage) {
		var createLogErrorAction = component.get("c.logAnError");
		createLogErrorAction.setParams({
			errorMessage: errorMessage
		});
		$A.enqueueAction(createLogErrorAction);
	},
	showToast: function(type, title, message) {
		var resultsToast = $A.get("e.force:showToast");
		resultsToast.setParams({
			title: title,
			message: message,
			type: type
		});
		resultsToast.fire();
	},
	updateSelectedContact: function(cmp) {
		const id = cmp.get('v.LeadObject.Contact_Partenaire__c');
		const obj = this.findContact(cmp, id);
		if(cmp.get("v.firmIsGroup") == false) {
			cmp.set('v.selectedUserName', obj != undefined ? obj.Name : '<CONTACT>');
		} else {
			cmp.set('v.selectedUserName', obj != undefined ? obj.FirstName : '<CONTACT>');
		}
		cmp.set('v.selectedUserPhone', obj != undefined ? obj.MobilePhone : '<TÉLÉPHONE>');
	},
	updateSelectedFirm: function(cmp) {
		const selected = cmp.get("v.LeadObject.Partenaire__c");
		const firms = cmp.get("v.firms");
		let firm = this.findFirm(cmp, selected);
		if(firm != undefined) {
			firm = firm.account;
			cmp.set("v.selectedFirmName", firm.Name);
			this.updateSignatureMail(cmp, firm.Name);
			cmp.set("v.selectedFirmFloor", (firm.Floor__c == "RDC" ? firm.Floor__c : firm.Floor__c + " étage"));
			if(firm.BillingAddress != undefined && firm.BillingAddress.street != null && firm.BillingAddress.postalCode != null && firm.BillingAddress.city != null)
				cmp.set("v.selectedFirmAddress", firm.BillingAddress.street + ', ' + firm.BillingAddress.postalCode + ' ' + firm.BillingAddress.city);
			else
				cmp.set("v.selectedFirmAddress", "<ADRESSE>");
		} else
			cmp.set("v.signatureMail","<SIGNATURE>");

		// Get firm info (is group and red phone)
		const firmId = cmp.get("v.LeadObject.Partenaire__c");
		if(firmId != null && firmId != '') {
			const action = cmp.get("c.getFirm");
			action.setParams({
				firm: firmId
			});
			action.setCallback(this, function(res) {
				if (res.getState() === "SUCCESS") {
					var account = res.getReturnValue();
					if( account != undefined && account.PartnerType__c=="Groupe") {
						cmp.set("v.firmIsGroup",true);
						cmp.set("v.redPhone", account.MainPhoneNumber__c);

					}
					else {
						cmp.set("v.firmIsGroup",false);
						cmp.set("v.redPhone", null);
					}
				} else {
					helper.showToast("error", "Erreur", "Erreur lors de la récupération des informations du cabinet partenaire sélectionné.");
				}
			});
			$A.enqueueAction(action);
			
		}

	},
	updateSignatureMail: function(cmp, firmName) {
		cmp.set("v.signatureMail",$A.get("$Label.c.LEAD_APPOINTMENT_SIGNATURE_MAIL") + " " + firmName);
	},
	findContact: function(cmp, id) {
		const contacts = cmp.get('v.contacts');
		for(let i = 0 ; i < contacts.length ; i++) {
			if(contacts[i].Id == id) {
				return contacts[i];
			}
		}
		return undefined;
	},
	findFirm: function(cmp, id) {
		const firms = cmp.get('v.firms');
		for(let i = 0 ; i < firms.length ; i++) {
			if(firms[i].account.Id == id) {
				return firms[i];
			}
		}
		return undefined;
	},
	manageTransfert: function(cmp) {
		if(cmp.get("{!v.appointmentType}") == "téléphonique" && cmp.get("{!v.LeadObject.RDV_EC_confirmer__c}") == "Oui") {
			cmp.set("v.LeadObject.Status", "EC à Trouver");
		} else {
			cmp.set("v.LeadObject.Status", "Partenaire");
			cmp.set("v.LeadObject.TransferMonitoring__c", "Partenaire");
		}
	},
	manageBaseGI: function(cmp) {
		var sendLeadToBaseGIAction = cmp.get("c.sendLeadToBaseGI");
		sendLeadToBaseGIAction.setParams({
			leadId : cmp.get("v.LeadObject.Id")
		});
		sendLeadToBaseGIAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				this.showToast("success", "Succès", "Le compte a bien été créé dans la Base GI !");
			} else {
				this.createLogError(cmp, this.findErrorMessage(cmp, this, res));
				this.showToast("error", "Erreur", this.findErrorMessage(cmp, this, res));
				
			}
		});
		$A.enqueueAction(sendLeadToBaseGIAction);
	},
	contactOk : function(cmp) {
		if(cmp.get("v.LeadObject.Contact_Partenaire__c") == null || cmp.get("v.LeadObject.Contact_Partenaire__c") == ''){
			cmp.set("v.showError", true);
			return false;
		}
		cmp.set("v.showError", false);
		return true;
	},
	brandingOk : function(cmp) {
		if(cmp.get("v.LeadObject.Branding__c") == null || cmp.get("v.LeadObject.Branding__c") == ''){
			cmp.set("v.showError", true);
			return false;
		}
		cmp.set("v.showError", false);
		return true;
	},
	switchShowPhysique : function(cmp) {
		var selected = cmp.get("v.LeadObject.Partenaire__c");
		var isOnline = cmp.get("v.isOnline");
		cmp.set("v.showPhysique", !isOnline[selected]);
	},
	save: function(cmp, event, helper) {
		const record = cmp.find("record");
		const firmId = cmp.get("v.LeadObject.Partenaire__c");
		cmp.set("v.LeadObject.Is_Appointment_Set__c", (cmp.get("{!v.LeadObject.RDV_EC_confirmer__c}") == "Oui" ? false : true));
		cmp.set("v.LeadObject.Partenaire__c", firmId == '' ? null : firmId);

		if(helper.contactOk(cmp) && helper.brandingOk(cmp)) {
			
			// Set appointment type
			cmp.set("v.LeadObject.Appointment_Type__c", this.getAppointmentType(cmp));
			
			// Set Status 
			helper.manageTransfert(cmp);
		
			record.saveRecord($A.getCallback(function(saveResult) {
				if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
					
					if(cmp.get("{!v.appointmentType}") == "transfert_direct") {
						helper.showToast("success", "Succès", "Les informations ont bien été enregistrées !");
					} else {
						helper.showToast("success", "Succès", "Le rendez-vous a bien été enregistré !");
					}
					
					helper.manageBaseGI(cmp);
					
                    $A.get('e.force:refreshView').fire();
				} else if (saveResult.state === "INCOMPLETE") {
					helper.showToast("error", "Erreur", "Impossible d'enregistrer le rendez-vous en mode hors-ligne.");
				} else if (saveResult.state === "ERROR") {
					helper.showToast("error", "Erreur", saveResult.error[0].message);
					console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
				} else {
					helper.showToast("error", "Erreur", saveResult.error[0].message);
					console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
				}
			}));
		}else{
			const select = cmp.find("selectContact");
			if(select)
				select.set("v.validity", false);
		}
	},
	getAppointmentType: function(cmp) {
		switch(cmp.get('v.appointmentType')) {
			case 'physique': 
				return cmp.get('v.appointmentLocation') ? 'Au bureau' : 'Chez le client';
			case 'téléphonique': return 'Téléphonique';
			default: return 'Transfert direct';
		}
	},
	findErrorMessage: function(component, helper, res) {
    	var errorMessage;
    	if(res.getError()[0].message != undefined) {
    		errorMessage = res.getError()[0].message;
    	} else if(res.getError()[0].pageErrors[0].message != undefined) {
    		errorMessage = res.getError()[0].pageErrors[0].message;
    	}
    	return errorMessage;
    },
	showSpinner : function(cmp,state) {
		var spinner = cmp.find("spjSpinner");
		if(state =="hide"){
			$A.util.addClass(spinner, "slds-hide");
		} else {
			$A.util.removeClass(spinner, "slds-hide");
		}
	},

})