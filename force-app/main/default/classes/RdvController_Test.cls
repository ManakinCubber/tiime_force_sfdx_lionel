@isTest
public class RdvController_Test {
    
    public static testmethod void testRdv(){
   
        Lead l = new Lead(Lastname = 'test', Email='test@test.com', MobilePhone='0633254856', company='oui');
        insert l;
       /* group__c g = new group__c(name = 'lou');
        insert g;
        SU__c s = new SU__c(group__c = g.id);
        insert s;
        BU__c b = new BU__c(su__c = s.ID);
        insert b;*/
        team__c t = new Team__c();
        insert t;

        dateTime startTime = Datetime.newInstance(2008, 12, 12, 12, 30, 11);
        dateTime endTime = Datetime.newInstance(2008, 12, 12, 13, 30, 11);
        /*Integer offset = UserInfo.getTimezone().getOffset(StartTime);
        StartTime = StartTime.addSeconds(offset/1000);
        Integer offset2 = UserInfo.getTimezone().getOffset(EndTime);
        EndTime = EndTime.addSeconds(offset2/1000);*/
        string timeS = JSON.serialize(starttime);
        string timeE = JSON.serialize(endtime);
        string bu = 'NOVAA';
        string d = date.Today().format();
        d = d.substring(1);
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
       /* intrateamjunction__c itj = new intrateamjunction__c(intrapreneur__c = u.id, team__c = t.id, primaryRelationship__c = true);
		insert itj;*/
        event e = new Event(OwnerId = u.id, WhoId = l.id, subject = 'test',ActivityDateTime = Datetime.newInstance(2008, 12, 12, 12, 30, 2), StartDateTime = Datetime.newInstance(2008, 12, 12, 12, 30, 2), EndDateTime = Datetime.newInstance(2008, 12, 12, 13, 30, 2));
            Test.startTest();
            RdvController.getLead(l.id);
            RdvController.getEventByMember(u.id, d);
            RdvController.currentUser();
            RdvController.getEvent(JSON.serialize(u), d);
            
            /*Database.LeadConvert lc = new database.LeadConvert();
lc.setLeadId(l.id);
LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
lc.setConvertedStatus(convertStatus.MasterLabel);
Database.LeadConvertResult lcr = Database.convertLead(lc);*/
            
            RdvController.save(JSON.serialize(e), TimeE,  TimeS, l.Lastname);
            //RdvController.updateFields(l.id, u.id, e);
            Test.stopTest();
    }    
}