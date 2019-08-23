({
	retrieveCabinets : function(component) {
		var getCabinetsAction = component.get("{!c.getCabinets}");
		
		getCabinetsAction.setCallback(this, function(res) {
			if(res.getState() === "SUCCESS") {
				console.log("success");
				console.log(res.getReturnValue());
				
				component.set("v.cabinets", res.getReturnValue());
				
				component.set('v.center', {location: {'PostalCode':'75001','Country':'France'}});
				component.set('v.zoomLevel', 6);
				
				this.addMarkers(component, 11);
				
			} else {
				console.log("erreur lors de la récupération des comptes cabinets : ");
				console.log(res.getState());
			}
		});
		$A.enqueueAction(getCabinetsAction);
	},
	addMarkers : function(component, maxRecord) {
		
		console.log("addMarker begin");
		const cabs = component.get("{!v.cabinets}");
		var locationArray = component.get("{!v.mapMarkers}");
		var index = component.get("{!v.index}");
		var i = 0;
		for(let key = index; key < cabs.length; key++) {
			if(i==maxRecord)break;
			console.log(cabs[key]);
            locationArray.push({location:{PostalCode:cabs[key].BillingPostalCode, Country:'France'}, title:cabs[key].Name});
			i++;
			index++;
		}
		component.set("v.mapMarkers", locationArray);
		component.set("v.index", index);
		console.log(locationArray);
		console.log("addMarker end");
		return index;
	}
})