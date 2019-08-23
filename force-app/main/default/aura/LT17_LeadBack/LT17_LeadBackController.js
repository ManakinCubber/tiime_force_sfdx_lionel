({
	doInit: function(component, event, helper) {

		var action = component.get("c.backLead");
		action.setParams({
			leadId: component.get("v.recordId"),
			type : component.get("v.type")
		});

		action.setCallback(this, function(response) {
			var state = response.getState();

			if (component.isValid() && state === "SUCCESS") {
				helper.showToast("success", "Succès", "La lead a été renvoyée.");
			} else if (component.isValid() && state === "INCOMPLETE") {
				helper.showToast("error", "Erreur", "L'action n'a pas abouti.");
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						helper.showToast("error", "Erreur", errors[0].message);
						console.log("Error message: " + errors[0].message);
					}
				} else {
					helper.showToast("error", "Erreur", "Une erreur est survenue.");
					console.log("Unknown error");
				}
			}

			$A.get("e.force:closeQuickAction").fire();
		});

		$A.enqueueAction(action);
	}
})