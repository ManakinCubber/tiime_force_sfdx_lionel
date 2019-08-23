@isTest
public class TestBatchHA {
    @isTest static void test() {
        Id rtClientId = Utils.getAccountRecordTypeByDeveloperName(Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_CLIENT);
        Account ent = new Account(Name = 'Entreprise 1', RecordTypeId = rtClientId);
        insert ent;
        ent.Name = 'Entreprise Prospect V2';
        update ent;
        ent.Name = 'Entreprise Prospect V3';
        update ent;
        ent.Name = 'Entreprise Prospect V4';
        update ent;
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Sample_Heading', CRON_EXP, new CronMajAccount() );
        Test.stopTest();
    }
}