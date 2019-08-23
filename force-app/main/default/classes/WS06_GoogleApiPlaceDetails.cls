public with sharing class WS06_GoogleApiPlaceDetails extends WS06_GoogleApi {
    
    public WS06_GoogleApiPlaceDetails() {
    	prepareRequest(Constants.WS_GOOGLE_API_PLACE_DETAILS);
    	
    	this.isFromAuraComponent = true;
    }
    
    public String callPlaceDetailsApi(String placeId) {
    	Google_Settings__c settings = Google_Settings__c.getOrgDefaults();
    	
    	this.req.setEndpoint(formatEndpoint(this.req.getEndpoint(), placeId, settings));
    	
    	HttpResponse resp = sendRequest();
    	
    	return resp.getBody();
    }
    
    private String formatEndpoint(String endpoint, String placeId, Google_Settings__c settings) {
    	System.debug(endpoint);
    	System.debug(placeId);
    	System.debug(settings);
    	return endpoint.replace('<placeid>', EncodingUtil.urlEncode(placeId, 'UTF-8')).replace('<key>', (settings != null && settings.ApiKey__c != null ? settings.ApiKey__c : ''));
    }
    
    public override HttpResponse callMock(HttpRequest req) {
    	MockHttpResponse mock = new MockHttpResponse();
    	return mock.respondPlaceDetails(req);
    }
}