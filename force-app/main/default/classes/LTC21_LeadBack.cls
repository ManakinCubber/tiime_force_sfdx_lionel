public with sharing class LTC21_LeadBack {
	@AuraEnabled
	public static void horodatageLeadBackT(Id transferId, Id leadId){
		update new Transfert__c(Id = transferId, LeadBackCastingError__c = true, DateLeadBackCastingError__c = Datetime.now());
		update new Lead(Id = leadId, LeadBackCastingError__c = true, DateLeadBackCastingError__c = Datetime.now());
	}
	
	@AuraEnabled
	public static void horodatageLeadBackPC(Id startId, Id leadId){
		update new Start__c(Id = startId, LeadBackTiimeCrea__c = true, DateLeadBackTiimeCrea__c = Datetime.now());
		update new Lead(Id = leadId, LeadBackTiimeCrea__c = true, DateLeadBackTiimeCrea__c = Datetime.now());
	}
	
	@AuraEnabled
	public static void horodatageLeadBackCastingPC(Id startId, Id leadId){
		update new Start__c(Id = startId, LeadBackCastingError__c = true, DateLeadBackCastingError__c = Datetime.now());
		update new Lead(Id = leadId, LeadBackCastingError__c = true, DateLeadBackCastingError__c = Datetime.now());
	}
}