({
	doInit : function(component, event, helper) {
		console.log("doInit");
		helper.retrieveCabinets(component);
	},
	ajouterBrest : function(component, event, helper) {
		var locationArray = component.get("{!v.mapMarkers}");
		console.log(locationArray);
		locationArray.push({location:{PostalCode:'29200', Country:'France'}, Title:'Brest'});
		console.log(component.get("{!v.mapMarkers}"));
		component.set("{!v.mapMarkers}", locationArray);
	},
	addMarkers : function(component, event, helper) {
		helper.addMarkers(component, 50);
	}
})