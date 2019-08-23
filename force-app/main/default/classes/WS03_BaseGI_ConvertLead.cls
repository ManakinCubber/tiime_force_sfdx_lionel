public with sharing class WS03_BaseGI_ConvertLead extends WS03_BaseGI {
    
    public WS03_BaseGI_ConvertLead() {
    	prepareRequest(Constants.WS_BAGI_CONVERT_LEAD_AUTH_NAME);
    	this.isFromAuraComponent = true;
		this.mustLogError = true;
    }
    
    public override HttpResponse callMock(HttpRequest req) {
    	MockHttpResponse mock = new MockHttpResponse();
    	return mock.respondConvertLead(this.req);
    }
    
    public void updateBGIAfterLeadConversion(Id accountId, Id oppId/*String offresIds*/) {
    	List<Account> accounts = [SELECT Id, Name, NumberBGI__c, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, ContractSignLink__c,
    		(SELECT Id, FirstName, LastName, Email, MobilePhone FROM Contacts),
    		(SELECT Id, Branding__c FROM Opportunities ORDER BY CreatedDate DESC) FROM Account WHERE Id = :accountId];
    	
    	List<Mission__c> missions = [SELECT Id, MissionBgiId__c, Price__c, MissionName__c, OfferName__c, Comment__c FROM Mission__c WHERE Opportunity__c = :oppId];
    	
    	if((!accounts.isEmpty()) && (!accounts.get(0).Contacts.isEmpty())) {
    		WS03_BaseGI.WsConvertedAccountWrapper wrapper = new WS03_BaseGI.WsConvertedAccountWrapper(
    			accounts.get(0), 
    			accounts.get(0).Contacts.get(0), 
    			missions
    		);
    		
    		this.req.setBody(wrapper.generateJSON());
    		System.debug(this.req.getBody());
    		HttpResponse resp = sendRequest();
    		
    		System.debug(resp);
    		System.debug(resp.getBody());
    		WS03_BaseGI.WsConvertedAccountResponse respObject = (WS03_BaseGI.WsConvertedAccountResponse) JSON.deserializeStrict(resp.getBody(), WsConvertedAccountResponse.class);
    		if(String.isBlank(respObject.erreur)) {
    			update new Account(Id = accountId, ContractSignLink__c = respObject.url);
    			//sendEmailAndSmsToClient(accountId);
    		} else {
    			//Utils.createLogError('Erreur lors de la conversion dans la BaseGI pour le compte ' + accountId + ': ' + respObject.erreur);
		   		throw new AuraHandledException('Erreur lors de la conversion dans la BaseGI pour le compte ' + accountId + ': ' + respObject.erreur);
    		}
    	}
    }
}