({
	doInit : function(component, event, helper) {
		component.find("leadBack").doInit();
		helper.horodatageLeadBack(component, helper);
	}
})