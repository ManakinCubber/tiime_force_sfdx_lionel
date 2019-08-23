({
	showToast : function(component, type, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: msg,
            messageTemplate: 'Mode is dismissible ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    }, 
    showSpinner : function(cmp,state) {
        var spinner = cmp.find("spjSpinner");
        if(state =="hide"){
            $A.util.addClass(spinner, "slds-hide");
        } else {
            $A.util.removeClass(spinner, "slds-hide");
        }
    }
})