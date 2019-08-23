public with sharing class LTC13_rapportNPS {
	
	private static Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('enquetedeSatisfaction__c').getDescribe().fields.getMap();
	
    @AuraEnabled
    public static List<enquetedeSatisfaction__c> getEnquetes(String AccountId){
    	List<enquetedeSatisfaction__c> enquestes =  [Select Id, Name, noteSatisfactionGlobaleNpsPassive__c, 
    	noteSatisfactionGlobaleNpsDetractor__c, SimplicityNotesNPSPromoter__c, SimplicityNotesNPSPassive__c, SimplicityNotesNPSDetractor__c, 
    	Satisfaction1contactNotesNPSPromoter__c, Satisfaction1contactNotesNPSPassive__c, Satisfaction1contactNotesNPSDetractor__c, 
    	RepresentativeSkillsNotesNPSPromoter__c, RepresentativeSkillsNotesNPSPassive__c, RepresentativeSkillsNotesNPSDetractor__c, 
    	PropaleNotesNPSPromoter__c, PropaleNotesNPSPassive__c, PropaleNotesNPSDetractor__c, NoteSatisfactionGlobaleNpsPromoter__c, 
    	NoteReactiviteNpsPromoter__c, NoteReactiviteNpsPassive__c, NoteReactiviteNPSDetractor__c  From enquetedeSatisfaction__c Where Partner__c =:AccountId];
    	return enquestes;
    }
    
    private static String getLabel(String fieldName) {
		Schema.SObjectField field = fieldMap.get(fieldName);
		Schema.DescribeFieldResult describe = field.getDescribe();
		return describe.getLabel();
	}

	@AuraEnabled
	public static Map<String, String> getLabels() {
		//Workaround to get field label in lightning component
		Map<String, String> labels = new Map<String, String>();
		labels.put('RepresentativeSkillsNotes__c', getLabel('RepresentativeSkillsNotes__c'));
		labels.put('notedeSatisfactionGlobale__c', getLabel('notedeSatisfactionGlobale__c'));
		labels.put('NotePropale__c', getLabel('NotePropale__c'));
		labels.put('RepresentativeReactivityNote__c', getLabel('RepresentativeReactivityNote__c'));
		labels.put('Simplicite_du_process__c', getLabel('Simplicite_du_process__c'));
		labels.put('notedeSatisfactionPrisecontact__c', getLabel('notedeSatisfactionPrisecontact__c'));
		return labels;
	}
}