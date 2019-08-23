({
    doInit: function(component, event, helper) {
        var u = component.get("c.getLabels");
        u.setCallback(this, function(res) {
            if (res.getState() === "SUCCESS") {
                component.set("v.labels",res.getReturnValue());
            } else {
                alert('Erreur lors de la création du composant "Enquête de satisfaction" \n'+res.getState());
                console.log("Failed with state: " + res.state);
            }
        });
        $A.enqueueAction(u);
    },
    handleSaveRecord: function(component, event, helper) {
        component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
            // NOTE: If you want a specific behavior(an action or UI behavior) when this action is successful 
            // then handle that in a callback (generic logic when record is changed should be handled in recordUpdated event handler)
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // handle component related logic in event handler
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Enregistrée",
                    "type":"success",
                    "key":"like",
                    "message": "L'enquête a été enregistrée"
                });
                resultsToast.fire();
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
    }
})