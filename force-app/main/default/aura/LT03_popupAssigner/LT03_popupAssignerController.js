({
	doInit : function(component, event, helper) {
		var ownerNameLead = component.get("v.LeadObject.Owner.Name");
		console.log("ownerNameLead: "+ownerNameLead);
		
		// Owner name n'a pas le temps de se mettre à jour assez vite, 
		//donc utilisation d'un flag pour que le popup ne s'ouvre plus après l'assignation.
		if((ownerNameLead == "Leads en attente" || ownerNameLead == "Leads EC à trouver" || ownerNameLead == "Leads en attente Call 2 et +") && component.get("v.componentActif")) { 
			console.log("begin popup to change owner");
			helper.openModel(component, event);
		}else console.log("Lead déjà assigné !");
	},
	
	openModel: function(component, event, helper) {
      helper.openModel(component, event);
	},
 
	closeModel: function(component, event, helper) {  
      helper.closeModel(component, event);
	},
	
	assigner : function(component, event, helper){	
		helper.showSpinner(component);
		var userId = $A.get("$SObjectType.CurrentUser.Id");
		//console.log("userIdCurrent : "+userId);
	    component.set("v.LeadObject.OwnerId", userId );
	    if(component.get("v.LeadObject.DateAssignation__c") == null) {
	    	component.set("v.LeadObject.DateAssignation__c", new Date());
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
	            component.set("v.componentActif", false);
	            resultsToast.fire();
	        } else if (saveResult.state === "INCOMPLETE") {
	            // handle the incomplete state
	            console.log("User is offline, device doesn't support drafts.");
	        } else if (saveResult.state === "ERROR") {
	            // handle the error state
	            console.log('Problem saving contact, error: ' + 
	                         JSON.stringify(saveResult.error));
	        } else {
	            console.log('Unknown problem, state: ' + saveResult.state +
	                        ', error: ' + JSON.stringify(saveResult.error));
	        }
	        helper.showSpinner(component,"hide");
	        helper.closeModel(component, event);

	        helper.checkNotify(component);
	    });
	    
	},

	closeNotify: function(component, event, helper) {
		component.set('v.isNotifyOpen', false);
	}
})