@isTest
public class Batch_Confirmation_SMS_TEST {
    
    @TestSetup
    static void prepareData() {
    	AP04_Factory.createGenericDataSample();
    	
    	// Generate an Start__c record
    	List<Lead> leads = [SELECT Id FROM Lead];
    	Start__c start = new Start__c(Crea__c = leads.get(0).Id);
    	insert start;
    	
    	// Generate an event on the start record
    	Event event = new Event(WhatId = start.Id, OwnerId = UserInfo.getUserId(), StartDateTime = DateTime.now().addHours(23).addMinutes(59), EndDateTime = Datetime.now().addHours(24));
    	insert event;
    	
    	List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE RecordType.DeveloperName = :Constants.CONTACT_RECORDTYPE_DEVELOPERNAME_PARTNER];
    	if(!contacts.isEmpty()) {
    		Transfert__c transfert = new Transfert__c(
    			Lead__c = leads.get(0).Id, 
    			Partenaire__c = contacts.get(0).AccountId, 
    			ContactPartenaire__c = contacts.get(0).Id
    		);
    		insert transfert;
    		
    		Event transfertEvent = new Event(WhatId = transfert.Id, OwnerId = UserInfo.getUserId(), StartDateTime = DateTime.now().addHours(23).addMinutes(59), EndDateTime = Datetime.now().addHours(24));
    		insert transfertEvent;
    	} else {
    		System.assert(false);
    	}
    }
    
    @isTest
    static void testRunBatch() {
    	List<Event> events = [SELECT Id, ConfirmationSmsSend__c FROM Event];
    	System.assert(events.size() == 2);
    	System.assert(!events.get(0).ConfirmationSmsSend__c);
    	System.assert(!events.get(1).ConfirmationSmsSend__c);
    	
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new SMS_Test.wsSMS_Mock());
    	System.enqueueJob(new Batch_Confirmation_SMS());
    	Test.stopTest();
    	
    	events = [SELECT Id, ConfirmationSmsSend__c FROM Event];
    	System.assert(events.size() == 2);
    	System.assert(events.get(0).ConfirmationSmsSend__c);
    	System.assert(events.get(1).ConfirmationSmsSend__c);
    }
}