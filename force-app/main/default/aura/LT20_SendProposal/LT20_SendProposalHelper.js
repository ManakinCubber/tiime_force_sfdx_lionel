({
	getFieldsLabels : function(component) {
		var getLabelAction = component.get("c.getLabels");
		getLabelAction.setCallback(this, function(res){
			if(res.getState() === "SUCCESS") {
				component.set("v.labels", res.getReturnValue());
			}
		});
		$A.enqueueAction(getLabelAction);
	},
	getOffresOptions : function(component) {
		var getOffreOptionsAction = component.get("c.getOffreOptions");
		getOffreOptionsAction.setParams({
			branding: component.get("{!v.simpleRecord.Lead__r.Branding__c}")
		});
		getOffreOptionsAction.setCallback(this, function(res){
			if(res.getState() === "SUCCESS") {
				var optionsPicklistArray = [];
				optionsPicklistArray = res.getReturnValue();
				
				var options = [];
				var optionsAlreadySelected = [];
				
				for(var label in optionsPicklistArray) {
					
					options.push({
						label: label,
						value: optionsPicklistArray[label]
					});
					
					if(component.get("{!v.simpleRecord.Lead__r.Offres__c}") != undefined && 
					component.get("{!v.simpleRecord.Lead__r.Offres__c}").indexOf(optionsPicklistArray[label]) != -1){
						optionsAlreadySelected.push(optionsPicklistArray[label]);
					}
				}
			}
			component.set("v.offreOptions", options);
			component.set("v.offreOptionsSelected", optionsAlreadySelected);
		});
		
		$A.enqueueAction(getOffreOptionsAction);
	},
	callBgiForOffreOptions: function(component) {
		var getOffreOptionsAction = component.get("c.getOffreOptionsViaBGI");
		getOffreOptionsAction.setParams({
			leadId: component.get("{!v.simpleRecord.Lead__c}"),
			transfertId: component.get("{!v.recordId}")
		});
		getOffreOptionsAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				var optionsPicklistArray = [];
				optionsPicklistArray = JSON.parse(res.getReturnValue());
				
				var options = [];
				var optionsAlreadySelected = [];
				if(optionsPicklistArray.offres != undefined) {
					for(var label in optionsPicklistArray.offres) {
						
						options.push({
							label: optionsPicklistArray.offres[label].designation,
							value: JSON.stringify(optionsPicklistArray.offres[label])
						});
					}
				} else {
					console.log("offres vide");
				}
				component.set("v.offreOptions", options);
				console.log(component.get("v.offreOptions"));
			} else {
				console.log(res);
				console.log(res.getError());
			}
			
		});
		$A.enqueueAction(getOffreOptionsAction);
	},
	getExistingMissions: function(component) {
		var getExistingMissionsAction = component.get("c.retrieveExistingMissions");
		getExistingMissionsAction.setParams({
			transfertId: component.get("{!v.recordId}")
		});
		getExistingMissionsAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				//console.log(res.getReturnValue());
				component.set("{!v.offreOptionsSelected}", res.getReturnValue());
				console.log(component.get("{!v.offreOptionsSelected}"));
				this.fillInMissionsList(component);
			}
		});
		$A.enqueueAction(getExistingMissionsAction);
	},
	changeOffers: function(component) {
		var currentMissionsLines = component.get("{! v.missions }");
        var selectedOffers = component.get("{!v.offreOptionsSelected}");
        var allOffers = component.get("{!v.offreOptions}");

        for (var missionCounter in currentMissionsLines) {
            for (var selectedOffersCounter in allOffers) {
                let offerMissions = JSON.parse(allOffers[selectedOffersCounter].value).missions;
                for (var offerMissionsCounter in offerMissions) {
                	if(offerMissions[offerMissionsCounter].tarifDeBase == null) {
                		offerMissions[offerMissionsCounter].tarifDeBase = offerMissions[offerMissionsCounter].tarif;
                	}
                    if (offerMissions[offerMissionsCounter].id == currentMissionsLines[missionCounter].id) {
                        offerMissions[offerMissionsCounter].tarif = currentMissionsLines[missionCounter].tarif;
                        offerMissions[offerMissionsCounter].commentaire = currentMissionsLines[missionCounter].commentaire;
                    }
                }
                var tempSelectedOffers = JSON.parse(allOffers[selectedOffersCounter].value);
                tempSelectedOffers.missions = offerMissions;
                allOffers[selectedOffersCounter].value = JSON.stringify(tempSelectedOffers);
            }
            
            for (var selectedOffersCounter in selectedOffers) {
                let offerMissions = JSON.parse(selectedOffers[selectedOffersCounter]).missions;
                for (var offerMissionsCounter in offerMissions) {
                	if(offerMissions[offerMissionsCounter].tarifDeBase == null) {
                		offerMissions[offerMissionsCounter].tarifDeBase = offerMissions[offerMissionsCounter].tarif;
                	}
                    if (offerMissions[offerMissionsCounter].id == currentMissionsLines[missionCounter].id) {
                        offerMissions[offerMissionsCounter].tarif = currentMissionsLines[missionCounter].tarif;
                        offerMissions[offerMissionsCounter].commentaire = currentMissionsLines[missionCounter].commentaire;
                    }
                }
                var tempSelectedOffers = JSON.parse(selectedOffers[selectedOffersCounter]);
                tempSelectedOffers.missions = offerMissions;
                selectedOffers[selectedOffersCounter] = JSON.stringify(tempSelectedOffers);
            }
        }
        component.set("{!v.offreOptions}", allOffers);
        component.set("{!v.offreOptionsSelected}", selectedOffers);
	},
	checkAccountId: function(component) {
		if(component.get("{!v.simpleRecord.ConvertedAccountId__c}") != null && 
			component.get("{!v.simpleRecord.ConvertedAccountId__c}") != "") {
				component.set("{!v.accountId}", component.get("{!v.simpleRecord.ConvertedAccountId__c}"));
			}
	},
	getPdfFiles: function(component) {
		var getPdfFilesAction = component.get("c.getAccountAttachments");
		getPdfFilesAction.setParams({
			partnerAccountId: component.get("{!v.simpleRecord.Partenaire__c}")
		});
		getPdfFilesAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				var options = [];
				for(var label in res.getReturnValue()) {
					options.push({
						label: res.getReturnValue()[label].Title,
						value: res.getReturnValue()[label].Id
					});
				}
				component.set("v.offreDocs", options);
			}
		});
		$A.enqueueAction(getPdfFilesAction);
	},
	fillInMissionsList: function(component) {
		var newMissionsList = [];
		var selectedOffers = component.get("{!v.offreOptionsSelected}");
		
		for(var selectedOffersCounter in selectedOffers) {
		
			let offerMissions = JSON.parse(selectedOffers[selectedOffersCounter]).missions;
			for(var offerMissionsCounter in offerMissions) {
				offerMissions[offerMissionsCounter].offerName = JSON.parse(selectedOffers[selectedOffersCounter]).designation;
				offerMissions[offerMissionsCounter].offerId = JSON.parse(selectedOffers[selectedOffersCounter]).id
				newMissionsList.push(offerMissions[offerMissionsCounter]);
			}
		}
		component.set("{! v.missions }", newMissionsList);
		//console.log(component.get("{! v.missions }"));
	},
	saveOffres: function(component, helper) {
		var saveAction = component.get("c.save");
    	saveAction.setParams({
    		leadId: component.get("{!v.simpleRecord.Lead__c}"),
    		transfertId: component.get("{!v.recordId}"),
    		missions: JSON.stringify(component.get("v.missions"))
    	});
    	saveAction.setCallback(this, function(res) {
    		if(res.getState() === "SUCCESS") {
    			this.showToast("success", "Succès", "Les offres ont bien été enregistrées sur la Lead");
    			// start lead conversion
    			this.convertLead(component, this);
    		} else {
    			this.toggleSpinner(component, "hide");
				this.showToast("error", "Erreur", this.findErrorMessage(component, this, res));
    		}
    	});
    	$A.enqueueAction(saveAction);
	},
	convertLead: function(component, helper) {
		var convertLeadAction = component.get("c.leadConversion");
		convertLeadAction.setParams({
			leadId: component.get("{!v.simpleRecord.Lead__c}"),
			oppId: component.get("{!v.oppId}")
			//offresIds: component.get("v.offreOptionsSelected").join(";")
		});
		convertLeadAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				this.showToast("success", "Succès", "La lead a été convertie");
				
				component.set("{!v.accountId}", res.getReturnValue()[0]);
				component.set("{!v.contactId}", res.getReturnValue()[1]);
				component.set("{!v.oppId}", res.getReturnValue()[2]);
				this.saveAccountIdOnTransfert(component, this);
			} else {
				this.toggleSpinner(component, "hide");
				this.showToast("error", "Erreur", this.findErrorMessage(component, this, res));
			}
		});
		$A.enqueueAction(convertLeadAction);
	},
	saveAccountIdOnTransfert: function(component, helper) {
		var saveAccountIdOnTransfertAction = component.get("c.saveAccountId");
		saveAccountIdOnTransfertAction.setParams({
			transfertId: component.get("{!v.recordId}"),
			accountId: component.get("{!v.accountId}"),
			oppId: component.get("{!v.oppId}")
		});
		saveAccountIdOnTransfertAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				this.linkSurveysToContact(component, this);
			} else {
				this.toggleSpinner(component, "hide");
				this.showToast("error", "Erreur", this.findErrorMessage(component, this, res));
			}
		});
		$A.enqueueAction(saveAccountIdOnTransfertAction);
	},
	linkSurveysToContact: function(component, helper) {
		var linkSurveysOnContactAction = component.get("c.linkSurveysOnContact");
		linkSurveysOnContactAction.setParams({
			leadId: component.get("{!v.simpleRecord.Lead__c}"),
			contactId: component.get("{!v.contactId}"),
			accountId: component.get("{!v.accountId}")
		});
		linkSurveysOnContactAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				this.showToast("success", "Succès", "Enquêtes de satisfaction rattachées au contact.");
				this.passOnTransfertInfo(component, this);
			} else {
				this.toggleSpinner(component, "hide");
				this.showToast("error", "Erreur", this.findErrorMessage(component, this, res));
			}
		});
		$A.enqueueAction(linkSurveysOnContactAction);
	},
	passOnTransfertInfo: function(component, helper) {
		var addAECommentOnOppAction = component.get("c.passOnTransfertInfoToAccOpp");
		addAECommentOnOppAction.setParams({
			transfertId: component.get("{!v.recordId}"),
			accountId: component.get("{!v.accountId}"),
			oppId: component.get("{!v.oppId}")
		});
		addAECommentOnOppAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				this.sendToBGI(component, this);
			} else {
				this.toggleSpinner(component, "hide");
				this.showToast("error", "Erreur", this.findErrorMessage(component, this, res));
			}
		});
		$A.enqueueAction(addAECommentOnOppAction);
	},
	sendToBGI: function(component, helper) {
		var sendToBGIAction = component.get("c.sendToBaseGI");
		sendToBGIAction.setParams({
			accountId: component.get("{!v.accountId}"),
			oppId: (component.get("{!v.oppId}") === undefined ? component.get("{!v.simpleRecord.ConvertedOpportunity__c}") : component.get("{!v.oppId}")),
			//offresIds: component.get("v.offreOptionsSelected").join(";"),
			filesToAttach: component.get("v.offreDocsSelected")
		});
		sendToBGIAction.setCallback(this, function(res){
			if(res.getState() === "SUCCESS") {
				this.saveOffers(component, this);
				this.showToast("success", "Succès", "La BaseGI a été notifiée de la conversion.");
			} else {
				this.toggleSpinner(component, "hide");
				this.showToast("error", "Erreur", this.findErrorMessage(component, this, res));
				this.createLogError(component, this.findErrorMessage(component, this, res));
			}
		});
		$A.enqueueAction(sendToBGIAction);
	},
	saveOffers: function(component, helper) {
		var saveOffersAction = component.get("c.saveOffersOnAccount");
		saveOffersAction.setParams({
			accountId: component.get("{!v.accountId}"),
			idOffers: component.get("v.offreDocsSelected").join(";")
		});
		saveOffersAction.setCallback(this, function(res){
			if(res.getState() === "SUCCESS") {
				this.changeTransfertStatus(component, this);
				//this.sendEmailNotification(component, this);
			} else {
				this.toggleSpinner(component, "hide");
				this.showToast("error", "Erreur", this.findErrorMessage(component, this, res));
			}
		});
		$A.enqueueAction(saveOffersAction);
	},
	sendEmailNotification: function(component, helper) {
		console.log(component.get("v.offreDocsSelected"));
		var sendNotificationAction = component.get("c.sendEmailOrSmsToClient");
		sendNotificationAction.setParams({
			accountId: component.get("{!v.accountId}"),
			partnerAccountId: component.get("{!v.simpleRecord.Partenaire__c}"),
			sendEmail: true,
			filesToAttach: component.get("v.offreDocsSelected")
		});
		sendNotificationAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				this.showToast("success", "Succès", "Email envoyé au client.");
				this.sendSmsNotification(component, this);
			} else {
				this.toggleSpinner(component, "hide");
				this.showToast("error", "Erreur", this.findErrorMessage(component, this, res));
			}
		});
		$A.enqueueAction(sendNotificationAction);
	},
	sendSmsNotification: function(component, helper) {
		var sendNotificationAction = component.get("c.sendEmailOrSmsToClient");
		sendNotificationAction.setParams({
			accountId: component.get("{!v.accountId}"),
			partnerAccountId: component.get("{!v.simpleRecord.Partenaire__c}"),
			sendEmail:  false,
			filesToAttach: null
		});
		sendNotificationAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				this.showToast("success", "Succès", "SMS envoyé au client.");
				this.changeTransfertStatus(component, this);
			} else {
				this.toggleSpinner(component, "hide");
				this.showToast("error", "Erreur", this.findErrorMessage(component, this, res));
			}
		});
		$A.enqueueAction(sendNotificationAction);
	},
	changeTransfertStatus: function(component, helper) {
		var changeStatusAction = component.get("c.changeStatus");
		changeStatusAction.setParams({
			transfertId: component.get("{!v.recordId}")
		});
		this.toggleSpinner(component, "hide");
		changeStatusAction.setCallback(this, function(res) {
			$A.get('e.force:refreshView').fire();
		});
		$A.enqueueAction(changeStatusAction);
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
	toggleSpinner : function(component, state) {
        var spinner = component.find("spinner");
        if(state=="hide"){
            $A.util.addClass(spinner, "slds-hide");
        } else {
            $A.util.removeClass(spinner, "slds-hide");
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
    updateLeadInfo: function(component, helper) {
    	var updateLeadAction = component.get("c.updateLead");
    	updateLeadAction.setParams({
    		leadId: component.get("{!v.simpleRecord.Lead__c}"), 
    		firstName: component.get("{!v.simpleRecord.Lead__r.FirstName}"),
    		lastName: component.get("{!v.simpleRecord.Lead__r.LastName}"),
    		companyName: component.get("{!v.simpleRecord.Company__c}"),
    		email: component.get("{!v.simpleRecord.MailAddress__c}"),
    		mobilePhone: component.get("{!v.simpleRecord.MobilePhone__c}"),
    		branding: component.get("{!v.simpleRecord.Lead__r.Branding__c}")
    	});
    	updateLeadAction.setCallback(this, function(res) {
    		if(res.getState() === "SUCCESS") {
    			this.showToast("success", "Succès", "La lead a été mise à jour.");
    			component.set("{!v.suggestUpdate}", "false");
    			this.getOffresOptions(component);
    		} else {
    			this.showToast("error", "Erreur", this.findErrorMessage(component, this, res));
    		}
    	});
    	$A.enqueueAction(updateLeadAction);
    }
})