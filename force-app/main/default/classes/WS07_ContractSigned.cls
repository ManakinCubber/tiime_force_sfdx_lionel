@RestResource(urlMapping='/bgi/v1/contractSigned/*')
global without sharing class WS07_ContractSigned {
    
    @HttpPost
    global static String newlySignedContract() {
    	String errorMessage = null;
    	RestRequest req = RestContext.request;
    	System.debug('welcome in newlySignedContract');
    	System.debug(req);
    	try {
	    	Blob blobBody = req.requestBody;
	    	System.debug(blobBody);
	    	WS07_ContractSigned.ContractDTO contractDto = (WS07_ContractSigned.ContractDTO) JSON.deserializeStrict( req.requestBody.toString(), ContractDTO.class);
	    	manageSignature(contractDto);
    	} catch(Exception e) {
    		System.debug(e);
    		errorMessage = e.getMessage();
       	}
       	
    	return errorMessage == null ? 'OK': errorMessage;
    }
    
    @TestVisible
    private static void manageSignature(ContractDTO contract) {
    	if(contract != null) {
    		// On recherche une lead non convertie (encore modifiable) corespondant à ce numéro de dossier.
    		List<Lead> leads = [SELECT Id, ContractSign__c FROM Lead WHERE NumeroCompteBaseGI__c = :contract.numeroDossier AND IsConverted = false AND ContractSign__c = false];
    		if(!leads.isEmpty()) {
    			Lead leadToUpdate = leads.get(0);
    			leadToUpdate.ContractSign__c = true;
    			update leadToUpdate;
    			
    			// La lead peut maintenant être convertie
    			Database.LeadConvertResult result = convertLead(leadToUpdate.Id);
    			
    			// L'opportunité peut être fermée dès maintenant.
   				closeOpp(result.getAccountId());
    		} else {
    			// Si aucune lead n'a été trouvée, cela peut signifier qu'elle a été convertie. On cherche donc un compte ayant le même numéro de dossier.
    			List<Account> accounts = [SELECT Id, ContractSign__c FROM Account WHERE NumberBGI__c = :contract.numeroDossier AND ContractSign__c = false];
    			if(!accounts.isEmpty()) {
    				Account accountToUpdate = accounts.get(0);
    				accountToUpdate.ContractSign__c = true;
    				update accountToUpdate;
    				
    				// L'opportunité peut être fermée.
    				closeOpp(accountToUpdate.Id);
    			} else {
    				throw new WS07_Exception('Aucun compte ou lead trouvé dans Salesforce avec l\'identifiant ' + contract.numeroDossier +'.');
    			}
    		}
    	} else {
    		throw new WS07_Exception('Impossible de lire le corps de la requête.');
    	}
    }
    
    private static Database.LeadConvertResult convertLead(Id leadId) {
    	LeadConverterProcessAE converter = new LeadConverterProcessAE(leadId);
    	return converter.launchLeadConversion();
    }
    
    private static void closeOpp(Id accountId) {
    	List<Opportunity> opps = [SELECT Id, StageName FROM Opportunity WHERE AccountId = :accountId AND StageName NOT IN :Constants.OPP_STAGENAME_CLOSED_SET];
    	for(Opportunity o : opps) {
    		o.StageName = Constants.OPP_STAGENAME_CONTRACT_SIGNED;
    	}
    	update opps;
    }
    
    public class ContractDTO {
    	private Integer numeroDossier;
    	private DateTime signatureTime;
    	
    	public ContractDTO(Integer numeroDossier) {
    		this.numeroDossier = numeroDossier;
    	}
    	public ContractDTO(Integer numeroDossier, DateTime signatureTime) {
    		this.numeroDossier = numeroDossier;
    		this.signatureTime = signatureTime;
    	}
    }
    
    private class WS07_Exception extends Exception {}
}