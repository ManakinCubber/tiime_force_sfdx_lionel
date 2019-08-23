({
	doInit : function(component, event, helper) {
        helper.getLabels(component);
        helper.getTasks(component);
	},
    goToAllTasks : function(component, event, helper) {
        var redirect = $A.get("e.force:navigateToObjectHome");
        redirect.setParams({
            "scope":'Task'
        });
        redirect.fire();
	},
    goToWhatId : function(component, event, helper) {
        var recordId = event.currentTarget.id;
        var redirect = $A.get("e.force:navigateToSObject");
        	redirect.setParams({
            "recordId": recordId
        });
        redirect.fire();
	},
    refresh : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})