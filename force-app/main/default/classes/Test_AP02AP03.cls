@isTest(SeeAllData = false)
public class Test_AP02AP03 {
	
    @isTest static void test() {
        Id rtClientId = Utils.getAccountRecordTypeByDeveloperName(Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_CLIENT);
        Account ent1 = new Account(Name = 'Entreprise 1', RecordTypeId = rtClientId);
        Account ent2 = new Account(Name = 'Entreprise 2 zefkze', RecordTypeId = rtClientId);
        insert new List<Account>{ent1, ent2};
    	Test.startTest();
        
        Contact contact1 = new Contact(MobilePhone = '0601020304', LastName = 'Contact1', AccountId = ent1.Id);
        Contact contact2 = new Contact(MobilePhone = '0602030405', LastName = 'Contact2', AccountId = ent2.Id);
        insert new List<Contact>{contact1, contact2};
        Stakeholder__c sh = new Stakeholder__c(RecordTypeId = Utils.getStakeholderRecordTypeIdByDeveloperName(Constants.STAKEHOLDER_RECORDTYPE_DEVELOPERNAME_PP), Company__c = ent1.Id, Contact__c = contact2.Id, StartDate__c = Date.today(), EndDate__c = Date.today().addDays(1));
        insert sh;
        Stakeholder__c sh2 = new Stakeholder__c(RecordTypeId = Utils.getStakeholderRecordTypeIdByDeveloperName(Constants.STAKEHOLDER_RECORDTYPE_DEVELOPERNAME_PP), Company__c = ent1.Id, Contact__c = contact2.Id, StartDate__c = Date.today().addDays(2));
        insert sh2;
        sh2.PrincipalContact__c = true;
        update sh2;
        Test.stopTest();
    }
    
    @isTest static void test3() {
        Id rtClientId = Utils.getAccountRecordTypeByDeveloperName(Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_CLIENT);
        Account ent1 = new Account(Name = 'Entreprise 1', RecordTypeId = rtClientId);
        Account ent2 = new Account(Name = 'Entreprise 2 zefkze', RecordTypeId = rtClientId);
        insert new List<Account>{ent1, ent2};
        Contact contact1 = new Contact(MobilePhone = '0601020304', LastName = 'Contact1', AccountId = ent2.Id);
        Contact contact2 = new Contact(MobilePhone = '0602030405', LastName = 'Contact2', AccountId = ent2.Id);
        insert new List<Contact>{contact1, contact2};
        Stakeholder__c sh = new Stakeholder__c(RecordTypeId = Utils.getStakeholderRecordTypeIdByDeveloperName(Constants.STAKEHOLDER_RECORDTYPE_DEVELOPERNAME_PP), Company__c = ent1.Id, Contact__c = contact2.Id, StartDate__c = Date.today(), EndDate__c = Date.today().addDays(1));
        insert sh;
        Stakeholder__c sh2 = new Stakeholder__c(RecordTypeId = Utils.getStakeholderRecordTypeIdByDeveloperName(Constants.STAKEHOLDER_RECORDTYPE_DEVELOPERNAME_PP), Company__c = ent1.Id, Contact__c = contact2.Id, StartDate__c = Date.today().addDays(2), PrincipalContact__c = true);
        insert sh2;
        
        Test.startTest();
        sh2.StartDate__c = Date.today();
        try {
            update sh2;
        }
        catch(DmlException ex) {
            system.debug('message erreur -> '+ex.getMessage());
            Boolean expectedExceptionThrown =  ex.getMessage().contains('La relation entre cette entreprise et cette personne existe déjà sur la période renseignée') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        try {
            Stakeholder__c sh3 = new Stakeholder__c(RecordTypeId = Utils.getStakeholderRecordTypeIdByDeveloperName(Constants.STAKEHOLDER_RECORDTYPE_DEVELOPERNAME_PP), Company__c = ent1.Id, Contact__c = contact2.Id, StartDate__c = Date.today().addDays(1));
        	insert sh3;
        }
        catch(DmlException ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('La relation entre cette entreprise et cette personne existe déjà sur la période renseignée') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        sh2.StartDate__c = Date.today().addDays(3);
        sh2.EndDate__c = Date.today().addDays(5);
        update sh2;
        try{
            delete contact2;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Impossible de supprimer un contact qui est défini comme principal dans un stakeholder') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        contact1.AccountId = ent1.Id;
        update contact1;
        Test.stopTest();
    }
    
    @isTest static void test2() {
        
        Id rtClientId = Utils.getAccountRecordTypeByDeveloperName(Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_CLIENT);
        Account ent1 = new Account(Name = 'Entreprise 1', RecordTypeId = rtClientId);
        Account ent2 = new Account(Name = 'Entreprise 2 zefkze', RecordTypeId = rtClientId);
        insert new List<Account>{ent1, ent2};
        Contact contact2 = new Contact(MobilePhone = '0602030405', LastName = 'Contact2', AccountId = ent2.Id);
        insert contact2;
        Stakeholder__c sh = new Stakeholder__c(RecordTypeId = Utils.getStakeholderRecordTypeIdByDeveloperName(Constants.STAKEHOLDER_RECORDTYPE_DEVELOPERNAME_PP), Company__c = ent1.Id, Contact__c = contact2.Id, StartDate__c = Date.today(), EndDate__c = Date.today().addDays(1));
        insert sh;
        Stakeholder__c sh4 = new Stakeholder__c(RecordTypeId = Utils.getStakeholderRecordTypeIdByDeveloperName(Constants.STAKEHOLDER_RECORDTYPE_DEVELOPERNAME_PP), Company__c = ent1.Id, Contact__c = contact2.Id, StartDate__c = Date.today().addDays(10));
        insert sh4;
        /*
        Contact contactToDelete = new Contact(MobilePhone = '0602030409', LastName = 'ContactToDelete', AccountId = ent2.Id);
        insert contactToDelete;
        delete contactToDelete;*/
        
        Test.startTest();
        ApexPages.StandardController ctrler2 = new ApexPages.StandardController(sh4);
        CloneStakeholderController cloneAction2 = new CloneStakeholderController(ctrler2);
        PageReference ref2 = cloneAction2.cloneStakeholder();
        
        ApexPages.StandardController ctrler = new ApexPages.StandardController(sh);
        CloneStakeholderController cloneAction = new CloneStakeholderController(ctrler);
        PageReference ref = cloneAction.cloneStakeholder();
        Test.stopTest();
    }
}