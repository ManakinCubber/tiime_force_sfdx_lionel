({
    doInit: function(component, event, helper) {
        const action = component.get("c.getCompanyPicklistValues");
        action.setCallback(this, function(result) {
            if(result.getState() === "SUCCESS") {
                const list = result.getReturnValue();
                helper.updatePicklist(component, 'turnovers', list['turnovers']);
                helper.updatePicklist(component, 'employees', list['employees']);
                helper.updatePicklist(component, 'incomes', list['incomes']);
                helper.updatePicklist(component, 'legalForms', list['legalForms']);
                helper.updatePicklist(component, 'contactSalutation', list['contactSalutation']);
            } else {
                console.log("Failed retrieving annual turnover picklist values, with state: " + result.getState());
            }
        });
        $A.enqueueAction(action);
    },
    clickValidate: function(component, event, helper) {
        console.log("Controller clickValidate begin");
        const page = component.get("v.pageNumber");
        console.log("page : "+page);
        if(page == 1) {
            console.log("Validating company fields");
            
            if(helper.validateForm(component, 'companyField') && helper.validateForm(component, 'companyFieldAnnualTurnover') &&
               helper.validateForm(component, 'companyFieldLastNetIncome') && helper.validateForm(component, 'companyFieldNumberOfEmployees') &&
               helper.validateForm(component, 'companyFieldLegalStatus')) {
                helper.updateCompany(component);
            }
        } else if(helper.validateForm(component, 'contactField') && helper.validateForm(component, 'contactFieldIncomPerTranche') &&
				  helper.validateForm(component, 'contactFieldNetworth') && helper.validateForm(component, 'contactFieldContactType') &&
				  helper.validateForm(component, 'contactFieldContactSalutation')) {
            helper.updateContact(component);          
        }

        console.log("Controller clickValidate end");
    },
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },
    handlerevtLockValidateBtn: function(component, event, helper) {
        console.log('Controller handlerevtLockValidateBtn Begin');

        component.set("v.validAccount",true);

        console.log('Controller handlerevtLockValidateBtn End');
    },
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            helper.fetchContact(component);
        } else if(eventParams.changeType === "ERROR") {
            helper.handleShowNotice(component, 'error', 'Erreur de chargement', component.get("v.recordError"), true);
        }
    },
    clickClose: function() {
        $A.get("e.force:closeQuickAction").fire();
    },
    checkIfValid: function(component, event, helper){
    	var inputField = event.getSource();
    	var inputLabel = inputField.get("v.label");
    	console.log(inputLabel);
    	var inputValue = event.getSource().get("v.value"); 
    	var message = '';
    	var taille = 0;
    	if(inputLabel == 'Siret'){
    		message = 'le SIRET comporte 14 numeros';
    		taille = 14
    	}

    	if (inputValue.length != taille) {
    		inputField.setCustomValidity(message); 
    		inputField.reportValidity();
    	}
    	else{
	    	 inputField.setCustomValidity('');
	    	 inputField.reportValidity();
    	 }
    }
})