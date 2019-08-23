public with sharing class AP15_ControllerLeadResume {
	
	private final static Integer MAX_RESULTS = 5;

	private static Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap();

	private static String getLabel(String fieldName) {
		Schema.SObjectField field = fieldMap.get(fieldName);
		Schema.DescribeFieldResult describe = field.getDescribe();
		return describe.getLabel();
	}

	@AuraEnabled
	public static Map<String, String> getLabels() {
		//Workaround to get field label in lightning component
		Map<String, String> labels = new Map<String, String>();
		labels.put('MobilePhone', getLabel('MobilePhone'));
		labels.put('WebFormComments__c', getLabel('WebFormComments__c'));
		labels.put('Evaluation_a_priori__c', getLabel('Evaluation_a_priori__c'));
		labels.put('Echeance_de_besoin_de_creation__c', getLabel('Echeance_de_besoin_de_creation__c'));
		labels.put('TypeOfNeed__c', getLabel('TypeOfNeed__c'));
		labels.put('WillHaveEmployes__c', getLabel('WillHaveEmployes__c'));
		labels.put('LegalStatus__c', getLabel('LegalStatus__c'));
		labels.put('Source__c', getLabel('Source__c'));
		labels.put('ContactPartenariat__c', getLabel('ContactPartenariat__c'));
		
		return labels;
	}
	
	@AuraEnabled
	public static List<Map<String, String>> getPicklistOptions(List<String> fieldNames) {
		List<Map<String, String>> lesPickLists = new List<Map<String, String>>();
		for(String fieldName : fieldNames)
			lesPickLists.add(Utils.getPicklistOptions('Lead', fieldName));
		return lesPickLists;

	}
	
	@AuraEnabled
	public static String nextCall(Id leadId, String status, String branding) {
		
		if(String.isBlank(branding)){
			 AuraHandledException e = new AuraHandledException('Merci de renseigner le Branding.');
			 e.setMessage('Merci de renseigner le Branding.');
			 throw e;
		}
		try{
			Lead lead = [SELECT Id, Status, Branding__c FROM Lead WHERE Id=:leadId];
			lead.Status = Constants.LEAD_MAP_NEXT_STATUS.get(status);
			lead.Branding__c = branding;
			update lead;
			return lead.Status;
		}catch(Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}
	
	@AuraEnabled
	public static String getStatus(Id leadId) {
		Lead lead = [SELECT Id, Status FROM Lead WHERE Id=:leadId];
		return lead.Status;
	}
	
	@AuraEnabled
	public static List<Contact> getContactPartenariat(Id accountId){
		return [SELECT Id, Name From Contact WHERE AccountId = :accountId];
	}
  
	@AuraEnabled
	public static String getLeadEnAttenteId(){
		return [SELECT Id FROM Group WHERE Type = :Constants.FILE_ATTENTE_OBJECT_TYPE AND DeveloperName = :Constants.FILE_ATTENTE_CALL1_DEV_NAME].Id;
	}
	
	@AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
            Stakeholder__c (Id, Name, Company__c, Contact__c WHERE id NOT IN :selectedIds),
            Lead (Id, Name WHERE id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Stackeholder & convert them into LookupSearchResult
        String stakeIcon = 'standard:contact';
        Stakeholder__c [] Stakeholders = ((List<Stakeholder__c>) searchResults[0]);
        for (Stakeholder__c stakeholder : Stakeholders) {
            results.add(new LookupSearchResult(stakeholder.Contact__c, 'Stakeholder__c', stakeIcon, stakeholder.Name, stakeholder.Name));
        }

        // Extract Opportunities & convert them into LookupSearchResult
        String leadIcon = 'standard:lead';
        Lead [] leads = ((List<Lead>) searchResults[1]);
        for (Lead l : leads) {
            results.add(new LookupSearchResult(l.Id, 'Lead', leadIcon, l.Name, l.Name));
        }

        return results;
    }
}