@isTest
public with sharing class AP07_SatisfactionSurvey_TEST {

	@isTest static void testLabels() {
		Map<String, String> labels = AP07_SatisfactionSurvey.getLabels();
		System.assertEquals(12, labels.size());
	}
	@isTest 
	static void testPickListOptions() {
		List<String> fieldNames = new List<String>();
		fieldNames.add('Evaluation_a_posteriori__c');
		fieldNames.add('Simplicite_du_process__c');
		fieldNames.add('notedeSatisfactionGlobale__c');
		List<Map<String, String>> res = AP07_SatisfactionSurvey.getPicklistOptions(fieldNames);
		System.assertEquals(3, res.size());
		for(Map<String, String> field : res){
			System.assertEquals(false, field.isEmpty());
		}
	}
}