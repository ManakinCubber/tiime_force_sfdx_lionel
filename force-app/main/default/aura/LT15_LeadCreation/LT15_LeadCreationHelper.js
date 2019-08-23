({
	doInit: function(component) {
		component.find("recordCreator").getNewRecord(
				"Lead", // sObject type (entityApiName)
				null, // recordTypeId
				false, // skip cache?
				$A.getCallback(function() {
					var rec = component.get("v.LeadObject");
					var error = component.get("v.recordError");
					if(error || (rec === null)) {
						console.log("Error initializing record template: " + error);
						return;
					}

					component.find('qualification').doInit();
				})
		);
	},
	reload: function(component) {
		component.set('v.show', false);
		setTimeout(function() {
			component.set('v.show', true);
			this.doInit(component);
		}.bind(this), 0);
	},
	validateForm: function(component) {
		// Show error messages if required fields are blank
		var allValid = component.find('leadField').reduce(function (validFields, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return inputCmp.get('v.validity').valid;
		}, true);

		allValid = this.validateInputField(component, component.get('v.simpleRecord.OrigineWebsite__c'), 'leadOriginField', 'originError') && allValid;
		allValid = this.validateInputField(component, component.get('v.simpleRecord.Canal__c'), 'leadCanalField', 'canalError') && allValid;
		// allValid = this.validateInputField(component, component.get('v.simpleRecord.Detail__c'), 'leadDetailField', 'detailError') && allValid;
		allValid = this.validateInputField(component, component.get('v.simpleRecord.MeansOfContact__c'), 'leadMeansOfContactField', 'meansOfContactError') && allValid;

		return allValid;
	},
	validateInputField: function(component, value, fieldId, errorId) {
		if(value == '') {
            this.showToast('error', 'Échec' , 'Des champs sont manquants.');
			$A.util.addClass(component.find(fieldId), 'slds-has-error');
			component.set('v.' + errorId, 'Remplissez ce champ.');
			return false;
		} else {
			$A.util.removeClass(component.find(fieldId), 'slds-has-error');
			component.set('v.' + errorId, null);
			return true;
		}
	},
	removeProxy: function(component, attribute) {
			let realAttribute = JSON.parse(JSON.stringify(component.get(attribute)));

			if(Array.isArray(realAttribute)) realAttribute = realAttribute[0];
			component.set(attribute, realAttribute);
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
	showSpinner : function(cmp,state) {
		var spinner = cmp.find("spjSpinner");
		if(state =="hide"){
			$A.util.addClass(spinner, "slds-hide");
		} else {
			$A.util.removeClass(spinner, "slds-hide");
		}
	},
  createClicked: function(component, helper, isQueued, isHorsCible) {
		if(helper.validateForm(component)) {
			helper.showSpinner(component, 'show');

			helper.removeProxy(component, 'v.simpleRecord.Event__c');
			helper.removeProxy(component, 'v.simpleRecord.CustomerRecommendation__c');
            helper.removeProxy(component, 'v.simpleRecord.Partnership__c');

			component.find("recordCreator").saveRecord(function(saveResult) {
				if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
					helper.showToast('success', 'Lead créée !' , 'La lead a été créée.');
					$A.get("e.force:closeQuickAction").fire();
                    var redirect;
                    if(isQueued) {
                        if(isHorsCible){
                            component.find("leadBack").doInit();
                        }
                        redirect = $A.get("e.force:navigateToObjectHome");
                        redirect.setParams({
                            "scope":'Lead'
                        });
                    } else {
                        redirect = $A.get("e.force:navigateToSObject");
					redirect.setParams({
						"recordId": component.get('v.simpleRecord.Id')
					});
                    }
                    
					redirect.fire();
                    if(!isQueued) {
						helper.reload(component);
                    }
                    
				} else if (saveResult.state === "INCOMPLETE") {
					console.log("User is offline, device doesn't support drafts.");
					helper.showToast('error', 'Échec' , 'Vous êtes hors-ligne. Vérifiez votre connexion internet.');
				} else if (saveResult.state === "ERROR") {
					const error = JSON.stringify(saveResult.error);
					console.log('Problem saving contact, error: ' + error);
					helper.showToast('error', 'Échec' , saveResult.error[0].message);
				} else {
					const error = JSON.stringify(saveResult.error);
					console.log('Unknown problem, state: ' + saveResult.state + ',error: ' + error);
					helper.showToast('error', 'Échec' , error);
				}
				helper.showSpinner(component, 'hide');
			}.bind(this));
		}
	},
	createAndWaitingList : function(component, helper) {
		var action = component.get("c.getLeadEnAttenteId");
		action.setCallback(this, function(res) {
			if (res.getState() === "SUCCESS") {
				component.set("v.simpleRecord.OwnerId", res.getReturnValue());
				//helper.showToast("success", "Succès", "La Lead est passée en file d'attente.");
			}
			else{
				helper.showToast("error", "Erreur", "Une erreur est survenue.");
			}
            helper.createClicked(component, helper, true, false);
		});
		$A.enqueueAction(action);
	},
	fixRecordType : function(component) {
		var action = component.get("c.fixRecordType");
		action.setParams({
				leadId: component.get('v.simpleRecord.Id'),
				canal: component.get('v.simpleRecord.Canal__c')
		});
		this.showSpinner(component,"");
		action.setCallback(this, function(res) {
			if (res.getState() === "SUCCESS") {
			}
			else if(res.getState() === "ERROR"){
				var errors = res.getError();
				console.log(errors);
				if (errors) {
					if (errors[0] && errors[0].message) {
						this.showToast(component, "error", "Erreur", "La modification du RecorType à échoué ! \n"+errors[0].message);
						console.log("Error message: " + errors[0].message);
					}
					else{
						console.log("La modification du RecorType à échoué ! Error sans message... ");
					}
				} else {
					this.showToast(component, "error", "Erreur", "La modification du RecorType à échoué !");
				}
			}
			this.showSpinner(component, "hide");
		});
		$A.enqueueAction(action);
	},
	getLabels : function(component) {
    	var u = component.get("c.getLabels");
        u.setCallback(this, function(res) {
            if (res.getState() === "SUCCESS") {
                component.set("v.labels",res.getReturnValue());
            } else {
                console.log("Failed with state: " + res.state);
            }
        });        
        $A.enqueueAction(u);
    },
	getContactPartenariat : function(component,helper,isInit){
		if(component.get("v.simpleRecord.Partnership__c") != null && component.get("v.simpleRecord.Partnership__c").length > 0) {
			var action = component.get("c.getContactPartenariat");
			action.setParams({
				accountId: helper.fixTypeOfPartnership(component)
			});
			action.setCallback(this, function(res) {
				if (res.getState() === "SUCCESS") {
					component.set("v.ListContactPartenariat", res.getReturnValue());
				}
				else if(res.getState() === "ERROR") {
					var errors = res.getError();
					console.log(errors[0].message);
				}
			});
			$A.enqueueAction(action);
		}
        else {
            component.set("v.ListContactPartenariat", []);
        }
    },
    fixTypeOfPartnership : function(component) {
    	return typeof component.get("v.simpleRecord.Partnership__c") === 'string' ? 
                component.get("v.simpleRecord.Partnership__c") : 
            	component.get("v.simpleRecord.Partnership__c")[0];
    },
	lookupSearch : function(component, event, helper) {
        // Get the lookup component that fired the search event
        const lookupComponent = event.getSource();
        // Get the SampleLookupController.search server side action
        const serverSearchAction = component.get('c.search');
        // You can pass optional parameters to the search action
        // but you can only use setParam and not setParams to do so
        serverSearchAction.setParam('anOptionalParam', 'not used');
        // Pass the action to the lookup component by calling the search method
        lookupComponent.search(serverSearchAction);
    },

	clearErrorsOnChange: function(component, event, helper) {
        const selection = component.get('v.selection');
        const errors = component.get('v.errors');

        if (selection.length && errors.length) {
            component.set('v.errors', []);
		}
    }
})