({
    doInit : function(cmp, event, helper){
        helper.getLead(cmp)
                
        var u = cmp.get("c.currentUser");
        u.setCallback(this, function(res) {
            if (res.getState() === "SUCCESS") {
                cmp.set("v.userInfo",res.getReturnValue());
            }
            else {
                alert('Erreur lors de la création du composant \n'+res.getState());
                console.log("Failed with state: " + res.state);
            }
        });
        $A.enqueueAction(u);
        var todayDate = new Date();
        todayDate.setDate(todayDate.getDate() + 1);
        var tomorrow = helper.formatDate(todayDate);
        cmp.set("v.tomorrowDate", tomorrow);		
    },
    
    
    fillAddressBU : function(cmp, event, helper){
        var user = cmp.get("v.selectedUser");
        var bu = cmp.get("v.selectedBU");

    },
    
    fillAddress : function(cmp, event, helper){
        cmp.set("v.chosenDate", cmp.get("v.tomorrowDate"));
        
    },
    
    onCheck: function(cmp, evt) {
        var checkCmp = cmp.find("checkbox");
        /*resultCmp = cmp.find("checkResult");
		 resultCmp.set("v.value", ""+checkCmp.get("v.value"));*/
    },
    
    back : function(cmp, event, helper){
        cmp.set("v.RdvPannel", false);
        //cmp.find("htmlDate").getElement().value = cmp.get("v.chosenDate");
        //cmp.set("v.seletedUser", null);
    },
    
    handleRdv : function(cmp, event, helper){
        helper.mail(cmp, event, helper);
    },
    
    handleLieuRdv : function(cmp, event, helper){
        helper.mail(cmp, event, helper);
        if(cmp.get("v.ChoixLieuRdv") == "chez le client"){
            cmp.set("v.newEvent.Location", (typeof cmp.get("v.lead").Street != "undefined" ? cmp.get("v.lead").Street+'\n' : "")+(typeof cmp.get("v.lead").PostalCode != "undefined" ? cmp.get("v.lead").PostalCode+'\n' : "")+(typeof cmp.get("v.lead").City != "undefined" ? cmp.get("v.lead").City : ""));
            console.log("Street => "+cmp.get("v.lead").Street);
        }
            else{
                cmp.set("v.newEvent.Location",''); 
            }
    },
    
    
    handleTime : function(cmp, event, helper){
        cmp.set("v.selectedStartTime", event.getParam("start"));
        cmp.set("v.selectedEndTime", event.getParam("end"));
    },
    
    formatDate : function(cmp, event, helper) {
        var date = cmp.get("v.selectedStartTime");
        if(date){
            var d = new Date(date);
            var datestring = ("0" + d.getDate()).slice(-2) + "-" + ("0"+(d.getMonth()+1)).slice(-2) + "-" +
                d.getFullYear();
            var time= ("0" + d.getHours()).slice(-2) + "H" + ("0" + d.getMinutes()).slice(-2);
            cmp.set("v.formattedDate", datestring);
            cmp.set("v.formattedTime", time);
            helper.mail(cmp, event, helper);
        }
    },
    
    setDate : function(cmp, event, handler){
        console.log('setDate begin');
        cmp.find("htmlDate").getElement().value = cmp.get("v.chosenDate");
        console.log('setDate begin');
    },
    
    
    HtmlHandleDate : function(cmp, event, helper){
        console.log('HtmlHandleDate begin');
        var date = cmp.find("htmlDate");
        cmp.set("v.chosenDate", date.getElement().value);
        console.log('HtmlHandleDate end');
    },
    
    handleDate : function(cmp, event, helper){
        console.log('********************************handleDate');
        var user = event.getParam("userId");
        var members = cmp.get("v.Membres");
        for(var i = 0; i < members.length ;i++){
            if(members[i].Id == user){
                cmp.set("v.selectedUser", members[i]);
            }
        }  
        cmp.set("v.selectedStartTime", event.getParam("start"));
        cmp.set("v.selectedEndTime", event.getParam("end"));
        cmp.set("v.userName", event.getParam("name"));
        cmp.set("v.RdvPannel", true);
    },
    
    callChild : function(cmp, event, helper){
        var child = cmp.find("fullCalendar");
        child.getEvent();
    },
    
    
    
    getMembers : function(cmp, event, helper){
        var action = cmp.get("c.getMembres");
        action.setParams({
            "BU": JSON.stringify(cmp.get("v.selectedBU"))
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                if(response.getReturnValue() == ""){
                    alert('Aucun membre trouvé pour cette B.U');
                    cmp.set("v.selectedBU", '');
                }
                cmp.set("v.Membres",response.getReturnValue().Us);
                //alert(JSON.stringify(cmp.get("v.Membres")));
            }
            else {
                alert('Erreur lors de la recherce de B.U'+response.getState());
                console.log("Failed with state: " + response.state);
            }
        });
        $A.enqueueAction(action);
    },
    
    clickSave : function(cmp, event, helper) {

        var button = cmp.find("enregister");
        helper.saveEvent(cmp);

    }
})