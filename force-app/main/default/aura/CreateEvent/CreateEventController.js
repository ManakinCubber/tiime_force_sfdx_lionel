({
    handleClick : function (component, event, helper) {
       var createRecordEvent = $A.get("e.force:createRecord");
       createRecordEvent.setParams({
           "entityApiName": "Event",
           "defaultFieldValues": {
               "WhatId":component.get("v.AccId"),
               "Subject":"Email" ,
               "Description":"test valou & niko"
           }
       });
       createRecordEvent.fire();
   }
})