({
	handleClick : function(component, event, helper) {
		component.set('v.showSpinner', !component.get('v.showSpinner'));
		var action = component.get("c.sendToSupportTiime");
		action.setParams({
			requestId: component.get("v.recordId")
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
                component.set('v.showSpinner', !component.get('v.showSpinner'));
				helper.showToast("success", "Succès", "La lead a été envoyée en file d'attente Support Tiime.");
                $A.get('e.force:refreshView').fire();
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
		});

		$A.enqueueAction(action);
	}
})