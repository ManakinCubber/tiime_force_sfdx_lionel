({
    doInit : function (component, event, helper) {
        component.set("v.simpleRecord.StageName",  "Opportunité perdue");
    },
	clickValidate : function(component, event, helper) {
		component.find("validation").set("v.label", "l'opportunité est perdue");
        component.find("validation").set("v.variant", "success");
        helper.showToast(component, 'SUCCESS', 'SUCCESS', 'Informations enregistrées');
    }
})