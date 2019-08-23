@isTest
public with sharing class WS08_FinalKbisReceived_TEST {
    private static final Integer NUMBER_DOSSIER_BGI = 99999;
    @testSetup
    static void setupData() {
    	AP04_Factory.createGenericDataSample();
    	
    	List<Lead> leads = [SELECT Id, NumeroCompteBaseGI__c, Partenaire__c, KbisReceive__c, KbisReceptionDate__c FROM Lead WHERE IsConverted = false];
    	System.assert(!leads.isEmpty());
    	System.assertEquals(false, leads.get(0).KbisReceive__c);
    	System.assertEquals(null, leads.get(0).KbisReceptionDate__c);
    	Account tiimeAccount;
    	List<Account> tiimeAccounts = [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Name = :Constants.LEAD_BRANDING_TIIME];
    	tiimeAccount = (tiimeAccounts.isEmpty() ? null : tiimeAccounts.get(0));
    	leads.get(0).NumeroCompteBaseGI__c = NUMBER_DOSSIER_BGI;
    	leads.get(0).Partenaire__c = tiimeAccount.Id;
    	leads.get(0).Contact_Partenaire__c = tiimeAccount.Contacts.get(0).Id;
    	update leads.get(0);
    }
    
    @isTest
    static void testSimpleLeadSignature() {
    	List<Lead> leads = [SELECT Id, NumeroCompteBaseGI__c, KbisReceive__c FROM Lead WHERE IsConverted = false];
    	Integer nbUnconvertedLeads = leads.size();
    	
    	List<Account> accounts = [SELECT Id FROM Account WHERE NumberBGI__c = :NUMBER_DOSSIER_BGI];
    	System.assert(accounts.isEmpty());
    	
    	WS08_FinalKbisReceived.KbisInfoDTO dto = new WS08_FinalKbisReceived.KbisInfoDTO(NUMBER_DOSSIER_BGI, Date.newInstance(2019, 07, 08));
    	
    	Test.startTest();
    	WS08_FinalKbisReceived.manageKbisReception(dto);
    	Test.stopTest();
    	
    	// On devrait avoir trouvé une lead et celle ci devrait avoir été mise à jour
    	Lead leadConverted = [SELECT Id, NumeroCompteBaseGI__c, KbisReceive__c, KbisReceptionDate__c FROM Lead WHERE Id = :leads.get(0).Id];
    	System.assertEquals(true, leadConverted.KbisReceive__c);
    	System.assertNotEquals(null, leadConverted.KbisReceptionDate__c);
    }
    
    @isTest
    static void testSimpleAccountSignature() {
    	List<Lead> leads = [SELECT Id FROM Lead WHERE NumeroCompteBaseGI__c = :NUMBER_DOSSIER_BGI];
    	System.assert(!leads.isEmpty());
    	
    	LeadConverterProcessAE converter = new LeadConverterProcessAE(leads.get(0).Id);
    	converter.launchLeadConversion();
    	
    	List<Account> accounts = [SELECT Id, KbisReceive__c, DateKbisReceive__c FROM Account WHERE NumberBGI__c = :NUMBER_DOSSIER_BGI];
    	System.assertEquals(1, accounts.size());
    	System.assertEquals(false, accounts.get(0).KbisReceive__c);
    	System.assertEquals(null, accounts.get(0).DateKbisReceive__c);
    	
    	WS08_FinalKbisReceived.KbisInfoDTO dto = new WS08_FinalKbisReceived.KbisInfoDTO(NUMBER_DOSSIER_BGI, '2019-07-08');
    	
    	Test.startTest();
    	WS08_FinalKbisReceived.manageKbisReception(dto);
    	Test.stopTest();
    	
    	// On devrait avoir la case cochée sur le compte.
    	accounts = [SELECT Id, KbisReceive__c, DateKbisReceive__c FROM Account WHERE NumberBGI__c = :NUMBER_DOSSIER_BGI];
    	System.assertEquals(true, accounts.get(0).KbisReceive__c);
    	System.assertNotEquals(null, accounts.get(0).DateKbisReceive__c);
    }
}