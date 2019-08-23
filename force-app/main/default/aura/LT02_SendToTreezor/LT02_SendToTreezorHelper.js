({
	helperMethod : function() {
		
	},
	changeStatus: function(component) {
		var changeStatusAction = component.get("c.changeAccountStatusAfterSuccessfullCallToTreezor");
		changeStatusAction.setParams({
			accountId: component.get("{!v.accountObject.Id}")
		});
		$A.enqueueAction(changeStatusAction);
	},
	toast: function(cmp,titre,etat ,message){
		var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                title: titre,
                message: message,
                key: 'info_alt',
                type: etat,
            });
            toastEvent.fire();
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
	buttonAction: function(component,event,helper){
		let button = event.getSource();
		if(button.get("v.disabled")) button.set('v.disabled',false);
		else button.set('v.disabled',true);
	}
})