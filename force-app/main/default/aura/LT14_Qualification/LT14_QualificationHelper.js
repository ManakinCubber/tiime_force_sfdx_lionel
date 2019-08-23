({
	initPickLists : function(cmp) {
		console.log("initPickLists begin");

		var action = cmp.get("c.getPicklistOptions");
		const fieldNames = ["TypeOfNeed__c","Echeance_de_besoin_de_creation__c","Evaluation_a_priori__c","LegalStatus__c","WillHaveEmployes__c"];
		const TypefieldNames = ["typeNoteBesoin","typeNoteBesoinCrea","typeNotePriori","typeNoteJuridique","typeNoteEmployes"];
		action.setParams({
			'fieldNames' : fieldNames
		});
		action.setCallback(this, function(res){
			if(res.getState() === "SUCCESS") {
				// console.log("picklists Opstions: ");
				// console.log(res.getReturnValue());
				var listOfPickList = res.getReturnValue();
				listOfPickList.forEach(function(field, i) {
					var options = Object.entries(field);
					//console.log(options);
					var typeNote = [];
					options.forEach(function(option, j) {
						typeNote[j] = {'label' : option[0],
								'value' : option[1]};
					});
					//console.log(JSON.stringify(typeNote));
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
				component.set("v.simpleRecord.Country", "France");
				//console.log("labels et France : ok");
			} else {
				alert('Erreur lors du chargement des labels" \n'+res.getState());
				console.log("Failed with state: " + res.state);
			}
		});        
		$A.enqueueAction(u);
	}
})