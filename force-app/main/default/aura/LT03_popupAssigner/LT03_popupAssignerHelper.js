({
	openModel: function(component, event) {
		component.set("v.isOpen", true);
		console.log("modal ouverte");
		console.log( component.get("v.isOpen"));
	},

	closeModel: function(component, event) {  
		component.set("v.isOpen", false);
		console.log("modal fermé");
	},

	checkNotify: function(cmp) {
		if(cmp.get('v.LeadObject.Linking__c') && cmp.get('v.LeadObject.RDV_EC_confirmer__c') == 'Oui') {
			cmp.set('v.isNotifyOpen', true);
		}
	},

	showSpinner : function(cmp,state) {
		var spinner = cmp.find("spjSpinner");
		if(state =="hide"){
			$A.util.addClass(spinner, "slds-hide");
		} else {
			$A.util.removeClass(spinner, "slds-hide");
		}
	},
})