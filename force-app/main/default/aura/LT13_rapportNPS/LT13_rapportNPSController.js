({
	doInit : function(component, event, helper) {
		helper.getLabels(component);
		var action = component.get("c.getEnquetes");
		action.setParams({
			AccountId: component.get("v.recordId"),
		});
		action.setCallback(this, function(res) {
			if (res.getState() === "SUCCESS") {
				var result = res.getReturnValue();
				console.log(result[0]);
				component.set("v.allEnquetes", result);
				component.set("v.nbEnquetes", result.length);
				helper.calculNPS(component, event, helper, result);
			}
			else{
				console.log("erreur ! !");
			}
		});
		$A.enqueueAction(action);
		
	}
})