({
	horodatageLeadBack : function(component, helper) {	
		var action = component.get("c.horodatageLeadBackPC");
		action.setParams({
			startId: component.get("v.recordId"),
			leadId: component.get("v.startRecord.Crea__c") 
		});
		action.setCallback(this, function(response) {
			var state = response.getState();

			if (component.isValid() && state === "SUCCESS") {
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
				} else {console.log("Unknown error");}
			}
		});
		$A.enqueueAction(action);
	}
})