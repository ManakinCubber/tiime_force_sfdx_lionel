public with sharing class LTC11_MapCabinets {
    
    @AuraEnabled
    public static List<Account> getCabinets() {
    	return [SELECT Id, Name, BillingStreet, BillingCity, BillingPostalCode, BillingCountry FROM Account WHERE Actif__c = true AND RecordType.DeveloperName = :Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_PARTNER];
    }
}