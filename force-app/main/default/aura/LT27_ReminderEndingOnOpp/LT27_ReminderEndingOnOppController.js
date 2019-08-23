({
	doInit : function(component, event, helper) {
		helper.searchIssueRelancePicklistValues(component);
		helper.selectOpenTask(component);
		helper.selectPreviousTask(component);
	},
	onIssueChange: function(component, event, helper) {
		let issue = component.find("selectIssue").get("v.value");
		
		switch(issue) {
			case "Relance reportée":
				component.set("v.displaySubmitButton", false);
				component.set("v.displayDelayDate", true);
				break;
			case undefined:
			case "":
				component.set("v.displaySubmitButton", false);
				component.set("v.displayDelayDate", false);
				break;
			default:
				component.set("v.displaySubmitButton", true);
				component.set("v.displayDelayDate", false);
				component.set("{! v.taskRecord.CallBackDate__c }", null);
		}
	},
	callbackDateChangeHandler: function(component, event, helper) {
		let callbackDate = component.get("{! v.taskRecord.CallBackDate__c }");
		
		if(callbackDate != undefined && callbackDate != "") {
			component.set("v.displaySubmitButton", true);
		}
	},
	saveTask: function(component, event, helper) {
		helper.saveTaskRecord(component);
		$A.get('e.force:refreshView').fire();
	}
})