@istest
public class SMS_Test {
    public class wsSMS_Mock implements HttpCalloutMock{
        //Implement http mock callout here
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"json":""}');
            response.setStatusCode(200);
            return response; 
        }
    }

    public static Testmethod void Test_send() {
        Id rtClientId = Utils.getAccountRecordTypeByDeveloperName(Constants.ACCOUNT_RECORDTYPE_DEVELOPERNAME_CLIENT);
        Account ent = new Account(Name = 'Entreprise 1', RecordTypeId = rtClientId);
        insert ent;
        Lead l = new Lead(MobilePhone='0601020304', Firstname='jacque', lastname='ok', company = ent.id);
        insert l;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new wsSMS_Mock());
        SMS.sendAsync('','',l.Id);
        test.stopTest();
    } 
}