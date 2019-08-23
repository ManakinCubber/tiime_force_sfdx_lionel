({
	updateMailBody : function(cmp, event, helper) {
		helper.formatDate(cmp);
		helper.updateMailBody(cmp);
	},
	updateContacts: function(cmp, event, helper) {
		helper.updateContacts(cmp, helper);
		helper.switchShowPhysique(cmp);
	},
	handleRecordUpdated: function(cmp, event, helper) {
		var eventParams = event.getParams();
		if(eventParams.changeType === "LOADED" || eventParams.changeType === "CHANGED") {
			cmp.set("v.CanBeTransferred", (cmp.get("v.LeadObject.Status")!="Partenaire"))
			helper.updateFirms(cmp, helper);
			if(!cmp.get("v.LeadObject.RDV_EC_confirmer__c")) {
				cmp.set("v.LeadObject.RDV_EC_confirmer__c", 'Non');
			}
		}
	},
	save : function(component,event,helper) {
		helper.save(component,event,helper);
	},
	changeOwnerToEcTrouver : function(component,event,helper) {
		var action = component.get("c.changeStatusToECaTrouver");
		action.setParams({
			leadId: component.get("v.LeadObject.Id"),
		});
		helper.showSpinner(component,"");
		action.setCallback(this, function(res) {
			if (res.getState() === "SUCCESS") {
				helper.showToast("success", "Succès", "La Lead est passée en Status 'EC à Trouver' !");
				component.find("ECaTrouver").set("v.variant", "success");
				$A.get('e.force:refreshView').fire();
			}
			else{
				helper.showToast("error", "Erreur", "Une erreur est survenue.");
			}
			helper.showSpinner(component, "hide");
		});
		$A.enqueueAction(action);
	},
	newTransfert : function(component) {
		component.set("v.CanBeTransferred", true);
		component.set("v.Is_Appointment_Set__c", false);
		component.set("v.LeadObject.Partenaire__c", null);
		
		// reset field Is_Appointment_Set__c to false
		var newTransfertChangeAction = component.get("c.changeAptPlannedForNewTransfert");
		newTransfertChangeAction.setParams({
			leadId: component.get("v.LeadObject.Id"),
			isAptPlanned: false
		});
		$A.enqueueAction(newTransfertChangeAction);
	}

})