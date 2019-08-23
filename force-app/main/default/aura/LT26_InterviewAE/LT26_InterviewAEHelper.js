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
	retrieveLeadData : function(component) {
		var getLeadAction = component.get("c.retrieveLead");
		getLeadAction.setParams({
			transfertId : component.get("{!v.recordId}")
		});
		getLeadAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				component.set("{!v.leadRecord}", res.getReturnValue());
			}
		});
		$A.enqueueAction(getLeadAction);
	},
	cleanLeadFields : function(component, payload) {
		payload.MobilePhone = component.get("{!v.leadRecord}").Mobilephone;
		payload.Email = component.get("{!v.leadRecord}").Email;
		payload.LastName = component.get("{!v.leadRecord}").LastName;
		payload.Company = component.get("{!v.leadRecord}").Company;
		if(payload.Canal__c == "partenariats") {
			payload.Detail__c = "";
			payload.CustomerRecommendation__c = null;
		} else if(payload.Canal__c == "events") {
			payload.Partnership__c = null;
			payload.Detail__c = "";
			payload.CustomerRecommendation__c = null;
		} else if(payload.Canal__c == "reco-client") {
			payload.Partnership__c = null;
			payload.Event__c = null;
			payload.Detail__c = "";
		} else {
			payload.Partnership__c = null;
			payload.Event__c = null;
			payload.CustomerRecommendation__c = null;
		}
		return payload;
	},
	showToast: function(type, title, message) {
		var resultsToast = $A.get("e.force:showToast");
		resultsToast.setParams({
			title: title,
			message: message,
			type: type
		});
		resultsToast.fire();
	}
})