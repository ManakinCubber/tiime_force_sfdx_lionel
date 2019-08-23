({
	doInit : function(component, event, helper) {
		helper.getFieldsLabels(component);
		helper.retrieveLeadData(component);
	},
    handleSubmit : function(component, event, helper) {
    	event.preventDefault();
    	var payload = event.getParams('fields');
    	payload  = helper.cleanLeadFields(component, payload.fields);
    	component.find('recordViewLeadForm').submit(payload);
    },
    handleLeadSuccess : function(component, event, helper) {
    	helper.showToast("success", "Succès", "Lead modifiée");
    },
    handleTransfertSuccess : function(component, event, helper) {
    	helper.showToast("success", "Succès", "Transfert modifié");
    }
})