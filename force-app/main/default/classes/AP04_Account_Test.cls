@isTest
public class AP04_Account_Test {
  @isTest static void test() {
        Id rtClientId = Utils.getAccountRecordTypeByDeveloperName(Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_CLIENT);
        Account ent = new Account(Name = 'Entreprise 1', RecordTypeId = rtClientId);
        
        Test.startTest();
        insert ent;
        ent.Name = 'Entreprise Prospect V2';
        update ent;
        ent.Name = 'Entreprise Prospect V3';
        update ent;
        Test.stopTest();
    }
    
  @isTest static void test2() {
        Id rtClientId = Utils.getAccountRecordTypeByDeveloperName(Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_CLIENT);
        Account ent = new Account(Name = 'Entreprise 1', RecordTypeId = rtClientId);

        insert ent;
        ent.Name = 'Entreprise Prospect V2';
        update ent;
        ent.Name = 'Entreprise Prospect V3';
        update ent;
        ent.Name = 'Entreprise Prospect V4';
        update ent;
        List<HistoryAccount__c> listHA = [SELECT id, newValue__c, EffectiveDate__c FROM HistoryAccount__c WHERe entreprise__c = :ent.Id];
        Test.startTest();
        listHA[1].newValue__c = 'Entreprise Prospect V25';
        update listHA[1];
        Date today = Date.today();
        listHA[2].EffectiveDate__c = today.addDays(-1);
        update listHA[2];
        listHA[2].EffectiveDate__c = today.addDays(10);
        update listHA[2];
        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Sample_Heading', CRON_EXP, new CronMajAccount() );
        Test.stopTest();
    }    
}