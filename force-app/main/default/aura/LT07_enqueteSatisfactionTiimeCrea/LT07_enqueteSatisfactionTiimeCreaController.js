({
    doInit: function(component, event, helper) {
    	helper.getLabels(component);
        helper.initPickLists(component);
    },
    handleSaveRecord: function(component, event, helper) {
        component.find("TheRecord").saveRecord($A.getCallback(function(saveResult) {
            // NOTE: If you want a specific behavior(an action or UI behavior) when this action is successful 
            // then handle that in a callback (generic logic when record is changed should be handled in recordUpdated event handler)
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // handle component related logic in event handler
                helper.showToast(component, 'SUCCESS', 'Enregistrée', 'L\'enquête a été enregistrée');
            } else if (saveResult.state === "INCOMPLETE") {
            	helper.showToast(component, 'warning', 'INCOMPLETE', "User is offline, device doesn't support drafts.");
        	} else {
            	var error = saveResult.error[0].message;
                helper.showToast(component, 'Error', 'Erreur', error);
            }
        }));
    },
    switchValueCheckB: function(component, event, helper) {
    	var checkbox = event.getSource().get("v.checked");
    	var name = event.getSource().get("v.name");
    	component.set("v.simpleRecord."+name, checkbox);
    },

})