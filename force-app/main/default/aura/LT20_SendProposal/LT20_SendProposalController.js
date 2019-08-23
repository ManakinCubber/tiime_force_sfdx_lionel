({
    doInit: function(component, event, helper) {
        //console.log("do init");
        // Retrieve fields labels
        helper.getFieldsLabels(component);

        // Retrieve Lead.Offres__c PicklistValues
        //helper.getOffresOptions(component);
        helper.callBgiForOffreOptions(component);
        
        //helper.getExistingMissions(component);

        helper.checkAccountId(component);

        helper.getPdfFiles(component);
    },
    handleOffresChange: function(component, event, helper) {
        //console.log(component.get("{!v.offreOptionsSelected}"));
        helper.fillInMissionsList(component);

    },
    missionChangeHandler: function(component, event, helper) {
    	helper.changeOffers(component);
    },
    handleSave: function(component, event, helper) {
        helper.toggleSpinner(component, "");
        // Save the lead Offres__c field
        helper.saveOffres(component, helper);
    },
    sendToBGI: function(component, event, helper) {
        helper.toggleSpinner(component, "");
        helper.sendToBGI(component, helper);
    },
    suggestUpdate: function(component, event, helper) {
        var suggestionDone = component.get("{!v.suggestUpdate}");
        if (suggestionDone != "true") {
            component.set("{!v.suggestUpdate}", "true");
        }
    },
    updateLeadInfo: function(component, event, helper) {
        helper.updateLeadInfo(component, helper);
    }
})