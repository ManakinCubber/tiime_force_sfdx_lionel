public with sharing class WS03_BaseGI_GetOffres extends WS03_BaseGI {
    
    public WS03_BaseGI_GetOffres() {
    	prepareRequest(Constants.WS_BAGI_GET_OFFRES_AUTH_NAME);
    	this.isFromAuraComponent = true;
		this.mustLogError = true;
    }
    
    public override HttpResponse callMock(HttpRequest req) {
    	MockHttpResponse mock = new MockHttpResponse();
    	return mock.respondGetOffres(this.req);
    }
    
    public WS03_BaseGI.WsGetOffresResponse getOffresByBranding(Id leadId) {
    	// Retrieve the lead's branding using the Id
    	Lead lead = [SELECT Id, Branding__c FROM Lead WHERE Id = :leadId];
    	WS03_BaseGI.WsGetOffresResponse respObject = null;
    	
    	if(lead != null) {
    		this.req.setEndpoint(this.req.getEndpoint() + lead.Branding__c);
    		HttpResponse resp = sendRequest();
    		System.debug(resp);
    		System.debug(resp.getBody());
    		
    		//String fakeBody = '{"code":0,"erreur":"","offres":[{"id":1,"designation":"Offre Novaa","missions":[{"id":1,"idMarque":55,"tarif":"99.00","libelle":"Comptabilit\u00e9","periodicite":"M"},{"id":2,"idMarque":55,"tarif":"499.00","libelle":"Bilan","periodicite":"A"}]}, {"id":2,"designation":"Offre Test","missions":[{"id":3,"idMarque":55,"tarif":"69.00","libelle":"TestMission","periodicite":"M"}]}]}';
    		respObject = (WS03_BaseGI.WsGetOffresResponse) JSON.deserializeStrict(resp.getBody(), WsGetOffresResponse.class);
    		System.debug(respObject);
    	}
    	return respObject;
    }
}