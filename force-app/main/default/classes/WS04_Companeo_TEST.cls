/*@isTest*/
public class WS04_Companeo_TEST {
        
    /*@isTest
    static void testGettingNewLeads() {
    	
    	List<Lead> leads = [SELECT Id FROM Lead];
    	System.assert(leads.isEmpty());
    	
    	Test.startTest();
    	WS04_Companeo ws = new WS04_Companeo();
    	ws.req.setHeader('path', 'ok');
    	ws.getAllNewLeadsFromCompaneo();
    	Test.stopTest();
    	
    	leads = [SELECT Id FROM Lead];
    	System.assert(leads.size() == 2);
    }
    
    @isTest
    static void testGettingNewLeadsNoLeads() {
    	
    	List<Lead> leads = [SELECT Id FROM Lead];
    	System.assert(leads.isEmpty());
    	
    	Test.startTest();
    	WS04_Companeo ws = new WS04_Companeo();
    	ws.req.setHeader('path', 'none');
    	ws.getAllNewLeadsFromCompaneo();
    	Test.stopTest();
    	
    	leads = [SELECT Id FROM Lead];
    	System.assert(leads.isEmpty());
    }
    
    @isTest
    static void testGettingNewLeadsDoublon() {
    	
    	List<Lead> leads = [SELECT Id FROM Lead];
    	System.assert(leads.isEmpty());
    	List<LogError__c> errors = [SELECT Id FROM LogError__c];
    	System.assert(errors.isEmpty());
    	
    	Test.startTest();
    	WS04_Companeo ws = new WS04_Companeo();
    	ws.req.setHeader('path', 'doublon');
    	ws.getAllNewLeadsFromCompaneo();
    	
    	
    	leads = [SELECT Id, Email, Name, MobilePhone FROM Lead];
    	System.assert(leads.size() == 1);
    	errors = [SELECT Id, Message__c FROM LogError__c];
    	System.assert(errors.isEmpty());
    	
    	ws.getAllNewLeadsFromCompaneo();
    	Test.stopTest();
    	
    	leads = [SELECT Id, Email, Name, MobilePhone FROM Lead];
    	System.assert(leads.size() == 2);
    	errors = [SELECT Id, Message__c FROM LogError__c];
    	System.assert(errors.size() == 1);
    	for(LogError__c e : errors) {
    		System.debug(e.Message__c);
    	}
    }*/
}