({
    doInit : function(cmp, event, helper){
        console.log('userCalendar.doInit begin');
        if(cmp.get("v.selectedMember")){
            var member = cmp.get("v.selectedMember");
            var Resources = { id: member.Id, title: member.Name, eventColor: 'orange'}
            cmp.set("v.Resources", Resources);
            helper.EventByMember(cmp, event, helper);
        }
        console.log('userCalendar.doInit end');
    },
    
    update : function(cmp, event, helper){
        //alert('handler chosenDate Modify');
        $('#calendar').fullCalendar('gotoDate',cmp.get("v.Day"));
        helper.EventByMember(cmp, event, helper);
    },
    
    
    afterScriptsLoaded: function(cmp,evt,helper){
        console.log('userCalendar.loadDataToCalendar begin');
        helper.loadDataToCalendar(cmp);
        console.log('userCalendar.loadDataToCalendar end');
    }
})