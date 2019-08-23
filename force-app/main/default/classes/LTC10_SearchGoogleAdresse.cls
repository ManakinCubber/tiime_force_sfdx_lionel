public with sharing class LTC10_SearchGoogleAdresse {
    	
	@AuraEnabled
	public static string getSuggestions(String input) {
	    WS06_GoogleApiPlaceAutocomplete gpa = new WS06_GoogleApiPlaceAutocomplete();
	    return Utils.replaceCodeToSymbol(gpa.callPlaceAutocompleteApi(input));
	}
	@AuraEnabled
	public static string getPlaceDetails(String placeId) {
     	WS06_GoogleApiPlaceDetails gpd = new WS06_GoogleApiPlaceDetails();
	    return  Utils.replaceCodeToSymbol(gpd.callPlaceDetailsApi(placeId));
	}
}