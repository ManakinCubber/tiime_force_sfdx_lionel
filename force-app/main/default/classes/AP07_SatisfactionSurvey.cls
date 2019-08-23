public with sharing class AP07_SatisfactionSurvey {
	private static Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('enquetedeSatisfaction__c').getDescribe().fields.getMap();

	private static String getLabel(String fieldName) {
		Schema.SObjectField field = fieldMap.get(fieldName);
		Schema.DescribeFieldResult describe = field.getDescribe();
		return describe.getLabel();
	}

	@AuraEnabled
	public static Map<String, String> getLabels() {
		//Workaround to get field label in lightning component
		Map<String, String> labels = new Map<String, String>();
		labels.put('notedeSatisfactionGlobale__c', getLabel('notedeSatisfactionGlobale__c'));
		labels.put('RepresentativeSkillsNotes__c', getLabel('RepresentativeSkillsNotes__c'));
		labels.put('RepresentativeReactivityNote__c', getLabel('RepresentativeReactivityNote__c'));
		labels.put('notedeSatisfactionPrisecontactcheck__c', getLabel('notedeSatisfactionPrisecontactcheck__c'));
		labels.put('RecommandationPartenaireCheck__c', getLabel('RecommandationPartenaireCheck__c'));
		labels.put('ComptaSigneeCheck__c', getLabel('ComptaSigneeCheck__c'));
		labels.put('NotePropale__c', getLabel('NotePropale__c'));
		labels.put('Evaluation_a_posteriori__c', getLabel('Evaluation_a_posteriori__c'));
		labels.put('notedeSatisfactionPrisecontact__c', getLabel('notedeSatisfactionPrisecontact__c'));
		labels.put('Simplicite_du_process__c', getLabel('Simplicite_du_process__c'));
		labels.put('Recommandation_Tiime_Crea__c', getLabel('Recommandation_Tiime_Crea__c'));
		labels.put('Proposition_d_un_cabinet_partenaire__c', getLabel('Proposition_d_un_cabinet_partenaire__c'));
		return labels;
	}
	
	@AuraEnabled
	public static List<Map<String, String>> getPicklistOptions(List<String> fieldNames) {
		List<Map<String, String>> lesPickLists = new List<Map<String, String>>();
		for(String fieldName : fieldNames)
			lesPickLists.add(Utils.getPicklistOptions('enquetedeSatisfaction__c', fieldName));
		return lesPickLists;
	}
	
	@AuraEnabled
	public static String getComponentTitle(Id enqueteId) {
		String title = '';
		List<EnquetedeSatisfaction__c> enquetes = [SELECT Id, RecordType.DeveloperName FROM EnquetedeSatisfaction__c WHERE Id = :enqueteId];
		if(!enquetes.isEmpty()) {
			title = Constants.ENQUETE_MAP_RECORDTYPE_DEVELOPERNAME_COMPONENT_TITLE.get(enquetes.get(0).RecordType.DeveloperName);
		}
		return title;
	}
}