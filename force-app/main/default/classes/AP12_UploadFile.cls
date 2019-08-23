public with sharing class AP12_UploadFile {

	public static void beforeDelete(Map<Id,ContentDocument> oldMap) {
		//Find type of linked entity
		Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();
		List<SObject> updatedObjects = new List<SObject>();

		List<Associate__c> partners = [SELECT ID_Id_Card__c,ID_Vital_Card__c,ID_Kbis__c,ID_Status__c FROM Associate__c WHERE
		                               ID_Id_Card__c IN :oldMap.keySet() OR
		                               ID_Vital_Card__c IN :oldMap.keySet() OR
		                               ID_Kbis__c IN :oldMap.keySet() OR
		                               ID_Status__c IN :oldMap.keySet()];
		for(Associate__c partner : partners) {
			if(oldMap.containsKey(partner.ID_Id_Card__c)) partner.ID_Id_Card__c = null;
			if(oldMap.containsKey(partner.ID_Vital_Card__c)) partner.ID_Vital_Card__c = null;
			if(oldMap.containsKey(partner.ID_Kbis__c)) partner.ID_Kbis__c = null;
			if(oldMap.containsKey(partner.ID_Status__c)) partner.ID_Status__c = null;
			updatedObjects.add(partner);
		}

		List<Start__c> starts = [SELECT ID_Registered_Office_Owner__c,ID_Registered_Office_Lessee__c,ID_Registered_Office_Hosted__c,ID_Lease__c FROM Start__c WHERE
		                         ID_Registered_Office_Owner__c IN :oldMap.keySet() OR
		                         ID_Registered_Office_Lessee__c IN :oldMap.keySet() OR
		                         ID_Registered_Office_Hosted__c IN :oldMap.keySet() OR
		                         ID_Lease__c IN :oldMap.keySet()];
		for(Start__c start : starts) {
			if(oldMap.containsKey(start.ID_Registered_Office_Owner__c)) start.ID_Registered_Office_Owner__c = null;
			if(oldMap.containsKey(start.ID_Registered_Office_Lessee__c)) start.ID_Registered_Office_Lessee__c = null;
			if(oldMap.containsKey(start.ID_Registered_Office_Hosted__c)) start.ID_Registered_Office_Hosted__c = null;
			if(oldMap.containsKey(start.ID_Lease__c)) start.ID_Lease__c = null;
			updatedObjects.add(start);
		}

		update updatedObjects;
	}

}