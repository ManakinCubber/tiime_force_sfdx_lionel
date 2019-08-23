({
	doInit : function(component, event, helper) {
		if(component.get("v.showAddress")){
			const fields = [];
			var street = component.get('v.street');
			var city = component.get('v.city');
			var country = component.get('v.country');
			var postalCode = component.get('v.postalCode');
			
			fields.push(street);
			fields.push(postalCode);
			fields.push(city);
			fields.push(country);
			
			fields.forEach(function(field){
				if(field != null)
					component.set("v.location", component.get("v.location")+" "+field);
			});
			component.set("v.showAddress", false);	
		}		
	},
	getCities : function(component, event, helper){	
		var params = {
		  "input" : component.get('v.location')	
		} 
		
		//console.log(params);
		
		helper.callServer(component,"c.getSuggestions",function(response){
			var resp = JSON.parse(response);
			//console.log('response : ---------------------------------------------');
			//console.log(response);	
			//console.log(resp.predictions);
			component.set('v.predictions',resp.predictions);
			helper.resetAddress(component);
		},params);	
	},
	getCityDetails : function(component, event, helper){
 
		var selectedItem = event.currentTarget;
	        var placeid = selectedItem.dataset.placeid;
	 
		var params = {
		   "placeId" : placeid  	
		} 
	 
		helper.callServer(component,"c.getPlaceDetails",function(response){
			
			var latitude = JSON.parse(response).result.geometry.location.lat;
			var longitude = JSON.parse(response).result.geometry.location.lng;
			var stringSpanAdress = JSON.parse(response).result.adr_address; 
			//console.log(stringSpanAdress);
			var listFieldAddress = ["street-address","locality","postal-code","country-name"];
			var present = [];
			listFieldAddress.forEach(function(field, i){ if(stringSpanAdress.includes(field)) present.push(i); });

			present.forEach(function(i) {
				var gauche = stringSpanAdress.substring(
							stringSpanAdress.indexOf(listFieldAddress[i])+listFieldAddress[i].length+2,
							stringSpanAdress.length
						);
				var info = gauche.substring( 0, gauche.search("<") );
				
				switch(listFieldAddress[i]) {
					case 'street-address' :
						component.set("v.street", info);
						break;
					case 'locality' :
						component.set("v.city", info);
						break;
					case 'postal-code' :
						component.set("v.postalCode", info);
						break;
					case 'country-name' :
						component.set("v.country", info);
						break;
					default:
						console.log("field inconnu : "+listFieldAddress[i]);
				}
			});
			
			if(longitude != null || latitude != null){
				component.set("v.latitude", latitude);	 
				component.set("v.longitude", longitude);
			}
			component.set('v.location',JSON.parse(response).result.formatted_address);	
			component.set('v.predictions',[]); 
		},params);	
	}
})