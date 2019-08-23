({
	updateStatusIcon: function(cmp, value) {
		cmp.set("v.valid", value);
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