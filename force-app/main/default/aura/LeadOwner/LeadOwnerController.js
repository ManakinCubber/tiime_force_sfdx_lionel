({
    doInit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.simpleRecord.OwnerId", userId );
        if(component.get("v.simpleRecord.DateAssignation__c") == null) {
        	component.set("v.simpleRecord.DateAssignation__c", new Date());
        }

        component.find("TheRecord").saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // record is saved successfully
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Succès",
                    "message": "La lead vous a été assignée.",
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