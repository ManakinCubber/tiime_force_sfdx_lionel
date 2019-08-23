({
	doInit: function(component, event, helper) {
		helper.init(component,event,helper);
		helper.getLabels(component);

		if(event.getParams().changeType == "CHANGED") {
			component.find("TheRecord").reloadRecord();
		}

		if(component.find('qualification') != undefined) {
			component.find('qualification').doInit();
		}
	},
	clickValidate : function(component, event, helper) {
		if(helper.checkRappel(component)) {
			if(component.get("v.simpleRecord.Activity__c") != "") {
				component.set("v.simpleRecord.QualificationDone__c", true);
			}
			helper.validation(component, helper);
		}
	},
	switchAppelerPlusTard : function(component, event, helper) {
		var newValue = !(component.get("v.showRappelerPlusTard"));
		component.set("v.showRappelerPlusTard", newValue);
		if(!newValue) {
			component.find('qualification').doInit();
		}
	},
	changeToNextCall : function(component,event,helper) {	
		var call = component.get("v.currentCall");
		var MapMessage = component.get("v.MapMessageNextCall");
		if(MapMessage[call] != undefined){
			var action = component.get("c.nextCall");
			action.setParams({
				leadId: component.get("v.recordId"),
				status: call,
				branding: component.get("v.simpleRecord.Branding__c")
			});
			helper.showSpinner(component,"");
			action.setCallback(this, function(res) {
				if (res.getState() === "SUCCESS") {
					call = res.getReturnValue();
					helper.setNextCall(component);
					helper.showToast(component, "success", "Succès", "La Lead est passée au "+call+" !");
					if(MapMessage[call] == undefined) component.set("v.showNextCall", false);
					$A.get('e.force:refreshView').fire();
				}
				else if(res.getState() === "ERROR"){
					var errors = res.getError();
					console.log(errors);
					if (errors) {
						if (errors[0] && errors[0].message) {
							helper.showToast(component, "error", "Erreur", "La Lead n'a pas changé de Statut ! \n"+errors[0].message);
							console.log("Error message: " + errors[0].message);
						}
						else{
							console.log("Error sans message... ");
						}
					} else {
						helper.showToast(component, "error", "Erreur", "La Lead n'a pas changé de Statut !");
					}
				}
				helper.showSpinner(component, "hide");
			});
			$A.enqueueAction(action);
		}
	},
	contactPartenariat : function(component,event,helper) {
		helper.getContactPartenariat(component, helper, false);
	},
	selectContactPartenariat : function(component, event, helper){
		component.set("v.simpleRecord.ContactPartenariat__c", component.find("selectContactPartenariat").get("v.value"));
	}
})