@isTest
public with sharing class WS07_ContractSigned_TEST {
    
    private static final Integer NUMBER_DOSSIER_BGI = 99999;
    @testSetup
    static void setupData() {
    	AP04_Factory.createGenericDataSample();
    	
    	List<Lead> leads = [SELECT Id, NumeroCompteBaseGI__c, ContractSign__c, DateContractSign__c FROM Lead WHERE IsConverted = false];
    	System.assert(!leads.isEmpty());
    	System.assertEquals(false, leads.get(0).ContractSign__c);
    	System.assertEquals(null, leads.get(0).DateContractSign__c);
    	
    	leads.get(0).NumeroCompteBaseGI__c = NUMBER_DOSSIER_BGI;
    	update leads.get(0);
    }
    
    @isTest
    static void testSimpleLeadSignature() {
    	List<Lead> leads = [SELECT Id, NumeroCompteBaseGI__c, ContractSign__c FROM Lead WHERE IsConverted = false];
    	Integer nbUnconvertedLeads = leads.size();
    	
    	List<Account> accounts = [SELECT Id FROM Account WHERE NumberBGI__c = :NUMBER_DOSSIER_BGI];
    	System.assert(accounts.isEmpty());
    	
    	WS07_ContractSigned.ContractDTO dto = new WS07_ContractSigned.ContractDTO(NUMBER_DOSSIER_BGI);
    	
    	Test.startTest();
    	WS07_ContractSigned.manageSignature(dto);
    	Test.stopTest();
    	
    	// On devrait avoir trouvé une lead et celle ci devrait avoir été mise à jour puis convertie
    	Lead leadConverted = [SELECT Id, NumeroCompteBaseGI__c, ContractSign__c, DateContractSign__c, IsConverted FROM Lead WHERE Id = :leads.get(0).Id];
    	System.assertEquals(true, leadConverted.ContractSign__c);
    	System.assertNotEquals(null, leadConverted.DateContractSign__c);
    	System.assertEquals(true, leadConverted.IsConverted);
    	
    	leads = [SELECT Id, NumeroCompteBaseGI__c, ContractSign__c FROM Lead WHERE IsConverted = false];
    	System.assertEquals(nbUnconvertedLeads - 1, leads.size());
    	
    	accounts = [SELECT Id FROM Account WHERE NumberBGI__c = :NUMBER_DOSSIER_BGI];
    	System.assertEquals(1, accounts.size());
    }
    
    @isTest
    static void testSimpleAccountSignature() {
    	List<Lead> leads = [SELECT Id FROM Lead WHERE NumeroCompteBaseGI__c = :NUMBER_DOSSIER_BGI];
    	System.assert(!leads.isEmpty());
    	
    	LeadConverterProcessAE converter = new LeadConverterProcessAE(leads.get(0).Id);
    	converter.launchLeadConversion();
    	
    	List<Account> accounts = [SELECT Id, ContractSign__c, DateContractSign__c, (SELECT Id, StageName FROM Opportunities) FROM Account WHERE NumberBGI__c = :NUMBER_DOSSIER_BGI];
    	System.assertEquals(1, accounts.size());
    	System.assertEquals(false, accounts.get(0).ContractSign__c);
    	System.assertEquals(null, accounts.get(0).DateContractSign__c);
    	System.assertEquals(1, accounts.get(0).Opportunities.size());
    	System.assertEquals(Constants.OPP_STAGENAME_PROP_SENT, accounts.get(0).Opportunities.get(0).StageName);
    	
    	WS07_ContractSigned.ContractDTO dto = new WS07_ContractSigned.ContractDTO(NUMBER_DOSSIER_BGI);
    	
    	Test.startTest();
    	WS07_ContractSigned.manageSignature(dto);
    	Test.stopTest();
    	
    	// On devrait avoir la case cochée sur le compte. L'opportunité associée devrait être close.
    	accounts = [SELECT Id, ContractSign__c, DateContractSign__c, (SELECT Id, StageName FROM Opportunities) FROM Account WHERE NumberBGI__c = :NUMBER_DOSSIER_BGI];
    	System.assertEquals(true, accounts.get(0).ContractSign__c);
    	System.assertNotEquals(null, accounts.get(0).DateContractSign__c);
    	System.assertEquals(1, accounts.get(0).Opportunities.size());
    	System.assertEquals(Constants.OPP_STAGENAME_CONTRACT_SIGNED, accounts.get(0).Opportunities.get(0).StageName);
    }
}