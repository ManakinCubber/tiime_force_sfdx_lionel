({
	find: function(inputs, title) {
		for(let i = 0 ; i < inputs.length ; i++)
			if(inputs[i].field == title)
				return i;
		return -1;
	},
	checkConditions: function(cmp, inputs) {
		for(let i = 0 ; i < inputs.length ; i++) {
			let input = inputs[i];
			if(input.conditions == undefined || input.conditions.length == 0) {
				input.shouldDisplay = true;
			} else {
				let ok = false;
				for(let j = 0 ; j < input.conditions.length ; j++) {
					let value = cmp.get(input.conditions[j].field);
					ok = value == input.conditions[j].value;
					if(ok) break;
				}
				input.shouldDisplay = ok;
			}
		}
	},
	resetInputs: function(cmp, inputs) {
		for(let i = 0 ; i < inputs.length ; i++) {
			inputs[i].valid = 0;
			inputs[i].documentId = null;
		}
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