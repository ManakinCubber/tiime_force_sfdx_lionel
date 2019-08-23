public with sharing class WS03_BaseGI_CreateDossierBGI extends WS03_BaseGI {
    
    public WS03_BaseGI_CreateDossierBGI() {
    	prepareRequest(Constants.WS_BAGI_ACC_CREA_FROM_LEAD_AUTH_NAME);
    	this.isFromAuraComponent = true;
		this.mustLogError = true;
    }
    
    public override HttpResponse callMock(HttpRequest req) {
    	MockHttpResponse mock = new MockHttpResponse();
    	return mock.respondCreateAccountFromLead(this.req);
    }
    
    public void createAccountFromLead(Id leadId) {
    	
    	List<Lead> leads = [SELECT Id, Company, FirstName, LastName, Name, Email, MobilePhone, OwnerId, City, PostalCode, Street, NumeroCompteBaseGI__c, NumeroIndividuBaseGI__c,
		TypeOfNeed__c, Echeance_de_besoin_de_creation__c, LegalStatus__c, Activity__c, ActivityDetails__c, UtmSource__c, UtmMedium__c, partenaire__c, Canal__c, 
    		partenaire__r.IdBureauBaseGI__c, Contact_Partenaire__r.FirstName, Contact_Partenaire__r.LastName FROM Lead WHERE Id = :leadId AND NumeroCompteBaseGI__c = null];
    	if(!leads.isEmpty()) {
    		Lead lead = leads.get(0);
	    	if(lead != null && lead.partenaire__c != null && lead.partenaire__r.IdBureauBaseGI__c != null) {
		    		
			    User user = [SELECT FirstName, LastName FROM User WHERE Id = :lead.OwnerId];
			    	
			    WS03_BaseGI.WsAccountFromLeadWrapper wrapper = new WS03_BaseGI.WsAccountFromLeadWrapper(lead, lead.partenaire__r, lead.Contact_Partenaire__r, user);
			    this.req.setBody(wrapper.generateJSON());
			    //System.debug(req.getBody());
			    //System.debug(req);
			    
			    handleWsRequest(wrapper, lead, 0);
	    	}
    	}
    }
    
    private void handleWsRequest(WsAccountFromLeadWrapper wrapper, Lead lead, Integer deepGauge) {
    	deepGauge++;
    	HttpResponse resp = sendRequest();
    	
    	if(resp != null) {
		    WS03_BaseGI.WsAccountFromLeadResponse respObject = (WS03_BaseGI.WsAccountFromLeadResponse) JSON.deserializeStrict(resp.getBody(), WsAccountFromLeadResponse.class);//Untyped
		    	
		   	if(String.IsNotBlank(respObject.erreur)) {
		   		if(respObject.code == Constants.WS_BAGI_ERROR_CODE_DUPLICATE && deepGauge == 1) {
		   			wrapper.modifyLeadName(' ' + DateTime.now().format(('dd-MM-YYYY HH\'h\'mm')));
		   			this.req.setBody(wrapper.generateJSON());
		   			handleWsRequest(wrapper, lead, deepGauge);
		   		} else {
		   			//Utils.createLogError('Erreur lors de création du dossier BGI pour la lead Id ' + lead.Id + ': ' + respObject.erreur);
		   			throw new AuraHandledException('Erreur lors de création du dossier BaseGI pour la lead Id ' + lead.Id + ': ' + respObject.erreur);
		   		}
		   	} else {
	    		lead.NumeroCompteBaseGI__c = respObject.numeroDossier;
	    		lead.NumeroIndividuBaseGI__c = respObject.idIndividu;
	    		update lead;
	    	}
	    }
    }
}