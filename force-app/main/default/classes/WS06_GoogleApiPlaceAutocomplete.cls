public with sharing class WS06_GoogleApiPlaceAutocomplete extends WS06_GoogleApi {
    
    public WS06_GoogleApiPlaceAutocomplete() {
    	prepareRequest(Constants.WS_GOOGLE_API_PLACE_AUTOCOMPLETE);
    	
    	this.isFromAuraComponent = true;
    }
    
    public String callPlaceAutocompleteApi(String input) {
    	Google_Settings__c settings = Google_Settings__c.getOrgDefaults();
    	
    	this.req.setEndpoint(formatEndpoint(this.req.getEndpoint(), input, settings));
    	
    	HttpResponse resp = sendRequest();
    	
    	return resp.getBody();
    }
    
    private String formatEndpoint(String endpoint, String input, Google_Settings__c settings) {
    	return endpoint.replace('<input>', EncodingUtil.urlEncode(input, 'UTF-8')).replace('<key>', (settings != null && settings.ApiKey__c != null ? settings.ApiKey__c : ''));
    }
    
    public override HttpResponse callMock(HttpRequest req) {
    	MockHttpResponse mock = new MockHttpResponse();
    	return mock.respondPlaceAutocomplete(req);
    }
}