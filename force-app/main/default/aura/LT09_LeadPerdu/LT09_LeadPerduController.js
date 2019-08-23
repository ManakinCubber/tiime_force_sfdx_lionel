({
	clickValidate : function(component, event, helper) {
		component.set("v.simpleRecord.Status", "Perdu");
        component.find("TheRecord").saveRecord($A.getCallback(function(saveResult) {
        console.log(saveResult.state);
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
            	component.find("validation").set("v.label", "la Lead est perdu");
            	component.find("validation").set("v.variant", "success");
	            helper.showToast(component, 'SUCCESS', 'SUCCESS', 'Informations enregistrées'); 
            } else if (saveResult.state === "ERROR" || saveResult.state === "INCOMPLETE") {
            	component.find("validation").set("v.variant", "brand");
            	let errors = JSON.stringify(saveResult.error);
            	console.log(errors);
                helper.showToast(component, 'ERROR', 'Attention', 'Il y a eu un problème lors de la modification, certains champs sont incorrects');
            }
            helper.showSpinner(component,"hide");
        }));
	},
})