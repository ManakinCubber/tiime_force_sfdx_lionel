({
   doInit : function(cmp, event, helper){
        var members = cmp.get("v.members");
        var Resources = [];
        for(var i = 0; i < cmp.get("v.members").length ;i++){
            Resources.push({ id: members[i].Id, title: members[i].Name, eventColor: 'orange'});
        }
        cmp.set("v.Resources", Resources);
        helper.checkEvent(cmp, event, helper);
    },
    
    update : function(cmp, event, helper){
        //alert('handler chosenDate Modify');
        $('#calendar').fullCalendar('gotoDate',cmp.get("v.Day"));
        console.log('update');
        helper.checkEvent(cmp, event, helper);
    },
    
    updateResources : function(cmp, event, helper){
        var members = cmp.get("v.members");
        var Resources = [];
        for(var i = 0; i < cmp.get("v.members").length ;i++){
            Resources.push({ id: members[i].Id, title: members[i].Name, eventColor: 'orange'});
        }
        cmp.set("v.Resources", Resources);
        if(cmp.get("v.isLoad")==true){
            console.log("updateResources isLoad => " + cmp.get("v.isLoad"));
        	$('#calendar').fullCalendar('refetchResources');
        }
        helper.checkEvent(cmp, event, helper);
    },
    
    afterScriptsLoaded: function(cmp,evt,helper){
        console.log('loadDataToCalendar begin');
        helper.loadDataToCalendar(cmp);
        console.log('loadDataToCalendar end');
    }
})