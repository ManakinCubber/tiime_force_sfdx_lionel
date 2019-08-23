({
    getLead : function(cmp){
        var action = cmp.get("c.getLead");
        action.setParams({
            "leadId": cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                cmp.set("v.lead",response.getReturnValue());
            }
            else {
                alert('Erreur lors de la création du composant \n'+response.getState());
                console.log("Failed with state: " + response.state);
            }
        });
        $A.enqueueAction(action);
    },
    saveEvent : function(cmp, event, helper) {
        console.log("saveEvent begin")
        if(cmp.get("v.ChoixRdv") == 'téléphonique'){
            cmp.set("v.newEvent.MeetingNature__c", 'Téléphonique');
        }
        else{
            if(cmp.get("v.ChoixLieuRdv") == 'au bureau' ){
              cmp.set("v.newEvent.MeetingNature__c", 'Physique chez Tiime');
            }
            else{
                cmp.set("v.newEvent.MeetingNature__c", 'Physique chez le client');
            }
        }
        var start = cmp.get("v.selectedStartTime");
        var end =  cmp.get("v.selectedEndTime");
        console.log('start = '+Date.parse(start)+'\nend = '+Date.parse(end));
        console.log('start = '+start+'\nend = '+end);
        //alert(start+'\n'+end);
        cmp.set("v.newEvent.OwnerId", cmp.get("v.selectedUser").Id);
        cmp.set("v.newEvent.WhoId", cmp.get("v.lead").Id);
        cmp.set("v.newEvent.Subject", "Rendez-vous "+cmp.get("v.ChoixRdv")+" avec "+cmp.get("v.lead").Name);
        console.log("selectedTime="+JSON.stringify(cmp.get("v.newEvent")));
        var evt = cmp.get("v.newEvent");
        evt.StartDateTime = null;
        evt.EndDateTime = null;
        evt.sobjectType ='Event';
        console.log("selectedTime="+JSON.stringify(evt));
        var action = cmp.get("c.save");
        var Lieu_Rendez_vous = '';
        if(cmp.get("v.ChoixRdv") == "physique") {
            if(cmp.get("v.ChoixLieuRdv") == "au bureau") {
                Lieu_Rendez_vous = "Au bureau";
            }
            else {
                Lieu_Rendez_vous = "Chez le client";
            }
        }
        else if(cmp.get("v.ChoixRdv") == "téléphonique") {
            Lieu_Rendez_vous = "Téléphonique";
        }
        action.setParams({
            "rdv":JSON.stringify(evt),
            "endTime":JSON.stringify(end),
            "startTime": JSON.stringify(start),
            "name":cmp.get("v.lead").Name
        });
        action.setCallback(this, function(response) {
            console.log("setCallback.saveEvent begin")
            if (response.getState() === "SUCCESS") {
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Event",
                    "defaultFieldValues": {
                        "Subject":evt.Subject,
                        "Description":evt.Description,
                        "MeetingNature__c":evt.MeetingNature__c,
                        "Type":evt.Type,
                        "StartDateTime":Date.parse(start),
                        "EndDateTime":Date.parse(end),
                        "Location":evt.Location,
                        "WhoId":evt.WhoId,
                        "OwnerId":cmp.get("v.selectedUser").Id,
                        "FirstRDV__c":true,
                        "SMS__c": evt.SMS__c,
                        "Lieu_Rendez_vous__c": Lieu_Rendez_vous
                    }
       });
       console.log("typeRdv value json => "+cmp.get("v.ChoixRdv"));
       console.log("Lieu rdv => "+Lieu_Rendez_vous);
       createRecordEvent.fire();
                /*var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": response.getReturnValue(),
                    "slideDevName": "detail"
                });
                navEvt.fire();*/
            }            
            else{
                this.GetErrors(cmp, response.getError());
                alert('Erreur lors de l\'enregistrement du rendez-vous');
                var button = cmp.find("enregister");
        		button.set("v.disabled", false);
				button.set("v.label", 'Prendre rendez-vous');
            }
            console.log("setCallback.saveEvent end")
        });
        $A.enqueueAction(action);
        console.log("saveEvent end");
    },
    
    formatDate : function(date) {
        var d = new Date(date);
        var month = '' + (d.getMonth() + 1);
        var day = '' + d.getDate();
        var year = d.getFullYear();
        if (month.length < 2) month = '0' + month;
        if (day.length < 2) day = '0' + day;
        return [year, month, day].join('-');
	},
    
    mail : function(cmp, event, helper){
        //alert("mail "+cmp.get("v.selectedUser"));
        var team = cmp.get("v.adressInfo");
        //alert(JSON.stringify(team));
        if(cmp.get("v.ChoixRdv") == "physique"){
            if(cmp.get("v.ChoixLieuRdv") == "au bureau"){
                helper.makeAdress(cmp, event, helper);
            	cmp.set("v.newEvent.Description", cmp.get("v.TemplateBureau"));
                cmp.set("v.newEvent.Type", 'Brand');
                //cmp.set("v.newEvent.Location", team.TeamInfoFormulaStreet__c+'\n'+team.TeamInfoFormulaPostalCode__c+'\n'+team.TeamInfoFormulaCity__c);
            	cmp.set("v.newEvent.Location", (typeof cmp.get("v.adressInfo").TeamInfoFormulaStreet__c != "undefined" ? cmp.get("v.adressInfo").TeamInfoFormulaStreet__c+"\n":"")+(typeof cmp.get("v.adressInfo").TeamInfoFormulaPostalCode__c != "undefined" ? cmp.get("v.adressInfo").TeamInfoFormulaPostalCode__c+'\n' : "")+(typeof cmp.get("v.adressInfo").TeamInfoFormulaCity__c != "undefined" ? cmp.get("v.adressInfo").TeamInfoFormulaCity__c : ""));
            }
            else{
                helper.makeAdress(cmp, event, helper);
         		cmp.set("v.newEvent.Description", cmp.get("v.TemplateClient"));
                cmp.set("v.newEvent.Type", 'Customer');
                cmp.set("v.newEvent.Location", (typeof cmp.get("v.lead").Street != "undefined" ? cmp.get("v.lead").Street+'\n' : "")+(typeof cmp.get("v.lead").PostalCode != "undefined" ? cmp.get("v.lead").PostalCode+'\n' : "")+(typeof cmp.get("v.lead").City != "undefined" ? cmp.get("v.lead").City : ""));

            }
        }
        else{
            helper.makeAdress(cmp, event, helper);
            cmp.set("v.newEvent.Description", cmp.get("v.TemplateTel"));
            cmp.set("v.newEvent.Type", 'Phone');
            cmp.set("v.newEvent.Location", "Rendez-vous téléphonique au "+cmp.get("v.lead.MobilePhone"));
        }
    },
    
    makeAdress : function(cmp, event, helper){
        console.log("MakeAdress::Begin:: => "+cmp.get("v.lead").Street+' '+cmp.get("v.lead").PostalCode+' '+cmp.get("v.lead").City);
        var team = cmp.get("v.adressInfo");
        if(team.TeamInfoFormulaStreet__c && team.TeamInfoFormulaCity__c && team.TeamInfoFormulaPostalCode__c && cmp.get("v.ChoixLieuRdv") == "au bureau"){
            cmp.set("v.adress", (team.TeamInfoFormulaStreet__c+' '+team.TeamInfoFormulaPostalCode__c)+' '+team.TeamInfoFormulaCity__c);
        	console.log("Valeur adresse Bureau => "+cmp.get("v.adress"));
        }
        else if (cmp.get("v.lead").Street && cmp.get("v.lead").City && cmp.get("v.lead").PostalCode && cmp.get("v.ChoixLieuRdv") != "au bureau") {
            console.log("Valeur adresse Client => "+(cmp.get("v.lead").Street+' '+cmp.get("v.lead").PostalCode+' '+cmp.get("v.lead").City));
            cmp.set("v.adress", (cmp.get("v.lead").Street+' '+cmp.get("v.lead").PostalCode+' '+cmp.get("v.lead").City));
            cmp.set("v.newEvent.Location", cmp.get("v.lead").Street +'\n'+cmp.get("v.lead").PostalCode+'\n'+cmp.get("v.lead").City);
            console.log("Value adresse client => "+cmp.get("v.adress"));
        }
    },
    
    GetErrors : function(cmp,errors) {
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log("Error message: " + errors[0].message);
                //cmp.set("v.ErrorCtrl",errors[0].message);
                //this.displayError(cmp);
            }            
        } else {
            console.log("Unknown error");
        }
    },
})