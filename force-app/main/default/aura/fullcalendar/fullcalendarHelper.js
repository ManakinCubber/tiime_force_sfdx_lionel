({
    checkEvent : function(cmp, event, helper){
        console.log("checkEvent begin");
        var action = cmp.get("c.getEventByBu");
        action.setParams({
            "Bu" : cmp.get("v.Bu"),
            "chosenDate" : JSON.stringify(cmp.get("v.Day"))
        });
        action.setCallback(this, function(response) {
            console.log("setCallback.checkEvent begin");
            if (response.getState() === "SUCCESS") {
                var events = [];
                var res  = response.getReturnValue();
                for(var i = 0; i < res.length ;i++){
                    console.log(JSON.stringify(res[i]));
                    events.push({ id: res[i].Id, resourceId: res[i].OwnerId, start:res[i].StartDateTime, end:res[i].EndDateTime, title: res[i].Subject, name: res[i].Owner.Name});
                }
                cmp.set("v.Events",events);
                if(cmp.get("v.isLoad")==true){
                    console.log('removeEvents');
                     //$('#calendar').fullCalendar('gotoDate',cmp.get("v.Day"));
                    $('#calendar').fullCalendar('removeEvents');
                    $('#calendar').fullCalendar('renderEvents',events);
                }
                console.log("setCallback.checkEvent end");
            }
            else {
                alert('Erreur lors de la recherche de la date.');
                console.log("Failed with state: " + response.state);
            }
        });
        $A.enqueueAction(action);
        console.log("checkEvent begin");
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
            timezone : 'local',
            selectable: true,
            maxTime : "20:01:00",
            minTime : "08:00:00",
            eventLimit: true, // allow "more" link when too many events
            header: {
                left: 'prev,next today ',
                center: 'title',
                right: ''
            },
            /*views: {
                agendaTwoDay: {
                    type: 'agenda',
                    duration: { days: 2 },
                    
                    // views that are more than a day will NOT do this behavior by default
                    // so, we need to explicitly enable it
                    groupByResource: true
                    
                    //// uncomment this line to group by day FIRST with resources underneath
                    //groupByDateAndResource: true
                }
            },*/
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
            
           	viewRender: function (view, element) {
                //alert('viewRender');
                var currentdate = view.start;
                currentdate = $A.localizationService.formatDate(currentdate, "yyyy-MM-dd");
                cmp.set("v.Day", currentdate);
                $('#calendar').fullCalendar('gotoDate',cmp.get("v.Day"));
            },
            select: function(startDate, endDate, jsEvent, view, resource) {
                var createEvent = cmp.getEvent("onDateSelected");
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
            businessHours: {
            start: '09:00',
            end:   '18:00',
            dow: [ 1, 2, 3, 4, 5]
    		},
            defaultDate: cmp.get("v.Day"),
            editable: false,
            eventLimit: true,
            events:datas,
            resources: function(callback){
                 	callback(cmp.get("v.Resources"));   
            },
            
        });
        console.log('isLoad='+cmp.get("v.isLoad"));
        cmp.set("v.isLoad",true);
        $('#calendar').fullCalendar('gotoDate',cmp.get("v.Day"));
        console.log('isLoad='+cmp.get("v.isLoad"));
        console.log("loadDataToCalendar End");
        
    }
})