({
	sendToTreezor : function(component, event, helper) {
		
	
		var callTreezorAction = component.get("c.sendAccountToTreezor");
		
		callTreezorAction.setParams({
			chronosAccountId : component.get("{!v.accountObject.ChronosId__c}")
		});
	
		helper.showSpinner(component); //enable spinner
		helper.buttonAction(component,event); //disable button
		
		callTreezorAction.setCallback(this, function(result){
			if(result.getState()==="SUCCESS") {
				helper.toast(component,"Succès de l'envoi",result.getState(), "Le compte a bien été envoyé à Treezor.");
				helper.changeStatus(component);
			} else {
                console.log("Failed retrieving files, with state: " + result.getState());
                
                helper.toast(component, "Echec de l'envoi", "ERROR", result.error[0].message);
                helper.buttonAction(component,event); //enable button
            }
            helper.showSpinner(component,"hide"); //disable spinner
		});
		
		$A.enqueueAction(callTreezorAction);
	}
})