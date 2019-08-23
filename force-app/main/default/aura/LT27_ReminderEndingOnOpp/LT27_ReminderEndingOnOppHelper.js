({
	selectOpenTask: function(component) {
		var retrieveCurrentTaskAction = component.get("c.retrieveCurrentTask");
		retrieveCurrentTaskAction.setParams({
			oppId: component.get("{!v.recordId}")
		});
		retrieveCurrentTaskAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				component.set("{! v.taskRecord }", res.getReturnValue());
			}
		});
		console.log("before call");
		$A.enqueueAction(retrieveCurrentTaskAction);
	},
	selectPreviousTask: function(component) {
		var selectPreviousTaskAction = component.get("c.retrievePreviousTask");
		selectPreviousTaskAction.setParams({
			oppId: component.get("{!v.recordId}")
		});
		selectPreviousTaskAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				component.set("{! v.previousTaskRecord }", res.getReturnValue());
			}
		});
		$A.enqueueAction(selectPreviousTaskAction);
	},
	searchIssueRelancePicklistValues: function(component) {
		var retrieveIssueRelancePicklistValuesAction = component.get("c.retrieveIssueRelancePicklistValues");
		retrieveIssueRelancePicklistValuesAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				let issueTab = [];
				for(var issue in res.getReturnValue()) {
					issueTab.push({label : issue, value : res.getReturnValue()[issue]});
				}
				component.set("{!v.issues}", issueTab);
			}
		});
		$A.enqueueAction(retrieveIssueRelancePicklistValuesAction);
	},
	saveTaskRecord: function(component) {
		var saveTaskAction = component.get("c.updateTaskRecord");
		saveTaskAction.setParams( {
			task: component.get("{! v.taskRecord }")
		});
		saveTaskAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				this.showToast("success", "Succès", "Tâche modifiée.");
			} else {
				console.log(res.getError()[0]);
				this.showToast("error", "Erreur", res);
			}
		});
		$A.enqueueAction(saveTaskAction);
	},
	showToast: function(type, title, message) {
		var resultsToast = $A.get("e.force:showToast");
		resultsToast.setParams({
			title: title,
			message: message,
			type: type
		});
		resultsToast.fire();
    }
})