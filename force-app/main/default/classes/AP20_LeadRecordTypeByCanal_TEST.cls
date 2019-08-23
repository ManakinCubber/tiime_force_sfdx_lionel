@isTest
public class AP20_LeadRecordTypeByCanal_TEST {
	
	@isTest
    static void testSwitchRecordTypeCanalPartenariatInsert() {
    	List<Lead> leads = AP04_Factory.newWebLeadsFactory(2);
        leads[0].Canal__c = Constants.LEAD_CANAL_PARTENARIATS;
        id rtPartenariatID = Utils.getLeadRecordTypeByDeveloperName(Constants.LEAD_RECORDTYPE_DEVELOPERNAME_PARTENARIAT);
	    id rtLeadClientID = Utils.getLeadRecordTypeByDeveloperName(Constants.LEAD_RECORDTYPE_DEVELOPERNAME_LEAD_CLIENT);

        Test.startTest();
        insert leads;
        Test.stopTest();
        
        Lead leadP = [SELECT Id,RecordTypeId, Canal__c FROM Lead WHERE Id = :leads[0].Id];
        Lead leadC = [SELECT Id,RecordTypeId, Canal__c FROM Lead WHERE Id = :leads[1].Id];
        System.assertEquals(rtPartenariatID, leadP.RecordTypeId);
        System.assertEquals(rtLeadClientID, leadC.RecordTypeId);
    }
    
    @isTest
    static void testSwitchRecordTypeCanalPartenariatUpdate() {
    	List<Lead> leads = AP04_Factory.newWebLeadsFactory(2);
        leads[0].Canal__c = Constants.LEAD_CANAL_PARTENARIATS;
        id rtPartenariatID = Utils.getLeadRecordTypeByDeveloperName(Constants.LEAD_RECORDTYPE_DEVELOPERNAME_PARTENARIAT);
	    id rtLeadClientID = Utils.getLeadRecordTypeByDeveloperName(Constants.LEAD_RECORDTYPE_DEVELOPERNAME_LEAD_CLIENT);
        insert leads;
        
        Test.startTest();
        leads[0].Canal__c = Constants.LEAD_CANAL_SEO;
        leads[1].Canal__c = Constants.LEAD_CANAL_PARTENARIATS;
        update leads;
        Test.stopTest();
        
        Lead leadC = [SELECT Id,RecordTypeId, Canal__c FROM Lead WHERE Id = :leads[0].Id];
        Lead leadP = [SELECT Id,RecordTypeId, Canal__c FROM Lead WHERE Id = :leads[1].Id];
        System.assertEquals(rtLeadClientID, leadC.RecordTypeId);
        System.assertEquals(rtPartenariatID, leadP.RecordTypeId);

    }
}