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
            helper.updateFirms(cmp, helper);
		}
	},
	sendEmail : function(component,event,helper) {
		helper.sendEmail(component,event,helper);
	},
    newRDV : function(cmp) {
        cmp.set("v.rdvProgramme", false);
    }

})