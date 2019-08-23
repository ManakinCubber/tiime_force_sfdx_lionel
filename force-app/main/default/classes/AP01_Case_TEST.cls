@isTest(seealldata=false)
public with sharing class AP01_Case_TEST {
    static testMethod void checkCumulateTime(){
        Case ticket = new Case(Origin = 'Web');
        insert ticket;
        
        //Test.setCreatedDate(ticket.Id, DateTime.now().addDays(-3));
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
        System.runAs(u){
            Test.startTest();
            ticket.Status = 'Fermé';
            update ticket;

            Case cTmp = [SELECT Id, CreatedDate, CumulateTime__c, LastModifiedDate, Status From Case Where Id=:ticket.id];

            System.debug('Test case create:' + cTmp.createdDate); 
            System.debug('Test lastmodifiedDate :' + cTmp.LastModifiedDate); 
            System.debug('Test case CumulateTime__c:' + cTmp.CumulateTime__c); 
            System.debug('Test case Status:' + cTmp.Status); 
            System.assertEquals(0, cTmp.CumulateTime__c.round(), 'CumulateTime need to be 0 hours');

            Test.stopTest();
        }
        
        /**
        Case ticket = new Case(Origin = 'Web');
        insert ticket;
        
        Test.setCreatedDate(ticket.Id, DateTime.now().addDays(-3));
        
        Test.startTest();
        ticket.Status = 'Fermé';
        update ticket;
        Case c = [SELECT Id, CreatedDate, CumulateTime__c, LastModifiedDate, Status From Case Where Id=:ticket.id];
        System.assertNotEquals(c.LastModifiedDate, c.CreatedDate);
        System.assertEquals(3*24, c.CumulateTime__c, 'CumulateTime need to be 72 hours');
        Test.stopTest(); */
    }
}