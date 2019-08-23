public class LTC26_InterviewAE {
    
    private static final Map<String, Set<String>> objectNameToFieldsNameMap = new Map<String, Set<String>> {
    	'Transfert__c'	=> new Set<String> {'AEComments__c', 'LeadTemperature__c', 'TemperatureDetails__c', 'Lead__c'},
    	'Lead'			=> new Set<String> {'Canal__c', 'Detail__c', 'Partnership__c', 'Event__c'}
    };
    
    @AuraEnabled
	public static Map<String, String> getLabels() {
		//Workaround to get field label in lightning component
		Map<String, String> labels = new Map<String, String>();
		for(String objectName : objectNameToFieldsNameMap.keySet()) {
    		for(String fieldApiName : objectNameToFieldsNameMap.get(objectName)) {
    			labels.put(fieldApiName, Utils.getFieldLabel(objectName, fieldApiName));
    		}
    	}
		return labels;
	}
	
	@AuraEnabled
	public static Lead retrieveLead(Id transfertId) {
		return [SELECT Id, Lead__c, Lead__r.Id, Lead__r.Name, Lead__r.Canal__c, Lead__r.Detail__c, Lead__r.Partnership__c, Lead__r.Event__c, Lead__r.CustomerRecommendation__c, Lead__r.OrigineWebsite__c, Lead__r.MobilePhone, Lead__r.Email, Lead__r.LastName, Lead__r.Company 
		FROM Transfert__c WHERE Id = :transfertId].get(0).Lead__r; 
	}
}