public class SMS {
    public class MessageParameter{
        @InvocableVariable(required=true)
        public String numero;
        @InvocableVariable(required=true)
        public String texte;
        @InvocableVariable(required=true)
        public String idLead;
	}
    
    @InvocableMethod
    public static void Send(MessageParameter[] parametres) {
        sendAsync(parametres[0].numero, parametres[0].texte, parametres[0].idLead);
    }
    
    public static String getExpediteur(String objectId){
    	String branding;
    	if(Utils.isInstanceOf(Constants.TRANSFERT_OBJECT_API_NAME, objectId)) {
    		branding = [SELECT Branding__c FROM Transfert__c  WHERE Id=:objectId].Branding__c;
    	} else if(Utils.isInstanceOf(Constants.LEAD_OBJECT_API_NAME, objectId)) {
    		branding = [SELECT Branding__c FROM Lead  WHERE Id=:objectId].Branding__c;
    	} else if(Utils.isInstanceOf(Constants.OPP_OBJECT_API_NAME, objectId)) {
    		branding = [SELECT Branding__c FROM Opportunity  WHERE Id=:objectId].Branding__c;
    	}
    	 
    	String PHONE_STANDARD_SDR = '#'+Constants.PHONE_STANDARD_SDR;
    	System.debug('PHONE_STANDARD_SDR -> '+PHONE_STANDARD_SDR);
    	Map<String, String>  LEAD_MAP_SMS_BRANDING_EXPEDITEUR = new Map<String, String> {
	   		'Novaa' => 'Novaa',
	   		'Incityz' => 'Incityz',
	   		'Condillac' => 'Condillac',
	   		'Ola Compta' => 'Ola Compta',
	   		'Goneo' => 'Goneo',
	   		'Le Net Expert Comptable' => 'WEB_SMS',
	   		'Onlicorn' => 'Onlicorn',
	   		'Pepit' => 'Pepit',
	   		'Evocompta' => 'Evocompta',
	   		'Tiime' => 'Tiime',
	   		'L-Expert-Comptable Lille' => 'WEB_SMS',
	   		'L-Expert-Comptable.com' => 'WEB_SMS',
	   		'Trouver-mon-comptable.com' => 'WEB_SMS',
	   		'Auficom' => 'Auficom',
			'Proxi Compta' => 'ProxiCompta'
   		};
   		return LEAD_MAP_SMS_BRANDING_EXPEDITEUR.get(branding);
    }
    
	@future(callout=true) 
    public static void sendAsync(String numero, String texte, String objectId) {
    	sendSMS(numero, texte, objectId, true);
    }
    
    public static boolean sendSMS(String numero, String texte, String objectId, boolean createTask) {
    	boolean smsSent = false;
    	String expediteur = SMS.getExpediteur(objectId);
        Message[] messages = new Message[0];
        Message msg = new Message();
        msg.to = numero;
        msg.body = texte;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.esendex.com/v1.0/messagedispatcher');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        String auth = 'Basic ' + EncodingUtil.base64Encode(Blob.valueof('valery.erhard@infoneo.fr:NDX2997'));
        req.setHeader('Authorization', auth);
        req.setHeader('Accept', '*/*');
        messages.add(msg);
        
        Query query = new Query();
        query.accountreference = 'EX0074883';
        query.messages = messages;
        String chaine = JSON.Serialize(query);
        chaine = chaine.left(chaine.indexOf(',')) + ',"from":"'+ expediteur  +'"' + chaine.right(chaine.length() - chaine.indexOf(','));
        req.setBody(chaine);
        System.debug(chaine);
        HttpResponse res;
        if(!Test.isRunningTest()) {
        	res = h.send(req);
        } else {
        	res = new HttpResponse();
        	res.setStatusCode(200);
        }
        if(res.getStatusCode() == 200) {
        	smsSent = true;
        	if(createTask) {
            	Task saveSms = new Task(Subject = 'Détails SMS', Status = 'Terminé', Description = texte, ActivityDate = Date.today());
            	
            	if(Utils.isInstanceOf(Constants.TRANSFERT_OBJECT_API_NAME, objectId) || Utils.isInstanceOf(Constants.OPP_OBJECT_API_NAME, objectId)) {
		    		saveSms.WhatId = objectId;
		    	} else if(Utils.isInstanceOf(Constants.LEAD_OBJECT_API_NAME, objectId)) {
		    		saveSms.WhoId = objectId;
		    	}
            	
            	Insert saveSms;
        	}
        }
        
        System.debug(res.getBody());
        System.debug(res.getStatusCode());
        System.debug(res.getStatus());
        return smsSent;
    }
    
    public class Message {
        String to {get;set;}
        String body {get;set;}
        public Message() {
            
        }
	}
    
    public class Query {
        String accountreference {get; set;}
        Message[] messages {get; set;}
    }
}