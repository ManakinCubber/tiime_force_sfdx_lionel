({
	initCheckbox : function(component){
    	component.find("checkB").set("v.checked",component.get("v.simpleRecord.notedeSatisfactionPrisecontactcheck__c"));
    },
    initPickLists : function(cmp) {
    console.log("initPickLists begin");
    	
    	var action = cmp.get("c.getPicklistOptions");
    	const fieldNames = ["notedeSatisfactionPrisecontact__c","Evaluation_a_posteriori__c"];
    	const TypefieldNames = ["typeNoteSatisfPriseContact","typeNoteEvalPoster"];
    	action.setParams({
    		'fieldNames' : fieldNames
    	});
    	action.setCallback(this, function(res){
			if(res.getState() === "SUCCESS") {
				console.log("picklists Opstions: ");
				console.log(res.getReturnValue());
				var listOfPickList = res.getReturnValue();
				listOfPickList.forEach(function(field, i) {
					var options = Object.entries(field);
					console.log(options);
					var typeNote = [];
					options.forEach(function(option, j) {
						typeNote[j] = {'label' : option[0],
										'value' : option[1]}
					});
					console.log(JSON.stringify(typeNote));
					cmp.set("v."+TypefieldNames[i], typeNote);
				});
				
			} else {
				console.log(res.getState());
			}
		});
		
		$A.enqueueAction(action);
    },
    getLabels : function(component) {
    	var u = component.get("c.getLabels");
        u.setCallback(this, function(res) {
            if (res.getState() === "SUCCESS") {
                component.set("v.labels",res.getReturnValue());
                console.log("labels ok");
            } else {
                alert('Erreur lors de la création du composant "Enquête de satisfaction" \n'+res.getState());
                console.log("Failed with state: " + res.state);
            }
        });        
        $A.enqueueAction(u);
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
})