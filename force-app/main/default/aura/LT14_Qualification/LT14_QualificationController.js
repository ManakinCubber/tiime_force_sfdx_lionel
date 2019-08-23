({
	doInit: function(component, event, helper) {
		helper.getLabels(component);
		helper.initPickLists(component);
		component.find('AddressByGoogle').doInit();
	}
})