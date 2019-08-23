({
	firstPage: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
    },
    prevPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.max(component.get("v.currentPageNumber")-1, 1));
    },
    nextPage: function(component, event, helper) {
        console.log("NEXT PAGE currentPageNumber=="+Math.min(component.get("v.currentPageNumber")+1, component.get("v.maxPageNumber")));
        component.set("v.currentPageNumber", Math.min(component.get("v.currentPageNumber")+1, component.get("v.maxPageNumber")));
        
        component.set("v.nextBtnDisabled", true);
        var lockEvent = component.getEvent("lockValidateBtn");
        lockEvent.fire();
    },
    lastPage: function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
    },
})