({	
	init : function(component,event, helper) {
		var eventParams = event.getParams();
		if(eventParams.changeType === "LOADED") {
			component.set("v.DateRappelInit", component.get("v.simpleRecord.CallBackDate__c"));
			helper.setNextCall(component);
			helper.getContactPartenariat(component, helper, true);
	    } 
	},
	removeProxy: function(component, attribute) {
			let realAttribute = JSON.parse(JSON.stringify(component.get(attribute)));

			if(Array.isArray(realAttribute)) realAttribute = realAttribute[0];
			component.set(attribute, realAttribute);
	},
    showSpinner : function(cmp,state) {
        var spinner = cmp.find("spjSpinner");
        if(state =="hide"){
            $A.util.addClass(spinner, "slds-hide");
        } else {
            $A.util.removeClass(spinner, "slds-hide");
        }
    },
    showToast : function(component, type, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: msg,
            messageTemplate: 'Mode is dismissible ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    getLabels : function(component) {
    	var u = component.get("c.getLabels");
        u.setCallback(this, function(res) {
            if (res.getState() === "SUCCESS") {
                component.set("v.labels",res.getReturnValue());
                component.set("v.simpleRecord.Country", "France");
                //console.log("labels et France : ok");
            } else {
                alert('Erreur lors du chargement des labels" \n'+res.getState());
                console.log("Failed with state: " + res.state);
            }
        });        
        $A.enqueueAction(u);
    },
    checkRappel : function(component) {
    	var showRappelerPlusTard = component.get("v.showRappelerPlusTard");
    	var dateRappel = component.get("v.simpleRecord.CallBackDate__c");
    	var DateRappelInit = component.get("v.DateRappelInit");
		if(showRappelerPlusTard && ( dateRappel == null || DateRappelInit == dateRappel)) {
			component.set("v.showDateRappelError", true);
			return false;
		}
		component.set("v.showDateRappelError", false);
		return true;
    },
    validation : function(component, helper) {
        helper.showSpinner(component);

        helper.removeProxy(component, 'v.simpleRecord.Event__c');
        helper.removeProxy(component, 'v.simpleRecord.CustomerRecommendation__c');
        helper.removeProxy(component, 'v.simpleRecord.Partnership__c');

        component.find("TheRecord").saveRecord($A.getCallback(function(saveResult) {
        //console.log(saveResult.state);
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
            	component.find("validation").set("v.variant", "success");
            	console.log(component.get("v.simpleRecord.Latitude"));	 
            	console.log(component.get("v.simpleRecord.Longitude"));
	            helper.showToast(component, 'SUCCESS', 'Succès', 'Informations enregistrées'); 
	            helper.setNextCall(component);
	            $A.get('e.force:refreshView').fire();
            } else if (saveResult.state === "ERROR" || saveResult.state === "INCOMPLETE") {
            	component.find("validation").set("v.variant", "brand");
            	let errors = JSON.stringify(saveResult.error);
            	console.log(errors);
                helper.showToast(component, 'ERROR', 'Attention', 'Il y a eu un problème lors de la modification, certains champs sont incorrects');
            }
            helper.showSpinner(component,"hide");
        }));
    },
    setNextCall : function(component) {
    	var MapMessage = component.get("v.MapMessageNextCall");
    	var action = component.get("c.getStatus");
    	action.setParams({
			leadId: component.get("v.recordId"),
		});
        action.setCallback(this, function(res) {
            if (res.getState() === "SUCCESS") {
                var status = res.getReturnValue();
                if(status != null && status.includes("Call")){
	                console.log("status retourné : "+status);
			        if(MapMessage[status] != undefined){
			        	component.set("v.showNextCall", true);
			        	component.set("v.currentCall", status);
			        	component.set("v.messagesNextCall", MapMessage[status]);
		        	}
		        	else component.set("v.showNextCall", false);
                }   
            } else {
                alert('Erreur lors du chargement du status" \n'+res.getState());
                console.log("Failed with state: " + res.state);
            }
        });       
        $A.enqueueAction(action);
    },
    getContactPartenariat : function(component,helper,isInit){
		if(component.get("v.simpleRecord.Partnership__c") != null && component.get("v.simpleRecord.Partnership__c").length > 0) {
			var action = component.get("c.getContactPartenariat");
			action.setParams({
				accountId: helper.fixTypeOfPartnership(component)
			});
			action.setCallback(this, function(res) {
				if (res.getState() === "SUCCESS") {
					component.set("v.ListContactPartenariat", res.getReturnValue());
				}
				else if(res.getState() === "ERROR") {
					var errors = res.getError();
					console.log(errors[0].message);
				}
			});
			$A.enqueueAction(action);
		}
        else {
            component.set("v.ListContactPartenariat", []);
        }
    },
    fixTypeOfPartnership : function(component) {
    	return typeof component.get("v.simpleRecord.Partnership__c") === 'string' ? 
                component.get("v.simpleRecord.Partnership__c") : 
            	component.get("v.simpleRecord.Partnership__c")[0];
    }
})