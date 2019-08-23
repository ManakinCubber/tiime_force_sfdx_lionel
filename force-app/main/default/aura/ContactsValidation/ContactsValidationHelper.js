({
	renderPage: function(component) {
		var records = component.get("v.allContacts"),
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber-2)*10, pageNumber*10);

        console.log('Helper renderPage pageNumber =='+pageNumber);
        console.log('Helper renderPage pageRecords =='+pageRecords);
        console.log('Helper renderPage records[pageNumber-1] =='+JSON.stringify(records[pageNumber-2]));

        component.set("v.currentContact", records[pageNumber-2]);
	},    
    checkCompanyFields: function(component) {
        let ok = true;
        let message = "";
        const company = component.get("v.companyObject");
        for(let key in company) {
            if(company[key] == null) {
                ok = false;
                message += "Le champ d'entreprise \"" + key.replace('__c', '').replace('_', ' ') + "\" est obligatoire.\n"; 
            }
        }

        if(!ok) {
            this.handleShowNotice(component, 'error', 'Validation', message, true);
        }
        return ok;
    },
    fetchContact: function(component){
        console.log('Helper fetchContact Begin');
        var accountId = component.get("v.recordId");
        var action = component.get("c.getStakeHolders");
        action.setParams({
            "accountId": accountId
        });
        this.showSpinner(component);
        action.setCallback(this, function(response){
	        if (response.getState() == "SUCCESS") {
	            var records = response.getReturnValue();
	            // console.log('Helper fetchContact records.length =='+records.length);
	            if(records.length == 0){
	                // console.log('Helper fetchContact records.length == 0');
	                // this.showToast(component, 'warning', 'Attention', 'Il n\'y a aucun contact à valider');
	                this.handleShowNotice(component, 'info', 'Validation', 'Il n\'y a aucun contact à valider', true);
	            }else{
	            	var singleStakePrincipal = false;
	            	var multipleStakePrincipal = false;
	            	records.forEach(function(record) {
	            		console.log(record['MainStakeholder__c']);
	            		if(record['MainStakeholder__c']){
	            			if(!singleStakePrincipal)singleStakePrincipal=true;
	            			else multipleStakePrincipal=true;
            			}
        			});
	            		
	            	if(!singleStakePrincipal){
	            		this.handleShowNotice(component, 'error', 'Validation', 'L\'entreprise n\'a pas de Stakeholder Principal.', true);
	            	}
	            	else if(multipleStakePrincipal){
	            		this.handleShowNotice(component, 'error', 'Validation', 'L\'entreprise a plusieurs de Stakeholder Principaux.', true);
	            	}
	                // console.log('Helper fetchContact records.length > 0');
	                else if(records[0]['Company__r']['ValidatedForAppWallet__c'] == true){
	                    // this.showToast(component, 'warning', 'Attention', 'Tous les contacts de cette entreprise ont déjà été validés');
	                    this.handleShowNotice(component, 'info', 'Validation', 'L\'entreprise a déjà été validée.', true);
	                }else{
	                    component.set("v.allContacts", records);
	                    // console.log("HelperJS records =="+JSON.stringify(records));
	                    component.set("v.maxPage", records.length + 1);            
	                    // console.log("HelperJS records[0] =="+JSON.stringify(records[0]));
	
	                    component.set("v.currentContact", records[0]);
	                    this.fetchPickListVal(component);
	                }
	            }
	
	            this.showSpinner(component,"hide");
            }else{
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log('errors ==='+JSON.stringify(errors));
                        this.handleShowNotice(component, 'error', 'Erreur', 'Une erreur est survenue lors du chargement de Stakeholders : '+errors[0].message, false);
                    }
                }else{
                    this.handleShowNotice(component, 'error', 'Erreur', 'Une erreur est survenue lors du chargement de Stakeholders.', false);
                }
            }
        });
        $A.enqueueAction(action);
        console.log('Helper fetchContact end');
    },

    fetchPickListVal: function(component) {
        console.log('Helper fetchPickListVal Begin');
        var action = component.get("c.fetchPicklistValues");
        var IncomOptionsList = [];
        var NetworthOptionsList = [];
        var ContactTypeList = [];
        action.setCallback(this, function(response) {
            console.log('Helper fetchPickListVal response.getState()='+response.getState());
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log('Helper allValues=='+JSON.stringify(allValues));
 
                if (allValues != undefined && allValues.length > 0) {
                    IncomOptionsList.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                    NetworthOptionsList.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                    contactTypes.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                var incomeOptions = allValues[0];
                var networthOptions = allValues[1];
                var contactTypes = allValues[2];
                console.log('Helper incomeOptions=='+incomeOptions);
                console.log('Helper networthOptions=='+networthOptions);
                for (var i = 0; i < incomeOptions.length; i++) {
                    IncomOptionsList.push({
                        class: "optionClass",
                        label: incomeOptions[i],
                        value: incomeOptions[i]
                    });
                }
                component.set("v.IncomOptions", IncomOptionsList);

                for (var i = 0; i < networthOptions.length; i++) {
                    NetworthOptionsList.push({
                        class: "optionClass",
                        label: networthOptions[i],
                        value: networthOptions[i]
                    });
                }
                component.set("v.NetworthOptions", NetworthOptionsList);

                for (var i = 0; i < contactTypes.length; i++) {
                    ContactTypeList.push({
                        class: "optionClass",
                        label: contactTypes[i],
                        value: contactTypes[i]
                    });
                }
                component.set("v.contactTypes", ContactTypeList);
            }
        });
        $A.enqueueAction(action);
        console.log('Helper fetchPickListVal end');
    },    
    showSpinner : function(cmp,state) {
        var spinner = cmp.find("spjSpinner");
        if(state =="hide"){
            $A.util.addClass(spinner, "slds-hide");
        } else {
            $A.util.removeClass(spinner, "slds-hide");
        }
    },
	validateForm: function(component,id) {
		console.log("begin validateForm");
		const fields = component.find(id);
		let allValid;

		if(Array.isArray(fields)) {
			allValid = fields.reduce(function (validFields, inputCmp) {
				inputCmp.showHelpMessageIfInvalid();
				return validFields && inputCmp.get('v.validity').valid;
			}, true);
		} else {
			fields.showHelpMessageIfInvalid();
			allValid = fields.get('v.validity').valid;
		}
		var hasError = id == 'contactField' ? this.dateUpdated(component) : this.checkApeCode(component);

		if (allValid && !hasError){
			component.set("v.errorMsg", "");
			component.set("v.showErrorMsg", false);
			return true;
		}else{
			component.set("v.errorMsg", " Remplir tous les champs obligatoires!");
			component.set("v.showErrorMsg", true);
			return false;
		}
    },
    checkApeCode: function(component) {
    	console.log("begin checkApeCode");
        let ape = component.get("v.companyObject.ApeCode__c");
        //console.log(ape[0]);
        
        var res = ((ape == null) || (ape == undefined) || (ape.length == 0));
        if(res) component.set("v.showErrorAPE", true);
        else component.set("v.showErrorAPE", false);
        console.log(component.get("v.showErrorAPE"));
        
        
    	if(!res){
	    	if(typeof(ape) == "object") { //Fix for when Proxy object (Locker Service)
	            ape = ape[0];
	            component.set("v.companyObject.ApeCode__c", ape);
	        }
    	}
        console.log("end checkApeCode");
    	
        return res
    },
    dateUpdated : function(component) {
        console.log('Helper dateUpdated begin');
        var correctDate = false;

        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();

        if(dd < 10){
            dd = '0' + dd;
        } 
        if(mm < 10){
            mm = '0' + mm;
        }
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        var dateInput = new Date(component.get("v.currentContact.Contact__r.Birthdate")).toString();
        if(dateInput == 'Invalid Date'){
            // console.log('################### Invalid Date==');
            // component.set("v.errorMsg", "Date invalide");
            // component.set("v.showErrorMsg", true);
            component.set("v.dateValidationError" , true);
            component.set("v.dateValidationErrorMsg" , "Date invalide");
            return true;
        } 
        if(component.get("v.currentContact.Contact__r.Birthdate") != '' && 
            component.get("v.currentContact.Contact__r.Birthdate") >= todayFormattedDate){

            component.set("v.dateValidationError" , true);
            component.set("v.dateValidationErrorMsg" , "La date d'anniversaire doit être antérieure à la date d'aujourd'hui.");
            return true;
        }else{
            component.set("v.dateValidationError" , false);
            return false;
        }
        console.log('Helper dateUpdated end');
    },
    updateContact: function(component) {        
        var currentContact = component.get("v.currentContact");
        console.log('### updateContact currentContact=='+JSON.stringify(currentContact));
        var maxPage = component.get("v.maxPage");
        var pageNumber = component.get("v.pageNumber");
        // var birthDate = new Date(component.get("v.currentContact.Contact__r.Birthdate")).toJSON();
        // console.log('### updateContact birthDate=='+birthDate);
        
        // Manual picklist values
        component.set('v.currentContact.Contact__r.IncomPerTranche__c', component.find("contactFieldIncomPerTranche").get("v.value"));
        component.set('v.currentContact.Contact__r.Networth__c', component.find("contactFieldNetworth").get("v.value"));
        component.set('v.currentContact.Contact__r.ContactType__c', component.find("contactFieldContactType").get("v.value"));
        component.set('v.currentContact.Contact__r.Salutation', component.find("contactFieldContactSalutation").get("v.value"));

        var action = component.get("c.updateContact");
        action.setParams({
            "contact": currentContact
            // ,"birthDate": birthDate
        });
        this.showSpinner(component);
        action.setCallback(this, function(result){
            var records = result.getReturnValue();
            if (result.getState() == "SUCCESS") {
            	//this.showToast(component, 'success', 'Succès', 'Le contact a bien été validé');
                // this.handleShowNotice(component, 'info', 'Succès', 'Le contact a bien été validé', false);
                // if(maxPage != pageNumber){
                //     component.set("v.nextBtnDisabled",false);
                // }

                // component.set("v.errorMsg", "");
                // component.set("v.showErrorMsg", false);

                component.set("v.dateValidationError" , false);
                component.set("v.dateValidationErrorMsg" , "");
                
                if(maxPage != pageNumber){
                    component.find("nextPage").nextPage();
                    component.set("v.validAccount",true);
                }else{
                    this.clickValidateAccount(component);
                    // component.set("v.validAccount",false);
                    return;
                }
            }else{
                var errors = result.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log('errors ==='+JSON.stringify(errors));
                        this.handleShowNotice(component, 'error', 'Erreur', 'Une erreur est survenue lors de la validation du contact : '+errors[0].message, false);
                    }
                }else{
                    this.handleShowNotice(component, 'error', 'Erreur', 'Une erreur est survenue lors de la validation du contact.', false);
                }
            }
            this.showSpinner(component,"hide");
        });
        $A.enqueueAction(action);
    },
    checkAllConValidated: function(component) {
          
    },    
    showToast : function(component, type, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: msg,
            messageTemplate: 'Mode is dismissible ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },    
    handleShowNotice : function(component, type, title, msg, closeWindow) {
        console.log("handleShowNotice type=="+type);
        component.find('notifLib').showNotice({
            "variant": type,
            "header": title,
            "message": msg,
            closeCallback: function() {
                if(closeWindow){
                    $A.get("e.force:closeQuickAction").fire();
                }  
            }
        });
    },
    clickValidateAccount: function(component) {
        console.log('Controller clickValidateAccount Begin');
        this.enableWallet(component);
        console.log('Controller clickValidateAccount end');
    },
    enableWallet: function(component) {
        var action = component.get("c.enableWallet");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.handleShowNotice(component, "info", "Succès", "Wallet a bien été activé", true);
                this.changeWalletStatus(component);
            } else {
                let errors = response.getError();
                let message = "";
                if (errors && Array.isArray(errors) && errors.length > 0) {
                	for(let key in errors) {
                		message += errors[key].message + '\n';
                	}
                } else {
                	message = "Une erreur interne est survenue";
                }
                this.handleShowNotice(component, "error", "Erreur", "Erreur lors de l'activation de Wallet :\n" + message, false);
                console.log("Failed with state: " + state);
                console.error(message);
            }
            this.showSpinner(component,"hide");
        });
        this.showSpinner(component);
        $A.enqueueAction(action);
    },
    changeWalletStatus: function(component) {
    	var changeStatusAction = component.get("c.changeStatusWallet");
    	changeStatusAction.setParams({
    		accountId: component.get("v.recordId")
    	});
    	$A.enqueueAction(changeStatusAction);
    },
    updateCompany: function(component) {
        const helper = this;
        helper.showSpinner(component);

        // Manual picklist values
        component.set('v.companyObject.LastNetIncome__c', component.find("companyFieldLastNetIncome").get("v.value"));
        component.set('v.companyObject.AnnualTurnover__c', component.find("companyFieldAnnualTurnover").get("v.value"));
        component.set('v.companyObject.NumberOfEmployees__c', component.find("companyFieldNumberOfEmployees").get("v.value"));
        component.set('v.companyObject.LegalStatus__c', component.find("companyFieldLegalStatus").get("v.value"));

        component.find("recordLoader").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                component.set("v.pageNumber", 2);
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
                helper.handleShowNotice(component, 'error', 'Erreur', 'Impossible de mettre à jour l\'entreprise. Vérifiez votre connexion internet.', false);
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error[0].message));
                helper.handleShowNotice(component, 'error', 'Erreur', 'Une erreur est survenue lors de la mise à jour de l\'entreprise : ' + JSON.stringify(saveResult.error[0].message), false);
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                helper.handleShowNotice(component, 'error', 'Erreur', 'Une erreur est survenue lors de la mise à jour de l\'entreprise : ' + JSON.stringify(saveResult.error[0].message), false);
            }
            helper.showSpinner(component,"hide");
        }));
    },
    updatePicklist: function(component, field, list) {
        const values = [];
        for(let key in list) {
            values.push({label: key, value: list[key]});
        }
        component.set("v." + field, values);
    }
})