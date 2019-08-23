({
    
    EventByMember : function(cmp, event, helper){
        console.log('userCalendar.EventByMember begin');
        var action = cmp.get("c.getEventByMember");
        action.setParams({
            "User" : cmp.get("v.selectedMember.Id"),
            "chosenDate" : JSON.stringify(cmp.get("v.Day"))
        });
        action.setCallback(this, function(response) {
            console.log('userCalendar.setCallback begin');
            if (response.getState() === "SUCCESS") {
                var events = [];
                var res  = response.getReturnValue();
                for(var i = 0; i < res.length ;i++){
                    console.log(JSON.stringify(res[i]));
                    events.push({ id: res[i].Id, resourceId: res[i].OwnerId, start:res[i].StartDateTime, end:res[i].EndDateTime, title: res[i].Subject});
                }
                cmp.set("v.Events",events);
                if(cmp.get("v.isLoad")==true){
                    console.log('removeEvents');
                    $('#calendar').fullCalendar('removeEvents');
                    $('#calendar').fullCalendar('renderEvents',events);
                }
            }
            else {
                alert('userCalendar : Erreur lors de la recherche de la date.');
                console.log("Failed with state: " + response.state);
            }
            console.log('userCalendar.setCallback end');
        });
        $A.enqueueAction(action);
        console.log('userCalendar.EventByMember end');
    },
    
    loadDataToCalendar :function(cmp){
        console.log("loadDataToCalendar Begin");
        var datas = cmp.get("v.Events");
        console.log(datas);
        var resources = cmp.get("v.Resources");
        console.log(resources);
        $('#calendar').fullCalendar({
            locale: 'fr',
            defaultView: 'agendaDay',
            contentHeight: 800,
            height: "parent",
            timezone : 'local',
            selectable: true,
            maxTime : "20:01:00",
            minTime : "08:00:00",
            eventLimit: true, // allow "more" link when too many events
            header: {
                left: '',
                center: '',
                right: ''
            },
            views: {
                /*agendaTwoDay: {
                    type: 'agenda',
                    duration: { days: 2 },
                    
                    // views that are more than a day will NOT do this behavior by default
                    // so, we need to explicitly enable it
                    groupByResource: true
                    
                    //// uncomment this line to group by day FIRST with resources underneath
                    //groupByDateAndResource: true
                }*/
            },
            /*eventClick: function(calEvent, jsEvent, view) {
                alert('start:'+calEvent);
                var prestation={'Date__c':calEvent.start};
                var createEvent = cmp.getEvent("PrestationChange");
                createEvent.setParams({ 
                    "prestation": calEvent.presta,
                    "status": 'edit'
                });
                createEvent.fire();
            },dayClick: function(date, jsEvent, view, resourceObj) {
                console.log(resourceObj);
                var createEvent = cmp.getEvent("onDateSelected");
                createEvent.setParams({ 
                    "selectedDate": date.format('YYYY-MM-DD HH:mm:ss'),
                    "userId":resourceObj.id,
                    "selectedStartTime" : resourceObj.start,
                    "selectedEndTime" : resourceObj.end,
                    "name" : resourceObj.title
                });
                createEvent.fire();
            },*/
            select: function(startDate, endDate, jsEvent, view, resource) {
                
                var createEvent = cmp.getEvent("onTimeSelected");
                createEvent.setParams({ 
                    "userId":resource.id,
                    "start" : $A.localizationService.formatDate(startDate, "yyyy-MM-ddTHH:mm:ss.000Z"),
                    "end" : $A.localizationService.formatDate(endDate, "yyyy-MM-ddTHH:mm:ss.000Z"),
                    "startEvent":startDate,
                    "endEvent":endDate,
                    "name" : resource.title
                });
                createEvent.fire();
            },
            viewRender:function( view, element ){
                var next = $('#calendar').fullCalendar('getDate');
            	cmp.set("v.Day", next.format());
            },
            businessHours: true,
            defaultDate: cmp.get("v.Day"),
            editable: false,
            eventLimit: true,
            events:datas,
            resources:resources
        });
        console.log('isLoad='+cmp.get("v.isLoad"));
        cmp.set("v.isLoad",true);
        console.log('isLoad='+cmp.get("v.isLoad"));
        console.log("loadDataToCalendar End");
    },
    
    
    
})