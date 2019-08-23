/**
* author:		Kévin Melliand
* date:			13/12/2018
* description:	Classe testant AP06_SendEmailFromLead. Couverture du code à 97%.
*/
@isTest
public class AP06_SendEmailFromLead_TEST {
    
    @TestSetup
    static void dataSetup() {
    	AP04_Factory.createGenericDataSample();
    	
    	List<Lead> leads = [SELECT Id FROM Lead];
    	System.assert(!leads.isEmpty());
    }
    
    @isTest
    static void proceedTest() {
    	
    	List<Lead> leads = [SELECT Id, Salutation, Name, Company, Email FROM Lead];
    	
    	List<Account> partnerAccounts = [SELECT Id, Name, (SELECT Id, Name FROM Contacts) FROM Account WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_PARTNER];
    	
    	Test.startTest();
    	if(!partnerAccounts.isEmpty()) {
    		for(Lead l : leads) {
    			l.Partenaire__c = partnerAccounts.get(0).id;
	    		l.Contact_Partenaire__c = partnerAccounts.get(0).Contacts.get(0).id;
	    		l.Email_Body__c = 'Corps du mail pour un test';
	    		Datetime dt = Datetime.now();
	    		l.Rendez_vous__c = dt.addDays(2);
	    		l.Is_Appointment_Set__c = true;
    		}
    		
    		update leads;
    	} else {
    		System.assert(false);
    	}
    	
    	System.assert(AP06_SendEmailFromLead.hasBeenCalled);
    	System.assertEquals(4, AP06_SendEmailFromLead.nbEmail);
    	
    	Test.stopTest();
    	
    	
    }
    
    @isTest
    static void testFromProcessBuilder() {
    	List<Lead> leads = [SELECT Id, Salutation, Name, Company, Email, Status, LossReason__c FROM Lead];
    	
    	List<Account> partnerAccounts = [SELECT Id, Name, (SELECT Id, Name FROM Contacts) FROM Account WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_PARTNER];
    	
    	Lead lead = Leads.get(0);
    	//lead.Status = Constants.LEAD_STATUS_CALL2;
    	//update lead;
    	
    	Test.startTest();
    	lead.Status = Constants.LEAD_STATUS_PERDU;
    	lead.LossReason__c = Constants.LEAD_SUIVI_TRANSFERT_INJOIGNABLE;
    	update lead;
    	Test.stopTest();
    }
}