/*
* @author Wailly LUA  (Wailly.lua@carrenet.com)
* @date 17/09/2018 (dd/mm/yyyy)
* @description Test class for ChronosCtrl_TEST
*/
@isTest
public class ChronosCtrl_TEST{
    
    static String fileName;
    static String accountName;
    static String extension;
    static String base64; 
    static String mimeType; 
    static String sfdcId; 
    static String sendType; 
    static String typeFile;
    private static final String DOCUMENT_NAME = 'DocTest';
    /*
     * @author LUA Wailly (Wailly.lua@carrenet.com)
     * @date 17/09/2018 (dd/mm/yyyy)
     * @description Initialise test environment with datas
     */
     @TestSetup
    static void initOrg(){ 
		accountName = 'Carrenet';
        extension = 'txt';
        base64 = 'RmljaGllcnMgbW9kaWZpw6lzIDoNCg0KUHJlc3RhdGlvbkhlYmRvbWFkYWlyZS5jbXAgKEhpZGUgdG90YWwgaG91cnMsIHVwZGF0ZSB0YWJsZSBkaXNwbGF5ID09PiBhdXJhOmlmKQ0KUHJlc3RhdGlvbkhlYmRvbWFkYWlyZUNvbnRyb2xsZXIuanMgKG5ldyBtZXRob2QgY3JlYXRlVGFzayAvIGNyZWF0ZSBFdmVudCwgcGVyaGFwcyBmaW5kIG5ldyB3YXkgdG8gY2FsbCBvbmUgc2luZ2xlIGZ1bmN0aW9uKQ0KDQpTYWlzaUFjdGl2aXRlLmNtcCAoY29tbWVudCBhdXJhIGhhbmRsZXIgZm9yIEFjdGl2aXR5RGVsZXRlICYgQWN0aXZpdHlWYWxpZGF0ZSkNClNhaXNpQWN0aXZpdGVDb250cm9sbGVyLmpzICh1cGRhdGUgaGFuZGxlcmV2dFNhaXNpQWN0aXZpdGVDaGFuZ2UgYmVjYXVzZSBlZGl0IGFjdGl2aXR5IG1vZGFsIGFsd2F5cyBkaXNwbGF5ZWQgd2hpbGUgdmFsaWRhdGluZyBhbmQgZGVsZXRpbmcgdGFzaykNCkFjdGl2aXRlRm9ybS5jbXAgKGRlbGV0ZSAic2xkcy1ncmlkX2FsaWduLXNwcmVhZCIgY2xhc3MpDQo='; 
        sfdcId = UserInfo.getUserId(); 
        sendType = 'companies'; 
        typeFile = 'status_document';               
        System.debug('extension==='+extension);
        System.debug('base64==='+base64);
        Blob myBlob = EncodingUtil.base64Decode(base64);
        ContentVersion cv = new ContentVersion(Title = DOCUMENT_NAME, VersionData = myBlob, PathOnClient = DOCUMENT_NAME + '.' + extension);
        insert cv;
    }

    @isTest
    static void uploadDocumentFileTest(){  
        Id docId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = :DOCUMENT_NAME].get(0).ContentDocumentId;
        Test.startTest();  
            ChronosCtrl.uploadDocumentFile(docId,  sfdcId, sendType, typeFile);
        Test.stopTest();
    }
    
    @isTest
    static void testGetContVersByDocId() {
    	Id docId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = :DOCUMENT_NAME].get(0).ContentDocumentId;
    	Test.startTest();  
            ChronosCtrl.getContVersByDocId(docId);
        Test.stopTest();
    }
}