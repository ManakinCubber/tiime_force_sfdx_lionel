({
	calculNPS : function(component, event, helper, result) {
		var nbEnquetes = component.get("v.nbEnquetes");
		
		var reactNPS = 0;
		var globalNPS = 0;
		var propalNPS = 0;
		var repSkillNPS = 0;
		var contact1NPS = 0;
		var simpleNPS = 0;
		
		var reactNPSDetractor = 0;
		var globalNPSDetractor = 0;
		var propalNPSDetractor = 0;
		var repSkillNPSDetractor = 0;
		var contact1NPSDetractor = 0;
		var simpleNPSDetractor = 0;
		
		var reactNPSPromoter = 0;
		var globalNPSPromoter = 0;
		var propalNPSPromoter = 0;
		var repSkillNPSPromoter = 0;
		var contact1NPSPromoter = 0;
		var simpleNPSPromoter = 0;
		
		for(var enquete of result){
			reactNPSDetractor += enquete.NoteReactiviteNPSDetractor__c;
			globalNPSDetractor += enquete.noteSatisfactionGlobaleNpsDetractor__c;
			propalNPSDetractor += enquete.PropaleNotesNPSDetractor__c;
			repSkillNPSDetractor += enquete.RepresentativeSkillsNotesNPSDetractor__c;
			contact1NPSDetractor += enquete.Satisfaction1contactNotesNPSDetractor__c;
			simpleNPSDetractor += enquete.SimplicityNotesNPSDetractor__c;
			
			reactNPSPromoter += enquete.NoteReactiviteNpsPromoter__c;
			globalNPSPromoter += enquete.NoteSatisfactionGlobaleNpsPromoter__c;
			propalNPSPromoter += enquete.PropaleNotesNPSPromoter__c;
			repSkillNPSPromoter += enquete.RepresentativeSkillsNotesNPSPromoter__c;
			contact1NPSPromoter += enquete.Satisfaction1contactNotesNPSPromoter__c;
			simpleNPSPromoter += enquete.SimplicityNotesNPSPromoter__c;
		}
		
		//Calcul du NPS avec un arrondi à deux décimales après la virgule.
		reactNPS = Math.round( ((reactNPSPromoter/nbEnquetes*100) - (reactNPSDetractor/nbEnquetes*100)) * 100) / 100;
		globalNPS = Math.round( ((globalNPSPromoter/nbEnquetes*100) - (globalNPSDetractor/nbEnquetes*100)) * 100) / 100;
		propalNPS = Math.round( ((propalNPSPromoter/nbEnquetes*100) - (propalNPSDetractor/nbEnquetes*100)) * 100) / 100;
		repSkillNPS = Math.round( ((repSkillNPSPromoter/nbEnquetes*100) - (repSkillNPSDetractor/nbEnquetes*100)) * 100) / 100;
		contact1NPS = Math.round( ((contact1NPSPromoter/nbEnquetes*100) - (contact1NPSDetractor/nbEnquetes*100)) * 100) / 100;
		simpleNPS = Math.round( ((simpleNPSPromoter/nbEnquetes*100) - (simpleNPSDetractor/nbEnquetes*100)) * 100) / 100;
		
		console.log("reactNPS : "+reactNPS);
		console.log("globalNPS : "+globalNPS);
		console.log("propalNPS : "+propalNPS);
		console.log("repSkillNPS : "+repSkillNPS);
		console.log("contact1NPS : "+contact1NPS);
		console.log("simpleNPS : "+simpleNPS);
		
		var labels = component.get("v.labels");
		var listLabelNPS = [labels.notedeSatisfactionGlobale__c,
							labels.RepresentativeReactivityNote__c,
							labels.NotePropale__c,
							labels.RepresentativeSkillsNotes__c,
							labels.notedeSatisfactionPrisecontact__c,
							labels.Simplicite_du_process__c,];
							
		component.set("v.listLabelNPS", listLabelNPS);
		var listNPS = [globalNPS,reactNPS,propalNPS,repSkillNPS,contact1NPS,simpleNPS];
		var NPS = [];
		for (var i = 0; i < listNPS.length; i++) {
		    var singleObj = {};
		    singleObj['label'] = listLabelNPS[i];
		    singleObj['value'] = listNPS[i];
		    NPS.push(singleObj);
		}
		
		component.set("v.NPS", NPS);
	},
	
	getLabels : function(component) {
    	var u = component.get("c.getLabels");
        u.setCallback(this, function(res) {
            if (res.getState() === "SUCCESS") {
                component.set("v.labels",res.getReturnValue());
            } else {
                alert('Erreur lors du chargement des labels" \n'+res.getState());
                console.log("Failed with state: " + res.state);
            }
        });        
        $A.enqueueAction(u);
    },
})