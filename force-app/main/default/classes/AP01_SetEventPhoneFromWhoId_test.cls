@isTest(seealldata=false)
public class AP01_SetEventPhoneFromWhoId_test {
    static testMethod void Test () {
        id rtID = [select id from Recordtype where sobjectType='Account' and developerName='Prospect'].id;
        Account acc = new Account(name='test',recordtypeId=rtID);
        insert acc;
        Contact ctt = new Contact(lastname='test',firstname='test',accountID=acc.id,mobilephone='0621000000');
        insert ctt;
        test.startTest();
        event evt = new event(subject='test',whoid=ctt.id,DurationInMinutes=5,ActivityDateTime=datetime.now());
        insert evt;
        lead ld = new lead(lastname='test',firstname='test',company='test',mobilephone='0621000000');
        insert ld;
        evt.whoid=ld.id;
        update evt;
        evt.whoid=null;
        update evt;
        test.stopTest();
    }
}