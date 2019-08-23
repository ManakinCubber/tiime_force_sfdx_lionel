//@RestResource(urlMapping='/Companeo/v1/newLeads/*')
global without sharing class WS04_Companeo {
    
    //@HttpPost
    global static String sendLeads() {
    	/*RestRequest req = RestContext.request;
    	System.debug('welcome in sendLeads');
    	System.debug(req);
    	String stringBody;
    	try {
	    	Blob blobBody = req.requestBody;
	    	System.debug(blobBody);
	    	stringBody = blobBody.toString();
    	} catch(Exception e) {
    		//stringBody = req.requestBody;
    		System.debug(e);
       	}
    	System.debug(stringBody);
    	List<Lead> leads = getLeadsFromResponse(stringBody);
    	
    	if(!leads.isEmpty()) {
    		Database.SaveResult[] saveResults = Database.insert(leads, false);
    		Utils.checkSaveResults(saveResults);
    	}*/
    	return 'OK';
    }
    
    /*private static List<Lead> getLeadsFromResponse(String srcBody) {
    	String body = srcBody.replaceAll('<!\\[CDATA\\[', '').replaceAll(']]>', '').replaceAll('<br/>', '');
    	Dom.Document doc = new Dom.Document();
    	List<Lead> leads = new List<Lead>();
    	if(String.isNotBlank(body)) {
    		doc.load(body);
    		leads = readDom(doc);
    	}
    	return leads;
    }
    
    private static List<Lead> readDom(Dom.Document doc) {
    	Dom.XMLNode address = doc.getRootElement();
    	List<Lead> leads = new List<Lead>();
    	for(DOM.XMLNode child : address.getChildElements()) {
    		leads.add(createDemande(child).convertToLead());
    	}
    	return leads;
    }
    
    private static Demande createDemande(DOM.XMLNode childNode) {
    	String jsonString = checkChildren(childNode, '');
    	jsonString = Utils.removeLastChar(jsonString);
    	jsonString = addTableInJson(jsonString, '"question":', '"reponse":', '"reponses":[');
    	jsonString = jsonString.replaceAll('"reponse":', '"reponse",');
    	jsonString = jsonString.replaceAll('"reponse"', '""');
    	jsonString = addTableInJson(jsonString, '"questionnaire":{', '"question":', '"questions":[');
    	jsonString = jsonString.replaceAll('}}}', '}]}}');
        jsonString = jsonString.replaceAll(']]', ']');
    	jsonString = jsonString.remove('"question":');
    	System.debug('in createDemande');
    	System.debug(jsonString);
        Demande demande = null;
        Integer counter = 0;
        do {
        	counter ++;
        	try {
	        	demande = (Demande) JSON.deserializeStrict(jsonString, Demande.class);
        	} catch(System.JSONException e) {
        		String errorColumn = e.getMessage().substring(e.getMessage().indexOf('column:') + 7, e.getMessage().length()).replaceAll(']', '');
        		Integer indexOfError = Integer.valueOf(errorColumn);
	        	System.debug(indexOfError);
	        	jsonString = jsonString.subString(0, indexOfError-2) + '\\ ' + jsonString.subString(indexOfError-1, jsonString.length());
        		System.debug(jsonString);
        	}
        } while(demande == null && counter < 100);
         
    	
        System.debug(demande);
    	return demande;
    }
    
    private static String checkChildren(DOM.XMLNode node, String jsonString) {
    	if(!node.getChildElements().isEmpty()) {
	    	jsonString += '{';
	    	for(DOM.XMLNode child : node.getChildElements()) {
	    		if(child.getAttributeCount() > 0 && (!child.getAttributeKeyAt(0).contains('id'))) {
	    			jsonString += '"' + child.getName() + '_' + child.getAttributeKeyAt(0) + '"' + ':' + '"' + child.getAttributeValue(child.getAttributeKeyAt(0), null).trim() + '"' +',';
	    		}
	    		if(!child.getName().contains('id')) {
		    		if(!String.isBlank(child.getText())) {
			    		jsonString += '"' + child.getName() + '"' + ':' + '"' + child.getText().trim() + '"' +',';
			    	} else if(!child.getChildElements().isEmpty()) {
		    			jsonString += '"' + child.getName() + '"' + ':';
		    		}
	    		}
	    		jsonString = checkChildren(child, jsonString);
	    	}
	    	jsonString = Utils.removeLastChar(jsonString);
	    	jsonString += '},';
    	}
    	return jsonString;
    }
    
    private static String addTableInJson(String jsonString, String baliseBoucle, String balisePremierElement, String baliseDebutListe) {
    	Integer counter = 0;
    	Integer currentPosition = 0;
    	Integer firstElement;
    	while(jsonString.indexOfIgnoreCase(baliseBoucle, currentposition) != -1 && counter < 100) {
    		firstElement = jsonString.indexOfIgnoreCase(balisePremierElement, jsonString.indexOfIgnoreCase(baliseBoucle, currentposition));
    		jsonString = jsonString.substring(0, firstElement) + baliseDebutListe + jsonString.substring(firstElement, jsonString.length());
    		firstElement = jsonString.indexOfIgnoreCase('}', jsonString.indexOfIgnoreCase(baliseDebutListe, firstElement));
    		jsonString = jsonString.substring(0, firstElement) + ']' + jsonString.substring(firstElement, jsonString.length());
    		currentPosition = firstElement;
    		counter++;
    	}
    	return jsonString;
    }
    
    private class Demande {
    	private String lead_id;
    	private String dem_num;
    	private String offer;
    	private String offer_id;
    	private String lead_date;
    	private String raison_sociale;
    	private String civilite;
    	private String nom;
    	private String prenom;
    	private String effectif;
    	private String activite;
    	private String activite_code;
    	private String poste;
    	private String poste_code;
    	private String fonction;
    	private String fonction_code;
    	private String code_postal;
    	private String ville;
    	private String adresse;
    	private String adresse2;
    	private String adresse3;
    	private String email;
    	private String telephone;
    	private String fax;
    	private String mobile;
    	private String commentaire;
    	private String internal_contact;
    	private Questionnaire questionnaire;
    	
    	public Lead convertToLead() {
    		Lead lead = new Lead(
    			Salutation = (this.civilite == 'MR' ? 'Monsieur' : 'Madame'),
    			FirstName = this.prenom, 
    			LastName = this.nom, 
    			Email = this.email,
    			MobilePhone = (this.mobile != null ? this.mobile : this.telephone),
    			Street = this.adresse,
    			City = this.ville,
    			PostalCode = this.code_postal,
    			Country = Constants.LEAD_COUNTRY_DEFAULT,
    			Company = this.raison_sociale,
    			Activity__c = findActivity(this.activite),
    			WebFormComments__c = formatComments(this.commentaire, questionnaire),
    			//HowManyEmployees__c = Integer.valueOf(this.effectif),
    			
    			Status = Constants.LEAD_STATUS_CALL1,
    			OwnerId = findQueue(),
    			OrigineWebsite__c = Constants.LEAD_WEBSITE_ORIGIN_COMPANEO,
    			UtmSource__c = Constants.LEAD_UTM_SOURCE_PARTENAIRE
    		);
    		
    		try {
    			lead.NumberOfEmployees = Integer.valueOf((this.effectif == null ? '0' : this.effectif));
    		} catch(Exception e) {
    			lead.WebFormComments__c += '</br></br>Effectif : ' + this.effectif;
    		}
    		
    		return lead;
    	}
    	
    	private String findActivity(String srcValue) {
    		String result = null;
    		if(String.isNotBlank(srcValue)) {
	    		List<Schema.PicklistEntry> pleList = Utils.getPicklistEntries('Lead', 'Activity__c');
	    		for(Schema.PicklistEntry ple : pleList) {
	    			if(ple.getValue().contains(srcValue) || srcValue.contains(ple.getValue())) {
	    				result = ple.getValue();
	    				break;
	    			}
	    		}
    		}
    		return result;
    	}
    	
    	private String formatComments(String commentaire, Questionnaire questionnaire) {
    		String result = commentaire;
    		if(questionnaire != null) {
	    		for(Question q : questionnaire.questions) {
	    			result += '</br></br>';
	    			result += q.value + '</br>';
	    			for(String s : q.reponses) {
	    				if(String.isNotBlank(s)) {
	    					result += s +'; ';
	    				}
	    			}
	    		}
    		}
    		return result;
    	}
    	
    	private Id findQueue() {
    		Id idReturned = null;
    		List<Group> groups = [SELECT Id FROM Group WHERE Type = :Constants.FILE_ATTENTE_OBJECT_TYPE AND DeveloperName = :Constants.FILE_ATTENTE_CALL1_DEV_NAME];
    		if(!groups.isEmpty()) {
    			idReturned = groups.get(0).Id;
    		}
    		return idReturned;
    	}
	}
    
    private class Questionnaire {
    	private List<Question> questions;
    }
    private class Question {
    	private String value;
    	private List<String> reponses;
    }*/
}