@isTest
public with sharing class LTC20_SendProposal_TEST {
    
    public static final String SELECTED_OFFERS = '[{"tarifDeBase":null,"tarif":99,"periodicite":"M","offerName":"Offre Novaa","offerId":1,"libelle":"Comptabilité","idMarque":55,"id":1,"commentaire":null},{"tarifDeBase":null,"tarif":499,"periodicite":"A","offerName":"Offre Novaa","offerId":1,"libelle":"Bilan","idMarque":55,"id":2,"commentaire":null}]';
    
    @TestSetup
    static void setupData() {
    	AP04_Factory.createGenericDataSample();
    }
    
    @isTest
    static void initController() {
    	
    	Map<String, String> labels = LTC20_SendProposal.getLabels();
    	System.assert(!labels.isEmpty());
    	
    	Map<String, String> offresOptions = LTC20_SendProposal.getOffreOptions(Constants.LEAD_BRANDING_NOVAA);
    	System.assert(!offresOptions.isEmpty());
    	
    	List<Account> accounts = [SELECT Id FROM Account];
    	System.assert(!accounts.IsEmpty());
    	
    	List<ContentDocument> docs = LTC20_SendProposal.getAccountAttachments(accounts.get(0).Id);
    	System.assert(docs.isEmpty());
    	
    }
    
    @isTest
    static void saveLeadWithOffers() {
    	List<Lead> leads = [SELECT Id, Offres__c FROM Lead];
    	System.assert(!leads.isEmpty());
    	System.assert(leads.get(0).Offres__c == null);
    	
    	Test.startTest();
    	LTC20_SendProposal.save(leads.get(0).Id, null, SELECTED_OFFERS);
    	Test.stopTest();
    	
    	List<Mission__c> missions = [SELECT Id FROM Mission__c];
        System.assert(!missions.isEmpty());
    }
    
    @isTest
    static void convertLeadTest() {
    	List<Lead> leads = [SELECT Id, Offres__c FROM Lead];
    	System.assert(!leads.isEmpty());
    	List<Account> accounts = [SELECT Id FROM Account];
    	Integer nbAccounts = accounts.size();
    	
    	Test.startTest();
    	LTC20_SendProposal.leadConversion(leads.get(0).Id);
    	Test.stopTest();
    	
    	accounts = [SELECT Id FROM Account ORDER BY CreatedDate DESC];
    	System.assert(accounts.size() == nbAccounts + 1);
    	
    	Transfert__c transfert = new Transfert__c();
    	insert transfert;
    	
    	List<account> sortedAccounts = [SELECT Id FROM Account ORDER BY CreatedDate DESC];
        List<Opportunity> sortedOpps = [SELECT Id FROM Opportunity ORDER BY CreatedDate DESC];
    	
    	LTC20_SendProposal.saveAccountId(transfert.Id, sortedAccounts.get(0).Id, sortedOpps.get(0).Id);
    	
    	transfert = [SELECT Id, ConvertedAccountId__c FROM Transfert__c WHERE Id = :transfert.Id];
    	System.assert(transfert.ConvertedAccountId__c != null);
    }
    
    @isTest
    static void convertLeadWithContactDuplicateTest() {
    	List<Stakeholder__c> shs = [SELECT Id FROM Stakeholder__c];
    	Integer stakeholdersNumber = shs.size();
    	List<Lead> leads = [SELECT Id, Offres__c, MobilePhone, Email FROM Lead];
    	System.assert(!leads.isEmpty());
    	List<Contact> contacts = [SELECT Id, MobilePhone, Email FROM Contact WHERE RecordType.DeveloperName = :Constants.CONTACT_RECORDTYPE_DEVELOPERNAME_CLIENT];
    	System.assert(!contacts.isEmpty());
    	
    	contacts.get(0).MobilePhone = leads.get(0).MobilePhone;
    	contacts.get(0).Email = leads.get(0).Email;
    	update contacts.get(0);
    	
        LTC20_SendProposal.save(leads.get(0).Id, null, '[]');
        
    	Test.startTest();
    	LTC20_SendProposal.leadConversion(leads.get(0).Id);
    	Test.stopTest();
    	
    	shs = [SELECT Id FROM Stakeholder__c];
    	System.assert(shs.size() == stakeholdersNumber + 1);
    	
    }
    
    @isTest
    static void sendToBaseGITest() {
    	
    	List<Account> accounts = [SELECT Id FROM Account];
    	System.assert(!accounts.isEmpty());
    	
    	Test.startTest();
    	LTC20_SendProposal.sendToBaseGI(accounts.get(0).Id, null, new List<Id> {null} );
    	Test.stopTest();
    }
    
    @isTest
    static void sendMailTest() {
    	List<Account> accounts = [SELECT Id FROM Account];
    	System.assert(!accounts.isEmpty());
    	
    	Transfert__c transfert = new Transfert__c();
    	insert transfert;
    	
    	LTC20_SendProposal.saveAccountId(transfert.Id, accounts.get(0).Id, null);
    	
    	Test.startTest();
    	LTC20_SendProposal.sendEmailOrSmsToClient(accounts.get(0).Id,  accounts.get(0).Id, true, new List<Id> {null});
    	Test.stopTest();
    }
    
    @isTest
    static void sendSmsTest() {
    	List<Account> accounts = [SELECT Id FROM Account];
    	System.assert(!accounts.isEmpty());
    	
    	Transfert__c transfert = new Transfert__c();
    	insert transfert;
    	
    	LTC20_SendProposal.saveAccountId(transfert.Id, accounts.get(0).Id, null);
    	
    	Test.startTest();
    	LTC20_SendProposal.sendEmailOrSmsToClient(accounts.get(0).Id, accounts.get(0).Id, false, new List<Id> {null});
    	Test.stopTest();
    }
}