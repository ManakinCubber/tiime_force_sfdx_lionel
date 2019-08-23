({
    doInit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        component.set("v.simpleRecord.Status", "Call 1" );
        component.set("v.simpleRecord.Partenaire__c", "");
        component.set("v.simpleRecord.Contact_Partenaire__c", "");

        component.find("TheRecord").saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // record is saved successfully
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Succès",
                    "message": "La lead a été remise en Call 1.",
                    "type" : "success"
                });
                resultsToast.fire();
            } else if (saveResult.state === "INCOMPLETE") {
                // handle the incomplete state
                console.log("User is offline, device doesn't support drafts.");
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Erreur",
                    "message": "Vous n'êtes pas connecté. Vérifiez votre connexion internet.",
                    "type" : "error"
                });
            } else if (saveResult.state === "ERROR") {
                // handle the error state
                console.log('Problem saving contact, error: ' + 
                             JSON.stringify(saveResult.error));

                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Erreur",
                    "message": "Erreur lors de l'assignation de la lead.",
                    "type" : "error"
                });
            } else {
                console.log('Unknown problem, state: ' + saveResult.state +
                            ', error: ' + JSON.stringify(saveResult.error));
            }
        });
    }
})