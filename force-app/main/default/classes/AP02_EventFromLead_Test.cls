@isTest
public class AP02_EventFromLead_Test {

    public static testmethod void testRdv(){
      Lead l = new Lead(Lastname = 'test', Email='test@test.com', MobilePhone='0633254856', company='oui');
        insert l;
        team__c t = new Team__c();
        insert t;
        dateTime startTime = Datetime.newInstance(2008, 12, 12, 12, 30, 2);
        dateTime endTime = Datetime.newInstance(2008, 12, 12, 13, 30, 2);
        string timeS = JSON.serialize(starttime);
        string timeE = JSON.serialize(endtime);
        string bu = 'NOVAA';
        string d = date.Today().format();
        User u = new User(LastName = 'Pepito',
                          FirstName='Bambino',
                          Alias = 'Michel',
                          Email = 'pepito.Bambino@michel.com',
                          Username = 'pepito.Bambino@michel.com',
                          Phone = '0621548698',
                          TimeZoneSidKey = 'GMT',
                          LanguageLocaleKey = 'en_US',
                          EmailEncodingKey = 'UTF-8',
                          LocaleSidKey = 'en_US',
                          ProfileId = '00e0N000001MnUYQA0'
                         );
        insert u;
        event e = new Event(OwnerId = u.id, WhoId = l.id, subject = 'test',ActivityDateTime = Datetime.newInstance(2008, 12, 12, 12, 30, 2), StartDateTime = Datetime.newInstance(2008, 12, 12, 12, 30, 2), EndDateTime = Datetime.newInstance(2008, 12, 12, 13, 30, 2));
        test.startTest();
        insert e;
        test.stopTest();
        
    }
}