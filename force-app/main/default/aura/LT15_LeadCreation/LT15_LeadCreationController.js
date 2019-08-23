({
	doInit: function(component, event, helper) {
		helper.doInit(component,helper);
		helper.getLabels(component);
	},
	createAndWaitingList : function(component, event, helper) {
		helper.createAndWaitingList(component, helper);
	},
	createClicked: function(component, event, helper) {
		if (component.get('v.selection').length > 0){
			// Set the right field selection field Id is a Contact Id for the Stakeholder
			if (component.get('v.selection')[0].sObjectType == 'Stakeholder__c'){
				component.set('v.simpleRecord.CustomerRecommendation__c', component.get('v.selection')[0].id);
				component.set('v.simpleRecord.LeadRecommendation__c', '');
			}
			if (component.get('v.selection')[0].sObjectType == 'Lead'){
				component.set('v.simpleRecord.LeadRecommendation__c', component.get('v.selection')[0].id);
				component.set('v.simpleRecord.CustomerRecommendation__c', '');
			}
		}
		helper.createClicked(component, helper, false, false);
	},
	contactPartenariat : function(component,event,helper) {
		helper.getContactPartenariat(component, helper, false);
	},
	selectContactPartenariat : function(component, event,helper){
		component.set("v.simpleRecord.ContactPartenariat__c", component.find("selectContactPartenariat").get("v.value"));
	},
    horsCibleretourSDR : function(component, event,helper){
		component.set("v.simpleRecord.WebFormComments__c", "Le prospect est une recommandation faite par un client '" + component.get("v.simpleRecord.OrigineWebsite__c") + "', à rappeler sous Tiime");
        helper.createClicked(component, helper, true, true);
	},
	lookupSearch : function(component,event,helper) {
		helper.lookupSearch(component, event, helper);
	},
	clearErrorsOnChange : function(component,event,helper) {
		helper.clearErrorsOnChange(component, event, helper);
	}
})