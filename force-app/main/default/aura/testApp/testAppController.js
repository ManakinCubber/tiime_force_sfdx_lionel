({
	handleClick : function (cmp, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "event"
        });
        createRecordEvent.fire();
    }
})