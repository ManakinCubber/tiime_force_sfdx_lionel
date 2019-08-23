public without sharing class WS06_GoogleApiDistanceMatrix extends WS06_GoogleApi {
    
    public WS06_GoogleApiDistanceMatrix() {
    	prepareRequest(Constants.WS_GOOGLE_API_DISTANCE_MATRIX);
    	
    	this.isFromAuraComponent = true;
    }
    
    public String callDistanceMatrixApi(String leadAddress, String accAddresses) {
    	Google_Settings__c settings = Google_Settings__c.getOrgDefaults();
    	
    	this.req.setEndpoint(formatEndpoint(this.req.getEndpoint(), leadAddress, accAddresses, settings));
    	
    	HttpResponse resp = sendRequest();
    	
    	return resp.getBody();
    }
    
    public override HttpResponse callMock(HttpRequest req) {
    	MockHttpResponse mock = new MockHttpResponse();
    	return mock.respondDistanceMatrix(req);
    }
    
    private String formatEndpoint(String endpoint, String leadAddress, String accAddresses, Google_Settings__c settings) {
    	return endpoint.replace('<origins>', EncodingUtil.urlEncode(leadAddress, 'UTF-8')).replace('<destinations>', EncodingUtil.urlEncode(accAddresses, 'UTF-8')).replace('<key>', (settings != null && settings.ApiKey__c != null ? settings.ApiKey__c : ''));
    }
}