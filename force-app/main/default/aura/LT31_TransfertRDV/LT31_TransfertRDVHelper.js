({
	updateFirms: function(cmp, helper) {
		const firms = cmp.get("c.getFirms");
		firms.setParams({
			leadId: cmp.get("v.simpleRecord.Lead__c"),
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
		if(wrapper.account.OnlinePartner__c)
			text += ' (En ligne)';
		else if(wrapper.distance != undefined)
			text += ' (' + wrapper.distance + ' km)';

		return text; 
	},
	updateContacts: function(cmp, helper) {
		const contacts = cmp.get("c.getContacts");
		contacts.setParams({
			firm: cmp.get("v.simpleRecord.Partenaire__c")
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
					cmp.set("v.simpleRecord.ContactPartenaire__c", cmp.get("v.contactsList")[0]["key"]);
				}else{
                    cmp.set("v.simpleRecord.ContactPartenaire__c", null);
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
					cmp.set("v.simpleRecord.Lead__r.Email_Body__c", cmp.get("v.TemplateBureau"));
				} else {
					cmp.set("v.simpleRecord.Lead__r.Email_Body__c", cmp.get("v.TemplateBureauGroupe"));
				}
			} else {
				if(cmp.get("v.firmIsGroup") == false) {
					cmp.set("v.simpleRecord.Lead__r.Email_Body__c", cmp.get("v.TemplateClient"));
				} else {
					cmp.set("v.simpleRecord.Lead__r.Email_Body__c", cmp.get("v.TemplateClientGroupe"));
				}
			}
		} else if(cmp.get("v.appointmentType") == "téléphonique") {
			this.makeAdress(cmp);
			if(cmp.get("{!v.simpleRecord.Lead__r.RDV_EC_confirmer__c}") == "Oui") {
				cmp.set("v.simpleRecord.Lead__r.Email_Body__c", cmp.get("v.TemplateTelAConfirmer"));
			} else {
				if(cmp.get("v.firmIsGroup") == false) {
					cmp.set("v.simpleRecord.Lead__r.Email_Body__c", cmp.get("v.TemplateTel"));
				} else {
					cmp.set("v.simpleRecord.Lead__r.Email_Body__c", cmp.get("v.TemplateTelGroupe"));
				}
			}
		} else {
			cmp.set("v.simpleRecord.Lead__r.Email_Body__c", null);
		}
	},
	makeAdress : function(cmp) {
		const obj = cmp.get("v.simpleRecord.Lead__r");
		if(obj != null && obj.Street != null && obj.PostalCode != null && obj.City != null)
			cmp.set("v.address", obj.Street + ', ' + obj.PostalCode + ' ' + obj.City);
		else
			cmp.set("v.address", "<ADRESSE>");
	},
	formatDate : function(cmp) {
		var date = cmp.get("v.simpleRecord.Lead__r").Rendez_vous__c;
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
		const id = cmp.get('v.simpleRecord.ContactPartenaire__c');
		const obj = this.findContact(cmp, id);
		if(cmp.get("v.firmIsGroup") == false) {
			cmp.set('v.selectedUserName', obj != undefined ? obj.Name : '<CONTACT>');
		} else {
			cmp.set('v.selectedUserName', obj != undefined ? obj.FirstName : '<CONTACT>');
		}
		cmp.set('v.selectedUserPhone', obj != undefined ? obj.MobilePhone : '<TÉLÉPHONE>');
	},
	updateSelectedFirm: function(cmp) {
		const selected = cmp.get("v.simpleRecord.Partenaire__c");
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

		// Get firm info (is group)
		const firmId = cmp.get("v.simpleRecord.Partenaire__c");
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
					}
					else {
						cmp.set("v.firmIsGroup",false);
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
	switchShowPhysique : function(cmp) {
		var selected = cmp.get("v.simpleRecord.Partenaire__c");
		var isOnline = cmp.get("v.isOnline");
		cmp.set("v.showPhysique", !isOnline[selected]);
	},
	sendEmail: function(cmp, event, helper) {
		helper.showSpinner(cmp);
        var action = cmp.get("c.sendEmailForRdv");
		action.setParams({
            transfertId: cmp.get("v.recordId"),
			leadId: cmp.get("v.simpleRecord.Lead__c"),
            leadContactPartenaire: cmp.get("v.simpleRecord.ContactPartenaire__c"), 
            leadBranding: cmp.get("v.simpleRecord.Lead__r.Branding__c"),
            leadEmail: cmp.get("v.simpleRecord.Lead__r.Email"),
            leadEmailBody: cmp.get("v.simpleRecord.Lead__r.Email_Body__c"),
            leadRendezVous: cmp.get("v.simpleRecord.Lead__r.Rendez_vous__c"),
            lieuRDV: helper.getAppointmentType(cmp)
		});
		action.setCallback(this, function(res) {
			if (res.getState() === "SUCCESS") {
                helper.showSpinner(cmp,"hide");
                cmp.set("v.rdvProgramme", true);
				helper.showToast("success", "Succès", "Le rendez-vous a bien été enregistré !");
            }
            else{
                helper.showSpinner(cmp,"hide");
                helper.showToast("error", "Erreur", this.findErrorMessage(cmp, this, res));
                console.log(this.findErrorMessage(cmp, this, res));
            }
		});
		$A.enqueueAction(action);
    },
	getAppointmentType: function(cmp) {
		switch(cmp.get('v.appointmentType')) {
			case 'physique': 
				return cmp.get('v.appointmentLocation') ? 'Au bureau' : 'Chez le client';
			case 'téléphonique': return 'Téléphonique';
			default: return '';
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
	}
})