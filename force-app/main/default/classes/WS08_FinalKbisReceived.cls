@RestResource(urlMapping='/bgi/v1/finalKbisReceived/*')
global without sharing class WS08_FinalKbisReceived {

	@HttpPost
    global static String newKbisReceived() {
    	String errorMessage = null;
    	RestRequest req = RestContext.request;
    	System.debug(req);
    	try {
	    	Blob blobBody = req.requestBody;
	    	System.debug(blobBody);
	    	WS08_FinalKbisReceived.KbisInfoDTO kbis = (WS08_FinalKbisReceived.KbisInfoDTO) JSON.deserializeStrict( req.requestBody.toString(), KbisInfoDTO.class);
	    	manageKbisReception(kbis);
    	} catch(Exception e) {
    		System.debug(e);
    		errorMessage = e.getMessage();
       	}
       	
    	return errorMessage == null ? 'OK': errorMessage;
    }
	
	@TestVisible
    private static void manageKbisReception(KbisInfoDTO kbis) {
    	if(kbis != null) {
    		// On recherche une lead non convertie (encore modifiable) corespondant à ce numéro de dossier.
    		List<Lead> leads = [SELECT Id, KbisReceive__c, KbisReceptionDate__c, NumeroCompteBaseGI__c FROM Lead WHERE NumeroCompteBaseGI__c = :kbis.numeroDossier AND IsConverted = false AND KbisReceive__c = false];
    		if(!leads.isEmpty()) {
    			Lead leadToUpdate = leads.get(0);
    			leadToUpdate.KbisReceive__c = true;
    			leadToUpdate.KbisReceptionDate__c = kbis.receivedKbisDate;
    			update leadToUpdate;
    			
    			// Le projet de création peut être passé au statut Kbis reçu
    			changeStartStatus(leadToUpdate.NumeroCompteBaseGI__c.intValue());
    		} else {
    			// Si aucune lead n'a été trouvée, cela peut signifier qu'elle a été convertie. On cherche donc un compte ayant le même numéro de dossier.
    			List<Account> accounts = [SELECT Id, KbisReceive__c, DateKbisReceive__c, NumberBGI__c FROM Account WHERE NumberBGI__c = :kbis.numeroDossier AND KbisReceive__c = false];
    			if(!accounts.isEmpty()) {
    				Account accountToUpdate = accounts.get(0);
    				accountToUpdate.KbisReceive__c = true;
    				accountToUpdate.DateKbisReceive__c = kbis.receivedKbisDate;
    				update accountToUpdate;
    				
    				// Le projet de création peut être passé au statut Kbis reçu
    				changeStartStatus(accountToUpdate.NumberBGI__c.intValue());
    			} else {
    				throw new WS08_Exception('Aucun compte ou lead trouvé dans Salesforce avec l\'identifiant ' + kbis.numeroDossier +'.');
    			}
    		}
    	} else {
    		throw new WS08_Exception('Impossible de lire le corps de la requête.');
    	}
    }
	
	private static void changeStartStatus(Integer numeroDossier) {
		List<Start__c> projetsCrea = [SELECT Id, ProjectStatus__c FROM Start__c WHERE  Crea__r.NumeroCompteBaseGI__c = :numeroDossier];
		if(!projetsCrea.isEmpty()) {
			projetsCrea.get(0).ProjectStatus__c = Constants.START_STATUS_KBIS;
			update projetsCrea.get(0);
		}
	}
	
	
	public class KbisInfoDTO {
    	private Integer numeroDossier;
    	private DateTime receivedKbisDate;
    	private Time receptionHour = Time.newInstance(9, 0, 0, 0);
    	
    	public KbisInfoDTO(Integer numeroDossier) {
    		this.numeroDossier = numeroDossier;
    	}
    	public KbisInfoDTO(Integer numeroDossier, Date receivedKbisDate) {
    		this.numeroDossier = numeroDossier;
    		this.receivedKbisDate = DateTime.newInstance(receivedKbisDate, this.receptionHour);
    	}
    	public KbisInfoDTO(Integer numeroDossier, String receivedKbisDate) {
    		this.numeroDossier = numeroDossier;
    		this.receivedKbisDate = DateTime.newInstance(Date.valueOf(receivedKbisDate), this.receptionHour);
    	}
    	
    }
	
	private class WS08_Exception extends Exception {}

}